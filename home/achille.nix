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
        curl
        dnsutils
        fastfetch
        file
        file-roller
        loupe
        papers
        pciutils
        rsync
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
        chromium
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
        "application/pdf" = "org.gnome.Papers.desktop";
        "application/vnd.rar" = "org.gnome.FileRoller.desktop";
        "application/x-7z-compressed" = "org.gnome.FileRoller.desktop";
        "application/x-rar" = "org.gnome.FileRoller.desktop";
        "application/zip" = "org.gnome.FileRoller.desktop";
        "image/gif" = "org.gnome.Loupe.desktop";
        "image/jpeg" = "org.gnome.Loupe.desktop";
        "image/png" = "org.gnome.Loupe.desktop";
        "image/svg+xml" = "org.gnome.Loupe.desktop";
        "image/webp" = "org.gnome.Loupe.desktop";
        "inode/directory" = "com.system76.CosmicFiles.desktop";
        "text/html" = "helium.desktop";
        "text/plain" = "dev.zed.Zed.desktop";
        "x-scheme-handler/http" = "helium.desktop";
        "x-scheme-handler/https" = "helium.desktop";
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
