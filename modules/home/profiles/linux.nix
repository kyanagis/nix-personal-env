{ user, homeDirectory, ... }:
{
  imports = [
    ../common.nix
  ];

  home.username = user;
  home.homeDirectory = homeDirectory;

  targets.genericLinux.enable = true;
}
