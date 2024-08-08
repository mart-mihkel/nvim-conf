{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    nodejs_22
    neofetch
    gnumake
    ripgrep
    neovim
    cargo
    gcc
    git
  ];
}
