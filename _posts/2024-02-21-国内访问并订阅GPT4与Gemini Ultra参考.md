---
layout: post
title: 国内访问并订阅 GPT4 与 Gemini Ultra 参考
date: 2024-02-21 15:00:00 +0800
categories: AGI
tags: GPT4 GeminiUltra
excerpt: 国内访问并订阅 GPT4 和 Gemini ultra。
---

![OpenAI and Gemini logo](/images/OpenAIAndGemini.png)

## 目录

- [1. 引言](#1-引言)
- [2. 访问](#2-访问)
- [3. 订阅](#3-订阅)
  - [3.1. 解决海外信用卡问题](#31-解决海外信用卡问题)
  - [3.2. GPT Plus 订阅](#32-gpt-plus-订阅)
  - [3.3. Gimini Advanced 订阅](#33-gimini-advanced-订阅)

## 1. 引言

GPT 的横空出世把 AGI 的发展往前推了一大步。对于个人来说，它可以作为一个强大的工具来提高我们的学习工作效率，改善工作质量，降低入门门槛，提升学习意愿，降低心理压力和心智负担。

它能做什么呢？它就像一个个人管家助手，它能和你交流对话、翻译、润色文章、写邮件、写简历、写日报周报、查询搜索信息、百科问答、整理和格式化数据、代码生成、图片生成处理和识别等功能，此外，你还能上传文档，让它回答你对文档内容的提问，总之，一切的一切你都可以试试，毕竟这是个没有使用边界的产品，想象空间无限，未来可期。

在所有 GPT 中，OpenAI 的 GPT4 和谷歌的 Gemini Ultra  无疑是最强的，但这两个产品在国内无法访问，国内用户既被国内防火墙 GFW 屏蔽又被国外公司屏蔽，两头 ban，如果因此错过这样强大的神器，浪费了这个时代机遇，属实可惜，于是便有了此文。此文是笔者的详细实践步骤，适合入门玩家参考，请谨慎参考，出了事笔者不负任何责任。

## 2. 访问

要想访问，首先要解决网络问题，能够科学上网是这一切的前提。强烈推荐首选美国西海岸的 vps。

参考：[科学上网之Gost方案v2][GostV2]。

## 3. 订阅

OpenAI 的 GPT3.5 web 版和谷歌的 Gemini Pro web 版可以免费使用，但我们需要的是更强大的版本，OpenAI 的 GPT4 需要付费订阅，谷歌的 Gemini Advanced 可以免费试用两个月，到期后需要付费订阅。

### 3.1. 解决海外信用卡问题

这两个产品的高级版在使用前都需要绑定海外信用卡，国内的信用卡、PayPal、双币 visa、双币 MasterCard 等都不可以使用。如果在国内想办理一些国外的信用卡实体卡很困难，虽然确有一些办法可以办理，但很麻烦，成本也不低。本教程使用虚拟 visa 卡。

我使用的是油管博主 Allen 推荐的 [fomepay][fomepay] 的虚拟 visa 卡 ([美国虚拟信用卡那些坑，Fomepay助力微信支付宝充值美元，支付ChatGPT，美国apple id][allenFomepayRecommend])。

- 注册并登录 [fomepay][fomepay]。注册海外产品尽量用海外邮箱或海外手机号，如谷歌的 Gmail 邮箱，不要用大陆和香港的邮箱或手机号。

- 开卡。fomepay 提供 visa（紫色）和 master card （金色）两种卡，卡类型有香港虚拟卡和美元虚拟卡，一定要选美元虚拟卡。⚠️ 注意阅读卡片描述文字（除了卡右侧有简短描述，点进卡片会有详细描述），不同的卡支持的服务不同，有的卡是不支持 ChatGPT Plus 的，选那种既支持 ChatGPT Plus 又支持 Gemini Advanced 的卡。开卡费用 10 美元，没有年费和月费，有效期 2 年。

![fomepay card description example](/images/fomepayCardDescDemo.png)

- 充值。充值每次最低 22 美元，单笔最高 800 美元，每天最多充 3 次，充值时间在 8:00 - 23:59。交易额小于10美元，每笔固定扣0.1美元，大于10美元不扣。跨境手续费1%，最低0.45美元（非美国站点），美国站点消费不收取。退款手续费2% 。使用支付宝充值前需要先开启美国节点的代理，如果没开启就充，会自动弹出提示。

### 3.2. GPT Plus 订阅

- 打开 ChatGPT 网址：[ChatGPT][chatgpt]。

- 点击左上角 ChatGPT 3.5 下拉按钮，点击按钮【Upgrade to Plus】，在弹出的窗口中选择中间的 Plus 订阅计划。

- 打开 [fomepay][fomepay] 卡的支付信息。登录 fomepay，选中并展开 卡中心，点击卡密（cvc），输入支付密码，弹出卡信息：流量、持卡人全称、姓、名、卡密、卡号、有效日期、邮编、国家、州省、城市、街道。

- 绑定 [ChatGPT][chatgpt] 的支付方式。在 ChatGPT 右边的支付方式界面中，依次填入上一步得到的卡号、有效期、cvc、持卡人全称。账单地址选择美国的一个免税州地址，我输入的是 Motherwell，在弹出的地址建议中选中带有 Motherwell 的地址，这个地址只有一个，很好找到。这是我参考博主 Allen 输入的地址信息（[ChatGPT Plus subscription by fomepay][allenChatGPTPlusSubscription]），他也是输入的这个，我相信你也可以输入这个地址，我之前输入的 fomepay 账单地址，没法绑定成功，直到输入这个地址。

- 信息填完之后，点击订阅按钮，如无意外就订阅成功了，否则得另寻它法。回到使用界面使用时，要记得点击左上角下拉按钮，将模型从 GPT-3.5 切换到 GPT-4 来。

### 3.3. Gimini Advanced 订阅

- 打开网站并[登录][gemini]，如果没注册则注册。

- 点选左上角 Gemini 下拉按钮，点选 Gemini Advanced 选项的 Upgrade 按钮进入订阅页面。

- 点击 Start trail。

- 在弹出的框中点选第一个选项：添加信用卡或借记卡。

- 在新弹出的框中，按要求依次填入：卡号、有效期、cvc、持卡人全名。点击账单地址输入栏，第一个下拉输入栏自动选择了美国，不用动，第二个输入栏输入邮编。点击保存即可。

- 大概齐参照[步骤 3.2](#32-gpt-plus-订阅) 既可。Gemini 的订阅比 OpenAI 的还更简单容易通过些。

- 如果只想免费试用一下，不想花钱订阅，一定要记得在试用期满前取消订阅，在两个月后的今天的前一天取消即可。

[allenChatGPTPlusSubscription]: https://youtu.be/SnXjdsYECbQ?t=448
[allenFomepayRecommend]: https://youtu.be/_rk1Wi6Vt8A?si=srVBkDZcC5SOpJx9
[chatgpt]: https://chat.openai.com
[fomepay]: https://www.fomepay.com
[gemini]: https://gemini.google.com
[GostV2]: https://blog.thomasyang.nl/科学上网/2023/05/20/科学上网之Gost方案v2.html