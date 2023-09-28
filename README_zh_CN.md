![keyviz-2.0](previews/banner.svg)

Keyviz，一个免费开源的实时键鼠输入可视化软件，让观众了解你在演示的过程中按下了什么快捷键

**简体中文** | [English](./README.md)

# ⌨️ 键盘输入 & 🖱️ 鼠标操作

Keyviz也可以显示鼠标、键盘+鼠标的操作，比如 <kbd>Cmd</kbd> + <kbd>Click</kbd> 或 <kbd>Alt</kbd> + <kbd>Drag</kbd>

![key-visualizer](previews/visualizer-bar.svg)

# 🎨 个性化

不只有黑与白，Keyviz可以高度自定义按键的显示效果，包括但不限于：预设风格、尺寸、键位图标显示切换（Shift的↑）、辅助键和常规键的颜色、边框

![settings-window](previews/settings.svg)

强大易用的设置菜单

- 隐藏常规键，留下组合键，比如只显示 <kbd>Cmd</kbd> + <kbd>K</kbd>**（默认）**
- 显示位置（区域、距离主显示器边缘的距离）
- 按键显示的停留时间
- 按键切入切出的动画

</br>

# 📥 安装

在 [Github Releases](https://github.com/mulaRahul/keyviz/releases) 下载最新版，根据操作系统安装/解压即用，或者通过下面的包管理器安装

<details>
  <summary>🥄 Scoop</summary>
    
  ```bash
  scoop bucket add extras # first, add the bucket
  scoop install keyviz
  ```

</details>

<details>
  <summary>🪟 Winget</summary>
    
  ```bash
  winget install mulaRahul.Keyviz
  ```

</details>

</br>

<details>
  <summary>提示缺少<code>*.dll</code>？</summary>
    
  如果运行程序弹出了缺少`.dll`文件的错误，大概率是环境缺少了VC++运行库，你可以在[**这里**](https://learn.microsoft.com/zh-cn/cpp/windows/latest-supported-vc-redist?view=msvc-170)下载安装

</details>

</br>

# 🛠️ 构建说明

在进一步开发、编译之前，请确保在系统上安装好了Flutter，可以参照[官方的安装指南](https://docs.flutter.dev/get-started/install)

安装并设置好Flutter后，克隆仓库或下载zip并解压

```bash
mkdir keyviz
git clone https://github.com/mulaRahul/keyviz.git .
```

cd到项目文件夹内 开始编译

```bash
cd keyviz
# 获取依赖
flutter pub get
# 编译可执行文件
flutter build windows
```

</br>

# 💖 支持该项目

Keyviz是一个免费项目，唯一的收益来源只有你们的慷慨捐赠，这将有助于我腾出更多的空余时间用于开发Keyviz

</br>

<details>
  <summary></summary>
  译于23/7/18，v2.0.0a发布的七天后，有些条目是作者还没改上去的，部分描述其实跟软件本体差挺多的
</details>
