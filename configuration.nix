# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, inputs, lib, ... }:

  let
    home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-26.05.tar.gz;
in
{

  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader & Hostname
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.timeout = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "tech_support";
  networking.networkmanager.enable = true;
  boot.supportedFilesystems = [ "exfat" "ntfs" ];
  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Locale & Timezone
  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  # X11 Keymap
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # User Configuration
  users.users."sudo-v3l" = {
    isNormalUser = true;
    description = "Shivansh Narayan Tripathi";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs; };
    users.sudo-v3l = import ./home.nix;
  };

  # Unfree packages and allowed packages
  
  nixpkgs.config = {
  allowUnfree = true;
  packageOverrides = pkgs: {
    gnome-icon-theme = pkgs.adwaita-icon-theme;
    };
  };

  programs.firefox.enable = true;
  programs.fish.enable = true;
  services.envfs.enable = true;
  services.geoclue2.enable = true;
  services.udisks2.enable = true;
  # Hyprland System Integration
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  fonts.packages = with pkgs; [
  rubik
  nerd-fonts.ubuntu
  nerd-fonts.jetbrains-mono
  ];
  # NVIDIA Graphics Setup
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

hardware.nvidia = {
  modesetting.enable = true;
  open = lib.mkForce true;
  powerManagement = {
    enable = true;
    finegrained = true; 
  };

  # Configure PRIME offloading
  prime = {
    offload = {
      enable = lib.mkForce true;
        enableOffloadCmd = lib.mkForce true;
  };

    intelBusId = lib.mkForce "PCI:0:2:0";
    nvidiaBusId = lib.mkForce "PCI:2:0:0";
  };
};
  boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.kernelParams = [ "nvidia-drm.modeset=1" ];

  # System Profiles Packages
  environment.systemPackages = with pkgs; [
    neovim
    wget
    curl
    git
    kitty
    foot
    wl-clipboard
    exfatprogs
  ];
  # Setting up hyprpaper
  # Generate the config file system-wide or read it directly
  systemd.user.services.hyprpaper = {
    description = "Hyprland wallpaper daemon";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.hyprpaper}/bin/hyprpaper --config /etc/hyprpaper.conf";
      Restart = "on-failure";
    };
  };

  # Write the hyprpaper config file declaratively
  environment.etc."hyprpaper.conf".text = ''
    preload = /etc/wallpapers/hello_friend.jpg
    wallpaper = ,/etc/wallpapers/hello_friend.jpg
    ipc = off
  '';

  system.stateVersion = "26.05"; # Do not touch

}
