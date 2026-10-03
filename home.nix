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
    rofi-wayland # Use Wayland native Rofi
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
      # Lua syntax for startup processes
      exec_once = [
        "${pkgs.waybar}/bin/waybar"
      ];

      # Variables
      "$mainMod" = "SUPER";

      # Keybindings array for hyprland.lua
      bind = [
        # Terminal & Launchers
        "$mainMod, Return, exec, kitty"
        "$mainMod, Q, killactive,"
        "$mainMod, Space, exec, rofi -show drun"
        "$mainMod, E, exec, dolphin"

        # Window Focus (Vim keys)
        "$mainMod, h, movefocus, l"
        "$mainMod, l, movefocus, r"
        "$mainMod, k, movefocus, u"
        "$mainMod, j, movefocus, d"

        # Workspace Switching (1-5)
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"

        # Move Active Window to Workspace
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"

        # Window Toggles
        "$mainMod, V, togglefloating,"
        "$mainMod, F, fullscreen,"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
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
