const host = "{{.Host}}";

// first test if a subpath exists, if not try a subdomain
// TODO: this should probably be specified in the json
function getServerURL(serverName) {
  if (/.*\.local$/.test(host)) {
    return `https://${host}/${serverName}`;
  } else {
    return `https://${serverName}.${host}`;
  }
}

function makeServerIcon(server) {
  const button = document.createElement("div");
  button.onclick = (_) => {
    location.href = getServerURL(server.name);
  };
  button.classList.add("serviceButton");
  const icon = document.createElement("img");
  icon.classList.add("serviceIcon");
  icon.src = server.icon;
  const name = document.createElement("p");
  name.innerText = server.name[0].toUpperCase() + server.name.substr(1); // capitalize first letter
  button.appendChild(icon);
  button.appendChild(name);
  return button;
}

async function loadIconJSON() {
  try {
    const response = await fetch("./caddy-dashboard-icons.json");
    icons = await response.json();
    return icons;
  } catch (error) {
    console.log(`Failed to load JSON: ${error}`);
    return null;
  }
}

function createIcons(icons) {
  if (icons == null) {
    return;
  }
  const container = document.getElementById("serviceContainer");
  for (const server of Object.values(icons)) {
    container.appendChild(makeServerIcon(server));
  }
}

document.addEventListener("DOMContentLoaded", () => {
  loadIconJSON().then((icons) => createIcons(icons));
});
