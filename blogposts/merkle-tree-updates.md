# How to update Merkle trees in ZK-based L2

The state of the Kairos L2 will be stored as a Merkle tree, as described in the
Kairos V0.1 specification. This means that we need to implement updating a
Merkle tree, along with proofs that the Merkle tree updates were executed
correctly. In this blogpost we will describe our design decisions around such
Merkle tree updates.

## The current situation

There are four concepts which can update the Merkle tree: Transfers, batch
proofs, deposits and withdrawals. Notice that transfers will not be implemented
to update the Merkle tree directly, as this would lead to issues related to the
sequential throughput, as described in a separate blogpost. Instead, the batch
proof will take care of the transfer-related Merkle tree updates. Specifically,
it will update the Merkle tree by loading the entire tree into the memory of a
zkVM as a private input, and updating it in-memory within the zkVM. This allows
us to prove to the L1 nodes that the Merkle root has been updated appropriately.
How to prove this for deposits and withdrawals, on the other hand, is still open
for consideration. More precisely, what is not yet certain is whether ZK proofs
are necessary and desirable for proving these Merkle root updates as well.

## Why without ZK?

So why would we question the use of ZK proofs here? Well, there are a few
drawbacks to using ZK proofs. Firstly, it makes the code which computes the
proofs dependent on the ZK prover, which both adds a reasonably sized dependency
and makes the code less agile in case the system opens itself up to multiple
provers. Secondly, generating ZK proofs can be computationally heavy, so we
might want to restrict these resource requirements to the features which really
require them. In general, ZK proofs are a fantastic tool because most things we
want to prove, such as the execution of the batch proofs, cannot be proven
easily without ZK. However, in the case of deposits and withdrawals, this might
just be possible after all.

## What is a Merkle tree?

Let us start with the beginning: What is a Merkle tree? A Merkle tree is a
cryptographic concept to generate a hash (called a "Merkle root") for a set of
data. It allows for efficient and secure verification of the contents of large
data structures. In addition, Merkle trees allow to quickly recompute the Merkle
root when the data changes locally, e.g. if only one element of a list of data
points changes.

TODO

We will now briefly explain how to construct a Merkle tree and compute the
Merkle root (the "hash" of the data) given a list of data points, as shown in
figure @merkle-tree-figure. First, for each data point, we compute the hash and
note that down. These hashes form the leafs of the Merkle tree. Then, in each
layer of the tree, two neighboring hashes are combined and hashed again,
assigning the resulting value to this node. Eventually the tree ends in one
node, the value of which is named the Merkle root.

## How to update without ZK?

- How to update without ZK?
  * Note: Deposits & withdrawals only change one leaf, so only the hashes the
    updated leaf interasts with are required in order to verify the Merkle root
  * Describe example tree update
  * Reduce to metadata (hashes & directions) and explain verification in
    formulae
  * Describe time and space complexity

## How to add and delete leaves and rebalance Merkle tree?


## Conclusion

In conclusion, we can update the Merkle tree for deposits and withdrawals
without requiring ZK proofs, but still allowing the L1 to verify the execution
occured appropriately. This simplifies some of the design of Kairos V0.1, as can
be seen in its specification.

# Old writings

Figures: "merkle-tree.svg" & "merkle-tree-updated.svg"
caption: "How to update a single leaf of a Merkle tree"

Let us look at @merkle-tree-update-figure-algorithm as an example of a
single-leaf Merkle tree update. As we can see, the datum D2 is updated to D2'.
As a result, H2, A1 and R each get updated. The deposit transaction itself will
include by necessity D2, D2', R and R', in order to provide the smart contract
with all the information necessary in order to execute the right processes. In
addition, the smart contract must verify that changing D2 to D2' does indeed
lead to the update of the Merkle tree from root R to root R'. Note now that in
order to verify this claim, we don't require the entire Merkle tree. Rather, all
we need are values H1 and A2 and the directionality (i.e. the fact that H1 is to
the left of H2, whereas A2 is to the right of A1, in the Merkle tree). Hence,
the required metadata is
$ {
  hashes: [(H1, Left), (A2, Right)],
  root: R'
}$

Given this metadata, we can now check that indeed for

$ "H2" = "hash"("D2"), "A1" = "hash"("H1", "H2") $
$ "H2'" = "hash"("D2'"), "A1'" = "hash"("H1", "H2'") $

it is true that
$ R = "hash"("A1", "A2"), "R'" = "hash"("A1'", "A2"). $

For a general balanced Merkle tree with $N$ leaves, this requires $log^2(N)$
hashes with their directionality, and the new Merkle root, to be passed to the
Validium smart contract in order to allow for verification.

Note: This should be implemented and tested as well for cases where a leaf must
be added/removed, rather than updated.



