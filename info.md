# Info

Useful reference links:
- https://ethereum.org/en/developers/docs/scaling/validium/
- https://docs.starkware.co/starkex/overview.html
- https://docs.starkware.co/starkex/architecture/solution-architecture.html

Notes:
- The validium smart contract stores the hash (i.e. root of the Merkle tree) of
  all the L2 account balances
- Withdrawals can be done easily through L2, by the user submitting a request to
  withdraw to L2 and L2 including that into the L1 transaction it generates
  next. However, this relies on the L2 not denying you service.
- "Validity proofs" are ZKPs rolled up into one

Questions:
- Does Risc0 support GPU acceleration? What about Lita's products?

First steps:
- Review & edit typst so Mark can use everything
- Dig into casper node: What does a Casper transaction look like? Data limits?
- Casper node environment: How to integrate ZK verifier?

Next batch of steps:
- Dig through todos
- Risc0 PoC: Write a simple program to prove 10,000 times, see how quickly it
  executes on a good machine
- Dig through the remaining issues
- Write the rest of the spec, including many diagrams for the responsibilities
  of each component, how they work internally and sequence diagrams

To do:
- Write out why this plan is so good, both for developer productivity and
  motivation, to build towards an ACTUS ZKR, and to please the Casper people who
  give us money and would like an NFT generating and transfering machine with
  low fees
- What exactly do the ZKPs prove?
- How to avoid conflicts between L1 and L2 transactions?
  * L1 must get precedence, but we also need to avoid DoS attacks
- How to assure being able to withdraw without needing the L2 node?
  * One option is to add a "withdraw all request" endpoint to the L1 contract,
    where someone can request to get all their funds back, and the L2 isn't
    allowed to post anything until they either pay back this person's funds, or
    show that this person has no funds on L2.
- To what extend do we need to make the L2 node's interface compliant with the
  L1 node's interface, in terms of
  * What does an L2 transaction look like?
  * What does a query look like to query account balances?
  * How do we make the Casper wallet compliant with L2?



