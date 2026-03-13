---
title: "2_字符设备（Character Device）"
date: 2026-03-13
draft: false
weight: 2
tags: ["Linux", "驱动开发", "内核"]
summary: "深入讲解 Linux 字符设备驱动开发，包括 file_operations、VFS 调用链、阻塞/非阻塞 I/O、poll/select、并发锁机制及完整驱动示例代码。"
ShowToc: true
TocOpen: false
---

# 1. 学习目标

**认知层**

1. 理解 Linux 内核 I/O 架构

2. 理解字符设备在内核的定位

3. 理解 VFS 的抽象思想

4. 理解 file\_operations 的设计哲学

**实现层**

能够独立写出：

1. 基础字符设备驱动（静态/动态注册）

2. 带中断的字符设备

3. 带阻塞唤醒机制的驱动

4. 支持 poll/select 的驱动

5. 基于 platform 总线 + device tree 的驱动

**理解层**

理解：

1. file\_operations 本质

2. VFS -> 驱动完整调用链

3. copy\_to\_user / copy\_from\_user 原理

4. 阻塞/非阻塞 I/O

5. wait\_queue 原理

6. poll/select/epoll 内核机制

7. 并发与锁（spinlock/mutex）

8. 中断上下文 vs 进程上下文

9. 驱动中的生命周期管理

# 2. 字符设备在内核中的位置

## 2.1 Linux 设备分类

```plain&#x20;text
Linux设备
│
├── 字符设备 (char)
├── 块设备 (block)
└── 网络设备 (net)
```

## 2.2 字符设备的本质

> 字符设备 = 一组被 VFS 调用的函数指针

## 2.3 VFS 视角

```plain&#x20;text
用户态
   open()

系统调用
   sys_open()

VFS
   vfs_open()

inode->i_fop->open()

你的驱动
   my_open()
```

核心理解：

> VFS 不关心你是 GPIO 还是 SPI
>
> 它只调用 file\_operations

# 3. 字符设备完整生命周期

```plain&#x20;text
module_init
    ↓
alloc_chrdev_region
    ↓
cdev_init
    ↓
cdev_add
    ↓
class_create
    ↓
device_create
    ↓
----------------------
用户 open/read/write
----------------------
    ↓
device_destroy
    ↓
class_destroy
    ↓
cdev_del
    ↓
unregister_chrdev_region
    ↓
module_exit
```

# 4. 字符设备核心结构拆解

## 4.1 major / minor

本质：

```plain&#x20;text
major = 驱动编号
minjor = 设备编号
```

举例：

```plain&#x20;text
/dev/mydev0  → (240, 0)
/dev/mydev1  → (240, 1)
```

高级理解：

> major 决定调用哪个 file\_operations
>
> minor 决定访问哪个设备实例

## 4.2 struct cdev

本质：

```plain&#x20;text
cdev = 把 file_operations 挂到内核
```

它是字符设备在内核中的“注册对象”。

## 4.3 设备节点

```plain&#x20;text
/dev/xxx
```

本质：

> 一个特殊文件
>
> inode 中保存着设备号

## 4.4 struct file\_operations（核心）

```c
struct file_operations {
    struct module *owner;
    int (*open)(...);
    ssize_t (*read)(...);
    ssize_t (*write)(...);
    long (*unlocked_ioctl)(...);
    __poll_t (*poll)(...);
};
```

> file\_operations 就是：“用户态能对设备做什么”的菜单

### 4.4.1 owner

防止模块被卸载

### 4.4.2 open/ release

作用：

* 建立设备私有数据

* 设置 file->private\_data

### 4.4.3 read / write

必须掌握：

```c
copy_to_user
copy_from_user
```

为什么不直接 memcpy？

因为：

> 用户空间和内核空间地址不同

### 4.4.4 ioctl

作用：

> 控制命令通道

一般用于：

* 设置参数

* 触发动作

* 读取状态

### 4.4.5 poll

用于：

* 非阻塞检测

* select/poll/epoll 支持

# 5. 调用链深度理解（必须搞懂）

```c
用户 read()
↓
glibc
↓
sys_read
↓
vfs_read
↓
file->f_op->read
↓
你的驱动 read
```

核心：

> 内核根本不知道你是谁
>
> 它只认 file\_operations

# 6. 阻塞与非阻塞

## 6.1 阻塞模型

```c
read()
    ↓
无数据
    ↓
sleep
    ↓
wait_queue
    ↓
中断到来
    ↓
wake_up
```

## 6.2 wait\_queue 核心思想

本质：

> 进程主动睡眠，等待条件成立

关键 API：

```c
wait_event_interruptible()
wake_up_interruptible()
```

# 7. poll/select 原理

用户：

```c
select()
poll()
epoll()
```

内核：

```c
vfs_poll()
    ↓
file->f_op->poll()
```

你必须实现：

```c
poll_wait()
```

核心：

> 告诉内核：什么时候你这个设备“可读”

# 8. 并发与锁

驱动常见问题：

* 多进程同时 read

* 中断和进程竞争资源

**锁分类**

必须理解：

> 中断里不能睡眠

# 9. 带中断的字符设备

流程：

```c
request_irq
    ↓
中断发生
    ↓
ISR
    ↓
更新数据
    ↓
wake_up
```

高级理解：

> ISR 只做最少的事情
>
> 复杂逻辑放到 tasklet/workqueue

# 10. platform 总线驱动

结构升级：

```c
device tree
    ↓
platform_device
    ↓
platform_driver
    ↓
probe()
```

字符设备注册放在 probe 里。

# 11. 完整知识结构图

```c
用户空间
  open/read/write/ioctl
          ↓
系统调用
          ↓
VFS
  file_operations
          ↓
字符设备驱动
  cdev
  wait_queue
  lock
  interrupt
          ↓
硬件寄存器
```

# 12. Q\&A

## 12.1 VFS 为什么需要 file\_operations？

Linux 有成千上万种设备：

* 串口

* I2C

* SPI

* GPIO

* LCD

* CAN

VFS 不可能知道每个设备怎么工作。

所以它做了一件非常聪明的事情：

> 它不能实现功能
>
> 它只定义“接口”

**本质解释**

file\_operations 是：

```c
struct file_operations {
    int (*open)(...);
    ssize_t (*read)(...);
    ...
};
```

VFS 只做：

```c
file->f_op->read(...)
```

它根本不关心：

* 你是串口

* 还是SPI

* 还是自定义电机

**架构本质**

这是：

> 面向接口编程

VFS = 抽象层

驱动 = 今天实现

这就是 Linux 能支持万物皆文件的原因。

## 12.2 为什么 open 里要设置 private\_data？

**先看问题**

同一个驱动：

```c
/dev/mydev0
/dev/mydev1
```

甚至：

两个进程同时 open

***

&#x20;内核怎么区分？

***

**file 结构**

每次open

```c
struct file {
    void *private_data;
}
```

open 被调用时：

你必须告诉内核：

> 这个file 对应哪个设备实例

***

**标准做法**

```c++
static int my_open(struct inode *inode, struct file *file)
{
    struct my_dev *dev;

    dev = container_of(inode->i_cdev, struct my_dev, cdev);
    file->private_data = dev;

    return 0;
}
```

**本质**

private\_data 是

> 每次 open 的“会话上下文”

就像socket连接一样

***

**不设置会发生什么？**

* 多设备混乱

* 多进程读写冲突

* 无法区分实例

***

**工程级理解**

private\_data = 驱动的“面向对象”

你其实是在实现：

```c
class Device {
}
```

## 12.3 为什么 ISR 里不能用 mutex？

**Linux 有两种执行环境**

| 环境    | 能否睡眠 |
| ----- | ---- |
| 进程上下文 | 可以   |
| 中断上下文 | 不能   |

**mutex 会做什么？**

如果锁被占用：

```c
sleep()
```

**中断上下文不能sleep**

为什么？

因为：

> 中断没有进程调度环境

中断是：

* CPU 立即打断当前任务

* 执行 ISR

* 必须尽快返回

如果你 sleep：

系统直接崩。

***

**所以怎么办？**

用：

```c
spinlock
```

spinlock 不睡眠，只忙等。

**本质理解**

中断 = 硬实时

mutex = 可能调度

## 12.4 poll 为什么必须配合 wait\_queue？

poll 的作用是：

> 问：你这个设备现在能不能读？

***

但内核怎么知道什么时候能读？

你必须告诉它：

> “如果有数据，请通知我”

**机制**

```c
poll_wait(file, &dev->wait, wait);
```

意思是：

> 把当前进程挂到 wait\_queue 上

然后：

当数据到来：

```c
wake_up_interruptible(&dev->wait);
```

**没有 wait\_queue 会怎样？**

poll 只能不断轮询：

CPU 100%

**本质**

poll 只是“查询接口”

wait\_queue 才是“通知机制”

## 12.5 阻塞 I/O 和非阻塞 I/O 本质区别是什么？

本质区别只有一句话：

> 是否允许当前进程睡眠等待

## 12.6 epoll 为什么比 select 高效？

## select 的问题

每次调用：

1. 把所有 fd 从用户态复制到内核

2. 遍历全部 fd

3. 返回后再复制回来

复杂度：

```c
O(n)
```

**epoll 的设计思想**

epoll 分两步：

1. 注册阶段（一次）

```c
epoll_ctl()
```

* 等待阶段

```c
epoll_wait()
```

## epoll 内核内部结构

* 红黑树（管理 fd）

* 就绪链表（ready list）

当事件发生：

* 直接加入 ready list

* epoll\_wait 只取 ready 的

复杂度：

```c
O(1)
```

**本质区别**

| 机制     | 模型   |
| ------ | ---- |
| select | 轮询   |
| epoll  | 事件驱动 |

## 高级理解

epoll 是：

> Linux I/O 多路复用的终极形态

# 13. 代码示例

## 13.1 驱动源码：mychardev.c

```c++
// mychardev.c
#include <linux/module.h>
#include <linux/init.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/device.h>
#include <linux/uaccess.h>
#include <linux/mutex.h>
#include <linux/ioctl.h>

#define DEV_NAME    "mychardev"
#define CLASS_NAME  "mychardev_cls"
#define BUF_SIZE    1024

// 一个示例 ioctl 命令：清空缓冲区
#define MY_IOCTL_MAGIC  'M'
#define MY_IOCTL_CLEAR  _IO(MY_IOCTL_MAGIC, 0)

static dev_t devno;                 // 主次设备号
static struct cdev my_cdev;
static struct class *my_class;
static struct device *my_device;

static DEFINE_MUTEX(buf_lock);
static char kbuf[BUF_SIZE];
static size_t data_len;             // 当前缓冲区内有效数据长度

static int my_open(struct inode *inode, struct file *filp)
{
    // 这里可做私有数据绑定：filp->private_data = ...
    pr_info("%s: open\n", DEV_NAME);
    return 0;
}

static int my_release(struct inode *inode, struct file *filp)
{
    pr_info("%s: release\n", DEV_NAME);
    return 0;
}

static ssize_t my_read(struct file *filp, char __user *ubuf, size_t count, loff_t *ppos)
{
    ssize_t ret;

    if (mutex_lock_interruptible(&buf_lock))
        return -ERESTARTSYS;

    // 使用 *ppos 支持多次 read（像普通文件一样）
    if (*ppos >= data_len) {
        ret = 0; // EOF
        goto out;
    }

    if (count > data_len - *ppos)
        count = data_len - *ppos;

    if (copy_to_user(ubuf, kbuf + *ppos, count)) {
        ret = -EFAULT;
        goto out;
    }

    *ppos += count;
    ret = (ssize_t)count;

out:
    mutex_unlock(&buf_lock);
    return ret;
}

static ssize_t my_write(struct file *filp, const char __user *ubuf, size_t count, loff_t *ppos)
{
    ssize_t ret;

    if (mutex_lock_interruptible(&buf_lock))
        return -ERESTARTSYS;

    // 简单策略：每次 write 覆盖写入（更像一个“消息缓冲区”）
    if (count > BUF_SIZE)
        count = BUF_SIZE;

    if (copy_from_user(kbuf, ubuf, count)) {
        ret = -EFAULT;
        goto out;
    }

    data_len = count;
    *ppos = 0;       // 写入后把文件位置重置，便于下一次 read 从头读
    ret = (ssize_t)count;

out:
    mutex_unlock(&buf_lock);
    return ret;
}

static long my_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
{
    (void)arg;

    if (_IOC_TYPE(cmd) != MY_IOCTL_MAGIC)
        return -ENOTTY;

    switch (cmd) {
    case MY_IOCTL_CLEAR:
        if (mutex_lock_interruptible(&buf_lock))
            return -ERESTARTSYS;
        memset(kbuf, 0, sizeof(kbuf));
        data_len = 0;
        mutex_unlock(&buf_lock);
        pr_info("%s: ioctl clear\n", DEV_NAME);
        return 0;
    default:
        return -ENOTTY;
    }
}

static const struct file_operations my_fops = {
    .owner          = THIS_MODULE,
    .open           = my_open,
    .release        = my_release,
    .read           = my_read,
    .write          = my_write,
    .unlocked_ioctl = my_ioctl,
    // 如需兼容 32bit ioctl 可加：.compat_ioctl = my_ioctl
};

static int __init my_init(void)
{
    int ret;

    // 1) 动态申请设备号（1 个次设备）
    ret = alloc_chrdev_region(&devno, 0, 1, DEV_NAME);
    if (ret) {
        pr_err("%s: alloc_chrdev_region failed: %d\n", DEV_NAME, ret);
        return ret;
    }

    // 2) 初始化并添加 cdev
    cdev_init(&my_cdev, &my_fops);
    my_cdev.owner = THIS_MODULE;

    ret = cdev_add(&my_cdev, devno, 1);
    if (ret) {
        pr_err("%s: cdev_add failed: %d\n", DEV_NAME, ret);
        goto err_unregister;
    }

    // 3) 创建 class 和 device（可自动生成 /dev 节点：udev/systemd 环境）
    my_class = class_create(CLASS_NAME);
    if (IS_ERR(my_class)) {
        ret = PTR_ERR(my_class);
        pr_err("%s: class_create failed: %d\n", DEV_NAME, ret);
        goto err_cdev_del;
    }

    my_device = device_create(my_class, NULL, devno, NULL, DEV_NAME);
    if (IS_ERR(my_device)) {
        ret = PTR_ERR(my_device);
        pr_err("%s: device_create failed: %d\n", DEV_NAME, ret);
        goto err_class_destroy;
    }

    mutex_init(&buf_lock);
    memset(kbuf, 0, sizeof(kbuf));
    data_len = 0;

    pr_info("%s: loaded. major=%d minor=%d\n", DEV_NAME, MAJOR(devno), MINOR(devno));
    return 0;

err_class_destroy:
    class_destroy(my_class);
err_cdev_del:
    cdev_del(&my_cdev);
err_unregister:
    unregister_chrdev_region(devno, 1);
    return ret;
}

static void __exit my_exit(void)
{
    device_destroy(my_class, devno);
    class_destroy(my_class);
    cdev_del(&my_cdev);
    unregister_chrdev_region(devno, 1);
    pr_info("%s: unloaded\n", DEV_NAME);
}

MODULE_LICENSE("GPL");
MODULE_AUTHOR("xiaoyu");
MODULE_DESCRIPTION("Basic complete char device example");
MODULE_VERSION("1.0");

module_init(my_init);
module_exit(my_exit);
```

## 13.2 Makefile

```makefile
obj-m += mychardev.o

KDIR ?= /lib/modules/$(shell uname -r)/build
PWD  := $(shell pwd)

all:
        $(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
        $(MAKE) -C $(KDIR) M=$(PWD) clean
```

## 13.3 编译、加载、测试

```bash
make
sudo insmod mychardev.ko
dmesg | tail -n 20

# 看看 /dev 节点是否自动出现
ls -l /dev/mychardev

# 写入
echo "hello char dev" | sudo tee /dev/mychardev

# 读取（注意：因为用了 *ppos，连续 cat 可能第二次读到 EOF）
cat /dev/mychardev
```
