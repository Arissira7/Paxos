# PaxosKV

基于 Paxos 共识算法的分布式 Key-Value 存储实现。

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

## 技术栈

- **Go 1.20+**
- **gRPC**: RPC 通信框架
- **Protocol Buffers**: 序列化格式

## 使用方法

### 启动 Acceptor 服务

```go
acceptorIds := []int64{0, 1, 2, 3, 4} // 5 个节点
servers := paxoskv.ServeAcceptors(acceptorIds)
```

每个 Acceptor 在端口 `3333 + acceptorId` 上监听。

### 运行 Paxos 提议

```go
proposer := &paxoskv.Proposer{
    Id: &paxoskv.PaxosInstanceId{
        Key: "my-key",
        Ver: 1,
    },
    Bal: &paxoskv.BallotNum{
        N: 0,
        ProposerId: 1,
    },
}

value := &paxoskv.Value{Vi64: 42}
acceptedValue := proposer.RunPaxos(acceptorIds, value)
```

### 读取值（无需提议）

```go
proposer := &paxoskv.Proposer{
    Id: &paxoskv.PaxosInstanceId{
        Key: "my-key",
        Ver: 1,
    },
    Bal: &paxoskv.BallotNum{N: 0, ProposerId: 1},
}

// 传入 nil 作为值，执行只读操作
readValue := proposer.RunPaxos(acceptorIds, nil)
```

## 关键实现细节

### Ballot Number 比较

```go
func (a *BallotNum) GE(b *BallotNum) bool {
    if a.N > b.N {
        return true
    }
    if a.N < b.N {
        return false
    }
    return a.ProposerId >= b.ProposerId
}
```

Ballot number 的比较确保了全局唯一性和有序性。

### 并发安全

- `KVServer` 使用 `sync.Mutex` 保护存储
- `Version` 使用独立的 mutex 保护每个版本的状态

## 运行要求

- Go 1.20 或更高版本
- Protocol Buffer 编译器 (用于重新生成 .pb.go 文件)
