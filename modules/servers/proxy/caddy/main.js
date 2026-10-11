const host = "{{.Host}}";
const services = '{{placeholder "http.vars.activeServices"}}'.split(" ");

for (var i = 0; i < services.length; i++) {
  services[i] = services[i].toLowerCase();
}

const faviconSize = 256;
const serviceFavicons = [
  ["jellyfin", "jellyfin.org"],
  ["sonarr", "sonarr.tv"],
  ["radarr", "radarr.video"],
  ["flaresolverr", "flaresolverr.com"],
  ["prowlarr", "prowlarr.com"],
  ["syncthing", "syncthing.net"],
  ["qbittorrent", "qbittorrent.org"],
  ["seerr", "seerr.dev"],
  ["transmission", "transmissionbt.com"],
];
const serviceFaviconMap = new Map(serviceFavicons);

// if .local mDNS domain, subdomains are not supported
// so it has to route to a subpath
function getServiceURL(serviceName) {
  if (/.*\.local$/.test(host)) {
    return `https://${host}/${serviceName}`;
  } else {
    return `https://${serviceName}.${host}`;
  }
}

function getFaviconURL(serviceName) {
  if (serviceFaviconMap.has(serviceName)) {
    return `https://www.google.com/s2/favicons?domain=${serviceFaviconMap.get(serviceName)}&sz=${faviconSize}`;
  } else {
    // best guess, no gaurantees
    return getServiceURL(serviceName) + "/favicon.ico";
  }
}

function makeServiceButton(serviceName) {
  const button = document.createElement("div");
  button.onclick = (_) => {
    location.href = getServiceURL(serviceName);
  };
  button.classList.add("serviceButton");
  const icon = document.createElement("img");
  icon.classList.add("serviceIcon");
  icon.src = getFaviconURL(serviceName);
  const name = document.createElement("p");
  name.innerText = serviceName[0].toUpperCase() + serviceName.substr(1); // capitalize first letter
  button.appendChild(icon);
  button.appendChild(name);
  return button;
}

document.addEventListener("DOMContentLoaded", () => {
  const container = document.getElementById("serviceContainer");
  for (const service of services) {
    container.appendChild(makeServiceButton(service));
  }
});
