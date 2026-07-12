{ ... }:
{
  services.flatpak = {
    enable = true;
    packages = [
      "com.discordapp.Discord"
      "com.spotify.Client"
    ];
  };
}
