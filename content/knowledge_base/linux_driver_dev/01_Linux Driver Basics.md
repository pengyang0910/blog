---
title: "1_Linux 驱动基础"
date: 2026-03-13
draft: false
weight: 1
tags: ["Linux", "驱动开发", "内核"]
summary: "Linux 驱动开发入门基础，涵盖驱动整体架构、设备模型、字符/块/网络设备分类，以及驱动调试方法和完整学习路线。"
ShowToc: true
TocOpen: false
---

# 1. 学习目标

学习 Linux 驱动的目标不是“会写驱动代码”，而是理解 Linux 如何管理硬件

完成学习后，需要具备以下能力：

1. 能理解 Linux 驱动整体架构

理解：

```bash
Linux Driver Architecture

用户空间
   │
   │  系统调用
   ▼
VFS (虚拟文件系统)
   │
   ▼
设备模型 (Device Model)
   │
   ├── bus
   ├── device
   ├── driver
   └── class
   │
   ▼
子系统 (Subsystem)
   │
   ├── char
   ├── net
   ├── input
   ├── iio
   ├── rtc
   └── usb
   │
   ▼
具体驱动
   │
   ▼
硬件
```

* 能独立编写基础驱动

掌握：

* 字符设备驱动

* platform 驱动

* I2C / SPI 驱动

* 中断驱动

* poll / select&#x20;

* 阻塞与非阻塞

- 理解 Linux 设备模型

理解：

```bash
device
driver
bus
class
```

以及：

```bash
platform bus
i2c bus
spi bus
usb bus
pci bus
```

* 能阅读 Linux 内核驱动源码

例如：

```bash
drivers/i2c
drivers/spi
drivers/input
drivers/net
drivers/usb
```

* 能 Debug 驱动问题

掌握：

```bash
printk
dmesg
devmem
trace
ftrace
```

# 2. Linux 驱动的本质

Linux 驱动本质只有一句话：

> 驱动就是把硬件接入 Linux 的设备模型

核心结构：

```bash
Linux Kernel

  Device Model
      │
      │
      ▼
   Subsystem
      │
      ▼
     Driver
      │
      ▼
    Hardware
```

# 3. Linux 驱动核心组成

Linux 驱动系统主要由四部分组成：

```bash
1 设备模型
2 驱动模型
3 I/O 接口
4 子系统
```

# 4. 设备模型（Device Model）

设备模型是 Linux 驱动的核心

结构：

```bash
bus
device
driver
class
```

关系：

```bash
           bus
            │
   ┌────────┴────────┐
 device             driver
```

当：

```bash
device.name == driver.name
```

Linux 会自动匹配并调用：

```bash
probe()
```

## 4.1 **设备模型的核心结构**

**struct device**

表示一个硬件设备。

例如：

```bash
I2C 设备
SPI 设备
USB 设备
Platform 设备
```

***

**struct device\_driver**

表示驱动程序。

例如：

```bash
i2c_driver
spi_driver
platform_driver
usb_driver
```

***

**struct bus\_type**

表示设备所在总线

例如：

```bash
platform_bus
i2c_bus
usb_bus
pci_bus
```

***

**struct class**

用于创建 /dev 设备节点

例如：

```bash
/dev/input
/dev/tty
/dev/video
```

# 5. Linux 驱动类型

Linux 驱动主要分为三类：

```bash
1 字符设备
2 块设备
3 网络设备
```

***

**字符设备**

特点：

```bash
按字节读写
无缓存
```

典型设备：

```bash
UART
GPIO
I2C
SPI
ADC
```

对应接口：

```bash
read()
write()
ioctl()
```

***

**块设备**

特点：

```bash
按块读写
有缓存
```

典型设备：

```bash
EMMC
SSD
SD卡
```

***

**网络设备**

特点：

```bash
面向数据包
```

例如：

```bash
Ethernet
WiFi
```

# 6. 字符设备驱动结构

字符设备是学习 Linux 驱动的入门

整体结构：

```bash
用户空间

open()
read()
write()

      │
      ▼

系统调用

      │
      ▼

VFS

      │
      ▼

file_operations

      │
      ▼

driver
```

***

**file\_operations**

核心结构：

```bash
struct file_operations
{
    open
    read
    write
    ioctl
    poll
    release
}
```

VFS 会调用这些函数

***

# 7. 驱动开发流程

一个最基本的字符设备驱动流程：

```bash
1 注册设备号
2 初始化 cdev
3 注册字符设备
4 创建设备节点
```

代码流程：

```bash
alloc_chrdev_regin()
cdev_init()
cdev_add()
class_create()
device_create()
```

# 8. Linux 驱动开发流程

驱动开发通常步骤：

```bash
1 确认硬件接口
2 确认设备树
3 编写驱动
4 编译内核模块
5 insmod 加载
6 测试设备
```

# 9. Linux 驱动调试方法

驱动开发最重要的是调试

常用方法：
**printk ：打印**

```bash
printk("driver init\n");
```

**dmesg ：查看**

```bash
dmesg
```

**devmem ：直接读写寄存器**

```bash
devmem 0x10000000
```

/proc /sys : 查看设备信息

```bash
/sys/class
/sys/bus
/proc/devices
```

# 10. Linux驱动学习路线

推荐学习顺序：

```bash
01 字符设备驱动
02 内核锁
03 中断
04 platform驱动
05 device model
06 input子系统
07 i2c
08 spi
09 uart
10 pwm
11 rtc
12 watchdog
13 can
14 net
15 adc
16 iio
17 usb
```

# 11. Q\&A

## 11.1 驱动基础

1. 为什么 Linux 需要 VFS ？

2. 为什么 file\_operations 必须存在？

3. open() 是如何进入驱动的？

## 11.2 设备模型

1. bus / device / driver 的关系是什么？

2. probe() 为什么会被调用？



## 11.3 platform 驱动

1. 为什么 Linux 大量使用 platform 设备？



## 11.4 中断

1. 为什么 ISR 不能使用 mutex ？

## 11.5 poll

1. poll 为什么必须配合 wait\_queue?
