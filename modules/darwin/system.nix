{ pkgs, user, homeDirectory, ... }:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.optimise.automatic = true;

  programs.zsh.enable = true;

  environment.shells = [
    pkgs.bash
    pkgs.zsh
  ];

  environment.systemPackages = with pkgs; [
    coreutils
    findutils
    gnugrep
    gnused
    gawk
    gnutar
  ];

  users.users.${user} = {
    home = homeDirectory;
    shell = pkgs.zsh;
  };

  system.primaryUser = user;

  system.defaults = {
    dock.autohide = true;
    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      ShowStatusBar = true;
    };
    NSGlobalDomain = {
      ApplePressAndHoldEnabled = false;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
    };
  };

  system.stateVersion = 6;
}
