{ config, pkgs, ... }:

{
  home.username = "lxvrns";
  home.homeDirectory = "/home/lxvrns";

  # This value determines the Home Manager release that your configuration is
  # compatible with.
  # You should not change this value, even if you update Home Manager.
  home.stateVersion = "22.11";

  home.packages = [
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

  # The primary way to manage plain files is through 'home.file'.
  home.file = {
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

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/lxvrns/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    EDITOR = "hx";
  };
  home.sessionPath = [
    "$HOME/.nimble/bin"
  ];
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.fish = {
    enable = true;
  };
}
