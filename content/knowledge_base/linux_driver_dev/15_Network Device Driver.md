---
title: "15_Linux Netdev 驱动（Network Device Driver）"
date: 2026-03-13
draft: false
weight: 15
tags: ["Linux", "驱动开发", "内核"]
summary: "Linux 网络设备驱动开发指南，讲解 net_device 结构、网络数据包收发流程、NAPI 机制、ethtool 接口及以太网/WiFi 驱动开发要点。"
ShowToc: true
TocOpen: false
---

# 1. 学习目标

1. **理解 Linux 网络设备架构**

理解 Linux 网络通信结构：

```c
User Space
   │
   ▼
Socket API
   │
   ▼
TCP/IP Stack
   │
   ▼
Network Driver
   │
   ▼
Network Hardware
```

***

* **理解 Linux 网络设备模型**

理解 Linux 网络设备核心结构：

```c
net_device
net_device_ops
sk_buff
```

***

* **理解网络数据收发流程**

掌握：

```c
发送路径
接收路径
```

* **能编写基础网络驱动**

掌握核心 API：

```c
alloc_netdev
register_netdev
unregister_netdev
```

***

* **能调试网络设备**

掌握工具

```c
ip
ifconfig
tcpdump
```

***

# 2. Linux 网络子系统简介

Linux 网络系统结构：

```c
User Application
       │
       ▼
Socket API
       │
       ▼
TCP/IP Protocol Stack
       │
       ▼
Network Device Driver
       │
       ▼
Network Hardware
```

例如：

```c
Ethernet
WiFi
CAN
```

***

# 3. Linux 网络设备

Linux 将网络设备表示为：

```c
net_device
```

系统中的设备：

```c
eth0
wlan0
can0
lo
```

查看设备：

```c
ip link
```

***

# 4. net\_device 结构

net\_device 表示：

```c
网络设备
```

结构：

```c
struct net_device
{
    char name[IFNAMSIZ];
    const struct net_device_ops *netdev_ops;
};
```

关键成员：

```c
name
netdev_ops
```

***

# 5. net\_device\_ops

net\_device\_ops 表示：

```c
网络设备操作接口
```

结构：

```c
struct net_device_ops
{
    int (*ndo_open)(struct net_device *);
    int (*ndo_stop)(struct net_device *);
    netdev_tx_t (*ndo_start_xmit)(struct sk_buff *,
                                  struct net_device *);
};
```

主要函数：

```c
open
stop
transmit
```

***

# 6. sk\_buff

Linux 网络数据使用：

```c
sk_buff
```

结构：

```c
struct sk_buff
{
    unsigned char *data;
    unsigned int len;
};
```

作用：

```c
表示网络数据包
```

例如：

```c
Ethernet frame
IP packet
TCP segment
```

***

# 7. Netdev 驱动注册流程

网络驱动基本流程：

```c
分配 net_device
      │
设置 net_device_ops
      │
register_netdev
      │
生成网络接口
```

流程图：

```c
Network Driver
       │
       ▼
alloc_netdev
       │
       ▼
register_netdev
       │
       ▼
eth0
```

***

# 8. 发送数据流程

发送流程：

```c
User Space
    │
send()
    │
TCP/IP Stack
    │
ndo_start_xmit
    │
Network Driver
    │
Hardware
```

驱动函数：

```c
ndo_start_xmit
```

示例：

```c
static netdev_tx_t my_xmit(struct sk_buff *skb,
                           struct net_device *dev)
{
    printk("send packet\n");

    dev_kfree_skb(skb);

    return NETDEV_TX_OK;
}
```

***

# 9. 接收数据流程

接收流程：

```c
Network Hardware
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
TCP/IP Stack
      │
      ▼
User Space
```

***

# 10. 网络驱动示例

简单网络驱动结构：

```c
static int my_net_open(struct net_device *dev)
{
    printk("net open\n");
    return 0;
}

static int my_net_stop(struct net_device *dev)
{
    printk("net stop\n");
    return 0;
}

static netdev_tx_t my_xmit(struct sk_buff *skb,
                           struct net_device *dev)
{
    printk("send packet\n");

    dev_kfree_skb(skb);

    return NETDEV_TX_OK;
}

static const struct net_device_ops my_netdev_ops =
{
    .ndo_open = my_net_open,
    .ndo_stop = my_net_stop,
    .ndo_start_xmit = my_xmit,
};
```

***

# 11. 驱动注册

分配设备：

```c
struct net_device *dev;

dev = alloc_netdev(0,"eth%d",NET_NAME_UNKNOWN,ether_setup);
```

注册设备：

```c
register_netdev(dev);
```

***

# 12. 用户空间管理网络

Linux 网络管理工具：

```c
ip
ifconfig
```

查看接口：

```c
ip link
```

启动接口：

```c
ip link set eth0 up
```

配置 IP：

```c
ip addr add 192.168.1.10/24 dev eth0
```

***

# 13. Netdev 子系统结构总结

Linux 网络驱动结构：

```c
User Space
   │
   ▼
Socket API
   │
   ▼
TCP/IP Stack
   │
   ▼
Network Driver
   │
   ▼
Hardware
```

核心结构：

```c
net_device
net_device_ops
sk_buff
```

***

# 14. 驱动常见问题

**网络接口不存在**

原因：

```c
register_netdev 没调用
```

***

**发送失败**

原因：

```c
ndo_start_xmit 未实现
```

***

**无法接收数据**

原因：

```c
IRQ 未注册
```

***

# 15. 总结

Linux 网络驱动核心结构：

```c
net_device
net_device_ops
sk_buff
```

关系：

```c
Network Stack
      │
      ▼
Network Driver
      │
      ▼
Hardware
```

最重要原则：

> **网络驱动 = TCP/IP Stack + net\_device**

# 16. Q\&A

## 16.1 基础理解

1. Linux 为什么把网络设备抽象为 net\_device?

2. sk\_buff 表示什么？

## 16.2 数据路径

1. 发送数据路径是什么？

2. 接收数据路径是什么？

## 16.3 驱动结构

1. nod\_start\_xmit 的作用是什么？

2. register\_netdev 做了什么？
