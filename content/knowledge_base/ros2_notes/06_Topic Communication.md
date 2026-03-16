---
title: "06_Topic 通信(发布订阅)"
date: 2026-03-16
draft: false
weight: 6
tags: ["ROS2", "机器人", "通信"]
summary: "ROS2 Topic 通信详解，包括发布订阅模型、异步通信特点、Publisher/Subscriber 编程示例，以及 topic 调试工具使用。"
ShowToc: true
TocOpen: false
---

# 1. 学习目标

1. **什么是 Topic**

2. **什么是 Publisher 和 Subscriber**

3. **Topic 通信流程是什么**

4. **ROS2 Topic 为什么是异步通信**

5. **如何编写一个发布者和订阅者**

# 2. 什么是 Topic

Topic 是 ROS2 中 **最常用的通信方式。**

通信模型：

```c++
Publisher → Topic → Subscriber
```

结构图：

```c++
     Publisher
         |
         | publish
         v
       Topic
         |
         | subscribe
         v
     Subscriber
```

简单理解：

> **Publisher 发布数据，Subscriber 订阅数据**

***

# 3. Topic 通信示例

例如：

机器人激光雷达：

```c++
lidar_node
    |
    | 发布数据
    v
   /scan
    |
    | 订阅数据
    v
slam_node
```

系统结构：

```c++
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

***

# 4. Topic 的核心特点

Topic 有三个重要特点：

1. **异步通信**

发布者和订阅者 **互不阻塞。**

```c++
Publisher 只负责发送
Subscriber 只负责接收
```

二者互不影响。

***

* **一对多通信**

一个 Publisher 可以有多个 Subscriber。

```c++
          lidar_node
               |
               v
             /scan
        /       |       \
       v        v        v
 slam_node  map_node  viewer_node
```

***

* 解耦设计

Publisher 不需要知道谁在订阅。

Subscriber 也不知道谁在发布。

只要 **Topic 名字相同即可通信。**

***

# 5. Topic 的组成

一个 Topic 通信需要三个要素：

```c++
Topic Name
Message Type
Publisher / Subscriber
```

例如：

```c++
Topic Name: /scan
Message Type: sensor_msgs/LaserScan
Publisher: lidar_node
Subscriber: slam_node
```

***

# 6. ROS2 Topic 通信流程

Topic 通信流程：

```c++
Publisher 创建 Topic
      |
      v
发布 Message
      |
      v
ROS2 中间件
      |
      v
Subscriber 接收 Message
```

系统结构：

```c++
Publisher
   |
   | message
   v
DDS Middleware
   |
   v
Subscriber
```

ROS2 实际使用&#x20;**&#x20;DDS 中间件&#x20;**&#x5B9E;现通信。

***

# 7. ROS2 Topic 示例（C++）

下面写一个最简单的：

**发布者 + 订阅者**

***

## 7.1 Publisher（发布节点）

创建文件：

```c++
publisher_node.cpp
```

代码：

```c++
#include "rclcpp/rclcpp.hpp"
#include "std_msgs/msg/string.hpp"

class PublisherNode : public rclcpp::Node
{
public:
  PublisherNode() : Node("publisher_node")
  {
    publisher_ = this->create_publisher<std_msgs::msg::String>("chatter", 10);

    timer_ = this->create_wall_timer(
      std::chrono::seconds(1),
      std::bind(&PublisherNode::publish_message, this));
  }

private:
  void publish_message()
  {
    auto message = std_msgs::msg::String();
    message.data = "Hello ROS2";

    publisher_->publish(message);

    RCLCPP_INFO(this->get_logger(), "Publish: %s", message.data.c_str());
  }

  rclcpp::Publisher<std_msgs::msg::String>::SharedPtr publisher_;
  rclcpp::TimerBase::SharedPtr timer_;
};

int main(int argc, char ** argv)
{
  rclcpp::init(argc, argv);

  auto node = std::make_shared<PublisherNode>();

  rclcpp::spin(node);

  rclcpp::shutdown();
}
```

***

## 7.2 Subscriber（订阅节点）

创建：

```c++
subscriber_node.cpp
```

代码：

```c++
#include "rclcpp/rclcpp.hpp"
#include "std_msgs/msg/string.hpp"

class SubscriberNode : public rclcpp::Node
{
public:
  SubscriberNode() : Node("subscriber_node")
  {
    subscription_ = this->create_subscription<std_msgs::msg::String>(
      "chatter",
      10,
      std::bind(&SubscriberNode::topic_callback, this, std::placeholders::_1));
  }

private:
  void topic_callback(const std_msgs::msg::String::SharedPtr msg)
  {
    RCLCPP_INFO(this->get_logger(), "Receive: %s", msg->data.c_str());
  }

  rclcpp::Subscription<std_msgs::msg::String>::SharedPtr subscription_;
};

int main(int argc, char ** argv)
{
  rclcpp::init(argc, argv);

  auto node = std::make_shared<SubscriberNode>();

  rclcpp::spin(node);

  rclcpp::shutdown();
}
```

***

# 8. 修改 CMakeLists.txt

添加：

```cmake
add_executable(publisher_node src/publisher_node.cpp)
add_executable(subscriber_node src/subscriber_node.cpp)

ament_target_dependencies(publisher_node rclcpp std_msgs)
ament_target_dependencies(subscriber_node rclcpp std_msgs)

install(TARGETS
  publisher_node
  subscriber_node
  DESTINATION lib/${PROJECT_NAME})
```

***

# 9. 编译运行

编译：

```cmake
colcon build
```

加载环境：

```cmake
source install/setup.bash
```

运行发布节点：

```cmake
ros2 run my_package publisher_node
```

运行订阅节点：

```cmake
ros2 run my_package subscriber_node
```

终端输出：

```cmake
Publish: Hello ROS2
Receive: Hello ROS2
```

说明通信成功。

***

# 10. ROS2 Topic 调试工具

ROS2 提供很多调试命令。

查看 Topic：

```cmake
ros2 topic list
```

查看 Topic 信息：

```cmake
ros2 topic info /chatter
```

查看消息内容：

```cmake
ros2 topic echo /chatter
```

查看消息类型：

```cmake
ros2 topic type /chatter
```

查看发送频率：

```cmake
ros2 topic hz /chatter
```

***

# 11. 总结

ROS2 Topic 本质：

```cmake
Publisher → Topic → Subscriber
```

特点：

```cmake
异步通信
一对多
解耦设计
```

系统结构：

```cmake
Publisher
    |
    v
  Topic
    |
    v
Subscriber
```

# 12. Q\&A

1. Topic 是什么

2. Publisher 和 Subscriber 的关系是什么

3. 为什么 Topic 是异步通信

4. Topic 为什么支持一对多

5. Topic 和 Service 的区别是什么
