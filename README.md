# Paxos

[![test](https://github.com/Arissira7/Paxos/actions/workflows/test.yml/badge.svg)](https://github.com/Arissira7/Paxos/actions/workflows/test.yml)
[![golangci-lint](https://github.com/Arissira7/Paxos/actions/workflows/golangci-lint.yml/badge.svg)](https://github.com/Arissira7/Paxos/actions/workflows/golangci-lint.yml)

A simple implementation of a distributed system based on the Paxos consensus algorithm.

## Core Concepts

### Paxos Roles

- **Proposer**: Proposes values and attempts to get them accepted by the cluster
- **Acceptor**: Receives proposals and votes on them
- **Quorum**: Minimum number of nodes required to reach consensus (n/2 + 1)

### Key Data Structures

| Structure | Description |
|-----------|-------------|
| `BallotNum` | Ballot number, composed of an incrementing sequence number and proposer ID |
| `PaxosInstanceId` | Paxos instance identifier, containing Key and Version |
| `Value` | Stored value (currently int64 type) |
| `Proposer` | Proposer state and RPC request structures |
| `Acceptor` | Acceptor state and RPC response structures |

## Protocol Flow

### Phase 1 (Prepare)
1. Proposer generates a new ballot number
2. Sends Prepare requests to all Acceptors
3. Acceptor promises not to accept any proposal with a number less than its `LastBal`
4. If a quorum of responses is received, return the highest voted value

### Phase 2 (Accept)
1. Proposer selects a value based on Phase 1 results (its own value or an already accepted value)
2. Sends Accept requests to all Acceptors
3. If a quorum of confirmations is received, the value is safely accepted
