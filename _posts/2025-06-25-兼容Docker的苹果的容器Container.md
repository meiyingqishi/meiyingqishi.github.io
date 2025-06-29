---
layout: post
title: 兼容 Docker 的苹果的容器 Container
date: 2025-06-25 20:00:00 +0800
---

![Apple container image](/images/apple-container01.png)

前不久，苹果公司开源了他们自己的容器系统 [Container](https://github.com/apple/container?tab=readme-ov-file)，
官方介绍：
> 一款用于在 Mac 上使用轻量级虚拟机创建和运行 Linux 容器的工具。它使用 Swift 编写，并针对 Apple 芯片进行了优化。

它有两个特点引起了我的注意：

- 使用苹果自己发明的编程语言 [Swift](https://www.swift.org) 编写，运行在自己的硬件上，
运行在自己的设计的芯片上，调用 Metal。这意味着它能最大限度的发挥 Mac 的性能，最大限度的降低 Mac
的负载。
- 兼容 Docker。能够使用 Docker 的庞大镜像库里的镜像。

意味着 Mac 电脑可以不用装 Docker 就能运行 Docker 容器。以下是我的使用记录以供参考。

### 前提条件

- 科学上网环境。可参考我的 [科学上网之 Gost 方案 v2](https://meiyingqishi.github.io/科学上网/2023/05/20/科学上网之Gost方案v2.html)。
- Apple Silicon Mac。我的是 M1 Pro 的 Mac。
- 最好 macOS 26 beta。我的是 macOS 15，还没更到最新的测试版。

### 安装

- 到 <https://github.com/apple/container/releases> 下载安装包 container-0.1.0-installer-signed.pkg。
- 双击已下载的安装包并按提示安装。
- 打开终端（后续都在终端中操作），运行 `proxy`（前提是已按照科学上网环境搭建教程 [终端代理配置](https://meiyingqishi.github.io/科学上网/2023/05/20/科学上网之Gost方案v2.html#611-终端代理配置) 在 `~/.zshrc` 中
  配置了环境变量）：

  ```zsh
  HTTP="http://127.0.0.1:7893"
  SOCKS="socks5://127.0.0.1:7891"
  alias proxy="export http_proxy=${HTTP} https_proxy=${HTTP} all_proxy=${SOCKS}"
  alias unproxy='unset all_proxy http_proxy https_proxy'
  ```

  > [!TIP]
  > :warning: 一些工具（如： `Gemin cli`）需要使用 `http`，如果只配置了 `socks5`，就会导致运行失败（之前的教训）。

### 启动容器服务

  ```zsh
  container system start
  ```
  
  遇到以下提示时输入大写的英文字符 `Y`：
  
  ```zsh
  Verifying apiserver is running...
  Installing base container filesystem...
  No default kernel configured.                                                             
  Install the recommended default kernel from [https://github.com/kata-containers/kata-containers/releases/download/3.17.0/kata-static-3.17.0-arm64.tar.xz]? [Y/n]:
  ```

### 设置本地 DNS 域（可选）

在当前系统 `macOS 15` 上搞了一番，没搞成功。略。

### 构建镜像

- 创建一个名为 `web-test` 的目录，用于存放创建容器镜像所需的文件，并创建一个名为 `Dockerfile` 的文件：

  ```zsh
  mkdir web-test
  cd web-test
  touch Dockerfile
  ```

- `Dockerfile` 文件内容如下：

  ```docker
  FROM docker.io/python:alpine

  # 使用真实局域网 IP 地址
  # 注意：请将 192.168.2.4 替换为您自己的 IP
  ENV http_proxy="http://192.168.2.4:7893"
  ENV https_proxy="http://192.168.2.4:7893"
  ENV HTTP_PROXY="http://192.168.2.4:7893"
  ENV HTTPS_PROXY="http://192.168.2.4:7893"

  WORKDIR /content
  RUN apk update && apk add curl
  RUN echo '<!DOCTYPE html><html><head><title>Hello</title></head><body><h1>Hello, world!</h1></body></html>' > index.html
  CMD ["python3", "-m", "http.server", "80", "--bind", "0.0.0.0"]
  ```

- 执行构建命令构建我们自定义的镜像

  ```zsh
  container build --tag web-test --file Dockerfile .
  ```

- 查看我们构建好的镜像

  ```zsh
  container images list
  ```

### 本地容器操作

- 根据我们刚创建好的镜像来创建并运行容器

  ```zsh
  container run --name my-web-server --detach --rm web-test
  ```

- 显示已启动的容器

  ```zsh
  container ls
  ```

  显示所有容器（包括已停止的容器）

  ```zsh
  container ls -a
  ```

- 打开网址（IP 是上一步显示容器信息的最后一列值），验证我们之前的操作结果是否实现业务逻辑

  ```zsh
  open http://192.168.64.3
  ```

- 在容器中运行命令

  ```zsh
  container exec -it my-web-server sh
  ```

- 从容器中退出来

  ```zsh
  exit
  ```

- 从另一个容器访问 Web 服务器。使用您的 web-test 镜像启动第二个容器，并指定 curl 命令从第一个容器中检索 index.html 内容。

  ```zsh
  container run -it --rm web-test curl http://192.168.64.3
  ```

### 使用 Docker hub 中的镜像

```zsh
container run --name hello-world --detach --rm hello-world
```

输出 `hello-world` 信息。

### 用后清理

- 停止容器（查看容器信息可参考前文）

  ```zsh
  container stop my-web-server
  ```

- 停止容器服务

  ```zsh
  container system stop
  ```

- 完全卸载容器服务（服务 + 数据）

  ```zsh
  uninstall-container.sh -d
  ```

  输完系统密码确认后就完全卸载了。

### 参考

- <https://github.com/apple/container>
- <https://github.com/apple/container/blob/main/docs/tutorial.md>
- <https://github.com/apple/container/blob/main/docs/how-to.md>
