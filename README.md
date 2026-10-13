# AHK desktop lite

个人自用的小工具：把一段文本**逐键**打进当前光标所在的输入框，全程**不碰剪贴板**。

主要用在**禁用了粘贴**的网页输入框上——网站拦得住 Ctrl+V，拦不住真实的键盘事件。

> **说明**：这是个人制作的简易 GUI，纯自用，不是正规产品。
> 基于 **AutoHotkey v2** 开发，界面用 AHK 内置的 `Gui` 类（Windows 原生控件），
> 不引入任何第三方绘制库。感谢 AutoHotkey 项目及其社区。
> 若本仓库内容涉及侵权，请联系我，我会立即删除。

---

## 下载安装

到 [Releases](../../releases) 下载 `AHK_desktop_lite_Setup.exe`，双击安装。

- **不需要管理员权限**，默认装到 `%LOCALAPPDATA%\Programs\AHK desktop lite`
- 会创建开始菜单和桌面快捷方式
- 安装向导是**英文**的（Inno Setup 官方不带简体中文语言包），一路 Next 即可
- 卸载走系统「应用和功能」，或安装目录里的 `unins000.exe`

## 使用

1. 打开 **AHK desktop lite**
2. 把要输入的内容粘进上方的输入框（往这里粘贴是本地操作，跟目标网站禁不禁粘贴无关）
3. 选打字速度，设好「开始前等待」秒数
4. 点 **开始输入**（或直接按 `F9`）
5. 在倒计时内把光标点到目标输入框，剩下的交给它

| 热键 | 作用 |
| --- | --- |
| `F9` | 开始输入（全局，不必让窗口在前台） |
| `Esc` | 中止输入（**只在本工具工作期间拦截**，平时 Esc 不受影响） |

其他：`从文件载入` 可以直接读一个 txt（按 UTF-8 读，并会自动去掉 BOM）；
`停顿节奏` 开关控制要不要在标点后和长文本中途加停顿。

## 打字速度

`WPM` 是每分钟多少"词"，按 1 词 = 5 字符折算：`60000 / (WPM × 5)` 毫秒每字符。

| WPM | 每字符间隔 | 大概相当于 |
| --- | --- | --- |
| 30 | 约 400ms | 慢速 |
| 50 | 约 240ms | 普通程序员（默认） |
| 70 | 约 170ms | 打得比较快 |
| 100 | 约 120ms | 飞快 |

脚本会保证间隔不低于 40ms——再快就不是人打字，而是灌数据了，也容易被网页吞字或判成重复输入。

打开 `停顿节奏` 后，还会额外加两层：标点后稍慢一点、每 25 个字符有几率插一次 0.4~1 秒的停顿。
**不加随机抖动**：挨得太近的按键在某些网页上会被当成重复输入。

## 配置文件

与程序同目录的 `AHK desktop lite.ini`，**只保存**打字速度、等待秒数、停顿开关这几项设置，
**不保存你输入过的任何内容**。删掉它就会恢复默认值。

## 实现说明（给想改代码的人）

程序只有一个 `gui.ahk`，双击 `run-gui.bat` 或直接用 AutoHotkey v2 运行即可，不需要编译。

几条踩过的坑，写在前面省得你也摔：

1. **字符串一律用单引号**。AHK v2 删掉了 v1 里「两个双引号表示一个字面双引号」的写法，
   写了会直接报 `Missing space or operator`。要在双引号串里放引号，用反引号转义，或者改用单引号。
2. **含中文的 `.ahk` 必须存成 UTF-8 BOM**（只能一个，重复加会让首行 `#Requires` 变成非法字符）。
   不加 BOM 的话 AHK 会按系统 ANSI(GBK) 读，中文全乱。
3. **变量名不能撞内置函数名**，比如 `log`、`mod`、`round`、`chr`，撞了会报
   `This Func cannot be used as an output variable`。
4. **`.bat` 里不要写中文**，连 `rem` 注释都不行——cmd 按 GBK 读 UTF-8 批处理会把中文拆坏。
5. **查语法不弹窗**：`AutoHotkey64.exe /ErrorStdOut /validate <脚本>`，错误走 stdout、返回码 2。
   （Git Bash 里要加 `MSYS_NO_PATHCONV=1`，否则开关名会被当路径转换。）

## 打包

安装包用 [Inno Setup](https://jrsoftware.org/isinfo.php) 编译：

```bat
"D:\Inno Setup 6\ISCC.exe" installer\AHK-desktop-lite.iss
```

产物在 `dist\AHK_desktop_lite_Setup.exe`。

## 基于 AutoHotkey

- 项目主页：<https://www.autohotkey.com/>
- 许可：GPLv2（安装包内附 `LICENSE-AutoHotkey.txt`）
- 本仓库**只包含界面与输入逻辑的脚本**，不含 AutoHotkey 源码本身；
  安装包里附的是 AutoHotkey 官方发布的运行时 `AutoHotkey64.exe`，未做任何修改。

## 致谢

- [AutoHotkey](https://www.autohotkey.com/) 项目及其社区 —— 没有它就没有这个小工具。
- 吃白饭的大肥鱼 deepseek V4.1 flash 为本项目提供助力。

## 免责声明

本工具按「现状」提供，个人自用，不保证适用于任何特定用途，使用产生的一切后果自负。

如认为本仓库的任何内容侵犯了您的权益，请联系我，我会**立即删除**。
