# Info

Useful reference links:
- https://ethereum.org/en/developers/docs/scaling/validium/
- https://docs.starkware.co/starkex/overview.html
- https://docs.starkware.co/starkex/architecture/solution-architecture.html

Notes:
- "Validity proofs" are ZKPs rolled up into one

First steps:
- Dig into casper node: What does a Casper transaction look like? Data limits?
- Casper node environment: How to integrate ZK verifier?
- Mermaid: Include a devShell with Mermaid, a command to generate SVGs from the
  .mmd files, and make sure the SVGs are generated before calling typst
  (Marijan)
- Dig through the remaining issues
- Write the rest of the spec, including many diagrams for the responsibilities
  of each component, how they work internally and sequence diagrams
- Risc0 PoC: Write a simple program to prove 10,000 times the same simple
  program, each time with different inputs and one output being the input to the
  next Tx. See how quickly it executes on a good machine. Include GPU
  acceleration.



