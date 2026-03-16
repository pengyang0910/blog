---
title: "04_ROS2 工作空间与 Package"
date: 2026-03-16
draft: false
weight: 4
tags: ["ROS2", "机器人", "开发环境"]
summary: "ROS2 工作空间与 Package 详解，包括目录结构、创建编译流程、colcon 构建工具使用及完整开发流程。"
ShowToc: true
TocOpen: false
---

# 1. 学习目标

1. **什么是 ROS2 工作空间（Workspace）**

2. **为什么 ROS2 要使用工作空间**

3. **什么是 ROS2 Package**

4. **工作空间与 Package 的关系是什么**

5. **如何创建，编译，运行一个 ROS2 Package**

# 2. 什么是 ROS2 工作空间

在 ROS2 中，所有的代码都必须放在 **工作空间（Workspace）**&#x4E2D;。

工作空间可以理解为：

> **ROS2 项目的开发目录**

例如：

```c
ros2_ws
```

一个典型的 ROS2 工作空间结构如下：

```c
ros2_ws
│
├── src
│   └── package
│
├── build
│
├── install
│
└── log
```

各目录作用：

| 目录      | 作用        |
| ------- | --------- |
| src     | 存放源码      |
| build   | 编译生成的中间文件 |
| install | 编译后的可执行程序 |
| log     | 编译日志      |

所以：

> **src 是开发目录**

其余目录都是 **编译系统自动生成的。**

***

# 3. 为什么需要工作空间

ROS2 使用 **模块开发。**

一个机器人系统通常包含多个模块：

例如：

```c
机器人系统
│
├── 相机驱动
├── 激光雷达驱动
├── SLAM算法
├── 导航算法
├── 电机控制
└── UI界面
```

如果这些代码全部放在一个工程里：

```c
project
 ├── slam
 ├── lidar
 ├── navigation
 ├── motor
```

问题：

```c
耦合严重
难复用
难维护
```

ROS2 的解决方案是：

```c
Workspace
 └── 多个 Package
```

例如：

```c
ros2_ws
└── src
    ├── lidar_driver
    ├── camera_driver
    ├── slam_package
    ├── navigation_package
    └── motor_driver
```

每个功能模块 **都是一个 Package。**

***

# 4. 什么是 ROS2 Package

Package 是：

> **ROS2 的最小软件单元**

可以理解为：

```c
ROS2 Package = 一个独立的软件模块
```

例如：

```c
camera_driver
lidar_driver
slam_package
navigation_package
```

一个 Package 中通常包含：

```c
源代码
配置文件
依赖描述
编译规则
```

典型结构：

```c
my_package
│
├── package.xml
├── CMakeLists.txt
│
├── src
│
├── include
│
├── launch
│
├── config
│
└── msg
```

各目录作用：

| 文件             | 作用    |
| -------------- | ----- |
| package.xml    | 包描述文件 |
| CMakeLists.txt | 编译规则  |
| src            | 源代码   |
| include        | 头文件   |
| launch         | 启动文件  |
| config         | 配置文件  |
| msg            | 自定义消息 |

***

# 5. Workspace 与 Package 的关系

关系非常简单：

```c
Workspace
   └── Package
```

一个工作空间中可以包含 **多个 Package**。

结构：

```c
ros2_ws
└── src
    ├── package1
    ├── package2
    ├── package3
```

编译时：

```c
colcon build
```

ROS2 会：

```c
扫描 src 目录
找到所有 package
一起编译
```

编译流程：

```c
src  → build → install
```

# 6. 创建 ROS2 工作空间

创建工作空间：

```bash
mkdir -p ~/ros2_ws/src
cd ~/ros2_ws
```

目录结构：

```bash
ros2_ws
└── src
```

接着初始化环境：

```bash
source /opt/ros/humble/setup.bash
```

***

# 7. 创建 ROS2 Package

创建 package：

```bash
cd ~/ros2_ws/src
```

创建 C++ package：

```bash
ros2 pkg create my_package --build-type ament_cmake
```

创建 Python package：

```bash
ros2 pkg create my_package --build-type ament_python
```

创建完成后：

```bash
cd ~/ros2_ws
```

***

# 8. 编译 ROS2 工作空间

进入工作空间：

```bash
cd ~/ros2_rw
```

编译：

```bash
colcon build
```

编译完成后：

```bash
ros2_ws
├── build
├── install
└── log
```

然后加载环境：

```bash
source install/setup.bash
```

这一步非常重要。

否则 ROS2 找不到你的 Package。

***

# 9. 运行 Package

查看 package：

```bash
ros2 pkg list
```

运行节点：

```bash
ros2 run package_name node_name
```

例如：

```bash
ros2 run demo_nodes_cpp talker
```

***

# 10. ROS2 开发流程总结

完整开发流程：

1. 创建 workspace

2. 创建 package

3. 编写代码

4. colcon build

5. source install/setup.bash

6. ros2 run

流程图：

```bash
创建 workspace
        │
        ▼
创建 package
        │
        ▼
编写 node
        │
        ▼
colcon build
        │
        ▼
source install
        │
        ▼
ros2 run
```

# 11. 总结

ROS2 开发结构：

```bash
Workspace
│
└── src
     ├── lidar_driver
     ├── camera_driver
     ├── slam
     ├── navigation
     └── motor_driver
```

本质就是：

```bash
工程目录
    └── 多个模块
```

每个模块：

```bash
一个 Package
```

# 12. Q\&A

1. ROS2 Workspace 是什么？

2. ROS2 Package 是什么？

3. 为什么 ROS2 要使用 Package？

4. Workspace 与 Package 的关系是什么？

5. colcon build 做了什么？
