#let title = [
  Test Plan
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
        Marijan Petricevic, Mark Greenslade, Matthew Doty, Avi Dessauer, Jonas Pauli,
        Andrzej Bronski, Quinn Dougherty
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
achieved by leveraging zero-knowledge proofs. To verify the functional
compliance of each specified interaction with Kairos, namely: deposit, transfer,
withdraw, and querying the state; this documents goal is to define test
objectives and to describe tests on different levels of the system using
different testing types. Since the L2 will ideally increase the throughput of
transactions, one has to expect that the nodes processing requests by users will
be required to deal with a huge amount of traffic. This means it's not only
important to ensure the correct execution of transactions and a correct
representation of the on-chain state through a data availability layer, but it's
also important to test the non-functional compliance of the system under normal
and abnormal conditions to verify its stability and to validate its capacity.

= Objectives
This seaction describes high-level objectives (no particular order) we plan to
reach with our testing efforts. We provide a short definition of each objective
and a reason why it is relevant for the system. In the next section "Risk
Analysis" (@risk-analysis) we will go into more detail on what risks are
associated with every single objective, justifying why the objective is desired.
Both the objectives and the risk accessment together will serve as a basis for
picking the respective test approaches.

== Correctness
Correctness is a self explanatory and essential objective that needs to be met
before it makes sense to ensure all the other objectives. Moreover, correctness
on one level of our system affects correctness on other levels of our system,
thus we need to test for correctness on every level of our system. This
additionally has the benefit that it makes it easy to isolate and detect
problems throughout the development cycle.

== Feature Complete
We want to make sure that the specified requirements and features of our
application are all implemented. Missing requirements or features could leave
users of our system in a irrecoverable state and potentially cause financial
damage.

== Always Deployable
The system should be in an always deployable state. In the beginning of the
development cycle this will ensure that the integration of all our systems
components is working together as intended and it allows us to identify
deployment issues early on. Later in the development cycle it will enable us to
deploy potentially important fixes or improvements to the system very fast.

== Availability
The system should be always available. Unavailability of our system could cause
financial damage to users, as well as trust issues towards the operators.

== Reliability
We want to ensure that our system operates consistently and reliably under
**normal and expected** conditions.

== Resiliency
We want to ensure that our system operates consistently and reliably under
potentially **abnormal and unexpected** conditions.

== Efficiency
Our system should use it's resources efficiently with respect to the complexity
of the executed task. For a user a more efficient use of resources has two
implications:
1. It improves the experience as the system should be more responsive and fast
2. With respect to zero-knowledge proofs it benefits our users by enabling the
  operator to charge less usage fees

It has also implications on other objectives listed here like reliability,
resiliency, performance, and scalability.

== Performance
Our system should be fast. This will improve the user experience of the system.

== Portability
Our system should be installable and usable on many different operating systems,
hardware platforms or devices. The service side should be installable and usable
in any environment whether in the cloud or on a self-hosted server. This will
allow the operator to target a bigger user audience, and make the operator
independent from the available/ chosen infrastructure.

== Usability
Our system should provide a good user experience for the targeted audience. This
builds more confidence from users towards the operator and will help with a
faster user adoption.

== Scalability
Our system should be scalable. This will enable the operator to increase/
decrease the amount of infrastructure with respect to the demand.

== Security
Our system should be secure. An insecure system could cause financial damage
either for the users or the operator.

== Operability
Our system should be easy to operate by system administrators. Tasks like
deploying, upgrading, migrating, and/or recovering from failures of our system
should be as easy as possible. This enables the operator to initially attract,
hire and keep good staff, and it will enable the staff to do the aforementioned
tasks fast and confidently.

== Maintainability
Our system should be well documented, easy to extend, easily fixable. Developers
should be able to be onboarded quickly. This enables the operator to attract,
hire and keep good staff. The staff will be able to be productive on the project
very fast.

== Compliance with Regulations
As our system will provide financial services we will want our system to comply
with eventual regulations. Not fullfilling this objective will result in
immediate financial loss for the operator.

= Risk Analysis <risk-analysis>
In this chapter we will provide a list of specific product risks that could be
caused by a possible failure or defect. Each risk is associated with one or more
of the previously discussed objectives of our testing efforts. The list also
gives an estimation of how likely it is that a risk will occur and how great the
respective impact could be. Given these two estimates, a risk
priority number is computed and assigned. Additionally, the list provides references to mitigation and contingency
approaches. Most of these mitigation approaches will be covered by tests, processes,
and technologies we use, which will be discussed in much more detail in the Testing
Levels section (@testing-levels).

The likelihood and impact risk level estimation is a number in the range between
1 and 5, where:

// typstfmt::off
#table(
  columns: 2,
  [*Number*], [*Meaning*],
  [1], [Very Low],
  [2], [Low],
  [3], [Medium],
  [4], [High],
  [5], [Very High],
)
// typstfmt::on

The risk priority is the result of the multiplication of the estimated
likelihood of the risk occuring and the impact should the defect manifest.

// typstfmt::off
#page(flipped: true)[
#table(
  columns: 6,
  [*Product Risk*], [*Likelihood*], [*Impact*], [*Risk Priority*], [*Mitigation*], [*Contingency*],
  [*Correctness*], [], [], [], [], [],
  [Incorrect or wrong computations could cause financial damage for users/operator, moreover cause long-term loss of trust and confidence in the operator], [5], [5], [25], [Unit testing], [Administrator to undo changes???],

  [*Always Deployable*], [], [], [], [], [],
  [Security fixes can't be deployed to production right away. Causes a long-term loss of trust and confidence in the operator/system], [5], [5], [25], [TODO], [TODO],
  [Improvements/ new features can't be deployed to production when finished. Causes potential loss of market-share because of competitors providing new features/improvements faster], [5], [5], [25], [TODO], [TODO],
  [Developers have no feedback whether their code is compatible with the remaining system. Causes a longer development cycle.], [5], [5], [25], [TODO], [TODO],

  [*Availability*], [], [], [], [], [],
  [Users are not able to perform deposits, transfers, withdrawals, and/or query the Data Availability layer. Causes financial damage for users/operator, moreover causes long-term loss of trust and confidence in the operator/system.], [5], [5], [25], [Monitoring], [TODO],

  [*Reliability*], [], [], [], [], [],
  [The system is not able to respond to a normal/expected amount of concurrent interactions. Causes users to lose trust and confidence in the system], [5], [5], [25], [TODO], [TODO],

  [*Resiliency*], [], [], [], [], [],
  [The system is not able to respond to a abnormal/unexpected amount of concurrent interactions. Causes users to lose trust and confidence in the system], [5], [5], [25], [TODO], [TODO],
  [A DDOS attack by adversaries could take the system down, causing financial damage to the operator and a loss of trust and confidence in the operator/system], [5], [5], [25], [TODO], [],

  [*Efficiency*], [], [], [], [], [],
  [Fees could be very high because of inefficient use of resources in the ZK context. Causes a loss of market share because competitors are cheaper], [3], [5], [15], [Benchmarking], [TODO],

  [*Performance*], [], [], [], [], [],

  [*Portability*], [], [], [], [], [],
  [Operator is unable to serve a broad audience. Causes a loss of market share to competitors.], [5], [5], [25], [TODO], [TODO],
  [Operator is unable to run the system on different types of infrastructure. Increases the dependency of the operator on a specific type of infrastructure.], [5], [5], [25], [TODO], [TODO],

  [*Usability*], [], [], [], [], [],
  [Users don't understand or find the UX unusable. Causes a loss of market share to competitors.], [5], [5], [25], [TODO], [TODO],
  [Third party applications have a hard time extending the system. Causes a loss of market share to competitors because users like a specific extension.], [5], [5], [25], [TODO], [TODO],

  [*Scalability*], [], [], [], [], [],
  [Operator is unable to serve a potentially high demand], [5], [5], [25], [TODO], [TODO],

  [*Security*], [], [], [], [], [],
  [Financial damage for the user/operator caused by adversaries stealing funds], [5], [5], [25], [TODO], [],
  [Users private data being leaked or stolen. Causes a loss of trust and confidence in the operator/system], [5], [5], [25], [TODO], [],

  [*Operability*], [], [], [], [], [],
  [System admins struggle with deploying the system], [5], [5], [25], [TODO], [TODO],
  [System admins struggle with upgrading the system], [5], [5], [25], [TODO], [TODO],
  [System admins struggle with migrating the system], [5], [5], [25], [TODO], [TODO],
  [System admins struggle with recovering after a defect occured in the system], [5], [5], [25], [TODO], [TODO],
  [Difficult to find staff if administering the system is frustrating], [5], [5], [25], [TODO], [TODO],

  [*Maintainability*], [], [], [], [], [],
  [Higher costs for the operator to fix problems with/evolve the system], [5], [5], [25], [TODO], [TODO],
  [Longer development cycles required to fix problems with/evolve the system], [5], [5], [25], [TODO], [TODO],
  [Difficulty to find staff if developent is frustrating], [5], [5], [25], [TODO], [TODO],

  [*Compliance with Reagulators*], [], [], [], [], [],
  [Regulators ban the use of the system because of violated regulations], [5], [5], [25], [TODO], [TODO],
)
]
// typstfmt::on

= Testing Levels <testing-levels>
== Component Testing
Verifies the functioning, correctness, and compliance to requirements, of code
that can be tested in isolation.

=== Test Objects
Test the smallest thing that can be tested on its own: functions, modules, data
structures, database models. The components that should be tested will most
likely occur in the lower-levels of the system.

=== Test Responsibility
The author of the module is required to write the respective tests.

=== Requirements/ Preconditions
- When possible, low-level components should be implemented in a way to do only
  one thing at a time such that they can be tested in isolation.
- When possible, low-level components/ functions should be pure i.e. not depend on
  or modify global or external state. common cases.
- It should be possible to run these tests locally fast.
- It should be possible to randomly generate inputs data
- Ideally the component should be designed in a way such that a relationship
  between input and output data can be expressed.

=== Functional Tests
This section describes what tests will be conducted in order to verify the
correctness and evaluate the compliance with functional requirements.

==== Unit Tests
Verify the the components correctness by testing its behavior, contract and
invariants for the most common cases.

The tests should provide confidence that the following defects are eliminated:
- incorrect functionality
- data flow problems
- incorrect logic

==== Property Tests
Test specific input-output relationships of a component using a large amount of
randomized and border-case data.

=== Non-functional Tests
Measure the total execution time. Measure the memory consumption.

=== White-box Tests
The code coverage for each component under test should be at least 9X%.

=== Change Related Tests
Every unit or property test will be run automatically at latest in CI
(regression test).

=== Technology
Use Rusts built-in test framework. Property test library TBD. These tests should
be placed in a `test` module located in the same file of the components
definition.

// ******************************************************************************

== Component Integration Testing
Tests the interaction/ interfaces between components.

=== Test Objects
Test components like functions, modules, data structures that integrate one or
more component.

=== Test Responsibility
The author of the module is required to write the respective tests.

=== Requirements
- When possible, components should be implemented in a way to serve only one
  purpose at a time.
- When possible, components/ functions should be pure i.e. not depend on or modify
  global or external state.
- It has to be possible to run these tests locally.
- The speed of execution of these tests should be proportional to the complexity.
  i.e. the more complex, the more execution time is acceptable.

=== Functional Tests
This section describes what tests will be conducted in order to verify the
correctness and evaluate the compliance with functional requirements.

==== Incremental Integration Tests
Verify whether the components integrates other components correctly by testing
its behavior, contract and invariants for the most common cases.

Incremental integration testing has the advantage that defects can be found
early and be isolated easier.

The tests should provide confidence that the following defects are eliminated:
- incorrect data, missing data, or incorrect data encoding
- incorrect sequencing or timing of interface calls
- interface missmatch because of hidden invariants or contracts
- failures in communication between components
- unhandled or improperly handled failures in communication between components
- incorrect assumptions about the meaning, units or boundaries of the data passed
  between components

==== Property Tests
Test specific input-output relationships of a component using a large amount of
randomized and border-case data for components that integrate multiple
components.

=== Non-functional Tests
Measure the total execution time. Measure the memory consumption.

==== Attack Tests
This applies specifically to on-chain contracts. Its required to test the most
common attack scenarios on a contract.

=== White-box Tests
The code coverage for each component under test should be at least 9X%.

=== Change Related Tests
Every integration or property test will be run automatically at latest in CI
(regression test).

=== Technology
Use Rusts built-in test framework. Property test library TBD. These tests should
be placed in a `test` module located in the same file of the components
definition.

// ******************************************************************************

== System Integration Testing
Test components like functions, modules, data structures that integrate one or
more external systems.

It is important to recognize that testing components that depend on external
systems should be tested against their production interface/ instance. This
gives true confidence about a test result and is a basis to be able to reason
about it. Only when tested against production system and getting a positive
test-result we can be sure that the interface of the system is compatible with
our component and that the runtime peculiarities are handled correctly by our
component.

=== Test Objects
Test components like functions, modules, data structures that integrate one or
more external systems.

In Kairos there are four integrations to external systems:
- The Kairos CLI used to interact with the Kairos server.
- The Kairos server reading/ updating the account-balances state on the L1, or
  forwarding deploys and waiting for their execution on-chain.
- The Kairos server using the RISC0 VM to create a batch-proof.
- The Kairos server using a data-store in order to provide data availability.

=== Test Responsibility
The author of the module is required to write the respective tests.

=== Requirements
- When possible, components should be implemented in a way to serve only one
  purpose at a time.
- It has to be possible to run these tests locally.
- The speed of execution of these tests should be proportional to the complexity.
  i.e. the more complex, the more execution time is acceptable.
- Functions that depend on external components should be tested against production
  instances of these external components. For Kairos we will need:
  - A clean state L1 network that can be launched in an automated manner, per
    test-case
  - A clean state data-store that can be launched in an automated manner, per
    test-case
  - A clean state Kairos server that can be launched in an automated manner, per
    test-case

=== Functional Tests
This section describes what tests will be conducted in order to verify the
correctness and evaluate the compliance with functional requirements.

==== Incremental Integration Tests
Verify whether the components integrates external systems correctly by testing
its behavior, contract and invariants for the most common cases.

Incremental integration testing has the advantage that defects can be found
early and be isolated easier.

The tests should provide confidence that the following defects are eliminated:
- incorrect message structures between systems
- incorrect data, missing data, or incorrect data encoding
- incorrect sequencing or timing of interface calls
- interface missmatch because of hidden invariants or contracts
- failures in communication between systems
- unhandled or improperly handled failures in communication between systems
- incorrect assumptions about the meaning, units or boundaries of the data passed
  between systems

=== Non-functional Tests
Measure the total execution time. Measure the memory consumption.

=== White-box Tests
The code coverage for each component under test should be at least 9X%.

=== Change Related Tests
Every integration test will be run automatically at latest in CI (regression
test).

=== Technology
Use Rusts built-in test framework. These tests should be placed in a dedicated
`test` module in a separate directory.

// ******************************************************************************

== System Testing
This level of testing is concerned with the behavior of the whole system as
defined by the scope of the project. It may include tests based on risk analysis
reports, system, functional or software requirements specifications, business
processes, use-cases or higher level descriptions of system behavior,
interactions with the operating system and system resources. The focus is on
**end-to-end** tasks that the system should perform. The test environment should
correspond to the final production environment as much as possible. This means
that all configurations should be the production configurations.

=== Test Objects
The production-like system and its stack as a whole and the configuration of the
system.

=== Test Responsibility
Since we are going to likely implement these tests using NixOS tests to ensure a
production like environment, someone capable of writing a NixOS test should
write these together with other development team members who have in-depth
knowledge about the aspect of the system that is being tested.

=== Requirements
- The Kairos stack comprised of the CLI, server, data-store, and L1 deployable in
  an automated fashion.
- A way to execute real user scenarios and workflows in an automated fashion.
- It has to be possible to run these tests locally.
- The speed of execution of these tests should be proportional to the complexity.
  i.e. the more complex, the more execution time is acceptable.

=== Functional Tests
This section describes what tests will be conducted in order to verify the
correctness and evaluate the compliance with functional requirements.

=== Smoke Test
Smoke tests verify that the system starts up successfully without crashing, that
the system is reachable, that essential functionality works and that the
integrated external components work too.

They are a first step towards end-to-end tests.

==== End-to-end Tests
End-to-end tests are used to validate real user scenarios and workflows with the
system. For Kairos we want to test that all the user scenarios described in the
requirements document work (deposit, transfer, withdraw, data availability
queries).

The tests should provide confidence that the following defects are eliminated:
- incorrect computations
- incorrect or unexpected system behavior
- incorrect control/data flows within the system
- failure to properly and completely execute end-to-end functional tasks
- failure of the system to work properly in the production environment
- failure of the system to work as described in the documentation/ user manual

=== Non-functional Tests
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

==== Volume Tests/ Stress tests
todo

==== Attack Tests
todo

=== White-box Tests
Coverage by leveraging tagref. We need to match every single tag in the
requirements doc which describes the functional requirements and use cases with
a corresponding system test.

==== Audit Test
Use a tool that audits the dependencies of our project to uncover
vulnerabilities

=== Change Related Tests
Every system test that can be run in CI (NixOS tests) will be run automatically
at latest in CI (regression test)

=== Technology
Use Nix/NixOS to enable a reproducible, easy to deploy system configuration. Use
NixOS tests for tezts that dont require physical hardware to verify the expected
behavior. Use NixOS to automatically provision and deploy physical machines to
perform appropriate tests.

// ******************************************************************************

== Accpetance Testing
=== Functional Tests
=== Non-functional Tests
=== White-box Tests
=== Change Related Tests

/*
===== Load Tests
====== Requirements
- Means to isolate the performance metrics for each individual component of our
  system. For Kairos in the case of total execution time we will need means to m
- A way to deploy the Kairos stack in a virtual cluster in an automated fashion.
- A way to deploy the Kairos stack onto physical hardware in an automated fashion.
- A way to execute a large amount of concurrent real user scenarios and workflows
*/

= Contingency Plans

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

