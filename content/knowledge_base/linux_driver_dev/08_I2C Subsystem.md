---
title: "8_Linux I2C 子系统（I2C Subsystem）"
date: 2026-03-13
draft: false
weight: 8
tags: ["Linux", "驱动开发", "内核"]
summary: "Linux I2C 子系统开发指南，讲解 I2C 总线架构、i2c_adapter/i2c_client/i2c_driver 结构、设备树匹配、数据传输 API 及用户空间调试工具使用。"
ShowToc: true
TocOpen: false
---

# 1. 学习目标

1. **理解 I2C 总线工作原理**

理解 I2C 总线结构：

```c
Master
Slave
SCL
SDA
```

以及通信方式：

```c
地址
读写
ACK
```

***

* **理解 Linux I2C 子系统架构**

理解 Linux I2C 驱动结构：

```c
i2c_adapter
i2c_client
i2c_driver
```

***

* **理解 I2C 设备匹配机制**

理解 Linux 如何匹配：

```c
i2c_device <-> i2c_driver
```

并触发：

```c
probe()
```

***

* **能编写简单 I2C 驱动**

掌握核心 API：

```c
i2c_add_driver
i2c_transfer
i2c_smbus_read_byte
```

***

* **能调试 I2C 设备**

掌握工具：

```c
i2cdetest
i2cget
i2cset
```

# 2. I2C 总线简介

I2C 是一种：

```c
两线串行通信总线
```

信号线：

```c
SCL 时钟
SDA 数据
```

结构：

```c
        Master
           │
           │
 ┌─────────┴─────────┐
 │         │         │
Slave1   Slave2    Slave3
```

**I2C 通信流程**

基本通信流程：

```c
Start
Address
Read/Write
Data
Stop
```

示例：

```c
Master -> Slave Address
Slave -> ACK
Master -> Data
Slave -> ACK
```

***

# 3. Linux I2C 子系统架构

Linux I2C 系统结构：

```c
I2C Device Driver
        │
        ▼
     i2c_core
        │
        ▼
   I2C Adapter Driver
        │
        ▼
      Hardware
```

三个核心对象：

```c
i2c_adapter
i2c_client
i2c_driver
```

***

# 4. i2c\_adapter

i2c\_adapter 表示：

```c
I2C 控制器
```

例如：

```c
SoC I2C Controller
```

结构：

```c
struct i2c_adapter
{
    struct device dev;
    const struct i2c_algorithm *algo;
}
```

作用：

```c
实现 I2C 硬件操作
```

例如：

```c
start
stop
read
write
```

***

# 5. i2c\_client

i2c\_client 表示：

```c
I2C 从设备
```

例如：

```c
EEPROM
RTC
温度传感器
```

结构：

```c
struct i2c_client
{
    unsigned short addr;
    struct i2c_adapter *adapter;
}
```

关键成员：

```c
addr
```

表示：

```c
I2C 从设备地址
```

***

# 6. i2c\_driver

i2c\_driver 表示：

```c
I2C 设备驱动
```

结构：

```c
struct i2c_driver
{
    int (*probe)(struct i2c_client *);
    int (*remove)(struct i2c_client *);

    const struct i2c_device_id *id_table;
};
```

核心函数：

```c
probe
remove
```

# 7. I2C 驱动匹配机制

Linux 会匹配：

```c
i2c_client
i2c_driver
```

匹配成功后：

```c
probe()
```

被调用。

流程：

```c
i2c_client register
        │
i2c_driver register
        │
match
        │
probe()
```

***

**匹配方式**

匹配通常使用：

```c
device tree compatible
```

例如：

```c
compatible = "at24c02"
```

驱动：

```c
static const struct of_device_id my_of_match[] =
{
    { .compatible = "at24c02" },
    { }
};
```

***

# 8. I2C 驱动注册

驱动注册：

```c
i2c_add_driver()
```

示例：

```c
static struct i2c_driver my_driver =
{
    .probe = my_probe,
    .remove = my_remove,
};
```

注册：

```c
module_i2c_driver(my_driver);
```

# 9. I2C 数据传输

Linux 提供两种主要接口：

```c
i2c_transfer
SMBus API
```

***

**i2c\_transfer**

底层接口：

```c
i2c_transfer()
```

示例：

```c
struct i2c_msg msg;

msg.addr = client->addr;
msg.flags = 0;
msg.len = len;
msg.buf = buf;

i2c_transfer(client->adapter,&msg,1);
```

***

**SMBus 接口**

更简单：

```c
i2c_smbus_read_byte()
i2c_smbus_write_byte()
```

示例：

```c
data = i2c_smbus_read_byte(client);
```

***

# 10. I2C 驱动示例

简单 I2C 驱动：

```c
static int my_probe(struct i2c_client *client,
                    const struct i2c_device_id *id)
{
    printk("i2c device detected\n");

    return 0;
}

static const struct i2c_device_id my_id[] =
{
    { "my_sensor", 0 },
    { }
};

static struct i2c_driver my_driver =
{
    .driver =
    {
        .name = "my_sensor",
    },
    .probe = my_probe,
    .id_table = my_id,
};

module_i2c_driver(my_driver);
```

***

# 11. Device Tree 描述 I2C 设备

I2C 设备通常在 Device Tree 中描述

示例：

```c
&i2c1
{
    temp@48
    {
        compatible = "my_sensor";
        reg = <0x48>;
    };
};
```

解释：

```c
i2c bus = i2c1
device address = 0x48
```

***

# 12. 用户空间 I2C 工具

Linux 提供 I2C 工具：

```c
i2cdetect
i2cget
i2cset
```

***

**i2cdetect**

扫描设备：

```c
i2cdetect -y 1
```

输出：

```c
00: -- -- -- 48 -- --
```

表示：

```c
设备地址 0x48
```

***

**i2cget**

读取寄存器

```c
i2cget -y 1 0x48
```

***

**i2cset**

写寄存器

```c
i2cset -y 1 0x48 0x01
```

***

# 13. I2C 子系统结构总结

I2C 子系统结构：

```c
I2C Device Driver
        │
        ▼
      i2c_core
        │
        ▼
    i2c_adapter
        │
        ▼
       Hardware
```

设备结构：

```c
i2c_adapter
     │
     ├── i2c_client
     │
     └── i2c_driver
```

# 14. 驱动常见问题

**probe 没有调用**

原因：

```c
compatible 不匹配
```

***

**I2C 读写失败**

原因：

```c
设备地址错误
```

***

**i2cdetect 找不到设备**

原因：

```c
I2C 硬件没有初始化
```

# 15. 总结

Linux I2C 子系统核心结构：

```c
i2c_adapter
i2c_client
i2c_driver
```

关系：

```c
i2c_adapter
      │
      ├── i2c_client
      │
      └── i2c_driver
```

匹配成功：

```c
probe()
```

最重要原则：

> **I2C 驱动 = Device Model + I2C Bus**

***

# 16. Q\&A

## 16.1 总线理解

1. I2C Master 和 Slave 的区别？

2. SDA 和 SCL 的作用？

***

## 16.2 Linux 架构

1. i2c\_adapter 表示什么？

2. i2c\_client 表示什么？

***

## 16.3 驱动流程

1. i2c\_driver 的 probe 为什么会被调用？

2. i2c\_transfer 的作用是什么？
