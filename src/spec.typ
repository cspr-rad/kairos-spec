#let title = [
  Kairos: Zero-knowledge Casper Transaction scaling
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

// @harry

The Casper blockchain's ecosystem yearns for a scaling solution to achieve a higher transaction throughput and continue to stay competitive. As a first step towards providing a trustless scaling solution, the goal of the initial version 0.1 of the Kairos project is to build a zero-knowledge (ZK) _validium_ for payment transactions in a second layer (L2). This system will both enable a higher transaction throughput and lower gas fees. Here, _validium_ refers to a rollup where the data, such as account balances, are stored on L2 rather than on the Casper blockchain directly (L1).

Additionally, Kairos V0.1 serves two other major purposes:

- It is the first step towards a cheap and frictionless NFT (non-fungible token) minting and transfer system aiding Casper to become _the_ blockchain to push the digital art industry forward.

- The concise size and complexity of its scope allows us to explore challenges and the problem space of building an L2 solution that leverages zero-knowledge technology and integrates with Casper's L1. Furthermore, it allows the team to collaborate and grow together by building a production-grade system.

Kairos V0.1 will support very few simple interactions and features. Users will be able to deposit and withdraw funds by interacting with an L1 smart contract controlled by Kairos. Transfers of funds to other participants will be serviced by the L2 and verified and stored by the L1. In the remainder of this document, we will detail the requirements of such a system.

In @overview (Product Overview) we describe the high-level features that Kairos V0.1 will support. @requirements specifies the requirements based on the described interactions and features. Next, in @architecture (Architecture) we propose an architecture of this initial version, together with the components interfaces and their interactions. We conclude the document with threat models and a glossary, which clarifies the terminology used throughout this document. Note that this specification comes with a number of blogposts detailing some of the design considerations in more detail, as listed in the bibliography.

= Product Overview<overview>

To have a common denominator on the scope of Kairos V0.1, this section describes the high-level features it has to provide.

== Features

=== Deposit money into L2 system

Users should be able to deposit CSPR tokens from the Casper chain to their Kairos account at any given time through a command line interface (CLI).

=== Withdraw money from L2 system

Users should be able to withdraw CSPR tokens from their Kairos account to the Casper chain at any given time through a CLI. This interaction should not require the approval of the operator (#link("https://ethereum.org/en/developers/docs/scaling/validium/#deposits-and-withdrawals")[see Ethereum's validium]).

=== Transfer money within the L2 system

Users should be able to transfer CSPR tokens from their Kairos account to another user's Kairos account at any given time through a CLI.

=== Query account balances

Anyone should be able to query the Kairos account balances of available CSPR tokens at any given time through a CLI. In particular, users can also query their personal account balance.

=== Verification

Anyone should be able to verify deposits, withdrawals, or transactions either through a CLI or application programming interface (API), i.e. a machine-readable way.

== Product Application

=== Target Audience

The target audience comprises users familiar with blockchain technology and applications built on top of the Casper blockchain.

=== Operating Environment

The product's backend will be deployed on modern powerfull machines equipped with a powerful graphics processing unit (GPU) and a large amount of working memory as well as persistent disk space. The machines will have continuous access to the Internet.

The CLI will be deployed on modern, potentially less powerfull hardware.

= Requirements <requirements>

Based on the product overview given in the previous section, this section aims to describe testable, functional requirements the system needs to meet.

== Functional requirements

=== Deposit money into L2 system

- *[tag:FRD00]* Depositing an amount of `CSPR tokens`, where `CSPR tokens >= min. amount` should be accounted correctly
- *[tag:FRD01]* Depositing an amount of `CSPR tokens`, where `CSPR tokens < min. amount` should not be executed at all
- *[tag:FRD02]* A user depositing any valid amount to its `account` should only succeed if the user has signed the deposit transaction
- *[tag:FRD03]* A user depositing any valid amount with a proper signature to another users account should fail
- *[tag:FRD04]* When a user submits a deposit request, the request cannot be used more than one time without the users approval

=== Withdraw money from L2 system

- *[tag:FRW00]* Withdrawing an amount of `CSPR tokens`, where `users account balance >= CSPR tokens > min. amount` should be accounted correctly
- *[tag:FRW01]* Withdrawing an amount of `CSPR tokens`, where `CSPR tokens < min. amount` should not be executed at all
- *[tag:FRW02]* Withdrawing an amount of `CSPR tokens`, where `CSPR tokens > users account balance` should not be possible
- *[tag:FRW03]* Withdrawing a valid amount from the users account should be possible without the intermediary operator of the system
- *[tag:FRW04]* Withdrawing a valid amount from the users account should only succeed if the user has signed the withdraw transaction
- *[tag:FRW05]* Withdrawing a valid amount from another users account should not be possible
- *[tag:FRW06]* When a user submits a withdraw request, the request cannot be used more than one time without the users approval

=== Transfer money within the L2 system

- *[tag:FRT00]* Transfering an amount of `CSPR tokens`, where `users account balance >= CSPR tokens > min. amount` should be accounted correctly
- *[tag:FRT01]* Transfering an amount of `CSPR tokens`, where `CSPR tokens < min. amount` should not be executed at all
- *[tag:FRT02]* Transfering an amount of `CSPR tokens`, where `CSPR tokens > users account` balance should not be possible
- *[tag:FRT03]* Transfering a valid amount to another user that does not have a registered account yet should be possible.
- *[tag:FRT04]* Transfering a valid amount to another user sbould only succeed if the user owning the funds has signed the transfer transaction
- *[tag:FRT05]* When a user submits a transfer request, the request cannot be used more than one time without the users approval

=== Query account balances

- *[tag:FRA00]* A user should be able to see its account balance immediately when it's queried through the CLI
- *[tag:FRA01]* Anyone should be able to see all account balances when querying the CLI or API

=== Verification

- *[tag:FRV00]* Anyone should be able to query and verify proofs of the system's state changes caused by deposit/withdraw/transfer interactions at any given time

=== Storage

- *[tag:FRD00]* Transaction data should be served read-only to anyone
- *[tag:FRD01]* Transaction data should be available at any given time
- *[tag:FRD02]* Transaction data should be written by known, verified entities only
- *[tag:FRD03]* Transaction data should be written immediately after the successful verification of correct deposit/withdraw/transfer interactions
- *[tag:FRD04]* Transaction data should not be written if the verification of the proof of the interactions fails
- *[tag:FRD05]* Transaction data should be stored redundantly

== Non-functional requirements

These are qualitative requirements, such as "it should be fast" and could be benchmarked.

- *[tag:NRB00]* The application should not leak any private nor sensitive informations like private keys
- *[tag:NRB01]* The backend API needs to be designed in a way such that it's easy to swap out a client implementation
- *[tag:NRB02]* The CLI should load fast
- *[tag:NRB03]* The CLI should respond on user interactions fast
- *[tag:NRB04]* The CLI should be designed in a user friendly way

= Architecture <architecture>

Kairos's architecture is a typical client-server architecture, where the server (backend) has access to a blockchain network. The client is a typical CLI application. The backend consists of 6 components, whose roles are described in more detail in @architecture-components. @components-diagram-figure displays the interfaces and interactions between the components of the system.

#figure(
  image("components_diagram.svg", width: 100%),
  caption: [
    Components diagram
  ],
) <components-diagram-figure>

== Architecture Components <architecture-components>
=== Kairos CLI (CLI client) <kairos-cli>

The Kairos CLI offers a simple user interface (UI) which provides commands to allow a user to deposit, transfer and withdraw funds allocated in their Kairos account. Once a user submits either of the transactions, the client delegates the bulk of the work to the Kairos node (@kairos-node). It can also be used to verify past state changes and to query account balances.

// Web UI is now post-version 0.1
// == Web UI
// 
// Note: The integration with Casper's L1 wallet shouldn't be difficult. There is an SDK in Typescript, which compiles to Javascript, and hence the small number of interactions we require with the L1 wallet will be implementable in anything else that compiles to or uses Javascript, whether that be Elm, Yesod, Typescript, Purescript..
// Proposal: If the L2 server is implemented in Haskell, we could use Yesod. Otherwise our preferred choice would be Elm.

=== Backend

==== Kairos Node (L2 Server) <kairos-node>

As stated in the introduction of this section, Kairos V0.1 has a client-server architecture. Therefore the Kairos node acts as a centralized L2. The reasoning behind this decision, potential dangers, and our methods for dealing with these dangers are explained in @centralized-L2.

The Kairos node is the backend interface, through which external clients (@kairos-cli) can submit deposits, transfers, or withdrawals of funds. It is moreover connected to a database (@database) to persist the account balances, whose state representation is maintained on-chain. State transitions of the account balances need to be verified and performed on-chain, requiring the node to create the relevant transactions on L1. These transactions call the respective endpoints of the smart contracts described in @contracts to do so. For performing and batching transfers the node utilizes a proving system provided by the Prover service (@prover). For deposits and withdrawals, the node creates according Merkle tree updates of the account balances.

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

==== Prover <prover>

The Prover is a separate service that exposes a _prove_ and a _verify_ endpoint, which will mainly be used by the Kairos node (@kairos-node) to prove batches of transfers. Under the hood, the Prover utilizes a zero-knowledge proving system that computes the account balances resulting from the transfers within a batch and a prove of correct computation.

==== Database <database>

The database is a persistent storage that stores the performed transfers and the account balances whose state is stored on the blockchain. To achieve more failsafe and reliable availability of the data, it is replicated sufficiently often. In the case of failure, standbys (replicas) can be used as new primary stores.

==== Kairos State/ Verifier Contract <contracts>

The Kairos State and Verifier Contract are responsible for verifying and performing state updates of the account balances representation on-chain. They can be two separate contracts or a single contract with several endpoints. The important thing is that the state update only happens if the updated state was verified successfully beforehand. The contracts are called by the Kairos node by creating according transactions and submitting them to a Casper node.

In order for the account balances representation (a Merkle tree root) to have an initial state, the Kairos State Contract will be initialized with an initial deposit. This initial deposit will be the balance of the system.

// TODO: Where does the ZK verification happen?
// This document currently silently assumes verification _can_ happen within the verifying smart contract. Is this the case? Answering that question will require a deep-dive into Risc0 or whicheven ZK prover we end up picking.
// 
// Old notes:
// Within the casper-node, if the ZK verification code doesn't fit into a smart contract? If it does, then within the same smart contract, or a dedicated one?
// Deep-dive into Risc0: What does verification require? How much data and computation?
// - Can this be integrated into a smart contract?
// - If so, should we use a separation ZK verification smart contract, or include it in the Validium start contract?
// - If not, how can we integrate this with the Casper node?

== APIs

The following sections describe the APIs of the previously described components.

=== Kairos Node (L2 Server) <kairos-node-api>
#table(
  columns: (auto, auto),
  [Endpoint],[Description],
  [`GET /counter`], [Returns the Kairos counter, a mechanism that prevents the usage of transfers more than one time without the users permission. It has to be added to each new L2 transaction in order to be accepted by the Kairos node.],
  [`GET /accounts/:accountID`], [Returns a single user's L2 account balance],
  [`GET /accounts`], [Returns the current Kairos state, i.e. all L2 account balances],
  [`POST /transfer`], [Takes an L2 transfer in JSON format, and returns a TxID],
  [`GET /transfer/:TxID`], [Returns the status of a given transfer: Cancelled, ZKP in progress, batch proof in progress, or "posted on L1 with blockhash X"],
  [`GET /deposit`], [Takes a JSON request for an L1 deposit and calculates the new Merkle root and accompanying data needed to verify the new Merkle root],
  [`GET /withdraw`], [Takes a JSON request for an L1 withdrawal and calculates the new Merkle root and accompanying data needed to verify the new Merkle root]
)

=== Kairos State/ Verifier Contract <contracts-api>

#table(
  columns: (auto, auto),
  [Endpoint],[Description],
  [`POST deposit(sender's public key, token ID, token amount, new Merkle root, metadata needed to verify the Merkle root, sender's signature)`],
  [- Verify that this amount of tokens can be sent, and move it from the sender's L1 account to the purse owned by Kairos \
  - Verify the sender's signature \
  - Verify the new Merkle root given public inputs and metadata \
  - Update the systems on-chain state
  ],
  [`POST withdrawal(Receiver's public key, token ID, token amount, new Merkle root, metadata needed to verify the merkle root, receiver's signature)`],
  [- Move the appropriate amount of tokens from the purse owned by Kairos to the receiver's L1 account \
  - Verify the receiver's signature \
  - Verify the new Merkle root given public inputs and metadata \
  - Update the system's on-chain state \
  ],
  [`POST ZKV:(ZKV, new Merkle root)`],
  [- Verify ZKV \
  - Update the systems on-chain state
  ]
)

=== CLI

The CLI offers the following commands:
#table(
  columns: (auto, auto),
  [Command],[Description],
  [`accounts`], [Returns all Kairos (L2) account balances],
  [`accounts <accountId>`], [Returns a users Kairos account balance],
  [`deposit <from-address> <amount> <key_pair>`], [Creates a deposit request for the Kairos node's deposit endpoint],
  [`withdraw <to-address> <amount> <key_pair>`], [Creates a withdraw request for the Kairos node's withdraw endpoint],
  [`transfer <from-address> <to-address> <amount> <key_pair>`], [Creates a withdraw request for the Kairos node's withdraw endpoint],
  // TODO revisit verify
  [`verify <Vector of Transfers>`], [Verifies batched transfers]
)

== Data

=== Kairos CLI/ Kairos Node <kairos-node-data>
==== Deposit 
- Depositor's address
- Depositor's signature
- Token amount
- Token ID, i.e. currency

==== Withdraw
- Withdrawer's address
- Withdrawer's signature
- Token amount
- Token ID, i.e. currency

==== Transfer
- Sender's address
- Receiver's address
- Token amount
- Token ID, i.e. currency
- Sender's signature

=== Kairos State/ Verifier Contract <contracts-data>
- Current Merkle root, representing the Kairos system's state;
- Kairos counter, a mechanism that prevents the usage of transfers more than one time without the users permission. See @uniqueness
- Its own account balance, which amounts to the total sum of all the Validium account balances.

=== Prover

The zero knowledge proofs for transfer transaction consist of the following:
- Public input: Unsigned L2 transaction
- Private input: L2 transaction signature
- Verify: Signature

For the ZK rollup:
- Public inputs: Old and new Merkle root, Kairos counter (a mechanism that prevents the usage of transfers more than one time without the users permission. See @uniqueness)
- Private inputs: The list of L2 transactions and their ZKPs, as well as the full old Merkle tree
- Verify:
  - The ZKPs don't clash, i.e. they all have separate senders and receivers
  - All ZKPs are valid
  - All L2 transactions include as a public input the last Merkle root posted on L1 by L2. This Merkle root itself is taken as a public input to the batch proof.
  - The old Merkle root is correctly transformed into the new Merkle root through applying all the L2 transactions

== Component Interaction

The following two sequence diagrams show how these individual components interact together to process a users `deposit` and `transfer` request.

=== Deposit Sequence Diagram

Depositing funds to user `Bob`'s account is divided into three phases, which are modelled in the following sequence diagrams.

In the first phase (@deposit-client-submit) users submit their deposit requests through the Kairos CLI to the Kairos node (L2 server), which updates the Merkle root and creates a _Deploy_. This _Deploy_ contains a _Session_ to execute the validation of this Merkle tree update, perform the state transition and transfer the funds from the users purse to the Kairos purse. This _Deploy_ also needs to be signed by the user before submitting, which can be accomplished by calling the Casper CLI.

After submitting, the L1 smart contracts take care of validating the new Merkle root, updating the Kairos state, and transferring the funds (@deposit-deploy-execution).

Lastly (@deposit-notify), the Kairos node gets notified after the _Deploy_ was processed successfully. The node then commits the updated state to the database. After sufficient time has passed, the user can query its account balance using the Kairos CLI

#page(flipped: true)[
  #figure(
      image("deposit_sequence_diagram_client_submit.svg", width: 100%),
      caption: [
        Deposit: User submits a deposit to L2 which gets forwarded to L1.
      ],
  ) <deposit-client-submit>
]

#page(flipped: true)[
#figure(
  image("deposit_sequence_diagram_deploy_execution.svg", width: 100%),
  caption: [
    Deposit: Execution of the _Deploy_ on L1.
  ],
) <deposit-deploy-execution>
]

#page(flipped: true)[
#figure(
  image("deposit_sequence_diagram_notify_l2.svg", width: 100%),
  caption: [
    Deposit: Notifying the L2 after succcessfull on-chain execution.
  ],
) <deposit-notify>
]

=== Transaction Sequence Diagram

Transfering funds from user `Bob` to a user `Alice` can be divided into four phases, which are modelled in the following sequence diagrams.

In the first phase (@transfer-submit) users submit their transactions through the Kairos CLI to the Kairos Node (L2 server), which accumulates them and checks for independence. In addition, the Kairos node will check that the batch proof which is going to be computed next, has the same value for the `Kairos counter` as the submitted transaction.

After `t` seconds or `n` transactions (@transfer-prove), the Kairos node creates a proof and the according _Deploy_ which will execute the validation and the state transition on-chain.

After submitting, the L1 smart contracts take care of first validating the proof and updating the state (@transfer-execute).

Lastly (@transfer-notify), the Kairos node gets notified when the _Deploy_ was processed successfully. The node then commits the updated state to the database. After sufficient time has passed, the users can query their account balances using the Kairos CLI

#page(flipped: true)[
#figure(
  image("transfer_sequence_diagram_client_submit.svg", width: 100%),
  caption: [
    Transfer: User submits a transaction to L2.
  ],
) <transfer-submit>
]

#page(flipped: true)[
#figure(
  image("transfer_sequence_diagram_l2_prove_deploy.svg", width: 100%),
  caption: [
    Transfer: Proving and submitting the proof.
  ],
) <transfer-prove>
]

#page(flipped: true)[
#figure(
  image("transfer_sequence_diagram_deploy_execution.svg", width: 100%),
  caption: [
    Transfer: Execution of the _Deploy_ on L1.
  ],
) <transfer-execute>
]

#page(flipped: true)[

#figure(
  image("transfer_sequence_diagram_notify_l2.svg", width: 100%),
  caption: [
    Transfer: Notifying the L2 after succcessfull on-chain execution.
  ],
) <transfer-notify>
]

= Threat model

= Glossary

Brief descriptions:
- L1: The Casper blockchain as it currently runs.
- L2: A layer built on top of the Casper blockchain, which leverages Casper's consensus algorithm and existing infrastructure for security purposes while adding scaling and/or privacy benefits

== ZKP

In recent decades, a new industry has evolved around the concept of zero knowledge proofs (ZKPs). In essence, the goal of this industry is to allow party A to prove to party B that they are in possession of information X without revealing this information to party B. In practice, this is accomplished by party A generating some proof, called a zero knowledge proof, based on information X, in such a way as to allow party B to verify that the proof (that party A possesses information X). In addition, this zero knowledge proof cannot be used ,in order to gain any information about X other than party A's possession of the information, hence the term "zero knowledge".

This general concept has many applications for two specific reasons: Privacy and scaling. Firstly, zero knowledge proofs allow you to share partial information, retaining your privacy. For example, I could share my birthday in an encoded way (e.g. hashed) and generate a zero knowledge proof that my age is higher than 21, thereby only revealing to you the fact that I am older than 21, and not what my actual age is. Similarly, I could prove to you that I have the password associated to a given Facebook account without actually having to reveal my password.

The second feature of zero knowledge proofs is scalability. Imagine information X is a large amount of data, then it is possible to generate a ZKP proving party A possesses data X, such that the ZKP itself is much smaller than the data X. This feature of ZKPs is particularly interesting to blockchains, as they experience an accute problem: Each transaction posted to a blockchain must, for most blockchains, be verified by each node. This provides a lot of duplicate work and thereby prevents most blockchains from scaling. One solution to this problem is to leverage ZKPs, where one server collects a set of transactions, generates proofs for them and then batches these proofs into one so-called batch proof. This batch proof can then be posted on the blockchain itself ("L1"), together with the related blockchain's state change. This concept constitutes an L2 scaling solution blockchains.

== Merkle tree

A Merkle tree is a cryptographic concept to generate a hash for a set of data. It allows for efficient and secure verification of the contents of large data structures. In addition, Merkle trees allow to quickly recompute the hash (called a "Merkle root") when the data changes locally, e.g. if only one element of a list of data points changes.

We will now briefly explain how to construct a Merkle tree and compute the Merkle root (the "hash" of the data) given a list of data points, as shown in figure @merkle-tree-figure. First, for each data point, we compute the hash and note that down. These hashes form the leafs of the Merkle tree. Then, in each layer of the tree, two neighboring hashes are combined and hashed again, assigning the resulting value to this node. Eventually the tree ends in one node, the value of which is named the Merkle root.

#figure(
  image("merkle-tree.svg", width: 80%),
  caption: [
    Merkle tree
  ],
) <merkle-tree-figure>

== ZK Rollup

A ZK Rollup is the simplest way to create a zero knowledge-based L2 scaling solution on top of a blockchain.

== ZK Validium

#bibliography("bibliography.yml")


== test <centralized-L2>
== test2<uniqueness>
