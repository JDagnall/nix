{
	lib,
	config,
	inputs,
	osConfig,
	...
}: {
	# import the noctalia module (its a flake input)
	imports = [
		inputs.noctalia.homeModules.default
	];
	options = {
		ui.noctalia = {
			enable = lib.mkEnableOption "Enable nocatalia config.";
			systemd.enable = lib.mkEnableOption "Enable launching noctalia from a system service.";
			lockScreen.enable = lib.mkEnableOption "Enable using noctalia as the idle manager.";
			osd.enable = lib.mkEnableOption "Enable using noctalia as the osd.";
			wallpaper.enable = lib.mkEnableOption "Enable using noctalia as the wallpaper.";
			notificationManager.enable = lib.mkEnableOption "Enable using noctalia as the notification manager.";
			launcherShortcut = lib.mkEnableOption "Enable shortcut (probably Meta+D) for the launcher.";
			deviceProfile =
				lib.mkOption {
					default = "desktop";
					type = lib.types.enum ["desktop" "laptop"];
					description = "The device profile for things like the idle timeouts and battery monitoring, ect.";
				};
			clipboardManager.enable =
				lib.mkOption {
					type = lib.types.bool;
					default = true;
					description = "Whether to enable the clipboard manager, requires wl-clipboard.";
				};
		};
	};
	config = let
		noctaliaCfg = config.ui.noctalia;
	in
		lib.mkIf config.ui.noctalia.enable {
			assertions = [
				{
					assertion = config.window-manager.hyprland.enable;
					message = "Noctalia requires a wayland compositor.";
				}
				{
					assertion = noctaliaCfg.enable != config.ui.waybar.enable;
					message = "Noctalia and waybar should not be enabled together.";
				}
				{
					assertion = noctaliaCfg.enable != config.ui.hyprpaper.enable;
					message = "Noctalia and hyprpaper should not be enabled together.";
				}
				{
					assertion = noctaliaCfg.enable != config.ui.hyprlock.enable;
					message = "Noctalia and hyprlock should not be enabled together.";
				}
				{
					assertion = noctaliaCfg.enable != config.ui.swayosd.enable;
					message = "Noctalia and swayosd should not be enabled together.";
				}
				{
					assertion = noctaliaCfg.enable != config.ui.mako.enable;
					message = "Noctalia and mako should not be enabled together.";
				}
			];

			programs.noctalia-shell = {
				enable = true;
				# currently choosing to launch from compositor
				systemd.enable = noctaliaCfg.systemd.enable;
				settings = {
					bar = {
						barType = "floating";
						position = "top";
						monitors = [];
						density = "default";
						showOutline = false;
						showCapsule = true;
						# backgroundOpacity = 0.93;
						# useSeparateOpacity = false;
						floating = false;
						marginVertical = 4;
						marginHorizontal = 4;
						frameThickness = 8;
						frameRadius = 12;
						outerCorners = true;
						hideOnOverview = false;
						displayMode = "always_visible";
						autoHideDelay = 500;
						autoShowDelay = 150;
						widgets = {
							left = [
								{id = "Launcher";}
								{id = "Clock";}
								{id = "SystemMonitor";}
								{id = "AudioVisualizer";}
							];
							center = [
								{id = "Workspace";}
							];
							right =
								[
									{id = "Tray";}
									{id = "NotificationHistory";}
									{id = "MediaMini";}
									{id = "Volume";}
									{id = "Network";}
									{id = "Bluetooth";}
								]
								++ lib.optionals (noctaliaCfg.deviceProfile == "laptop") [
									{id = "Battery";}
									{id = "Brightness";}
								]
								++ [
									{id = "ControlCenter";}
								];
						};
						screenOverrides = [];
					};
					general = {
						avatarImage =
							builtins.fetchurl {
								url = "https://cdnb.artstation.com/p/assets/images/images/035/450/685/large/ryth-asset.jpg";
								name = "pyro_frog.jpg";
								sha256 = "sha256:0gcnw96b43z2l5pm2iaarz6rxb7snxn8a8vldxvqn6hzppvl4wp8";
							};
						showScreenCorners = false;
						forceBlackScreenCorners = false;
						animationSpeed = 1.75;
						animationDisabled = false;
						compactLockScreen = false;
						lockOnSuspend = true;
						showSessionButtonsOnLockScreen = true;
						showHibernateOnLockScreen = false;
						enableShadows = true;
						shadowDirection = "bottom_right";
						shadowOffsetX = 2;
						shadowOffsetY = 3;
						language = "";
						allowPanelsOnScreenWithoutBar = true;
						showChangelogOnStartup = true;
						telemetryEnabled = false;
						enableLockScreenCountdown = true;
						lockScreenCountdownDuration = 10000;
						autoStartAuth = false;
						allowPasswordWithFprintd = osConfig.service.fprintd.enable;
					};
					ui = {
						tooltipsEnabled = true;
						panelsAttachedToBar = true;
						settingsPanelMode = "attached";
						wifiDetailsViewMode = "grid";
						bluetoothDetailsViewMode = "grid";
						networkPanelView = "wifi";
						bluetoothHideUnnamedDevices = false;
						boxBorderEnabled = false;
					};
					location = {
						name = "Brisbane";
						weatherEnabled = true;
						weatherShowEffects = true;
						use12hourFormat = false;
						showWeekNumberInCalendar = false;
						showCalendarEvents = false;
						showCalendarWeather = true;
						analogClockInCalendar = false;
						# Monday?
						firstDayOfWeek = -1;
						hideWeatherTimezone = false;
						hideWeatherCityName = false;
					};
					calendar = {
						cards = [
							{
								enabled = true;
								id = "calendar-header-card";
							}
							{
								enabled = true;
								id = "calendar-month-card";
							}
							{
								enabled = true;
								id = "weather-card";
							}
						];
					};
					wallpaper = {
						enabled = noctaliaCfg.wallpaper.enable;
						overviewEnabled = false;
						# directory = "";
						# monitorDirectories = [];
						enableMultiMonitorDirectories = false;
						showHiddenFiles = false;
						viewMode = "single";
						setWallpaperOnAllMonitors = true;
						fillMode = "fill";
						automationEnabled = false;
						wallpaperChangeMode = "random";
						randomIntervalSec = 300;
						transitionDuration = 1500;
						transitionType = "random";
						transitionEdgeSmoothness = 0.05;
						panelPosition = "follow_bar";
						hideWallpaperFilenames = false;
						sortOrder = "name";
					};
					appLauncher = {
						enableClipboardHistory = noctaliaCfg.clipboardManager.enable;
						autoPasteClipboard = false;
						enableClipPreview = true;
						clipboardWrapText = true;
						# just assuming here that wl-clipboard is being used. May need to fix later
						clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
						clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
						position = "center";
						pinnedApps = [];
						useApp2Unit = false;
						sortByMostUsed = true;
						terminalCommand = lib.mkIf (config.home.sessionVariables ? TERMINAL) "${config.home.sessionVariables.TERMINAL} -e";
						customLaunchPrefixEnabled = false;
						customLaunchPrefix = "";
						viewMode = "list";
						showCategories = true;
						iconMode = "tabler";
						showIconBackground = false;
						enableSettingsSearch = true;
						enableWindowsSearch = true;
						ignoreMouseInput = false;
						screenshotAnnotationTool = "";
					};
					controlCenter = {
						position = "close_to_bar_button";
						diskPath = "/";
						shortcuts = {
							left = [
								{id = "Network";}
								{id = "Bluetooth";}
								{id = "NoctaliaPerformance";}
							];
							right =
								[
									{id = "Notifications";}
									{id = "KeepAwake";}
								]
								++ lib.optionals (noctaliaCfg.deviceProfile == "laptop") [
									{id = "PowerProfile";}
									{id = "NightLight";}
								];
						};
						cards =
							[
								{
									enabled = true;
									id = "profile-card";
								}
								{
									enabled = true;
									id = "shortcuts-card";
								}
								{
									enabled = true;
									id = "audio-card";
								}
							]
							++ lib.optionals (noctaliaCfg.deviceProfile == "laptop") [
								{
									enabled = false;
									id = "brightness-card";
								}
							]
							++ [
								{
									enabled = true;
									id = "weather-card";
								}
								{
									enabled = true;
									id = "media-sysmon-card";
								}
							];
					};
					systemMonitor = {
						cpuWarningThreshold = 80;
						cpuCriticalThreshold = 90;
						tempWarningThreshold = 80;
						tempCriticalThreshold = 90;
						gpuWarningThreshold = 80;
						gpuCriticalThreshold = 90;
						memWarningThreshold = 80;
						memCriticalThreshold = 90;
						swapWarningThreshold = 80;
						swapCriticalThreshold = 90;
						diskWarningThreshold = 80;
						diskCriticalThreshold = 90;
						cpuPollingInterval = 1000;
						gpuPollingInterval = 3000;
						enableDgpuMonitoring = false;
						memPollingInterval = 1000;
						diskPollingInterval = 30000;
						networkPollingInterval = 1000;
						loadAvgPollingInterval = 3000;
						useCustomColors = false;
					};
					dock = {
						enabled = false;
						# position = "bottom";
						# displayMode = "auto_hide";
						# backgroundOpacity = 1;
						# floatingRatio = 1;
						# size = 1;
						# onlySameOutput = true;
						# monitors = [];
						# pinnedApps = [];
						# colorizeIcons = false;
						# pinnedStatic = false;
						# inactiveIndicators = false;
						# deadOpacity = 0.6;
						# animationSpeed = 1;
					};
					network = {
						wifiEnabled = true;
						bluetoothRssiPollingEnabled = false;
						bluetoothRssiPollIntervalMs = 10000;
						wifiDetailsViewMode = "grid";
						bluetoothDetailsViewMode = "grid";
						bluetoothHideUnnamedDevices = false;
					};
					sessionMenu = {
						enableCountdown = true;
						countdownDuration = 2000;
						position = "center";
						showHeader = true;
						largeButtonsStyle = true;
						largeButtonsLayout = "single-row";
						showNumberLabels = true;
						powerOptions = [
							{
								action = "lock";
								enabled = true;
							}
							{
								action = "suspend";
								enabled = true;
							}
							{
								action = "hibernate";
								enabled = true;
							}
							{
								action = "reboot";
								enabled = true;
							}
							{
								action = "logout";
								enabled = true;
							}
							{
								action = "shutdown";
								enabled = true;
							}
						];
					};
					notifications = {
						enabled = noctaliaCfg.notificationManager.enable;
						monitors = [];
						location = "top_right";
						overlayLayer = true;
						respectExpireTimeout = false;
						lowUrgencyDuration = 3;
						normalUrgencyDuration = 8;
						criticalUrgencyDuration = 15;
						enableKeyboardLayoutToast = true;
						saveToHistory = {
							low = true;
							normal = true;
							critical = true;
						};
						sounds = {
							enabled = false;
							volume = 0.5;
							separateSounds = false;
							criticalSoundFile = "";
							normalSoundFile = "";
							lowSoundFile = "";
							excludedApps = "discord,firefox,chrome,chromium,edge";
						};
						enableMediaToast = false;
					};
					osd = {
						enabled = noctaliaCfg.osd.enable;
						location = "top_middle";
						autoHideMs = 2000;
						overlayLayer = true;
						enabledTypes = [
							0
							1
							2
						];
						monitors = [];
					};
					audio = {
						volumeStep = 5;
						volumeOverdrive = false;
						cavaFrameRate = 30;
						visualizerType = "linear";
						mprisBlacklist = [];
						preferredPlayer = "";
						volumeFeedback = false;
					};
					brightness = {
						brightnessStep = 5;
						enforceMinimum = true;
						enableDdcSupport = false;
					};
					colorSchemes = {
						darkMode = true;
					};
					templates = {
						activeTemplates = [];
						enableUserTheming = true;
					};
					nightLight = {
						enabled = noctaliaCfg.deviceProfile == "laptop";
						forced = false;
						autoSchedule = true;
						nightTemp = "4000";
						dayTemp = "6500";
						manualSunrise = "06:30";
						manualSunset = "18:30";
					};
					hooks = {
						enabled = false;
					};
					desktopWidgets = {
						enabled = false;
						gridSnap = false;
						monitorWidgets = [];
					};
				};
				plugins = {};
				pluginSettings = {};
			};
			stylix.targets.noctalia-shell.enable = config.stylix.enableHomeConfig;
		};
}
