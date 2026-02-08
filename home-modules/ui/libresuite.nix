{
	pkgs,
	lib,
	config,
	...
}: {
	options = {
		ui.libreoffice.enable = lib.mkEnableOption "Install libreoffice suite";
	};
	config =
		lib.mkIf config.ui.libreoffice.enable {
			home.packages = with pkgs; [
				libreoffice-qt-fresh
				hunspell # language dictionaries for libreoffice
				hunspellDicts.en_GB-ise
				hunspellDicts.en_AU
			];
		};
}
