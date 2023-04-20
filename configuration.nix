# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.config.permittedInsecurePackages = [
    "electron-21.4.0"
  ];

  nix.gc = {
    automatic = true;
    randomizedDelaySec = "14m";
    options = "--delete-older-than 10d";
  };
  
  # Bootloader
    # systemd
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  hardware.bumblebee = {
    enable = true;
    pmMethod = "none";
  };
  
  boot.tmp.cleanOnBoot = true;
  boot.supportedFilesystems = [ "ntfs" ];
  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };
  boot.initrd.systemd.enable = true;
  # Enable swap on luks
  boot.initrd.luks.devices."luks-45d017f2-4c39-4676-937c-e922f533638d".device = "/dev/disk/by-uuid/45d017f2-4c39-4676-937c-e922f533638d";
  boot.initrd.luks.devices."luks-45d017f2-4c39-4676-937c-e922f533638d".keyFile = "/crypto_keyfile.bin";
  
  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Pacific/Auckland";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_NZ.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_NZ.UTF-8";
    LC_IDENTIFICATION = "en_NZ.UTF-8";
    LC_MEASUREMENT = "en_NZ.UTF-8";
    LC_MONETARY = "en_NZ.UTF-8";
    LC_NAME = "en_NZ.UTF-8";
    LC_NUMERIC = "en_NZ.UTF-8";
    LC_PAPER = "en_NZ.UTF-8";
    LC_TELEPHONE = "en_NZ.UTF-8";
    LC_TIME = "en_NZ.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_BAT="powersave";
      CPU_SCALING_GOVERNOR_ON_AC="powersave";

      # The following prevents the battery from charging fully to
      # preserve lifetime. Run `tlp fullcharge` to temporarily force
      # full charge.
      # https://linrunner.de/tlp/faq/battery.html#how-to-choose-good-battery-charge-thresholds
      START_CHARGE_THRESH_BAT0=40;
      STOP_CHARGE_THRESH_BAT0=50;

      # 100 being the maximum, limit the speed of my CPU to reduce
      # heat and increase battery usage:
      CPU_MAX_PERF_ON_AC=75;
      CPU_MAX_PERF_ON_BAT=60;
    };
  };
  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  #services.xserver.displayManager.lightdm.enable = true;
  services.flatpak.enable = true;
  #services.xserver.windowManager.nimdow.enable = true;
  #services.xserver.displayManager.defaultSession = "none+qtile";
  #services.xserver.windowManager.qtile.enable = true;
  #services.xserver.windowManager.i3 = {
  #  enable = true;
  #  extraPackages = with pkgs; [
  #    dmenu # app launcher
  #    i3lock # screen locker
  #    i3status # status bar
  #    #i3blocks
  #  ];
  #};
  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  
  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = false;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };
  
  # NVIDIA
  services.xserver.videoDrivers = [ "modesetting" ];
  #hardware.opengl.enable = true;

  services.udev.extraRules = ''
    SUBSYSTEM=="input", GROUP="input", MODE="0666"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="612[0-7]", MODE:="0666", GROUP="plugdev"
    KERNEL=="hidraw*", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="612[0-7]", MODE="0666", GROUP="plugdev"
    '';
  
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lxvrns = {
    isNormalUser = true;
    description = "L";
    extraGroups = [ "docker networkmanager" "wheel" ];
    packages = with pkgs; [
      #
   ];
  };

  virtualisation.docker.enable = true;

  # Enable automatic login for the user.
  #services.xserver.displayManager.autoLogin.enable = true;
  #services.xserver.displayManager.autoLogin.user = "lxvrns";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs;
    let
      r-with-my-pkgs = rWrapper.override {
        packages = with rPackages;
        [ pandoc skimr tidyverse ggplot2 dplyr rmarkdown knitr ];
      };
      rstudio-with-my-pkgs = rstudioWrapper.override {
        packages = with rPackages; 
          [ quarto patchwork visdat simputation VIM  pandoc skimr ggplot2 dplyr tidyverse rmarkdown knitr ];
       };
#      my-python-packages = ps: with ps; [
#      
#      ];
    in
   [
  #syspkgs
    wget
    google-chrome
    aria
    renameutils
    ffmpeg_6-full
    discord
    geeqie
    kfind
    polkit
    uhk-agent
    lsof
    file
    texlive.combined.scheme-full
    falkon
    #(python3.withPackages my-python-packages)
    pandoc
    rofi
    fd
    dmenu
    fzf
    libreoffice
    gparted
    sddm-kcm
    libsForQt5.qtstyleplugin-kvantum
    ripgrep
    zathura
    st
    obsidian
    unzip
    helix
    git
    nushell
    r-with-my-pkgs
    rstudio-with-my-pkgs
    neofetch
    firefox
    vivaldi
    mpv
    bitwarden
    cmatrix
    (vscode-with-extensions.override {
      vscode = vscodium;
      vscodeExtensions = with vscode-extensions; [
        bbenoist.nix
        ms-python.python
        ms-azuretools.vscode-docker
        ms-vscode-remote.remote-ssh
        esbenp.prettier-vscode
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "remote-ssh-edit";
          publisher = "ms-vscode-remote";
          version = "0.47.2";
          sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
         }
        {
          name = "nimvscode";
          version = "0.1.26";
          publisher = "nimsaem";
          sha256 = "unxcnQR2ccsydVG3H13e+xYRnW+3/ArIuBt0HlCLKio=";
        }
        {
          name = "sequoia";
          version = "0.10.0";
          publisher = "wicked-labs";
          sha256 = "sha256-nZirPixORjmRXNCGtoADo+Sd4CNGxHG6c3QfCLZUKlM=";
        }
      ];
    }) 
  ];
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;
  environment.shells = with pkgs; [ fish ];
  environment.binsh = "${pkgs.bash}/bin/bash";

  # fonts
  fonts.fonts = with pkgs; [
  noto-fonts
  noto-fonts-cjk
  noto-fonts-emoji
  hasklig
  hack-font
  powerline-fonts
  siji
  unifont
  liberation_ttf
  fira-code
  fira-code-symbols
  mplus-outline-fonts.githubRelease
  dina-font
  proggyfonts
  ubuntu_font_family
];
fonts.fontconfig = {
  antialias = true;
  hinting.enable = true;
  hinting.autohint = true;
  hinting.style = "hintfull";
};
fonts.enableDefaultFonts = true;

fonts.fontconfig.subpixel = {
  rgba = "rgb";
  lcdfilter = "default";
};
  
  
  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  #services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
