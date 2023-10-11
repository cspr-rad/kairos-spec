#let title = [
  ZK Validium Proof of Concept
]
#let time_format = "[weekday] [month repr:long] [day padding:none], [year]"
#set page(
  paper: "a4",
  numbering: "1",
  margin: (x: 3.2cm, y: 4.0cm),
)
#set heading(numbering: "1.")
#set text(
  // font: "Linux Libertine",
  size: 12pt,
)

#align(center, text(21pt)[
  *#title*

  Marijan Petricevic,
  Nick Van den Broeck

  #datetime.today().display(time_format)
])

#outline(
  title: "Contents",
  indent: auto,
)

#pagebreak()

= Introduction

== Motivation

As an intermediate step towards building a zero-knowledge rollup for ACTUS contracts, the goal of this project - a zero-knowledge validium, is to explore the required changes that need to be made on the Casper node in order to create/ validate zero-knowledge proofs. Furthermore the size and complexity of this project not only provides an opportunity to get a better understanding of the challenges associated with bringing zero-knowledge prooving into production but also allows the team to collaborate and grow together by developing a production-grade solution.

It is important to mention that a zero-knowledge validium is a layer 2 scaling solution which in comparison to a zero-knowledge rollup moves the data availability and computation off the chain.

== Goal

Build a system to allow Casper payments with lower gas fees.

TODO: Mention that this is the first step both towards a very cheap, frictionless NFT system (minting and transfering) so Casper can become _the_ art blockchain, and towards putting ACTUS on Casper.

A user of the validium will be able to deposit, withdraw and transfer CSPR token. In the following sections we will discuss the mandatory-, optional-, and delimination criteria we require for each of the aforementioned interactions.

== Why should you care?

= Criteria

== Interactions

=== Deposit money into L2 system

A user should be able to deposit CSPR token from the Casper chain to its validium account at any given time through a web user interface (UI), or through a command-line-interface (CLI).

=== Withdraw money from L2 system

A user should be able to withdraw CSPR token from his account to the Casper chain at any given time through a web UI, or through the CLI. This interaction should be made possible without the approval of the validium operator ([see](https://ethereum.org/en/developers/docs/scaling/validium/#deposits-and-withdrawals))

=== Transfer money within the L2 system

A user should be able to transfer CSPR token from his validium account to another users validium account at any given time through a web UI, or through the CLI.

=== Query account balances

A user should be able to query its validium account balance of available CSPR token at any given time through a web UI, or through the CLI.

== Requirements

=== Verification: Each transfer must be verified by L1

=== Storage

Common queries must be easy to make against the L2 node, such as checking account balances and listing all transactions related to a specific person. In addition, the storage must be persistent and reliable, i.e. there must be redundancies built-in to avoid loss of data.

=== Which trust assumptions can we make?

== Post-PoC features

=== The L2 node should be paid

=== Query storage

Anyone can query the transaction history based on certain filters, such as a specific party being involved and time constraints.

== Usage

- Use cases
- What will run where, and by whom: Normal usage through website, plus CLI to interact with the system more. CLI should work on all Linux systems. CLI is only used by developers.

= Requirements

== Functional requirements

=== Deposits

=== Withdrawals

=== Withdrawals without requiring L2 approval

This endpoint is necessary in order to avoid such a stringent trust assumption on the L2. Without it, we require L2's approval in order to withdraw our funds from the system in case we lose trust.

=== Transfer

=== Query account balance

=== Query all transfers given filters

Filters could be that one party is involved (i.e. "give me all data related to this institution") or time-bounded.

=== Verification

=== Storage

== Non-functional requirements

These are qualitative requirements, such as "it should be fast". Can be fulfilled with e.g. benchmarks.

=== Base functionality

- [tag:NRB01] The application should not leak any private or sensitive informations like private keys
- [tag:NRB01] The backend API needs to be designed in a way such that it's easy to swap out a web-UI implementation

= UI/UX

Mockups written out + diagrams.

= High-level design

- List the different components and their rough responsibilities briefly & add diagrams
- List design decisions and why they are made
- Describe the requirements on each component
- Describe the hardware and tooling we will use: Rust, WASM (for Casper smart contracts)..

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

== Validium vs. rollup

We're attempting to create an L2 solution which can scale to 10k Tx/s. However, these transactions need to be indpendent, since dependent transactions require the latter transaction to be aware of the state resulting from the first transaction, which you'll not be able to query quickly enough (given restrictions such as the time it takes to sign a transaction and send messages around given the speed of light). Therefore, in order to reach 10k Tx/s you need at least 20k people using the L2. Therefore, 20k people's L2 account balances need to be stored within the validium L1 smart contract. This means the data associated with this contract will supercede Casper L1's data limits, leading to the requirement for our L2 solution to be a Validium.

== Centralized L2

Decentralized L2s require many complex problems to be resolved:
- Everyone involved in the L2 must get paid
- L2 storage must have a consensus algorithm to take away the need for a trust assumption on its storers
- ...

Therefore, a centralized L2 including only a single node, ran by the Casper Association, is a very attractive solution. This poses the question, what are the dangers in centralized L2s?
- Denial of service: The L2 node could block any user from using the system
- Denial of withdrawal: We could block someone from getting their funds back. We should build a feasible solution for this. Look into Data Availability Committees. Should we think through (roughly) a post-PoC solution already?
- What if the L2 node loses the data? Then we can no longer confirm who owns what, and the L2 system dies a painful death.

TODO: What can we do about these issues? To the extent that they remain, how can we reduce their impact?

== Privacy provided by L2

We don't really provide any increased privacy compared to L1. The reason for this is that we don't want to be TornadoCash 2.0.

= Low-level design

Go through all components and describe in detail how they work. What does the
ZKP prove? What does the smart contract design look like?

Add sequence diagrams for interactions between all the components.

== Data

Transaction:
- [tag:DT01] Sender address
- [tag:DT02] Receiver address
- [tag:DT03] Amount
- [tag:DT04] Token-ID i.e. currency
- [tag:DT05] Associated layer 1 blockhash

= Testing

== E2E testing

== Integration testing

== Attack testing

== Property testing

== Whatever else Syd can come up with



