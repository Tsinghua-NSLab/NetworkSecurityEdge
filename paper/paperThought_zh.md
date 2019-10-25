## 文章核心逻辑
目前还未想清楚文章的核心逻辑, 有两个可能的核心论点:
1. 云边协同的网络安全架构
2. 运营商端可以出售一些网络安全能力给Cloud端
感觉这两个可以合起来说明: 边缘计算的兴起给ISP带来新的机会?

可能的定题: Network Security with Edge Computing: A new aspect for network security 

## 文章架构




## 搜集到的一些背景知识
1. 移动网络流量占据世界web pages流量比重已达到52.2% (website traffic generated through mobile phones, [link](https://www.statista.com/statistics/241462/global-mobile-phone-website-traffic-share) )
2. 移动蜂窝网络通讯的基本框架为: Endhost --PPP--> 无线接入 --ISP的局域网--> 基于NAT分配公网IP ----> Internet
3. 传统的移动网络分为三部分: 无线接入网(Radio Access Network) --> 移动核心网 --> 应用网络(数据中心) 
4. MEC(Mobile Edge Computing)是要放到无线接入点和有线网络之间,可部署在无线接入网与移动核心网之间。目前MEC系统计划采用OpenStack或Container虚拟化技术管理IT资源。有些文章里认为边缘服务器要达到的性能为: 10核以上、48GB/CPU、支持40Gb的连接能力、48V直流供电(兼容现有基站设备)、可无风扇运行
5. 由于NAT的出现, 很多情况下来自Mobile的流量到Server后，server端不能采用“封锁IP”的策略。【这可能是导致Zero-Trust概念出现的原因？】
6. 边缘计算技术分为了：微云(Micro Cloud)、薄云(Cloudlet)和雾计算(Fog, 思科提出)
7. 计算卸载问题是一个典型的边缘计算资源管理问题


