{ config, lib, pkgs, profile, ... }:
let
  commonPackages = with pkgs; [
    age
    bash-language-server
    bat
    bind
    binutils
    binwalk
    btop
    clang-tools
    cmake
    curl
    eza
    fd
    file
    gcc
    gh
    git-lfs
    gnumake
    jq
    just
    libressl.nc
    lua-language-server
    nil
    nmap
    nodejs_22
    openssl
    pnpm
    pkg-config
    python3
    pyright
    radare2
    ripgrep
    rsync
    socat
    sops
    stylua
    tree
    typescript-language-server
    unzip
    uv
    vscode-langservers-extracted
    wget
    whois
    wireshark-cli
    yarn
    yq
    zip
    zstd
  ];

  linuxPackages = with pkgs; [
    gdb
    ltrace
    patchelf
    strace
    tcpdump
  ];

  darwinPackages = with pkgs; [
    coreutils
    findutils
    gawk
    gnugrep
    gnused
    gnutar
    lldb
    tcpdump
  ];

  linuxZshHandoff = ''
    if [[ $- == *i* ]] && command -v zsh >/dev/null 2>&1 && [[ -z "''${ZSH_VERSION:-}" ]]; then
      exec zsh
    fi
  '';

in
{
  home.stateVersion = "25.05";

  xdg.enable = true;

  xdg.configFile."nix/nix.conf".text = ''
    experimental-features = nix-command flakes
    keep-derivations = true
    keep-outputs = true
  '';

  home.sessionVariables = {
    COREPACK_ENABLE_AUTO_PIN = "0";
    DOTFILES_PROFILE = profile;
    EDITOR = "nvim";
    FZF_DEFAULT_COMMAND = "fd --type f --hidden --follow --exclude .git";
    MANPAGER = "less -FR";
    PAGER = "less -FR";
    VISUAL = "nvim";
  };

  home.sessionPath = lib.optionals pkgs.stdenv.isDarwin [
    "${pkgs.coreutils}/bin"
    "${pkgs.findutils}/bin"
    "${pkgs.gnugrep}/bin"
    "${pkgs.gnused}/bin"
    "${pkgs.gawk}/bin"
    "${pkgs.gnutar}/bin"
  ];

  home.shellAliases = {
    cat = "bat --style=plain";
    ccw = "cc -Werror -Wall -Wextra";
    la = "eza -lah --all --group-directories-first";
    ll = "eza -lah --group-directories-first";
    ls = "eza --group-directories-first";
  };

  home.packages =
    commonPackages
    ++ lib.optionals pkgs.stdenv.isLinux linuxPackages
    ++ lib.optionals pkgs.stdenv.isDarwin darwinPackages;

  programs.home-manager.enable = true;

  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = lib.optionalString pkgs.stdenv.isLinux linuxZshHandoff;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.git = {
    enable = true;
    settings = {
      core.editor = "nvim";
      init.defaultBranch = "main";
      merge.conflictstyle = "zdiff3";
      pull.rebase = false;
      push.autoSetupRemote = true;
    };
    lfs.enable = true;
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      "line-numbers" = true;
      "side-by-side" = true;
      "syntax-theme" = "gruvbox-dark";
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withRuby = false;
    withPython3 = true;
    plugins = [
      pkgs.vimPlugins.plenary-nvim
      pkgs.vimPlugins.telescope-nvim
      pkgs.vimPlugins.nvim-lspconfig
      pkgs.vimPlugins.nvim-cmp
      pkgs.vimPlugins.cmp-nvim-lsp
      pkgs.vimPlugins.cmp-buffer
      pkgs.vimPlugins.cmp-path
      pkgs.vimPlugins.luasnip
      pkgs.vimPlugins.cmp_luasnip
      pkgs.vimPlugins.friendly-snippets
      pkgs.vimPlugins.nvim-autopairs
      pkgs.vimPlugins.gitsigns-nvim
      pkgs.vimPlugins.comment-nvim
      pkgs.vimPlugins.gruvbox-nvim
    ];
    extraConfig = builtins.readFile ./nvim/init.vim;
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      addKeysToAgent = "yes";
      serverAliveInterval = 60;
      serverAliveCountMax = 3;
      extraOptions = lib.optionalAttrs pkgs.stdenv.isDarwin {
        UseKeychain = "yes";
      };
    };
  };

  programs.tmux = {
    enable = true;
    clock24 = true;
    extraConfig = ''
      set -g mouse on
      set -g history-limit 100000
      set -g base-index 1
      setw -g pane-base-index 1
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "tmux config reloaded"
    '';
    terminal = "screen-256color";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    dotDir = config.home.homeDirectory;
    history = {
      path = "${config.xdg.stateHome}/zsh/history";
      save = 100000;
      size = 100000;
    };
    initContent = lib.mkMerge [
      (lib.mkOrder 550 ''
        if [ -e /usr/local/share/zsh-completions ]; then
          fpath=(/usr/local/share/zsh-completions $fpath)
        fi
      '')
      ''
        setopt NO_BEEP
        unsetopt LIST_BEEP

        setopt hist_ignore_all_dups
        setopt hist_ignore_space
        setopt hist_reduce_blanks
        setopt hist_save_no_dups
        setopt inc_append_history
        setopt share_history

        autoload history-search-end
        zle -N history-beginning-search-backward-end history-search-end
        zle -N history-beginning-search-forward-end history-search-end
        bindkey "^p" history-beginning-search-backward-end
        bindkey "^n" history-beginning-search-forward-end

        bindkey -e
      ''
    ];
  };

  services.ssh-agent.enable = true;
}
