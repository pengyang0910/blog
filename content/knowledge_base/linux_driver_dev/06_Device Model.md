---
title: "6_Linux 设备模型（Device Model）"
date: 2026-03-13
draft: false
weight: 6
tags: ["Linux", "驱动开发", "内核"]
summary: "Linux 设备模型核心原理解析，包括 bus/device/driver/class 四大对象、驱动匹配机制、sysfs 文件系统及设备模型在各子系统中的实现。"
ShowToc: true
TocOpen: false
---

# 1. 学习目标

1. **理解 Linux 为什么需要设备模型**

理解 Linux 如何统一管理：

```c
CPU
内存
外设
总线
驱动
```

***

* **理解 Device Model 核心结构**

理解四个核心对象：

```c
bus
device
driver
class
```

***

* **理解驱动匹配机制**

理解 Linux 如何匹配：

```c
device <-> driver
```

并触发：

```c
probe()
```

***

* **理解 sysfs 与设备模型关系**

理解：

```c
/sys
```

目录如何反映设备结构

***

* **理解 Device Model 在驱动中的作用**

理解 Linux 驱动架构：

```c
bus
device
driver
```

以及：

```c
platform
i2c
spi
usb
```

都是 Device Model 的实现

***

# 2. 为什么需要设备模型

早期 Linux 驱动结构比较简单：

```c
driver <-> hardware
```

问题是：

```c
设备越来越多
总线越来越复杂
```

例如：

```c
PCI
USB
I2C
SPI
Platform
```

Linux 需要一个统一框架管理设备。

于是引入：

> Linux Device Model

# 3. Device Model 核心结构

Linux 设备模型核心结构：

```c
bus
device
driver
class
```

关系结构：

```c
           bus
            │
    ┌───────┴────────┐
 device             driver
```

当：

```c
device 与 driver 匹配
```

Linux 自动调用：

```c
probe()
```

# 4. bus（总线）

总线表示：

```c
设备连接方式
```

例如：

```c
PCI
USB
I2C
SPI
platform
```

Linux 使用：

```c
struct bus_type
```

表示总线：

示例：

```c
struct bus_type i2c_bus_type
```

**bus 的作用**

bus 主要负责：

```c
管理 device
管理 driver
匹配 device 和 driver
```

匹配流程：

```c
device register
driver register
bus match
probe()
```

# 5. device（设备）

device 表示：

```c
一个硬件设备
```

例如：

```c
UART controller
I2C device
SPI flash
USB camera
```

Linux 使用：

```c
struct device
```

表示设备。

***

**struct device**

核心成员：

```c
struct device
{
    struct device *parent;
    struct bus_type *bus;
    struct device_driver *driver;
};
```

关键成员：

```c
bus
driver
```

# 6. driver （驱动）

driver 表示：

```c
设备驱动程序
```

Linux 使用：

```c
struct device_driver
```

结构：

```c
struct device_driver
{
    const char *name;
    struct bus_type *bus;
};
```

驱动会注册到：

```c
bus
```

# 7. device 与 driver 匹配

Linux 会在 bus 上匹配：

```c
device
driver
```

匹配成功后：

```c
probe()
```

被调用。

流程：

```c
driver register
      │
device register
      │
bus match
      │
probe()
```

**示例**

例如：

```c
i2c device
```

匹配：

```c
i2c driver
```

成功后：

```c
i2c_probe()
```

被调用。

# 8. class（设备类）

class 用于：

```c
用户空间设备管理
```

例如：

```c
/dev/input
/dev/tty
/dev/video
```

Linux 使用：

```c
struct class
```

表示设备类。

***

**class 结构**

class 用于：

```c
创建设备节点
```

例如：

```c
/dev/mydev
```

代码：

```c
class_create()
device_create()
```

# 9. sysfs 与 Device Model

Linux 通过：

```c
sysfs
```

展示设备模型。

路径：

```c
/sys
```

例如：

```c
/sys/bus
/sys/devices
/sys/class
```

**/sys/bus**

表示系统总线：

```c
/sys/bus/i2c
/sys/bus/spi
/sys/bus/platform
```

**/sys/devices**

表示系统设备：

```c
/sys/devices/platform
```

***

**/sys/calss**

表示类：

```c
/sys/class/input
/sys/class/net
```

# 10. Device Model 层次结构

完整结构：

```c
               device
                 │
                 │
               bus
                 │
        ┌────────┴────────┐
     driver              class
```

更完整架构：

```c
Hardware
   │
   ▼
Device
   │
   ▼
Bus
   │
   ▼
Driver
   │
   ▼
Subsystem
```

# 11. Device Model 与驱动关系

Linux 所有驱动都基于 Device Model。

例如：

| 子系统      | bus          |
| -------- | ------------ |
| platform | platform bus |
| i2c      | i2c bus      |
| spi      | spi bus      |
| usb      | usb bus      |
| pci      | pci bus      |

***

示例

I2C 驱动结构：

```c
i2c bus
   │
   ├── i2c device
   │
   └── i2c driver
```

# 12. Device Model 工作流程

完整流程：

```c
Device register
      │
Driver register
      │
Bus match
      │
probe()
      │
Driver init
```

# 13. Deive Model 示例

例如：

```c
SPI Flash
```

系统结构：

```c
SPI bus
   │
spi_device
   │
spi_driver
   │
probe()
```

# 14. 驱动常见问题

**probe 没有调用**

原因：

```c
device 与 driver 不匹配
```

例如：

```c
compatible 不一致
```

**sysfs 没有设备**

原因：

```c
device 没有注册
```

**设备节点不存在**

原因：

```c
class 未创建
```

# 15. 总结

Linux Device Model 核心结构：

```c
bus
device
driver
class
```

关系：

```c
bus
 │
 ├── device
 │
 └── driver
```

匹配成功：

```c
probe()
```

最重要原则：

> Linux 驱动 = Device Model + Subsystem

***

# 16. Q\&A

## 16.1 结构理解

1. 为什么 Linux 需要 Device Model？

2. bus 的作用是什么？



## 16.2 设备匹配

1. device 和 driver 如何匹配？

2. probe 为什么会被调用？

## 16.3 sysfs

1. `/sys/bus` 和 `/sys/devices` 有什么区别？

2. `/sys/class` 的作用是什么？
