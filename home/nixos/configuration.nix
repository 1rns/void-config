{ inputs, lib, config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  # --------- NIX --------- #

  nixpkgs = {
    overlays = [];

    config = {
      allowUnfree = true;
      permittedInsecurePackages = [ "electron-21.4.0" ];
    }
  };

  nix = {
    # Adds each flake input as a registry
    # Makes nix3 commands consistent with flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # Adds inputs to the system's legacy channels,
    # makes legacy nix commands consistent
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
    };

    gc = {
      automatic = true;
      randomizedDelaySec = "14m";
      options = "--delete-older-than 15d";
    };
  };

  # ---------     --------- #


  # --------- BOOT --------- #

  boot = {
    loader = {
      systemd.boot.enable = true;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot/efi";
    };

    initrd = {
      secrets."/crypto_keyfile.bin" = null;
      systemd.enable = true;
      # Enable swap on luks
      initrd.luks.devices."luks-45d017f2-4c39-4676-937c-e922f533638d".device = "/dev/disk/by-uuid/45d017f2-4c39-4676-937c-e922f533638d";
      initrd.luks.devices."luks-45d017f2-4c39-4676-937c-e922f533638d".keyFile = "/crypto_keyfile.bin";
    };

    tmp.cleanOnBoot = true;
    supportedFilesystems = [ "ntfs" ];
  };

  # ---------     --------- #


  # --------- AUDIO --------- #

  sound.enable = true;
  hardware.pulseaudio.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = false;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ---------     --------- #


  # --------- NVIDIA   --------- #
  hardware.nvidia.powerManagement.enable = true;
  services.xserver = {
    videoDrivers = [ "nvidia" ];
    config = ''
      Section "Device"
          Identifier  "Intel Graphics"
          Driver      "intel"
          #Option      "AccelMethod"  "sna" # default
          #Option      "AccelMethod"  "uxa" # fallback
          Option      "TearFree"        "true"
          Option      "SwapbuffersWait" "true"
          BusID       "PCI:0:2:0"
          #Option      "DRI" "2"             # DRI3 is now default
      EndSection

      Section "Device"
          Identifier "nvidia"
          Driver "nvidia"
          BusID "PCI:1:0:0"
          Option "AllowEmptyInitialConfiguration"
      EndSection
    '';
    screenSection = ''
      Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
      Option         "AllowIndirectGLXProtocol" "off"
      Option         "TripleBuffer" "on"
    '';
  };
  hardware.nvidia.prime = {
  # Sync Mode
  sync.enable = true;
  # Offload Mode
  #offload.enable = true;

  # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
  nvidiaBusId = "PCI:1:0:0";

  # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
  intelBusId = "PCI:0:2:0";
  };
  hardware.nvidia.modesetting.enable = true;
  hardware.opengl.enable = true;

  services.udev.extraRules = ''
    SUBSYSTEM=="input", GROUP="input", MODE="0666"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="612[0-7]", MODE:="0666", GROUP="plugdev"
    KERNEL=="hidraw*", ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="612[0-7]", MODE="0666", GROUP="plugdev"
  '';

  # ---------     --------- #


  # --------- FONTS --------- #

  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    hasklig
    google-fonts
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

  # ---------     --------- #


  # --------- LOGITECH MX 3 --------- #
  systemd.services.logiops = {
    description = "An unofficial userspace driver for HID++ Logitech devices";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.logiops}/bin/logid";
    };
  };
  environment.etc."logid.cfg".text = ''
    devices: ({
      name: "Wireless Mouse MX Master 3";
      smartshift: {
        on: true;
        threshold: 12;
      };
      hiresscroll: {
        hires: true;
        target: false;
      };
      dpi: 800;
      buttons: ({
        cid: 0xc3;
        action = {
          type: "Gestures";
          gestures: ({
            direction: "Left";
            mode: "OnRelease";
            action = {
              type = "Keypress";
              keys: ["KEY_F15"];
            };
          }, {
            direction: "Right";
            mode: "OnRelease";
            action = {
              type = "Keypress";
              keys: ["KEY_F16"];
            };
          }, {
            direction: "Down";
            mode: "OnRelease";
            action = {
              type: "Keypress";
              keys: ["KEY_F17"];
            };
          }, {
            direction: "Up";
            mode: "OnRelease";
            action = {
              type: "Keypress";
              keys: ["KEY_F18"];
            };
          }, {
            direction: "None";
            mode: "OnRelease";
            action = {
              type = "Keypress";
              keys: ["KEY_PLAYPAUSE"];
            };
          });
        };
      }, {
        cid: 0x53;
        action = {
          type: "Keypress";
          keys: ["KEY_SPACE"];
        };
      });
    });
  '';

  # ---------     --------- #


  # --------- SYSPKGS --------- #

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
      my-python-packages = ps: with ps; [

      ];
    in
   [
    wget
    okular
    gallery-dl
    logiops
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
    (python3.withPackages my-python-packages)
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

  # ---------     --------- #


  # --------- NETWORKING --------- #

  networking = {
    hostName = "NIXOS";
    networking.networkmanager.enable = true;
    # Open ports in the firewall:
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether:
    # networking.firewall.enable = false;
  };

  # ---------     --------- #


  # --------- SERVICES --------- #

  services = {
    xserver = {
      enable = true;
      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = true;
      layouut = "us";
      xkbVariant = "";
    };

    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_BAT="powersave";
        # The following prevents the battery from charging fully to
        # preserve lifetime. Run `tlp fullcharge` to temporarily force
        # full charge.
        # https://linrunner.de/tlp/faq/battery.html#how-to-choose-good-battery-charge-thresholds
        START_CHARGE_THRESH_BAT0=50;
        STOP_CHARGE_THRESH_BAT0=80;
    };

    power-profiles-daemon.enable = false;
    flatpak.enable = true;
    printing.enable = true;
    blueman.enable = true;
  };

  # ---------     --------- #


  # --------- ETC --------- #

  hardware.bluetooth.enable = true;



  users.users = {
    L = {
      isNormalUser = true;
      extraGroups = [ "wheel" "wheel" "networkmanager" ];
    };
  };
  time.timeZone = "Pacific/Auckland";
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

  system.stateVersion = "22.11";
}
