{
	pkgs,
	lib,
	config,
	osConfig,
	...
}: {
	options = {
		ui.obsidian.enable = lib.mkEnableOption {description = "Enable obsidian config.";};
	};
	config =
		lib.mkIf config.ui.obsidian.enable {
			programs.obsidian = {
				enable = true;
				cli.enable = true;
				vaults = {
					classes =
						lib.mkIf osConfig.service.syncthing.folders.classes.enable {
							enable = true;
							target = "classes/obsidian";
						};
				};
				defaultSettings = {
					cssSnippets = [
						{
							enable = true;
							name = "wider_margins";
							source = ./snippets/margin.css;
						}
					];
					extraFiles = {
						latex-preamble = {
							target = "preamble.sty";
							source = ./preamble.sty;
						};
						vim-bindings-config = {
							target = ".obsidian.vimrc";
							source = ./.obsidian.vimrc;
						};
					};
					corePlugins = [
						"file-explorer"
						"global-search"
						"switcher"
						"graph"
						"backlink"
						"outgoing-link"
						"tag-pane"
						"page-preview"
						"daily-notes"
						"templates"
						"note-composer"
						"command-palette"
						"editor-status"
						"bookmarks"
						"outline"
						"word-count"
						"file-recovery"
						"bases"
					];
					communityPlugins = [
						{
							pkg =
								pkgs.fetchFromGitHub {
									owner = "blacksmithgu";
									repo = "obsidian-dataview";
									rev = "0.5.68";
									hash = "sha256-vmf96wjDrGeGVjZJGKUC8dUTu+lCxy0EIF5DkybAdko=";
								};
							enable = true;
						}
						{
							pkg =
								pkgs.fetchFromGitHub {
									owner = "platers";
									repo = "obsidian-linter";
									rev = "1.31.2";
									hash = "sha256-AOQmciZ0Dw1e1QkQt5ezNrksKacQKSKsGMyGfDGPmU0=";
								};
							enable = true;
						}
						{
							pkg =
								pkgs.fetchFromGitHub {
									owner = "xRyul";
									repo = "obsidian-image-converter";
									rev = "1.4.3";
									hash = "sha256-ACCGadnOvAxNjAcyWTyInOE5vT1tiiiS0lUeJponDMs=";
								};
							settings = {
								folderPresets = [
									{
										name = "media";
										type = "CUSTOM";
										customTemplate = "/media";
									}
								];
								selectedFolderPreset = "media";
								filenamePresets = [
									{
										name = "parent + note  + num";
										customTemplate = "{parentfolder}-{notename}-{counter:001}";
										skipRenamePatterns = "";
										conflictResolution = "increment";
									}
								];
								selectedFilenamePreset = "parent + note  + num";
							};
							enable = true;
						}
						{
							pkg =
								pkgs.fetchFromGitHub {
									owner = "ckRobinson";
									repo = "multi-column-markdown";
									rev = "0.9.1";
									hash = "sha256-pdNvfMq64cDaE6iNvD0CUwF3icLxx/v53nzNwUsJJm8=";
								};
							enable = true;
						}
						{
							pkg =
								pkgs.fetchFromGitHub {
									owner = "nadavspi";
									repo = "obsidian-relative-line-numbers";
									rev = "3.1.0";
									hash = "sha256-ZBfBWmAIuaJlD4VKLn/2k0jWtzI5j+ewsSzpjJaCnAY=";
								};
							enable = true;
						}
						{
							pkg =
								pkgs.fetchFromGitHub {
									owner = "Automattic";
									repo = "harper-obsidian-plugin";
									rev = "2.0.0";
									hash = "sha256-aGOwOPRDq0LJpABawifEfeloo2U9qCVC8av5ssNguzk=";
								};
							enable = true;
						}
						{
							pkg =
								pkgs.fetchFromGitHub {
									owner = "MahmoudFawzyKhalil";
									repo = "obsidian-global-search-and-replace";
									rev = "0.5.0";
									hash = "sha256-TAvhaqpYtCS8fdnWBwKl9RlPckvgLALIGE+KhdyafOg=";
								};
							enable = true;
						}
						{
							pkg =
								pkgs.fetchFromGitHub {
									owner = "wei2912";
									repo = "obsidian-latex";
									rev = "0.4.1";
									hash = "sha256-XCPYpXBJNjppDIO5R+hGUk+zRYrHx1aCtjB0hwaCZdg=";
								};
							enable = true;
						}
						{
							settings = {
								profiles = [
									{
										title = "global";
										content = "'::pb|' -> '<div style=\"page-break-after: always;\"></div>|'\n";
									}
								];
								activeProfile = "global";
							};
							enable = true;
							pkg =
								pkgs.fetchFromGitHub {
									owner = "aptend";
									repo = "typing-transformer-obsidian";
									rev = "0.4.9";
									hash = "sha256-MKcJ0tQxNxZcKMO23ZmJCOh5WvQmm5On7v1uFCKpe5c=";
								};
						}
						{
							settings = {
								vimrcFileName = ".obsidian.vimrc";
								vimStatusPromptMap = {
									normal = "🟢N";
									insert = "🟠I";
									visual = "🟡V";
									replace = "🔴R";
								};
							};
							enable = true;
							pkg =
								pkgs.fetchFromGitHub {
									owner = "esm7";
									repo = "obsidian-vimrc-support";
									rev = "0.10.2";
									hash = "sha256-q6QQ6Knh7WviccJJxPhxmyl63zPHjZvNcbAOVPbDwKc=";
								};
						}
						{
							enable = true;
							pkg =
								pkgs.fetchFromGitHub {
									owner = "connerohnesorge";
									repo = "vim-toggle";
									rev = "1.1.0";
									hash = "sha256-FsELIybYNeNiEcL5QFQbRPwH4AVVaJtj1jDVOfqY73g=";
								};
						}
					];
				};
			};
			stylix.targets.obsidian = {
				enable = true;
				vaultNames = [] ++ lib.optionals osConfig.service.syncthing.folders.classes.enable ["classes"];
			};
		};
}
