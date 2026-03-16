---
title: "2_ROS2 系统架构"
date: 2026-03-16
draft: false
weight: 2
tags: ["ROS2", "机器人"]
summary: "ROS2 系统架构详解，涵盖 Node、Topic、Service、Action 四大核心概念，以及分布式系统特性和与传统程序的区别。"
ShowToc: true
TocOpen: false
---

# 1. 学习目标

1. **ROS2 系统是由哪些核心组件组成的？**

2. **各个组件之间如何通信？**

3. **ROS2 的运行结构是什么样的？**

4. **一个机器人系统在 ROS2 中如何组织？**

# 2. ROS2 系统总体结构

ROS2 的核心思想其实非常简单：

> **机器人系统 = 多个 Node 通过通信机制协作**

整体结构如下：

```sql
                +-------------------+
                |       Node        |
                |   (Camera Node)   |
                +-------------------+
                         |
                         | Topic
                         v
                +-------------------+
                |       Node        |
                |    (SLAM Node)    |
                +-------------------+
                         |
                         | Topic
                         v
                +-------------------+
                |       Node        |
                |   (Navigation)    |
                +-------------------+
                         |
                         | Topic
                         v
                +-------------------+
                |       Node        |
                |   (Motor Node)    |
                +-------------------+
```

也就是说：

机器人系统不是一个程序，而是 **多个程序组成的系统。**

每个程序负责不同的功能。

例如：

机器人系统：

```bash
相机节点
激光雷达节点
IMU 节点
SLAM 节点
导航节点
电机控制节点
```

这些节点之间通过 ROS2 通信。

***

# 3. ROS2 的四个核心概念

ROS2 的核心概念只有四个：

```bash
Node
Topic
Servie
Action
```

***

## 3.1 Node（节点）

Node 就是 **一个独立运行的程序模块。**

例如：

```bash
camera_node
lidar_node
slam_node
navigation_node
motor_node
```

每个 Node 负责一个功能。

例如：

```bash
camera_node
负责读取摄像头数据

lidar_node
负责读取激光雷达

slam_node
负责建图

navigation_node
负责路径规划

motor_node
负责控制电机
```

所以 ROS2 的设计原则是：

> **一个 Node 只做一件事。**

***

## 3.2 Topic （发布订阅）

Topic &#x662F;**&#x20;ROS2 最常用的通信方式**。

通信模型：

```bash
Publisher -> Topic -> Subscriber
```

示例：

```bash
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

```bash
      +-------------+
      | lidar_node  |
      +-------------+
            |
            | publish
            v
         /scan topic
            |
            | subscribe
            v
      +-------------+
      |  slam_node  |
      +-------------+
```

特点：

```bash
一对多
异步通信
实时数据流
```

典型应用：

```bash
传感器数据
图像数据
里程计
状态数据
```

***

## 3.3 Service（服务通信）

Service 是 **请求-响应通信。**

通信模型：

```bash
Client → Request → Server
Client ← Response ← Server
```

示例：

```bash
导航节点 请求 地图服务
```

结构图：

```bash
       Client
         |
         | Request
         v
      +--------+
      | Server |
      +--------+
         ^
         |
       Response
```

特点：

```bash
同步通信
一问一答
```

典型应用：

```bash
启动地图
获取机器人状态
设置参数
```

***

## 3.4 Action（任务通信）

Action 用于 **长时间任务。**

例如：

```bash
导航到目标点
机械臂抓取
自动泊车
```

因为这些任务：

```bash
需要时间
可以取消
需要反馈进度
```

Action 的通信结构：

```bash
Client → Goal
Server → Feedback
Server → Result
```

结构：

```bash
Client
   |
   |  Goal
   v
Action Server
   |
   | Feedback
   v
Client
   |
   | Result
   v
Client
```

# 4. ROS2 系统运行结构

在 ROS2 中，一个系统运行起来通常是这样：

```bash
Robot System
│
├── lidar_node
├── camera_node
├── imu_node
├── slam_node
├── navigation_node
└── motor_node
```

节点之间通信：

```bash
lidar_node  → /scan
camera_node → /image
imu_node    → /imu
slam_node   → /map
navigation  → /cmd_vel
motor_node  → 控制电机
```

系统图：

```bash
        lidar_node
             |
             | /scan
             v
           slam_node
             |
             | /map
             v
        navigation_node
             |
             | /cmd_vel
             v
          motor_node
```

***

# 5. ROS2 分布式系统

ROS2 的一个巨大优势是：

> **天然支持分布式系统。**

节点可以运行在不同设备。

例如：

```bash
机器人系统
```

```bash
机器人本体
├── lidar_node
├── motor_node
└── imu_node

计算机
├── slam_node
├── navigation_node
└── visualization_node
```

通信通过网络完成。

```bash
Robot  ←→ WiFi/Ethernet ←→ PC
```

ROS2 自动发现节点。

不需要配置 IP。

***

# 6. ROS2 与传统程序的区别

传统机器人程序：

```c
main()
{
    read_lidar();
    read_camera();
    slam();
    navigation();
    motor_control();
}
```

问题：

```c
代码巨大
耦合严重
难维护
难扩展
```

ROS2 方案：

```c
lidar_node
camera_node
slam_node
navigation_node
motor_node
```

优点：

```c
模块化
可复用
易扩展
分布式
```

***

# 7. 总结

ROS2 的系统架构可以用一句话总结：

```c
ROS2 = Node + 通信机制
```

通信机制包括：

```c
Topic   → 数据流
Service → 请求响应
Action  → 长任务
```

系统结构：

```c
多个 Node
通过 Topic/Service/Action 通信
组成机器人系统
```

记住这张核心图：

```c
          Node
            |
            | Topic
            v
          Node
            |
            | Service
            v
          Node
            |
            | Action
            v
          Node
```

# 8. Q\&A

1. **什么是 ROS2 Node？**

2. **Topic 和 Service 的区别是什么？**

3. **Action 为什么存在？**

4. **ROS2 为什么适合机器人系统？**

