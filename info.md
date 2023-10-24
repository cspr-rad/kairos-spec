# Info

Useful reference links:
- https://ethereum.org/en/developers/docs/scaling/validium/
- https://docs.starkware.co/starkex/overview.html
- https://docs.starkware.co/starkex/architecture/solution-architecture.html

Notes:
- "Validity proofs" are ZKPs rolled up into one. In the spec, we call them ZKRs.

Next actions:
- Add `prover` as a component to the spec: High-level design & mermaid (Nick)
- Remove UI/UX section, move diagrams in high-level and low-level design (Nick)
- Rewrite `Validium vs. Rollup` section: What are both, and write a clearer
  conclusion (Nick)
- Rewrite low-level design into "considerations" and "design", and make "design"
  have the same structure for each component (Nick)
- Rewrite "two phases": Make it clear what phase 1 is (Nick)
- Ensuring L2 Tx uniqueness (Nick)
  * Explain the problem better
  * Better solution: Keep a counter of #L2 ZKRs posted on L1, and use that as a
    L2 Tx datum & public input to the ZKPs and ZKR. Include in 6.1.4 etc.
- Replace Mermaid so it works in Nix (Marijan)
- Finish up the diagrams (Marijan)
- Finish data redundancy subsubsection (Marijan)
- Get the spec approved by Mark (Nick)
- Split up the work into separate projects & ask the team to get started (Nick)
- Set up test plan (Nick)

The projects:
- Casper node deep-dive: What does a Casper transaction look like? Data limits?
- Casper wallet deep-dive: How can we get L2 Txs (JSON blobs) signed with the
  user's private key?
- Risc0 deep-dive
  * Benchmark running 10,000 small transactions, with GPU acceleration. Do we
    need parallelization over multiple machines for the PoC?
  * Benchmark the storage and computational needs of ZKR verification: Can this
    run within a smart contract?

Remaining decisions, after deep-dives:
- Split up the smart contract into two, where one stores the state and the other
  verifies the proofs



