![keyviz-2.0](previews/banner.svg)

Keyviz, 一个免费开源的实时键鼠输入可视化软件, 让观众了解你在演示过程中按下了哪些快捷键

**简体中文** | [English](./README.md)

# ⌨️ 键盘输入 & 🖱️ 鼠标操作

Keyviz 现在也可以显示鼠标操作！不仅是鼠标点击, 还可以显示与键盘组合的鼠标操作, 比如 <kbd>Cmd</kbd> + <kbd>Click</kbd> 或 <kbd>Alt</kbd> + <kbd>Drag</kbd> 等等

![key-visualizer](previews/visualizer-bar.svg)

# 🎨 个性化

不仅限于黑白两色, Keyviz 可以高度自定义按键的显示效果, 包括但不限于：预设风格、尺寸、颜色（辅助键和常规键）、边框、图标等

![settings-window](previews/settings.svg)

强大且易用的设置菜单

- 过滤常规键, 只显示快捷键组合, 比如 <kbd>Cmd</kbd> + <kbd>K</kbd> **（默认）**
- 调整显示位置
- 设置按键显示的停留时间
- 切换动画预设, 设置按键显示和消失的动画效果

</br>

# 📥 安装

你可以从 [Github Releases](https://github.com/mulaRahul/keyviz/releases) 页面下载最新版的 Keyviz, 根据操作系统安装或解压即可

或者通过以下包管理器安装

<details>

  <summary>🪟 Windows</summary>

  ### 👜 Microsoft Store
  可以直接从 [Microsoft Store](https://apps.microsoft.com/detail/Keyviz/9phzpj643p7l?mode=direct) 下载 Keyviz

  ### 🥄 Scoop
  ```bash
  scoop bucket add extras # 首先添加 bucket
  scoop install keyviz
  ```

  ### 📦 Winget
  ```bash
  winget install mulaRahul.Keyviz
  ```

  </br>

  <details>
  <summary>提示缺少<code>*.dll</code>?</summary>

  如果运行程序时提示缺少 `.dll` 文件, 可能是缺少 VC++ 运行库，你可以在[这里](https://learn.microsoft.com/zh-cn/cpp/windows/latest-supported-vc-redist?view=msvc-170)下载安装

  </details>

</details>

</br>

<details>

  <summary>🍎 MacOS</summary>

  ### 🔒 权限
  
  Keyviz 需要 **输入监控** 和 **辅助功能** 权限，请在设置中启用：
  </br>
  ```
  设置 > 隐私与安全 > 输入监控/辅助功能
  ```

  </br>

</details>

</br>

<details>

  <summary>🐧 Linux</summary>

  ### ❗ v2.x.x 需求
  ```bash
  sudo apt-get install libayatana-appindicator3-dev
  ```
  或
  ```bash
  sudo apt-get install appindicator3-0.1 libappindicator3-dev
  ```

  </br>

</details>


</br>

# 🛠️ 构建说明

在开发/编译之前, 请确保在系统上安装好了 Flutter, 可以参照[官方的安装指南](https://docs.flutter.dev/get-started/install)

安装并设置好 Flutter 后, 克隆仓库或下载 zip 并解压

```bash
mkdir keyviz
cd keyviz
git clone https://github.com/mulaRahul/keyviz.git .
```

进入项目文件夹并开始编译：

```bash
flutter build windows
```

</br>

# 💖 支持该项目

Keyviz 是一个免费项目, 唯一的收益来源是你们的慷慨捐赠, 这将有助于我腾出更多的时间用于开发 Keyviz
