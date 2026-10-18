{
    self,
    lib,
    ...
}: {
    flake.modules.nixos.arr = {config, ...}: let
        cfg = config.my.servers.arr;
    in {
        imports = with self.modules.nixos; [servers];
        key = "my/nixos/arr";
        options.my = {
            servers.arr = {
                # TODO: need something here for defining access to an actual directory
                # obviously that would need to be host specific, but I would like a service
                # that ensures that all files in the 'arr' directory belong at least to the arr
                # group
                user = {
                    name = lib.mkOption {
                        description = "A user to assign the arr media data to";
                        default = "arr";
                        type = lib.types.str;
                    };
                };
                group = {
                    name = lib.mkOption {
                        description = "A common group for all arr servers to use, this simply defines access directorie(s) where the media is stored.";
                        default = "arr";
                        type = lib.types.str;
                    };
                    umask = lib.mkOption {
                        description = "Umask for the group.";
                        default = 0003;
                        type = lib.types.int;
                    };
                    members = lib.mkOption {
                        description = "Users to add to the arr group";
                        default = [];
                        type = with lib.types; listOf str;
                    };
                };
            };
        };
        config = {
            users.users.${cfg.user.name} = {
                isSystemUser = true;
                group = "${cfg.group.name}";
            };
            users.groups.${cfg.group.name} = {
                members = cfg.group.members;
            };
        };
    };
}
