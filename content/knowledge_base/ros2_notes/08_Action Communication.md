---
title: "08_Action 通信"
date: 2026-03-16
draft: false
weight: 8
tags: ["ROS2", "机器人", "通信"]
summary: "ROS2 Action 通信详解，包括长任务处理、Goal/Feedback/Result 三要素、与 Topic/Service 的区别，以及 Action Client/Server 编程示例。"
ShowToc: true
TocOpen: false
---

# 1. 学习目标

1. 什么是 ROS2 Action

2. Action 与 Topic / Service 的区别是什么

3. Action 的通信流程是什么

4. Action Client 与 Action Server 的作用是什么

5. Action 为什么适合长时间任务

# 2. 为什么需要 Action

先看一个问题：

如果机器人要执行 **导航任务：**

```bash
机器人 -> 导航到目标点
```

执行过程：

```bash
开始导航
移动中
还剩3米
还剩1米
到达目标
```

如果用 Service：

```bash
Client → Request → Server
Client ← Response ← Server
```

问题：

```bash
无法反馈进度
无法取消任务
任务时间过长
```

所以 ROS2 引入：

> **Action：专门处理长时间任务**

***

# 3. Action 的通信结构

Action 的通信包含三个部分：

```bash
Goal
Feedback
Result
```

通信流程：

```bash
Client → Goal → Server
Server → Feedback → Client
Server → Result → Client
```

结构图：

```bash
         Action Client
              |
              | Goal
              v
         Action Server
              |
              | Feedback
              v
         Action Client
              |
              | Result
              v
         Action Client
```

***

# 4. Action 的组成

一个 Action 包含三部分数据：

```bash
Goal
Result
Feedback
```

例如：

机器人导航 Action：

```bash
Goal：
目标位置

Result：
是否成功

Feedback：
当前距离目标的距离
```

Action 文件示例：

```bash
float32 target_x
float32 target_y
---
bool success
---
float32 remaining_distance
```

结构说明：

| 部分       | 作用      |
| -------- | ------- |
| Goal     | 客户端发送任务 |
| Result   | 任务最终结果  |
| Feedback | 任务执行进度  |

# 5. Action 通信流程

Action 的完整流程：

```bash
Client 发送 Goal
        |
        v
Server 接收 Goal
        |
        v
Server 执行任务
        |
        v
Server 持续发送 Feedback
        |
        v
Server 完成任务
        |
        v
Server 返回 Result
```

流程图：

```bash
Client
  |
  | Goal
  v
Server
  |
  | Feedback
  v
Client
  |
  | Result
  v
Client
```

***

# 6. Action 与 Topic / Service 的区别

| 特性    | Topic | Service | Action |
| ----- | ----- | ------- | ------ |
| 通信方式  | 发布订阅  | 请求响应    | 长任务    |
| 是否持续  | 持续    | 一次      | 持续     |
| 是否反馈  | 否     | 否       | 有      |
| 是否可取消 | 否     | 否       | 可以     |

简单记忆：

```bash
Topic -> 数据流
Service -> 一次操作
Action -> 长任务
```

***

# 7. ROS2 内置 Action 示例

ROS2 自带一个 Action：

```bash
example_interfaces/action/Fibonacci
```

查看 Action：

```bash
ros2 interface show example_interfaces/action/Fibonacci
```

输出：

```bash
int32 order
---
int32[] sequence
---
int32[] partial_sequence
```

结构：

```bash
Goal
int32 order

Result
int32[] sequence

Feedback
int32[] partial_sequence
```

***

# 8. Action Server 示例（C++）

创建：

```bash
fibonacci_action_server.cpp
```

代码示例：

```c++
#include <memory>
#include "rclcpp/rclcpp.hpp"
#include "rclcpp_action/rclcpp_action.hpp"
#include "example_interfaces/action/fibonacci.hpp"

class FibonacciServer : public rclcpp::Node
{
public:
  using Fibonacci = example_interfaces::action::Fibonacci;
  using GoalHandleFibonacci = rclcpp_action::ServerGoalHandle<Fibonacci>;

  FibonacciServer()
  : Node("fibonacci_server")
  {
    action_server_ = rclcpp_action::create_server<Fibonacci>(
      this,
      "fibonacci",
      std::bind(&FibonacciServer::handle_goal, this, std::placeholders::_1, std::placeholders::_2),
      std::bind(&FibonacciServer::handle_cancel, this, std::placeholders::_1),
      std::bind(&FibonacciServer::handle_accepted, this, std::placeholders::_1));
  }

private:
  rclcpp_action::Server<Fibonacci>::SharedPtr action_server_;

  rclcpp_action::GoalResponse handle_goal(
    const rclcpp_action::GoalUUID &,
    std::shared_ptr<const Fibonacci::Goal> goal)
  {
    RCLCPP_INFO(this->get_logger(), "Goal request: %d", goal->order);
    return rclcpp_action::GoalResponse::ACCEPT_AND_EXECUTE;
  }

  rclcpp_action::CancelResponse handle_cancel(
    const std::shared_ptr<GoalHandleFibonacci>)
  {
    return rclcpp_action::CancelResponse::ACCEPT;
  }

  void handle_accepted(const std::shared_ptr<GoalHandleFibonacci> goal_handle)
  {
    execute(goal_handle);
  }

  void execute(const std::shared_ptr<GoalHandleFibonacci> goal_handle)
  {
    auto result = std::make_shared<Fibonacci::Result>();
    result->sequence.push_back(0);
    result->sequence.push_back(1);

    for (int i = 2; i < goal_handle->get_goal()->order; i++)
    {
      result->sequence.push_back(result->sequence[i-1] + result->sequence[i-2]);
    }

    goal_handle->succeed(result);
  }
};
```

***

# 9. Action Client 示例

客户端发送 Goal：

```c++
auto goal_msg = Fibonacci::Goal();
goal_msg.order = 10;

action_client_->async_send_goal(goal_msg);
```

客户端会收到：

```c++
Feedback
Result
```

# 10. ROS2 Action 调试工具

查看 Action：

```c++
ros2 action list
```

查看 Action 类型：

```c++
ros2 action info /fibonacci
```

发送 Goal：

```c++
ros2 action send_goal /fibonacci example_interfaces/action/Fibonacci "{order: 10}"
```

查看反馈：

```c++
Feedback:
partial_sequence: [0,1,1,2]
```

# 11. 总结

Action 通信结构：

```c++
Client → Goal → Server
Server → Feedback → Client
Server → Result → Client
```

特点：

```c++
支持长任务
支持进度反馈
支持任务取消
```

适用场景：

```c++
机器人导航
机械臂操作
自动驾驶任务
复杂控制流程
```

***

# 12. Q\&A

1. Action 为什么存在？

2. Action 与 Service 的区别是什么？

3. Action 的三个核心数据是什么？

4. Action Client 与 Server 的作用是什么？

5. 什么任务适合 Action？
