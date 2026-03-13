---
title: "10_Linux UART 驱动（UART Driver）"
date: 2026-03-13
draft: false
weight: 10
tags: ["Linux", "驱动开发", "内核"]
summary: "Linux UART 驱动开发指南，涵盖 TTY 子系统、Serial Core、uart_driver/uart_port/uart_ops 结构、串口中断处理及用户空间串口访问方法。"
ShowToc: true
TocOpen: false
---

# 1. 学习目标

1. **理解 UART 通信原理**

理解 UART 基本结构：

```c
TX
RX
Baudrate
Start Bit
Stop Bit
```

***

* **理解 Linux UART 驱动架构**

理解 UART 驱动结构：

```c
TTY Core
Serial Core
UART Driver
Hardware
```

***

* **理解 Linux 串口设备结构**

理解 Linux 串口设备：

```c
/dev/ttyS0
/dev/ttyS1
```

***

* **能编写基础 UART 驱动**

掌握核心结构：

```c
uart_driver
uart_port
uart_ops
```

***

* **理解 UART 中断处理**

掌握：

```c
接收中断
发送中断
```

***

# 2. UART 简介

UART 是一种：

```c
异步串行通信接口
```

通信线：

```c
TX 发送
RX 接收
```

可选：

```c
RTS
CTS
```

***

**UART 通信结构**

UART 数据帧：

```c
Start Bit
Data Bit
Parity
Stop Bit
```

示例：

```c
| Start | Data | Stop |
```

特点：

```c
异步通信
无时钟线
```

***

# 3. Linux UART 驱动架构

Linux UART 驱动结构：

```c
User Space
    │
    ▼
TTY Subsystem
    │
    ▼
Serial Core
    │
    ▼
UART Driver
    │
    ▼
Hardware
```

***

TTY Subsystem

TTY 表示：

```c
终端设备
```

例如：

```c
终端
串口
伪终端
```

TTY设备：

```c
/dev/tty
/dev/ttyS0
/dev/pts/0
```

***

**Serial Core**

Serial Core 是：

```c
Linux 串口驱动框架
```

负责：

```c
统一管理串口驱动
```

# 4. UART 驱动核心结构

Linux UART 驱动核心结构：

```c
uart_driver
uart_port
uart_ops
```

***

# 5. uart\_driver

uart\_driver 表示：

```c
UART 驱动
```

结构：

```c
struct uart_driver
{
    const char *driver_name;
    const char *dev_name;
    int major;
    int minor;
};
```

作用：

```c
注册串口驱动
```

例如：

```c
ttyS
```

***

# 6. uart\_port

uart\_port 表示：

```c
UART 端口
```

结构：

```c
struct uart_port
{
    unsigned long iobase;
    int irq;
    unsigned int uartclk;
};
```

表示：

```c
串口硬件资源
```

例如：

```c
寄存器地址
IRQ
波特率时钟
```

***

# 7. uart\_ops

uart\_ops 表示：

```c
UART 操作接口
```

结构：

```c
struct uart_ops
{
    unsigned int (*tx_empty)(struct uart_port *);
    void (*set_mctrl)(struct uart_port *, unsigned int);
    void (*start_tx)(struct uart_port *);
    void (*stop_tx)(struct uart_port *);
};
```

这些函数负责：

```c
发送
接收
控制
```

# 8. UART 驱动注册流程

UART 驱动基本流程：

```c
注册 uart_driver
        │
初始化 uart_port
        │
uart_add_one_port
        │
生成 /dev/ttySx
```

流程图：

```c
uart_register_driver
        │
uart_add_one_port
        │
TTY subsystem
        │
/dev/ttyS0
```

# 9. UART 中断处理

UART 通常使用中断：

```c
RX interrupt
TX interrupt
```

例如：

```c
收到数据
```

流程：

```c
UART hardware
      │
      ▼
IRQ
      │
      ▼
ISR
      │
      ▼
tty buffer
```

***

**接收数据流程**

```c
Hardware RX
     │
     ▼
ISR
     │
     ▼
tty_insert_flip_char
     │
     ▼
tty_flip_buffer_push
```

# 10. UART 驱动示例

简单 UART 驱动结构：

```c
static struct uart_driver my_uart_driver =
{
    .driver_name = "my_uart",
    .dev_name = "ttyS",
};

static struct uart_port my_port =
{
    .iobase = 0x10000000,
    .irq = 5,
};

static int __init my_uart_init(void)
{
    uart_register_driver(&my_uart_driver);

    uart_add_one_port(&my_uart_driver,&my_port);

    return 0;
}
```

***

# 11. 用户空间访问

Linux 串口设备：

```c
/dev/ttyS0
/dev/ttyS1
```

用户程序访问：

```c
open("/dev/ttyS0")
read()
write()
```

***

**串口**

常用工具：

```c
minicom
screen
picocom
```

示例：

```c
screen /dev/ttyS0 115200
```

***

# 12. Device Tree 描述 UART

UART 通常 Device Tree 中描述。

示例：

```c
serial@10000000
{
    compatible = "my-uart";
    reg = <0x10000000 0x1000>;
    interrupts = <5>;
};
```

***

# 13. UART 驱动结构总结

UART 驱动结构：

```c
User Space
   │
   ▼
TTY Subsystem
   │
   ▼
Serial Core
   │
   ▼
UART Driver
   │
   ▼
Hardware
```

核心结构：

```c
uart_driver
uart_port
uart_ops
```

***

# 14. 驱动常见问题

**串口没有设备节点**

原因：

```c
uart_register_driver 没调用
```

***

**串口无法发送**

原因：

```c
波特率配置错误
```

***

**接收数据错误**

原因：

```c
UART 时钟错误
```

***

# 15. 总结

Linux UART 驱动核心结构：

```c
TTY Subsystem
      │
Serial Core
      │
UART Driver
      │
Hardware
```

关键结构：

```c
uart_driver
uart_port
uart_ops
```

最重要原则：

> **UART 驱动 = TTY 子系统 + Serial Core**

# 16. Q\&A

## 16.1 基础理解

1. UART 为什么不需要时钟线？

2. Start Bit 和 Stop Bit 的作用是什么？

***

## 16.2 Linux 架构

1. TTY 子系统的作用是什么？

2. Serial Core 为什么存在？

***

## 16.3 驱动结构

1. uart\_port 表示什么？

2. uart\_ops 的作用是什么？
