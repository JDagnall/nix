{
    lib,
    config,
    ...
}: {
    options.service.languagetool = {
        enable = lib.mkEnableOption "Enable languagetool server";
    };
    config = lib.mkIf config.service.languagetool.enable {
        services.languagetool = {
            enable = true;
            port = 8081;
            public = false;
            settings = {};
            jvmOptions = ["-Xmx512m"];
        };
    };
}
