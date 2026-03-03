---
title: "ROS2 基础介绍"
date: 2026-03-03
draft: false
weight: 1
tags: ["ROS2", "机器人", "嵌入式"]
summary: "ROS2 的基本概念、核心架构与常用工具概述。"
ShowToc: true
TocOpen: false
---

## 什么是 ROS2？

**ROS2**（Robot Operating System 2）是用于机器人开发的开源中间件框架。它并不是一个真正的操作系统，而是运行在 Linux/Windows/macOS 之上的一套工具集、库和通信机制。

### ROS2 vs ROS1

| 对比项 | ROS1 | ROS2 |
|--------|------|------|
| 通信中间件 | 自研（TCPROS） | DDS（工业标准） |
| 实时性 | 不支持 | 支持（配合 RTOS） |
| 多机器人 | 单 Master 限制 | 原生支持 |
| 安全性 | 无 | DDS 安全插件 |
| 维护状态 | EOL（停止维护） | 持续更新 |

**推荐版本**：ROS2 Humble（LTS，支持至 2027 年）

---

## 核心概念

### Node（节点）

ROS2 程序的基本单元，每个节点是一个独立的进程，负责特定功能。

```
摄像头节点 → 图像处理节点 → 目标检测节点 → 控制节点
```

### Topic（话题）

节点之间**异步、单向**的数据通信通道，发布者/订阅者模式。

```
Publisher（发布者）  →  /camera/image  →  Subscriber（订阅者）
```

### Service（服务）

节点之间**同步、双向**的通信，请求/响应模式。

```
Client（客户端）  →  请求  →  Server（服务端）
                  ←  响应  ←
```

### Action（动作）

适合**长时间执行的任务**，支持中途反馈和取消。

```
Client → Goal（目标）→ Server
       ← Feedback（过程反馈）←
       ← Result（最终结果）←
```

### Parameter（参数）

节点的可配置项，运行时可动态修改。

---

## 常用命令

```bash
# 查看所有节点
ros2 node list

# 查看所有话题
ros2 topic list

# 实时查看话题数据
ros2 topic echo /topic_name

# 查看话题发布频率
ros2 topic hz /topic_name

# 查看消息类型
ros2 topic info /topic_name

# 手动发布消息
ros2 topic pub /chatter std_msgs/msg/String "data: 'Hello'"

# 查看所有服务
ros2 service list

# 查看节点信息
ros2 node info /node_name

# 录制话题数据
ros2 bag record /topic_name

# 回放录制数据
ros2 bag play rosbag2_xxx
```

---

## 工作空间与包

```bash
# 创建工作空间
mkdir -p ~/ros2_ws/src
cd ~/ros2_ws

# 创建功能包（Python）
ros2 pkg create --build-type ament_python my_package

# 创建功能包（C++）
ros2 pkg create --build-type ament_cmake my_package

# 编译工作空间
colcon build

# 加载环境变量
source install/setup.bash
```

---

## 最简单的节点示例（Python）

```python
import rclpy
from rclpy.node import Node
from std_msgs.msg import String

class HelloNode(Node):
    def __init__(self):
        super().__init__('hello_node')
        self.publisher = self.create_publisher(String, '/hello', 10)
        self.timer = self.create_timer(1.0, self.timer_callback)

    def timer_callback(self):
        msg = String()
        msg.data = 'Hello, ROS2!'
        self.publisher.publish(msg)
        self.get_logger().info(f'Publishing: {msg.data}')

def main():
    rclpy.init()
    node = HelloNode()
    rclpy.spin(node)
    rclpy.shutdown()
```

---

## 安装（Ubuntu 22.04 + ROS2 Humble）

```bash
# 设置软件源
sudo apt install software-properties-common
sudo add-apt-repository universe

# 添加 ROS2 GPG key
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
  -o /usr/share/keyrings/ros-archive-keyring.gpg

# 添加仓库
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
  http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" \
  | sudo tee /etc/apt/sources.list.d/ros2.list

# 安装
sudo apt update
sudo apt install ros-humble-desktop

# 加载环境（写入 .bashrc 永久生效）
echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
source ~/.bashrc
```

---

## 参考资料

- [ROS2 官方文档](https://docs.ros.org/en/humble/)
- [ROS2 中文社区](https://www.guyuehome.com/)
- 《ROS2 机器人编程实战》
