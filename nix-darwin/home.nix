# home.nix
# Applied via: darwin-rebuild switch --flake .
# (home-manager is wired in as a nix-darwin module in flake.nix, so you
# don't run `home-manager switch` separately — one command updates both.)

{ config, pkgs, ... }:

{
  home.username = "johnycsh";
  home.homeDirectory = "/Users/johnycsh";
  home.stateVersion = "24.05"; # pin at whatever home-manager release is current when first switching — don't bump casually

  # --- Plain packages -------------------------------------------------
  # Ported from `brew leaves` (top-level, explicitly installed formulae).
  # Grow this list tool-by-tool as each one gets migrated in later commits.
  home.packages = with pkgs; [
    # shell / fuzzy / nav
    fzf
    ripgrep
    bat
    tree
    zsh-syntax-highlighting
    zsh-autosuggestions
    television
    gh-dash # verify this is the standalone binary, not a gh-extension-only package, before first switch

    # git / dev workflow
    git
    gh
    lazygit
    tig
    go
    rustc
    cargo # brew's "rust" formula installs both rustc + cargo; pkgs.rust itself is a toolchain attrset, not an installable package
    pyenv
    python312
    python312Packages.tkinter
    python312Packages.ipython
    uv
    virtualenv
    pandoc
    automake
    cmake

    # networking / remote
    curl
    wget
    rsync
    mosh
    nmap
    inetutils # provides telnet, among other classic net utils
    wireguard-tools
    s3cmd
    qemu

    # files / archives
    p7zip
    _7zz # brew's "sevenzip" == nixpkgs' 7-Zip CLI
    poppler
    tesseract
    zbar
    qrencode

    # misc CLI
    jq
    yq-go # brew's "yq" is the Go rewrite; nixpkgs splits yq (python) vs yq-go
    tldr
    cowsay
    cmatrix
    asciinema
    picocom
    exiftool
    yt-dlp
    sqlcipher
    fish
    elinks # nixpkgs doesn't have felinks (a fork of elinks); closest equivalent
    notcurses
    verilator

    # editors
    neovim
    vim

    # terminal
    tmux
  ];

  # --- Left on Homebrew for now, deliberately ---------------------------
  # arm-none-eabi-gcc, icarus-verilog  -> niche embedded/HDL toolchains
  # cliclick                           -> macOS automation-only, unlikely to be in nixpkgs
  # bitcoin                            -> verify nixpkgs package name before moving
  # code-server                        -> works fine from brew; nixpkgs has it too, move later
  # coder, mutagen-io/mutagen          -> custom brew taps, kept in flake.nix's homebrew.brews instead
  # openvino, lsusb, tuios, fpp, gdb   -> less common; check `nix search nixpkgs <name>` first

  # --- Declarative program configs -------------------------------------
  # These give Nix ownership of the binary + its config file, instead of
  # Stow just symlinking a hand-edited file. NOTE: enableZshIntegration is
  # deliberately left off all four — that flag makes home-manager inject
  # its init hooks into home-manager's OWN generated ~/.zshrc, which only
  # happens if programs.zsh.enable = true here. We're keeping the real
  # .zshrc Stow-managed instead (zshrc/.zshrc in this repo), so the
  # `eval "$(atuin init zsh)"` etc. lines live there by hand, same as
  # omerxx's original file did. Nix still owns the binary + `settings`;
  # Stow's .zshrc just owns the one-line shell-hook activation.

  programs.atuin = {
    enable = true;
    # Fully declarative, same reasoning as starship below: his
    # config.toml was almost entirely defaults (commented-out docs) with
    # only these three overrides actually set, so home-manager now
    # generates ~/.config/atuin/config.toml and atuin/ is removed from
    # this repo rather than kept Stow-symlinked.
    settings = {
      style = "compact";
      enter_accept = true;
      sync.records = true;
    };
  };

  programs.starship = {
    enable = true;
    # Fully declarative: home-manager generates ~/.config/starship.toml
    # from this attrset, so (unlike zshrc) there's no Stow-managed copy
    # of this file anymore — starship/ was removed from this repo.
    settings = {
      add_newline = false;
      format = "$directory$character";
      palette = "catppuccin_mocha";
      right_format = "$all";
      command_timeout = 1000;

      character = {
        vicmd_symbol = "[N] >>>";
        success_symbol = "[➜](bold green)";
      };

      git_branch.format = "[$symbol$branch(:$remote_branch)]($style)";

      golang.format = "[ ](bold cyan)";

      palettes.catppuccin_mocha = {
        rosewater = "#f5e0dc";
        flamingo = "#f2cdcd";
        pink = "#f5c2e7";
        mauve = "#cba6f7";
        red = "#f38ba8";
        maroon = "#eba0ac";
        peach = "#fab387";
        yellow = "#f9e2af";
        green = "#a6e3a1";
        teal = "#94e2d5";
        sky = "#89dceb";
        sapphire = "#74c7ec";
        blue = "#89b4fa";
        lavender = "#b4befe";
        text = "#cdd6f4";
        subtext1 = "#bac2de";
        subtext0 = "#a6adc8";
        overlay2 = "#9399b2";
        overlay1 = "#7f849c";
        overlay0 = "#6c7086";
        surface2 = "#585b70";
        surface1 = "#45475a";
        surface0 = "#313244";
        base = "#1e1e2e";
        mantle = "#181825";
        crust = "#11111b";
      };
    };
  };

  programs.zoxide.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.sessionVariables = { };

  home.sessionPath = [
    "/run/current-system/sw/bin"
    "$HOME/.nix-profile/bin"
  ];

  programs.home-manager.enable = true;

  # programs.zsh is intentionally NOT enabled here — see note above.
  # Nix's PATH additions and the Nix daemon sourcing live directly in the
  # Stow-managed zshrc/.zshrc instead, so there's exactly one place that
  # owns zsh startup.
}
