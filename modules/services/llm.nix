# this could all easily be a server rather than a service, but for now
# i just want it locally
# could also move this to servers, still use it locally and just have caddy
# make revproxies
# this also groups everything into a systemd tartget that needs to be started
{
    self,
    lib,
    inputs,
    ...
}: let
    target = {
        wantedBy = lib.mkForce ["local-llm.target"];
        partOf = ["local-llm.target"];
    };
    ollamaPort = 11434;
    searxPort = 13219;
    open-webuiPort = 13171;
    mcpSearxPort = 10778;
in {
    flake.modules.nixos.local-llm = {...}: {
        config = {
            systemd.targets."local-llm" = {
                description = "Local llm related services including ollama.";
                # doesn't start on boot
            };
        };
    };
    flake.modules.nixos.ollama = {
        pkgs,
        config,
        ...
    }: {
        imports = with self.modules.nixos; [gpu local-llm];
        options = {
            my.services.ollama = {
                models = lib.mkOption {
                    type = with lib.types; listOf str;
                    default = [];
                    description = "The models to be installed, aquired through `ollama pull`.";
                };
            };
        };
        config = let
            cfg = config.my.services.ollama;
        in {
            systemd.services.ollama = target; # add to target
            # special case, this one also needs to be a dependency of ollama
            systemd.services.ollama-model-loader = {
                wantedBy = lib.mkForce ["local-llm.target" "ollama.service"];
                partOf = ["local-llm.target"];
            };
            services.ollama = let
                gpuType = config.my.hardware.gpu.type;
            in {
                enable = true;
                package =
                    if gpuType == "nvidia"
                    then pkgs.ollama-cuda
                    else if gpuType == "amd"
                    then pkgs.ollama-rocm
                    else pkgs.ollama;
                # home = ;
                host = "localhost";
                # group = ;
                port = ollamaPort;
                loadModels = cfg.models;
                syncModels = true;
                openFirewall = false;
                # rocmOverrideGfx =;
                environmentVariables = {
                    OLLAMA_FLASH_ATTENTION = "1";
                    OLLAMA_KV_CACHE_TYPE = "q8_0"; # needs flash attention
                    OLLAMA_CONTEXT_LENGTH = "16384";
                    OLLAMA_NUM_PARALLEL = "1";
                    OLLAMA_KEEP_ALIVE = "30m";
                };
            };
        };
    };
    flake.modules.nixos.searx = {
        pkgs,
        config,
        ...
    }: {
        imports = with self.modules.nixos; [sops local-llm home-manager-interface];
        config = {
            sops = {
                secrets = let
                    host = config.networking.hostName;
                in {
                    "llm/searx/key" = {
                        sopsFile = "${inputs.secrets}/${host}/llm.yaml";
                    };
                };
                templates."searx-env" = let
                    sopsPlaceholder = config.sops.placeholder;
                in {
                    content = ''
                        SEARXNG_SECRET=${sopsPlaceholder."llm/searx/key"}
                    '';
                };
            };
            systemd.services.searx = target; # add to target
            services.searx = {
                enable = true;
                # domain = ;
                openFirewall = false;
                # limiterSettings ={};
                settings = {
                    use_default_settings = true;
                    general = {};
                    search = {
                        safe_search = 2;
                        formats = ["html" "json"];
                    };
                    server = {
                        port = searxPort;
                        bind_address = "localhost";
                        secret_key = "@SEARXNG_SECRET@";
                    };
                };
                environmentFile = config.sops.templates."searx-env".path;
            };
            home-manager = lib.mkIf config.my.home-manager.enabled {
                sharedModules = [self.modules.homeManager.searx-mcp-local];
            };

            # this does need internet access itself, not just access
            # to searXNG so it has to run outside of any sandbox
            # ATM I am only using searx for its MCP capability but I suppose I
            # could add a toggle for this
            systemd.services.mcp-searxng = {
                inherit (target) wantedBy partOf;
                after = ["searx.service"];
                requires = ["searx.service"];
                environment = {
                    SEARXNG_URL = "http://localhost:${toString searxPort}";
                    MCP_HTTP_PORT = "${toString mcpSearxPort}";
                    MCP_HTTP_HOST = "localhost";
                };
                serviceConfig = {
                    ExecStart = "${pkgs.mcp-searxng}/bin/mcp-searxng";
                    User = "searx";
                    Group = "searx";
                    # maybe block LAN targets
                    # IPAddressDeny = [];
                    ProtectSystem = "strict";
                    ProtectHome = true;
                    PrivateTmp = true;
                    NoNewPrivileges = true;

                    ReadOnlyPaths = [];
                    # ReadWritePaths = ;

                    CapabilityBoundingSet = "";
                    DevicePolicy = "closed";
                    LockPersonality = true;
                    ProtectClock = true;
                    ProtectControlGroups = true;
                    ProtectHostname = true;
                    ProtectKernelLogs = true;
                    ProtectKernelModules = true;
                    ProtectKernelTunables = true;
                    ProtectProc = "invisible";
                    PrivateDevices = true;
                    PrivateMounts = true;
                    PrivateUsers = true;
                    PrivateIPC = true;
                    RemoveIPC = true;
                    RestrictAddressFamilies = [
                        "AF_INET"
                        "AF_INET6"
                        "AF_UNIX"
                    ];
                    RestrictNamespaces = true;
                    RestrictRealtime = true;
                    SystemCallArchitectures = "native";
                    SystemCallErrorNumber = "EPERM";
                    SystemCallFilter = [
                        "@system-service"
                        "@privileged"
                    ];
                    UMask = "0077";
                };
            };
        };
    };

    flake.modules.homeManager.searx-mcp-local = {osConfig, ...}: {
        config = {
            assertions = [
                {
                    assertion = osConfig.services.searx.enable;
                    message = "Searxng will need to be enabled for the searx-mcp to work.";
                }
            ];

            programs.mcp.servers."searx" = {
                description = "An internet metasearch engine which aggregates results from various search services and databases.";
                environment = {
                    SEARXNG_URL = "http://localhost:${toString searxPort}";
                };
                url = "http://localhost:${toString mcpSearxPort}/mcp";
                # command = "${lib.getExe pkgs.mcp-searxng}";
                # this is a freeform submodule and I can use these in other modules
                host = "localhost";
                port = mcpSearxPort;
                sandbox = {
                    url = "http://localhost:${toString mcpSearxPort}/mcp";
                    port = mcpSearxPort;
                };
            };
        };
    };

    # This thing is like 4GB of python lol
    flake.modules.nixos.open-webui = {config, ...}: {
        config = {
            # has its own license for some stupid reason
            my.allowedUnfreePkgNames = ["open-webui"];
            systemd.services.open-webui = target;
            services.open-webui = {
                enable = true;
                port = open-webuiPort;
                host = "localhost";
                openFirewall = false;
                # stateDir = ;
                environment =
                    {
                        ANONYMIZED_TELEMETRY = "False";
                        DO_NOT_TRACK = "True";
                        SCARF_NO_ANALYTICS = "True";
                    }
                    // lib.optionalAttrs config.services.ollama.enable {
                        OLLAMA_BASE_URL = "http://localhost:${toString ollamaPort}";
                    }
                    // lib.optionalAttrs config.services.searx.enable {
                        ENABLE_WEB_SEARCH = "True";
                        WEB_SEARCH_ENGINE = "searxng";
                        SEARXNG_QUERY_URL = "http://localhost:${toString searxPort}/search?q=<query>&format=json";
                    };
                # environmentFile = "";
            };
        };
    };

    flake.modules.homeManager.mcp = {config, ...}: {
        options = {
            my.services.mcp = {
                allowedServers = lib.mkOption {
                    type = with lib.types; nullOr (listOf str);
                    default = null;
                    description = "Names of enabled MCP servers. If null, it is assumed that no configured servers are enabled.";
                };
            };
        };
        config = let
            cfg = config.my.services.mcp;
            allowedServers =
                if cfg.allowedServers != null
                then cfg.allowedServers
                else [];
            serverToggles = lib.genAttrs allowedServers (_: {enabled = true;});
        in {
            programs.mcp = {
                enable = true;
                servers = serverToggles;
            };
        };
    };
}
