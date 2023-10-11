# Info

Questions:
- How do we create ZKVP (zero knowledge validium proofs) quickly? Do we need to
  create parallelization "manually", through recursive proofs, or does RISC0
  handle this for us?
- What should be the structure of the spec? In what order should we figure
  things out and write them down? For figuring things out, I would propose
  1. goal
  2. interactions
  3. high-level design a system that fits these interactions, i.e. list
  components and how they interact
  4. decide on tooling and low-level designs, i.e. decide how each component
  will be built, what the smart contract will look like in detail, and what the
  ZKP will prove
  5. test plan
- Pros and cons of validium vs. rollup
- What are the interesting queries people should be able to make at the
  validium?
- What are the dangers in having a centralized L2?
  * Denial of service: The L2 node could block any user from using the system
  * Denial of withdrawal: We could block someone from getting their funds back.
    We should build a feasible solution for this. Look into Data Availability
    Committees. Should we think through (roughly) a post-PoC solution already?
  * What if the L2 node loses the data? Then we can no longer confirm who owns
    what, and the L2 system dies a painful death.

Notes:
- The validium smart contract stores the hash of the entire accounting
- Withdrawals can be done easily through L2, by the user submitting a request to
  withdraw to L2 and L2 including that into the L1 transaction it generates
  next. However, this relies on the L2 not denying you service.
- "Validity proofs" are ZKPs rolled up into one

Goal: Build a system to allow Casper payments with lower gas fees.

Solution: ZKR/V to specifically only allow 

Requirements:
- Anyone can deposit, withdraw and query their account balance
- Anyone who has money deposited, can transfer to others who have deposited
  money
- Privacy is maintained: You cannot see who transfered money to who, within one
  rolled up state update
- Security is maintained: You cannot transfer someone else's money or create
  money

In terms of the 6 component rollup:
- Consensus layer = Casper's L1, which must be able to accept deposits and
  withdrawals and accept L2 state updates
- L2 nodes: A centralized, single L2 node, for simplicity's sake. This will
  connect all the other components.
- Data availability: The L2 server allows an interface to query public inputs
  and their associated proofs
- Contracts: Simple payments
- ZK prover: Risc0 generates proofs from the L1 simple payment transactions sent
  to the L2 node
- Rollup: ???

Components in design terms:
- L1 contract
  * Deposit & withdraw money
  * Accept state updates from L2, checking their (rolled up) proof
- L2 server
  * Read L1 contract state
  * Accept payment requests
  * Generate ZKPs
  * Roll up ZKPs
  * Store ZKPs and open an interface to query public data
  * Post state updates to L1
- Website
  * Connect to your CSPR wallet
  * Deposit, withdraw & query account balance
  * Make L2 payments
  * Query L2 storage: Public info & proofs
- CLI
  * Do everything the website can do
  * Verify proofs & rollups

Issues:
- Learn about the Casper node: Limit on data per L1 transaction etc.?
- How to integrate a ZK verifier with the Casper node?
- How to avoid conflicts between L1 and L2 transactions?
  * L1 must get precedence, but we also need to avoid DoS attacks
- What exactly do the ZKPs prove?
- Privacy: What data do we expose?
  * Decision: The L2 data availability layer will expose all public data,
    including the original transactions.
- How to assure being able to withdraw without needing the L2 node?
- How does the L2 node get paid?
  * This is a post-PoC worry, once we get something in prodcution that people
    actually use.

To do:
- Write out why this plan is so good, both for developer productivity and
  motivation, to build towards an ACTUS ZKR, and to please the Casper people who
  give us money and would like an NFT generating and transfering machine with
  low fees
- Dig into Merkle trees, and how they are used as cryptographic proofs of states
  for validiums
  * What are "Merkle proofs" in the context of Validium fund withdrawals?



