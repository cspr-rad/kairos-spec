# Info

Notes:
- The validium smart contract stores the hash (i.e. root of the Merkle tree) of
  all the L2 account balances
- Withdrawals can be done easily through L2, by the user submitting a request to
  withdraw to L2 and L2 including that into the L1 transaction it generates
  next. However, this relies on the L2 not denying you service.
- "Validity proofs" are ZKPs rolled up into one

First steps:
- Merge spec.md into spec.typ
- Review & edit typst so Mark can use everything
- Dig into casper node: What does a Casper transaction look like? Data limits?
- How are ZKVPs generated? With parallelism?
- Casper node environment: How to integrate ZK verifier?

Next batch of steps:
- Dig through todos
- Dig through the remaining issues
- Write the rest of the spec, including many diagrams for the responsibilities
  of each component, how they work internally and sequence diagrams

To do:
- Write out why this plan is so good, both for developer productivity and
  motivation, to build towards an ACTUS ZKR, and to please the Casper people who
  give us money and would like an NFT generating and transfering machine with
  low fees
- Learn about the Casper node: Limit on data per L1 transaction etc.?
- How to integrate a ZK verifier with the Casper node?
- Dig into Merkle trees, and how they are used as cryptographic proofs of states
  for validiums
  * What are "Merkle proofs" in the context of Validium fund withdrawals?
- Look into ZKVMs: Do we need to parallelize the ZKP generation "manually",
  through recursive proofs, or does RISC0 handle this for us?
- What exactly do the ZKPs prove?
- How to avoid conflicts between L1 and L2 transactions?
  * L1 must get precedence, but we also need to avoid DoS attacks
- How to assure being able to withdraw without needing the L2 node?
- To what extend do we need to make the L2 node's interface compliant with the
  L1 node's interface, in terms of
  * What does an L2 transaction look like?
  * What does a query look like to query account balances?
  * How do we make the Casper wallet compliant with L2?



