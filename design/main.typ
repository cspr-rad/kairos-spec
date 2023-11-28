#let title = [
  Kairos: Zero-knowledge Casper Transaction Scaling
]
#let time_format = "[weekday] [month repr:long] [day padding:none], [year]"
#set page(paper: "a4", numbering: "1", margin: (x: 3.2cm, y: 4.0cm))
#set heading(numbering: "1.")
#set text(
  // font: "Linux Libertine",
  size: 12pt,
)
#show link: underline

#align(
  center,
  text(
    21pt,
  )[
    *#title*

    Design

    #align(
      center,
      text(
        12pt,
      )[
        Marijan Petricevic, Nick Van den Broeck, Mark Greenslade, Tom Sydney Kerckhove,
        Matthew Doty, Avi Dessauer, Jonas Pauli, Andrzej Bronski, Quinn Dougherty, Chloe
        Kever
      ],
    )

    #datetime.today().display(time_format)
  ],
)

#outline(title: "Contents", indent: auto)
#pagebreak()

= Architecture <architecture>

To give the reader an idea of what a system defined in the previous sections
might look like, this section proposes a possible architecture. The features and
requirements described previously suggest two core components in the system. A
CLI and an L2 node implementing the client-server pattern. The L2 node should
not be monolithic but rather obey the principle of separation of concerns to
allow for easier extensibility and replacement of components in the future.
Therefore, the L2 node unifies various other components described in more detail
in the following @architecture-components and exposes them through a single API.

#figure(image("components_diagram.svg", width: 100%), caption: [
  Components diagram
]) <components-diagram-figure>

== Architecture Components <architecture-components>
=== Client CLI <cli>

The client CLI's user interface (UI) is comprised of commands allowing users to
deposit, transfer, and withdraw funds allocated in their L2 account. Once a user
executes any of the commands, the client delegates the bulk of the work to the
L2 node (@l2-node). Moreover, the client CLI can be used to verify past state
changes and to query account balances and transfers.

// Web UI is now post-version 0.1
// == Web UI
//
// Note: The integration with Casper's L1 wallet shouldn't be difficult. There is an SDK in Typescript, which compiles to Javascript, and hence the small number of interactions we require with the L1 wallet will be implementable in anything else that compiles to or uses Javascript, whether that be Elm, Yesod, Typescript, Purescript..
// Proposal: If the L2 server is implemented in Haskell, we could use Yesod. Otherwise our preferred choice would be Elm.

=== L2 Node <l2-node>

As constrained in the requirements document, the L2 node is centralized. The detailed
reasoning behind this decision, potential dangers, and our methods for dealing
with these dangers are explained in @centralized-L2.

The L2 node is the interface through which external clients (@cli) can submit
deposits, transfers, or withdrawals of funds. Moreover, it is connected to a
data store (@data-store) to persist the account balances, whose state
representation #footnote[The state representation is the Merkle root, see @glossary.] is
maintained on-chain. State transitions of the account balances are verified and
executed on-chain, requiring the node to create respective transactions on L1
using the L1's software development kit (SDK). These transactions, in turn, call
the respective endpoints of smart contracts described in @contracts to do so. To
execute batch transfers the node utilizes a proving system provided by the
Prover service (@prover). For deposits and withdrawals, the node creates
according Merkle tree updates of the account balances @merkle-tree-updates.

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

=== Prover <prover>

The Prover is a separate service that exposes a _batchProve_ and a _batchVerify_ endpoint,
mainly used by the L2 node (@l2-node) to prove batches of transfers. Under the
hood, the Prover uses a zero-knowledge proving system that computes the account
balances resulting from the transfers within a batch and a proof of correct
computation.

=== Data Store <data-store>

The data store is a persistent storage that stores the performed transfers and
the account balances whose state representation is stored on the blockchain. To
achieve more failsafe and reliable availability of the data, it is replicated
sufficiently often by so-called standbys (replicas). In the case of failure,
standbys can be used as new primary stores (@data-redundancy).

=== L1 State/ Verifier Contract <contracts>

The L1 State and Verifier Contracts are responsible for verifying and performing
updates of the Merkle root of account balances. They can be two separate
contracts or a single contract with several endpoints. A state update only
happens if the updated state was verified successfully beforehand. The contracts
are called by the L2 node by creating according transactions and submitting them
to an L1 node.

For the Merkle tree root to have an initial value, the State Contract will be
initialized with a deposit. This initial deposit then becomes the balance of the
system.

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

The following section proposes a possible API of the previously described
components.

=== Client CLI

#table(
  columns: (auto, auto, auto, auto),
  [Name],
  [Arguments],
  [Return Value],
  [Description],
  [get_balance],
  [accountId: AccountID],
  [balance: UnsignedINT],
  [Returns a user's L2 account balance. The UnsignedINT type should be a type that
    allows for safe money computations (Read @safe-money)],
  [transfer],
  [sender: AccountID, recipient: AccountID, amount: UnsignedINT, token_id: TokenID,
    nonce: Nonce, key_pair: KeyPair],
  [transferId: TransferID],
  [Creates, signs and submits an L2 transfer to the L2 node. A cryptographic nonce
    should be used in order to prevent replay attacks.],
  [getTransfer],
  [transferId: TransferID],
  [transfer: TransferState],
  [Returns the status of a given transfer: Cancelled, ZKP in progress, batch proof
    in progress, or "posted on L1 with blockhash X"],
  [deposit],
  [depositor: AccountID, amount: UnsignedINT, token_id: TokenID, key_pair: KeyPair],
  [transaction: Transaction],
  [Creates an L1 deposit transaction, by first asking the L2 node to create an
    according L1 transaction for us, afterward signing it on the client-side and
    then submitting it to L1 through the L2 node],
  [withdraw],
  [withdrawer: AccountID, amount: UnsignedINT, token_id: TokenID key_pair: KeyPair],
  [transaction: Transaction],
  [Creates an L1 withdraw transaction, by first asking the L2 node to create an
    according L1 transaction for us, afterward signing it on the client-side and
    then submitting it to L1 through the L2 node],
  [verify],
  [proof: Proof, public_inputs: PublicInputs],
  [result: VerifyResult],
  [Returns whether a proof is legitimate or not],
)

=== L2 Node <l2-node-api>
#table(
  columns: (auto, auto, auto, auto),
  [Name],
  [Arguments],
  [Return Value],
  [Description],
  [get_balance],
  [accountId: AccountID],
  [balance: UnsignedINT],
  [Returns a user's L2 account balance. The UnsignedINT type should be a type that
    allows for safe money computations (Read @safe-money)],
  [transfer],
  [sender: AccountID, recipient: AccountID, amount: UnsignedINT, token_id: TokenID,
    nonce: Nonce, signature: Signature, sender_pub_key: PubKey],
  [transferId: TransferID],
  [Schedules an L2 transfer, and returns a transfer-ID],
  [getTransfer],
  [transferId: TransferID],
  [transfer: TransferState],
  [Returns the status of a given transfer: Cancelled, ZKP in progress, batch proof
    in progress, or "posted on L1 with blockhash X"],
  [deposit],
  [depositor: AccountID, amount: UnsignedINT, token_id: TokenID],
  [transaction: Transaction],
  [Creates an L1 deposit transaction containing an according Merkle tree root
    update and accompanying metadata needed to verify the update based on the
    depositor's account ID and the amount. The returned transaction is an L1
    transaction that has to be signed by the depositor on the client-side.],
  [withdraw],
  [withdrawer: AccountID, amount: UnsignedINT, token_id: TokenID],
  [transaction: Transaction],
  [Creates an L1 withdraw transaction containing an according Merkle tree root
    update and accompanying metadata needed to verify the update based on the
    withdrawer's account ID and the amount. The returned transaction is an L1
    transaction that has to be signed by the withdrawer on the client-side.],
  [submitTransaction],
  [signedTransaction: SignedTransaction],
  [submitResult: SubmitResult],
  [Forwards a signed L1 transaction and submits it to the L1 for execution.],
  [verify],
  [proof: Proof, public_inputs: PublicInputs],
  [result: VerifyResult],
  [Returns whether a proof is legitimate or not],
)

=== L1 State/ Verifier Contract <contracts-api>

#table(
  columns: (auto, auto, auto, auto),
  [Name],
  [Arguments],
  [Return Value],
  [Description],
  [verify_deposit],
  [depositor: AccountID, amount: UnsignedINT, token_id: TokenID,
    updated_account_balances: MerkleRootHash, update_metadata:
    MerkleRootUpdateMetadata, signature: Signature],
  [],
  [- Verifies that the transaction contains the same amount of tokens used to update
      the account balance\
      - Moves the amount from the depositor's L1 account to the account owned by the
        system\
      - Verifies the depositor's signature\
      - Verifies the new Merkle root given the public inputs and metadata\
      - Updates the system's on-chain state on successful verification
  ],
  [verify_withdraw],
  [withdrawer: AccountID, amount: UnsignedINT, tokenId: TokenID,
    updated_account_balances: MerkleRootHash, update_metadata:
    MerkleRootUpdateMetadata, signature: Signature],
  [],
  [- Verifies that the transaction moves the same amount of tokens used to update the
      account balance\
      - Moves the amount from the account owned by the system to the withdrawer's L1
        account\
      - Verifies the withdrawer's signature\
      - Verifies the new Merkle root given the public inputs and metadata\
      - Updates the system's on-chain state on successful verification
  ],
  [verify_transfers],
  [proof: Proof, publicInputs: PublicInputs],
  [],
  [- Verifies that the proof computed from performing batch transfers on the L2 is
      valid\
      - Updates the system's on-chain state on successful verification
  ],
)

== Component Interaction

Figures 2 and 3 show sequence diagrams for processing a user's deposit and
transfer requests, respectively.

=== Deposit Sequence Diagram

Depositing funds to user `Bob`'s account is divided into three phases, which are
modelled in the following sequence diagrams.

In the first phase (@deposit-client-submit) users submit their deposit requests
through the client CLI to the L2 node. The L2 node creates an L1 transaction
(_Deploy_) containing the according Merkle root update and the update metadata,
which can be used to verify that the update was done correctly. More precisely,
the _Deploy_ contains a _Session_ that executes the validation of the Merkle
tree update, performs the state transition and transfer the funds from the
user's L1 account (purse) to the systems L1 account. This _Deploy_ needs to be
signed by the user before submitting, this is achieved by making use of the L1's
SDK on the client-side.

After submitting, the L1 smart contracts take care of validating the new Merkle
root, updating the system's state, and transferring the funds
(@deposit-deploy-execution).

Lastly (@deposit-notify), the L2 node gets notified after the _Deploy_ was
processed successfully. The node then commits the updated state to the data
store. After sufficient time has passed, the user can query its account balance
using the client CLI.

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

Transfering funds from user `Bob` to a user `Alice` can be divided into four
phases, which are modelled in the following sequence diagrams.

In the first phase (@transfer-submit) users submit their transfer requests
through the client CLI to the L2 node. The L2 node accumulates the transfer
requests and checks for independence. In addition, the L2 node will check that
the batch proof which is going to be computed next, a valid nonce.

After `t` seconds or `n` transactions (@transfer-prove), the L2 node batches the
transfers, creates a proof of computation, and the according _Deploy_ which will
execute the validation and the state transition on-chain.

After submitting, the L1 smart contracts take care of first validating the proof
and updating the state (@transfer-execute).

Lastly (@transfer-notify), the L2 node gets notified when the _Deploy_ was
executed successfully. The node then commits the updated state to the data
store. After sufficient time has passed, the users can query their account
balances using the client CLI

#page(flipped: true)[
  #figure(
    image("transfer_sequence_diagram_client_submit.svg", width: 100%),
    caption: [
      Transfer: User submits a transfer to L2.
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

/ Validium: Please refer to @validium and @validium-vs-rollup
/ L1: The Casper blockchain as it currently runs.
/ L2: A layer built on top of the Casper blockchain, which leverages Casper's
  consensus algorithm and existing infrastructure for security purposes while
  adding scaling and/or privacy benefits
/ Nonce/ Kairos counter: A mechanism that prevents the usage of L2 transactions more than once without
  the user's permission. It is added to each L2 transaction, which is verified by
  the batch proof and L1 smart contract. For an in-depth explanation, see
  @uniqueness.
/ Zero knowledge proof (ZKP): Is a proof generated by person A which proves to person B that A is in
  possession of certain information X without revealing X itself to B. These ZKPs
  provide some of the most exciting ways to build L2s with privacy controls and
  scalability. @zkp
/ Merkle trees: Are a cryptographic concept to generate a hash given a dataset. It allows for
  efficient and secure verification of the contents of large data strutures.
  @merkle-tree

#bibliography("bibliography.yml")
