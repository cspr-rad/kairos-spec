# Centralized L2

Decentralized L2s require many complex problems to be resolved. For example,
everyone involved in the L2 must get paid, including the storers and provers. In
addition, we must avoid any trust assumptions on individual players, making it
difficult to provide reasonable storage options. Instead, this requires a
complex solution such as Starknet's Data Availability Committee. Each of these
issues takes time to resolve, and doing all this within the project's version
0.1 is likely to prevent the project from ever launching into production.
Therefore, a centralized L2 ran by the Casper Association is an attractive
initial solution. This poses the question, what are the dangers of centralized
L2s?
- Denial of service: The L2 server could block any user from using the system
- Loss of trust in L2: The L2 server could blacklist someone, thereby locking in
  their funds. This opens up attacks based on blackmail.
- Loss of data: What if the L2 server loses the data? Then we can no longer
  confirm who owns what, and the L2 system dies a painful death.

Unfortunately there is nothing we can do about the L2 denying you service within
a centralized L2 setting. If the L2 decides to blacklist your public key, you
will not have access to its functionality. Of course we should keep in mind two
key things here:
+ Withdrawing your current funds from the Validium should always be possible,
  even without permission from the L2.
+ The centralized L2 will be ran by the Casper Association, which has a
  significant incentive to aid and stimulate the Casper ecosystem to offer equal
  access to all.

As mentioned before, we will design the system in such a way that withdrawing
validium funds is possible without L2 approval. This eliminates the second
danger associated with centralized L2s ZKVs, requiring exclusively that you have
access to the current Validium state. Without such access, the L2 would be
entirely dead, as no deposits or withdrawals can be made without it.

Finally, what if the L2 loses its data? The Casper Association has a very strong
incentive to prevent this, since the entire project would die permanently if
this occurs. Therefore, we will build the L2 service in such a way as to include
the necessary redundancy, as mentioned above.



