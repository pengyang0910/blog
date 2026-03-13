---
title: "14_Linux CAN 驱动（SocketCAN Subsystem）"
date: 2026-03-13
draft: false
weight: 14
tags: ["Linux", "驱动开发", "内核"]
summary: "Linux SocketCAN 驱动开发详解，涵盖 CAN 总线协议、SocketCAN 架构、can_frame 数据结构、CAN 设备注册及用户空间 CAN 通信编程。"
ShowToc: true
TocOpen: false
---

# 1. 学习目标

1. **理解 CAN 总线工作原理**

理解 CAN 总线结构：

```c
CAN_H
CAN_L
```

以及通信方式：

```c
广播通信
优先级仲裁
帧结构
```

***

* **理解 Linux CAN 子系统架构**

理解 Linux CAN 驱动结构：

```c
User Space
   │
   ▼
SocketCAN
   │
   ▼
CAN Network Driver
   │
   ▼
CAN Controller
```

* **理解 CAN 核心结构**

掌握核心对象：

```c
can_device
net_device
can_frame
```

***

* **能编写基础 CAN 驱动**

掌握核心 API：

```c
register_candev
alloc_candev
can_put_echo_skb
```

***

* **能使用用户空间工具测试 CAN**

掌握工具：

```c
ip
candump
cansend
```

***

# 2. CAN 总线简介

CAN 是一种：

```c
多主机通信总线
```

信号线：

```c
CAN_H
CAN_L
```

结构：

```c
User Space
   │
   ▼
SocketCAN
   │
   ▼
CAN Network Driver
   │
   ▼
CAN Controller
```

特点：

```c
广播通信
高可靠性
实时性强
```

***

**CAN 帧结构**

标准 CAN 帧：

```c
| ID | DLC | DATA | CRC |
```

示例：

```c
ID   = 0x123
DATA = 8 bytes
```

***

# 3. Linux CAN 子系统架构

Linux CAN 子系统结构：

```c
User Space
    │
    ▼
Socket API
    │
    ▼
SocketCAN
    │
    ▼
CAN Network Driver
    │
    ▼
CAN Controller Driver
```

Linux 将 CAN 设备当作：

```c
网络设备
```

例如：

```c
can0
can1
```

***

# 4. SocketCAN

SocketCAN 是 Linux CAN 框架。

作用：

```c
统一 CAN 通信接口
```

用户程序使用：

```c
socket()
```

访问 CAN。

例如：

```c
socket(PF_CAN, SOCK_RAW, CAN_RAW)
```

***

# 5. CAN 核心结构

CAN 子系统核心结构：

```c
net_device
can_device
can_frame
```

# 6. can\_frame

CAN 数据帧结构：

```c
struct can_frame
{
    canid_t can_id;
    __u8 can_dlc;
    __u8 data[8];
};
```

字段：

```c
can_id CAN ID
can_dlc 数据长度
data 数据
```

***

# 7. net\_device

Linux CAN 设备本质是：

```c
网络设备
```

结构：

```c
struct net_device
```

系统设备：

```c
can0
can1
```

***

# 8. CAN 驱动核心结构

CAN 驱动核心对象：

```c
can_priv
net_device
can_ops
```

***

**can\_priv**

can\_priv 表示：

```c
CAN 设备私有数据
```

结构：

```c
struct can_priv
{
    struct can_bittiming bittiming;
};
```

用于：

```c
波特率配置
```

***

**can\_ops**

CAN 驱动操作接口：

```c
start
stop
transmit
```

***

# 9. CAN 驱动注册流程

CAN 驱动基本流程：

```c
分配 net_device
      │
初始化 can_priv
      │
register_candev
      │
生成 canX
```

流程图：

```c
CAN Driver
     │
     ▼
alloc_candev
     │
     ▼
register_candev
     │
     ▼
can0
```

***

# 10. CAN 数据发送

发送 CAN 帧：

```c
write(socket)
```

驱动流程：

```c
User Space
    │
send()
    │
SocketCAN
    │
Driver
    │
Hardware
```

驱动函数：

```c
ndo_start_xmit
```

***

# 11. CAN 数据接收

接收流程：

```c
CAN Hardware
      │
      ▼
IRQ
      │
      ▼
Driver
      │
      ▼
netif_rx
      │
      ▼
SocketCAN
      │
      ▼
User Space
```

# 12. CAN 驱动示例

简单 CAN 驱动结构：

```c
static int my_can_open(struct net_device *dev)
{
    printk("can open\n");
    return 0;
}

static int my_can_close(struct net_device *dev)
{
    printk("can close\n");
    return 0;
}

static const struct net_device_ops my_can_ops =
{
    .ndo_open = my_can_open,
    .ndo_stop = my_can_close,
};
```

注册：

```c
dev = alloc_candev(sizeof(struct my_priv), 1);
dev->netdev_ops = &my_can_ops;

register_candev(dev);
```

# 13. 用户空间 CAN 工具

Linux 提供 CAN 工具：

```c
ip
candump
cansend
```

***

**配置 CAN**

启动 CAN：

```c
ip link set can0 up type can bitrate 500000
```

***

**发送 CAN**

```c
cansend can0 123#11223344
```

***

**接收 CAN**

```c
candump can0
```

***

# 14. Device Tree 描述 CAN

CAN 控制器通常通过 Device Tree 描述。

示例：

```c
can@4000
{
    compatible = "my-can";
    reg = <0x4000 0x100>;
    interrupts = <10>;
};
```

***

# 15. CAN 子系统结构总结

Linux CAN 子系统结构：

```c
User Space
   │
   ▼
SocketCAN
   │
   ▼
CAN Driver
   │
   ▼
CAN Hardware
```

核心结构：

```c
net_device
can_device
can_frame
```

***

# 16. 驱动常见问题

**CAN 无法发送**

原因：

```c
CAN 未启动
```

***

**CAN 数据错误**

原因：

```c
波特率不匹配
```

***

# 17. 总结

Linux CAN 子系统核心结构：

```c
SocketCAN
    │
    ▼
CAN Driver
    │
    ▼
CAN Hardware
```

核心对象：

```c
net_device
can_device
can_frame
```

最重要原则：

> **CAN 驱动 = SocketCAN + Network Device**

***

# 18. Q\&A

## 18.1 基础理解

1. CAN 为什么适合汽车通信？

2. CAN 总线为什么抗干扰？

***

## 18.2 Linux 架构

1. 为什么 Linux 把 CAN 当作网络设备？

2. SocketCAN 的作用是什么？

***

## 18.3 驱动流程

1. alloc\_candev 做了什么？

2. register\_candev 的作用是什么？
