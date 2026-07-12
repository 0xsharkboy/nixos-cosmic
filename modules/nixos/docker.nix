{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.exegol ];

  virtualisation.docker.enable = true;
  users.users.achille.extraGroups = [ "docker" ];
}
