---
title: "12_Linux RTC 驱动（RTC Subsystem）"
date: 2026-03-13
draft: false
weight: 12
tags: ["Linux", "驱动开发", "内核"]
summary: "Linux RTC 实时时钟驱动开发详解，涵盖 RTC 子系统架构、rtc_device/rtc_class_ops 结构、时间读写操作、闹钟功能及 hwclock 工具使用。"
ShowToc: true
TocOpen: false
---

# 1. 学习目标

1. **理解 RTC 的作用**

理解 RTC 在系统中的作用

```c
系统时间保存
掉电时间保持
闹钟功能
定时唤醒
```

***

* **理解 Linux RTC 子系统架构**

理解 RTC 驱动结构：

```c
User Space
   │
   ▼
RTC Core
   │
   ▼
RTC Driver
   │
   ▼
Hardware
```

***

* **理解 RTC 核心结构**

掌握核心对象：

```c
rtc_device
rtc_class_ops
rtc_time
```

***

* **能编写简单 RTC 驱动**

掌握核心 API：

```c
rtc_register_device
rtc_read_time
rtc_set_time
```

***

* **能使用用户空间工具操作 RTC**

掌握工具：

```c
hwclock
date
```

***

# 2. RTC 简介

RTC 表示：

```c
实时时钟
```

RTC 芯片通常具有：

```c
独立时钟
电池供电
```

因此在系统断电时：

```c
RTC 仍然运行
```

常见 RTC 芯片：

```c
DS1307
PCF8563
DS3231
```

***

# 3. Linux RTC 子系统架构

Linux RTC 子系统架构：

```c
User Space
    │
    ▼
RTC Core
    │
    ▼
RTC Driver
    │
    ▼
RTC Hardware
```

用户空间接口：

```c
/dev/rtc0
/dev/rtc1
```

***

# 4. RTC 核心结构

RTC 子系统核心结构：

```c
rtc_device
rtc_class_ops
rtc_time
```

***

# 5. rtc\_device

rtc\_device 表示：

```c
RTC 设备
```

结构：

```c
struct rtc_device
{
    struct device dev;
};
```

x系统中通常存在：

```c
/dev/rtc0
```

表示第一个 RTC 设备。

***

# 6. rtc\_class\_ops

rtc\_class\_ops 表示：

```c
RTC 操作接口
```

结构：

```c
struct rtc_class_ops
{
    int (*read_time)(struct device *, struct rtc_time *);
    int (*set_time)(struct device *, struct rtc_time *);
};
```

主要操作：

```c
读取时间
设置时间
```

***

# 7. rtc\_time

rtc\_time 表示：

```c
时间结构
```

结构：

```c
struct rtc_time
{
    int tm_sec;
    int tm_min;
    int tm_hour;
    int tm_mday;
    int tm_mon;
    int tm_year;
};
```

例如：

```c
2024-01-01 12:00:00
```

# 8. RTC 驱动注册流程

RTC 驱动基本流程：

```c
初始化驱动
      │
注册 rtc_device
      │
实现 rtc_class_ops
      │
用户空间访问
```

流程图：

```c
RTC Driver
     │
     ▼
rtc_register_device
     │
     ▼
RTC Core
     │
     ▼
/dev/rtc0
```

# 9. RTC 读取时间

驱动实现：

```c
rtc_read_time()
```

示例：

```c
static int my_rtc_read_time(struct device *dev,
                            struct rtc_time *tm)
{
    tm->tm_year = 124;
    tm->tm_mon = 0;
    tm->tm_mday = 1;
    tm->tm_hour = 12;
    tm->tm_min = 0;
    tm->tm_sec = 0;

    return 0;
}
```

# 10. RTC 设置时间

驱动实现：

```c
rtc_set_time()
```

示例：

```c
static int my_rtc_set_time(struct device *dev,
                           struct rtc_time *tm)
{
    printk("set rtc time\n");
    return 0;
}
```

# 11. RTC 驱动示例

简单 RTC 驱动结构：

```c
static const struct rtc_class_ops my_rtc_ops =
{
    .read_time = my_rtc_read_time,
    .set_time  = my_rtc_set_time,
};

static int my_rtc_probe(struct platform_device *pdev)
{
    struct rtc_device *rtc;

    rtc = devm_rtc_device_register(&pdev->dev,
                                   "my_rtc",
                                   &my_rtc_ops,
                                   THIS_MODULE);

    return 0;
}
```

# 12. 用户空间访问

Linux RTC 设备：

```c
/dev/rtc0
```

查看系统时间：

```c
date
```

查看 RTC 时间：

```c
hwclock
```

示例：

```c
hwclock -r
```

设置 RTC：

```c
hwclock -w
```

# 13. RTC 中断功能

很多 RTC 支持：

```c
闹钟中断
周期中断
```

例如：

```c
定时唤醒系统
```

流程：

```c
RTC alarm
    │
    ▼
IRQ
    │
    ▼
RTC Driver
```

# 14. Device Tree 描述 RTC

RTC 通常通过 I2C 连接。

Device Tree 示例：

```c
&i2c1
{
    rtc@68
    {
        compatible = "ds1307";
        reg = <0x68>;
    };
};
```

解释：

```c
I2C地址 = 0x68
```

# 15. RTC 子系统结构总结

RTC 子系统结构：

```c
User Space
   │
   ▼
RTC Core
   │
   ▼
RTC Driver
   │
   ▼
RTC Hardware
```

核心结构：

```c
rtc_device
rtc_class_ops
rtc_time
```

***

# 16. 驱动常见问题

**RTC 时间错误**

原因：

```c
RTC 时钟没有初始化
```

***

**hwclock 无法读取**

原因：

```c
rtc_device 没注册
```

***

**RTC 不保存时间**

原因：

```c
RTC 电池失效
```

***

# 17. 总结

Linux RTC 子系统核心结构：

```c
rtc_device
rtc_class_ops
rtc_time
```

关系：

```c
RTC Core
     │
     ▼
RTC Driver
     │
     ▼
Hardware
```

最重要原则：

> **RTC 驱动 = RTC Core + RTC Hardware**

# 18. Q\&A

## 18.1 基础理解

1. RTC 为什么在断电后还能保存时间？

2. RTC 和系统时间有什么区别？

***

## 18.2 Linux 架构

1. rtc\_device 表示什么？

2. rtc\_class\_ops 的作用是什么？

***

## 18.3 驱动流程

1. rtc\_read\_time 做了什么？

2. rtc\_register\_device 的作用是什么？
