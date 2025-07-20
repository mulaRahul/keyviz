![keyviz-2.0](previews/banner.svg)

Keyviz，实时地可视化键盘和鼠标的操作，免费并开源。在任何你想要的时候，让观众看到你按下了哪些键。

[English](./README.md) | **简体中文**

# ⌨️ 键盘输入 & 🖱️ 鼠标操作

不止键盘，还有鼠标，甚至修饰键+鼠标操作！就像 <kbd>Cmd</kbd> + <kbd>Click</kbd> 和 <kbd>Alt</kbd> + <kbd>Drag</kbd>。

![key-visualizer](previews/visualizer-bar.svg)

# 🎨 个性化

颜色主题不是非黑即白！你能想到的，样式、大小、颜色、图标甚至更多，都可以调整！

![settings-window](previews/settings.svg)

层次分明的设置菜单 —

- 只显示组合键，比如 <kbd>Cmd</kbd> + <kbd>K</kbd>**（默认开启）**
- 按键可视化显示的位置
- 按键显示的停留时间
- 按键出现消失的动画

</br>

# 📥 安装

你可以在 [Github Releases](https://github.com/mulaRahul/keyviz/releases) 下载最新的 Keyviz。如果下载的是安装器版，解压压缩包并运行其中的安装器，随后按步骤操作即可安装。

以下为分系统的特殊步骤 -

<details><summary>🪟 Windows</summary>
  ### 👜 Microsoft Store

  你可以直接从 [Microsoft store](https://apps.microsoft.com/detail/Keyviz/9phzpj643p7l?mode=direct) 下载 Keyviz。

  ### 🥄 Scoop

  ```ps
  scoop bucket add extras # 加附加桶
  scoop install keyviz
  ```

  ### 📦 Winget

  ```ps
  winget install mulaRahul.Keyviz
  ```

  <details><summary>缺少<code>*.dll文件？</code></summary>
    如果你收到了缺少`.dll`文件的错误，应该是缺少 Visual C++ 可再发行程序包。

    你可以在[这里](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist?view=msvc-170)下载它。
  </details>
</details>

<details><summary>🍎 macOS</summary>
  ### 🔒 权限

  Keyviz 需要**输入监视**和**辅助功能**权限才能工作。在这里开启—

  `系统偏好设置` > `隐私与安全性` > `输入监视`/`辅助功能`
</details>

<details><summary>🐧 Linux</summary>
  ### ❗ v2.x.x 依赖项

  ```sh
  sudo apt-get install libayatana-appindicator3-dev
  ```

  或者是

  ```sh
  sudo apt-get install appindicator3-0.1 libappindicator3-dev
  ```
</details>

# 🛠️ 构建说明

在进一步开发、编译之前，请确保在系统上安装好了 Flutter，可以参照官方的[安装指南](https://docs.flutter.dev/get-started/install)。

安装并设置好 Flutter 后，用`git`克隆仓库或下载压缩包并解压。

```bash
mkdir keyviz
cd keyviz
git clone https://github.com/mulaRahul/keyviz.git .
```

进入 Flutter 项目目录并运行编译命令来构建可执行文件—

```bash
flutter build windows
```

</br>

# 💖 支持

Keyviz 是免费的，唯一的收益来源即为你们的慷慨捐赠。这可以帮助我在空闲时间更多地开发 Keyviz。

|zh-Hans|Translators|Thanks!|
|:--|:--|---|
|`2023-07-18`|@Miuzarte|第一个 commit！|
|`2025-07-21`|@I21b|同步 en & 小优化～|
