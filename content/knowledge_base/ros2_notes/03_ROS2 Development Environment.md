---
title: "03_ROS2 开发环境"
date: 2026-03-16
draft: false
weight: 3
tags: ["ROS2", "机器人", "开发环境"]
summary: "ROS2 开发环境搭建，包括 Linux 系统配置、ROS2 安装、常用命令行工具（CLI）介绍及 talker/listener 示例运行。"
ShowToc: true
TocOpen: false
---

# 1. 学习目标

1. **ROS2 程序运行在什么环境中**

2. **ROS2 系统如何启动和管理**

3. **ROS2 常用命令行工具是什么**

# 2. ROS2 运行环境

## 2.1 ROS2 运行在什么系统上

ROS2 通常运行在 Linux 系统上。

最常见的开发环境是：

```c
Ubuntu + ROS2
```

例如：

```c
Ubuntu 22.04 + ROS2 Humble
Ubuntu 20.04 + ROS2 Foxy
```

系统结构如下：

```c
机器人应用
      ↓
ROS2框架
      ↓
Linux系统
```

简单解释：

```c
Linux = 操作系统
ROS2 = 机器人软件框架
机器人程序 = ROS2 应用
```

因此：

> ROS2 本质上是 **运行在 Linux 上的软件框架。**

***

## 2.2 ROS2 安装

安装 ROS2 通常使&#x7528;**&#x20;APT 包管理器**。

例如在 Ubuntu 上安装 ROS2：

```bash
sudo apt install ros-humble-desktop
```

安装完成后，需要加载 ROS2 环境：

```bash
source /opt/ros/humble/setup.bash
```

为了每次终端自动加载，可以写入：

```bash
~/.bashrc
```

例如：

```bash
echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
```

之后重新打开终端，ROS2 环境就会自动加载。

***

# 3. ROS2 命令行工具

ROS2 提供了非常强大的 **命令行工具（CLI）。**

CLI 可以帮助我们：

* 查看系统状态

* 调试节点

* 发送消息

* 管理系统

ROS2 所有命令都以：

```bash
ros2
```

开头。

***

## 3.1 查看节点（Node）

查看系统中正在运行的节点：

```bash
ros2 node list
```

输出示例：

```bash
/talker
listener
```

查看节点详细信息：

```bash
ros2 node info /talker
```

可以看到：

* 发布的话题

* 订阅的话题

* 服务

***

## 3.2 查看 Topic

查看系统中的话题：

```bash
ros2 topic list
```

示例输出：

```bash
/chatter
/scan
/cmd_vel
```

查看话题类型：

```bash
ros2 topic type /chatter
```

查看话题数据：

```bash
ros2 topic echo /chatter
```

查看发布频率：

```bash
ros2 topic hz /chatter
```

***

## 3.3 查看 Service

查看系统中的服务：

```bash
ros2 service list
```

示例：

```bash
/rpset_map
/spawn_entity
```

查看服务类型：

```bash
ros2 service type /reset_map
```

调用服务：

```bash
ros2 service call
```

***

## 3.4 查看 Action

Action 通常用于 **长时间任务。**

查看系统中的 Action：

```bash
ros2 action list
```

查看 Action 类型：

```bash
ros2 action info
```

***

# 4. ROS2 系统运行示例

ROS2 官方提供一个最经典的例子：

**talker / listener**

talker 负责发布消息：

```bash
Hello World
```

listener 负责接收消息。

系统结构：

```bash
+-------------+
|   talker    |
| publisher   |
+-------------+
       |
       | Topic: /chatter
       v
+-------------+
|  listener   |
| subscriber  |
+-------------+
```

运行示例：

启动 talker：

```bash
ros2 run demo_nodes_cpp talker
```

启动 listener：

```bash
ros2 run demo_nodes_cpp listener
```

此时 listener 会不断接收到：

```bash
Hello World
```

***

# 5. ROS2 CLI 工具总结

ROS2 最常用的 CLI 命令：

```bash
ros2 node list
ros2 topic list
ros2 service list
ros2 action list
```

调试命令：

```bash
ros2 topic echo
ros2 topic hz
ros2 node info
```

这些命令是 **ROS2 开发中最常使用的工具。**

***

# 6. 总结

ROS2 开发环境包含三个核心部分：

```bash
Linux 系统
ROS2 框架
ROS2 CLI 工具
```

开发者通常通过 **CLI 工具** 来：

```bash
查看节点
查看话题
调试系统
发送消息
```

掌握 CLI 工具后，就可以开始编写 **ROS2 程序**。

***

# 7. Q\&A

1. ROS2 为什么需要 Linux 环境？

2. ROS2 CLI 工具解决什么问题？

3. 为什么 ROS 系统需要大量调试工具？
