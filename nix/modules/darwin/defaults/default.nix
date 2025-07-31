# macOS system defaults configuration
{ config, lib, ... }:

let
  cfg = config.mySystem;
  inherit (lib) mkIf;
in
{
  config = {
    # System settings
    system.defaults = {
      # Dock configuration
      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.2;
        expose-animation-duration = 0.1;
        launchanim = false;
        magnification = false;
        minimize-to-application = true;
        mouse-over-hilite-stack = true;
        orientation = "bottom";
        show-process-indicators = true;
        show-recents = false;
        static-only = true;
        tilesize = 48;
      };

      # Finder configuration
      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        CreateDesktop = false;
        FXDefaultSearchScope = "SCcf"; # Current folder
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "Nlsv"; # List view
        QuitMenuItem = true;
        ShowPathbar = true;
        ShowStatusBar = true;
        _FXShowPosixPathInTitle = true;
      };

      # Trackpad configuration
      trackpad = {
        Clicking = true;
        Dragging = true;
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = true;
      };

      # Menu bar configuration
      menuExtraClock = {
        Show24Hour = true;
        ShowAMPM = false;
        ShowDayOfWeek = true;
        ShowDate = 1; # Always
      };

      # Global system preferences
      NSGlobalDomain = {
        # Appearance
        AppleInterfaceStyle = "Dark";
        AppleInterfaceStyleSwitchesAutomatically = false;

        # Keyboard
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;

        # Mouse/Trackpad
        AppleEnableMouseSwipeNavigateWithScrolls = true;
        AppleEnableSwipeNavigateWithScrolls = true;

        # Text and input
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSNavPanelExpandedStateForSaveMode = true;
        PMPrintingExpandedStateForPrint = true;

        # Window behavior
        NSWindowResizeTime = 0.001;

        # Measurement units
        AppleMeasurementUnits = "Inches";
        AppleMetricUnits = 0;
        AppleTemperatureUnit = "Fahrenheit";
      };

      # Screen saver and security
      screensaver = {
        askForPassword = true;
        askForPasswordDelay = 0;
      };

      # Login window
      loginwindow = {
        DisableConsoleAccess = true;
        GuestEnabled = false;
        PowerOffDisabledWhileLoggedIn = true;
        RestartDisabledWhileLoggedIn = true;
        ShutDownDisabledWhileLoggedIn = true;
      };

      # Security and privacy
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;

      # Universal Access
      universalaccess = {
        closeViewScrollWheelToggle = true;
        HIDScrollZoomModifierMask = 262144; # Control key
        mouseDriverCursorSize = 1.0;
        reduceMotion = false;
        reduceTransparency = false;
      };

      # Activity Monitor
      ActivityMonitor = {
        IconType = 2; # CPU Usage
        ShowCategory = 100; # All Processes
        SortColumn = "CPUUsage";
        SortDirection = 0;
      };

      # Custom user defaults for applications
      CustomUserPreferences = mkIf (cfg.profileType == "work") {
        # Work-specific application defaults
        "com.apple.Safari" = {
          IncludeDevelopMenu = true;
          WebKitDeveloperExtrasEnabledPreferenceKey = true;
        };
        "com.apple.mail" = {
          DisableReplyAnimations = true;
          DisableSendAnimations = true;
        };
      } // mkIf (cfg.profileType == "personal") {
        # Personal-specific application defaults
        "com.spotify.client" = {
          AutoPlay = false;
        };
      };
    };

    # Security settings
    security.pam.enableSudoTouchId = true;
  };
}
