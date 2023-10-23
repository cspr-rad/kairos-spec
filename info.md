# Info

Useful reference links:
- https://ethereum.org/en/developers/docs/scaling/validium/
- https://docs.starkware.co/starkex/overview.html
- https://docs.starkware.co/starkex/architecture/solution-architecture.html

Notes:
- "Validity proofs" are ZKPs rolled up into one. In the spec, we call them ZKRs.

Next actions:
- Research how to avoid Tx duplication
- Finish the sequence diagrams
- Get the spec approved by Mark
- Casper node deep-dive: What does a Casper transaction look like? Data limits?
- Casper wallet deep-dive: How can we get L2 Txs (JSON blobs) signed with the
  user's private key?
- Risc0 deep-dive
  * Benchmark running 10,000 small transactions, with GPU acceleration. Do we
    need parallelization over multiple machines for the PoC?
  * Benchmark the storage and computational needs of ZKR verification: Can this
    run within a smart contract?



