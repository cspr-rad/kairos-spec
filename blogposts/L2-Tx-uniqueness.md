# Ensuring L2 transaction uniqueness

When designing a ZK-based L2 on top of a blockchain, one important consideration
is to ensure L2 transaction uniqueness. This means that any L2 transaction which
is posted to an L2 node, cannot later b resubmitted without the original
signees' approval. For example, if person A pays person B $50, we must ensure
that person B cannot reuse the corresponding L2 transaction in order to receive
$50 a second time.

The solution to this problem is to add some data to each L2 transaction which
confirms its uniqueness, and to check this piece of data either in the batch
proof or the L1 smart contract. The real question is, what data should be added?
Naively, there are two types of solutions: We can convey information about the
world, or about the state of the L2.

Let us consider passing along some information about the state of the world
first, independent from any blockchain concepts. An example of this would be
adding a timestamp to each L2 transaction. The batch proof can then take as a
public input the timestamp when it is computed, and make sure that the
individual L2 transactions' timestamps fall within a reasonable window from its
own. However, this poses several problems:
- Time is a very complex concept. There are timezones, leap seconds etc.
- Time doesn't translate very well to blockchains. In a decentralized L2, each
  node would have a different timestamp at which it records a given batch proof.
  This might produce some trouble.
- The uniqueness issue is very sensitive. One requirement is that (almost) any
  transaction submitted correctly, would be accepted by the batch proof, to
  avoid having to recompute and resign L2 transactions on a regular basis. On
  the other hand, we also require that not a single L2 transaction can ever be
  resubmitted to a different batch proof. The combination of these two
  requirements means that the verification in the batch proof, based on the
  timestamp of the L2 transaction and the timestamp of the batch proof, can
  almost never be wrong. This is a sufficiently stringent requirement to kill
  the idea of using timestamps.
- These issues apply more generally than only to time: Few real-world concepts
  map neatly enough onto blockchain concepts to be able to use them here in
  enforcing L2 transaction uniqueness.

The other suggestion was to include some information about the L2's state when
submmitting a new L2 transaction. For example, we could use some form of hash of
the L2 state, like a Merkle root in case the data is stored as a Merkle tree.
However, the L2 state is not unique. This means that any data which depends on
the L2 state will also not be unique, potentially leading to trouble. In
addition, the L2 state changes very frequently, whereas anything that goes into
L2 transactions must be slow to change. Imagine each L2 transaction changes the
L2 state in such a way that the next L2 transaction should take into account
(e.g. by including an updated Merkle tree). We would then have to reduce our
parallel transaction throughput to become sequential, as no two L2 transactions
can be computed and submitted independently. For more information, see the
Casper Association blogpost about sequential throughput.

Based on this analysis, we can draw a number of conclusions:
- The data X to be added to the L2 transactions should be dependent on something
  unique, i.e. not the L2 state
- X should not change too frequently, insinuating depending on L1 rather than L2
- X being discrete, as opposed to continuous, would help to make sure that the
  function which determines whether an L2 transaction fits into a given batch
  proof makes no mistakes. This is the problem explained above with timestamps.
- The data should represents something clear and consistent within the
  blockchain world.

This brought us to a new idea: What about [logical
time](https://en.wikipedia.org/wiki/Logical_clock)? We can track L2-L1
interactions using a counter, and use the value of this counter both as part of
the L2 transactions, a public input to the batch proof so the L2 transactions
can be verified, and the L1 smart contract in order to match the batch proof's
claimed counter value with the L1's reality. Such a counter could, for example,
track the number of times the L2 posts a batch proof onto the L1. This provides
an elegant and concise solution to the problem. In the Kairos specification,
this counter is referred to as the Kairos counter.

In order to confirm that the right people sign off on the counter which is
included in a given L2 transaction, the counter is included in the bytestring to
be signed. This prevents anyone from resubmitting old transactions with a new
counter value.

As a sidenote, the Kairos counter system has an important effect on the L2
nodes, namely that they have to verify each L2 transaction comes in with the
correct counter in order to be accepted into the next batch proof to be
computed. This requires an extra endpoint on the L2 nodes in order for users to
query the Kairos counter value they should add to their L2 transactions. In
particular, after a number of seconds S or a number of L2 transactions N, the L2
node must close off the next batch proof's L2 transaction queue to start its
computation, given that batch proof computations cannot easily be added to
iteratively. In addition, if the Kairos counter value of a submitted L2
transaction is incorrect, the L2 node should provide a reasonable error message
explaining the issue.

In conclusion, a new danger must be handled by ZK-based L2s, namely to provide a
mechanism to enforce L2 transactions to be unique in their posting on L1. In
order to accomplish this, we discovered the Kairos counter, and will add this
concept both to the L2 transactions, batch proofs and L1 smart contract.



