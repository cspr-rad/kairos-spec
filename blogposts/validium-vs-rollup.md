# Validium vs. Rollup

Introduction: Context for ZKR vs. ZKV
- The blockchain industry is highly focused on scaling solutions right now
- One of the most promising options is to build a ZK-based L2
- Important question: What do you still put on the L1?
- Option 1: ZKRs put the data and state update proofs on L1
- Option 2: ZKVs only put state hashes on state update proofs on L1
- We will discuss an important note on the difficulty of building rollups

A note on sequential vs. parallel throughput:
- Imagine two people interacting with a DEX
- My transaction thus dependents on the state that results from your swap. There
  are now two options:
- Option 1. I am aware of your output state. In this case, you have created,
  signed and submitted your transaction to the L2 server. I then pull your
  output state from the L2 server, construct, sign and submit my transaction.
  Given limitations such as how long it takes to sign a transaction and to send
  data back and forth to the server, this setup leads to a maximal sequential
  throughput #footnote[Sequential throughput is defined by the number of
  transactions which can be posted to the L2 where each transaction depends on
  the output of the former.] of around 1 Tx/s.
- Option 2. I am not aware of your output state. In this case, I have to
  construct a L2 transaction and sign it without being fully aware of its
  effects yet. In the example of the DEX swaps, I will sign a transaction which
  does not fully determine how many tokens I will receive back from the DEX,
  which leads to uncertainty and possible complications. In addition, within a
  centralized L2 scenario, this option allows the L2 server to change the order
  in which transactions happen, thus creating the equivalent of sandwich
  attacks.
- Our solution is to ensure all L2 transactions within the same batch proof to
  be independent of one another. This avoids any complications. In making this
  decision, we restrict the sequential throughput of your system.

We need to store a lot of data for scalability:
- We want substantial throughput, but as mentioned we're only increasing
  parallel throughput
- This means we need to make sure transactions are parallelized, each
  interacting with a different part of the blockchain
- Hence the blockchain will have many parts, which corresponds to much separate
  data, e.g. many wallets and sharding smart contracts
- Few blockchains can store all that data in one smart contract, which would be
  necessary in order to build a ZKR-based L2
- Finally, state updates get expensive (gas fees), which takes away one of the
  main benefits of building ZK-based L2s in the first place
- Hence, ZKRs are mostly useful for very specific projects and purposes, such as
  ones which interact with other projects through Polygon CDK's
  interoperability, and for projects which allow for sequential transactions in
  the same batch proof

Conclusion: We want a big system that can support all of the Casper blockchain's
future transactions, as well as digital art (NFT minting & transfers) and
eventually many L2 dApps, which means we don't fit within the parallelized ZKR
use case. Hence we require a ZKV.



