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
						hostname = "mini.lan";
						host = "server";
						user = "james";
						identityFile = "~/.ssh/key";
					};
					framework = {
						hostname = "framework.lan";
						host = "framework";
						user = "james";
						identityFile = "~/.ssh/key";
					};
					pc = {
						hostname = "pc.lan";
						host = "pc";
						user = "james";
						identityFile = "~/.ssh/key";
					};
					book = {
						hostname = "book.lan";
						host = "book";
						user = "james";
						identityFile = "~/.ssh/key";
					};
					orion = {
						hostname = "orion.lan";
						host = "orion";
						user = "james";
						identityFile = "~/.ssh/key";
					};
				};
			};
		};
}
