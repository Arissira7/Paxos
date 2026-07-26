# Paxos

[![test](https://github.com/Arissira7/Paxos/actions/workflows/test.yml/badge.svg)](https://github.com/Arissira7/Paxos/actions/workflows/test.yml)
[![golangci-lint](https://github.com/Arissira7/Paxos/actions/workflows/golangci-lint.yml/badge.svg)](https://github.com/Arissira7/Paxos/actions/workflows/golangci-lint.yml)

基于 Paxos 共识算法的分布式系统简单实现

## 核心概念

### Paxos 角色

- **Proposer (提议者)**: 提出值并尝试让集群接受
- **Acceptor (接受者)**: 接收提议并投票
- **Quorum (多数派)**: 达成共识所需的最小节点数 (n/2 + 1)

### 关键数据结构

| 结构 | 说明 |
|------|------|
| `BallotNum` | 投票编号，由递增序号和提议者ID组成 |
| `PaxosInstanceId` | Paxos 实例标识，包含 Key 和 Version |
| `Value` | 存储的值（当前为 int64 类型） |
| `Proposer` | 提议者状态及 RPC 请求结构 |
| `Acceptor` | 接受者状态及 RPC 响应结构 |

## 协议流程

### Phase 1 (Prepare)
1. Proposer 生成新的 ballot number
2. 向所有 Acceptor 发送 Prepare 请求
3. Acceptor 承诺不再接受小于其 `LastBal` 的提议
4. 若获得多数派响应，返回已投票的最大值

### Phase 2 (Accept)
1. Proposer 基于 Phase 1 结果选择值（自身值或已接受的值）
2. 向所有 Acceptor 发送 Accept 请求
3. 若获得多数派确认，值被安全接受
