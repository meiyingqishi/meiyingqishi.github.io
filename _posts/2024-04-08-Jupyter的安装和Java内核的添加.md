---
layout: post
title: Jupyter 的安装和 Java 内核的添加
date: 2024-04-08 20:00:00 +0800
categories: 工具
tags:  jupyter ijava
excerpt: 在 Mac 本地安装 Jupyter lab, 并为其安装 Java 内核 IJava。
---

![The cover for Jupyter icon](/images/jupyter_app_icon_161280.png)

## 目录

- [1. 引言](#1-引言)
- [2. 注意事项](#2-注意事项)
- [3. 前提条件](#3-前提条件)
- [4. 避坑提示](#4-避坑提示)
- [5. 操作步骤](#5-操作步骤)
- [6. 常用命令](#6-常用命令)
- [7. 深入了解](#7-深入了解)
- [8. 参考资源](#8-参考资源)

## 1. 引言

当我在 [zyb0408.github.io][on-java8-blog] 博客阅读 [《On Java 8》][on-java8] 时看到
博客推荐安装 [Jupyter Lab][jupyter-install] 时, 顺势尝试安装了以下, 踩了一些坑, 填满了坑后, 觉得有
必要记录 📝 一下以备不时之需。

## 2. 注意事项

- 系统：笔者使用的是 `macOS` 系统，其它系统操作类似。
  使用的脚本语言解释器为 `zsh`, 切换指令

  ```bash
  chsh -s /bin/zsh
  ```

- 如果运行中遇到权限问题, 可在命令前加 `sudo` 后再重新执行。

## 3. 前提条件

- 科学上网环境。如无可参考笔者的 [科学上网之 Gost 方案 v2][beyondgfw]。

- 如果未安装则安装 [Homebrew][homebrew], 以便安装管理其它工具

  ```bash
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ```

- 如果未安装则安装 [wget][wget]

  ```bash
  brew install wget
  ```

- 如果未安装则安装 [Python][python], Jupyter 依赖 Python 环境

  ```bash
  brew install python
  ```

- 安装 [SDKMAN][sdkman-install]

  ```bash
  curl -s "https://get.sdkman.io" | bash
  source "$HOME/.sdkman/bin/sdkman-init.sh"
  ```

  查看是否安装成功, 执行
  
  ```bash
  sdk version
  ```

  如果显示类似如下信息则表示安装成功

  ```bash
  SDKMAN!
  script: 5.18.2
  native: 0.4.6
  ```

- 使用 SDKMAN 安装 Java 环境

  ```bash
  sdk install java
  ```

## 4. 避坑提示

由于笔者使用 Homebrew 安装的 Python, 所以在后续使用:

```bash
python3 install.py --sys-prefix
```

安装 IJava 的时候会遇到错误:

```text
Traceback (most recent call last):
File "/Users/myqs/Downloads/ijava/install.py", line 6, in <module>
  from jupyter_client.kernelspec import KernelSpecManager
ModuleNotFoundError: No module named ‘jupyter_client'
```

且包括但不限于在官网查了很多资料, 都没能解决问题, 最后只好通过 Python 的 [venv 虚拟环境][python-venv]来安装,
所以这篇博文是介绍在 Python 虚拟环境中安装 Jupyter 的文章。

笔者还未尝试过不通过 Homebrew 而直接安装 Python 后再来安装 Jupyter 的情况, 欢迎读者自行尝试并反馈结果。

## 5. 操作步骤

- 创建虚拟环境

  ```bash
  python3 -m venv jupyter-venv
  ```

- 激活虚拟环境

  ```bash
  source jupyter-venv/bin/activate
  ```

- 安装 JupyterLab

  ```bash
  pip install jupyterlab
  ```

- 安装 IJava

  - [环境要求][ijava-requirements]: Java JDK >= 9

  - 下载 [IJava][ijava-releases]

    ```bash
    wget https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip
    ```

  - 解压 ijava-1.3.0.zip, 进入 ijava

    ```bash
    unzip ijava-1.3.0.zip -d ijava && ijava
    ```

  - 安装 IJava

    ```bash
    python3 install.py --sys-prefix
    ```

  - 查看安装情况

    ```bash
    jupyter kernelspec list
    ```

    如果输出结果如下所示, 包含 java 内核, 则说明安装成功

    ```bash
    Available kernels:
    java       /Users/myqs/Documents/jupyter-venv/share/jupyter/kernels/java
    python3    /Users/myqs/Documents/jupyter-venv/share/jupyter/kernels/python3
    ```

- 启动 JupyterLab

  ```bash
  jupyter lab
  ```

- 效果截图

  ![Jupyterlab notebook](/images/jupyterlab-notebook.png)

  ![Jupyterlab notebook run hello world](/images/jupyterlab-notebook-helloworld.png)

- 退出 Python venv 虚拟环境

  ```bash
  deactivate
  ```

## 6. 常用命令

- SDKMAN
  - 查看 SDKMAN 安装的版本信息

    ```bash
    sdk version
    ```

  - 安装最新版 Java

    ```bash
    sdk install java
    ```

  - 安装特定版本 Java

    ```bash
    sdk install java 21.0.2-tem
    ```
  
  - 卸载已安装的 Java 版本

    ```bash
    sdk uninstall java 21.0.2-tem
    ```

  - 显示可安装的软件包类型

    ```bash
    sdk list
    ```

  - 显示可用 Java 版本信息列表

    ```bash
    sdk list java
    ```

  - 选择在当前终端中使用给定版本

    ```bash
    sdk use java 21.0.2-tem
    ```

  - 选择将给定版本设置为默认版本

    ```bash
    sdk default java 21.0.2-tem
    ```

  - 查看当前正在使用的版本内容

    ```bash
    sdk current java
    ```

- Jupyter
  - 列出当前 Jupyter 环境中可用的内核

    ```bash
    jupyter kernelspec list
    ```

  - 安装新的内核

    ```bash
    jupyter kernelspec install ijava/install.py
    ```

  - 卸载指定的内核

    ```bash
    jupyter kernelspec uninstall java
    ```

## 7. 深入了解

- [Jupyter][jupyter]
- [IJava][ijava]

## 8. 参考资源

- [科学上网之Gost方案v2][beyondgfw]
- [Jupyter][jupyter]
- [IJava][ijava]
- [Jupyter][jupyter]
- [Python][python]
- [SdkMan][sdkman]

[beyondgfw]: https://meiyingqishi.github.io/科学上网/2023/05/20/科学上网之Gost方案v2.html
[homebrew]: https://brew.sh/zh-cn
[wget]: https://www.gnu.org/software/wget
[sdkman]: https://sdkman.io
[sdkman-install]: https://sdkman.io/install
[on-java8]: https://www.onjava8.com
[on-java8-blog]: https://zyb0408.github.io/gitbooks/onjava8
[ijava]: https://github.com/SpencerPark/IJava
[ijava-releases]: https://github.com/SpencerPark/IJava/releases
[ijava-requirements]: https://github.com/SpencerPark/IJava?tab=readme-ov-file#requirements
[jupyter]: https://jupyter.org
[jupyter-install]: https://jupyter.org/install
[python]: https://www.python.org
[python-venv]: https://docs.python.org/zh-cn/3/library/venv.html
