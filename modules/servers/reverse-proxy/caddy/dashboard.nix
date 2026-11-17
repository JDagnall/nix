{
    self,
    lib,
    ...
}: {
    # TODO: really needs to be spun out into its own thing, or replaced
    # with something else.
    flake.modules.nixos.caddyDashboard = {config, ...}: {
        key = "my/nixos/caddy-dashboard";
        imports = with self.modules.nixos; [caddy];
        config = let
            default_http_path = "caddy/www";
            dashboardIcons = lib.filter (x: x.dashboardIcon.enable && x.reverseProxy.enable) (lib.attrValues config.my.servers.servers);

            # get a file extension
            getFileExt = path: let
                m = builtins.match ".*\\.([^./]+)$" path;
            in
                if m == null
                then ""
                else "." + builtins.head m;

            iconDetails = lib.mergeAttrsList (map (server: {
                ${server.name} = {
                    name = server.name;
                    icon = "./icons/${server.name}${getFileExt server.dashboardIcon.icon}";
                };
            })
            dashboardIcons);
            iconDetailsJSONLink = {
                "${default_http_path}/caddy-dashboard-icons.json" = {
                    text = builtins.toJSON iconDetails;
                    user = config.services.caddy.user;
                    group = config.services.caddy.group;
                };
            };

            # grabs all the non-nix files from this directory + the json
            web_files = lib.fileset.toList (lib.fileset.fileFilter (file: !file.hasExt "nix") ./.);

            icon_links = map (server: {
                "${default_http_path}/icons/${server.name}${getFileExt server.dashboardIcon.icon}" = {
                    source = server.dashboardIcon.icon;
                    user = config.services.caddy.user;
                    group = config.services.caddy.group;
                };
            })
            dashboardIcons;

            web_file_links = map (x: {
                "${default_http_path}/${baseNameOf x}" = {
                    source = x;
                    user = config.services.caddy.user;
                    group = config.services.caddy.group;
                };
            })
            web_files;
        in {
            environment.etc = lib.mergeAttrsList (web_file_links ++ icon_links ++ [iconDetailsJSONLink]);
            my.servers.proxy.caddy.extraHandlers = [
                (hostname: ''
                    @dashboard host ${hostname}
                    handle @dashboard {
                        root /etc/caddy/www
                        templates {
                            mime text/html text/plain text/javascript
                        }
                        file_server
                    }
                '')
            ];
        };
    };
}
