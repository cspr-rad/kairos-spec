# KAIROS - A zk-validium for the Casper Blockchain

- https://ethereum.org/en/developers/docs/scaling/validium/

## Motivation

As an intermediate step towards building a rollup using zero-knowledge proofs for ACTUS contracts, the goal of this project - a zero-knowledge validium, is to explore the required changes that need to be made on the Casper node in order to create/ validate zero-knowledge proofs. Moreover the size and complexity of this project does not only make it optimal to get a better understanding of the problem of bringing zero-knowledge into production, but also allows the team to work and grow together by building a production-grade solution.

A zero-knowledge validium is a layer 2 scaling solution which compared to a zero-knowledge rollup moves the data availability and computation off the chain.

## Goal Definition

A user of the validium will be able to deposit, withdraw and transfer CSPR token. In the following sections we will discuss the mandatory-, optional-, and delimination criteria we require for each of the aforementioned interactions.

### Mandatory Criteria

#### Deposit

A user should be able to deposit CSPR token from the Casper chain to his validium account at any given time through a web user interface (UI), or through a command-line-interface (CLI).

#### Withdraw

A user should be able to withdraw CSPR token from his account to the Casper chain at any given time through a web UI, or through the CLI. This interaction should be made possible without the approval of the validium operator ([see](https://ethereum.org/en/developers/docs/scaling/validium/#deposits-and-withdrawals))

#### Transfer

A user should be able to transfer CSPR token from his validium account to another users validium account at any given time through a web UI, or through the CLI.

#### Account Balance

A user should be able to query its validium account balance of available CSPR token at any given time through a web UI, or through the CLI.

#### Verification

At any given time anyone should be able to verify deposits, withdrawals, or transactions. This should be possible through a web UI, the CLI, or through an application-programming-interface (API) i.e. a machine-readable way.

#### Data Availability/ Storage

Due to the nature of validiums, transaction data will be stored off-chain. To ensure that deposit, withdraw, and transfer interactions can be proven and verified at any given time by anyone, data needs to be available read-only publicly at any given time. To reduce the complexity of the project, this data will be stored by a centralized server that can be trusted. Writing and mutating data should only be possible by selected trusted instances/ machines. Moreover access to the transaction data should be available through an API.

### Optional Criteria

#### Account Balance

TODO discuss whether this is actually needed
At any given time a user should be able to see all the previous transactions that involve its account.

## Product Use

### Area of Application

The product allows users to benefit from faster and cheaper transactions on the Casper chain.

### Target Group

The target groups are unexperienced and experienced blockchain users.

### Operating conditions

Operation of the software will be on dedicated poweful machines.

## Product Environment

The end product will be a common client-server application.

### Software

- The server host-machine will require a NixOS installation.

- The CLI-client should run on any Linux distribution.

- The UI-client should run on any modern web-browser with JavaScript enabled.

### Hardware

- The server host-machine will need a powerful CPU and depending on the zero-knowledge prooving system a powerful GPU, if it supports GPU acceleration.

- The server host-machine, CLI-/UI-clients will need a working internet connection.

## Functional Requirements

### Base Functionality

- [tag:FRB00] When opening the web-UI it waits for the user's inputs

### Deposit

- [tag:FRD00] Depositing an amount of `CSPR tokens`, where `CSPR tokens > 0` should be accounted correctly
- [tag:FRD01] Depositing an amount of `CSPR tokens`, where `CSPR tokens <= 0` should not be executed at all

### Withdraw

- [tag:FRW00] Withdrawing an amount of `CSPR tokens`, where `users validium account balance >= CSPR tokens > 0` should be accounted correctly
- [tag:FRW01] Withdrawing an amount of `CSPR tokens`, where `CSPR tokens <= 0` should not be executed at all
- [tag:FRW02] Withdrawing an amount of `CSPR tokens`, where `CSPR tokens > users validium account balance` should not be possible
- [tag:FRW03] Withdrawing a valid amount from the users validium account should be possible without the intermediary operator of the validium.

### Transfer

- [tag:FRT00] Transfering an amount of `CSPR tokens`, where `users validium account balance >= CSPR tokens > 0` should be accounted correctly
- [tag:FRT01] Transfering an amount of `CSPR tokens`, where `CSPR tokens =< 0` should not be executed at all
- [tag:FRT02] Transfering an amount of `CSPR tokens`, where `CSPR tokens > users validium account` balance should not be possible
- [tag:FRT03] Transfering a valid amount to a user that does not have a registered validium account yet should be possible.

### Account Balance

- [tag:FRA00] The user should be able to see his account balance immediately when it's queried (either through the CLI or web-UI)
- [tag:FRA01] The user should be able to see all the past transactions involving its account (TODO discuss whether we actually need this for this MVP)

### Verification

- [tag:FRV00] Anyone should be able to verify proofs of the validiums state changes caused by deposit/ withdraw/ transfer interactions
- [tag:FRV01] Anyone should be able to verify proofs of the validiums state changes caused by deposit/ withdraw/ transfer interactions at any given time

### Data Availability/ Storage
- [tag:FRD00] Data should be served read-only to anyone
- [tag:FRD01] Data should be available at any given time
- [tag:FRD02] Data should be written by known, verified entities only
- [tag:FRD03] Data should be written immediately after the successful verification of correct deposit/ withdraw/ transfer interactions

## Non-functional Requirements

### Base Functionality

- [tag:NRB100] The application should not leak any private or sensitive informations like private keys

## Data

## Use-cases

## User Interface/ User Experience

## E2E-tests

## Architecture

## Architecture Components

## Component Interactions (Sequence Diagrams)

### Deposit

### Withdraw

### Transfer
