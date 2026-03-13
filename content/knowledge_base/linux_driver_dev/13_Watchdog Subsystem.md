---
title: "13_Linux Watchdog 驱动（Watchdog Subsystem）"
date: 2026-03-13
draft: false
weight: 13
tags: ["Linux", "驱动开发", "内核"]
summary: "Linux Watchdog 看门狗驱动开发指南，包括看门狗工作原理、watchdog_device 结构、喂狗机制、超时处理及系统复位保护功能实现。"
ShowToc: true
TocOpen: false
---

# 1. 学习目标

1. **理解 Watchdog 的作用**

理解 Watchdog 的核心用途：

```c
系统死机检测
自动重启系统
系统可靠性保障
```

***

* **理解 Linux Watchdog 子系统架构**

理解 Watchdog 驱动结构：

```c
User Space
    │
    ▼
Watchdog Core
    │
    ▼
Watchdog Driver
    │
    ▼
Hardware
```

***

* **理解 Watchdog 核心结构**

掌握核心对象：

```c
watchdog_device
watchdog_ops
watchdog_info
```

***

* **能编写简单 Watchdog 驱动**

掌握 API：

```c
watchdog_register_device
watchdog_ping
watchdog_start
watchdog_stop
```

***

* **能使用用户空间工具控制 Watchdog**

掌握设备：

```c
/dev/watchdog
```

***

# 2. Watchdog 简介

Watchdog （看门狗）是一种：

```c
硬件定时器
```

工作原理：

```c
系统定期喂狗
```

如果系统没有喂狗：

```c
定时器超时
```

则：

```c
系统自动复位
```

***

**Watchdog 工作流程**

基本流程：

```c
系统启动
    │
    ▼
启动 Watchdog
    │
    ▼
定期喂狗
    │
    ▼
系统正常运行
```

如果系统死机：

```c
没有喂狗
```

则：

```c
Watchdog Reset
```

***

# 3. Linux Watchdog 子系统架构

Linux Watchdog 子系统结构：

```c
User Space
   │
   ▼
Watchdog Core
   │
   ▼
Watchdog Driver
   │
   ▼
Watchdog Hardware
```

用户空间设备：

```c
/dev/watchdog
```

# 4. Watchdog 核心结构

Watchdog 子系统核心结构：

```c
watchdog_device
watchdog_ops
watchdog_info
```

***

# 5. watchdog\_device

watchdog\_device 表示：

```c
Watchdog 设备
```

结构：

```c
struct watchdog_device
{
    const struct watchdog_ops *ops;
    unsigned int timeout;
};
```

关键成员：

```c
timeout
```

表示：

```c
Watchdog 超时时间
```

***

# 6. watchdog\_ops

watchdog\_ops 表示：

```c
Watchdog 操作接口
```

结构：

```c
struct watchdog_ops
{
    int (*start)(struct watchdog_device *);
    int (*stop)(struct watchdog_device *);
    int (*ping)(struct watchdog_device *);
};
```

主要操作：

```c
启动 Watchdog
停止 Watchdog
喂狗
```

***

# 7. watchdog\_info

watchdog\_info 表示：

```c
Watchdog 信息
```

结构：

```c
struct watchdog_info
{
    unsigned int options;
    const char *identity;
};
```

例如：

```c
设备名称
支持功能
```

***

# 8. Watchdog 驱动注册流程

Watchdog 驱动基本流程：

```c
初始化驱动
     │
注册 watchdog_device
     │
Watchdog Core
     │
生成 /dev/watchdog
```

流程图：

```c
Watchdog Driver
      │
      ▼
watchdog_register_device
      │
      ▼
Watchdog Core
      │
      ▼
/dev/watchdog
```

***

# 9. Watchdog 启动

驱动实现：

```c
watchdog_start()
```

示例：

```c
static int my_wdt_start(struct watchdog_device *wdt)
{
    printk("watchdog start\n");
    return 0;
}
```

# 10. Watchdog 停止

驱动实现：

```c
watchdog_stop()
```

示例：

```c
static int my_wdt_start(struct watchdog_device *wdt)
{
    printk("watchdog start\n");
    return 0;
}
```

***

# 11. Watchdog 喂狗

驱动实现：

```c
watchdog_ping()
```

示例：

```c
static int my_wdt_stop(struct watchdog_device *wdt)
{
    printk("watchdog stop\n");
    return 0;
}
```

***

# 12. Watchdog 驱动示例

简单 Watchdog 驱动结构：

```c
static const struct watchdog_ops my_wdt_ops =
{
    .start = my_wdt_start,
    .stop  = my_wdt_stop,
    .ping  = my_wdt_ping,
};

static struct watchdog_device my_wdt_dev =
{
    .ops = &my_wdt_ops,
    .timeout = 10,
};

static int __init my_wdt_init(void)
{
    watchdog_register_device(&my_wdt_dev);
    return 0;
}
```

***

# 13. 用户空间访问

Linux Watchdog 设备：

```c
/dev/watchdog
```

喂狗方法：

```c
write("/dev/watchdog")
```

示例：

```c
echo 1 > /dev/watchdog
```

***

**watchdog 工具**

Linux 提供工具：

```c
watchdog
```

配置：

```c
/etc/watchdog.conf
```

# 14. Watchdog 自动重启机制

如果系统：

```c
死机
```

无法执行：

```c
ping
```

则：

```c
Watchdog timeout
```

触发：

```c
System Reset
```

# 15. Device Tree 描述 Watchdog

Watchdog 设备通常在 Device Tree 中描述。

示例：

```c
watchdog@10030000
{
    compatible = "my-watchdog";
    reg = <0x10030000 0x1000>;
};
```

***

# 16. Watchdog 子系统结构总结

Watchdog 子系统结构：

```c
User Space
   │
   ▼
Watchdog Core
   │
   ▼
Watchdog Driver
   │
   ▼
Hardware
```

核心结构：

```c
watchdog_device
watchdog_ops
watchdog_info
```

***

# 17. 驱动常见问题

**Watchdog 无法启动**

原因：

```c
start 函数没有实现
```

***

Watchdog 不重启系统

原因：

```c
硬件 reset 未配置
```

***

**Watchdog 自动关闭**

原因：

```c
驱动 stop 被调用
```

***

# 18. 总结

Linux Watchdog 子系统核心结构：

```c
watchdog_device
watchdog_ops
watchdog_info
```

关系：

```c
Watchdog Core
      │
      ▼
Watchdog Driver
      │
      ▼
Hardware
```

最重要原则：

> **Watchdog 驱动 = Watchdog Core + Watchdog Hardware**

# 19. Q\&A

## 19.1 基础理解

1. Watchdog 为什么可以防止系统死机？

2. 为什么必须定期喂狗？

***

## 19.2 Linux 架构

1. watchdog\_device 表示什么？

2. watchdog\_ops 的作用是什么？

***

## 19.3 驱动流程

1. watchdog\_register\_device 做了什么？

2. watchdog\_ping 的作用是什么？

