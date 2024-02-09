#let title = [
  Test Strategy
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

//test-strategy (what questions)
//- what are the high-level testing objectives
//- what types of testing are in scope
//- what is not in scope, and why
//- what are some risks and mitigations
//- what is the defining point when testing is done (Finish line)
//
//test-plan (how questions)
//- supports the test-strategy it explains how we are going to execute the strategy
//- how will functional testing occur
//- how many cycles of testing will there be
//- how will the performance testing coordinated

= Introduction

Kairos is a layer 2 (L2) zero-knowledge (ZK) rollup built on top of the layer 1
(L1) Casper blockchain. A rollup's goal is to lower transaction costs and to
increase the throughput of the underlying L1. In the case of Kairos, this is
achieved by leveraging zero-knowledge proofs. Since the L2 will ideally increase
the throughput of transactions, one has to expect that the nodes processing
requests by users will be required to deal with a huge amount of traffic. This
means it's not only important to ensure the correct execution of transactions
and a correct representation of the on-chain state through a data availability
layer, but it's also important to test the system under normal and abnormal
conditions to verify its stability and to validate its capacity.

= Objectives

== Correctness
Correctness is a essential objective that needs to be met before it makes sense
ensuring all the other objectives. To not only ensure the correctness of the
whole application but also make it easy to isolate and detect problems
throughout the development cycle, testing is required in every single
abstraction layer of the application.

=== Test Types

==== Unit Tests
Unit tests aim to verify the correctness of the most primitive components/
functions of the applications that usually occur in the lower-levels in the
abstraction hierarchy. They can/ should be utilized for all the components/
functions in our system that do one thing at a time.

It should be possible to run these tests locally and at latest in CI.

===== Requirements
- When possible, low-level components/ functions should be implemented in a way to
  do only one thing at a time such that they can be tested in isolation.
- When possible, low-level components/ functions should be pure i.e. not depend or
  modify global or external state.
- Test the components/ functions behavior, contract and invariants for the most
  common cases.
- It has to be possible to run these tests locally fast.

==== Property Tests
They have a similar granularity to unit tests, and test specific input-output
relationships of a component/function using a large amount of randomized and
border-case data.

It should be possible to run these tests locally and at latest in CI.

===== Requirements
- When possible, low-level components/ functions should be implemented in a way to
  do only one thing at a time such that they can be tested in isolation.
- Input data should be possible to generate, a relationship between input and
  output has to be expressed.
- It has to be possible to run these tests locally fast.

==== Integration Tests
Integration tests should be applied on many levels of the systems. Whenever two
or more components are used together:
- a function that forms an abstraction over `n` low-level functions
- a function depending on a external component like a database
- a function implementing a feature by utilizing several functions and external
  components
an integration test should be written. It is important to recognize that testing
components that depend on external components should be tested against their
real production instance. This allows us to have actual confidence about a test
result and to be able to reason about it. Only when tested against production
components and getting a positive test-result we can be sure that the interface
of the componant is compatible with our component and that the runtime
peculiarities of the external component are handled correctly by our component.

In Kairos there are four integrations to external components:
- The Kairos CLI used to interact with the Kairos server.
- The Kairos server reading/ updating the account-balances state on the L1, or
  forwarding deploys and waiting for their execution on-chain.
- The Kairos server using the RISC0 VM to create a batch-proof.
- The Kairos server using a data-store in order to provide data availability.

It should be possible to run these tests locally and at latest in CI.

===== Requirements
- When possible, lower-level components/ functions should be pure i.e. not depend
  or modify global or external state.
- Functions that depend on external components should try to do only one thing at
  a time.
- Functions that depend on external components should be tested against production
  instances of these external components. For Kairos we will need:
  - A clean state L1 network that can be launched in an automated manner, per
    test-case
  - A clean state data-store that can be launched in an automated manner, per
    test-case
  - A clean state Kairos server that can be launched in an automated manner, per
    test-case
- It has to be possible to run these tests locally.
- The speed of execution of these tests should be proportional to the complexity.
  i.e. the more complex, the more execution time is acceptable.

==== End-to-end Tests
End-to-end tests are used to validate real user scenarios and workflows with the
system. Ideally this system is as close to the production scenario as possible.
This means that all configurations should be the production configurations. For
Kairos we want to test that all the user scenarios described in the requirements
document work.

It should be possible to run these tests locally and at latest in CI.

===== Requirements
- The Kairos stack comprised of the CLI, server, data-store, and L1 deployable in
  an automated fashion.
- A way to execute real user scenarios and workflows in an automated fashion.
- It has to be possible to run these tests locally.
- The speed of execution of these tests should be proportional to the complexity.
  i.e. the more complex, the more execution time is acceptable.

== Always Deployable
Our system should be in an always deployable state.=== Test Types
We can achieve this objective by implementing all the previously mentioned test
types for the correctness objective, if we decide to package our stack with Nix
and configure it using NixOS. However there is a way we can prove deployability
in an isolated way through smoke tests.

==== Smoke test
Smoke tests verify that the system starts up successfully without crashing, that
the system is reachable, that essential functionality works and that the
integrated external components work too.

It should be possible to run these tests locally and at latest in CI, or on a
physical machine.

===== Requirements
- The Kairos stack comprised of the CLI, server, data-store, and L1 deployable in
  an automated fashion.
- It has to be possible to run these tests locally.
- The speed of execution of these tests should be proportional to the complexity.
  i.e. the more complex, the more execution time is acceptable.
- It should be possible to run this test on a real physical machine.

== Reliability
We want to ensure that our system operates consistently and reliably under
normal and expected conditions. We want to

=== Test Types
==== Load Tests
Load tests focus on the consistency and reliability of our system under normal
and anticipated conditions. We want to investigate how multiple (expected
amounts of) users accessing our system concurrently affect our systems total
execution time, response time, throughput and other performance metrics (see
Performance metrics). Moreover, it helps us figure out that upper bound of the
operating capacity and potential bottlenecks of our system. The load tests will
give us more accurate measurements the closer we are to our actual production
scenario.

It should be possible to run these tests locally and at latest in CI, and for
more precise results on physical hardware.

===== Requirements
- Means to isolate the performance metrics for each individual component of our
  system. For Kairos in the case of total execution time we will need means to m
- A way to deploy the Kairos stack in a virtual cluster in an automated fashion.
- A way to deploy the Kairos stack onto physical hardware in an automated fashion.
- A way to execute a large amount of concurrent real user scenarios and workflows
  in an automated fashion.

== Scalability
==== Volume Tests
===== Requirements

== Performance

== Security
=== Test Types
==== Attack Tests
===== Requirements
==== Audit Tests
===== Requirements

== Maintainability
=== Test Types

== Compliance with Regulations
=== Test Types

= Risc Analysis

= Performance Metrics
== Total Execution Time and CPU Time
The time required to execute a given operation and the CPU time of the given
operation. Characteristics:
- linear
- reliable
- repeatable
- easy to measure
- consistent
- independent

== Response time
The amount of time that elapses from when a user submits a request until the
result is returned from the system.

== Throughput
System throughput is a measure of the number of jobs/ operations that are
completed per unit time.

== Speedup and relative change
*Speedup* and *relative change* are useful metrics for comparing systems since
they normalize performance to a common basis. They are often calculated directly
from execution times.

