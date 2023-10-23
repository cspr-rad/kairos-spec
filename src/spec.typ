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

In @overview (Product Overview) we specify the high-level interactions that the proof of concept will implement. @requirements determines requirements based on the specified interactions to end-to-end test. Next, we describe some UI/UX concerns in @uiux. Next, we provide an abstract architecture in @high-level-design (High-Level Design), followed by the Low-Level Design in @low-level-design and testing concerns in @testing.

= Product Overview<overview>

To have a common denominator on the scope of the proof of concept, this section describes the high-level mandatory-, optional-, and delimination features it has to fulfill.

== Mandatory Features

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

== Optional Features: Post-PoC features

=== Query storage

Anyone can query the transaction history based on certain filters, such as a specific party being involved and time constraints.

== Usage

The proof of concept can be used by any participants of the Casper network. It will allow any of them to transfer tokens and make payments with lower gas fees and significantly higher transaction throughput.

There will be two groups of users: tech-savvy and less tech-savvy. In order to accommodate both groups, we will offer three user interfaces: A web interface (website) for the less tech-savvy customer, and a CLI client and L2 API for developers. Thereby, we can serve customers directly while laso allowing new projects to build on top of our platform. Finally, this allows us to ensure that even customers in low-resource environments can participate, by moving the resource-heavy away from the web UI.

Our L2 server itself will be a set of dedicated, powerful machines, including a powerful CPU and GPU, in order to provide GPU accelleration for ZK proving (see Risc0). The machines will run NixOS and require a solid internet connection. The CLI client will run on any Linux distribution, whereas the web client will support any modern web-browser with JavaScript enabled.

= Requirements <requirements>

Based on the product overview given in the previous section, this section aims to describe testable, functional requirements the validium needs to fulfill.

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

=== Transfer money within the L2 system

- [tag:FRT00] Transfering an amount of `CSPR tokens`, where `users validium account balance >= CSPR tokens > 0` should be accounted correctly
- [tag:FRT01] Transfering an amount of `CSPR tokens`, where `CSPR tokens =< 0` should not be executed at all
- [tag:FRT02] Transfering an amount of `CSPR tokens`, where `CSPR tokens > users validium account` balance should not be possible
- [tag:FRT03] Transfering a valid amount to another user that does not have a registered validium account yet should be possible.
- [tag:FRT03] Transfering a valid amount to another user sbould only succeed if the user owning the funds has signed the transfer transaction

=== Query account balances

- [tag:FRA00] The user should be able to see its validium account balance immediately when it's queried (either through the CLI or web-UI)
- [tag:FRA01] Anyone should be able to see all validium account balances through the CLI, web-UI and API

=== Verification

- [tag:FRV00] Anyone should be able to query and verify proofs of the validiums state changes caused by deposit/withdraw/transfer interactions at any given time

=== Storage

- [tag:FRD00] Transaction data should be served read-only to anyone
- [tag:FRD01] Transaction data should be available at any given time
- [tag:FRD02] Transaction data should be written by known, verified entities only
- [tag:FRD03] Transaction data should be written immediately after the successful verification of correct deposit/withdraw/transfer interactions
- [tag:FRD04] Transaction data should not be written if the verification of the proof of the interactions fails

=== Post-PoC: Query all transfers given filters

- [tag:FRA02] The user should be able to see all the past transactions involving its validium account

Filters could be that one party is involved (i.e. "give me all data related to this institution") or time-bounded.

== Non-functional requirements

These are qualitative requirements, such as "it should be fast". Can be fulfilled with e.g. benchmarks.

- [tag:NRB01] The application should not leak any private or sensitive informations like private keys
- [tag:NRB01] The backend API needs to be designed in a way such that it's easy to swap out a web-UI implementation

= UI/UX <uiux>

Mockups we want:
- WebUI: Connect to wallet, see your L1 & Validium account balance(s), deposit/withdrawal, L2 transfer, sign L2 Tx

#figure(
  image("components.svg", width: 50%),
  caption: [
    Overview of the components
  ],
)

#figure(
  image("deposit.svg", width: 100%),
  caption: [
    Deposit sequence diagram
  ],
)

#figure(
  image("simple_transfer.svg", width: 100%),
  caption: [
    Singular transfer sequence diagram
  ],
)

#figure(
  image("transfer_sequence.svg", width: 100%),
  caption: [
    Sequence diagram for a set of transfers
  ],
)

= High-level design <high-level-design>

Any ZK validium can be described as a combination of 6 components. For this proof of concept, we made the following choices:
- Consensus layer = Casper's L1, which must be able to accept deposits and withdrawals and accept L2 state updates
- Contracts: Simple payments
- ZK prover: Risc0 generates proofs from the L2 simple payment transactions
- L2 nodes: A centralized, single L2 server, for simplicity reasons. This will connect all other components.
- Data availability: The L2 server allows an interface to query public inputs and their associated proofs as well as the validium's current state
- Rollup: Risc0 is used to combine proofs into one, compressed ZKR, posted on L1

From a services perspective, the system consists of four components:
- L1 smart contract: This allows users to deposit, withdraw and transfer tokens
- L2 server: This allows users to post L2 transactions, generates ZKPs and posts the results on Casper's L1, and allows for querying the validium's current state
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

== L2 server

The L2 server will be ran on three powerful machines running NixOS, as mentioned before. The server code will be written in Rust, to assure performance and simplify interactions with Casper's L1. The database will be postgres, duplicated over the three machines.

// @Mark: Do we want to build the L2 server in Haskell or in Rust?
// Pros:
// - Easier to test
// - Clients can be generated from APIs such as Servant, ensuring correctness of server/client interactions
// - Yesod framework can be used for Web UI
// 
// Cons:
// - Some data types have to be reimplemented from Rust, since Casper's L1 is in Rust
// - Rust is a bit faster
// - There might be some data type sharing between the Risc0, smart contract and L2 server code

== Web UI

// @Mark: What tooling do we want to use for the Web UI?
// Note: The integration with Casper's L1 wallet shouldn't be difficult. There is an SDK in Typescript, which compiles to Javascript, and hence the small number of interactions we require with the L1 wallet will be implementable in anything else that compiles to or uses Javascript, whether that be Elm, Yesod, Typescript, Purescript..
// Proposal: If the L2 server is implemented in Haskell, we could use Yesod. Otherwise our preferred choice would be Elm.

== CLI

The CLI will be built in Rust and packaged with Nix, supporting all Linux distributions. This allows us to use the client interface derived from the L2 server's API (written in Rust) in the CLI, simplifying the implementation.

== Design decisions

=== Validium vs. rollup

We're attempting to create an L2 solution which can scale to 10'000 transaction/s. However, these transactions need to be indpendent, since dependent transactions require the latter transaction to be aware of the state resulting from the first transaction, which you'll not be able to query quickly enough (given restrictions such as the time it takes to sign a transaction and send messages around given the speed of light). Therefore, in order to reach 10k transaction/s you need at least 20k people using the L2. Therefore, 20k people's L2 account balances need to be stored within the validium L1 smart contract. This means the data associated with this contract will supercede Casper L1's data limits, leading to the requirement for our L2 solution to be a Validium.

=== Centralized L2

Decentralized L2s require many complex problems to be resolved. For example, everyone involved in the L2 must get paid, both the storers, provers etc. In addition, we must avoid any trust assumptions on individual players, making it difficult to provide reasonable storage options, and requires a complex solution, e.g. Starknet's Data Availability Committee. Each of these issues takes time to resolve, and doing all this within the proof of concept would likely lead to an infinite loop of design improvements and realizations of vulnerabilities.

Therefore, a centralized L2 ran by the Casper Association is a very attractive initial solution. This poses the question, what are the dangers of centralized L2s?
- Denial of service: The L2 server could block any user from using the system
- Loss of trust in L2: The L2 server could blacklist someone, thereby locking in their funds. This opens up blackmail attacks and the like.
- Loss of data: What if the L2 server loses the data? Then we can no longer confirm who owns what, and the L2 system dies a painful death.

Unfortunately there is nothing we can do about the L2 denying you service within a centralized L2 setting. If the L2 decides to blacklist your public key, you will not have access to its functionality. Of course we should keep in mind two key things here:
+ Withdrawing your current funds from the Validium should always be possible, even without permission from the L2.
+ The centralized L2 will be ran by the Casper Association, which has a significant incentive to aid and stimulate the Casper ecosystem to offer equal access to all.

As mentioned before, we will design the system in such a way that withdrawing validium funds is possible without L2 approval. This eliminates the second danger associated with centralized L2s ZKVs, requiring exclusively that you have access to the current Validium state. Without such access, the L2 would be entirely dead, as no deposits or withdrawals can be made without it.

Finally, what if the L2 loses its data? The Casper Association has a very strong incentive to prevent this, since the entire project would die permanently if this occurs. Therefore, we will build the L2 service in such a way as to include the necessary redundancy, as mentioned above.

=== Privacy provided by L2

We don't really provide any increased privacy compared to L1 within this proof of concept. The reason for this is that providing any extra privacy would raise AML-related concerns we wish to stay away from.

=== The L2 server should get paid

Within our proof of concept, this issue is rather simple, given the L2 is centralized. In essence, all we need to do is make sure that the Casper ecosystem grows and benefits from the existence of the L2, and the Casper Association will receive funds to keep the system appropriately maintained. Also note that worst-case scenario, as long as the current Valadium state is known, any user can still withdraw their funds from the Validium.

= Low-level design <low-level-design>

In this section, we will describe in detail how each component works individually. Note that these components are strung together into the bigger project according to the diagrams shown in @uiux.

== L2 server

=== Ensuring L2 transaction uniqueness

We have to make sure the same L2 transaction cannot be used twice. One option is to add the Merkle root of the Validium's state at the time the L2 transaction is submitted, to the ZKP's public inputs, and have the ZKR code verify this. The problem with this approach is that any deposit or withdrawal on L1 would then require all in-progress L2 transactions to be recreated and resigned. We could have the smart contract store two Merkle roots though, the current one and the last one posted by L2 (i.e. the second one doesn't change based on deposits and withdrawals). That way, no L2 transactions must be resigned upon deposit or withdrawal, while we also guarantee uniqueness.

Note that this solution does require that the same L2 transaction cannot be posted twice within the same rollup. However, this is easy to avoid by requiring all L2 transactions rolled up into the same ZKR (for posting to L1) to be independent, i.e. to not clash in senders and receivers with any other L2 transactions. We want to set this requirement anyway in order to stimulate parallelization opportunities within the ZKP/ZKR generation.

=== Two phases of the server <phases>

After collecting L2 transactions, the L2 server must be allowed time to create a ZKR and post it to L1. During this "phase 2", no new L2 transactions can be accepted into the queue, given the L2 transaction posting uniqueness discussion above. Therefore, the L2 server will accept transactions for ten seconds, then refuse them for ten seconds so it has time to create a ZKR and post it to L1. Afterward new L2 transactions are accepted again. If an L2 transaction is posted during phase 2, a clear error message is returned to the API caller. Our web UI and CLI will be built to appropriately deal with this error, waiting for a few seconds before a retry.

Note that this second phase requires some amount of computation and therefore some time to get accomplished. Meanwhile, if a deposit or withdraw transaction gets pushed to L1, the ZKR computation must start over, since the old Merkle root is different. The generation of the individual ZKPs, on the other hand, does not depend on the old Merkle root, only on their sender and receiver's Validium balances.

=== L2 transactions

The contents of an L2 transaction are:
- Sender's address
- Receiver's address
- Token ID, i.e. currency
- Token amount
- Sender's signature
- Last merkle root published on L1 by L2, i.e. the current state of the Validium ignoring any deposits or withdrawals made since the last ZKV post

=== How will L2 become aware of deposits and withdrawals?

The casper-node allows for creating a web hook. Therefore, by running a casper-node on each L2 server, we can ensure the servers get notified as soon as a deposit or withdrawal is made on the L1 smart contract.

=== What does the L2 API look like?

- GET /accounts/:accountID returns a single user's L2 account balance
- GET /accounts returns the current Validium state, i.e. all L2 account balances
- POST /transfer takes in an L2 transaction in JSON format, and returns a TxID
- GET /transfer/:TxID shows the status of a given transaction: Cancelled, ZKP in progress, ZKR in progress, or "posted in L1 block with blockhash X"
- GET /deposit takes in a JSON request for an L1 deposit and calculates the new Merkle root as well as generating a ZKP for it
- GET /withdrawal takes in a JSON request for an L1 withdrawal and calculates the new Merkle root as well as generating a ZKP for it

Note that through the CLI, any user can decide to compute the ZKP necessary for depositing/withdrawing money locally, thereby relying less on the L2 server. This cuts down the dependency on the L2 server to nothing but requesting the current Merkle tree.

=== Data redundancy

We must accomplish an appropriate amount of redundance in the data storage, given that losing the Validium state would lead to a loss of al Validium funds. Therefore, we decided to commence the project with three servers, one master and two slaves. The data sharing between the three servers will be handled using Postgres duplication, which is built into Postgres, very mature tooling. The master server will be assigned the master role to Postgres, with the slaves copying all incoming data. Postgres' duplication feature also solves the problem of syncing up servers after one of them went down.

Naively, we might want to consider building a failsafe into the Validium smart contract in case the Validium's state gets lost. After all, such a situation would be disasterous. However, any failsafe which could be built, would create more risk and complexity than it would resolve. Therefore, we opt to focus on building data redundancy as mentioned above, including measures such having the three servers spread out geographically.

// In deploying the storage, we must
// - Deploy to three servers
// - Make sure that if one server goes down, another one is picked as master and can take over temporarily
// - If a server comes back up, it must get synced with the others automatically
// - Keep the three servers geographically spread out, i.e. located in three different countries.

=== Load balance for ZK proving

Within the PoC, the ZKPs themselves will be sufficiently quick to generate that there is litlte opportunity for speedup through parallelization. When exploring the ZKR, we should look into parallelization opportunities.

Note that we can limit the number of transactions we accept during a single loop of the system in order to provide a feasible PoC. After going into production, we can optimize the server(s)' performance to keep up with demand.

=== What happens when you post an L2 transaction?

- Check if the transaction is posted within the server's phase 1, see @phases. If not, return a clear error to the API caller.
- Create a TxID and return this to the API caller
- Post the transaction and TxID to the dB
- Verify the transaction. If this fails, put the transaction status to Cancelled.
  - Signature
  - TokenID and amount are legitimate, given the current Validium's state
  - The transaction is independent of the current queue of transactions, i.e. the sender and recipient aren't included yet
- Generate a ZKP
- Once the server reaches phase 2, generate the ZKR and post it to the L1 smart contract
- Put the status of all transactions included in this ZKR to Success once the L1 transaction is accepted

Notes:
- Anytime the L2 server posts something to its database, this information is sent to the backup servers.
- The web UI can create a web hook to be notified by a casper-node when the smart contract is updated through the Transfer endpoint, i.e. when the L2 transaction it posted might be included. At that point it can contact the L2 to verify the transaction's success.

== Smart contract

The smart contract stores the following data:
- Current Merkle root, representing the Validium's state
- The last Merkle root posted by the L2 (i.e. deposits). This is needed for the L2 rollup to work.
- Its own account balance, which amounts to the total sum of all the Validium account balances

The smart contract offers the following API and verifications:
- POST deposit: sender's public key, token ID, token amount, new Merkle root, ZKP verifying the Merkle root, sender's signature
  - Verify that this amount of tokens can be sent, and take it out of the sender's 1 account
  - Verify the ZKP given public inputs
  - Update the smart contract's state
- POST withdrawal: Receiver's public key, token ID, token amount, new Merkle root, ZKP verifying the merkle root
  - Move the appropriate amount of tokens to the receiver's L1 account
  - Verify the ZKP given public inputs
  - Update the smart contract's state
- POST ZKV: ZKV, new Merkle root
  - Verify ZKV
  - Update the smart contract's state

=== Smart contract initialization

Initiating the L1 smart contract requires putting money onto the Validium. The balance of the smart contract will then be equal to the initial deposit, and the Merkle roots (current and "current minus deposits/withdrawals") will be equal to the Merkle root for a Merkle tree with only one leaf, namely the single initial account.

== ZKP

=== What exactly do the ZKPs look like?

Transfer transaction:
- Public inputs: Unsigned L2 transaction
- Private inputs: L2 transaction signature
- Verify: Signature

Deposit transaction:
- Public inputs: Old Merkle root, new Merkle root, sender, token ID, token amount
- Private inputs: Info on the old Merkle tree in order to verify
- Verify: Merkle root update. Note that the signature must be checked by L1.

Withdrawal transaction:
- Public inputs: Old Merkle root, new Merkle root, receiver, token ID, token amount
- Private inputs: Info on the old Merkle tree in order to verify, signature
- Verify: Merkle root update & signature

=== How do Merkle tree updates work? <merkle-tree-update>

Transfer transactions don't have a Merkle tree update themselves. Rather, this duty is taken over by the ZKR. The main reason for this is that we want to avoid trasnfers from depending on the Merkle root, requiring each transfer in progress to be recreated and resigned anytime a deposit or withdrawal is posted on L1. On the other hand, deposit and withdrawal transaction do require the Merkle tree to be updated. Note that these transactions only change one of the leafs. Therefore, in order to verify whether the old Merkle root has been appropriately transformed into the new Merkle root, all we need is the leaves which the updated leaf interacts with.

#figure(
  grid(
    columns: 2,
    image("merkle-tree.svg", width: 80%),
    image("merkle-tree-updated.svg", width: 80%)
  ),
  caption: [
    How to update a single leaf of a Merkle tree
  ],
) <merkle-tree-update-figure>

Let's look at @merkle-tree-update-figure as an example of a single-leaf Merkle tree update. As we can see, the datum D2 is updated to D2'. As a result, H2, A1 and R each get updated. The deposit transaction itself will include by necessity D2, D2', R and R', in order to provide the smart contract with all the information necessary in order to execute the right processes. In addition, the smart contract must verify that changing D2 to D2' does indeed lead to the update of the Merkle tree from root R to root R'. Note now that in order to verify this claim, we don't require the entire Merkle tree. Rather, all we need are values H1 and A2 and the directionality (i.e. the fact that H1 is to the left of H2, whereas A2 is to the right of A1, in the Merkle tree). Given these parameters, we can now check that indeed for

$ "H2" = "hash"("D2"), "A1" = "hash"("H1", "H2") $
$ "H2'" = "hash"("D2'"), "A1'" = "hash"("H1", "H2'") $

it is true that
$ R = "hash"("A1", "A2"), "R'" = "hash"("A1'", "A2"). $

For a general balanced Merkle tree with $N$ leaves, this requires $log^2(N)$ hashes, each with their directionality, to be passed along to the Validium smart contract, to allow the verification.

=== Where does the ZK verification happen?

Within the casper-node, if the ZK verification code doesn't fit into a smart contract? If it does, then within the same smart contract, or a dedicated one?
// TODO: Deep-dive into Risc0: What does verification require? How much data and computation?
// - Can this be integrated into a smart contract?
// - If so, should we use a separation ZK verification smart contract, or include it in the Validium start contract?
// - If not, how can we integrate this with the Casper node?

=== Comparison of ZK provers

We decided to build the PoC using Risc0 as a ZK prover system, both for the individual ZKPs and for the rollup. The reason for this is a combination of Risc0's maturity in comparison to its competitors, and Risc0's clever combination of STARKs and SNARKs to quickly produce small proofs and verify them. In addition, Risc0 is one of few options which allows for GPU acceleration for the ZKR computation.

== ZKR

The ZK rollup verifies the following:
- The ZKPs don't clash, i.e. they all have separate senders and receivers
- All ZKPs are valid
- All L2 transactions include as a public input the last Merkle root posted on L1 by L2. This Merkle root itself is taken as a public input to the ZKR.
- The old Merkle root is correctly transformed into the new Merkle root through applying all the L2 transactions

Its public inputs include the old Merkle root and new Merkle root. The private inputs are the list of L2 transactions and their ZKPs, as well as the full old Merkle tree.

== Web UI: List interactions

// TODO: Deep-dive into the Casper wallet. Can we sign arbitrary JSON blobs? If not, how could we use the user's private key to sign our L2 Txs?

- Connect to Casper wallet
- Sign L2 Tx: This requires an "L2 wallet" of some type
- Query Validium balance
- Query Casper L1 balance
- Deposit on and withdraw from Validium: Create, sign & submit L1 transaction, check its status on casper-node
- Transfer within Validium: Query Validium state, create, sign & submit L2 transaction, check its status on L2 server

== CLI: List interactions

- Connect to Casper wallet
- Query Validium balance
- Query Casper L1 balance
- Deposit on and withdraw from Validium: Create, sign & submit L1 transaction, check its status on casper-node
- Transfer within Validium: Query Validium state, create, sign & submit L2 transaction, check its status on L2 server
- Query last N ZKPs posted to L1
- Verify a ZKP

= Testing <testing>

== E2E testing

== Integration testing

== Testing the smart contract

== Attack testing

== Property testing

- We don't need Merkle tree rebalancing. If this fails, research and implement Merkle tree rebalancing, generate ZKPs for it and include this as an endpoint to the Validium smart contract.

== Whatever else Syd can come up with

= Notes

- Once we go beyond the PoC, we want to consider allowing users to post ZKPs of L2 transactions as well, rather than only raw L2 transactions.
- Merkle roots aren't unique. Therefore, we could imagine the Validium state getting back into a state it has been in before, thereby allowing old L2 transactions to be reused. How do we avoid this issue? One solution would be to add an extra leaf to the Merkle tree, and update this leaf with each ZKR, e.g. $"L'" = "hash"(L)$



