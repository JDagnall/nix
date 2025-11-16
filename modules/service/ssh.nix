{
	lib,
	config,
	...
}: {
	options = {
		service.sshd.enable = lib.mkEnableOption "Enable the ssh daemon config";
		service.sshd.james.authKeys.enable = lib.mkEnableOption "Add ssh keys of hosts to authorizedKeys for user james.";
		ssh.host-pub-keys =
			lib.mkOption {
				type = lib.types.attrsOf lib.types.str;
				description = "List of my user public keys at different hosts for easy reference";
				default = {};
			};
	};
	config = {
		ssh.host-pub-keys = {
			pc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINi4vaMqWu0EleK32TMjaW/EgMHuNI7iMHYLuHER6p0n james.t.dagnall@gmail.com";
			framework = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFqllBz9dOTXIAezDIM24SwFD2VLlQJu+XeR2HOmOd48 james@framework";
			server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEPdrwbgx4Cc8/ty3tynVtUy1RkeyUFc48fJtSEci6K8 james.t.dagnall@gmail.com";
		};
		users.users.james.openssh.authorizedKeys.keys =
			lib.mkIf config.service.sshd.james.authKeys.enable [
				config.ssh.host-pub-keys.pc
				config.ssh.host-pub-keys.framework
				config.ssh.host-pub-keys.server
			];
		sops.secrets = let
			host = config.networking.hostName;
		in
			lib.mkIf (config.sops.enable && config.service.sshd.enable) {
				"ssh/root/private" = {
					sopsFile = ../../secrets/${host}/ssh.yaml;
					path = "/etc/ssh/ssh_host_ed25519_key";
				};
				"ssh/root/public" = {
					sopsFile = ../../secrets/${host}/ssh.yaml;
					path = "/etc/ssh/ssh_host_ed25519_key.pub";
				};
				"ssh/james/private" = {
					sopsFile = ../../secrets/${host}/ssh.yaml;
					path = "/home/james/.ssh/key";
					owner = "james";
				};
				"ssh/james/public" = {
					sopsFile = ../../secrets/${host}/ssh.yaml;
					path = "/home/james/.ssh/key.pub";
					owner = "james";
				};
			};
		services.openssh =
			lib.mkIf config.service.sshd.enable {
				enable = true;
				settings = {
					PasswordAuthentication = false;
					PermitRootLogin = "no";
					# cant think of any reason not to restrict to me
					# Allowusers = ["james"];
				};
			};
	};
}
