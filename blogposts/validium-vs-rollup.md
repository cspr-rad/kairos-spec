# Validium vs. Rollup

Introduction:
- Context for ZKR vs. ZKV
  * The blockchain industry is highly focused on scaling solutions right now
  * One of the most promising options is to build a ZK-based L2
  * Important question: What do you still put on the L1?
  * Option 1: ZKRs put the data and state update proofs on L1
  * Option 2: ZKVs only put state hashes on state update proofs on L1
  * We will discuss an important note on the difficulty of building rollups

Overview:
- We need substantial throughput, but usually only parallelized throughput is
  increased
- Increasing sequential throughput is either dangerous or very limited (~1 Tx/s)
- This measn we need to make sure transactions are parallelized, each
  interacting with a different part of the blockchain
- Hence the blockchain will have many parts, i.e. wallets and smart contracts
  (e.g. sharding)
- This requires lots of data to be stored
- Few blockchains can store all that data in one smart contract, which would be
  necessary in order to build a ZKR-based L2
- Finally, state updates get expensive (gas fees), which takes away one of the
  main benefits of building ZK-based L2s in the first place
- Hence, ZKRs are mostly useful for very specific projects and purposes, which
  can then interact with other projects through e.g. Polygon CDK's
  interoperability
- For us, we want a big system that can support all of the Casper blockchain's
  future transactions, as well as digital art (NFT minting & transfers) and
  eventually many L2 dApps, which means we don't fit within the ZKR use case.
  Hence we require a ZKV.

As mentioned in the introduction, a ZK rollup is an L2 solution where the state
is stored on the L1, while state updates are performed by the L2. A ZK proof,
proving that such a state update was performed correctly, is then posted along
with the new state on L1. A ZK Validium is similar to a ZK rollup except in that
the whole state isn't posted to the L1, but rather a hash of the state. This
requires significantly less data resources on L1, and therefore allows further
scaling.

We are attempting to create an L2 solution which can scale up to 10,000
transactions per second. However, these transactions need to be independent. The
reason for that is that dependent transactions require latter transaction to be
aware of the state resulting from the prior transaction. Note: the state is a
Merkle root of the account balances. Given restrictions such as the time it
takes to sign a transaction and send messages around constrained by the speed of
light, one is not quick enough to query the prior state. Therefore, in order to
reach 10,000 transactions per second you need at least 20,000 people using the
L2. This requires 20,000 people's L2 account balances to be stored within the L1
smart contract. However, this amount of data supercedes Casper L1's data limits.
In conclusion, any L2 ZK solution on top of Casper must be a Validium.



