#Requires AutoHotkey v2.0
#SingleInstance Off
; ================================================================
; type_text.ahk —— 逐键模拟真人打字，输入到当前活动窗口
;
; 用法：
;   AutoHotkey64.exe type_text.ahk "文本"            [等待秒] [WPM]
;   AutoHotkey64.exe type_text.ahk "@文本文件路径"    [等待秒] [WPM]
;
;   等待秒   默认 5   —— 留出时间让你切到目标输入框
;   WPM      默认 50  —— 打字速度，50 词/分 ≈ 普通程序员
;                        （1 词按 5 字符算 → 每字符约 240ms）
;
; 例：
;   type_text.ahk "hello world" 5 50
;   type_text.ahk "@D:\text\note.txt" 5 45
;
; 为什么这样设计：
;   - 逐字符 SendText（SendInput 模式），走真实键盘事件，完全不碰剪贴板
;     → 对禁用粘贴的网页有效
;   - 匀速发送，不做随机抖动；只在标点后稍慢、长文本偶发停顿
;   - 间隔不低于 40ms —— 挨得太近的按键容易被个别网页当成重复输入
;
; 注意：目标窗口若以管理员身份运行，本脚本也要以管理员身份启动，
;       否则 Windows 的 UIPI 会把模拟输入拦掉（表现为敲了没反应）。
;
; 本文件必须存成 UTF-8 BOM，否则中文会乱码。
; 字符串一律用单引号，不要用双写引号转义（AHK v2 不认这种写法）。
; ================================================================

if (A_Args.Length < 1) {
    MsgBox('用法: type_text.ahk  "文本"  或  "@文件路径"   [等待秒] [WPM]     例: "hello" 5 50', 'AHK desktop lite', 'Icon!')
    ExitApp(1)
}

src     := A_Args[1]
waitSec := (A_Args.Length >= 2) ? A_Args[2] + 0 : 5
wpm     := (A_Args.Length >= 3) ? A_Args[3] + 0 : 50
if (wpm <= 0)
    wpm := 50

if (SubStr(src, 1, 1) = '@') {
    fp := SubStr(src, 2)
    if !FileExist(fp) {
        MsgBox('文本文件不存在: ' fp, 'AHK desktop lite', 'Icon!')
        ExitApp(1)
    }
    raw := FileRead(fp, 'UTF-8')
    ; 去掉可能存在的 UTF-8 BOM，否则开头会多出一个看不见的怪字符
    if (SubStr(raw, 1, 1) = Chr(0xFEFF))
        raw := SubStr(raw, 2)
    text := raw
} else {
    text := src
}

if (text = '') {
    MsgBox('没有要输入的文本。', 'AHK desktop lite', 'Icon!')
    ExitApp(1)
}

; WPM 折算击键间隔（1 词 = 5 字符）
baseMs := 60000 / (wpm * 5)
if (baseMs < 40)
    baseMs := 40          ; 间隔托底：太快容易被网页吞字或判成重复

Sleep(Round(waitSec * 1000))

idx := 0
for ch in StrSplit(text) {
    if (ch = Chr(13))
        continue
    if (ch = Chr(10)) {
        Send('{Enter}')
        idx += 1
        Sleep(Round(baseMs * 2))
        continue
    }
    SendText(ch)
    idx += 1
    gap := baseMs
    if (ch ~= '[,，。.、；;：:！!？?）)】]')      ; 标点后稍慢
        gap += baseMs * Random(0.6, 1.4)
    if (Mod(idx, 25) = 0 && Random(1, 100) <= 50)   ; 每 25 字有 50% 概率停顿一下
        gap += Random(400, 1000)
    Sleep(Round(gap))
}

ExitApp(0)
