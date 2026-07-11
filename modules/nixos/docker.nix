{ ... }:
{
  virtualisation.docker.enable = true;
  users.users.achille.extraGroups = [ "docker" ];
}

