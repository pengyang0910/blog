---
title: "17_Linux USB 驱动（USB Subsystem）"
date: 2026-03-13
draft: false
weight: 17
tags: ["Linux", "驱动开发", "内核"]
summary: "Linux USB 子系统驱动开发详解，包括 USB 总线架构、usb_device/usb_interface/usb_driver 结构、URB 数据传输、设备枚举流程及 USB 驱动匹配机制。"
ShowToc: true
TocOpen: false
---

# 1. 学习目标

1. **理解 USB 总线工作原理**

理解 USB 通信结构：

```c
Host
Device
Hub
Endpoint
```

***

* **理解 Linux USB 子系统架构**

理解 USB 驱动结构：

```c
User Space
    │
    ▼
USB Core
    │
    ▼
USB Driver
    │
    ▼
USB Device
```

***

* **理解 USB 核心结构**

掌握核心对象：

```c
usb_device
usb_interface
usb_driver
```

***

* **理解 USB 枚举流程**

理解 Linux 如何识别 USB 设备：

```c
Device Plug
Device Enumeration
Driver Match
Probe
```

***

* **能编写简单 USB 驱动**

掌握API：

```c
usb_register
usb_alloc_urb
usb_submit_urb
```

***

# 2. USB 总线简介

USB 是一种：

```c
主从结构通信总线
```

系统结构：

```c
USB Host
   │
   ▼
USB Hub
   │
   ▼
USB Device
```

例如：

```c
键盘
鼠标
U盘
摄像头
WiFi
```

***

# 3. USB 通信结构

USB 通信通过：

```c
Endpoint
```

进行。

设备结构：

```c
Device
   │
   ▼
Configuration
   │
   ▼
Interface
   │
   ▼
Endpoint
```

***

**Endpoint 类型**

USB Endpoint 类型

```c
Control
Bulk
Interrupt
Isochronous
```

用途：

```c
Control     控制传输
Bulk        大数据传输
Interrupt   小数据快速传输
Isochronous 实时数据
```

***

# 4. Linux USB 子系统架构

Linux USB 子系统结构：

```c
User Space
    │
    ▼
USB Core
    │
    ▼
USB Driver
    │
    ▼
USB Host Controller
    │
    ▼
USB Device
```

例如：

```c
xhci
ehci
uhci
```

***

# 5. USB 核心结构

USB 驱动核心对象：

```c
usb_device
usb_interface
usb_driver
```

***

# 6. usb\_device

usb\_deive 表示：

```c
USB 设备
```

结构：

```c
struct usb_device
{
    struct device dev;
};
```

表示：

```c
USB 硬件设备
```

***

# 7. usb\_interface

USB 设备可以有多个：

```c
Interface
```

例如：

```c
USB 摄像头
   ├─ 视频接口
   └─ 控制接口
```

结构：

```c
struct usb_interface
{
    struct usb_host_interface *altsetting;
};
```

***

# 8. usb\_driver

usb\_driver 表示：

```c
USB 设备驱动
```

结构：

```c
struct usb_driver
{
    const char *name;

    int (*probe)(struct usb_interface *,
                 const struct usb_device_id *);

    void (*disconnect)(struct usb_interface *);
};
```

核心函数：

```c
probe
discoonnect
```

***

# 9. USB 驱动匹配机制

USB 驱动通过：

```c
VID
PID
```

匹配设备。

例如：

```c
Vendor ID
product ID
```

驱动定义：

```c
static const struct usb_device_id id_table[] =
{
    { USB_DEVICE(0x1234,0x5678) },
    { }
};
```

***

# 10. USB 驱动注册流程

USB 驱动基本流程：

```c
定义 usb_driver
      │
usb_register
      │
USB Core
      │
设备匹配
      │
probe()
```

流程图：

```c
USB Device Plug
      │
      ▼
USB Core
      │
      ▼
Match Driver
      │
      ▼
Probe
```

# 11. USB 数据传输

USB 数据传输使用：

```c
URB
```

URB 表示：

```c
USB Request Block
```

结构：

```c
struct urb
{
    struct usb_device *dev;
    void *transfer_buffer;
};
```

***

**URB 传输流程**

```c
Driver
   │
   ▼
usb_alloc_urb
   │
   ▼
usb_submit_urb
   │
   ▼
USB Controller
```

# 12. USB 驱动示例

简单 USB 驱动：

```c
static int my_probe(struct usb_interface *interface,
                    const struct usb_device_id *id)
{
    printk("USB device connected\n");
    return 0;
}

static void my_disconnect(struct usb_interface *interface)
{
    printk("USB device disconnected\n");
}

static struct usb_driver my_driver =
{
    .name = "my_usb",
    .probe = my_probe,
    .disconnect = my_disconnect,
    .id_table = id_table,
};
```

注册：

```c
usb_register(&my_driver);
```

# 13. 用户空间查看 USB

查看 USB 设备

```c
lsusb
```

查看 USB 拓扑：

```c
lsusb -t
```

查看内核信息：

```c
dmesg
```

***

# 14. USB 设备节点

USB 设备通常通过：

```c
udev
```

创建设备节点。

例如：

```c
/dev/ttyUSB0
/dev/video0
/dev/hidraw0
```

***

# 15. USB 子系统结构总结

Linux USB 子系统结构：

```c
User Space
   │
   ▼
USB Core
   │
   ▼
USB Driver
   │
   ▼
USB Host Controller
   │
   ▼
USB Device
```

核心结构：

```c
usb_device
usb_interface
usb_driver
```

***

# 16. 驱动常见问题

**USB 设备无法识别**

原因：

```c
VID/PID 不匹配
```

***

**probe 未调用**

原因：

```c
id_table 未配置
```

***

**数据传输失败**

原因：

```c
Endpoint 类型错误
```

***

# 17. 总结

Linux USB 子系统核心结构：

```c
usb_device
usb_interface
usb_driver
```

关系：

```c
USB Core
     │
     ▼
USB Driver
     │
     ▼
USB Device
```

最重要原则：

> **USB 驱动 = USB Core + USB Device**

# 18. Q\&A

## 18.1 基础理解

1. USB 为什么采用 Host/Device 架构？

2. Endpoint 的作用是什么？

***

## 18.2 Linux 架构

1. usb\_interface 表示什么？

2. usb\_driver 的 probe 为什么会被调用？

***

## 18.3 驱动流程

1. URB 的作用是什么？

2. usb\_submit\_urb 做了什么？

