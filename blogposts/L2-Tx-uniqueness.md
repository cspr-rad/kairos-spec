# Ensuring L2 transaction uniqueness

When designing an L2 on top of a blockchain, one important consideration is to
ensure L2 transaction uniqueness. This means that any L2 transaction which is
posted to an L2 node, cannot be read later and resubmitted without the original
signees' approval. For example, if person A pays person B $50, we must ensure
that person B cannot reuse the corresponding L2 transaction in order to receive
a second $50.

The solution to this problem is to add some data to each L2 transaction which
confirms the uniqueness.

In order to confirm that the right people sign off on the data odded to the L2
transaction, this data is included in the signatures, i.e. it is included in the
bytestring to be signed.

We must ensure that each L2 transaction which is posted to the L2 server, can only be used on the L1 once. This can be accomplished in many ways, which generally fall into two categories:
+ Add something to the L2 transaction about the state of the world.
+ Add something to the L2 transaction about the state of the Validium.

The former option is difficut to accomplish, as there are few real-world concepts which translate into the blockchain world easily. For example, naively speaking, time would be a great option: What if we add a timestamp to each L2 transaction? There are two problems with a suggestion like this:
- Time is a very complex concept in the blockchain world. Which `currentTime` should the timestamp be compared to by a casper-node? There is no well-defined time at which a block is added to the blockchain, as each node does so at a different time.
- We must ensure that the bounds on the timestamp are loose enough such that no transactions meant to go into a given batch proof are refused, while never allowing a transaction which was added to the last batch proof to be added to a new one. This requirement of having no mistakes on either end, is so stringent that timestamps don't offer enough information.

The alternative is to add a piece of information X about the Validium's state to each L2 transaction. The batch proof can then include that piece of information as a public input, and check that all L2 transactions have that same public input. However, we must make sure that X is unique, meaning that even if the Validium reverts back to an old state, no old L2 transactions can be reused against the will of the person who signed them. Therefore, we decided to make use of [logical time](https://en.wikipedia.org/wiki/Logical_clock) analogous to [lamport timestamps](https://en.wikipedia.org/wiki/Lamport_timestamp). Meaning that X will be a counter, initialized at 0 and increasing by 1 every time a batch proof is posted to the L1. As such, the batch proof and Validium smart contract can verify perfectly whether a given L2 transaction fits into its rollup, while also providing a simple and clear user interface.

# Two phases of the server

The L2 server accumulates a queue of L2 transactions which can be posted into the same batch proof. Based upon a number of limits #footnote[Two examples of such limits would be the number of transactions posted into one batch proof, and the time window which is compiled into one batch prof. The latter limit is necessary in order to allow a sensible sequential throughput as well.] the server will start computing a batch proof based on its current queue. Any new transactions must now set their Validium counter to one higher than before, in order to fit into the next batch proof rather than the current one. This will be communicated by the L2 server through a clear error.



