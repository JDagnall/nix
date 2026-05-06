{
	lib,
	config,
	osConfig,
	...
}: {
	options = {
		shell.ssh.enable = lib.mkEnableOption "Enable ssh user config.";
	};
	config =
		lib.mkIf config.shell.ssh.enable {
			programs.ssh = {
				enable = true;
				enableDefaultConfig = false;
				# can only reliably resolve these hosts is with tailscale
				matchBlocks =
					lib.mkIf osConfig.service.tailscale.enable {
						mini = {
							hostname = "mini";
							host = "server";
							user = "james";
							identityFile = "~/.ssh/key";
						};
						framework = {
							hostname = "framework";
							host = "framework";
							user = "james";
							identityFile = "~/.ssh/key";
						};
						pc = {
							hostname = "pc";
							host = "pc";
							user = "james";
							identityFile = "~/.ssh/key";
						};
						book = {
							hostname = "book";
							host = "book";
							user = "james";
							identityFile = "~/.ssh/key";
						};
						orion = {
							hostname = "orion";
							host = "orion";
							user = "james";
							identityFile = "~/.ssh/key";
						};
					};
			};
		};
}
