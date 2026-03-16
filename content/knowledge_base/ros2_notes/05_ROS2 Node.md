---
title: "05_ROS2 节点(Node)"
date: 2026-03-16
draft: false
weight: 5
tags: ["ROS2", "机器人"]
summary: "ROS2 Node 节点详解，包括节点的概念、架构优势、基本结构、生命周期，以及 C++ 节点的创建、编译和运行方法。"
ShowToc: true
TocOpen: false
---

# 1. 学习目标

1. 什么是 ROS2 Node

2. 为什么 ROS2 要使用 Node 架构

3. 一个 Node 的基本结构是什么

4. 如何编写一个 ROS2 Node

5. 如何运行一个 Node

# 2. 什么是 Node

Node 是：

> **ROS2 系统中的最小运行单元**

可以理解为：

例如一个机器人系统：

每个 Node 负责一个功能。

例如：

| Node           | 功能     |
| -------------- | ------ |
| camera\_node   | 读取摄像头  |
| lidar\_node    | 读取激光雷达 |
| slam\_node     | 建图     |
| navigate\_node | 路径路径   |
| motor\_node    | 控制电机   |

所以：

> **一个机器人系统 = 多个 Node 协作**

***

# 3. 为什么 ROS2 使用 Node 架构

如果机器人系统写成一个程序：

问题：

ROS2 的解决方案：

优势：

| 优点  | 说明            |
| --- | ------------- |
| 模块化 | 每个 Node 独立    |
| 可复用 | Node 可单独使用    |
| 易维护 | 修改不影响其他模块     |
| 分布式 | Node 可运行在不同设备 |

***

# 4. Node 在系统中的位置

ROS2 系统结构：

例如：

Node 之间 **不直接调用函数，**&#x800C;是通过通信。

***

# 5. Node 的基本结构

一个 Node 本质上是：

程序结构：

ROS2 C++ 示例：

代码含义：

| 代码                 | 作用       |
| ------------------ | -------- |
| rclcpp::init       | 初始化 ROS2 |
| Node::make\_shared | 创建节点     |
| rclcpp::spin       | 运行节点     |
| rclcpp::shutdown   | 关闭系统     |

***

# 6. 创建第一个 ROS2 Node（C++）

进入 package：

创建文件：

代码：

***

# 7. 修改 CMakeLists.txt

为了编译 Node，需要在 CMaktLists.txt 中添加：

***

# 8. 编译 Node

回到工作空间：

编译：

加载环境：

***

# 9. 运行 Node

运行：

终端输出：

说明 Node 已经运行。

***

# 10. Node 生命周期

Node 的运行流程：

流程图：

***

# 11. 一个机器人系统的 Node 示例

一个完整机器人：

通信：

# 12. 总结

ROS2 Node 编程的核心步骤：

代码模块：

# 13. Q\&A

1. Node 是什么？

2. 为什么 ROS2 使用 Node 架构？

3. Node 与普通程序有什么区别？

4. rclcpp::spin() 的作用是什么？

5. Node 是如何运行的？
