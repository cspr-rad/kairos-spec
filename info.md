# Info

Useful reference links:
- https://ethereum.org/en/developers/docs/scaling/validium/
- https://docs.starkware.co/starkex/overview.html
- https://docs.starkware.co/starkex/architecture/solution-architecture.html

Next actions:
- Revisit sequence diagrams (Marijan)
- Write 1-2 blogposts (Nick)

The projects:
- Split up the work into separate projects & ask the team to get started
- Set up test plan
- Casper node deep-dive: What does a Casper transaction look like? Data limits?
- Risc0 deep-dive
  * Benchmark running 10,000 small transactions, with GPU acceleration. Do we
    need parallelization over multiple machines for the PoC?
  * Benchmark the storage and computational needs of batch proof verification:
    Can this run within a smart contract?
- Test our assumption that we don't need Merkle tree rebalancing

Remaining decisions, after deep-dives:
- Split up the smart contract into two, where one stores the state and the other
  verifies the proofs



