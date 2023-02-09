# Keyviz

<a href="https://www.producthunt.com/posts/keyviz?utm_source=badge-featured&utm_medium=badge&utm_souce=badge-keyviz" target="_blank"><img src="https://api.producthunt.com/widgets/embed-image/v1/featured.svg?post_id=354216&theme=neutral" alt="Keyviz - Visualize&#0032;your&#0032;keystrokes&#0032;in&#0032;real&#0045;time | Product Hunt" style="width: 96px; height: 20px;" width="96" height="20" /></a>
![downloads](https://img.shields.io/github/downloads/mulaRahul/keyviz/total?color=fff)

Keyviz is a free and open-source software to visualise your ⌨️ keystrokes in real time! Let your audience know what handy shortcuts/keys you're pressing during screencasts, presentations, collaborations, or whenever you need it.

![keyviz-preview](previews/key-visual.png)

## 🦄 Style
![multiple-styles](previews/multiple-styles.png)

Don't restrain yourself to just black & white! Change the visualisation's style, size, colour (modifier and regular keys), border, icon, and symbols.

## ⚙️ Fully Customizable
![keyviz-settings](previews/settings-window.png)

Powerful and easy-to-use configuration options. 
- Filter normal keys and only display shortcuts like <kbd>Ctrl</kbd> + <kbd>S</kbd>
- Adjust the visualisation position on the screen
- Decide how much the visualisation lingers on the screen before animating out
- Switch between animation presets to animate your visualisation in & out

# Installation
You can download the latest version of keyviz from the [Github Releases](https://github.com/mulaRahul/keyviz/releases) page. For the installer, unzip the downloaded file, run the installer and follow the familiar steps to install keyviz.

Or, install keyviz using [Winget](https://learn.microsoft.com/en-us/windows/package-manager/):
```powershell
winget install mulaRahul.Keyviz
```

Or from [Scoop](https://scoop.sh/):
```powershell
scoop bucket add extras # first, add the bucket
scoop install keyviz
```

Alternatively, you can get the portable version which doesn't require installation but may or may not work on every system.

# Quickstart
You can also check out this [video tutorial](https://youtu.be/FwuTqWzlRSc).

Follow the above [installation](#installation) process to start. Then, you can start visualising your keystrokes by just running the application.

To open the settings window, find the keyviz icon on the right side of the **Taskbar** or **Taskbar > Hidden Icons <kbd>^</kbd>**. Then right-click on the icon and select **Settings**. 

The settings window will appear, from which you customise the style, appearance, and other general visualisation settings. You can also pause the visualisations temporarily by left-clicking on the tray icon.

## `*.dll` Missing Error?

![57611-error](https://user-images.githubusercontent.com/96373135/208227804-315e4ab9-b846-4266-87f7-789bf6ef1922.png)

If you're getting a `.dll` missing error after installing the application, you're missing the required Visual C++ redistributables. You can get the same from here [VSC++ Redist](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist?view=msvc-170).

# Feature Requests
You can **vote** for planned features in this [📃 poll](https://github.com/mulaRahul/keyviz/discussions/36).

If you want to request features, start a discussion or join our [discord](https://discord.gg/qyrKWCvtEq) community and let us know about your suggestions. You can go ahead and vote for the requested features by others and see the future development plans.
