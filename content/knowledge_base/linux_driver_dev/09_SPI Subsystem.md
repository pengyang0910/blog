---
title: "9_Linux SPI 子系统（SPI Subsystem）"
date: 2026-03-13
draft: false
weight: 9
tags: ["Linux", "驱动开发", "内核"]
summary: "Linux SPI 子系统开发详解，包括 SPI 控制器/设备/驱动结构、spi_message/spi_transfer 数据传输、设备树配置及 SPI 驱动常见问题排查。"
ShowToc: true
TocOpen: false
---

# 1. 学习目标

1. **理解 SPI 总线工作原理**

理解 SPI 通信结构：

```c
Master
Slave
MOSI
MISO
CS
```

***

* **理解 Linux SPI 子系统架构**

理解 Linux SPI 驱动结构：

```c
spi_controller
spi_device
spi_drive
```

***

* **理解 SPI 驱动匹配机制**

理解 Linux 如何匹配：

```c
spi_device <-> spi_driver
```

并触发：

```c
probe()
```

***

* **能编写简单 SPI 驱动**

掌握核心 API：

```c
spi_register_driver
spi_sync
spi_write
spi_read
```

***

* **能调试 SPI 设备**

理解 SPI 数据传输：

```c
spi_message
spi_transfer
```

***

# 2. SPI 总线简介

SPI 是一种：

```c
高速同步串行通信总线
```

信号线：

```c
SCLK   时钟
MOSI   Master Out Slave In
MISO   Master In Slave Out
CS     Chip Select
```

结构：

```c
        Master
           │
           │
   ┌───────┼────────┐
   │       │        │
Slave1   Slave2   Slave3
```

特点：

```c
全双工
高速
主从结构
```

***

# 3. Linux SPI 子系统架构

Linux SPI 子系统结构：

```c
SPI Device Driver
        │
        ▼
      spi_core
        │
        ▼
   SPI Controller Driver
        │
        ▼
       Hardware
```

核心对象：

```c
spi_controller
spi_device
spi_driver
```

***

# 4. spi\_controller

spi\_controller 表示：

```c
SPI 控制器
```

例如：

```c
SoC SPI Controller
```

结构：

```c
struct spi_controller
{
    struct device dev;
    int (*transfer)(struct spi_controller *, struct spi_message *);
};
```

作用：

```c
实现 SPI 硬件控制
```

例如：

```c
发送时钟
读写数据
控制 cs
```

# 5. spi\_device

spi\_device 表示：

```c
SPI 设备
```

例如：

```c
SPI FLash
ADC
DAC
LCD 控制器
```

结构：

```c
struct spi_device
{
    struct spi_controller *controller;
    u32 max_speed_hz;
    u8 chip_select;
};
```

关键成员：

```c
chip_select
```

表示：

```c
SPI 设备片选
```

# 6. spi\_driver

spi\_driver 表示：

```c
SPI 设备驱动
```

结构：

```c
struct spi_driver
{
    int (*probe)(struct spi_device *);
    int (*remove)(struct spi_device *);

    struct device_driver driver;
};
```

核心函数：

```c
probe
remove
```

***

# 7. SPI 驱动匹配机制

Linux 会匹配：

```c
spi_device
spi_driver
```

匹配成功后：

```c
probe()
```

被调用。

流程：

```c
spi_device register
        │
spi_driver register
        │
match
        │
probe()
```

**匹配方式**
通常通过：

```c
device tree compatible
```

例如：

```c
compatible = "my-spi-device";
```

驱动：

```c
static const struct of_device_id my_spi_match[] =
{
    { .compatible = "my-spi-device" },
    { }
};
```

***

# 8. SPI 驱动注册

驱动注册：

```c
spi_register_driver()
```

示例：

```c
static struct spi_driver my_driver =
{
    .probe = my_probe,
    .remove = my_remove,
};
```

注册：

```c
module_spi_driver(my_driver);
```

***

# 9. SPI 数据传输

SPI 传输使用：

```c
spi_message
spi_transfer
```

结构：

```c
spi_message
    │
    └── spi_transfer
```

***

**spi\_transfer**

表示一次 SPI 传输：

```c
struct spi_transfer
{
    const void *tx_buf;
    void *rx_buf;
    unsigned int len;
};
```

***

**spi\_message**

表示一组 SPI 传输：

```c
struct spi_message
{
    struct list_head transfers;
};
```

***

# 10. SPI 传输示例

发送数据

```c
spi_write(spi, buf, len);
```

读取数据：

```c
spi_read(spi, buf, len);
```

全双工：

```c
spi_sync(spi, &message);
```

***

# 11. 驱动示例

简单 SPI 驱动：

```c
static int my_spi_probe(struct spi_device *spi)
{
    printk("spi device detected\n");

    spi_write(spi, "hello", 5);

    return 0;
}

static struct spi_driver my_driver =
{
    .driver =
    {
        .name = "my_spi",
    },
    .probe = my_spi_probe,
};

module_spi_driver(my_driver);
```

***

# 12. Device Tree 描述 SPI 设备

SPI 设备通常通过 Device Tree 描述。

示例：

```c
&spi1
{
    mydevice@0
    {
        compatible = "my-spi-device";
        reg = <0>;
        spi-max-frequency = <1000000>;
    };
};
```

解释：

```c
spi bus = spi1
chip select = 0
max speed = 1MHz
```

# 13. SPI 子系统结构总结

SPI 子系统结构：

```c
SPI Device Driver
        │
        ▼
      spi_core
        │
        ▼
   spi_controller
        │
        ▼
      Hardware
```

设备关系：

```c
spi_controller
      │
      ├── spi_device
      │
      └── spi_driver
```

# 14. 驱动常见问题

**probe 没有调用**
原因：

```c
compatible 不匹配
```

***

**SPI 数据错误**

原因：

```c
SPI mode 不一致
```

例如：

```c
CPOL
CPHA
```

***

**SPI 设备无法通信**

原因：

```c
CS 配置错误
```

***

# 15. 总结

Linux SPI 子系统核心结构：

```c
spi_controller
spi_device
spi_driver
```

关系：

```c
spi_controller
      │
      ├── spi_device
      │
      └── spi_driver
```

匹配成功：

```c
probe()
```

最重要原则：

> **SPI 驱动 = Device Model + SPI Bus**

# 16. Q\&A

## 16.1 总线理解

1. SPI 和 I2C 的区别是什么？

2. SPI 为什么更快？

***

## 16.2 Linux 架构

* spi\_controller 表示什么？

* spi\_device 表示什么？

***

## 16.3 驱动流程

* spi\_driver 的 probe 为什么会被调用？

* spi\_message 和 spi\_transfer 的区别？
