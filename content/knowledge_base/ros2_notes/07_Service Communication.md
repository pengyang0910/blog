---
title: "07_Service 通信"
date: 2026-03-16
draft: false
weight: 7
tags: ["ROS2", "机器人", "通信"]
summary: "ROS2 Service 通信详解，包括请求响应模型、同步通信特点、与 Topic 的区别、Client/Server 编程示例及调试工具。"
ShowToc: true
TocOpen: false
---

# 1. 学习目标

1. 什么是 ROS2 Service

2. Service 与 Topic 的区别是什么

3. Service 的通信流程是什么

4. 什么是 Service Client 和 Server

5. 如何编写一个 Service Server 和 Client

# 2. 什么是 Service

Service 是 ROS2 中的一种 **请求-响应通信方式。**

通信模型：

```cmake
Client → Request → Server
Client ← Response ← Server
```

结构图：

```cmake
     Client
       |
       | Request
       v
    Service
       |
       v
     Server
       |
       | Response
       v
     Client
```

简单理解：

> **Client 发送请求，Server 处理并返回结果。**

***

# 3. Service 通信示例

例如：

机器人系统中：

```cmake
navigation_node 请求 当前地图
```

系统结构：

```cmake
navigation_node
       |
       | Request
       v
    map_service
       |
       | Response
       v
navigation_node
```

另一个例子：

```cmake
UI → 请求机器人状态
robot_node → 返回状态
```

***

# 4. Service 的特点

Service 有三个重要特点：

1. **同步通信**

Client 发送请求后会等待结果。

```cmake
Request → 等待 → Response
```

***

* **一对一通信**

一个 Service Server 一次只处理一个请求。

```cmake
Client -> Server
```

不像 Topic 支持一对多。

***

* **适合控制类操作**

Service 常用于：

```cmake
获取状态
设置参数
触发操作
```

例如：

```cmake
重置系统
保存地图
获取机器人状态
```

***

# 5. Topic 与 Service 区别

| 特性   | Topic | Service |
| ---- | ----- | ------- |
| 通信方式 | 发布订阅  | 请求响应    |
| 通信模式 | 异步    | 同步      |
| 关系   | 一对多   | 一对一     |
| 应用   | 数据流   | 控制操作    |

简单记忆：

```cmake
Topic → 持续数据流
Service → 一次请求
```

***

# 6. Service 的组成

一个 Service 包含三个部分：

```cmake
Service Name
Request
Response
```

例如：

```cmake
Service Name: /add_two_ints

Request:
int64 a
int64 b

Response:
int64 sum
```

***

# 7. 查看 ROS2 Service

ROS2 自带很多 Service。

查看 Service：

```bash
ros2 service list
```

查看 Service 类型：

```bash
ros2 service type /add_two_ints
```

查看 Service 结构：

```bash
ros2 interface show example_interfaces/srv/AddTwoInts
```

输出：

```bash
int64 a
int64 b
---
int64 sum
```

上半部分：

```bash
Request
```

下半部分：

```bash
Response
```

***

# 8. Service Server 示例（C++）

创建：

```bash
add_server.cpp
```

代码：

```c++
#include "rclcpp/rclcpp.hpp"
#include "example_interfaces/srv/add_two_ints.hpp"

class AddServer : public rclcpp::Node
{
public:
  AddServer() : Node("add_server")
  {
    service_ = this->create_service<example_interfaces::srv::AddTwoInts>(
      "add_two_ints",
      std::bind(&AddServer::handle_service, this,
      std::placeholders::_1, std::placeholders::_2));

    RCLCPP_INFO(this->get_logger(), "Service Ready");
  }

private:
  void handle_service(
    const std::shared_ptr<example_interfaces::srv::AddTwoInts::Request> request,
    std::shared_ptr<example_interfaces::srv::AddTwoInts::Response> response)
  {
    response->sum = request->a + request->b;

    RCLCPP_INFO(this->get_logger(),
      "Request: %ld + %ld",
      request->a, request->b);
  }

  rclcpp::Service<example_interfaces::srv::AddTwoInts>::SharedPtr service_;
};

int main(int argc, char ** argv)
{
  rclcpp::init(argc, argv);

  auto node = std::make_shared<AddServer>();

  rclcpp::spin(node);

  rclcpp::shutdown();
}
```

# 9. Service Client 示例

创建：

```c++
add_client.cpp
```

代码：

```c++
#include "rclcpp/rclcpp.hpp"
#include "example_interfaces/srv/add_two_ints.hpp"

class AddClient : public rclcpp::Node
{
public:
  AddClient() : Node("add_client")
  {
    client_ = this->create_client<example_interfaces::srv::AddTwoInts>("add_two_ints");

    auto request = std::make_shared<example_interfaces::srv::AddTwoInts::Request>();

    request->a = 10;
    request->b = 20;

    while (!client_->wait_for_service(std::chrono::seconds(1))) {
      RCLCPP_INFO(this->get_logger(), "Waiting for service...");
    }

    auto result = client_->async_send_request(request);

    if (rclcpp::spin_until_future_complete(this->get_node_base_interface(), result)
        == rclcpp::FutureReturnCode::SUCCESS)
    {
      RCLCPP_INFO(this->get_logger(), "Result: %ld", result.get()->sum);
    }
  }

private:
  rclcpp::Client<example_interfaces::srv::AddTwoInts>::SharedPtr client_;
};

int main(int argc, char ** argv)
{
  rclcpp::init(argc, argv);

  auto node = std::make_shared<AddClient>();

  rclcpp::spin(node);

  rclcpp::shutdown();
}
```

# 10. 修改 CMakeLists.txt

添加：

```cmake
add_executable(add_server src/add_server.cpp)
add_executable(add_client src/add_client.cpp)

ament_target_dependencies(add_server rclcpp example_interfaces)
ament_target_dependencies(add_client rclcpp example_interfaces)

install(TARGETS
  add_server
  add_client
  DESTINATION lib/${PROJECT_NAME})
```

# 11. 编译运行

编译：

```bash
colcon build
```

加载环境：

```bash
source install/setup.bash
```

运行 Server：

```bash
ros2 run my_package add_server
```

运行 Client：

```bash
ros2 run my_package add_client
```

输出：

```bash
Request: 10 + 20
Result: 30
```

# 12. Service 调试工具

查看 Service：

```bash
ros2 service list
```

查看 Service 类型：

```bash
ros2 service type /add_two_ints
```

手动调用：

```bash
ros2 service call /add_two_ints example_interfaces/srv/AddTwoInts "{a: 5, b: 3}"
```

输出：

```bash
sum: 8
```

***

# 13. Service 总结

Service 通信结构：

```bash
Client → Request → Server
Client ← Response ← Server
```

特点：

```bash
同步通信
一对一
适合控制操作
```

对比：

```bash
Topic → 数据流
Service → 请求响应
```

# 14. Q\&A

1. Service 是什么？

2. Service 与 Topic 的区别是什么？

3. Service 为什么是同步通信？

4. Client 和 Server 分别做什么？

5. 什么场景适合 Service？
