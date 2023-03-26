# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader
    # systemd
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  
    # grub
  #boot.loader = {
  #  efi = {
  #    canTouchEfiVariables = true;
  #    efiSysMountPoint = "/boot/efi";
  #  };
  #  grub = {
  #    enable = true;
  #    version = 2;
  #    efiSupport = true;
  #    devices = [ "nodev" ];
  #    useOSProber = true;
  #  };
  #};

  # unstable fix (maybe) nope
  #boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.bumblebee = {
    enable = true;
    pmMethod = "none";
  };
  
  
  boot.cleanTmpDir = true;
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

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
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
  
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lxvrns = {
    isNormalUser = true;
    description = "L";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      #
   ];
  };

  # Enable automatic login for the user.
  #services.xserver.displayManager.autoLogin.enable = true;
  #services.xserver.displayManager.autoLogin.user = "lxvrns";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #syspkgs
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    rofi
    fd
    dmenu
    fzf
    nim
    gparted
    sddm-kcm
    libsForQt5.qtstyleplugin-kvantum
    ripgrep
    zathura
    fish
    st
    obsidian
    unzip
    helix
    git
    dash
    neofetch
    firefox
    vscodium
    mpv
    bitwarden
    cmatrix    
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
  environment.binsh = "${pkgs.dash}/bin/dash";

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
fonts.fontconfig.defaultFonts = {
  serif = [ "Source Serif Pro" ];
  sansSerif = [ "Source Sans Pro" ];
  monospace = [ "Ubuntu Mono" ];
};

fonts.fontconfig.subpixel = {
  rgba = "rgb";
  lcdfilter = "default";
};
  
  
  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

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
