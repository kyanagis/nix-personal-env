{ ... }:
{
  home.stateVersion = "25.05";

  xdg.enable = true;

  xdg.configFile."nix/nix.conf".text = ''
    experimental-features = nix-command flakes
    keep-derivations = true
    keep-outputs = true
  '';

  programs.home-manager.enable = true;
}
