---
title: "10_Launch系统"
date: 2026-03-16
draft: false
weight: 10
tags: ["ROS2", "机器人", "开发环境"]
summary: "ROS2 Launch 系统详解，包括启动脚本编写、多节点启动、参数加载、Topic 重映射，以及完整机器人系统启动示例。"
ShowToc: true
TocOpen: false
---

# 1. 学习目标

1. 什么是 ROS2 Launch

2. Launch 为什么存在

3. Launch 文件的基本结构是什么

4. 如何使用 Launch 启动多个 Node

5. 如何在 Launch 中加载参数

# 2. 什么是 Launch

Launch 是：

> **ROS2 的系统启动工具**

用于：

```bash
启动多个 Node
加载参数
设置环境
管理系统启动
```

简单理解：

```bash
Launch = 系统启动脚本
```

# 3. 为什么需要 Launch

假设机器人系统：

```bash
机器人系统
├── lidar_node
├── camera_node
├── slam_node
├── navigation_node
└── motor_node
```

如果手动启动：

```bash
ros2 run lidar lidar_node
ros2 run camera camera_node
ros2 run slam slam_node
ros2 run navigation navigation_node
```

问题：

```bash
步骤复杂
容易出错
难维护
```

ROS2 Launch

```bash
ros2 launch robot_system robot.launch.py
```

一次启动整个系统

***

# 4. Launch 系统结构

Launch 文件通常防在：

```bash
package
 └── launch
      └── robot.launch.py
```

Launch 文件结构：

```bash
launch
 └── robot.launch.py
```

***

# 5. Launch 文件类型

ROS2 支持三种 Launch 文件：

| 类型     | 推荐程度 |
| ------ | ---- |
| Python | 推荐   |
| XML    | 较少   |
| YAML   | 较少   |

ROS2 官方推荐：

```bash
Python Launch
```

因为更灵活。

***

# 6. Launch 文件基本结构

一个 Launch 文件结构：

```python
from launch import LaunchDescription
from launch_ros.actions import Node

def generate_launch_description():

    return LaunchDescription([
        Node(
            package='my_package',
            executable='my_node',
            name='my_node'
        )
    ])
```

结构说明：

| 部分                | 作用        |
| ----------------- | --------- |
| LaunchDescription | Launch 描述 |
| Node              | 启动节点      |
| package           | 包名        |
| executable        | 节点程序      |
| name              | 节点名称      |

***

# 7. 启动多个 Node

Launch 可以同时启动多个节点。

示例：

```python
from launch import LaunchDescription
from launch_ros.actions import Node

def generate_launch_description():

    return LaunchDescription([

        Node(
            package='lidar_pkg',
            executable='lidar_node',
            name='lidar'
        ),

        Node(
            package='slam_pkg',
            executable='slam_node',
            name='slam'
        ),

        Node(
            package='nav_pkg',
            executable='navigation_node',
            name='navigation'
        )

    ])
```

运行：

```bash
ros2 launch robot_system robot.launch.py
```

系统同时启动三个 Node。

***

# 8. Launch 加载参数

Launch 可以加载参数文件。

例如：

```python
Node(
    package='nav_pkg',
    executable='navigation_node',
    parameters=['config/nav.yaml']
)
```

配置文件：

```yaml
navigation_node:
  ros__parameters:
    max_speed: 2.0
    goal_tolerance: 0.5
```

***

# 9. Launch 设置参数

也可以直接在 Launch 中设置参数：

```python
Node(
    package='robot_pkg',
    executable='robot_node',
    parameters=[
        {"max_speed": 2.0},
        {"robot_name": "robot1"}
    ]
)
```

***

# 10. Launch 设置 Topic 重映射

Launch 可以修改 Topic 名称。

例如：

```python
Node(
    package='camera_pkg',
    executable='camera_node',
    remappings=[
        ('/image', '/camera/image_raw')
    ]
)
```

作用：

```python
/image → /camera/image_raw
```

***

# 11. Launch 系统启动流程

系统启动流程：

```python
Launch File
     |
     v
创建 Node
     |
     v
加载参数
     |
     v
启动 Node
```

系统结构：

```python
launch
   |
   v
node1
node2
node3
```

# 12. 一个机器人 Launch 示例

完整机器人系统：

```python
from launch import LaunchDescription
from launch_ros.actions import Node

def generate_launch_description():

    return LaunchDescription([

        Node(
            package='lidar_driver',
            executable='lidar_node'
        ),

        Node(
            package='camera_driver',
            executable='camera_node'
        ),

        Node(
            package='slam_pkg',
            executable='slam_node'
        ),

        Node(
            package='navigation_pkg',
            executable='nav_node'
        )

    ])
```

启动：

```bash
ros2 launch robot robot.launch.py
```

# 13. Launch 调试工具

查看运行节点：

```bash
ros2 node list
```

查看 Topic：

```bash
ros2 topic list
```

查看参数：

```bash
ros2 param list
```

***

# 14. Launch 系统总结

Launch 本质：

```bash
Launch = 系统启动脚本
```

作用：

```bash
启动多个 Node
加载参数
管理系统启动
```

系统结构：

```bash
launch file
    |
    v
node1
node2
node3
```

***

# 15. Q\&A

1. Launch 为什么存在？

2. Launch 文件的作用是什么？

3. Launch 如何启动多个 Node？

4. Launch 如何加载参数？

5. Launch 为什么适合机器人系统？
