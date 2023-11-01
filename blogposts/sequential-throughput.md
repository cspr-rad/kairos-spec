== Sequential throughput

In this section, we want to make a quick note about a fundamental restriction of L2 scaling solutions. Imagine you and I both want to submit a swap on a DEX, and you come in first. My transaction thus dependents on the state that results from your swap. There are now two options:
+ I am aware of your output state. In this case, you have created, signed and submitted your transaction to the L2 server. I then pull your output state from the L2 server, construct, sign and submit my transaction. Given limitations such as how long it takes to sign a transaction and to send data back and forth to the server, this setup leads to a maximal sequential throughput #footnote[Sequential throughput is defined by the number of transactions which can be posted to the L2 where each transaction depends on the output of the former.] of around 1 Tx/s.
+ I am not aware of your output state. In this case, I have to construct a L2 transaction and sign it without being fully aware of its effects yet. In the example of the DEX swaps, I will sign a transaction which does not fully determine how many tokens I will receive back from the DEX, thereby allowing for sandwich attacks and the like. Finally, not mentioning the full state a given L2 transaction depends on in this transaction, leads to the problem of L2 transaction uniqueness: How can you assure that the DEX swap you just signed, won't be executed twice by the L2 server?

Our solution is to keep all L2 transactions rolled up into the same L1 transaction independent of one another, to avoid such complications. In making this decision, we restrict the sequential throughput of your system.



