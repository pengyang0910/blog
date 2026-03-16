---
title: "09_参数系统(Parameter)"
date: 2026-03-16
draft: false
weight: 9
tags: ["ROS2", "机器人"]
summary: "ROS2 参数系统详解，包括参数声明与获取、运行时修改、YAML 配置文件使用，以及参数在工程中的实际应用。"
ShowToc: true
TocOpen: false
---

# 1. 学习目标

1. 什么是 ROS2 参数系统

2. 参数为什么存在

3. 如何在 Node 中声明和获取参数

4. 如何在运行时修改参数

5. 参数文件（YAML）如何使用

# 2. 什么是 ROS2 参数

参数是：

> 运行时配置变量

例如：

```c++
robot_speed = 1.5
camera_fps = 30
lidar_range = 20
```

这些参数可以：

```c++
启动时设置
运行时修改
配置文件加载
```

***

# 3. 为什么需要参数系统

例如：

机器人最大速度：

```c
max_speed = 1.5;
```

如果需要修改：

```c
重新编译代码
```

这在机器人系统开发中非常不方便。

ROS2 参数系统解决方案：

```c
max_speed -> Parameter
```

启动时配置：

```c
ros2 run robot_node --ros-args -p max_speed:=2.0
```

代码无需修改

***

# 4. ROS2 参数基本结构

参数属于 Node。

结构：

```c
Node
 └── Parameter
```

例如：

```c
navigation_node
 ├── max_speed
 ├── goal_tolerance
 └── planner_type
```

每个 Node 都可以有用自己的参数。

***

# 5. 参数类型

ROS2 支持多种参数类型

| 类型     | 示例       |
| ------ | -------- |
| bool   | true     |
| int    | 10       |
| double | 1.5      |
| string | "robot"  |
| array  | \[1,2,3] |

例如：

```c
max_speed = 1.5
robot_name = "robot1"
enable_nav = true
```

***

# 6. 声明参数

在 Node 中无需先声明参数。

示例：

```c++
this->declare_parameter("robot_speed",1.0);
```

含义：

```c++
参数名：robot_speed
默认值：1.0
```

完整示例：

```c++
double speed;

this->get_parameter("robot_speed", speed);

RCLCPP_INFO(this->get_logger(), "Speed: %f", speed);
```

***

# 7. 设置参数

运行 Node 时可以设置参数：

```bash
ros2 run my_package param_node --ros-args -p robot_speed:=2.0
```

程序输出：

```bash
Speed:2.0
```

***

# 8. 查看参数

查看 Node 参数：

```bash
ros2 param list
```

查看某个 Node 参数;

```bash
ros2 param list /param_node
```

查看参数值：

```bash
ros2 param get /param_node robot_speed
```

输出：

```bash
1.0
```

***

# 9. 修改参数

运行时修改参数：

```bash
ros2 param set /param_node robot_speed 3.0
```

再次查看：

```bash
ros2 param get /param_node robot_speed
```

输出：

```bash
3.0
```

***

# 10. 参数配置文件（YAML）

在工程中，参数通常写在配置文件。

例如：

```bash
config/robot.yaml
```

内容：

```yaml
param_node:
  ros__parameters:
    robot_speed: 2.5
    robot_name: "robot1"
    enable_navigation: true
```

***

# 11. 使用参数文件

启动 Node：

```yaml
ros2 run my_package param_node --ros-args --params-file config/robot.yaml
```

程序会自动加载参数。

# 12. 参数系统在工程中的使用

在机器人系统中：

```yaml
navigation_node
 ├── max_speed
 ├── goal_tolerance
 └── planner_type
```

SLAM：

```yaml
slam_node
 ├── map_resolution
 ├── update_rate
 └── sensor_range
```

相机：

```yaml
camera_node
 ├── fps
 ├── exposure
 └── resolution
```

参数系统让：

```yaml
代码逻辑
配置数据
```

彻底分离。

***

# 13. 参数系统总结

ROS2 参数系统：

```yaml
Node
 └── Parameter
```

特点：

```yaml
运行时配置
无需重新编译
支持配置文件
支持动态修改
```

典型用途：

```yaml
算法参数
系统配置
设备参数
调试参数
```

# 14. Q\&A

1. 什么是 ROS2 参数系统？

2. 参数为什么存在？

3. declare\_parameter 的作用是什么？

4. 如何运行时修改参数？

5. YAML 参数文件有什么作用？

