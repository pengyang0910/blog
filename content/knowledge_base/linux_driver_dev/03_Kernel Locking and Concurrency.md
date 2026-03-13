---
title: "3_Linux 内核锁与并发控制（Kernel Locking & Concurrency）"
date: 2026-03-13
draft: false
weight: 3
tags: ["Linux", "驱动开发", "内核"]
summary: "Linux 内核并发控制机制详解，包括 spinlock、mutex、semaphore、rwlock、atomic 等锁的使用场景与选择指南，以及驱动中常见并发问题分析。"
ShowToc: true
TocOpen: false
---

# 1. 学习目标

1. 理解 Linux 内核为什么需要锁

理解：

```bash
多进程
多CPU
中断
内核线程
```

导致的 **并发访问问题**。

***

* 理解 Linux 内核并发来源

能够识别以下并发来源：

```bash
用户进程
SMP 多核
中断
软中断
tasklet
workqueue
内核线程
```

***

* 掌握常用内核锁

能够正确使用：

```bash
spinlock
mutex
semaphore
rwlock
atomic
```

***

* 能分析驱动中的竞态条件

例如：

```bash
多个进程同时访问设备
中断和进程同时访问数据
多 CPU 访问同一变量
```

***

* 能选择合适的锁

例如：

| 场景    | 推荐锁      |
| ----- | -------- |
| 进程上下文 | mutex    |
| 中断    | spinlock |
| 计数器   | atomic   |
| 读多写少  | rwlock   |

# 2. 什么是并发问题

并发问题的本质：

> 多个执行流同时访问共享资源。

例如：

```bash
CPU0           CPU1

counter++      counter++
```

执行顺序：

```bash
read counter
add 1
write counter
```

可能出现：

```bash
counter = 1
```

而不是：

```bash
counter = 2
```

这就是 **竞态条件（Race Condition）**。

# 3. Linux 内核并发来源

Linux 内核的并发比用户空间复杂。

主要来源：

```bash
1 多进程
2 多 CPU
3 软中断
4 内核线程
```

***

1. **用户进程并发**

多个进程访问同一设备：

```bash
process1 → write()
process2 → write()
```

同时进入驱动。

***

* **SMP 多核**

多 CPU 同时运行：

```bash
CPU0 → driver
CPU1 → driver
```

***

* **中断**

中断可以打断当前代码：

```bash
driver code
    │
    │
interrupt
    │
ISR
```

* **内核线程**

例如：

```bash
kworker
ksoftirqd
```

# 4. Linux 内核执行上下文

理解锁必须理解 **执行上下文。**

Linux 有两种主要上下文：

```bash
进程上下文
中断上下文
```

1. **进程上下文**

特点：

```bash
可以睡眠
可以调度
```

例如：

```c
read()
write()
open()
```

* **中断上下文**

特点：

```bash
不能睡眠
不能调度
必须快速完成
```

例如：

```bash
ISR
```

所以：

```bash
中断不能使用 mutex
```

***

# 5. Linux 内核锁分类

Linux 内核锁主要分为：

```bash
自旋锁 （Spinlock）
互斥锁（Mutex）
信号量（Semaphore）
读写锁（RWLock）
原子变量（Atomic）
```

***

# 6. 自旋锁（Spinlock）

自旋锁特点：

```bash
忙等待
不会睡眠
适合短时间锁
```

示例：

```c
spinlock lock;
spin_lock(&lock);
/* critical section */
spin_unlock(&lock);
```

***

**使用场景**

```bash
中断处理
短时间临界区
SMP 同步
```

***

**为什么叫自旋**

CPU 会不断循环：

```c
while(lock == busy)
    spin
```

***

**带中断**

```c
spin_lock_irqsave(&lock, flags);

/* critical section */

spin_unlock_irqrestore(&lock, flags);
```

作用：

```bash
关闭本地 CPU 中断
```

防止：

```bash
中断再次获取锁
```

***

# 7. 互斥锁（Mutex）

mutex 特点：

```bash
可以睡眠
不能在中断使用
```

示例：

```c
struct mutex lock;
mutex_lock(&lock);
/* critical section */
mutex_unlock(&lock);
```

***

**使用场景**

```c
进程上下文
较长临界区
驱动数据保护
```

***

# 8. 信号量（Semaphore）

信号量特点：

```c
允许多个访问
计数型锁
```

示例：

```c
struct semaphore sem;
down(&sem);
/* critical section */
up(&sem);
```

***

使用场景

```c
资源管理
设备访问限制
```

***

# 9. 读写锁（RWLock）

特点：

```c
多个读
单个写
```

示例：

```c
rwlock_t lock;
read_lock(&lock);
read_unlock(&lock);
write_lock(&lock);
write_unlock(&lock);
```

***

**使用场景**

```c
读多写少
配置数据
```

***

# 10. 原子变量（Atomic）

用于简单计数。

示例：

```c
atomic_t counter;
atomic_set(&counter,0);
atomic_inc(&counter);
atomic_read(&counter);
```

***

**使用场景**

```c
计数器
引用计数
```

# 11. 驱动中的典型并发问题

**场景1：多个进程访问设备**

```c
process1 → write
process2 → write
```

需要：

```c
mutex
```

**场景2：中断和进程共享数据**

```c
process context
        │
        ▼
driver data

        ▲
        │
interrupt
```

需要：

```c
spinlock
```

**场景3：统计计数**

```c
irq_count++
```

需要：

```c
atomic
```

# 12. 锁选择指南

选择锁时的决策：

```c
是否在中断？
        │
        ├─ yes → spinlock
        │
        └─ no
             │
             ├─ 临界区短 → spinlock
             │
             └─ 临界区长 → mutex
```

# 13. 驱动示例

保护共享数据：

```c
static DEFINE_MUTEX(dev_lock);

static ssize_t my_write(...)
{
    mutex_lock(&dev_lock);

    /* 操作设备 */

    mutex_unlock(&dev_lock);

    return len;
}
```

# 14. 常见错误

**错误1：中断中使用 mutex**

错误代码：

```c
mutex_lock(&lock);
```

原因：

```c
mutex 会睡眠
中断不能睡眠
```

**错误2：自旋锁临界区太长**

错误：

```c
持有spinlock执行大量代码
```

结果：

```c
CPU长时间忙等
```

**错误3：忘记解锁**

```c
死锁
```

# 15. 总结

Linux 内核并发来源：

```c
process
SMP
interrupt
kernel thread
```

常见锁：

```c
spinlock
mutex
semaphore
rwlock
atomic
```

最重要原则：

```c
中断 → spinlock
进程 → mutex
计数 → atomic
```

# 16. Q\&A

## 16.1 基础理解

1. 为什么 Linux 内核需要锁？

2. 什么是竞态条件？

## 16.2 上下文

1. 什么是进程上下文？

2. 为什么中断不能睡眠

## 16.3 锁选择

1. 为什么 ISR 不能使用 mutex？

2. spinlock 和 mutex 的区别？

## 16.4 驱动问题

1. 为什么驱动中断和进程共享数据需要 spinlock？
