{
    pkgs,
    lib,
    config,
    inputs,
    ...
}: let
    cfg = config.zfs;
in {
    imports = [inputs.disko.nixosModules.disko];
    options = {
        zfs = {
            enable = lib.mkEnableOption ''
                Enable ZFS RAID array for orion. This will override
                the kernel version probably.
            '';
        };
    };
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
            # sata1 = {
            # id = "wwn-0x5000c5007a0640d0"; # busted
            # };
        };
    in
        lib.mkIf cfg.enable {
            boot.supportedFilesystems = {zfs = true;};
            boot.zfs = {
                forceImportRoot = false;
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
                        ZED_EMAIL_ADDR = lib.mkIf config.msmtp.enable ["root"];
                        ZED_EMAIL_PROG = lib.mkIf config.msmtp.enable "${pkgs.msmtp}/bin/msmtp";
                        ZED_EMAIL_OPTS = "@ADDRESS@";
                        ZED_NOTIFY_INTERVAL_SECS = 3600;
                        ZED_NOTIFY_VERBOSE = false; # only notify when pool is unhealthy
                        ZED_USE_ENCLOSURE_LEDS = true;
                        ZED_SCRUB_AFTER_RESILVER = true;
                    };
                    enableMail = config.msmtp.enable;
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
                defaults.monitored = "-a -o on -s (S/../.././02|L/../1/./03)" + lib.optionalString config.msmtp.enable " -m root";
                notifications.mail = lib.mkIf config.msmtp.enable {
                    mailer = "${pkgs.msmtp}/bin/msmtp";
                };
            };
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
                zpool = {
                    raid = {
                        type = "zpool";
                        mode = "raidz1"; # 1 disk parity
                        mountpoint = "/raid"; # nixos .mount unit mountpoint
                        mountOptions = ["nofail" "x-systemd.device-timeout=10s"];
                        options = {
                            ashift = "12";
                            mountpoint = "legacy"; # tells zfs not to mount, so nixos mounts the fs the normal way
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
                        };
                    };
                };
            };
        };
}
