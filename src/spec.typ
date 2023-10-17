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
#show link: underline

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

The Casper Asscoiation has adopted the aim to establish ACTUS contracts on top of the Casper blockchain, unlocking the potential to improve transparency and insights into TradFi without giving up scalability and privacy. As an intermediate step towards building a Layer2 for ACTUS contracts, the goal of this project is to explore the L2-space through a smaller scope. The reason for building this proof of concept is to focus the engineering effort and move forward productively, both in learning about Casper's L1 and how to integrate with it, building an L2, and generating and verifying ZK rollups. Furthermore the size and complexity of this project not only provides an opportunity to get a better understanding of the challenges associated with bringing zero-knowledge proving into production but also allows the team to collaborate and grow together by developing a production-grade solution.

The goal of the proof of concept is to build a zero knowledge validium which exclusively supports payment transfers on its L2. Here, validium refers to the fact that the L2 account balances are stored off-chain, i.e. on L2 rather than L1, enabling both a higher transaction throughput and reduced gas fees on Casper. This is a great first step in the direction of building an ACTUS ZK-based L2 on Casper. Note that this proof of concept also forms the first step towards very cheap, frictionless systems for NFT minting and transfers, to aid Casper in becoming _the_ blockchain to push the art industry forward.

The project itself contains very few basic interactions: Any user will be able to deposit to and withdraw from an L1 contract controlled by the ZK validium, and use the L2 to transfer tokens to others who have done the same. In the remainder of this document, we will detail the requirements on such a system and how we plan to implement and test it.

In @criteria (Criteria) we specify the high-level interactions that the proof of concept will implement. @requirements determines requirements based on the specified interactions to end-to-end test. Next, we describe some UI/UX concerns in @uiux. Next, we provide an abstract architecture in @high-level-design (High-Level Design), followed by the Low-Level Design in @low-level-design and testing concerns in @testing.

= Criteria <criteria>

To have a common denominator on the scope of the proof of concept, this section describes the high-level mandatory-, optional-, and delimination criteria it has to fulfill.

== Mandatory Criteria

=== Deposit money into L2 system

A user should be able to deposit CSPR tokens from the Casper chain to their validium account at any given time through a web user interface (UI) or command line interface (CLI).

=== Withdraw money from L2 system

A user should be able to withdraw CSPR tokens from their validium account to the Casper chain at any given time through a web UI or CLI. This interaction should be made possible without the approval of the validium operator (#link("https://ethereum.org/en/developers/docs/scaling/validium/#deposits-and-withdrawals")[see Ethereum's validium]).

=== Transfer money within the L2 system

A user should be able to transfer CSPR tokens from their validium account to another user's validium account at any given time through a web UI or CLI.

=== Query account balances

Anyone should be able to query the validium account balances of available CSPR tokens at any given time through a web UI or CLI. In particular, users can also query their personal account balance.

Due to the nature of validiums, transaction data will be stored off-chain. To ensure interactions can be proven and verified at any given time by anyone, data needs to be available read-only publicly through an API. To reduce the complexity of the project, the data will be stored by a centralized server that can be trusted. Writing and mutating data should only be possible by selected trusted instances/machines. The storage must be persistent and reliable, i.e. there must be redundancies built-in to avoid loss of data.

=== Verification

Each transfer must be verified by L1. In addition, at any given time anyone should be able to verify deposits, withdrawals, or transactions. This should be possible through a web UI, the CLI, or application programming interface (API), i.e. a machine-readable way.

== Optional Criteria: Post-PoC features

=== Query storage

Anyone can query the transaction history based on certain filters, such as a specific party being involved and time constraints.

== Usage

The proof of concept can be used by any participants of the Casper network. It will allow any of them to transfer tokens and make payments with lower gas fees and significantly higher transaction throughput.

There will be two groups of users: tech-savvy and less tech-savvy. In order to accommodate both groups, we will offer three user interfaces: A web interface (website) for the less tech-savvy customer, and a CLI client and L2 API for developers. Thereby, we can serve customers directly while laso allowing new projects to build on top of our platform. Finally, this allows us to ensure that even customers in low-resource environments can participate, by moving the resource-heavy away from the web UI.

Our L2 server itself will be a set of dedicated, powerful machines, including a powerful CPU and GPU, in order to provide GPU accelleration for ZK proving (see Risc0). The machines will run NixOS and require a solid internet connection. The CLI client will run on any Linux distribution, whereas the web client will support any modern web-browser with JavaScript enabled.

= Requirements <requirements>

Based on the criteria defined in the previous section, this section aims to describe testable, functional requirements the validium needs to fulfill.

== Functional requirements

=== Start up web client

- [tag:FRB00] Automatically connects to the users CSPR wallet when they access the web interface

=== Deposit money into L2 system

- [tag:FRD00] Depositing an amount of `CSPR tokens`, where `CSPR tokens > 0` should be accounted correctly
- [tag:FRD01] Depositing an amount of `CSPR tokens`, where `CSPR tokens <= 0` should not be executed at all
- [tag:FRD02] A user depositing any valid amount to on its `validium account` should only succeed if the user has signed the deposit transaction
- [tag:FRD03] A user depositing any valid amount with a proper signature to another users `validium account` should fail

=== Withdraw money from L2 system

- [tag:FRW00] Withdrawing an amount of `CSPR tokens`, where `users validium account balance >= CSPR tokens > 0` should be accounted correctly
- [tag:FRW01] Withdrawing an amount of `CSPR tokens`, where `CSPR tokens <= 0` should not be executed at all
- [tag:FRW02] Withdrawing an amount of `CSPR tokens`, where `CSPR tokens > users validium account balance` should not be possible
- [tag:FRW03] Withdrawing a valid amount from the users validium account should be possible without the intermediary operator of the validium
- [tag:FRW03] Withdrawing a valid amount from the users validium account should only succeed if the user has signed the withdraw transaction
- [tag:FRW03] Withdrawing a valid amount from another users validium account should not be possible

=== Withdraw money from L2 system without requiring L2 approval

This endpoint is necessary in order to avoid such a stringent trust assumption on the L2. Without it, we require L2's approval in order to withdraw our funds from the system in case we lose trust.

- [tag:FRW04] Any user can withdraw all their money from the Validium without requiring L2's approval

=== Transfer money within the L2 system

- [tag:FRT00] Transfering an amount of `CSPR tokens`, where `users validium account balance >= CSPR tokens > 0` should be accounted correctly
- [tag:FRT01] Transfering an amount of `CSPR tokens`, where `CSPR tokens =< 0` should not be executed at all
- [tag:FRT02] Transfering an amount of `CSPR tokens`, where `CSPR tokens > users validium account` balance should not be possible
- [tag:FRT03] Transfering a valid amount to another user that does not have a registered validium account yet should be possible.
- [tag:FRT03] Transfering a valid amount to another user sbould only succeed if the user owning the funds has signed the transfer transaction

=== Query account balances

- [tag:FRA00] The user should be able to see its validium account balance immediately when it's queried (either through the CLI or web-UI)
- [tag:FRA01] Anyone should be able to see all validium account balances through the CLI, web-UI and API

=== Post-PoC: Query all transfers given filters

- [tag:FRA02] The user should be able to see all the past transactions involving its validium account (TODO discuss whether we actually need this for this MVP)

Filters could be that one party is involved (i.e. "give me all data related to this institution") or time-bounded.

=== Verification

- [tag:FRV00] Anyone should be able to query and verify proofs of the validiums state changes caused by deposit/withdraw/transfer interactions at any given time

=== Storage

- [tag:FRD00] Transaction data should be served read-only to anyone
- [tag:FRD01] Transaction data should be available at any given time
- [tag:FRD02] Transaction data should be written by known, verified entities only
- [tag:FRD03] Transaction data should be written immediately after the successful verification of correct deposit/withdraw/transfer interactions
- [tag:FRD04] Transaction data should not be written if the verification of the proof of the interactions fails

== Non-functional requirements

These are qualitative requirements, such as "it should be fast". Can be fulfilled with e.g. benchmarks.

- [tag:NRB01] The application should not leak any private or sensitive informations like private keys
- [tag:NRB01] The backend API needs to be designed in a way such that it's easy to swap out a web-UI implementation

= UI/UX <uiux>

Mockups written out + diagrams.

= High-level design <high-level-design>

Any ZK validium can be described as a combination of 6 components. For this proof of concept, we made the following choices:
- Consensus layer = Casper's L1, which must be able to accept deposits and withdrawals and accept L2 state updates
- Contracts: Simple payments
- ZK prover: Risc0 generates proofs from the L2 simple payment transactions
- L2 nodes: A centralized, single L2 node, for simplicity reasons. This will connect all other components.
- Data availability: The L2 server allows an interface to query public inputs and their associated proofs as well as the validium's current state
- Rollup: Risc0 is used to combine proofs into one, compressed ZKR, posted on L1

From a services perspective, the system consists of four components:
- L1 smart contract: This allows users to deposit, withdraw and transfer tokens
- L2 node: This allows users to post L2 transactions, generates ZKPs and posts the results on Casper's L1, and allows for querying the validium's current state
- Web UI: Connect to your wallet, deposit, withdraw and transfer tokens, and query the validium's state and your own balance
- CLI: Do everything the Web UI offers, and query and verify the Validium proofs

== Smart contract

The L1 smart contract will be implemented in WASM. Each update of the contract will be accompanied by a ZKP, in order to keep things uniform. The contract itself then has to verify two things:
+ That the ZKP is correct, given the contract endpoint called
+ That the ZKP's public inputs correspond to the inputs of the contract endpoint call
In other words, when an endpoint call comes in, we
- derive the ZK circuit to use for verification from which endpoint is called;
- run the ZK circuit to verify the proof, using the endpoint call's parameters as the public inputs, e.g. "user X deposits Y tokens";
- if the verification succeeds, the L1 transaction is accepted.

== L2 node

The L2 node will be ran on three powerful machines running NixOS, as mentioned before. The server code will be written in Rust, to assure performance and simplify interactions with Casper's L1. The database will be postgres, duplicated over the three machines.

== Web UI

TODO: determine the tooling.

== CLI

The CLI will be built in Rust and packaged with Nix, supporting all Linux distributions. This allows us to use the client interface derived from the L2 server's API (written in Rust) in the CLI, simplifying the implementation.

== Design decisions

=== Validium vs. rollup

We're attempting to create an L2 solution which can scale to 10'000 Tx/s. However, these transactions need to be indpendent, since dependent transactions require the latter transaction to be aware of the state resulting from the first transaction, which you'll not be able to query quickly enough (given restrictions such as the time it takes to sign a transaction and send messages around given the speed of light). Therefore, in order to reach 10k Tx/s you need at least 20k people using the L2. Therefore, 20k people's L2 account balances need to be stored within the validium L1 smart contract. This means the data associated with this contract will supercede Casper L1's data limits, leading to the requirement for our L2 solution to be a Validium.

=== Centralized L2

Decentralized L2s require many complex problems to be resolved. For example, everyone involved in the L2 must get paid, both the storers, provers etc. In addition, we must avoid any trust assumptions on individual players, making it difficult to provide reasonable storage options, and requires a complex solution, e.g. Starknet's Data Availability Committee. Each of these issues takes time to resolve, and doing all this within the proof of concept would likely lead to an infinite loop of design improvements and realizations of vulnerabilities.

Therefore, a centralized L2 ran by the Casper Association is a very attractive initial solution. This poses the question, what are the dangers of centralized L2s?
- Denial of service: The L2 node could block any user from using the system
- Loss of trust in L2: The L2 server could blacklist someone, thereby locking in their funds. This opens up blackmail attacks and the like.
- Loss of data: What if the L2 node loses the data? Then we can no longer confirm who owns what, and the L2 system dies a painful death.

Unfortunately there is nothing we can do about the L2 denying you service within a centralized L2 setting. If the L2 decides to blacklist your public key, you will not have access to its functionality. Of course we should keep in mind two key things here:
+ Withdrawing your current funds from the Validium should always be possible, even without permission from the L2.
+ The centralized L2 will be ran by the Casper Association, which has a significant incentive to aid and stimulate the Casper ecosystem to offer equal access to all.

As mentioned before, we will design the system in such a way that withdrawing all your validium funds is possible without L2 approval. This eliminates the second danger associated with centralized L2s ZKVs.

Finally, what if the L2 loses its data? The Casper Association has a very strong incentive to prevent this, since the entire project would die permanently if this failure shows up even once. Therefore, we will build the L2 service in such a way as to include the necessary redundancy, as mentioned above.

=== Privacy provided by L2

We don't really provide any increased privacy compared to L1 within this proof of concept. The reason for this is that providing any extra privacy would raise AML-related concerns we wish to stay away from.

=== The L2 node should get paid

Within our proof of concept, this issue is rather simple, given the L2 is centralized. In essence, all we need to do is make sure that the Casper ecosystem grows and benefits from the existence of the L2, and the Casper Association will receive funds to keep the system appropriately maintained. Also note that worst-case scenario, as long as the current Valadium state is known, any user can still withdraw their funds from the Validium.

= Low-level design <low-level-design>

In this section, we will describe in detail how each component works individually. Note that these components are strung together into the bigger project according to the diagrams shown in @uiux.

== L2 server

- What does an L2 Tx look like?
- How will the L2 be made aware that a deposit/withdrawal happened?
- Describe interactions the L2 server offers
- Describe how the data redundancy and load balancing (for the ZK proving) work
- In what format does the L2 API accept messages and send replies? CBOR? JSON?

== Smart contract

- What does the API look like?
- What are the constraints on the implementation?
- How to test this?

== ZKP

- Which ZKP do we use? Why?
- What exactly is proven by a ZKP?
- What are the public and private inputs of the ZKP?
- Issue: We have to make sure the same L2 Tx cannot be used twice
  - Add the Merkle root pre-ZKR Tx to the L2 Tx, and verify this in the ZKR? But then any deposit or withdrawal requires all L2 Tx in process to be recreated and resigned.

=== Comparison of ZK provers

- Risc0
- ValidaVM
- Noir
- Halo2
- OSL

== ZKR

- What exactly is proven by the ZKR?

== Web UI: List interactions

== CLI: List interactions

= Testing <testing>

== E2E testing

== Integration testing

== Attack testing

== Property testing

== Whatever else Syd can come up with

= Notes

- Once we go beyond the PoC, we want to consider allowing users to post ZKPs of L2 transactions as well, rather than only raw L2 transactions.



