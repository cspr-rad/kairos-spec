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

The Casper Asscoiation has adopted the aim to establish ACTUS contracts on top of the Casper blockchain, unlocking the potential for transparency and insights into TradFi without giving up scalability and privacy. As an intermediate step towards building a Layer2 for ACTUS contracts, the goal of this project is to explore the L2-space through a smaller scope. The reason for building this proof of concept is to focus the engineering effort and move forward productively, both in learning about Casper's L1 and how to integrate with it, building an L2, and generating and verifying ZK rollups. Furthermore, the size and complexity of this project not only provides an opportunity to get a better understanding of the challenges associated with bringing zero-knowledge into production but also allows the team to collaborate and grow together by developing a production-grade solution.

The goal of the proof of concept is to build a zero knowledge validium for payment transfers on its L2. Here, validium refers to the fact that the L2 data, such as account balances, are stored on L2 rather than L1, enabling both a higher transaction throughput and reduced gas fees on Casper. This is a great first step in the direction of building an ACTUS ZK-based L2 on Casper. Note that this proof of concept also forms the first step towards very cheap, frictionless systems for NFT minting and transfers, to aid Casper in becoming _the_ blockchain to push the digital art industry forward.

The project itself contains very few basic interactions. Any user will be able to deposit to and withdraw from an L1 contract controlled by the ZK validium, and use the L2 to transfer tokens to others who have done the same. In the remainder of this document, we will detail the requirements on such a system and how we plan to implement and test it.

In @overview (Product Overview) we specify the high-level interactions that the proof of concept will implement. @requirements determines requirements based on the specified interactions to end-to-end test. Next, we provide an abstract architecture in @high-level-design (High-Level Design), followed by low-level design considerations in @considerations and their conclusions in @low-level-design. We conclude with testing concerns in @testing.

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

Due to the nature of validiums, transaction data will be stored off-chain. To ensure interactions can be proven and verified at any given time by anyone, data needs to be available read-only publicly through an API. To reduce the complexity of the project, the data will be stored by a centralized server that can be trusted. Writing and mutating data should only be possible by selected trusted instances/machines. The storage must be persistent and reliable, i.e. there must be redundancies built-in to avoid data loss.

=== Verification

Each transfer must be verified by L1. In addition, at any given time anyone should be able to verify deposits, withdrawals, or transactions. This should be possible through a web UI, the CLI, or application programming interface (API), i.e. a machine-readable way.

== Optional Features: Post-PoC features

=== Query storage

Anyone can query the transaction history based on certain filters, such as a specific party being involved and time constraints. This includes the public information associated with each transaction on both L1 and L2, as well as the associated ZKPs.

== Usage

The proof of concept can be used by any participants of the Casper network. It will allow any of them to transfer tokens with lower gas fees and significantly higher transaction throughput.

There will be two groups of users: tech-savvy and less tech-savvy. In order to accommodate both groups, we will offer three user interfaces: A web interface (website) for the less tech-savvy customer, and a CLI client and a L2 API for developers. Thereby, we can serve customers directly while also allowing new projects to build on top of our platform. Even customers in low-resource environments can participate, as we will move the resource-heavy away from the web UI, while allowing developers to generate ZKPs on the client-side by using our L2 API.

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
- [tag:FRW04] Withdrawing a valid amount from the users validium account should only succeed if the user has signed the withdraw transaction
- [tag:FRW05] Withdrawing a valid amount from another users validium account should not be possible

=== Transfer money within the L2 system

- [tag:FRT00] Transfering an amount of `CSPR tokens`, where `users validium account balance >= CSPR tokens > 0` should be accounted correctly
- [tag:FRT01] Transfering an amount of `CSPR tokens`, where `CSPR tokens =< 0` should not be executed at all
- [tag:FRT02] Transfering an amount of `CSPR tokens`, where `CSPR tokens > users validium account` balance should not be possible
- [tag:FRT03] Transfering a valid amount to another user that does not have a registered validium account yet should be possible.
- [tag:FRT04] Transfering a valid amount to another user sbould only succeed if the user owning the funds has signed the transfer transaction
- [tag:FRT05] When a transfer request is submitted, this request cannot be used to make the transfer happen twice

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
- [tag:FRA03] Transactions should be filterable by time
- [tag:FRA04] Transactions should be filterable by sender
- [tag:FRA05] Transactions should be filterable by recipient
- [tag:FRA06] Transactions should be filterable by amount
- [tag:FRA07] Transactions should be filterable by any combination of the previously mentioned criterias

== Non-functional requirements

These are qualitative requirements, such as "it should be fast" and could e.g. be benchmarked.

- [tag:NRB00] The application should not leak any private nor sensitive informations like private keys
- [tag:NRB01] The backend API needs to be designed in a way such that it's easy to swap out a web-UI implementation
- [tag:NRB02] The web-UI should load fast
- [tag:NRB03] The web-UI should respond on user interactions fast
- [tag:NRB04] The web-UI should be designed in a user friendly way
- [tag:NRB05] The web-UI should achieve a very high score running Google lighthouse against it

= High-level design <high-level-design>

TODO: Add components diagram here.

Any ZK validium can be described as a combination of 6 components. For this proof of concept, we made the following choices:
- Consensus layer: Casper's L1, which must be able to accept deposits and withdrawals and accept L2 state updates
- Contracts: Simple payments
- ZK prover: Risc0 generates proofs from the L2 simple payment transactions
- Rollup: Risc0 also combines proofs into a compressed ZKR, posted on L1
- L2 nodes: A centralized L2 server connects all other components
- Data availability: The L2 server offers an interface to query public inputs and their associated proofs as well as the validium's current state

From a services perspective, the system consists of four components:
- L1 smart contract: This allows users to deposit, withdraw and transfer tokens
- L2 server: This allows users to post L2 transactions, generates ZKPs and posts the results on Casper's L1, and allows for querying the validium's current state. This is also where the ZKPs and ZKRs are generated.
- Web UI: Connect to your wallet, deposit, withdraw and transfer tokens, and query the validium's state and your own balance
- CLI: Do everything the Web UI offers, and query and verify the Validium proofs

== L2 server

The L2 server will be ran on three powerful machines running NixOS, as mentioned before. The server code will be written in Rust, to assure performance and simplify interactions with Casper's L1. The database will be postgres, replicated over the three machines.

// @Mark: Do we want to build the L2 server in Haskell or in Rust?
// Pros:
// - Easier to test, and better test tooling
// - Clients can be generated from APIs such as Servant, ensuring correctness of server/client interactions
// - Yesod framework can be used for Web UI
// 
// Cons:
// - Some data types have to be reimplemented from Rust, since Casper's L1 is in Rust
// - Rust is a bit faster
// - There might be some data type sharing between the Risc0, smart contract and L2 server code

== Smart contract

The L1 smart contract will be implemented in WASM. Each update of the contract will be accompanied by metadata to confirm the update was made legitimately, such as a ZKP. When a contract endpoint is called, the contract
+ computes the proof's "public inputs", given the contract endpoint call;
+ verifies the update was done correctly, given the public inputs, contract endpoint and metadata, e.g. by running the ZK verifier;
+ if the verification succeeds, the L1 transaction is accepted.

== Prover

There will be a service, running on the same servers as the L2 server, which computes ZK proofs and ZK rollups. This service will be implemented in Rust, using Risc0 to generate ZKPs.

== Web UI

// @Mark: What tooling do we want to use for the Web UI?
// Note: The integration with Casper's L1 wallet shouldn't be difficult. There is an SDK in Typescript, which compiles to Javascript, and hence the small number of interactions we require with the L1 wallet will be implementable in anything else that compiles to or uses Javascript, whether that be Elm, Yesod, Typescript, Purescript..
// Proposal: If the L2 server is implemented in Haskell, we could use Yesod. Otherwise our preferred choice would be Elm.

== CLI

// The CLI will be built using the same programming language as the L2 server, and packaged with Nix, supporting all Linux distributions. This allows us to use the client interface derived from the L2 server's API in the CLI, simplifying the implementation.

== Design decisions

=== Validium vs. Rollup

As mentioned in the introduction, a ZK rollup is an L2 solution where the state is stored on the L1, while state updates are performed by the L2. A ZK proof that such a state update was performed correctly, is then posted along with the new state on L1. A ZK Validium is similar to a ZK rollup except in that the state isn't posted to the L1, but rather some sort of hash of the state. This requires significantly less data resources on L1, and therefore allows further scaling.

We are attempting to create an L2 solution which can scale to 10'000 transaction per second. However, these transactions need to be independent, since dependent transactions require the latter transaction to be aware of the state resulting from the first transaction, which you'll not be able to query quickly enough (given restrictions such as the time it takes to sign a transaction and send messages around given the speed of light). Therefore, in order to reach 10,00 transaction per second you need at least 20,000 people using the L2. This requires 20,000 people's L2 account balances to be stored within the L1 smart contract. However, this much data supercedes Casper L1's data limits. In conclusion, any L2 ZK solution on top of Casper must be a Validium.

=== Centralized L2

Decentralized L2s require many complex problems to be resolved. For example, everyone involved in the L2 must get paid, including the storers and provers. In addition, we must avoid any trust assumptions on individual players, making it difficult to provide reasonable storage options. Instead, this requires a complex solution such as Starknet's Data Availability Committee. Each of these issues takes time to resolve, and doing all this within the proof of concept is likely to prevent the project from ever launching into production. Therefore, a centralized L2 ran by the Casper Association is an attractive initial solution. This poses the question, what are the dangers of centralized L2s?
- Denial of service: The L2 server could block any user from using the system
- Loss of trust in L2: The L2 server could blacklist someone, thereby locking in their funds. This opens up attacks based on blackmail.
- Loss of data: What if the L2 server loses the data? Then we can no longer confirm who owns what, and the L2 system dies a painful death.

Unfortunately there is nothing we can do about the L2 denying you service within a centralized L2 setting. If the L2 decides to blacklist your public key, you will not have access to its functionality. Of course we should keep in mind two key things here:
+ Withdrawing your current funds from the Validium should always be possible, even without permission from the L2.
+ The centralized L2 will be ran by the Casper Association, which has a significant incentive to aid and stimulate the Casper ecosystem to offer equal access to all.

As mentioned before, we will design the system in such a way that withdrawing validium funds is possible without L2 approval. This eliminates the second danger associated with centralized L2s ZKVs, requiring exclusively that you have access to the current Validium state. Without such access, the L2 would be entirely dead, as no deposits or withdrawals can be made without it.

Finally, what if the L2 loses its data? The Casper Association has a very strong incentive to prevent this, since the entire project would die permanently if this occurs. Therefore, we will build the L2 service in such a way as to include the necessary redundancy, as mentioned above.

=== Privacy provided by L2

We decided not to provide any increased privacy compared to Casper's L1 within this proof of concept. The reason for this is that providing any extra privacy would raise AML-related concerns we wish to stay away from, as seen in the famous TornadoCash example.

=== The L2 server should get paid

Within our proof of concept this issue is rather simple, given the L2 is centralized. All we need to ensure is that the Casper ecosystem grows and benefits from the existence of the L2, and the Casper Association will receive funds to appropriately maintain and extend the L2. Also note that worst-case scenario, as long as the current Valadium state is known, any user can still withdraw their funds from the Validium.

= Design considerations <considerations>

In this section, we will describe in detail how each component works individually. Note that these components are strung together into the bigger project according to the diagrams shown in @high-level-design.

== L2 server

=== Sequential throughput

In this section, we want to make a quick note about a fundamental restriction of L2 scaling solutions. Imagine you and I both want to submit a swap on a DEX, and you come in first. My transaction thus dependents on the state that results from your swap. There are now two options:
+ I am aware of your output state. In this case, you have created, signed and submitted your transaction to the L2 server. I then pull your output state from the L2 server, construct, sign and submit my transaction. Given limitations such as how long it takes to sign a transaction and to send data back and forth to the server, this setup leads to a maximal sequential throughput #footnote[Sequential throughput is defined by the number of transactions which can be posted to the L2 where each transaction depends on the output of the former.] of around 1 Tx/s.
+ I am not aware of your output state. In this case, I have to construct a L2 transaction and sign it without being fully aware of its effects yet. In the example of the DEX swaps, I will sign a transaction which does not fully determine how many tokens I will receive back from the DEX, thereby allowing for sandwich attacks and the like. Finally, not mentioning the full state a given L2 transaction depends on in this transaction, leads to the problem of L2 transaction uniqueness: How can you assure that the DEX swap you just signed, won't be executed twice by the L2 server?

Our solution is to keep all L2 transactions rolled up into the same L1 transaction independent of one another, to avoid such complications. In making this decision, we restrict the sequential throughput of your system.

=== Ensuring L2 transaction uniqueness <uniqueness>

We must ensure that each L2 transaction which is posted to the L2 server, can only be used on the L1 once. This is can be accomplished in many ways, which generally fall into two categories:
+ Add something to the L2 transaction about the state of the world;
+ Add something to the L2 transaction about the state of the Validium.

The former option is difficut to accomplish, as there are few real-world concepts which translate into the blockchain world easily. For example, naively speaking, time would be a great option: What if we add a timestamp to each L2 transaction? There are two problems with a suggestion like this:
- Time is a very complex concept in the blockchain world. Which `currentTime` should the timestamp be compared to by a casper-node? There is no well-defined time at which a block is added to the blockchain, as each node does so at a different time.
- We must ensure that the bounds on the timestamp are loose enough that no transactions meant to go into a given ZKR are refused, while never allowing a transaction which went into the last ZKR to be accepted into a new one. This requirement of having no mistakes on either end, is so stringent that timestamps don't offer enough information.

The alternative is to add a piece of information X about the Validium's state to each L2 transaction. The ZKR can then include that piece of information as a public input, and check that all L2 transactions have that same public input. However, we must make sure that X is unique, meaning that even if the Validium reverts back to an old state, no old L2 transactions can be reused against the will of the person who signed them. Therefore, we decided X will be a counter, initialized at 0 and increasing by 1 every time a ZKR is posted to the L1. As such, the ZKR and Validium smart contract can verify perfectly whether a given L2 transaction fits into its rollup, while also providing a simple and clear user interface.

=== Two phases of the server <phases>

The L2 server accumulates a queue of L2 transactions which can be posted into the same ZKR. Based upon a number of limits #footnote[Two examples of such limits would be the number of transactions posted into one ZKR, and the time window which is compiled into one ZKR. The latter limit is necessary in order to allow a sensible sequential throughput as well.] the server will start computing a ZKR based on its current queue. Any new transactions must now set their Validium counter to one higher than before, in order to fit into the next ZKR rather than the current one. This will be communicated by the L2 server through a clear error.

=== How will L2 become aware of deposits and withdrawals?

The casper-node allows for creating a web hook. Therefore, by running a casper-node on each L2 server, we can ensure the servers get notified as soon as a deposit or withdrawal is made on the L1 smart contract.

=== Data redundancy

Because losing the Validium state would lead to a loss of all the funds held by the Validium, there needs to be an appropriate amount of redundancy of the stored data. To meet this requirement, we decided rely on PostgreSQL's streaming replication feature (physical replication). The streaming replication feature comes with two crucial benefits we can make use of:
- Fail-over: Meaning that when the primary server fails, one of the replicating standby servers can take over the role of the primary
- Read-only load balancing: Read-only queries can be distributed among several servers

By configuring the streaming replication to be synchronous, we can additionally achieve reliable freshness of the data across all servers. Moreover, it makes the cluster more resilient if the primary server fails after updating. In an asynchronous setting, data could be written to the primary server, which could afterwards fail before sending the update to the standby server, leading to loss of data. In a synchronous setting, the update to the primary server would fail and require a retry until the update gets replicated across all instances.

The number of standby servers can be arbitrarily increased or decreased. For the PoC we decided to start with one primary server and two replicating standby servers.

Naively, we might want to consider building a failsafe into the Validium smart contract in case the Validium's state gets lost. After all, such a situation would be disasterous. However, building a failsafe would itself create risk and complexity. Therefore, we opt to focus on building data redundancy as mentioned above, including measures such having the three servers spread out geographically.

// In deploying the storage, we must
// - Deploy to three servers
// - Make sure that if one server goes down, another one is picked as master and can take over temporarily
// - If a server comes back up, it must get synced with the others automatically
// - Keep the three servers geographically spread out, i.e. located in three different countries.

=== Load balance for ZK proving

Within the PoC, the ZKPs themselves will be sufficiently quick to generate that there is little opportunity for speedup through parallelization. When exploring the ZKR, we should look into parallelization opportunities.

Note that we can limit the number of transactions we accept during a single loop of the system in order to provide a feasible PoC. After going into production, we can optimize the server(s)' performance to keep up with demand.

=== What happens when you post an L2 transaction?

- Check if the transaction is posted with the correct Validium counter, see @phases. If not, return a clear error to the API caller.
- Create a TxID and return this to the API caller
- Write the transaction and TxID to the database
- Verify the transaction. If this fails, put the transaction status to Cancelled.
  - Signature
  - TokenID and amount are legitimate, given the current Validium's state
  - The transaction is independent of the current queue of transactions, i.e. the sender and recipient aren't included yet
- Generate a ZKP and write it to the database
- During the server's phase 2, generate the ZKR and post it to the L1 smart contract
- Put the status of all transactions included in this ZKR to Success once the L1 transaction is accepted

Notes:
- Anytime the L2 server posts something to its database, this information is sent to the backup servers.
- The web UI can create a web hook to be notified by a casper-node when the smart contract is updated through the Transfer endpoint, i.e. when the L2 transaction it posted might be included. At that point it can contact the L2 to verify the transaction's success.

== Smart contract

Each smart contract endpoint will require the new Merkle root and some form of proof that this Merkle root was correctly computed. After verifying this proof, the smart contract's state will be updated and the necessary actions executed on L1. For more details on the smart contract's state and endpoints, see @low-level-design.

== ZKP

=== How do Merkle tree updates work? <merkle-tree-update>

Transfer transactions don't have a Merkle tree update themselves. Rather, this duty is taken on by the ZKR. The main reason for this is that we want to avoid transfers from depending on the Merkle root, requiring each transfer in progress to be recreated and resigned anytime a deposit or withdrawal is posted on L1. On the other hand, deposit and withdrawal transaction do require the Merkle tree to be updated. Note that these transactions only change one of the leafs. Therefore, in order to verify whether the old Merkle root has been appropriately transformed into the new Merkle root, all we need is the leaves which the updated leaf interacts with.

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

Let us look at @merkle-tree-update-figure as an example of a single-leaf Merkle tree update. As we can see, the datum D2 is updated to D2'. As a result, H2, A1 and R each get updated. The deposit transaction itself will include by necessity D2, D2', R and R', in order to provide the smart contract with all the information necessary in order to execute the right processes. In addition, the smart contract must verify that changing D2 to D2' does indeed lead to the update of the Merkle tree from root R to root R'. Note now that in order to verify this claim, we don't require the entire Merkle tree. Rather, all we need are values H1 and A2 and the directionality (i.e. the fact that H1 is to the left of H2, whereas A2 is to the right of A1, in the Merkle tree). Given these parameters, we can now check that indeed for

$ "H2" = "hash"("D2"), "A1" = "hash"("H1", "H2") $
$ "H2'" = "hash"("D2'"), "A1'" = "hash"("H1", "H2'") $

it is true that
$ R = "hash"("A1", "A2"), "R'" = "hash"("A1'", "A2"). $

For a general balanced Merkle tree with $N$ leaves, this requires $log^2(N)$ hashes, each with their directionality, to be passed along to the Validium smart contract, to allow the verification.

Note: This should be implemented and tested as well for cases where a leaf must be added/removed, rather than updated.

=== Where does the ZK verification happen?

Within the casper-node, if the ZK verification code doesn't fit into a smart contract? If it does, then within the same smart contract, or a dedicated one?
// TODO: Deep-dive into Risc0: What does verification require? How much data and computation?
// - Can this be integrated into a smart contract?
// - If so, should we use a separation ZK verification smart contract, or include it in the Validium start contract?
// - If not, how can we integrate this with the Casper node?

=== Comparison of ZK provers

We decided to build the PoC using Risc0 as a ZK prover system, both for the individual ZKPs and for the rollup. The reason for this is a combination of Risc0's maturity in comparison to its competitors, and Risc0's clever combination of STARKs and SNARKs to quickly produce small proofs and verify them. In addition, Risc0 is one of few options which allow for GPU acceleration for the ZKR computation.

= Low-level design <low-level-design>

== L2 server

=== L2 transactions

The content of an L2 transaction is:
- Sender's address
- Receiver's address
- Token ID, i.e. currency
- Token amount
- Sender's signature
- Validium's counter, as discussed in @uniqueness

=== What does the L2 API look like?

- GET /counter returns the Validium counter which new L2 transactions should use in order to be accepted by the server
- GET /accounts/:accountID returns a single user's L2 account balance
- GET /accounts returns the current Validium state, i.e. all L2 account balances
- POST /transfer takes in an L2 transaction in JSON format, and returns a TxID
- GET /transfer/:TxID shows the status of a given transaction: Cancelled, ZKP in progress, ZKR in progress, or "posted in L1 block with blockhash X"
- GET /deposit takes in a JSON request for an L1 deposit and calculates the new Merkle root as well as generating a ZKP for it
- GET /withdraw takes in a JSON request for an L1 withdrawal and calculates the new Merkle root as well as generating a ZKP for it

Note that through the CLI, any user can decide to compute the ZKP necessary for depositing/withdrawing money locally, thereby relying less on the L2 server. This cuts down the dependency on the L2 server to nothing but requesting the current Merkle tree. However, this does require the L2 server to accept ZKPs directly, rather than only L2 transactions, which is a post-PoC feature.

#figure(
  image("transfer_sequence_diagram_client_submit.svg", width: 100%),
  caption: [
    Transfer: User submits a transaction to L2.
  ],
)

#figure(
  image("transfer_sequence_diagram_l2_prove_deploy.svg", width: 100%),
  caption: [
    Transfer: Proving and submitting the proof.
  ],
)

#figure(
  image("transfer_sequence_diagram_deploy_execution.svg", width: 100%),
  caption: [
    Transfer: Execution of the Deploy on L1.
  ],
)

#figure(
  image("transfer_sequence_diagram_notify_l2.svg", width: 100%),
  caption: [
    Transfer: Notifying the L2 after succcessfull on-chain execution.
  ],
)

== Smart contract

=== Smart contract data

The smart contract stores the following data:
- Current Merkle root, representing the Validium's state;
- The Validium counter, see @uniqueness
- Its own account balance, which amounts to the total sum of all the Validium account balances.

=== Smart contract API

The smart contract offers the following API, with each endpoint verifying and acting as described:
- POST deposit: sender's public key, token ID, token amount, new Merkle root, metadata verifying the Merkle root, sender's signature
  - Verify that this amount of tokens can be sent, and move it from the sender's L1 account to the Validium smart contract
  - Verify the sender's signature
  - Verify the new Merkle root given public inputs and metadata
  - Update the smart contract's state
- POST withdrawal: Receiver's public key, token ID, token amount, new Merkle root, metadata verifying the merkle root, receiver's signature
  - Move the appropriate amount of tokens from the Validium smart contract to the receiver's L1 account
  - Verify the receiver's signature
  - Verify the new Merkle root given public inputs and metadata
  - Update the smart contract's state
- POST ZKV: ZKV, new Merkle root
  - Verify ZKV
  - Update the smart contract's state

=== Smart contract initialization

Initiating the L1 smart contract requires putting money onto the Validium. The balance of the smart contract will then be equal to the initial deposit, and the Merkle roots (current and "current minus deposits/withdrawals") will be equal to the Merkle root for a Merkle tree with only one leaf, namely the single initial account.

== Prover

The zero knowledge proofs for transfer transaction consist of the following:
- Public input: Unsigned L2 transaction
- Private input: L2 transaction signature
- Verify: Signature

The ZK rollup verifies the following:
- The ZKPs don't clash, i.e. they all have separate senders and receivers
- All ZKPs are valid
- All L2 transactions include as a public input the last Merkle root posted on L1 by L2. This Merkle root itself is taken as a public input to the ZKR.
- The old Merkle root is correctly transformed into the new Merkle root through applying all the L2 transactions

Its public inputs are the old and new Merkle root. The private inputs are the list of L2 transactions and their ZKPs, as well as the full old Merkle tree.

== Web UI

// TODO: Deep-dive into the Casper wallet. Can we sign arbitrary JSON blobs? If not, how could we use the user's private key to sign our L2 Txs?

The Web UI offers the following interactions:
- Connect to Casper wallet
- Sign L2 Tx: This requires an "L2 wallet" of some type
- Query Validium balance
- Query Casper L1 balance
- Deposit on and withdraw from Validium: Create, sign & submit L1 transaction, check its status on casper-node
- Transfer within Validium: Query Validium state, create, sign & submit L2 transaction, check its status on L2 server

== CLI

The CLI offers the following interactions:
- All Web UI interactions
- Query last N ZKPs posted to L1
- Verify a ZKP

= Testing <testing>

== E2E testing

== Integration testing

== Testing the smart contract

== Attack testing

== Property testing

- Test our assumption that we don't need Merkle tree rebalancing. If this fails, research and implement Merkle tree rebalancing, generate ZKPs for it and include this as an endpoint to the Validium smart contract.

== Whatever else Syd can come up with

= Notes

- Post-PoC, we want to allow users to post ZKPs of L2 transactions as well, rather than only raw L2 transactions.



