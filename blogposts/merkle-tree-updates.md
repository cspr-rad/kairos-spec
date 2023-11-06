# Merkle trees: How to update without a zero-knowledge proof?

Transfer transactions don't have a Merkle tree update themselves. Rather, this
duty is taken on by the batch proof. The main reason for this is that we want to
avoid transfers from depending on the Merkle root, requiring each transfer in
progress to be recreated and resigned anytime a deposit or withdrawal is posted
on L1. On the other hand, deposit and withdrawal transaction do require the
Merkle tree to be updated. Note that these transactions only change one of the
leafs. Therefore, in order to verify whether the old Merkle root has been
appropriately transformed into the new Merkle root, all we need is the leaves
which the updated leaf interacts with.

#figure(
  grid(
    columns: 2,
    image("merkle-tree.svg", width: 80%),
    image("merkle-tree-updated.svg", width: 80%)
  ),
  caption: [
    How to update a single leaf of a Merkle tree
  ],
) <merkle-tree-update-figure-algorithm>

Let us look at @merkle-tree-update-figure-algorithm as an example of a
single-leaf Merkle tree update. As we can see, the datum D2 is updated to D2'.
As a result, H2, A1 and R each get updated. The deposit transaction itself will
include by necessity D2, D2', R and R', in order to provide the smart contract
with all the information necessary in order to execute the right processes. In
addition, the smart contract must verify that changing D2 to D2' does indeed
lead to the update of the Merkle tree from root R to root R'. Note now that in
order to verify this claim, we don't require the entire Merkle tree. Rather, all
we need are values H1 and A2 and the directionality (i.e. the fact that H1 is to
the left of H2, whereas A2 is to the right of A1, in the Merkle tree). Given
these parameters, we can now check that indeed for

$ "H2" = "hash"("D2"), "A1" = "hash"("H1", "H2") $
$ "H2'" = "hash"("D2'"), "A1'" = "hash"("H1", "H2'") $

it is true that
$ R = "hash"("A1", "A2"), "R'" = "hash"("A1'", "A2"). $

For a general balanced Merkle tree with $N$ leaves, this requires $log^2(N)$
hashes, each with their directionality, to be passed along to the Validium smart
contract, to allow the verification.

Note: This should be implemented and tested as well for cases where a leaf must
be added/removed, rather than updated.



