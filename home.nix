{ config, pkgs, inputs, ... }:

{
  home.username = "sudo-v3l";
  home.homeDirectory = "/home/sudo-v3l";
  home.stateVersion = "24.11";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # --- User Packages ---
  home.packages = with pkgs; [
    # Hyprland & Wayland Ecosystem Tools
    hyprpaper
    hyprpicker
    rofi
    grim
    slurp
    wl-clipboard
    awww
    nwg-look
    font-awesome # Required for Waybar module icons

    # Utilities & Applications
    btop
    fastfetch
    grc
    kdePackages.dolphin
    discord
    steam
  ];

  # --- Activate Waybar ---
  programs.waybar = {
    enable = true;
    systemd.enable = true; # Launches automatically via user systemd service

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;

        modules-left = [ "hyprland/workspaces" "hyprland/submap" ];
        modules-center = [ "hyprland/window" ];
        modules-right = [ "pulseaudio" "network" "cpu" "memory" "clock" "tray" ];

        "hyprland/workspaces" = {
          format = "{name}";
          on-click = "activate";
        };

        "clock" = {
          format = "{:%Y-%m-%d %H:%M}";
        };
      };
    };

    style = ''
      * {
        font-family: Roboto, Helvetica, Arial, sans-serif;
        font-size: 13px;
      }
      window#waybar {
        background-color: rgba(20, 20, 20, 0.85);
        color: #ffffff;
      }
      #workspaces button {
        padding: 0 5px;
        color: #888888;
      }
      #workspaces button.active {
        color: #ffffff;
      }
    '';
  };

# --- Hyprland Lua Configuration ---
  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    configType = "lua";

    settings = {
      # Autostart processes in Lua array
      exec_once = [
        "${pkgs.waybar}/bin/waybar"
      ];

      # Bindings using raw key strings (bypasses invalid $ Lua identifiers)
      bind = [
        # Terminal & Launchers
        "SUPER, Return, exec, ${pkgs.kitty}/bin/kitty"
        "SUPER, Q, killactive,"
        "SUPER, Space, exec, ${pkgs.rofi}/bin/rofi -show drun"
        "SUPER, E, exec, ${pkgs.kdePackages.dolphin}/bin/dolphin"

        # Window Focus (Vim keys)
        "SUPER, h, movefocus, l"
        "SUPER, l, movefocus, r"
        "SUPER, k, movefocus, u"
        "SUPER, j, movefocus, d"

        # Workspace Switching (1-5)
        "SUPER, 1, workspace, 1"
        "SUPER, 2, workspace, 2"
        "SUPER, 3, workspace, 3"
        "SUPER, 4, workspace, 4"
        "SUPER, 5, workspace, 5"

        # Move Active Window to Workspace
        "SUPER SHIFT, 1, movetoworkspace, 1"
        "SUPER SHIFT, 2, movetoworkspace, 2"
        "SUPER SHIFT, 3, movetoworkspace, 3"
        "SUPER SHIFT, 4, movetoworkspace, 4"
        "SUPER SHIFT, 5, movetoworkspace, 5"

        # Toggles
        "SUPER, V, togglefloating,"
        "SUPER, F, fullscreen,"
      ];

      bindm = [
        "SUPER, mouse:272, movewindow"
        "SUPER, mouse:273, resizewindow"
      ];
    };
  };
  # --- Shell Configuration ---
  programs.fish = {
    enable = true;

    shellAliases = {
      config = "cd /etc/nixos && sudo nvim configuration.nix";
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#tech_support";
    };

    interactiveShellInit = ''
      set -g fish_greeting ""
      if type -q grc
        source ${pkgs.grc}/etc/grc.fish
      end

      # Autostart Hyprland on TTY1 login
      if test (tty) = "/dev/tty1"
        exec Hyprland
      end
    '';
  };
}
