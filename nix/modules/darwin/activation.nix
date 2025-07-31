# Additional system activation scripts
# Handles tasks that need to run after system rebuild

{ config, pkgs, ... }:

{
  # System activation scripts for tasks not handled by nix-darwin directly
  system.activationScripts.postUserActivation.text = ''
    # Create project directories (from Ansible personal role)
    mkdir -p ~/Projects/code/

    # Create Screenshots directory
    mkdir -p ~/Pictures/Screenshots

    # Set proper permissions
    chmod 755 ~/Projects/code/
    chmod 755 ~/Pictures/Screenshots

    echo "Custom activation scripts completed"
  '';

  # LaunchAgents for key remapping (from Ansible)
  environment.etc = {
    "local-key-remapping.plist" = {
      target = "LaunchAgents/com.local.KeyRemapping.plist";
      text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
          <key>Label</key>
          <string>com.local.KeyRemapping</string>
          <key>ProgramArguments</key>
          <array>
            <string>/usr/bin/hidutil</string>
            <string>property</string>
            <string>--set</string>
            <string>{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x7000000E0}]}</string>
          </array>
          <key>RunAtLoad</key>
          <true/>
        </dict>
        </plist>
      '';
    };
  };
}
