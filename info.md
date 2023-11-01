# Info

Useful reference links:
- https://ethereum.org/en/developers/docs/scaling/validium/
- https://docs.starkware.co/starkex/overview.html
- https://docs.starkware.co/starkex/architecture/solution-architecture.html

Next actions:
- Add a summary of "Why centralized L2?" somewhere, and move to a blogpost
- Don't mention the Casper Association running anything
- Remove Risc0, NixOS and Rust mentions in sections 5-6
- Turn the `blogposts/` folder into blogposts

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



