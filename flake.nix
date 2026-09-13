{
  description = "steam-run with libsodium 1.0.18";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      lib = nixpkgs.lib;
      # The Steam client only ships for x86_64-linux
      systems = [ "x86_64-linux" ];
    in
    {
      packages = lib.genAttrs systems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };

          libsodium1018 = pkgs.callPackage ./pkgs/libsodium { };

          steamRun = pkgs.stdenvNoCC.mkDerivation {
            pname = "steam-run";
            version = pkgs.steam.version;
            nativeBuildInputs = [ pkgs.makeWrapper ];
            dontUnpack = true;
            dontBuild = true;
            installPhase = ''
              runHook preInstall
              mkdir -p $out/bin
              makeWrapper ${pkgs.steam}/bin/steam-run $out/bin/steam-run \
                --prefix LD_LIBRARY_PATH : ${libsodium1018}/lib
            '';
            meta = {
              description = "steam-run with libsodium 1.0.18 in LD_LIBRARY_PATH";
              license = lib.licenses.unfreeRedistributableFoss;
              platforms = [ "x86_64-linux" ];
            };
          };
        in
        {
          default = steamRun;
          inherit libsodium1018 steamRun;
        });
    };
}
