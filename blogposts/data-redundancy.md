# Data redundancy

Due to the nature of validiums, transaction data will be stored off-chain. To ensure interactions can be proven and verified at any given time by anyone, data needs to be available read-only publicly through an API. To reduce the complexity of the project, the data will be stored by a centralized server that can be trusted. Writing and mutating data should only be possible by selected trusted instances/machines. The storage must be persistent and reliable, i.e. there must be redundancies built-in to avoid data loss.

Because losing the Validium state would lead to a loss of all the funds held by the Validium, there needs to be an appropriate amount of redundancy of the stored data. To meet this requirement, we decided rely on PostgreSQL's streaming replication feature (physical replication). The streaming replication feature comes with two crucial benefits we can make use of:
- Fail-over: Meaning that when the primary server fails, one of the replicating standby servers can take over the role of the primary
- Read-only load balancing: Read-only queries can be distributed among several servers

By configuring the streaming replication to be synchronous, we can additionally achieve reliable freshness of the data across all servers. Moreover, it makes the cluster more resilient if the primary server fails after updating. In an asynchronous setting, data could be written to the primary server, which could afterwards fail before sending the update to the standby server, leading to loss of data. In a synchronous setting, the update to the primary server would fail and require a retry until the update gets replicated across all instances.

The number of standby servers can be arbitrarily increased or decreased. For version 0.1 we decided to use one primary server and two replicating standby servers.

Naively, we might want to consider building a failsafe into the Validium smart contract in case the Validium's state gets lost. After all, such a situation would be disasterous. However, building a failsafe would itself create risk and complexity. Therefore, we opt to focus on building data redundancy as mentioned above, including measures such having the three servers spread out geographically.

// In deploying the storage, we must
// - Deploy to three servers
// - Make sure that if one server goes down, another one is picked as master and can take over temporarily
// - If a server comes back up, it must get synced with the others automatically
// - Keep the three servers geographically spread out, i.e. located in three different countries.

We should be clear about when to write the Validium state to the dB: Each L2 Tx
should be written to an "in progress" table as it comes in. Once the batch proof
is confirmed, the associated "in progress" L2 Txs are written to an "archive" L2
Txs table, and the batch proof to an "archive" batch proof table. This way, all
data can be backed up appropriately (data redundancy) and nothing is too
memory-dependent.



