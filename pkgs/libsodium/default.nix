{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
}:

# libsodium 1.0.18: the Steam client requires this exact version at runtime;
# newer releases (1.0.19+) break it.
stdenv.mkDerivation (finalAttrs: {
  pname = "libsodium";
  version = "1.0.18";

  src = fetchurl {
    url = "https://download.libsodium.org/libsodium/releases/old/libsodium-${finalAttrs.version}.tar.gz";
    hash = "sha256-b1BEkLNCpPikxKAvybhmy++GItXfTlRStGvhIeRmNsE=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [ autoreconfHook ];

  separateDebugInfo = stdenv.hostPlatform.isLinux && stdenv.hostPlatform.libc != "musl";

  enableParallelBuilding = true;
  hardeningDisable = lib.optional (
    stdenv.hostPlatform.isMusl && stdenv.hostPlatform.isx86_32
  ) "stackprotector";

  configureFlags = lib.optional (
    stdenv.hostPlatform.isMusl && stdenv.hostPlatform.isx86_32
  ) "--disable-ssp";

  doCheck = true;

  meta = with lib; {
    description = "Modern and easy-to-use crypto library";
    homepage = "https://doc.libsodium.org/";
    license = licenses.isc;
    pkgConfigModules = [ "libsodium" ];
    platforms = platforms.all;
  };
})
