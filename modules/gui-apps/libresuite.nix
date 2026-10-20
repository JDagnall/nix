{...}: {
    flake.modules.homeManager.libresuite = {pkgs, ...}: {
        config = {
            home.packages = with pkgs; [
                libreoffice-qt-stable
                hunspell # language dictionaries for libreoffice
                hunspellDicts.en_GB-ise
                hunspellDicts.en_AU
            ];
        };
    };
}
