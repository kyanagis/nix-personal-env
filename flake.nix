{
  description = "Cross-platform Nix environment for WSL, Linux, and macOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, nix-darwin, ... }:
    let
      linuxSystem = "x86_64-linux";
      darwinSystem = "aarch64-darwin";

      envOr = name: fallback:
        let
          value = builtins.getEnv name;
        in
          if value != "" then value else fallback;

      sudoUser = builtins.getEnv "SUDO_USER";
      resolvedUser =
        if sudoUser != "" then sudoUser else envOr "USER" "nixuser";
      linuxHomeDirectory =
        if sudoUser != "" then "/home/${resolvedUser}" else envOr "HOME" "/home/${resolvedUser}";
      darwinHomeDirectory =
        if sudoUser != "" then "/Users/${resolvedUser}" else envOr "HOME" "/Users/${resolvedUser}";

      mkPkgs = system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = false;
        };

      profileModule = profile: ./modules/home/profiles + "/${profile}.nix";

      mkHome = { system, profile, user, homeDirectory }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs system;
          extraSpecialArgs = {
            inherit inputs user profile homeDirectory;
          };
          modules = [
            (profileModule profile)
          ];
        };
    in {
      homeConfigurations = {
        wsl = mkHome {
          system = linuxSystem;
          profile = "wsl";
          user = resolvedUser;
          homeDirectory = linuxHomeDirectory;
        };

        linux = mkHome {
          system = linuxSystem;
          profile = "linux";
          user = resolvedUser;
          homeDirectory = linuxHomeDirectory;
        };
      };

      darwinConfigurations.mac = nix-darwin.lib.darwinSystem {
        system = darwinSystem;
        specialArgs = {
          user = resolvedUser;
          homeDirectory = darwinHomeDirectory;
          inherit inputs;
        };
        modules = [
          ./modules/darwin/system.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.backupFileExtension = "pre-hm";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              user = resolvedUser;
              homeDirectory = darwinHomeDirectory;
              profile = "darwin";
              inherit inputs;
            };
            home-manager.users.${resolvedUser} = import ./modules/home/profiles/darwin.nix;
          }
        ];
      };

      checks.${linuxSystem} = {
        home-wsl = self.homeConfigurations.wsl.activationPackage;
        home-linux = self.homeConfigurations.linux.activationPackage;
      };

      checks.${darwinSystem} = {
        darwin-system = self.darwinConfigurations.mac.system;
      };

      formatter.${linuxSystem} = (mkPkgs linuxSystem).nixpkgs-fmt;
      formatter.${darwinSystem} = (mkPkgs darwinSystem).nixpkgs-fmt;
    };
}
