{...}: {
    flake.modules.nixos.orion.james = {config, ...}: {
        # TODO: should import a version of my user module here
        # imports = with self.modules.nixos; [];
        config = {
            # so I can use 'sendmail'
            users.groups."msmtp".members = [config.users.groups."james".name];
            # add myself to the media group
            users.groups."media".members = ["james"];
            my.gaming.minecraft-servers = {
                groupMembers = ["james"];
            };
        };
    };
    # flake.modules.home.pc.james = {...}: {};
}
