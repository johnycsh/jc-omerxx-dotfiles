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

    # git / dev workflow
    git
    gh
    lazygit
    tig
    go
    rust
    pyenv
    python311
    python311Packages.tkinter
    uv
    virtualenv
    ipython
    pandoc
    automake
    cmake

    # networking / remote
    curl
    wget
    rsync
    mosh
    nmap
    telnet
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
    felinks
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
    # settings = { };  # port over atuin/config.toml once compared against current setup
  };

  programs.starship = {
    enable = true;
    # settings = { };  # port over starship/starship.toml, translated to Nix attrs
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
