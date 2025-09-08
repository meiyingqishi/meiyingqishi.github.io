---
layout: post
title: Cloudflare 探索之为网站免费 HTTPS
date: 2025-02-22 20:00:00 +0800
categories: 笔记
tags: 技术
excerpt: 借助 Cloudflare 让我们自己部署的个人网站使用免费的 HTTPS 连接。
---

![Cloudflare flexible Cover](/assets/images/cloudflare/cf-flexible-connect2.webp "题图")

## 目录

- [1. 引文](#1-引文)
- [2. Cloudflare 是什么](#2-cloudflare-是什么)
- [3. Cloudflare 历史](#3-cloudflare-历史)
- [4. 问题描述](#4-问题描述)
  - [4.1. 问题一](#41-问题一)
  - [4.2. 问题二](#42-问题二)
- [5. 需求分析](#5-需求分析)
- [6. 解决方案](#6-解决方案)
  - [6.1. 问题一解法](#61-问题一解法)
  - [6.2. 问题二解法](#62-问题二解法)
- [7. 操作步骤](#7-操作步骤)
- [8. 参考](#8-参考)

## 1. 引文

书接上文（[Cloudflare 探索之让浏览器显示安全访问网页\[1\]][1]）。上文介绍了使用 [Cloudflare\[2\]][2] 将我们的网站包装成能 HTTPS 加密
传输的网站，但是那只是一个半成品，在【终端 -🔐-> CF 节点】之间是加密的，但【CF 节点 -> 应用服务器】
之间还是明文传输，表面看是完美，实质还是不完美，对于有安全性要求的站点来说，是达不到要求的，没能完全解决实际问题。

这一篇是究极完全体，是完全加密的，即【终端 -🔐-> CF 节点 -🔐-> 应用服务器】之间是完全加密的，
能够充分的保证信息传输的安全。在应用 HTTPS 时应该优先参考这篇，不过应先阅读完前一篇后再阅读这篇。

为了保持文章的完整性，请容许我对 CF 做一番简单介绍。

## 2. Cloudflare 是什么

- 成立时间：2009.7
- 总部：旧金山
- 创始人：马修·普林斯（Matthew Prince）、李·霍洛韦（Lee Holloway）、米歇尔·扎特林（Michelle Zatlyn）
- 状态：现已上市，业务遍及全球，是全球最大的 CDN 提供商。
- 提供的服务：
  - CDN
  - DDoS 防护
  - WAF（Web 应用防火墙）
  - SSL/TLS 加密（提供免费和高级 SSL 证书，确保数据传输安全）
  - 1.1.1.1（免费 DNS 服务）
  - WARP VPN
  - Zero Trust
  - 域名服务（域名解析、域名购买）
  - Workers（边缘计算）
  - Pages
  - hCaptcha（真人验证）
  - Turnstile（hCaptcha 的替代品）
  - 大量免费 Email 📧
  - ……

## 3. Cloudflare 历史

要了解为什么要有 Cloudflare 以及其具体的详细的产品细节请自行查看 [Cloudflare 官网\[3\]][3]和[维基百科\[4\]][4]资料。

为了内容的完整性，我再将问题描述一遍。

## 4. 问题描述

### 4.1. 问题一

这是我遇到的一个真实问题。我有一台亚马逊的 VPS，先前已在上面部署了 [Gost\[5\]][5]，并在应用内
通过 certbot 申请并使用了证书，占用了 443 端口，没有使用 Nginx 等工具。

现在我需要在上面再部署一个 web 应用 [Memos\[6\]][6]，这个应用我使用了 Nginx 来做反代，我想让
应用走 HTTPS 来使用加密链接，但是由于 443 端口以被 Gost 占用，导致我的 Nginx 起不起来，只能
配成其它端口，但我又不想使用其它端口，因为每次都要在浏览器里输端口号很麻烦，还容易忘，请问我该怎么办？

### 4.2. 问题二

如果配置应用走 HTTPS，那么我需要申请一个证书，可以通过 certbot 自动机器人申请 Let's Encrypt 申请
免费的证书，可是使用自签名的免费证书后在用户初次访问这个网站时会提示让用户安装我这个证书，这就形成了
猜疑链，通常用户遇到这种情况会警觉，觉得是不安全的（被第三方搞证书劫持来进行钓鱼🎣），会马上关掉，这是对的，也应该是这样，我也是这样。

那么还可以付费申请证书，可是作为穷人的我又不想花钱申请付费证书，请问我该怎么办？

## 5. 需求分析

略。

问题描述阶段已经描述得很清楚。

## 6. 解决方案

令人沮丧的是，在网上找了一段时间，一圈有一圈，还是没能找到贴合的解决方案。

突然想到了还有 Cloudflare 这个很佛心的赛博大善人，之前也或多或少在 B 站和油管看过一些介绍和使用
CF 的视频，于是打开 CF 探寻一番，终于找到了理想的解决方案，于是便有了此文。

***Q & A：***

### 6.1. 问题一解法

一言以蔽之，就是巧妙的利用 CF 强大而又灵活的规则集。

### 6.2. 问题二解法

CF 提供申请免费证书，这个证书有效期最长达 **15** 年。这个证书作用的阶段是从【CF -> 应用服务器】
这个阶段。我不仅将域名托管到 CF 上，使用 CF 来进行域名解析，还开启了 CF 的代理功能，即使用 CF 作为用户的代理中介来访问
我的网站，而 CF 对自家签名的证书是认的。不会再出现浏览器弹出安全提示来警告用户不要安装不安全的第三方证书的情况。

## 7. 操作步骤

- 注册或登录 [Cloudflare\[2\]][2] 。

- 托管域名到 CF 上。将在别处购买或免费申请的域名（例如 example.com）输入帐户主页的添加域里面。

  - 如果是在 CF 上购买的域名，则不用进行这步操作，会自行托管。建议在这个平台购买，因为这大善人承诺按成本定价。

  - `帐户主页[左] -> 添加域[右] -> 快速扫描 DNS 记录 -> Free -> 继续前往激活 -> 按页面提示替换名称服务器`

- 为应用创建子域名（域名解析）。添加 DNS 的 A 记录。

  - `帐户主页[左] -> 点击自己刚托管的域名[右 example.com] -> DNS[左] -> 添加记录`

  - 记录类型为 A，名称为根据自己的实际要求配置的二级域名前缀（如 memos），IPv4 部分填入自己的服务器地址，
  **开启代理状态**（一定要开启，这是最重要的前提条件），保存，几分钟后就会生效。

- 申请证书。

  - `帐户主页 -> 托管的域名 -> SSL/TLS -> 源服务器 -> 创建证书 -> 创建`

  - 分别复制源证书和私钥到本地文本编辑器，并分别命名为 `<域名>.pem` 和 `<域名>.key` （尖括号部分替换为自己的内容，下同），
  如 `memos.example.com.pem`、`memos.example.com.key`。

  - 确定。

- 登录 VPS 服务器（此处为 Linux 服务器 Ubuntu，其它方式同理）。

- 在服务器上开启应用（memos） 要使用的 HTTPS 端口（默认是使用 443，之所以要绑定其它端口是因为被其它应用占用（如 Gost））。

  - 有的平台（如 AWS）默认是通过在其网站上通过添加安全组来开放端口（不激活 ufw），如果是则自行添加，跳过以下步骤，否则继续以下步骤（DigitalOcean、Linode）。

  - 通常可以通过 Ubuntu 的默认防火墙来开启端口（其它 Linux 系统可通过 firewalld(Red Hat、CentOS)、nftables 等来启用端口，
  如果不确定则可以使用更全面但更复杂的 Linux 内核直接搭载的 iptables）。

  - 查看是否已激活 ufw：`sudo ufw status verbose`

  - 如果没激活则执行以下命令激活，否则跳过这步。

    ```bash
    sudo ufw allow ssh
    sudo ufw enable
    ```

  - 开放端口（此处为 8443，你也可以配置自己的其它端口）：`sudo ufw allow <8443>`

- 安装 Nginx：`sudo apt install nginx`。

- 上传证书到服务器（我使用的客户端是 Mac，VPS 是 AWS lightsail）。

  - 打开终端并执行命令，先上传到 tmp 文件夹再移动到 Nginx 的 ssl 文件夹。中括号部分是可选的，
    `-i` 后面的参数是登录 VPS 的密钥，如果是输入密码则不需要指定这个参数。(尖括号部分需要替换为自己的地址，下同)

    ```zsh
    scp [-i ~/.ssh/loginKey.pem] <~/Downloads/memos.example.com.pem> <ubuntu@memos.example.com>:/tmp/
    scp [-i ~/.ssh/loginKey.pem] <~/Downloads/memos.example.com.key> <ubuntu@memos.example.com>:/tmp/
    ssh [-i ~/.ssh/loginKey.pem] <ubuntu@memos.example.com> "sudo mv /tmp/<memos.example.com.pem> /etc/nginx/ssl/ && sudo mv /tmp/<memos.example.com.key> /etc/nginx/ssl/"
    ```

- 登录服务器并设置证书和密钥权限。

  ```bash
  sudo chown root:root /etc/nginx/ssl/<memos.example.com.pem> /etc/nginx/ssl/<memos.example.com.key>
  sudo chmod 644 /etc/nginx/ssl/<memos.example.com.pem>
  sudo chmod 600 /etc/nginx/ssl/<memos.example.com.key>
  ```

- 配置对应网站的 Nginx 配置文件。进入 `/etc/nginx/sites-available/` 目录并创建对应网站的配置文件 <memos.example.com>。

  ```bash
  cd /etc/nginx/sites-available
  touch <memos.example.com>
  ```

- 添加配置。填入以下配置信息：

  ```bash
  server {
    listen <8443> ssl;
    server_name <memos.example.com>;

    ssl_certificate /etc/nginx/ssl/<memos.example.com.pem>;
    ssl_certificate_key /etc/nginx/ssl/<memos.example.com.key>;

    location / {
      proxy_pass <http://localhost:5230>;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
    }

    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
      root /usr/share/nginx/html;
    }
  }
  ```

- 将配置文件链接到 Nginx 的执行目录。

  ```bash
  sudo ln -s /etc/nginx/sites-available/<memos.example.com> /etc/nginx/sites-enabled/<memos.example.com>
  ```

- 测试配置文件语法：`sudo nginx -t`

- 使配置文件生效。

  - 查看 Nginx 状态：`sudo systemctl status nginx`

  - 如果是未启动则启动：`sudo systemctl start nginx`

  - 如果已启动了则重新加载配置文件：`sudo nginx -s reload`

- **修改 SSL/TLS 加密模式**。

  `帐户主页 -> 托管域名<example.com> -> SSL/TLS -> 概述 -> SSL/TLS 配置 -> 自定义 SSL/TLS -> 选中 完全（严格）选项并保存`

  ![Secret Mode Image](/assets/images/cloudflare/cf-secret-mode.webp "加密模式")

- 勾选边缘证书里面的选项（可选）。

  `帐户主页 -> 托管域名<example.com> -> SSL/TLS -> 概述`

  - 勾选✅右边👉的 **始终使用 HTTPS**、**TLS 1.3**、**自动 HTTPS 重写**

- WAF（Web 应用防火墙）配置（可选）。

  - `帐户主页 -> 托管域名<example.com> -> 安全性 -> WAF`

    - 自定义规则

      ![Self custom rule](/assets/images/cloudflare/cf-customrule-badreq.webp "自定义规则 恶意请求")

    - 速率限制规则

      ![IP access speed rate limit 1](/assets/images/cloudflare/cf-iprate-limit01.webp)
      ![IP access speed rate limit 2](/assets/images/cloudflare/cf-iprate-limit02.webp)

- 安全性设置（可选）。

  - `帐户主页 -> 托管域名<example.com> -> 安全性 -> 设置`，安全级别设为🀄️，质询通过期设为
  30 分钟，然后勾选上 浏览器完整性检查 和 替换不安全的 JavaScript 库。

- **端口映射规则添加**。

  - `帐户主页 -> 托管域名<example.com> -> 规则 -> 概述 -> 创建规则`

      ![Traffic forward rule 1](/assets/images/cloudflare/cf-traffic-forward-rule01.webp)
      ![Traffic forward rule 2](/assets/images/cloudflare/cf-traffic-forward-rule02.webp)

## 8. 参考

- \[1]: <https://meiyingqishi.github.io/笔记/2024/12/19/Cloudflare探索之让浏览器显示安全访问网页.html>
- \[2]: <https://www.cloudflare.com/zh-cn>
- \[3]: <https://www.cloudflare.com/zh-cn/our-story>
- \[4]: <https://en.wikipedia.org/wiki/Cloudflare>
- \[5]: <https://blog.thomasyang.nl/科学上网/2023/05/20/科学上网之Gost方案v2.html>
- \[6]: <https://memos.thomasyang.nl>

[1]: https://meiyingqishi.github.io/笔记/2024/12/19/Cloudflare探索之让浏览器显示安全访问网页.html
[2]: https://www.cloudflare.com/zh-cn
[3]: https://www.cloudflare.com/zh-cn/our-story
[4]: https://en.wikipedia.org/wiki/Cloudflare
[5]: https://meiyingqishi.github.io/科学上网/2023/05/20/科学上网之Gost方案v2.html
[6]: https://memos.thomasyang.nl
