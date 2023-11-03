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

The Casper blockchain's ecosystem yearns for a scaling solution to achieve a higher transaction throughput and continue to stay competitive. As a first step towards providing a trustless scaling solution, the goal of the initial version 0.1 of the Kairos project is to build a zero-knowledge (ZK) _validium_ @validium-vs-rollup for payment transactions in a second layer (L2). This system will both enable a higher transaction throughput and lower gas fees. Here, _validium_ refers to a rollup where the data, such as account balances, are stored on L2 rather than on the Casper blockchain directly (L1).

Additionally, Kairos V0.1 serves two other major purposes:

- It is the first step towards a cheap and frictionless NFT (non-fungible token) minting and transfer system aiding Casper to become _the_ blockchain to push the digital art industry forward.

- The conciseness and complexity of its scope allow us to explore the problem space of L2 solutions which leverage zero-knowledge technology and integrate with Casper's L1. Furthermore, it allows the team to collaborate and grow together by building a production-grade system.

Kairos V0.1 will support very few simple interactions and features. Users will be able to deposit and withdraw funds by interacting with an L1 smart contract controlled by Kairos. Transfers of funds to other participants will be serviced by the L2 and verified and stored by the L1. In the remainder of this document, we will detail the requirements of such a system.

In @overview (Product Overview) we describe the high-level features that Kairos V0.1 will support. @requirements specifies the requirements based on the described interactions and features. Next, in @architecture (Architecture) we propose an architecture of this initial version, together with the component interfaces and their interactions. We conclude the document with threat models and a glossary, which clarifies the terminology used throughout this document. Note that this specification comes with a number of blogposts detailing some of the design considerations in more detail, as listed in the bibliography @compare-zk-provers @trustless-cli.

= Product Overview<overview>

To have a common denominator on the scope of Kairos V0.1, this section describes the high-level features it has to support.

== Product Application

=== Target Audience

The target audience comprises users familiar with blockchain technology and applications built on top of the Casper blockchain.

=== Operating Environment

The product's backend will be deployed on modern powerfull machines equipped with a powerful graphics processing unit (GPU) and a large amount of working memory as well as persistent disk space. The machines will have continuous access to the Internet.

The CLI will be deployed on modern, potentially less powerfull hardware.

=== Constraints <constraints>

The product should be a centralized solution for this initial version 0.1.

The utilized proving system should be zero knowledge.

== Features

=== Deposit money into L2 system

*[tag:F00]*: Users should be able to deposit tokens from their L1 account to their L2 account at any given time through a command line interface (CLI).

=== Withdraw money from L2 system

*[tag:F01]*: Users should be able to withdraw tokens from their L2 account to their L1 account any given time through a CLI. This interaction should not require the approval of the operator (#link("https://ethereum.org/en/developers/docs/scaling/validium/#deposits-and-withdrawals")[see Ethereum's validium]).

=== Transfer money within the L2 system

*[tag:F02]*: Users should be able to transfer tokens from their L2 account to another user's L2 account at any given time through a CLI.

=== Query account balances

*[tag:F03]*: Anyone should be able to query any L2 account balances at any given time through a CLI. In particular, users can also query their personal L2 account balance.

=== Query transaction data

*[tag:F04]*: Anyone should be able to query any L2 transactions at any given time through a CLI.

=== Verification

*[tag:F05]*: Anyone should be able to verify deposits, withdrawals, or transactions either through a CLI or application programming interface (API), i.e. a machine-readable way.

= Requirements <requirements>

Based on the product overview given in the previous section, this section aims to describe testable, functional requirements the system needs to meet.

== Functional requirements

=== Deposit money into L2 system

- *[tag:F00-00]* Depositing an amount of `tokens`, where `tokens >= MIN_AMOUNT` should be accounted correctly
- *[tag:F00-01]* Depositing an amount of `tokens`, where `tokens < MIN_AMOUNT` should not be executed at all
- *[tag:F00-02]* A user depositing any valid amount to its `L2 account` should only succeed if the user has signed the deposit transaction
- *[tag:F00-03]* A user depositing any valid amount with a proper signature to another users account should fail
- *[tag:F00-04]* When a user submits a deposit request, the request cannot be used more than one time without the users approval

=== Withdraw money from L2 system

- *[tag:F01-00]* Withdrawing an amount of `tokens`, where `users L2 account balance >= tokens > MIN_AMOUNT` should be accounted correctly
- *[tag:F01-01]* Withdrawing an amount of `tokens`, where `tokens < MIN_AMOUNT` should not be executed at all
- *[tag:F01-02]* Withdrawing an amount of `tokens`, where `tokens > users L2 account balance` should not be possible
- *[tag:F01-03]* Withdrawing a valid amount from the users L2 account should be possible without the intermediary operator of the system
- *[tag:F01-04]* Withdrawing a valid amount from the users L2 account should only succeed if the user has signed the withdraw transaction
- *[tag:F01-05]* Withdrawing a valid amount from another users L2 account should not be possible
- *[tag:F01-06]* When a user submits a withdraw request, the request cannot be used more than one time without the users approval

=== Transfer money within the L2 system

- *[tag:F02-00]* Transfering an amount of `CSPR tokens`, where `users L2 account balance >= tokens > MIN_AMOUNT` should be accounted correctly
- *[tag:F02-01]* Transfering an amount of `CSPR tokens`, where `tokens < MIN_AMOUNT` should not be executed at all
- *[tag:F02-02]* Transfering an amount of `CSPR tokens`, where `tokens > users L2 account balance` should not be possible
- *[tag:F02-03]* Transfering a valid amount to another user that does not have a registered L2 account yet should be possible.
- *[tag:F02-04]* Transfering a valid amount to another user sbould only succeed if the user owning the funds has signed the transfer transaction
- *[tag:F02-05]* When a user submits a transfer request, the request cannot be used more than one time without the users approval

=== Query account balances

- *[tag:F03-00]* A user should be able to see its L2 account balance immediately when it's queried through the CLI
- *[tag:F03-01]* Anyone should be able to obtain any L2 account balances when querying the CLI or API
- *[tag:F03-02]* Account balances should be written by known, verified entities only
- *[tag:F03-03]* Account balances should be updated immediately after the successful verification of correct deposit/withdraw/transfer interactions
- *[tag:F03-04]* Account balances should not be updated if the verification of the proof of the interactions fails
- *[tag:F03-05]* Account balances should should be stored redundantly @data-redundancy

=== Query transaction data
- *[tag:F04-00]* A user should be able to see its L2 transactions immediately when they are queried through the CLI
- *[tag:F04-01]* Anyone should be able to obtain any L2 transactions when querying the CLI or API
- *[tag:F04-02]* Transaction data should be written by known, verified entities only
- *[tag:F04-03]* Transaction data should be written immediately after the successful verification of correct deposit/withdraw/transfer interactions
- *[tag:F04-04]* Transaction data should not be written if the verification of the proof of the interactions fails
- *[tag:F04-05]* Transaction data should be stored redundantly @data-redundancy

=== Verification

- *[tag:F05-00]* Anyone should be able to query and verify proofs of the system's state changes caused by deposit/withdraw/transfer interactions at any given time

== Non-functional requirements

These are qualitative requirements, such as "it should be fast" and could be benchmarked.

- *[tag:NF00]* The application should not leak any private nor sensitive informations like private keys
- *[tag:NF01]* The backend API needs to be designed in a way such that it's easy to swap out a client implementation
- *[tag:NF02]* The CLI should start fast
- *[tag:NF03]* The CLI should respond on user interactions fast
- *[tag:NF04]* The CLI should be designed in a user friendly way
- *[tag:NF05]* The L2 should support a high parallel transaction throughput #footnote[Read @sequential-throughput for more insight into parallel vs. sequential transaction throughput.]
- *[tag:NF06]* The whole system should be easy to extend with new features

= A suggested architecture <architecture>

The features and reqirements described in the previous sections, suggest two core actors in the system. A CLI and a L2 node, implementing the client-server pattern. The L2 node is not a monolyth, it interacts with various other components described in more deail in the following @architecture-components.

#figure(
  image("components_diagram.svg", width: 100%),
  caption: [
    Components diagram
  ],
) <components-diagram-figure>

== Architecture Components <architecture-components>
=== CLI (CLI client) <cli>

The client CLI offers a simple user interface (UI) providing commands to allow a user to deposit, transfer and withdraw funds allocated in their L2 account. Once a user performs any of the interactions, the client delegates the bulk of the work to the L2 node (@l2-node). The client CLI can moreover be used to verify past state changes and to query account balances as well as transfers.

// Web UI is now post-version 0.1
// == Web UI
// 
// Note: The integration with Casper's L1 wallet shouldn't be difficult. There is an SDK in Typescript, which compiles to Javascript, and hence the small number of interactions we require with the L1 wallet will be implementable in anything else that compiles to or uses Javascript, whether that be Elm, Yesod, Typescript, Purescript..
// Proposal: If the L2 server is implemented in Haskell, we could use Yesod. Otherwise our preferred choice would be Elm.


=== L2 Node <l2-node>

As constrained in @constraints, the L2 node is centralized. The detailed reasoning behind this decision, potential dangers, and our methods for dealing with these dangers are explained in @centralized-L2.

The L2 node is the interface through which external clients (@cli) can submit deposits, transfers, or withdrawals of funds. It is moreover connected to a data store (@data-store) to persist the account balances, whose state representation #footnote[The state representation is the Merkle root, see @glossary.] is maintained on-chain. State transitions of the account balances need to be verified and performed on-chain, requiring the node to create respective transactions on L1 using the L1's software development kit (SDK). These transactions in turn, call the respective endpoints of smart contracts described in @contracts to do so. To execute and batch transfers, the node utilizes a proving system provided by the Prover service (@prover). For deposits and withdrawals, the node creates according Merkle tree updates of the account balances @merkle-tree-updates.

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

The Prover is a separate service that exposes a _batchProve_ and a _batchVerify_ endpoint, which will mainly be utilized by the L2 node (@l2-node) to prove batches of transfers. Under the hood, the Prover utilizes a zero-knowledge proving system that computes the account balances resulting from the transfers within a batch and a proof of correct computation.

==== Data Store <data-store>

The data store is a persistent storage that stores the performed transfers and the account balances whose state representation is stored on the blockchain. To achieve more failsafe and reliable availability of the data, it is replicated sufficiently often. In the case of failure, standbys (replicas) can be used as new primary stores (@data-redundancy).

==== L1 State/ Verifier Contract <contracts>

The L1 State and Verifier Contracts are responsible for verifying and performing updates of the Merkle root of account balances. They can either be two separate contracts or a single contract with several endpoints. The important thing is that the state update only happens if the updated state was verified successfully beforehand. The contracts are called by the L2 node by creating according transactions and submitting them to a L1 node.

In order for the Merkle tree root to have an initial value, the State Contract will be initialized with a deposit. This initial deposit then becomes the balance of the system.

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

The following section proposes a possible API of the previously described components.

=== CLI

#table(
  columns: (auto, auto, auto, auto),
  [Name],[Arguments],[Return Value],[Description],
  [getAccount],[accountId: AccountID],[balance: UnsignedINT],[Returns a user's L2 account balance. The `UnsignedINT` type should to be a type that allows for safe money computations],
  [transfer],[sender: AccountID, recipient: AccountID, amount: UnsignedINT, nonce: Nonce, keyPair: KeyPair],[transferId: TransferID],[Creates, signs and submits a L2 transfer to the L2 node],
  [getTransfer],[transferId: TransferID],[transfer: TransferState],[Returns the status of a given transfer: Cancelled, ZKP in progress, batch proof in progress, or "posted on L1 with blockhash X"],
  [deposit],[depositor: AccountID, amount: UnsignedINT, keyPair: KeyPair],[transaction: Transaction],[Creates a L1 deposit transacion, by asking the L2 node to create an according L1 transaction for us, signing it on the client side and then submitting it to L1 through the L2 node],
  [withdraw],[withdrawer: AccountID, amount: UnsignedINT, keyPair: KeyPair],[transaction: Transaction],[Creates a L1 withdraw transacion, by asking the L2 node to create an according L1 transaction for us, signing it on the client side and then submitting it to L1 through the L2 node],
  [verify],[proof: Proof, publicInputs: PublicInputs],[result: VerifyResult],[Returns whether a proof is legitimate or not]
)


=== L2 Node <l2-node-api>
#table(
  columns: (auto, auto, auto, auto),
  [Name],[Arguments],[Return Value],[Description],
  [getAccount],[accountId: AccountID],[balance: UnsignedINT],[Returns a user's L2 account balance. The `UnsignedINT` type should to be a type that allows for safe money computations],
  [transfer],[sender: AccountID, recipient: AccountID, amount: UnsignedINT, nonce: Nonce, signature: Signature, senderPubKey: PubKey],[transferId: TransferID],[Schedules an L2 transfer, and returns a TxID],
  [getTransfer],[transferId: TransferID],[transfer: TransferState],[Returns the status of a given transfer: Cancelled, ZKP in progress, batch proof in progress, or "posted on L1 with blockhash X"],
  [deposit],[depositor: AccountID, amount: UnsignedINT],[transaction: Transaction],[Creates a L1 deposit transacion containing an according Merkle tree root update and accompanying metadata needed to verify it, based on the depositor's account ID and the amount. The returned transaction is a L1 transaction that has to be signed by the depositor.],
  [withdraw],[withdrawer: AccountID, amount: UnsignedINT],[transaction: Transaction],[Creates a L1 withdraw transacion containing an according Merkle tree root update and accompanying metadata needed to verify it, based on the withdrawer's account ID and the amount. The returned transaction is a L1 transaction that has to be signed by the withdrawer.],
  [submitTransaction],[signedTransaction: SignedTransaction],[submitResult: SubmitResult],[Forwards a signed L1 transaction and submits it to the L1 for execution.],
  [verify],[proof: Proof, publicInputs: PublicInputs],[result: VerifyResult],[Returns whether a proof is legitimate or not]
)

=== L1 State/ Verifier Contract <contracts-api>

#table(
  columns: (auto, auto),
  [Endpoint],[Description],
  [`POST deposit(sender's public key, token ID, token amount, new Merkle root, metadata needed to verify the Merkle root, sender's signature)`],
  [- Verify that this amount of tokens can be sent, and move it from the sender's L1 account to the purse owned by Kairos \
  - Verify the sender's signature \
  - Verify the new Merkle root given public inputs and metadata \
  - Update the system's on-chain state
  ],
  [`POST withdrawal(Receiver's public key, token ID, token amount, new Merkle root, metadata needed to verify the merkle root, receiver's signature)`],
  [- Move the appropriate amount of tokens from the purse owned by Kairos to the receiver's L1 account \
  - Verify the receiver's signature \
  - Verify the new Merkle root given public inputs and metadata \
  - Update the system's on-chain state \
  ],
  [`POST batch_proof:(batch proof, new Merkle root)`],
  [- Verify batch proof \
  - Update the system's on-chain state
  ]
)

== Data

=== Kairos CLI/ L2 Node <l2-node-data>
==== Deposit (L1)
- Depositor's address
- Depositor's signature
- Token amount
- Token ID, i.e. currency

==== Withdraw (L1)
- Withdrawer's address
- Withdrawer's signature
- Token amount
- Token ID, i.e. currency

==== Transfer (L2)
- Sender's address
- Receiver's address
- Token amount
- Token ID, i.e. currency
- Sender's signature
- Kairos counter

=== Kairos State/ Verifier Contract <contracts-data>
- Current Merkle root, representing the Kairos system's state
- Kairos counter
- Its own account balance, which amounts to the total sum of all the Validium account balances

=== Prover

The zero knowledge proofs for transfer transaction consist of the following:
- Public input: Unsigned L2 transaction
- Private input: L2 transaction signature
- Verify: Signature

For the ZK rollup:
- Public inputs: Old and new Merkle root and the Kairos counter
- Private inputs: The list of L2 transactions and their ZKPs, as well as the full old Merkle tree
- Verify:
  - The ZKPs don't clash, i.e. they all have separate senders and receivers
  - All ZKPs are valid
  - All L2 transactions include the same Kairos counter as the batch proof
  - The old Merkle root is correctly transformed into the new Merkle root through applying all the L2 transactions

== Component Interaction

The following two sequence diagrams show how these individual components interact together to process a user's `deposit` and `transfer` request.

=== Deposit Sequence Diagram

Depositing funds to user `Bob`'s account is divided into three phases, which are modelled in the following sequence diagrams.

In the first phase (@deposit-client-submit) users submit their deposit requests through the Kairos CLI to the L2 node, which updates the Merkle root and creates a _Deploy_. This _Deploy_ contains a _Session_ to execute the validation of this Merkle tree update, perform the state transition and transfer the funds from the users purse to the Kairos purse. This _Deploy_ also needs to be signed by the user before submitting, which can be accomplished by calling the Casper CLI.

After submitting, the L1 smart contracts take care of validating the new Merkle root, updating the Kairos state, and transferring the funds (@deposit-deploy-execution).

Lastly (@deposit-notify), the L2 node gets notified after the _Deploy_ was processed successfully. The node then commits the updated state to the data store. After sufficient time has passed, the user can query its account balance using the Kairos CLI.

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

In the first phase (@transfer-submit) users submit their transactions through the Kairos CLI to the L2 node, which accumulates them and checks for independence. In addition, the L2 node will check that the batch proof which is going to be computed next, has the same value for the `Kairos counter` as the submitted transaction.

After `t` seconds or `n` transactions (@transfer-prove), the L2 node creates a proof and the according _Deploy_ which will execute the validation and the state transition on-chain.

After submitting, the L1 smart contracts take care of first validating the proof and updating the state (@transfer-execute).

Lastly (@transfer-notify), the L2 node gets notified when the _Deploy_ was processed successfully. The node then commits the updated state to the data store. After sufficient time has passed, the users can query their account balances using the Kairos CLI

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

= Glossary <glossary>

- L1: The Casper blockchain as it currently runs.
- L2: A layer built on top of the Casper blockchain, which leverages Casper's consensus algorithm and existing infrastructure for security purposes while adding scaling and/or privacy benefits
- Kairos counter: A mechanism that prevents the usage of L2 transactions more than once without the user's permission. It is added to each L2 transaction, which is verified by the batch proof and L1 smart contract. For an in-depth explanation, see @uniqueness.
- A zero knowledge proof (ZKP) is a proof generated by person A which proves to person B that A is in possession of certain information X without revealing X itself to B. These ZKPs provide some of the most exciting ways to build L2s with privacy controls and scalability. @zkp
- Merkle trees are a cryptographic concept to generate a hash given a dataset. It allows for efficient and secure verification of the contents of large data strutures. @merkle-tree

#bibliography("bibliography.yml")
