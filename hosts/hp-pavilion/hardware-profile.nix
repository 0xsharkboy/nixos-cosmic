{ ... }:
{
  # HP Pavilion Laptop 15-eh2xxx (6K9M2EA#ABF)
  # AMD Ryzen 7 5825U with integrated Barcelo graphics.
  boot = {
    kernelModules = [ "kvm-amd" ];
    kernelParams = [ "amd_pstate=active" ];
  };

  hardware = {
    cpu.amd.updateMicrocode = true;

    amdgpu.initrd.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
