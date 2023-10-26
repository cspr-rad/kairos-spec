# Spec

A first draft of the spec can be found in [spec](./src/spec.typ).

The sequence diagram that we created at the workshop in Zug can be found in the diagrams subdirectory [here](./src/diagrams/simple_transfer_diagram.mmd).

Additional sequence diagrams can be found [here](./src/diagrams).

# Typst

Generate the spec's pdf by running `typst c spec.typ`, continually update
throughout development by running `typst w spec.typ`.

# Diagrams

All the diagrams can be either built alltogether by running `nix build .#diagrams` or individually. To build them individually please follow the following subsection.

## PlantUML
In order to build the `*.puml` diagrams, we use [PlantUML](https://plantuml.com/). For installation, see [Local Installation notes](https://plantuml.com/faq-install) or enter the `devShell` of this project by running `nix develop`. The package in the `nixpkgs` set is called `plantuml`. Once installed, `*.puml` diagrams can be converted to svg by running:
```
plantuml diagrams/transfer_sequence_diagram_client_submit.puml -tsvg
```

## Graphviz
In order to build the `*.dot` diagrams, we use [Graphviz](https://graphviz.org/). For installation, see [Downloads](https://graphviz.org/download/) or enter the `devShell` of this project by running `nix develop`. The package in the `nixpkgs` set is called `graphviz`. Once installed, `*.puml` diagrams can be converted to svg by running:
```
dot -Tsvg diagrams/merkle-tree.dot > merkle-tree.svg
```

