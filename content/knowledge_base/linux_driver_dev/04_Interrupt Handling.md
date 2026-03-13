---
title: "4_Linux 中断机制（Interrupt Handling）"
date: 2026-03-13
draft: false
weight: 4
tags: ["Linux", "驱动开发", "内核"]
summary: "Linux 中断处理机制详解，涵盖中断注册/释放、Top Half/Bottom Half、tasklet、workqueue、共享中断及中断风暴等常见问题处理。"
ShowToc: true
TocOpen: false
---

# 1. 学习目标

1. **理解 Linux 中断的作用**

理解：

```c
硬件如何通知 CPU
```

例如：

```c
按键按下
UART 收到数据
网络收到数据
定时器到期
```

***

* **理解 Linux 中断处理流程**

能够解释完整流程：

```c
Hardware
   │
   ▼
IRQ
   │
   ▼
Interrupt Controller
   │
   ▼
CPU
   │
   ▼
ISR（中断处理函数）
   │
   ▼
Driver
```

***

* 能编写基础中断驱动

掌握：

```c
request_irq
free_irq
irq_handler
```

* **理解 Top Half / Bottom Half**

理解：

```c
Top Half
Bottom Half
```

以及：

```c
tasklet
workqueue
```

* 能分析驱动中的中断问题

例如：

```c
中断丢失
中断风暴
中断共享
```

# 2. 什么是中断

中断是：

> 硬件通知 CPU 的一种机制

如果没有中断，CPU 必须：

```c
while(1)
{
    检查设备
}
```

这种方式叫：

```c
Polling(轮询)
```

效率极低

***

**中断方式**

设备主动通知 CPU：

```c
设备
  │
IRQ信号
  │
CPU
```

CPU 立即处理

# 3. Linux 中断整体结构

Linux 中断系统结构：

```c
Hardware Device
      │
      ▼
Interrupt Controller
      │
      ▼
IRQ Number
      │
      ▼
Kernel IRQ Subsystem
      │
      ▼
Driver ISR
```

例如：

```c
GPIO
UART
Network
Timer
```

# 4. 中断号（IRQ）

每个中断都有编号：

```c
IRQ number
```

例如：

```c
IRQ 0   timer
IRQ 1   keyboard
IRQ 14  disk
```

驱动需要：

```c
注册 IRQ
```

# 5. 中断处理函数

驱动必须提供：

```c
ISR（Interrupt Service Routine）
```

函数格式：

```c
irqreturn_t handler(int irq, void *dev)
```

示例：

```c
irqreturn_t my_irq_handler(int irq, void *dev_id)
{
    printk("interrupt occurred\n");
    return IRQ_HANDLED;
}
```

返回值：

```c
IRQ_HANDLED
IRQ_NONE
```

# 6. 中断注册

驱动使用：

```c
request_irq()
```

注册中断。

函数：

```c
int request_irq(unsigned int irq,
                irq_handler_t handler,
                unsigned long flags,
                const char *name,
                void *dev);
```

参数说明：

**示例**

```c
request_irq(irq_num,
            my_irq_handler,
            IRQF_SHARED,
            "my_device",
            dev);
```

# 7. 释放中断

驱动卸载时：

```c
free_irq()
```

示例：

```c
free_irq(irq_num, dev);
```

# 8. 中断执行上下文

中断运行在：

```c
Interrupt Context
```

特点：

```c
不能睡眠
不能调度
必须快速完成
```

因此：

```c
不能使用 mutex
不能使用 msleep
```

# 9. Top Half / Bottom Half

Linux 将中断处理分为两部分：

```c
Top Half
Bottom Half
```

原因：

> 中断必须尽快完成。

**Top Half**

Top Half 就是：

```c
ISR
```

特点：

```c
执行很快
只做必要工作
```

例如：

```c
读取中断状态
清除中断
保存数据
```

**Bottom Half**

耗时工作放到：

```c
Bottom Half
```

例如：

```c
数据处理
协议解析
复杂计算
```

# 10. Linux Bottom Half 机制

Linux 提供三种 Bottom Half：

```c
softirq
tasklet
workqueue
```

**softirq**

特点：

```c
高性能
内核使用
```

例如：

```c
网络协议栈
```

驱动很少直接使用。

***

**tasklet**

特点：

```c
基于 softirq
简单易用
```

示例：

```c
DECLARE_TASKLET(my_tasklet, tasklet_func, data);
```

调度：

```c
tasklet_schedule(&my_tasklet);
```

**workqueue**

特点：

```c
运行在进程上下文
可以睡眠
```

示例：

```c
schedule_work(&work);
```

# 11. 中断处理流程

完整流程：

```c
Hardware interrupt
      │
      ▼
CPU
      │
      ▼
ISR (Top Half)
      │
      ▼
Schedule Bottom Half
      │
      ▼
tasklet / workqueue
      │
      ▼
Driver processing
```

# 12. 共享中断

Linux 支持：

```c
共享 IRQ
```

多个设备共用同一个 IRQ。

注册时需要：

```c
IRQF_SHARED
```

ISR 必须检查：

```c
是不是自己的中断
```

示例：

```c
if (!device_interrupt)
    return IRQ_NONE;
```

# 13. 驱动示例

简单中断驱动：

```c
static irqreturn_t my_irq_handler(int irq, void *dev_id)
{
    printk("interrupt\n");

    return IRQ_HANDLED;
}

static int __init my_init(void)
{
    request_irq(irq_num,
                my_irq_handler,
                IRQF_SHARED,
                "my_irq",
                NULL);

    return 0;
}

static void __exit my_exit(void)
{
    free_irq(irq_num,NULL);
}
```

# 14. 驱动常见问题

**中断丢失**

原因：

```c
没有清除中断状态
```

**中断风暴**

原因：

```c
中断一直触发
```

例如：

```c
GPIO状态未清除
```

**ISR执行太长**

问题：

```c
阻塞其他中断
```

解决：

```c
使用 bottom half
```

# 15. 总结

Linux 中断核心结构：

```c
Hardware
   │
IRQ
   │
CPU
   │
ISR (Top Half)
   │
Bottom Half
   │
Driver
```

最重要原则：

```c
ISR 必须快速
复杂逻辑放 Bottom Half
```

# 16. Q\&A

## 16.1 基础理解

1 为什么需要中断？

2 中断和 polling 的区别？

***

## 16.2 中断结构

3 IRQ 是什么？

4 request\_irq 做了什么？

***

## 16.3 上下文

5 为什么 ISR 不能睡眠？

6 为什么 ISR 不能使用 mutex？

***

## 16.4 Bottom Half

7 为什么需要 Top Half / Bottom Half？

8 tasklet 和 workqueue 的区别？
