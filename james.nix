{ pkgs, ... }: {
  users.groups.james = { };
  users.users.james = {
    isNormalUser = true;
    group = "james";
    extraGroups = [ "wheel" ];
    initialPassword = "pass";
    packages = with pkgs;
      [
      	# things you always want installed no exceptions
        vim
        git
	zsh
      ];
    # make sure we always have a shell
    shell = pkgs.zsh;
  };
  # make sure we always have a shell
  programs.zsh.enable = true;
}
