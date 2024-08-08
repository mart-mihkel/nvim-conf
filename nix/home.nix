{ ... }:

{
  home.username = "maun";
  home.homeDirectory = "/home/maun";
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;
  programs.firefox.enable = true;

  programs.git = {
    enable = true;
    userName = "mart-mihkel";
    userEmail = "mart.mihkel.aun@gmail.com";
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      vi = "nvim";
      vim = "nvim";
      vimdiff = "nvim";
    };
  };
}
