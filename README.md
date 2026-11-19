# Dotfiles

Personalized fork of [omerxx/dotfiles](https://github.com/omerxx/dotfiles),
adapted for my own machine. Package management is moving to Nix
(nix-darwin + home-manager); most config files are still Stow-managed.

## Install

1. **Bootstrap Nix**, if not already installed — the
   [Determinate Systems installer](https://github.com/DeterminateSystems/nix-installer):
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```
   Open a new shell (or `. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh`) afterward.

2. **Apply the nix-darwin + home-manager config**, which installs most CLI
   tools and generates a few fully-declarative configs (atuin, starship,
   zoxide, direnv):
   ```bash
   mkdir -p ~/.config/nix-darwin
   cp nix-darwin/flake.nix nix-darwin/home.nix ~/.config/nix-darwin/
   cd ~/.config/nix-darwin
   sudo nix run nix-darwin -- switch --flake .
   ```
   Re-run `sudo nix run nix-darwin -- switch --flake .` any time `flake.nix`/`home.nix` change.

3. **Stow everything else.** This repo's `.stowrc` defaults every package's
   target to `~/.config`, which is correct for most packages (`nvim`,
   `tmux`, `television`, `gh-dash`, `nix-darwin`, etc.) but **not** for
   `zshrc` — that needs to land at `$ZDOTDIR` (`~/.config/zsh` on a machine
   using the XDG-style zsh layout), not `~/.config` itself. Check your
   `$ZDOTDIR` (`echo $ZDOTDIR`) before stowing:
   ```bash
   stow aerospace ghostty hammerspoon karabiner kindavim nvim sketchybar skhd television tmux wezterm gh-dash
   stow -t "${ZDOTDIR:-$HOME}" zshrc
   ```
   `atuin` and `starship` are **not** Stow packages — home-manager owns
   their config entirely (step 2 generates `~/.config/atuin/config.toml`
   and `~/.config/starship.toml` directly). If atuin still reads a stale
   `~/.atuin/config.toml` from an older standalone install, it'll ignore
   the Nix-generated one — move that file aside.

## What's Nix-managed vs. Stow-managed

| Nix (home.nix) | Stow |
|---|---|
| Most CLI packages (`home.packages`) | `nvim`, `tmux`, `television`, `gh-dash`, `zshrc` |
| `atuin`, `starship`, `zoxide`, `direnv` config (`programs.*`) | GUI app configs (see below) |

`zshrc/.zshrc` still does the shell-hook activation (`eval "$(starship init
zsh)"` etc.) by hand — home-manager's `enableZshIntegration` isn't used,
since that requires home-manager to own `~/.zshrc`/`$ZDOTDIR/.zshrc`
outright, which conflicts with keeping it Stow-managed.

## Future todos

- **macOS GUI / WM apps untouched**: `aerospace`, `ghostty`, `hammerspoon`,
  `karabiner`, `kindavim`, `sketchybar`, `skhd`, `wezterm` are still
  omerxx's originals, stowed as-is — not yet reviewed or personalized.
  Some reference his keybindings/workflow assumptions (e.g. sketchybar
  items) that may not make sense here.
- **`felinks` → `elinks` swap**: `home.nix` substitutes `elinks` for
  omerxx's `felinks` (nixpkgs doesn't have the fork) — not yet confirmed
  acceptable, and the Homebrew `felinks` formula hasn't been uninstalled
  pending that decision.
- **Retire remaining Homebrew duplicates deliberately**: `zsh` (currently
  the running shell — needs care) and `python@3.11` (home.nix uses 3.12)
  were held back from the bulk Homebrew-formula uninstall on purpose.
- **Homebrew's final footprint**: should end up as just GUI casks + custom
  taps (`coder`, `mutagen-io`), already declared in `flake.nix`'s
  `homebrew.casks`/`brews` — revisit once the GUI tier above is reviewed,
  since some of those apps may become nix-darwin `homebrew.casks` entries
  too.
- **Package names verified against nixpkgs so far**: `ipython`, `telnet`
  (→ `inetutils`), `rust` (→ `rustc` + `cargo`), `felinks` (→ `elinks`).
  Several packages in `home.nix`'s "left on Homebrew for now" comment
  block haven't been checked yet (`bitcoin`, `code-server`, `openvino`,
  etc.) — verify nixpkgs names before migrating each.
