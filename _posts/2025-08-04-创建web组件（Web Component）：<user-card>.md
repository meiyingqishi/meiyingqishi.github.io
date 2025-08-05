---
layout: post
title: 创建 web 组件（Web Component）：<user-card>
date: 2025-08-04 20:00:00 +0800
---

![Web component user card cover](/images/usercard-cover.png)

- 创建项目

打开终端输入以下指令：

```bash
mkdir webcompdemo
cd webcompdemo
```

- 创建组件

```bash
touch user-card.js
nvim user-card.js
```

填入以下内容：

```js
class UserCard extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: 'open' }); // 开启 Shadow DOM
  }

  connectedCallback() {
    const name = this.getAttribute('name') || '未知用户';
    const avatar = this.getAttribute('avatar') || 'https://via.placeholder.com/80';
    const description = this.getAttribute('description') || '这个人很神秘。';

    this.shadowRoot.innerHTML = `
      <style>
        .card {
          font-family: sans-serif;
          border: 1px solid #ccc;
          border-radius: 10px;
          padding: 16px;
          display: flex;
          align-items: center;
          width: 300px;
          box-shadow: 2px 2px 10px rgba(0,0,0,0.05);
        }
        img {
          border-radius: 50%;
          width: 80px;
          height: 80px;
          margin-right: 16px;
        }
        .info {
          display: flex;
          flex-direction: column;
        }
        .name {
          font-size: 18px;
          font-weight: bold;
          margin: 0 0 4px 0;
        }
        .desc {
          font-size: 14px;
          color: #666;
        }
      </style>
      <div class="card">
        <img src="${avatar}" alt="Avatar" />
        <div class="info">
          <div class="name">${name}</div>
          <div class="desc">${description}</div>
        </div>
      </div>
    `;
  }
}

customElements.define('user-card', UserCard);
```

- 测试使用

创建主页：

```bash
touch index.html
nvim index.html
```

填入以下内容：

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8" />
  <title>User Card Demo</title>
</head>
<body>
  <user-card
    name="Thomas"
    avatar="https://i.pravatar.cc/80?img=4"
    description="资深软件工程师，热爱开放技术。">
  </user-card>

  <script type="module" src="./user-card.js"></script>
</body>
</html>
```

- 启动 nodejs 本地服务（避免浏览器的跨域限制）

**浏览器出于安全考虑，阻止了从 file:// 路径中加载 type="module" 的 JS 文件。
这种限制主要是为了防止跨文件访问带来的信息泄露和本地文件篡改风险。前提是已安装了 nodejs**

```bash
npx serve .
```

在浏览器中反问 <http://localhost:3000> 就能看到封面效果。

![Web component user card shot](/images/webcomponent-usercard.png)
