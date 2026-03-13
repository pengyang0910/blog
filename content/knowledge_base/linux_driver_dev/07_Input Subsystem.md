---
title: "7_Linux Input 子系统（Input Subsystem）"
date: 2026-03-13
draft: false
weight: 7
tags: ["Linux", "驱动开发", "内核"]
summary: "Linux Input 子系统详解，涵盖 input_device/input_handler 结构、事件上报机制、EV_KEY/EV_ABS 事件类型及键盘/鼠标/触摸屏驱动开发方法。"
ShowToc: true
TocOpen: false
---

# 1. 学习目标

1. **理解 Linux Input 子系统的作用**

理解 Linux 如何统一管理：

```c
键盘
鼠标
触摸屏
按键
游戏手柄
```

***

* **理解 Input 子系统架构**

理解三层结构：

```c
Input Device
Input Core
Input Handler
```

***

* **理解 Input 事件机制**

理解 Linux 如何表示输入事件

```c
EV_KEY
EV_REL
EV_ABS
```

***

* 能编写简单 Input 驱动

掌握核心 API：

```c
input_allocate_device
input_register_device
input_report_key
input_sync
```

***

* **能分析用户空间 Input 设备**

掌握：

```c
/dev/input/eventX
```

以及：

```c
evtest
```

工具。

***

# 2. 为什么需要 Input 子系统

如果没有 Input 子系统，每个输入设备驱动都需要自己实现：

```c
字符设备
事件解析
用户接口
```

例如：

```c
键盘驱动
鼠标驱动
触摸屏驱动
```

接口都不同。

Linux 于是引入

> Input Subsystem

统一输入设备。

***

# 3. Input 子系统整体结构

Input 子系统结构：

```c
Input Device Driver
        │
        ▼
      Input Core
        │
        ▼
   Input Handler
        │
        ▼
   User Space
```

例如：

```c
按键驱动
    │
input subsystem
    │
evdev
    │
/dev/input/event0
    │
用户程序
```

***

# 4. Input 子系统核心结构

Input 子系统核心对象：

```c
input_dev
input_handler
input_event
```

***

**input\_dev**

表示：

```c
输入设备
```

例如：

```c
keyboard
mouse
touchscreen
button
```

结构：

```c
struct input_dev
{
    const char *name;
    struct input_id id;
};
```

***

**input\_handler**

表示：

```c
输入事件处理器
```

例如：

```c
evdev
keyboard handler
mouse handler
```

***

**input\_event**

表示：

```c
输入事件
```

结构：

```c
struct input_event
{
    struct timeval time;
    __u16 type;
    __u16 code;
    __s32 value;
};
```

# 5. Input 事件类型

Linux 定义多种输入事件：

**EV\_KEY**

按键事件：

```c
键盘
按键
```

***

**EV\_REL**

相对坐标：

```c
鼠标移动
```

***

**EV\_ABS**

绝对坐标：

```c
触摸屏
```

***

**EV\_SYN**

同步事件：

```c
事件结束
```

***

# 6. Input 驱动工作流程

Input 驱动基本流程：

```c
驱动初始化
      │
分配 input_dev
      │
设置设备能力
      │
注册设备
      │
产生事件
```

流程图：

```c
input_allocate_device
        │
input_set_capability
        │
input_register_device
        │
input_report_xxx
        │
input_sync
```

# 7. 分配 Input 设备

驱动首先需要：

```c
input_allocate_device()
```

示例：

```c
struct input_dev *input;
input = input_allocate_device();
```

# 8. 设置设备能力

例如：

```c
按键设备
```

代码：

```c
set_bit(EV_KEY, input->evbit);
set_bit(KEY_ENTER, input->keybit);
```

表示：

```c
支持按键事件
```

# 9. 注册 Input 设备

注册设备：

```c
input_register_device(input);
```

注册成功后：

系统生成：

```c
/dev/input/eventX
```

***

# 10. 上报输入事件

驱动检测到按键

```c
button pressed
```

上报：

```c
input_report_key(input,KEY_ENTER,1);
input_sync(input);
```

释放按键：

```c
input_report_key(input,KEY_ENTER,0);
input_sync(input);
```

# 11. 完整 Input 驱动示例

简单按键驱动：

```c
static struct input_de *button_dev;
static int __init button_init(void)
{
    button_key = input_allocate_device();
    
    button_dev->name = "my_button";
    
    set_bit(EV_KEY, button_dev->evbit);
    set_bit(KEY_ENTER, button_dev->keybit);
    
    input_register_device(button_dev);
    
    return 0;
}
```

按键触发：

```c
input_report_key(button_dev, KEY_ENTER, 1);
input_sync(button_dev);
```

# 12. 用户空间访问

Input 设备位于：

```c
/dev/input/
```

例如：

```c
/dev/input/event0
/dev/input/event1
```

用户程序读取：

```c
struct input_event
```

***

**evtest 工具**

测试 Input 设备：

测试 Input 设备：

```c
evtest
```

示例：

```c
evtest /dev/input/event0
```

输出：

```c
Event: type 1 (EV_KEY), code 28 (KEY_ENTER), value 1
```

# 13. Input 子系统结构总结

Input 子系统结构：

```c
Hardware
   │
Driver
   │
Input Device
   │
Input Core
   │
Input Handler
   │
/dev/input/eventX
   │
User Space
```

# 14. 驱动常见问题

**没有生成 eventX**

原因：

```c
input_register_device 没调用
```

***

**evtest 无事件**

原因：

```c
没有 input_report
```

***

事件类型错误

原因：

```c
EV_KEY / EV_REL / EV_ABS 设置错误
```

# 15. 总结



Input 子系统核心结构：

```c
Input Device
      │
      ▼
Input Core
      │
      ▼
Input Handler
      │
      ▼
/dev/input/eventX
```

事件机制：

```c
input_report_key
input_sync
```

最重要原则：

> **Input 子系统负责统一输入事件接口**

***

# 16. Q\&A

## 16.1 架构理解

1. 为什么 Linux 需要 Input 子系统？

2. Input Device 和 Input Handler 的关系？

***

## 16.2 事件机制

1. input\_event 结构表示什么？

2. EV\_KEY 和 EV\_ABS 的区别？

***

## 16.3 驱动流程

1. input\_register\_device 做了什么？

2. input\_report\_key 的作用是什么？

