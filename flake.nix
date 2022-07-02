{
  description = "Additional components for the Google Cloud CLI.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let data = import ./data.nix { };
    in flake-utils.lib.eachDefaultSystem (system: {
      packages = builtins.mapAttrs (name: pkg:
        nixpkgs.legacyPackages.${system}.stdenv.mkDerivation {
          name = "${name}-${pkg.version}";
          version = pkg.version;
          src = builtins.fetchurl pkg.src;
          sourceRoot = ".";
          installPhase = ''
            install -m755 -D bin/* -t $out/bin/
          '';
        }) data.googleCloudSdkComponents.${system};
    });
}
