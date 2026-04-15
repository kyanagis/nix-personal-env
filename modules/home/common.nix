{ config, lib, pkgs, profile, ... }:
let
  corePackages = with pkgs; [
    coreutils
    findutils
    gnugrep
    gnused
    gawk
    gnutar
    bash-language-server
    bat
    bind
    btop
    curl
    eza
    fd
    file
    gh
    git
    git-lfs
    gnupg
    jq
    jqp
    just
    libressl.nc
    ripgrep
    ripgrep-all
    rsync
    socat
    tree
    unzip
    wget
    whois
    yq
    zip
    zstd
  ];

  buildPackages = with pkgs; [
    (lib.hiPrio binutils)
    buf
    clang-tools
    cmake
    deadnix
    delve
    gcc
    gnumake
    go
    gopls
    grpcurl
    lua-language-server
    nix-output-monitor
    nix-tree
    nil
    nixd
    nixpkgs-fmt
    pkg-config
    protobuf
    rust-analyzer
    rustc
    cargo
    shellcheck
    shfmt
    statix
    stylua
    taplo
    opentofu
    terraform-ls
  ];

  languagePackages = with pkgs; [
    nodejs_22
    pipx
    pixi
    pnpm
    pre-commit
    pyright
    python3
    ruff
    typescript-language-server
    uv
    vscode-langservers-extracted
    yarn
  ];

  infraPackages = with pkgs; [
    actionlint
    ansible
    ansible-lint
    awscli2
    docker-client
    docker-compose
    hadolint
    helmfile
    k9s
    kubectl
    kubectx
    kubernetes-helm
    kustomize
    stern
    trivy
  ];

  dataPackages = with pkgs; [
    httpie
    mariadb.client
    openssl
    pgcli
    postgresql
    sqlite
  ];

  docsPackages = with pkgs; [
    graphviz
    markdownlint-cli
    marksman
    pandoc
    yamllint
  ];

  securityPackages = with pkgs; [
    age
    binwalk
    mtr
    nmap
    radare2
    sops
    tcpdump
    usbutils
    wireshark-cli
  ];

  commonPackages =
    corePackages
    ++ buildPackages
    ++ languagePackages
    ++ infraPackages
    ++ dataPackages
    ++ docsPackages
    ++ securityPackages;

  linuxPackages = with pkgs; [
    gdb
    ltrace
    patchelf
    strace
  ];

  darwinPackages = with pkgs; [
    iproute2mac
    lldb
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

  programs.zoxide = {
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
      pkgs.vimPlugins.nvim-lspconfig
      pkgs.vimPlugins.nvim-cmp
      pkgs.vimPlugins.cmp-nvim-lsp
      pkgs.vimPlugins.cmp-path
      pkgs.vimPlugins.nvim-autopairs
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
