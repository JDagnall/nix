{
	lib,
	config,
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
				matchBlocks = {
					server = {
						host = "server.lan";
						user = "james";
						identityFile = "~/.ssh/key";
					};
					framework = {
						host = "framework.lan";
						user = "james";
						identityFile = "~/.ssh/key";
					};
					pc = {
						host = "pc.lan";
						user = "james";
						identityFile = "~/.ssh/key";
					};
				};
			};
		};
}
