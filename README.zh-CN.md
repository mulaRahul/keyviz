# [Keyviz](https://keyviz.org)

[English](./README.md) | **简体中文**

<div>
   <img src="https://img.shields.io/github/v/release/mulaRahul/keyviz?style=flat-square" alt="Releases">
   <img src="https://img.shields.io/github/downloads/mulaRahul/keyviz/total?style=flat-square" alt="Downloads">
   <img src="https://img.shields.io/github/stars/mulaRahul/keyviz?style=flat-square" alt="Stars">
   <img src="https://img.shields.io/github/license/mulaRahul/keyviz?style=flat-square" alt="License">
   <img src="https://img.shields.io/badge/platform-Windows%20%7C%20macOS-lightgrey?style=flat-square" alt="Platform Support">
</div>

Keyviz 是一个**免费开源**工具，可以实时可视化你的键盘按键和鼠标操作。在教程、演示、协作或任何需要展示操作过程的场景中，都可以清晰地告诉观众你正在使用哪些快捷键。

## ⌨️ 按键与 🖱️ 鼠标操作可视化
除了普通按键，还可以可视化鼠标操作，比如 <kbd>Cmd</kbd> + <kbd>Click</kbd>、<kbd>Alt</kbd> + <kbd>Drag</kbd> 等组合。

<img src="previews/visualization.png" alt="Keystroke Visualization" width="450">

你还可以在光标附近显示鼠标点击与滚轮动作。

<img src="previews/mouse-indicator.gif" alt="Mouse Indicator" width="450">

</br>

## ⚙️ 高度可定制
你不需要局限于默认样式，几乎所有可视化细节都可自定义：
- **样式：** 调整颜色（修饰键与普通键）、大小、布局、边框和背景。
- **过滤：** 通过热键过滤或自定义过滤控制显示哪些按键。
- **历史：** 保留最近输入的可视化轨迹。
- **位置：** 将可视化区域移动到屏幕任意位置。
- **动画：** 自定义输入出现与消失的动画效果。

</br>

<img src="previews/settings.png" alt="Settings Panel" width="600">

</br>

## 📥 安装

### Windows 与 macOS
你可以在 **[GitHub Releases](https://github.com/mulaRahul/keyviz/releases)** 页面下载 Keyviz 的最新版本。

*   **Windows：** 下载 `.msi` 安装包并按提示完成安装。
*   **macOS：** 下载 `.dmg`。
    **注意：** Keyviz 需要 **Input Monitoring** 与 **Accessibility** 权限，请在这里开启：
    `Settings > Privacy & Security > Input Monitoring & Accessibility`

### Linux (x11)
Keyviz 支持基于 X11 协议的 Linux。当前可通过下方源码构建方式体验。

</br>

## 🛠️ 从源码构建

如果你想参与贡献或体验最新功能，请先在系统中安装好 [Node.js](https://nodejs.org/) 与 [Tauri](https://v2.tauri.app/start)。

1.  **克隆仓库：**
    ```bash
    git clone https://github.com/mulaRahul/keyviz.git
    cd keyviz
    ```

2.  **安装依赖：**
    ```bash
    npm install
    ```

3.  **构建可执行文件：**
    ```bash
    npx tauri build
    ```

<br/>

## 💖 支持项目

*   **Star 仓库：** 帮助更多人发现 Keyviz。
*   **GitHub Sponsors：** [赞助 @mularahul](https://github.com/sponsors/mulaRahul)
*   **Keyviz Pro：** 获取更多高级功能，同时支持开源项目持续开发。

👉 **[前往 keyviz.org/pro 升级 Pro](https://keyviz.org/pro)**

</br>

---

由 <a href="https://v2.tauri.app/">Tauri</a> 驱动，使用 🦀 与 ❤️ 构建。
