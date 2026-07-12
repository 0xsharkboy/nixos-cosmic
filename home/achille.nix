{ pkgsUnstable, zenBrowser, ... }:
{
  home = {
    username = "achille";
    homeDirectory = "/home/achille";
    stateVersion = "26.05";
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    packages = with pkgsUnstable; [
      bat
      codex
      fd
      fzf
      htop
      jq
      nil
      nixfmt
      ripgrep
      shellcheck
      unzip
      wl-clipboard
      zed-editor
      zenBrowser
      zip
    ];
  };

  xdg.enable = true;

  programs = {
    ghostty = {
      enable = true;
      enableZshIntegration = true;
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
