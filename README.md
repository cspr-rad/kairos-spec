# Spec

A first draft of the spec can be found in [spec](./src/spec.typ).

The sequence diagram that we created at the workshop in Zug can be found in the diagrams subdirectory [here](./src/diagrams/transfer_sequence_diagram.mmd). Additional sequence diagrams can be found [here](./src/diagrams).

# Typst

Generate the spec's pdf by running `typst c spec.typ`, continually update
throughout development by running `typst w spec.typ`.

# Mermaid

In order to create sequence diagrams, we use [Mermaid](https://mermaid.js.org/#/). For installation, see [github](https://github.com/mermaid-js/mermaid-cli) or the flake.nix devShell. In NixOS, you can import mermaid-cli as either `pkgs.mermaid-cli` (nixos-unstable) or `pkgs.nodePackages.mermaid-cli` (nixos-23.05). Once installed, any of the diagrams can be converted to svg through
```
mmdc -i <input>.mmd -o <output>.svg
```



