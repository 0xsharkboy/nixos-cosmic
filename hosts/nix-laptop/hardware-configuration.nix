# Placeholder only. Replace this file with the output of
# `nixos-generate-config --root /mnt` on the target laptop before installation.
{ ... }:
{
  # This declaration only makes the repository evaluable before the target
  # machine exists. Do not install with it: the generated hardware file must
  # replace this entire file.
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos-placeholder";
    fsType = "ext4";
  };
}
