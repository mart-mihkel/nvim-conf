{ ... }:

{
  users.users.maun = {
    isNormalUser = true;
    description = "Mart-Mihkel Aun";
    extraGroups = [ "networkmanager" "wheel" ];
  };
}
