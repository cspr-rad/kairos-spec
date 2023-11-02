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
          kairos-spec = pkgs.runCommand "kairos-spec"
            {
              nativeBuildInputs = with pkgs; [
                typst
              ];
            }
            ''
              mkdir -p $out
              cp -r ${self'.packages.diagrams}/* .
              cp ${./src}/* .
              typst compile spec.typ $out/spec.pdf
            '';
          diagrams = pkgs.runCommand "diagrams" { nativeBuildInputs = with pkgs; [ plantuml graphviz ]; }
            ''
              mkdir -p $out
              for file in "${./diagrams}"/*; do
                filename=$(basename "$file")
                base_filename="''${filename%.*}"
                if [[ $file == *.puml ]]; then
                  echo "$file"
                  plantuml "$file" -tsvg -o $out
                fi
                if [[ $file == *.dot ]]; then
                  plantuml "$file" -tsvg -o "$out"
                  dot -Tsvg "$file" > "$out/$base_filename.svg"
                fi
              done
            '';
        in
        {
          treefmt = {
            projectRootFile = ".git/config";
            programs.nixpkgs-fmt.enable = true;
            settings.formatter = { };
          };
          packages = {
            inherit kairos-spec diagrams;
            default = self'.packages.kairos-spec;
          };
          devShells.default = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [
              typst
              typst-lsp
              graphviz
              plantuml
            ];
          };
        };
    };
}
