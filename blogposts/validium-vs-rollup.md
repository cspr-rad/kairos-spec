== Validium vs. Rollup

As mentioned in the introduction, a ZK rollup is an L2 solution where the state is stored on the L1, while state updates are performed by the L2. A ZK proof, proving that such a state update was performed correctly, is then posted along with the new state on L1. A ZK Validium is similar to a ZK rollup except in that the whole state isn't posted to the L1, but rather a hash of the state. This requires significantly less data resources on L1, and therefore allows further scaling.

We are attempting to create an L2 solution which can scale up to 10,000 transactions per second. However, these transactions need to be independent. The reason for that is that dependent transactions require latter transaction to be aware of the state resulting from the prior transaction. Note: the state is a Merkle root of the account balances. Given restrictions such as the time it takes to sign a transaction and send messages around constrained by the speed of light, one is not quick enough to query the prior state. Therefore, in order to reach 10,000 transactions per second you need at least 20,000 people using the L2. This requires 20,000 people's L2 account balances to be stored within the L1 smart contract. However, this amount of data supercedes Casper L1's data limits. In conclusion, any L2 ZK solution on top of Casper must be a Validium.



