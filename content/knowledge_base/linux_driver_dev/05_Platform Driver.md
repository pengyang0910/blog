---
title: "5_Linux Platform 驱动（Platform Driver）"
date: 2026-03-13
draft: false
weight: 5
tags: ["Linux", "驱动开发", "内核"]
summary: "Linux Platform 驱动开发指南，讲解 platform_device/platform_driver 结构、设备树匹配机制、资源获取及嵌入式 SoC 设备驱动编写方法。"
ShowToc: true
TocOpen: false
---

# 1. 学习目标

1. **理解什么是 Platform Device**

理解嵌入式设备的特点：

```c
设备直接挂在 SoC 上
没有传统总线
```

例如：

```c
UART 控制器
GPIO 控制器
ADC
PWM
RTC
```

***

* **理解 Platform Driver 的作用**

理解 Linux 如何管理这些设备

```c
platform_device
platform_driver
```

* **理解驱动匹配机制**

理解 Linux 如何匹配设备和驱动：

```c
name match
device tree match
```

***

* **能编写基本 Platform Driver**

掌握核心函数：

```c
platform_driver_register
probe
remove
```

* 能从 Device Tree 获取硬件资源

掌握：

```c
寄存器地址
IRQ
GPIO
```

# 2. 为什么需要 Platform Driver

PC 系统设备通常通过总线连接：

```c
PCI
USB
SATA
```

设备可以自动枚举：

```c
PCI Scan
```

但嵌入式系统不同。

设备通常是：

```c
SoC 内部设备
```

例如：

```c
UART controller
I2C controller
SPI controller
```

这些设备：

```c
地址固定
不会自动发现
```

因此 Linux 需要一种机制描述它们：

```c
platform device
```

# 3. Platform 驱动整体结构

Platform 设备模型：

```c
Platform Bus
     │
     ├── platform_device
     │
     └── platform_driver
```

匹配流程：

```c
platform_device
        │
        │ match
        ▼
platform_driver
        │
        ▼
probe()
```

# 4. Platform 设备结构

Platform 设备结构：

```c
struct platform_device
{
    const char *name;
    int id;
    struct device dev;
};
```

核心成员

```c
name
```

用于匹配 driver

# 5. Platform Driver 结构

驱动结构：

```c
struct platform_driver
{
    int (*probe)(struct platform_device *);
    int (*remove)(struct platform_device *);

    struct device_driver driver;
};
```

核心函数：

```c
probe
remove
```

# 6. Platform 驱动匹配机制

Linux 会匹配：

```c
platform_device
platform_driver
```

匹配方式：

**1 name match**

```c
device.name == driver.name
```

**2 device tree match**

使用：

```c
compatible
```

例如：

```c
compatible = "my-uart";
```

# 7. Platform Driver 生命周期

完整流程：

```c
driver register
      │
device register
      │
driver match
      │
probe()
      │
device running
      │
remove()
```

# 8. probe 函数

当设备匹配成功时：

```c
probe()
```

被调用。

函数：

```c
int probe(struct platform_device *pdev)
```

主要工作：

```c
获取资源
初始化硬件
注册设备
```

# 9. remove 函数

驱动卸载时调用：

```c
int remove(struct platform_device *pdev)
```

主要工作：

```c
释放资源
关闭设备
```

# 10. Platform 资源（Resource）

设备资源包括：

```c
寄存器地址
IRQ
DMA
```

Linux 使用：

```c
struct resource
```

表示资源。

***

**获取寄存器地址**

```c
platform_get_resource()
```

示例：

```c
res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
```

***

**映射寄存器**

```c
ioremap()
```

示例：

```c
base = devm_ioremap_resource(&pdev->dev,res);
```

**获取中断**

```c
platform_get_irq()
```

示例：

```c
irq = platform_get_irq(pdev,0);
```

# 11. Platform Driver 示例

简单 Platform 驱动：

```c
static int my_probe(struct platform_device *pdev)
{
    printk("platform driver probe\n");
    return 0;
}

static int my_remove(struct platform_device *pdev)
{
    printk("platform driver remove\n");
    return 0;
}

static struct platform_driver my_driver =
{
    .probe = my_probe,
    .remove = my_remove,
    .driver =
    {
        .name = "my_device",
    },
};

module_platform_driver(my_driver);
```

# 12. Device Tree 与 Platform Driver

在嵌入式系统中：

```c
设备通常来自 Device Tree
```

示例：

```c
uart0: serial@10000000
{
    compatible = "my-uart";
    reg = <0x10000000 0x1000>;
    interrupts = <5>;
};
```

驱动匹配：

```c
static const struct of_device_id my_of_match[] =
{
    { .compatible = "my-uart" },
    { }
};
```

注册：

```c
.driver = {
    .name = "my_uart",
    .of_match_table = my_of_match,
}
```

# 13. Platform Driver 完整流程

完整流程：

```c
Device Tree
     │
     ▼
platform_device
     │
     ▼
platform bus
     │
     ▼
platform_driver
     │
     ▼
probe()
```

# 14. 驱动常见问题

**probe没有调用**

原因：

```c
compatible 不匹配
```

**resource获取失败**

原因：

```c
device tree错误
```

**ioremap失败**

原因：

```c
地址错误
```

# 15. 总结

Platform 驱动核心结构：

```c
Device Tree
      │
platform_device
      │
platform_bus
      │
platform_driver
      │
probe()
      │
Driver
```

最重要原则：

```c
设备描述 → Device Tree
驱动实现 → Platform Driver
```

# 16. Q\&A

## 16.1 基础理解

1. 为什么嵌入式 Linux 使用 platform driver？

2. platform device 和 platform driver 的关系？

***

## 16.2 匹配机制

1. compatible 的作用是什么？

2. probe 为什么会被调用？

***

## 16.3 资源管理

1. platform\_get\_resource 做什么？

2. 为什么需要 ioremap？

