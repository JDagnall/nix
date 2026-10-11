{...}: {
    flake.modules.nixos.languagetool = {...}: {
        services.languagetool = {
            enable = true;
            port = 8081;
            public = false;
            settings = {};
            jvmOptions = ["-Xmx512m"];
        };
    };
}
