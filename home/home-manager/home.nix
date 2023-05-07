{ inputs, lib, config, pkgs, ... }: {
  imports = [
    # ./nvim.nix
  ];

  nixpkgs = {
    overlays = [];
    config = {
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);
    };
  };

  home = {
    username = "L";
    homeDirectory = "/home/L";
  };

  # Add stuff for your user as you see fit:
  home.packages = with pkgs; [
    # Install Nerd Fonts with a limited number of fonts
    (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })
    # Adds a command 'my-hello' to environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    pkgs.armcord
    pkgs.persepolis
    pkgs.fish
    pkgs.nim
    pkgs.gcc
  ];

  home.file = {
    # The primary way to manage plain files is through 'home.file'.
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  home.sessionVariables = {
    EDITOR = "hx";
  };


  # Enable home-manager and git
  programs = {
    home-manager.enable = true;
    git.enable = true;
    fish.enable = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  home.stateVersion = "22.11";
}
