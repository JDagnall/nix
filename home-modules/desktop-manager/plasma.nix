{
	lib,
	config,
	...
}: {
	options = {
		desktop-manager.plasma.enable = lib.mkEnableOption "Enable KDE Plasma 6 user config";
	};
	config =
		lib.mkIf config.desktop-manager.plasma.enable {
			# programs.plasma = {
			# 	enable = true;
			# 	overrideConfig = false;
			# 	# resetFiles = []; # wipe plasma config files on each gen
			# 	# resetFilesExclude = [];
			# 	configFile = {};
			# 	desktop = {
			# 		icons = {
			# 			size = 2; # 0-7
			# 		};
			# 	};
			# 	hotkeys = {
			# 		commands = {
			# 			term =
			# 				lib.mkIf config.term.wezterm.enable {
			# 					command = "wezterm";
			# 					key = "Meta+T";
			# 					comment = "Open wezterm";
			# 				};
			# 		};
			# 	};
			# 	shortcuts = {
			# 		kwin = {
			# 			"Switch to Desktop 1" = "Meta+1";
			# 			"Switch to Desktop 2" = "Meta+2";
			# 			"Window to Desktop 1" = "Meta+!";
			# 			"Window to Desktop 2" = "Meta+@";
			# 		};
			# 	};
			# 	krunner = {
			# 		position = "center";
			# 		shortcuts.launch = "Meta+D";
			# 	};
			# 	kscreenlocker = {
			# 		lockOnResume = true;
			# 		autoLock = true;
			# 		passwordRequired = true;
			# 		timeout = 5; # min
			# 	};
			# 	kwin = {
			# 		borderlessMaximizedWindows = true;
			# 		effects = {
			# 			blur.enable = true;
			# 			desktopSwitching.animation = "slide";
			# 		};
			# 		nightLight = {
			# 			enable = true;
			# 			mode = "times";
			# 			time = {
			# 				morning = "08:00";
			# 				evening = "22:00";
			# 			};
			# 		};
			# 		titlebarButtons = {
			# 			left = ["more-window-actions" "application-menu"];
			# 			right = ["minimize" "maximize" "close"];
			# 		};
			# 		virtualDesktops = {
			# 			number = 2;
			# 		};
			# 	};
			# 	powerdevil = {
			# 		AC = {
			# 			autoSuspend = {
			# 				action = "sleep";
			# 				idleTimeout = 600;
			# 			};
			# 			dimDisplay = {
			# 				enable = true;
			# 				idleTimeout = 60;
			# 			};
			# 			dimKeyboard.enable = true;
			# 			displayBrightness = 10;
			# 			keyboardBrightness = 10;
			# 			inhibitLidActionWhenExternalMonitorConnected = true;
			# 			powerButtonAction = "showLogoutScreen";
			# 			powerProfile = "performance";
			# 			whenLaptopLidClosed = "sleep";
			# 			whenSleepingEnter = "hybridSleep";
			# 		};
			# 		battery = {
			# 			autoSuspend = {
			# 				action = "sleep";
			# 				idleTimeout = 600;
			# 			};
			# 			dimDisplay = {
			# 				enable = true;
			# 				idleTimeout = 60;
			# 			};
			# 			dimKeyboard.enable = true;
			# 			displayBrightness = 10;
			# 			keyboardBrightness = 10;
			# 			inhibitLidActionWhenExternalMonitorConnected = true;
			# 			powerButtonAction = "showLogoutScreen";
			# 			powerProfile = "powerSaving";
			# 			whenLaptopLidClosed = "sleep";
			# 			whenSleepingEnter = "hybridSleep";
			# 		};
			# 		lowBattery = {
			# 			autoSuspend = {
			# 				action = "hibernate";
			# 				idleTimeout = 60;
			# 			};
			# 			dimDisplay = {
			# 				enable = true;
			# 				idleTimeout = 20;
			# 			};
			# 			dimKeyboard.enable = true;
			# 			displayBrightness = 10;
			# 			keyboardBrightness = 10;
			# 			inhibitLidActionWhenExternalMonitorConnected = true;
			# 			powerButtonAction = "showLogoutScreen";
			# 			powerProfile = "powerSaving";
			# 			whenLaptopLidClosed = "sleep";
			# 			whenSleepingEnter = "hybridSleep";
			# 		};
			# 	};
			# 	panels = [
			# 		{
			# 			location = "bottom";
			# 			hiding = "windowsgobelow";
			# 			lengthMode = "fill";
			# 			opacity = "translucent";
			# 			screen = "all";
			# 			widgets = [
			# 				{
			# 					name = "org.kde.plamsa.kickoff";
			# 					config = {
			# 						General = {
			# 							icon = "nix-snowflake-white";
			# 							alphaSort = true;
			# 						};
			# 					};
			# 				}
			# 				{
			# 					iconTasks = {
			# 						launchers = [];
			# 					};
			# 				}
			# 				"org.kde.plasma/marginseparator"
			# 				{
			# 					systemTray.items = {
			# 						shown = [
			# 							"org.kde.plasma.battery"
			# 							"org.kde.plasma.bluetooth"
			# 							"org.kde.plasma.networkmanagement"
			# 							"org.kde.plasma.volume"
			# 						];
			# 						hidden = [];
			# 					};
			# 				}
			# 				{
			# 					digitalClock = {
			# 						calendar.firstDayOfWeek = "monday";
			# 						time.format = "12h";
			# 					};
			# 				}
			# 			];
			# 		}
			# 	];
			# 	session.general.askForConfirmationOnLogout = false;
			# 	session.sessionRestore.restoreOpenApplicationsOnLogin = "onLastLogout";
			# };
			# stylix.targets =
			# 	lib.mkIf config.stylix.enableHomeConfig {
			# 		kde = {
			# 			enable = true;
			# 			useWallpaper = true;
			# 			# decorations = "";
			# 		};
			# 		qt.enable = lib.mkDefault true;
			# 	};
		};
}
