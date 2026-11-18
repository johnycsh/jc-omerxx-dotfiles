{
  description = "johnycsh's Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
  let
    configuration = { pkgs, ... }: {
      # System-wide packages. Keep this small — most CLI tools belong in
      # home.nix (home.packages) instead, scoped to the user account.
      environment.systemPackages = [
        pkgs.vim
      ];

      nix.settings.experimental-features = "nix-command flakes";
      nix.configureBuildUsers = true;
      nix.useDaemon = true;

      programs.zsh.enable = true; # default login shell on macOS

      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 4;
      nixpkgs.hostPlatform = "aarch64-darwin"; # Apple Silicon

      security.pam.enableSudoTouchIdAuth = true;

      users.users.johnycsh.home = "/Users/johnycsh";
      home-manager.backupFileExtension = "backup"; # don't error on pre-existing files, rename-and-keep them instead

      # system.defaults = { ... };  # macOS defaults (dock, finder, etc.) — TODO once the basics are working

      # Homebrew itself still needs to be installed manually, but once
      # present, nix-darwin can declare which casks/brews should exist.
      homebrew = {
        enable = true;
        onActivation = {
          autoUpdate = false;
          cleanup = "none"; # conservative default: won't uninstall anything not listed below until we trust the list
        };
        casks = [
          # fill in as we migrate each GUI tool
        ];
        brews = [
          # custom taps that don't exist in nixpkgs go here
        ];
      };
    };
  in
  {
    darwinConfigurations."DRP-e1" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        configuration
        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.johnycsh = import ./home.nix;
        }
      ];
    };

    darwinPackages = self.darwinConfigurations."DRP-e1".pkgs;
  };
}
