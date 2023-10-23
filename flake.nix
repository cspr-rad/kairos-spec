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
            nativeBuildInputs = with pkgs; [
              nodePackages.mermaid-cli
              graphviz
              typst
            ];
            buildCommand = ''
              set -x
              mkdir -p $out
              dot -Tsvg $src/diagrams/merkle-tree.dot > $out/merkle-tree.svg
              dot -Tsvg $src/diagrams/merkle-tree-updated.dot > $out/merkle-tree-updated.svg
              mmdc -i $src/diagrams/transfer_sequence_diagram.mmd -o $out/transfer_sequence.svg
              mmdc -i $src/diagrams/deposit_sequence_diagram.mmd -o $out/deposit.svg
              mmdc -i $src/diagrams/simple_transfer_diagram.mmd -o $out/simple_transfer.svg
              mmdc -i $src/diagrams/components_diagram.mmd -o $out/components.svg
              cp $src/spec.typ $out/spec.typ
              typst compile $out/spec.typ $out/spec.pdf
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
              nodePackages.mermaid-cli
              graphviz
            ];
          };
        };
    };
}
