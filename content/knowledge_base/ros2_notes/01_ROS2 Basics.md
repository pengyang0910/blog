---
title: "01_ROS2 基础认知"
date: 2026-03-16
draft: false
weight: 1
tags: ["ROS2", "机器人"]
summary: "ROS2 入门基础，介绍 ROS2 解决的问题、系统结构、核心概念（Node/Topic/Service/Action）以及与 ROS1 的架构区别。"
ShowToc: true
TocOpen: false
---

# 1. 学习目标

1. **ROS2 解决什么问题**

2. **ROS2 系统结构是什么**

3. **ROS2 与 ROS1 有什么区别**

# 2. ROS2 解决什么问题

## 2.1 背景：机器人软件很复杂

一个完整机器人系统通常由多个子系统组成：

> **机器人系统 = 传感器 + 算法 + 控制 + 通信**

典型机器人软件模块：

```c
激光雷达
相机
IMU
里程计
SLAM
路径规划
运动控制
机械执行
```

例如一个移动机器人系统：

```c
激光雷达 -> 用于环境感知
相机 -> 视觉识别
IMU -> 姿态估计
SLAM -> 构建地图
导航 -> 路径规划
控制 -> 控制电机运动
```

这些模块 **必须互相通信。**

例如：

```c
激光雷达 -> SLAM
SLAM -> 地图
地图 -> 导航
导航 -> 控制
控制 -> 电机
```

***

## 2.2 如果没有 ROS 会发生什么

如果不要 ROS ，开发者通常会：

* 写 **socket 通信**

* 写 **共享内存**

* 写 **消息队列**

* 写 **RPC 接口**

系统会变成这样：

```c
雷达程序 <-> SLAM 程序
SLAM 程序 <-> 导航程序
导航程序 <-> 控制程序
相机程序 <-> AI 识别
```

问题：

1. **程序耦合性严重**

每个模块都必须知道：

```c
IP 地址
通信协议
数据格式
端口
```

***

* **系统难以维护**

修改一个模块可能影响：

```c
SLAM
导航
控制
```

***

* **无法复用**

一个项目的代码很难复用到另一个机器人系统

***

## 2.3 ROS 的解决方案

ROS 提出一种新的机器人软件架构：

```c
模块化 + 消息通信
```

核心思想：

把机器人系统拆成多个 **独立模块。**

每个模块是一个 **Node（节点）。**

模块之间通过 **统一通信机制&#x20;**&#x8FDB;行数据交换。

系统结构：

```c
       ROS2通信系统

 Node A   Node B   Node C
    |        |        |
    +--------+--------+
         数据通信
```

这样：

* 每个模块独立运行

* 模块之间通过 ROS 通信

* 系统更加可扩展

***

# 3. ROS2 系统结构

ROS2 系统的核心思想是：

```c
节点 + 消息通信
```

ROS2 定义了四种核心通信机制：

```c
Node
Topic
Service
Action
```

***

## 3.1 Node（节点）

Node 是 ROS 系统中的 **基本运行单元。**

简单理解：

```c
Node = 一个机器人功能模块
```

例如：

```c
激光雷达驱动节点
相机驱动节点
SLAM 节点
导航节点
电机控制节点
```

系统示例：

```sql
+------------+
| LiDAR Node |
+------------+

+------------+
| Camera Node|
+------------+

+------------+
| SLAM Node  |
+------------+

+------------+
| Nav Node   |
+------------+

+------------+
| Motor Node |
+------------+
```

每个 Node：

* 独立运行

* 负责一个功能

* 通过 ROS 通信

***

## 3.2 Topic（通信）

Topic 是 **发布/订阅通信模型。**

结构：

```c
Publisher -> Topic -> Subscriber
```

示例：

```c
激光雷达节点
      |
      | 发布数据
      v

    /scan

      |
      v

 SLAM节点
```

结构图：

```c
+------------+
|  LiDAR Node|
+------------+
      |
      | publish
      v

   /scan Topic

      |
      | subscribe
      v

+------------+
|  SLAM Node |
+------------+
```

特点：

* 异步通信

* 多发布者

* 多订阅者

* 适合传感器数据

例如：

```c
雷达 -> SLAM
雷达 -> 避障
雷达 -> 地图构建
```

***

## 3.3 Service（服务通信）

Service 是一种 **请求/响应通信机制。**

类似：

```c
RPC
HTTP API
函数调用
```

结构：

```c
Client → Request → Server
Client ← Response ← Server
```

示例：

```c
导航节点 请求：

reset_map()

地图节点 返回：

OK
```

结构图：

```c
+-----------+
|  Client   |
+-----------+
      |
      | Request
      v
+-----------+
|  Server   |
+-----------+
      ^
      | Response
```

特点：

* 同步通信

* 一问一答

* 用于控制命令

## 3.4 Action （任务通信）

Action 用于 **长时间任务。**

适合场景：

```c
机器人导航
机械臂运动
路径规划
```

Action 通信包括三个部分：

```c
Goal
Feedback
Result
```

例子：

机器人导航：

```c
发送目标点
机器人移动
持续反馈位置
到达目标
```

流程：

```c
Client -> Goal
Server -> Feedback
Server -> Result
```

***

## 3.5 ROS2 系统结构图

ROS2 软件架构：

```c
Application Layer
(机器人算法)

        ↓

ROS2 Client Library
(rclcpp / rclpy)

        ↓

RMW Layer
(ROS Middleware)

        ↓

DDS
(FastDDS / CycloneDDS)

        ↓

Operating System
(Linux)
```

简单理解：

```c
机器人算法
    ↓
ROS2通信接口
    ↓
DDS通信
    ↓
操作系统
```

***

# 4. ROS2 与 ROS1 区别

ROS2 是 ROS1 的**下一代版本**。

最核心区别是：

**通信架构不同。**

***

## 4.1 ROS1 架构

ROS1 使用 **中心节点：**

```c
ROS Master
```

系统结构：

```c
Node A
   |
Node B → ROS Master
   |
Node C
```

所有节点启动时必须：

```c
向 Master 注册
```

Master 负责：

```c
节点发现
Topic 管理
连接消息
```

问题：

```c
单点故障
实时性差
扩展困难
```

***

## 4.2 ROS2 架构

ROS2 取消了 **ROS Master**。

使用：

```c
DDS 通信中间件
```

结构：

```c
Node A ←→ Node B
Node B ←→ Node C
Node C ←→ Node A
```

特点：

```c
去中心化
自动发现节点
高实时性
支持分布式系统
```

***

## 4.3 ROS2 架构优势

ROS2 解决了 ROS1 的多个问题：

| 特性    | ROS1   | ROS2 |
| ----- | ------ | ---- |
| 通信架构  | Master | DDS  |
| 实时性   | 较弱     | 强    |
| 分布式   | 一般     | 强    |
| 嵌入式支持 | 较差     | 更好   |
| 安全性   | 无      | 支持   |

***

# 5. 总结

ROS2 的核心思想：

```c
模块化机器人软件架构
```

系统组成：

```c
Node
Topic
Service
Action
```

软件架构：

```c
机器人应用
    ↓
ROS2框架
    ↓
DDS通信
    ↓
操作系统
```

# 6. Q\&A

1. **ROS 为什么需要 Node 结构**

2. **Topic 通信为什么比函数调用好**

3. **ROS2 为什么取消 ROS Master**
