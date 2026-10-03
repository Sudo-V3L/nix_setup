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

  # Unfree packages & Programs
  nixpkgs.config.allowUnfree = true;
  programs.firefox.enable = true;
  programs.fish.enable = true;
  services.envfs.enable = true;

  # Hyprland System Integration
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Display Manager (greetd)
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = ''
          ${pkgs.tuigreet}/bin/tuigreet \
          --time \
          --remember \
          --remember-user-session \
          --theme "border=red;text=red;prompt=red;time=red;action=red;button=red;container=black;input=red" \
          --cmd Hyprland
        '';
        user = "greeter";
      };
    };
  };

  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
    TTYPath = "/dev/tty1";
  };

  # NVIDIA Graphics Setup
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:2:0:0";
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
