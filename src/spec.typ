#let title = [
  Kairos: Zero-knowledge Validium Proof of Concept
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

The Casper Asscoiation has adopted the aim to establish ACTUS contracts on top of the Casper blockchain, thereby unlocking the potential to improve transparency and insights into TradFi without giving up scalability and privacy. As an intermediate step towards building a zero-knowledge-based Layer2 for ACTUS contracts, the goal of this project is to explore the ZK L2-space through a smaller scope. The reason for building this proof of concept is to focus the engineering effort and move forward productively, both in learning about Casper's L1 and how to integrate with it, building an L2, and generating and verifying ZK rollups. Furthermore the size and complexity of this project not only provides an opportunity to get a better understanding of the challenges associated with bringing zero-knowledge proving into production but also allows the team to collaborate and grow together by developing a production-grade solution.

The scope of the proof of concept is to build a zero knowledge validium which exclusively supports payment transfers on its L2. Here, a validium refers to the fact that the L2 account balances are stored off-chain, i.e. on L2 rather than L1. Enabling both a higher transaction throughput and reduced Casper gas fees. Afterwards, the project and gained knowledge can be used to include ACTUS contracts. 

Note that this proof of concept also forms the first step both towards very cheap, frictionless systems such as NFT minting and transfers, to aid Casper in becoming _the_ blockchain to push the art industry forward, as well as pushing forward towards the ACTUS end-goal.

The project itself contains very few basic interactions: Any user will be able to deposit to and withdraw from an L1 contract controlled by the ZK validium, and use the L2 to transfer tokens to others who have done the same. In the remainder of this document, we will detail the requirements on such a system and how we plan to implement and test it.

In @criteria (Criteria) we specify the high-level interactions that the proof of concept will implement. Afterwards, in @requirements we determine requirements based on the specified interactions which will/ can be end-to-end tested. Next, we describe some UX/UI concerns in @uxui. Next, we provide an abstract architecture in @high-level-design (High-Level Design), followed by the Low-Level Design in @low-level-design and lastly we discuss testing concerns in @testing.
k
= Criteria <criteria>

To have a common denominator on what the scope of the proof-of-concept is, this section describes the high-level mandatory-, optional-, and delimination criteria it has to fulfill.

== Mandatory Criteria

=== Deposit money into L2 system

A user should be able to deposit CSPR token from the Casper chain to its validium account at any given time through a web user interface (UI), or through a command-line-interface (CLI).

=== Withdraw money from L2 system

A user should be able to withdraw CSPR token from his account to the Casper chain at any given time through a web UI, or through the CLI. This interaction should be made possible without the approval of the validium operator ([see](https://ethereum.org/en/developers/docs/scaling/validium/#deposits-and-withdrawals))

=== Transfer money within the L2 system

A user should be able to transfer CSPR token from his validium account to another users validium account at any given time through a web UI, or through the CLI.

=== Query account balances

A user should be able to query its validium account balance of available CSPR token at any given time through a web UI, or through the CLI.

=== Verification

Each transfer must be verified by L1. And at any given time anyone should be able to verify deposits, withdrawals, or transactions. This should be possible through a web UI, the CLI, or through an application-programming-interface (API) i.e. a machine-readable way.

=== Storage

At any given time anyone should be able to check account balances and list all transactions related to a specific account. The storage must be persistent and reliable, i.e. there must be redundancies built-in to avoid loss of data.

Due to the nature of validiums, transaction data will be stored off-chain. To ensure that deposit, withdraw, and transfer interactions can be proven and verified at any given time by anyone, data needs to be available read-only publicly at any given time. To reduce the complexity of the project, this data will be stored by a centralized server that can be trusted. Writing and mutating data should only be possible by selected trusted instances/ machines. Moreover access to the transaction data should be available through an API.

=== Trust Assumptions

== Optional Criteria: Post-PoC features

=== The L2 node should be paid

=== Query storage

Anyone can query the transaction history based on certain filters, such as a specific party being involved and time constraints.

== Usage

- Use cases: This PoC allows users to benefit from faster and cheaper transactions on the Casper chain
- Target audience: Anyone who wants to make payment transfers on Casper
- Operating conditions: Our services will be ran on dedicated, powerful machines
- Product environment: There are two end-products, a web client (ran in resource-low environments, both in terms of computation and connectivity) and a CLI client (ran in resource-high environments by developers)

Tooling:
- The server host-machine will run on NixOS. It will include a powerful CPU and, depending on the ZK proving system we choose, a powerful GPU to provide ZKP acceleration. In addition, all machines involved (host and clients) require a working internet connection.
- The CLI client should run on any Linux distribution
- The web client should run on any modern web-browser with JavaScript enabled

= Requirements <requirements>

Based on the criteria defined in the previous section, this section aims to describe testable functional requirements the validium needs to fulfill.

== Functional requirements

=== Start up web client

- [tag:FRB00] Automatically connects to the users CSPR wallet

=== Deposit money into L2 system

- [tag:FRD00] Depositing an amount of `CSPR tokens`, where `CSPR tokens > 0` should be accounted correctly
- [tag:FRD01] Depositing an amount of `CSPR tokens`, where `CSPR tokens <= 0` should not be executed at all
- [tag:FRD02] A user depositing any valid amount to on its `validium account` should only succeed if the user has signed the deposit transaction
- [tag:FRD03] A user depositing any valid amount with a proper signature to another users `validium account` should not be possible

=== Withdraw money from L2 system

- [tag:FRW00] Withdrawing an amount of `CSPR tokens`, where `users validium account balance >= CSPR tokens > 0` should be accounted correctly
- [tag:FRW01] Withdrawing an amount of `CSPR tokens`, where `CSPR tokens <= 0` should not be executed at all
- [tag:FRW02] Withdrawing an amount of `CSPR tokens`, where `CSPR tokens > users validium account balance` should not be possible
- [tag:FRW03] Withdrawing a valid amount from the users validium account should be possible without the intermediary operator of the validium
- [tag:FRW03] Withdrawing a valid amount from the users validium account should only succeed if the user has signed the withdraw transaction
- [tag:FRW03] Withdrawing a valid amount from another users validium account should not be possible

=== Withdraw money from L2 system without requiring L2 approval

This endpoint is necessary in order to avoid such a stringent trust assumption on the L2. Without it, we require L2's approval in order to withdraw our funds from the system in case we lose trust.

=== Transfer money within the L2 system

- [tag:FRT00] Transfering an amount of `CSPR tokens`, where `users validium account balance >= CSPR tokens > 0` should be accounted correctly
- [tag:FRT01] Transfering an amount of `CSPR tokens`, where `CSPR tokens =< 0` should not be executed at all
- [tag:FRT02] Transfering an amount of `CSPR tokens`, where `CSPR tokens > users validium account` balance should not be possible
- [tag:FRT03] Transfering a valid amount to another user that does not have a registered validium account yet should be possible.
- [tag:FRT03] Transfering a valid amount to another user sbould only succeed if the user owning the funds has signed the transfer transaction

=== Query account balance

- [tag:FRA00] The user should be able to see its validium account balance immediately when it's queried (either through the CLI or web-UI)

=== Post-PoC: Query all transfers given filters

- [tag:FRA01] The user should be able to see all the past transactions involving its validium account (TODO discuss whether we actually need this for this MVP)

Filters could be that one party is involved (i.e. "give me all data related to this institution") or time-bounded.

=== Verification

- [tag:FRV00] Anyone should be able to verify proofs of the validiums state changes caused by deposit/ withdraw/ transfer interactions at any given time

=== Storage

- [tag:FRD00] Transaction data should be served read-only to anyone
- [tag:FRD01] Transaction data should be available at any given time
- [tag:FRD02] Transaction data should be written by known, verified entities only
- [tag:FRD03] Transaction data should be written immediately after the successful verification of correct deposit/ withdraw/ transfer interactions
- [tag:FRD04] Transaction data should not be written if the verification of the proof of the interactions fails

== Non-functional requirements

These are qualitative requirements, such as "it should be fast". Can be fulfilled with e.g. benchmarks.

- [tag:NRB01] The application should not leak any private or sensitive informations like private keys
- [tag:NRB01] The backend API needs to be designed in a way such that it's easy to swap out a web-UI implementation

= UI/UX <uxui>

Mockups written out + diagrams.

= High-level design <high-level-design>

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

= Low-level design <low-level-design>

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

= Testing <testing>

== E2E testing

== Integration testing

== Attack testing

== Property testing

== Whatever else Syd can come up with



