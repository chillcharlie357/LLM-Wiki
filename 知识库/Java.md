---
title: Java
source: https://www.notion.so/2ff10c9390f180f7a963cff32566c869
---

# Java

## 基础概念

### OOP

#### 虚方法表（vtable）

JVM 加载类时会为类创建 vtable，本质是一个保存虚方法入口地址的数组。

- 子类重写父类方法时，子类 vtable 对应槽位指向子类实现。
- 子类未重写时，继续沿用父类实现。

#### 非虚方法

- `static`：直接绑定到类。
- `private`：子类无法继承和重写。
- `final`：禁止子类重写。

#### 抽象类与接口的区别

| 特性 | 抽象类 | 接口 |
| --- | --- | --- |
| 成员变量 | 可以有实例变量和常量 | 默认是常量 |
| 方法实现 | 可以有普通方法和抽象方法 | Java 8 后支持 default / static |
| 构造函数 | 有 | 没有 |
| 继承/实现 | 单继承 | 多实现 |
| 设计语义 | 强调 is-a | 强调 can-do |

- 抽象类可以拥有自己的状态。
- 接口即使有 default 方法，也没有实例变量。

### 为什么抽象类不能实例化，但是有构造方法

抽象类构造函数用于初始化从父类继承下来的成员变量，供子类实例化时走完整调用链。

## String、StringBuilder、StringBuffer

- `String`：不可变，修改会创建新对象。
- `StringBuilder`：可变，线程不安全，单线程性能最好。
- `StringBuffer`：可变，线程安全，但性能略低。

## 泛型与类型擦除

- 泛型是类型参数化。
- Java 泛型只存在于编译阶段，运行时会被擦除。
- 不能在运行时通过 `instanceof T` 判断类型，也不能直接 `new T()`。

## 异常处理体系

- `Error`：JVM 无法处理的严重问题。
- `Exception`：程序可以处理的异常。
- Checked Exception：必须显式处理。
- Runtime Exception：编译器不强制处理。

## Object 类与基础约定

- `==`：比较值或引用地址。
- `equals()`：很多类会重写以比较内容。
- `hashCode()`：若两个对象 `equals` 相等，则 `hashCode` 也必须相等。

## 反射

反射允许程序在运行时调用任意对象的属性和方法。

## 集合 Collections

- `Collection`：存放单一元素。
- `List`：有序，可重复。
- `Set`：无序，不重复。
- `Queue`：强调 FIFO。
- `Map`：存放键值对。

## 关联页面

- [[知识库/Spring]]
- [[知识库/垃圾回收器]]
