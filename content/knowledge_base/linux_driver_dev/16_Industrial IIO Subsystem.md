---
title: "16_Linux IIO 驱动（Industrial I!O Subsystem）"
date: 2026-03-13
draft: false
weight: 16
tags: ["Linux", "驱动开发", "内核"]
summary: "Linux IIO 工业输入输出子系统开发指南，涵盖 IIO 架构、iio_dev/iio_chan_spec 结构、ADC/DAC 驱动开发、缓冲区采集及 sysfs 用户空间接口。"
ShowToc: true
TocOpen: false
---

# 1. 学习目标

1. **理解 IIO 子系统的作用**

理解 Linux 如何统一管理传感器设备：

```c
ADC
DAC
IMU
温度传感器
压力传感器
```

***

* **理解 Linux IIO 子系统架构**

理解 IIO 驱动结构：

```c
User Space
   │
   ▼
IIO Core
   │
   ▼
IIO Driver
   │
   ▼
Hardware
```

***

* **理解 IIO 核心结构**

掌握核心对象：

```c
iio_dev
iio_chan_spec
iio_info
```

***

* 理解 IIO 数据采集机制

掌握：

```c
Direct mode
Buffered mode
Trigger
```

***

* **能编写简单 IIO 驱动**

掌握 API：

```c
iio_device_alloc
iio_device_register
```

***

# 2. IIO 子系统简介

IIO 表示：

```c
工业输入输出系统
```

用于管理：

```c
模拟信号
传感器设备
数据采集设备
```

例如：

```c
ADC
DAC
IMU
温度传感器
光照传感器
```

***

# 3. Linux IIO 子系统架构

Linux IIO 子系统结构：

```c
User Space
    │
    ▼
Sysfs Interface
    │
    ▼
IIO Core
    │
    ▼
IIO Driver
    │
    ▼
Hardware
```

用户空间通常通过：

```c
/sys/bus/iio
```

访问设备。

***

# 4. IIO 核心结构

IIO 子系统核心对象：

```c
iio_dev
iio_chan_spec
iio_info
```

***

# 5. iio\_dev

iio\_dev 表示：

```c
一个 IIO 设备
```

结构：

```c
struct iio_dev
{
    struct device dev;
    const struct iio_info *info;
    const struct iio_chan_spec *channels;
    int num_channels;
};
```

作用：

```c
描述整个传感器设备
```

***

# 6. iio\_chan\_spec

iio\_chan\_spec 表示：

```c
传感器通道
```

例如：

```c
ADC0
ADC1
温度通道
加速度通道
```

结构：

```c
struct iio_chan_spec
{
    int type;
    int channel;
};
```

***

**示例**

定义 ADC 通道：

```c
static const struct iio_chan_spec adc_channels[] =
{
    {
        .type = IIO_VOLTAGE,
        .channel = 0,
    },
};
```

***

# 7. iio\_info

iio\_info 表示：

```c
IIO 设备操作接口
```

结构：

```c
struct iio_info
{
    int (*read_raw)(struct iio_dev *,
                    struct iio_chan_spec const *,
                    int *, int *, long);
};
```

作用：

```c
读取设备数据
```

***

# 8. IIO 驱动注册流程

IIO 驱动基本流程：

```c
分配 iio_dev
      │
配置 channel
      │
实现 iio_info
      │
iio_device_register
```

流程图：

```c
IIO Driver
      │
      ▼
iio_device_alloc
      │
      ▼
iio_device_register
      │
      ▼
/sys/bus/iio/devices
```

***

# 9. IIO 数据读取

驱动通过：

```c
read_raw()
```

返回数据。

示例：

```c
static int my_read_raw(struct iio_dev *indio_dev,
                       struct iio_chan_spec const *chan,
                       int *val, int *val2, long mask)
{
    *val = 1234;
    return IIO_VAL_INT;
}
```

# 10. IIO 驱动示例

简单 IIO 驱动：

```c
static const struct iio_info my_iio_info =
{
    .read_raw = my_read_raw,
};

static int my_probe(struct platform_device *pdev)
{
    struct iio_dev *indio_dev;

    indio_dev = devm_iio_device_alloc(&pdev->dev, 0);

    indio_dev->info = &my_iio_info;
    indio_dev->channels = adc_channels;
    indio_dev->num_channels = 1;

    iio_device_register(indio_dev);

    return 0;
}
```

# 11. 用户空间访问

IIO 设备位于：

```c
/sys/bus/iio/devices/
```

例如：

```c
/sys/bus/iio/devices/iio:device0
```

读取数据：

```c
cat in_voltages0_raw
```

输出：

```c
2048
```

***

# 12. Buffered Mode

IIO 支持：

```c
缓冲采样
```

用于：

```c
高速数据采集
```

例如：

```c
IMU
高速 ADC
```

结构：

```c
Trigger
Buffer
Driver
```

***

# 13. Trigger 机制

Trigger 表示：

```c
采样触发源
```

例如：

```c
定时器
外部中断
硬件事件
```

流程：

```c
Trigger
   │
   ▼
ADC sample
   │
   ▼
Buffer
```

***

# 14. IIO 子系统结构总结

Linux IIO 子系统结构：

```c
User Space
   │
   ▼
Sysfs
   │
   ▼
IIO Core
   │
   ▼
IIO Driver
   │
   ▼
Hardware
```

核心结构：

```c
iio_dev
iio_chan_spec
iio_info
```

# 15. 驱动常见问题

**sysfs 没有设备**

原因：

```c
iio_device_register 未调用
```

***

**无法读取数据**

原因：

```c
read_raw 未实现
```

***

**通道错误**

原因：

```c
iio_chan_spec 配置错误
```

***

# 16. 总结

Linux IIO 子系统核心结构：

```c
iio_dev
iio_chan_spec
iio_info
```

关系：

```c
IIO Core
     │
     ▼
IIO Driver
     │
     ▼
Hardware
```

最重要原则：

> **IIO 驱动 = IIO Framework  + Sensor Hardware**

# 17. Q\&A

## 17.1 架构理解

1. IIO 子系统主要管理哪些设备？

2. 为什么 ADC 驱动通常基于 IIO？

## 17.2 核心结构

1. iio\_dev 表示什么？

2. iio\_chan\_spec 表示什么？

## 17.3 驱动流程

1. iio\_device\_register 做了什么？

2. read\_raw 的作用是什么？

