{
  description = "kairos-spec";
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    inputs@{ self
    , flake-parts
    , nixpkgs
    , treefmt-nix
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [
        treefmt-nix.flakeModule
      ];
      perSystem = { config, self', inputs', system, pkgs, lib, ... }:
        let
          kairos-spec = pkgs.stdenv.mkDerivation {
            name = "kairos-spec";
            src = ./src;
            nativeBuildInputs = [
              pkgs.typst
            ];
            buildCommand = ''
              mkdir -p $out
              typst compile $src/spec.typ $out/spec.pdf
            '';
          };
        in
        {
          treefmt = {
            projectRootFile = ".git/config";
            programs.nixpkgs-fmt.enable = true;
            settings.formatter = { };
          };
          packages = {
            inherit kairos-spec;
            default = self'.packages.kairos-spec;
          };
          devShells.default = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [
              typst
              typst-lsp
            ];
          };
        };
    };
}
