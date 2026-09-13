{
  description = "An isolated Steam-run environment with custom libraries";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
	libsodium1018 = pkgs.callPackage ./pkgs/libsodium { };
        
        extraLibs = [
	  libsodium1018
	  pkgs.snappy
        ];

        # 2. Create a custom steam-run that includes your extra libraries
	customSteamRun = (pkgs.steam.override {
          extraLibraries = pkgs: extraLibs;
        }).run;
      in
      {
        # Allows you to drop into a shell with 'nix develop'
        devShells.default = pkgs.mkShell {
          buildInputs = extraLibs; # Available for building from source

          shellHook = ''
            echo "Steam-run environment loaded!"
            echo "Use 'steam-run ./your-compiled-binary' to execute."
          '';

          # Expose your customized steam-run directly in the shell path
          packages = [ customSteamRun ];
        };

        # Optional: Allows you to run it directly via 'nix run'
        apps.default = {
          type = "app";
          program = "${customSteamRun}/bin/steam-run";
        };
      });
}
