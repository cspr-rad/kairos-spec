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

ADD FIGURE 2: "merkle-tree.svg"

Digging into the specifics, a Merkle tree is quite simple to construct. You
start with a dataset in the form of a list of data points. Each data point is
turned into a bytestring and hashed. To create each next level of the tree,
hashes are paired up, added together and hashed again. The final resulting node,
i.e. the top of the tree, is the Merkle root.

## How to update without ZK?

Let us start by noting that deposits and withdrawals only change one leaf.
Therefore, not the entire Merkle tree is affected, but only the hashes relate to
this one leaf. Let us look at figure 2 for an example. As we can see here,
computing the new Merkle root exclusively requires the values of A1' and A2,
which themselves require H1 and D2'.

ADD FIGURE 2: "merkle-tree.svg" & "merkle-tree-updated.svg"
caption: "How to update a single leaf of a Merkle tree"

The only thing left to note, is that we can simplify the aim from
> prove that the Merkle tree update was executed legitimately"
to
> prove that there is a Merkle tree with root R and leaf D2 which transforms
> into a Merkle root with root R' when replacing leaf D2 by D2'.

As it turns out, this is a much simpler aim. In particular, we now see that all
the values in the Merkle tree are irrelevant to this aim except for the ones
mentioned previously: D2, D2', H1 and A2. Given these values, we can then
compute

$ "H2" = "hash"("D2"), "A1" = "hash"("H1", "H2") $
$ "H2'" = "hash"("D2'"), "A1'" = "hash"("H1", "H2'") $

and verify that, indeed,
$ R = "hash"("A1", "A2"), "R'" = "hash"("A1'", "A2"). $

This proves that the claim is correct, i.e. that there is a Merkle tree with
root R and leaf D2 which transforms into a Merkle tree with root R' when D2 is
replaced by D2'.

Practically speaking, this means that deposits and withdrawals can stay away
from the world of ZK and instead include the following metadata:
$ { [(H1, Left), (A2, Right)], D2}. $
Here, the `Left` refers to the fact that `H1` is to the left of `H2` and `H2'`.
Given this metadata, the L1 smart contract can then compute the new Merkle root
R' and update its state, since it has access to the difference between D2' and
D2 (i.e. the amount of money deposited in the transaction) and the old Merkle
root R (from its own state.

As you can see, both the time and space complexity of this verification are
`O(log_2(N))`, where `N` is the number of elements in the data set. The only
assumption made here is that the Merkle tree is balanced, which will be
discussed in a separate blogpost.

## Conclusion

In conclusion, we can update the Merkle tree for deposits and withdrawals
without requiring ZK proofs, but still allowing the L1 to verify the execution
occured appropriately. This simplifies some of the design of Kairos V0.1, as can
be seen in its specification.



