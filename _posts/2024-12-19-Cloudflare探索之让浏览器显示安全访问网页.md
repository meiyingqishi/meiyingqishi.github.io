---
layout: post
title: Cloudflare 探索之让浏览器显示安全访问网页
date: 2024-12-19 20:00:00 +0800
categories: 笔记
tags: 技术
excerpt: 借助 Cloudflare 让我们自己部署的个人网站在浏览器端显示 HTTPS 连接。
---

![Cloudflare flexible Cover](/assets/images/cloudflare/cf-flexible-connect.webp "题图")

## 引文

Cloudflare 是一家独特的公司，它们提供了很多强大而又简单实用产品，更特别的是价格相对比较便宜，
更更特别的是很多产品是免费的，而收费的产品也提供了一定的免费额度，足以供个人开发者和小公司使用了。
所以，很多人觉得它们很佛心，江湖人送外号 **赛博佛主**，或者给予 **赛博大善人** 的美称。

我在B站或油管或多或少看到了一些博主分享的各种使用用例，但苦于自己没有实际的实用场景，所以一直没能
亲身动手实践，以致感受不深。近来，由于自己有一个特定的需求需要解决（即部署一个类似便签的笔记📒应用 [Memos][memos]
到自己的 VPS 上，但遇到和其它应用冲突的问题），一时半会解决不了，查了很多资料，也在 GitHub 社区
提了问，但还是没找到解决方案，自己已尝试使用 Cloudflare 来解决，也没能成功，沮丧的我只能放着，
任由 80 端口继续肆掠，浏览器出现烦人的警告⚠️。有一天我心血来潮，灵感涌现，突然决定再试试，就试成功了，
于是便有了此文。

## 问题描述

这是一个现实而非虚构的问题。我有一台 VPS，上面运行着一个服务 [Gost][gost]，
我现在打算在这台服务器上部署另一个 web 服务 [Memos][memos]，我想使用 HTTPS 来进行加密连接，
以实现安全访问网站的目的，但不巧的是 Gost 已经占用了 443 端口，如果我在 [Nginx][nginx] 里为
Memos 配置使用 443 端口，会导致 Nginx 起不来（因为端口冲突），我只能沮丧的继续使用不安全的 80
 端口来走 HTTP 访问。

- 为什么不为 HTTPS 配置走其它端口（如 8443 等）？
  
  因为很不优雅，有时候自己也会忘记在访问时在最后加上端口号，其他用户访问时是没有在后面加端口的习惯的，
别人也不知道 HTTPS 映射的新端口是什么。

## 需求分析

我现在需要在不改动 Gost 的情况下实现在浏览器端使用 HTTPS 来访问 Memos，使用默认的 443 端口。

## 解决方案

还是使用强大的 Cloudflare，网络请求示意图如封面所示，从用户浏览器到 Cloudflare 服务器这段是 HTTPS 加密
连接，而从 Cloudflare 到网站服务器这段是未加密的 http 连接，因为我们实现的效果是让浏览器不显示危险警告⚠️，
而是显示安全的 HTTPS 连接。

本文是解决方案之一，属于不完全版本，推荐指数 2.5 颗星，算不上有多推荐。之后会有一篇完全版本，包含
CF 端到源服务器都是加密🔐的，那个才是五星完全推荐方案。

1. 访问 [Cloudflare][cf]。

1. [登录][cf-login]（如果没有账号则先[注册][cf-reg]）。
![Cloudflare Login](/assets/images/cloudflare/cf-login.webp "登录")

1. 托管域名到 Cloudflare（如果是在 Cloudflare 上购买的域名，则略过这步。
建议在 Cloudflare 上购买域名，因为这大善人郑重承诺按成本定价， 流行的 [GoDaddy][godaddy]第一年促销便宜，
后面会变得很贵）。

    1. 登录进入后，点左侧列表 **网站**，点右侧内容区的 **+ 添加域** 按钮。
    ![Cloudflare Login](/assets/images/cloudflare/cf-adddomain-btn.webp "添加域按钮")

    1. 在新页面的 **输入现有域** 文本框中输入已购买的域名（如：thomasyang.org）。
    ![Cloudflare Login](/assets/images/cloudflare/cf-adddomain-panel.webp "输入现有域面板")

    1. 默认选择 **快速扫描 DNS 记录**，后面两个选项是需要付费的高级会员，点击按钮 **继续**。

    1. 选中下面的 **免费计划** 项并点击 **继续** 按钮。
    ![Cloudflare Login](/assets/images/cloudflare/cf-freepanel.webp "免费计划选项")

    1. 按要求更改名称服务器（完成后，需要一些时间生效）。

1. 在 **网站** 面板点击已经托管成功的域名，再点击 **DNS** 面板，添加 A 记录，将域名绑定到 IP。
![Cloudflare Login](/assets/images/cloudflare/cf-add-a-record.webp "添加 A 记录")

1. **开启代理。必须开启代理才能实现本文所说的功能。（开启代理后，Cloudflare 才能拦截并操控请求信息以实现各种功能，
代理状态：小黄云 + 已代理。如果不开启代理，代理状态显示为 仅 DNS，则请求不经过 Cloudflare
服务器，相当于直接访问服务器，这样会直接暴露 IP，Cloudflare 提供的很多功能也无法实现，因为这些功能都是
基于代理来实现的）。**

1. 切换到 **SSL/TLS** 下的 **概述** 面板，点击内容区的 **配置** 按钮。
![Cloudflare Login](/assets/images/cloudflare/cf-config-connect-secret-mode.webp "配置按钮")

1. **选择 Cloudflare 用于连接到您的源服务器的加密模式。经笔者实践，必须选择 灵活（flexible）模式才能生效
（选择其它项都不会成功，浏览器仍显示当前网页使用的是不安全的连接）**
![Cloudflare Login](/assets/images/cloudflare/cf-flexible-mode.webp "灵活模式")

1. 效果如下。

![Cloudflare Login](/assets/images/cloudflare/browser-effects.webp)

## 参考

- [Cloudflare][cf]
- [Gost][gost]
- [Memos][memos]
- [Memos Offical][memos-offcial]
- [Nginx][nginx]

[cf]: https://www.cloudflare.com/zh-cn
[cf-login]: https://dash.cloudflare.com/login
[cf-reg]: https://dash.cloudflare.com/sign-up
[godaddy]: https://www.godaddy.com
[gost]: https://gost.run
[memos]: https://memos.thomas-yang.com
[memos-offcial]: https://www.usememos.com
[nginx]: https://nginx.org
