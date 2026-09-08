{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    android-tools
    scrcpy
  ];

  # Android Emulator uses KVM directly; libvirt is not required.
  users.users.achille.extraGroups = [ "kvm" ];
}
