{ ... }:
{
  virtualisation.virtualbox.guest = {
    enable = true;
    clipboard = true;
    dragAndDrop = true;
  };

  users.users.achille.extraGroups = [ "vboxsf" ];
}
