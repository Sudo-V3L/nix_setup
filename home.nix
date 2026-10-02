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

  # --- Hyprland Configuration & Waybar Autostart ---
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      # Autostart Waybar on session launch
      "exec-once" = [
        "${pkgs.waybar}/bin/waybar"
      ];

      # Practical default modifier (SUPER / Windows key)
      "$mainMod" = "SUPER";

      bind = [
        "$mainMod, Q, exec, kitty"
        "$mainMod, C, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, E, exec, dolphin"
        "$mainMod, R, exec, rofi -show drun"
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
      set fish_greeting
    '';

    plugins = [
      {
        name = "grc";
        src = pkgs.fishPlugins.grc.src;
      }
    ];
  };
}
