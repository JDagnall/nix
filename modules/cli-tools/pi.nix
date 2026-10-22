# https://github.com/microvm-nix/microvm.nix is an alternative to bwrap here.
# Its complicated and creates a virtualised nixos config in a qemu container.
# But it is a much safer alternative if I ever give this thing code-execution.
{lib, ...}: {
    flake.modules.homeManager.pi = {
        pkgs,
        config,
        osConfig,
        ...
    }: {
        config = let
            ollamaEnabled = osConfig.services.ollama.enable;
            ollamaModels = osConfig.services.ollama.loadModels or [];
            ollamaPort = osConfig.services.ollama.port or 11434;

            pi-sandboxed = let
                # for a server to be mapped into the sandbox it must have and a `host`, a `port` and a `sandbox.port`
                # these are needed to map local servers network traffic into the sandbox
                mcpServers = map (x: x.value // {name = x.name;}) (lib.attrsToList config.programs.mcp.servers);
                otherServers =
                    []
                    ++ lib.optional ollamaEnabled {
                        name = "ollama";
                        host = osConfig.services.ollama.host;
                        port = ollamaPort;
                        sandbox = {
                            port = ollamaPort;
                        };
                    };
                # only the enabled mcp servers with a specified port, and either a hostname or a url
                filterServer = server:
                    lib.all (x: x == true) (map (filter: filter server) [
                        (x: x ? port && x ? host && x ? name)
                        (x: x ? sandbox.port)
                    ]);
                mapServer = server:
                    lib.pipe server [
                        (x: lib.filterAttrs (_: x: x != null) x)
                    ];
                servers = builtins.filter filterServer (map mapServer (mcpServers ++ otherServers));

                # this creates a unix socket that maps the local tcp traffic of the mcp server
                #
                mkSocket = server: ''
                    socat UNIX-LISTEN:"$sockdir/${server.name}.sock",fork TCP:${server.host}:${toString server.port} & \
                    SOCK_PROC_IDS+=("$!")
                '';
                # socket files are binded to the bubblewrap env,
                # this makes the socat command to bind those sockets to the local network device
                # in bubble wrap
                mkBridge = server: ''socat TCP-LISTEN:${toString server.sandbox.port},bind=127.0.0.1,fork,reuseaddr UNIX-CONNECT:"/run/bridge/${server.name}.sock" &'';

                # these are so that hostname can be resolved inside the sandbox
                # may need to do some stuff with this if I ever want this to reach out to an
                # external MCP server
                sandboxHosts = pkgs.writeText "sandbox-hosts" "127.0.0.1 localhost\n";
                sandboxNss = pkgs.writeText "sandbox-nsswitch.conf" "hosts: files\n";
            in
                pkgs.writeShellApplication {
                    name = "pi";
                    runtimeInputs = with pkgs; [bubblewrap ripgrep fd socat];
                    # all read only for the minute
                    # would need to give it write access for edit perms,
                    text = ''
                        repo="$PWD"
                        sockdir="$(mktemp -d)" # place to put the socket files
                        chmod 700 "$sockdir"

                        SOCK_PROC_IDS=()
                        ${lib.concatStringsSep "\n" (map (server: mkSocket server) servers)}

                        # makes sure to kill the socket processses
                        trap 'kill "''${SOCK_PROC_IDS[@]}" 2>/dev/null; rm -rf "$sockdir"' EXIT

                        bwrap \
                          --unshare-all \
                          --die-with-parent --new-session \
                          --tmpfs "$HOME" \
                          --bind "${config.programs.pi-coding-agent.configDir}" "$HOME/.pi/agent" \
                          --bind "$sockdir" /run/bridge \
                          --chdir "$repo" \
                          --ro-bind "$repo" "$repo" \
                          --ro-bind /nix/store /nix/store \
                          --ro-bind ${sandboxHosts} /etc/hosts \
                          --ro-bind ${sandboxNss} /etc/nsswitch.conf \
                          --proc /proc --dev /dev --tmpfs /tmp \
                          --setenv HOME "$HOME" \
                          --setenv TERM "$TERM" \
                          --setenv LANG "$LANG" \
                          ${pkgs.bash}/bin/bash -c '
                              ${lib.concatStringsSep "\n" (map (server: mkBridge server) servers)}

                              ${pkgs.pi-coding-agent}/bin/pi "$@"
                          ' bash "$@"
                    '';
                };
        in {
            programs.pi-coding-agent = {
                enable = true;
                package = pi-sandboxed;
                # context = ; global context
                configDir = "${config.home.homeDirectory}/.pi/agent";
                # appendSystem = ; additional system prompt
                # extraPackages = ;
                models = {
                    providers = {
                        ollama = lib.mkIf ollamaEnabled {
                            api = "openai-completions";
                            apiKey = "ollama";
                            baseUrl = "http://localhost:${toString ollamaPort}/v1";
                            models = map (model: {id = model;}) ollamaModels;
                        };
                    };
                };
                # https://pi.dev/docs/latest/settings
                settings = {
                    # defaultModel = "";
                    # defaultProvider = "";
                    # enabledModels =[];
                    # defaultThinkingLevel = ;
                    # modelThinkingLevels = {
                    # "ollama/qwen:36" = "";
                    # };
                    # thinkingBudgets = ;
                    # Available built-in tools are read, bash,
                    #  powershell, edit, write, grep, find, and ls
                    compaction = {
                        enabled = true;
                        # reserveTokens = ;
                        # keepRecentTokens = ;
                        # modelOverrides = ;
                    };
                    defaultTools = [
                        "read"
                        "grep"
                        "ls"
                        "find"
                        "-write"
                        "-bash"
                        "-edit"
                    ];
                    tuiMode = "fullscreen"; #regular
                    # theme = "system";
                    # skills = [];
                    # enableSkillCommands = false;
                    # prompts = [];
                    # extensions = [];
                    # packages = [];
                    enableAnalytics = false;
                    enableInstallTelemetry = false;
                };
                # https://pi.dev/docs/latest/keybindings
                keybindings = {
                };
            };
            home.file.".pi/agent/mcp.json" = let
                mcpCfg = config.programs.mcp;
                McpCommonAttrs = server: {
                    exposure = server.exposure or "direct"; # may not be optimal
                    description = server.description or "An MCP server";
                    timeout = server.timeout or 30;
                    env = server.environment or server.env or null;
                };
                allowedAttrs = ["name" "command" "args" "env" "cwd" "exposure" "timeout" "description" "url"];
                mapServer = server:
                    lib.pipe server [
                        (x: server // (McpCommonAttrs x))
                        (x: x // (x.sandbox or {}))
                        (x: lib.filterAttrs (n: v: (builtins.elem n allowedAttrs) && (v != null)) x)
                    ];
                filterServer = server:
                    lib.all (x: x == true) (map (filter: filter server) [
                        (x: x.enabled or false)
                        # this mcp.json is from the perspective of the bwrap sandbox
                        # so a sandbox url has to be specified or a command
                        (x: x ? command || (x ? sandbox.url && x.sandbox.url != null))
                    ]);
                servers = map mapServer (lib.filter filterServer (map (x: x.value // {name = x.name;}) (lib.attrsToList mcpCfg.servers)));
                mkMcp = server: lib.nameValuePair server.name (lib.removeAttrs server ["name"]);
            in {
                enable = mcpCfg.enable;
                text = builtins.toJSON {
                    mcpServers = lib.genAttrs' servers mkMcp;
                };
            };
        };
    };
}
