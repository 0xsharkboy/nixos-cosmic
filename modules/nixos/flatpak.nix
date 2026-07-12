{ ... }:
{
  services.flatpak = {
    enable = true;
    packages = [
      "com.bitwarden.desktop"
      "com.discordapp.Discord"
      "com.spotify.Client"
    ];
  };
}
