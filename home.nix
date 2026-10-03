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
    extraConfig = '' 
      -- Local Variables & Binaries
      local mod = "SUPER"
      local terminal = "${pkgs.kitty}/bin/kitty"
      local launcher = "${pkgs.rofi}/bin/rofi -show drun"
      local fileManager = "${pkgs.kdePackages.dolphin}/bin/dolphin"
      hl.on("hyprland.start", function()
        hl.exec_cmd("${pkgs.waybar}/bin/waybar")
      end)

      -- Environment Variables
      hl.env("XCURSOR_SIZE", "24")
      hl.enx("HYPRCURSOR_SIZE", "24")

      -- Application Hotkeys
      hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal))
      hl.bind(mod .. " + Space", hl.dsp.exec_cmd(launcher))
      hl.bind(mod .. " + E", hl.dsp.exec_cmd(fileManager))
      hl.bind(mod .. " + Q", "killactive")

      -- Focus
      hl.bind(mod .. " + H", hl.dsp.focus({ direction = "left" }))
      hl.bind(mod .. " + L", hl.dsp.focus({ direction = "right" }))
      hl.bind(mod .. " + K", hl.dsp.focus({ direction = "up" }))
      hl.bind(mod .. " + J", hl.dsp.focus({ direction = "down" }))

      -- Workspace switching
      for i = 1, 9 do
        hl.bind(mod .. " + " .. i, hl.dsp.focus({ workspace = i }))
	hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.focus({ workspace = i }))

      -- Mouse Controls
      hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
      hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), {mouse = true})
    '';
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
