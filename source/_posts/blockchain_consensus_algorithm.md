---
title: 区块链共识算法详解
date: 2017-07-29 14:56:13
tags:
- 区块链
- 共识算法
---

# PBFT

实用拜占庭容错系统（Practical Byzantine Fault Tolerance, PBFT），可以降低拜占庭协议的运行复杂度，从指数级别降低到多项式级别（Polynomial）。

PBFT 是一类状态机拜占庭系统，所有节点采取的行动一致，共同维护一个状态。需要运行三类基本协议：一致性协议、检查点协议和视图更换协议。

该协议将服务器分为两类：主节点和从节点，主节点只有一个，并且来自客户端的请求需要在所有节点上都按照一个确定的顺序执行。在协议中，主节点负责将客户端的请求排序；从节点按照主节点提供的顺序执行请求。每个服务器节点在同样的配置信息下工作，该配置信息也叫做视图，主节点更换，视图也随之变化。

一致性协议至少包含若干个阶段：请求（request）、序号分配（pre-prepare）和响应（reply）。根据协议设计的不同，可能包含相互交互（prepare），序号确认（commit）等阶段。

PBFT 的一致性协议如下图所示（C 为客户端，N3 为故障节点）：

{% asset_img 1160773-670f70bcaeb0eca4.png %}

PBFT 假设故障节点为 m 个，而整个服务节点数为 3m + 1 个。每个客户端请求需要经过 5 个阶段：

1. 客户端发送请求，激活主节点服务操作
2. 主节点接受请求后，启动三阶段协议，向各从节点广播请求
* 2.1 序号分配阶段，主节点给请求赋值一个序号 n，广播序号分配消息和客户端的请求消息 m， 并构造 PRE-PREPARE 消息给各从节点
* 2.2 交互阶段，从节点接收 PRE-PREPARE 消息，向其他服务节点广播 PREPARE 消息
* 2.3 序号确认阶段，各节点对视图内的请求和次序进行验证后，广播 COMMIT 消息，执行请求并响应给客户端
3. 客户端等待来自不同节点的响应， 如果有 m + 1 个响应相同， 则该响应即为运算的结果

PBFT 在区块链中一般适合用于对强一致性有要求的私有链和联盟链场景。Hyperledger 中 PBFT 就是一个可选的共识协议。

