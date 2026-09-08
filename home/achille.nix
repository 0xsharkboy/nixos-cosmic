{ heliumBrowser, pkgs, pkgsUnstable, ... }:
{
  home = {
    username = "achille";
    homeDirectory = "/home/achille";
    stateVersion = "26.05";
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    packages =
      (with pkgs; [
        amberol
        celluloid
        curl
        dnsutils
        fastfetch
        file
        file-roller
        gnome-calendar
        loupe
        papers
        pciutils
        protonmail-bridge-gui
        rsync
        thunderbird
        tree
        usbutils
        wget
      ])
      ++ [ heliumBrowser ]
      ++ (with pkgsUnstable; [
        android-studio
        bat
        claude-code
        bruno
        codex
        cutter
        jadx
        fd
        fzf
        ghidra-bin
        htop
        jq
        jetbrains.datagrip
        lazygit
        nil
        nixfmt
        opencode
        ripgrep
        shellcheck
        unzip
        wl-clipboard
        jetbrains.webstorm
        yq
        zed-editor
        zip
      ]);
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  xdg = {
    enable = true;

    mimeApps = {
      enable = true;
      defaultApplications = {
        "application/ogg" = "io.bassi.Amberol.desktop";
        "application/pdf" = "org.gnome.Papers.desktop";
        "application/vnd.rar" = "org.gnome.FileRoller.desktop";
        "application/x-7z-compressed" = "org.gnome.FileRoller.desktop";
        "application/x-rar" = "org.gnome.FileRoller.desktop";
        "application/zip" = "org.gnome.FileRoller.desktop";
        "audio/aac" = "io.bassi.Amberol.desktop";
        "audio/flac" = "io.bassi.Amberol.desktop";
        "audio/mpeg" = "io.bassi.Amberol.desktop";
        "audio/ogg" = "io.bassi.Amberol.desktop";
        "audio/opus" = "io.bassi.Amberol.desktop";
        "audio/x-m4a" = "io.bassi.Amberol.desktop";
        "audio/x-wav" = "io.bassi.Amberol.desktop";
        "image/gif" = "org.gnome.Loupe.desktop";
        "image/jpeg" = "org.gnome.Loupe.desktop";
        "image/png" = "org.gnome.Loupe.desktop";
        "image/svg+xml" = "org.gnome.Loupe.desktop";
        "image/webp" = "org.gnome.Loupe.desktop";
        "inode/directory" = "com.system76.CosmicFiles.desktop";
        "message/rfc822" = "thunderbird.desktop";
        "text/html" = "helium.desktop";
        "text/calendar" = "org.gnome.Calendar.desktop";
        "text/plain" = "dev.zed.Zed.desktop";
        "video/mp2t" = "io.github.celluloid_player.Celluloid.desktop";
        "video/mp4" = "io.github.celluloid_player.Celluloid.desktop";
        "video/mpeg" = "io.github.celluloid_player.Celluloid.desktop";
        "video/quicktime" = "io.github.celluloid_player.Celluloid.desktop";
        "video/webm" = "io.github.celluloid_player.Celluloid.desktop";
        "video/x-matroska" = "io.github.celluloid_player.Celluloid.desktop";
        "video/x-msvideo" = "io.github.celluloid_player.Celluloid.desktop";
        "x-scheme-handler/http" = "helium.desktop";
        "x-scheme-handler/https" = "helium.desktop";
        "x-scheme-handler/mailto" = "thunderbird.desktop";
      };
    };

    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  programs = {
    ghostty = {
      enable = true;
      enableZshIntegration = true;
      settings."font-family" = "JetBrainsMono Nerd Font";
    };

    git = {
      enable = true;
      settings.user = {
        name = "0xsharkboy";
        email = "achille@0xsharkboy.dev";
      };
    };

    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };

    tmux.enable = true;

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = [
          "git"
          "sudo"
          "command-not-found"
        ];
      };
    };
  };
}
