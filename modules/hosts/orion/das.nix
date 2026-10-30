{
    self,
    lib,
    inputs,
    ...
}: {
    flake.modules.nixos.orion = {pkgs, ...}: let
    in {
        imports = with self.modules.nixos; [inputs.disko.nixosModules.disko msmtp];
        config = let
            disks = {
                sas1 = {
                    id = "wwn-0x5000c500413b007b";
                };
                sas2 = {
                    id = "wwn-0x5000c500413b35d3";
                };
                sas3 = {
                    id = "wwn-0x5000c500412abbbf";
                };
                sata1 = {
                    id = "wwn-0x500003998bb00f05";
                };
                sata2 = {
                    id = "wwn-0x5000c5003edc3d59";
                };
                sata3 = {
                    id = "wwn-0x500003992b701242";
                };
            };
        in {
            boot.supportedFilesystems = {zfs = true;};
            boot.zfs = {
                forceImportRoot = false;
            };
            my = {
                services.msmtp = {
                    accounts = {
                        gmail = {
                            host = "smtp.gmail.com";
                            auth = true;
                            user = "james.t.dagnall";
                            from = "james.t.dagnall@gmail.com";
                        };
                    };
                    defaultAccount = "gmail";
                    defaultAlias = {
                        to = "james.t.dagnall@gmail.com";
                    };
                };
            };
            # overriding kernelPackages and falling back to the last LTS version
            # which ZFS supports, this should gaurantee that ZFS supports the kernel version
            # this is also usually the default `linuxPackages` but im manually specifying it here
            # when the LTS version is bumped I will change it
            boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_18;
            # ZFS required this, to ensure the array is imported on the correct ID.
            # Bit random but ok.
            networking.hostId = "b24f2708";
            services.zfs = {
                autoScrub = {
                    enable = true;
                    pools = []; # empty == all
                    interval = "monthly";
                };
                zed = {
                    settings = {
                        ZED_DEBUG_LOG = "/tmp/zed.debug.log";
                        ZED_EMAIL_ADDR = ["root"];
                        ZED_EMAIL_PROG = "${pkgs.msmtp}/bin/msmtp";
                        ZED_EMAIL_OPTS = "@ADDRESS@";
                        ZED_NOTIFY_INTERVAL_SECS = 3600;
                        ZED_NOTIFY_VERBOSE = false; # only notify when pool is unhealthy
                        ZED_USE_ENCLOSURE_LEDS = true;
                        ZED_SCRUB_AFTER_RESILVER = true;
                    };
                    enableMail = true;
                };
            };

            # drive health monitoring
            services.smartd = {
                enable = true;
                devices = map (disk: {device = "/dev/disk/by-id/${disk.id}";}) (lib.attrValues disks);
                autodetect = false;
                # Custom default directives applied to all monitored drives:
                # -a : Monitor all SMART parameters
                # -o on : Enable SMART automatic offline data collection
                # -s (S/../.././02|L/../01/./03) : Run Short self-test daily at 2AM, Long test monthly on the 1st at 3AM
                # -m root : Send mail alerts to root
                defaults.monitored = "-a -o on -s (S/../.././02|L/../1/./03) -m root";
                notifications.mail = {
                    mailer = "${pkgs.msmtp}/bin/msmtp";
                };
            };
            environment.systemPackages = with pkgs; [smartmontools];
            # I assume zed runs as root
            # users.groups."msmtp".members = lib.mkIf config.msmtp.enable [];
            # TODO: I would like if disko could label the drives and the partitions
            disko.devices = {
                disk = lib.mapAttrs (name: disk: {
                    type = "disk";
                    device = "/dev/disk/by-id/${disk.id}";
                    content = {
                        type = "gpt";
                        partitions = {
                            zfs = {
                                size = "100%";
                                content = {
                                    type = "zfs";
                                    pool = "raid";
                                };
                            };
                        };
                    };
                })
                disks;
                # The configuration here is not really 'declarative' as in it should
                # change based on the rest of the system configuration. Disko is not
                # able to update the state of the drives without wiping them.
                # This is really just to keep track of thier state and remake them if need be.
                # Would be cool tho is disko had a zfs option where it could tear down and
                # remake the pool / datasets
                zpool = {
                    raid = {
                        type = "zpool";
                        mode = "raidz1"; # 1 disk parity
                        # mountOptions = ["nofail" "x-systemd.device-timeout=10s"];
                        options = {
                            ashift = "12";
                        };
                        rootFsOptions = {
                            compression = "zstd";
                            "com.sun:auto-snapshot" = "false";
                            acltype = "posixacl";
                            xattr = "sa";
                        };
                        datasets = {
                            "media" = {
                                type = "zfs_fs";
                                mountpoint = "/raid/media"; # nixos .mount unit mountpoint
                                # dont fail if the pool cant be imported on boot, because the
                                # DAS may not be plugged in etc etc.
                                mountOptions = ["nofail" "x-systemd.device-timeout=10s"];
                                options = {
                                    mountpoint = "legacy"; # tells zfs not to mount, so nixos mounts the fs the normal way
                                    recordsize = "1M";
                                };
                            };
                            "immich" = {
                                type = "zfs_fs";
                                mountpoint = "/raid/immich"; # nixos .mount unit mountpoint
                                # dont fail if the pool cant be imported on boot, because the
                                # DAS may not be plugged in etc etc.
                                mountOptions = ["nofail" "x-systemd.device-timeout=10s"];
                                options = {
                                    mountpoint = "legacy"; # tells zfs not to mount, so nixos mounts the fs the normal way
                                    recordsize = "1M";
                                };
                            };
                        };
                    };
                };
            };
        };
    };
}
