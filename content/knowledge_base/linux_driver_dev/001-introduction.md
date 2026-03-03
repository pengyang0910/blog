---
title: "Linux 驱动开发：基础介绍"
date: 2026-03-03
draft: false
weight: 1
tags: ["Linux", "驱动开发", "内核"]
summary: "Linux 驱动程序的基本概念、分类与开发流程概述。"
ShowToc: true
TocOpen: false
---

## 什么是 Linux 驱动？

Linux 驱动程序（Device Driver）是操作系统内核与硬件设备之间的桥梁。它运行在内核空间，负责控制硬件、向上层提供统一的访问接口。

```
用户程序 (user space)
    ↓  系统调用 (syscall)
内核 (kernel space)
    ↓  驱动接口
硬件设备 (hardware)
```

---

## 驱动的三大分类

| 类型 | 说明 | 典型设备 |
|------|------|---------|
| **字符设备** | 按字节流顺序访问 | 串口、键盘、传感器 |
| **块设备** | 以固定大小块随机访问 | 硬盘、SD卡、eMMC |
| **网络设备** | 通过 socket 接口访问 | 网卡、WiFi 模块 |

---

## 内核模块基础

Linux 驱动以**内核模块（Kernel Module）**的形式存在，可以动态加载/卸载，无需重新编译内核。

### 最简单的内核模块

```c
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>

static int __init hello_init(void)
{
    printk(KERN_INFO "Hello, Linux Driver!\n");
    return 0;
}

static void __exit hello_exit(void)
{
    printk(KERN_INFO "Goodbye, Linux Driver!\n");
}

module_init(hello_init);
module_exit(hello_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Parry");
MODULE_DESCRIPTION("A simple hello world driver");
```

### 常用命令

```bash
# 编译模块
make -C /lib/modules/$(uname -r)/build M=$(pwd) modules

# 加载模块
sudo insmod hello.ko

# 查看已加载模块
lsmod | grep hello

# 查看内核日志
dmesg | tail

# 卸载模块
sudo rmmod hello
```

---

## 驱动开发的基本流程

1. **分析硬件** — 阅读数据手册，了解寄存器地址、时序要求
2. **选择驱动类型** — 字符设备 / 块设备 / 网络设备
3. **编写驱动代码** — 实现 `probe`、`remove`、`file_operations` 等接口
4. **编写 Makefile** — 配置内核模块编译
5. **编译 & 测试** — 交叉编译后在目标板上测试
6. **编写设备树** — 在嵌入式平台上描述硬件信息（DTS）

---

## 重要的内核 API

| API | 用途 |
|-----|------|
| `printk()` | 内核日志输出 |
| `kmalloc() / kfree()` | 内核内存分配/释放 |
| `copy_to_user()` | 内核 → 用户空间数据拷贝 |
| `copy_from_user()` | 用户空间 → 内核数据拷贝 |
| `request_irq()` | 注册中断处理函数 |
| `ioremap()` | 将物理地址映射到内核虚拟地址 |

---

## 开发环境准备

```bash
# 安装内核头文件（Ubuntu）
sudo apt install linux-headers-$(uname -r)

# 安装编译工具链
sudo apt install build-essential

# 嵌入式交叉编译（ARM）
sudo apt install gcc-arm-linux-gnueabihf
```

---

## 参考资料

- [The Linux Kernel documentation](https://www.kernel.org/doc/html/latest/)
- 《Linux 设备驱动程序》（第三版）— Jonathan Corbet 等著
- 《嵌入式 Linux 驱动开发实战》
