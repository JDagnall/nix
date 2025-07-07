{ pkgs, ... }:
{
    users.groups.james = { };
    users.users.james = {
        isNormalUser = true;
        group = "james";
        extraGroups = [ "wheel" ];
        initialPassword = "pass";
        packages = with pkgs; [
            vim
            git
        ];
        shell = pkgs.zsh;
    };
}
