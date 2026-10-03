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
