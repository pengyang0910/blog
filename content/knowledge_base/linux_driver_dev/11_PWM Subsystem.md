---
title: "11_Linux PWM 驱动（PWM Subsystem）"
date: 2026-03-13
draft: false
weight: 11
tags: ["Linux", "驱动开发", "内核"]
summary: "Linux PWM 子系统开发指南，讲解 PWM 脉冲宽度调制原理、pwm_chip/pwm_device 结构、PWM 注册与配置方法及背光/电机控制等应用场景。"
ShowToc: true
TocOpen: false
---

# 1. 学习目标

1. **理解 PWM 工作原理**

理解 PWM 信号：

```c
周期（Period）
占空比（Duty Cycle）
频率（Frequency）
```

***

* **理解 Linux PWM 子系统架构**

理解 PWM 驱动结构：

```c
PWM Core
PWM Driver
Hardware
```

核心对象：

```c
pwm_chip
pwm_device
pwm_ops
```

***

* **能使用 PWM 控制设备**

例如：

```c
LED 亮度
电机速度
风扇转速
```

***

* **能编写简单 PWM 控制驱动**

掌握 API：

```c
pwm_request
pwm_config
pwm_enable
pwm_disable
```

***

* **理解 PWM 与 Device Tree 的关系**

理解：

```c
pwm controller
pwm comsumer
```

***

# 2. PWM 简介

PWM 表示：

```c
脉冲宽度调制
```

PWM 信号：

```c
|----|____|----|____
```

周期：

```c
一个完整波形时间
```

占空比：

```c
高电平时间 / 周期
```

***

**PWM 示例**

占空比：

```c
25%
50%
75%
```

示例：

```c
25%: |--____|
50%: |----____|
75%: |------__|
```

# 3. Linux PWM 子系统架构

Linux PWM 子系统结构：

```c
PWM Consumer
      │
      ▼
    PWM Core
      │
      ▼
   PWM Driver
      │
      ▼
   Hardware
```

例如：

```c
LED Driver
Motor Driver
Backlight Driver
```

***

# 4. PWM 子系统核心结构

PWM 子系统核心对象：

```c
pwm_chip
pwm_device
pwm_ops
```

***

# 5. pwm\_chip

pwm\_chip 表示：

```c
PWM 控制器
```

例如：

```c
SoC PWM Controller
```

结构：

```c
struct pwm_chip
{
    struct device *dev;
    const struct pwm_ops *ops;
    int npwm;
};
```

关键成员：

```c
npwm
```

表示：

```c
PWM 通道数量
```

***

# 6. pwm\_device

pwm\_device 表示：

```c
一个 PWM 通道
```

例如：

```c
PWM0
PWM1
PWM2
```

结构：

```c
struct pwm_device
{
    unsigned int hwpwm;
};
```

***

# 7. pwm\_ops

pwm\_ops 表示：

```c
PWM 硬件操作接口
```

结构：

```c
struct pwm_ops
{
    int (*config)(struct pwm_chip *, struct pwm_device *,
                  int duty_ns, int period_ns);

    int (*enable)(struct pwm_chip *, struct pwm_device *);

    void (*disable)(struct pwm_chip *, struct pwm_device *);
};
```

主要操作：

```c
配置 PWM
开启 PWM
关闭 PWM
```

***

# 8. PWM 驱动注册流程

PWM 驱动基本流程：

```c
初始化 pwm_chip
        │
pwmchip_add
        │
注册 PWM 控制器
        │
用户获取 pwm_device
```

流程图：

```c
PWM Driver
      │
      ▼
pwmchip_add
      │
      ▼
PWM Core
      │
      ▼
Consumer Driver
```

***

# 9. PWM 配置接口

Linux 提供以下接口：

```c
pwm_request
pwm_config
pwm_enable
pwm_diable
```

***

**pwm\_request**

获取 PWM 设备：

```c
pwm = pwm_request(0,"my_pwm");
```

***

**pwm\_config**

配置 PWM：

```c
pwm_config(pwm, duty_ns, period_ns);
```

参数：

```c
duty_ns
period_ns
```

***

**pwm\_enable**

启动 PWM：

```c
pwm_enable(pwm);
```

**pwm\_diable**

关闭 PWM：

```c
pwm_diable(pwm);
```

***

# 10. PWM 驱动示例

简单 PWM 驱动结构：

```c
static int my_pwm_enable(struct pwm_chip *chip,
                         struct pwm_device *pwm)
{
    printk("pwm enable\n");
    return 0;
}

static const struct pwm_ops my_pwm_ops =
{
    .enable = my_pwm_enable,
};

static struct pwm_chip my_chip =
{
    .ops = &my_pwm_ops,
    .npwm = 4,
};

static int __init my_pwm_init(void)
{
    pwmchip_add(&my_chip);
    return 0;
}
```

# 11. Device Tree 描述 PWM

PWM 控制器通常在 Device Tree 中描述。

示例：

```c
pwm@10020000
{
    compatible = "my-pwm";
    reg = <0x10020000 0x1000>;
    #pwm-cells = <2>;
};
```

***

**PWM 使用示例**

LED 使用 PWM：

```c
led
{
    pwms = <&pwm0 0 500000>;
};
```

解释：

```c
pwm0 控制器
channel 0
周期 500000 ns
```

# 12. 用户空间 PWM 控制

Linux 提供：

```c
/sys/class/pwm
```

例如：

```c
/sys/class/pwm/pwmchip0
```

使用：

```c
export
period
duty_cycle
enable
```

示例：

```c
echo 0 > export
echo 1000000 > period
echo 500000 > duty_cycle
echo 1 > enable
```

# 13. PWM 子系统结构总结

PWM 子系统结构：

```c
Consumer Driver
      │
      ▼
    PWM Core
      │
      ▼
    pwm_chip
      │
      ▼
    Hardware
```

核心对象：

```c
pwm_chip
pwm_device
pwm_ops
```

***

# 14. 驱动常见问题

**PWM 无输出**

原因：

```c
没有 pwm_enable
```

***

**PWM 频率错误**

原因：

```c
period 配置错误
```

***

**PWM 不稳定**

原因：

```c
时钟源错误
```

***

# 15. 总结：

Linux PWM 子系统核心结构：

```c
pwm_chip
pwm_device
pwm_ops
```

关系：

```c
pwm_chip
     │
     └── pwm_device
```

最重要原则：

> **PWM 驱动 = PWM Core + PWM Controller**

***

# 16. Q\&A

## 16.1 基础理解

1. PWM 为什么可以控制 LED 亮度？

2. PWM 占空比是什么意思？

***

## 16.2 Linux 架构

1. pwm\_chip 表示什么？

2. pwm\_device 表示什么？

***

## 16.3 驱动流程

1. pwm\_config 做了什么？

2. pwm\_enable 的作用是什么？
