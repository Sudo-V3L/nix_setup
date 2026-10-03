{ config, pkgs, inputs, ... }:

{
  home.username = "sudo-v3l";
  home.homeDirectory = "/home/sudo-v3l";
  home.stateVersion = "24.11";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # --- User Packages ---
  home.packages = with pkgs; [
    # Wayland Clipboard Utilities
    wl-clipboard
    cliphist
    wl-clip-persist

    # General Applications
    btop
    fastfetch
    grc
    kdePackages.dolphin
    discord
    steam
  ];
  services.udiskie = {
    enable = true;
    tray = "always";
  };
  
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      # Pin Hyprland rendering to the Intel iGPU
      env = [
        "AQ_DRM_DEVICES,/dev/dri/by-path/pci-0000:00:02.0-card:/dev/dri/by-path/pci-0000:02:00.0-card"
      ];
    };
  };

  # Enable end-4's Illogical Impulse environment via illogical-flake
  programs.illogical-impulse = {
    enable = true;
    dotfiles = {
      fish.enable = true;
      kitty.enable = true;
      starship.enable = true;
    };
  };
}
