#Requires AutoHotkey v2.0
#SingleInstance Force
; ================================================================
; AHK desktop lite —— 简易键盘输入器（个人自用小工具）
;
; 基于 AutoHotkey v2 开发。AutoHotkey 版权归其作者所有，GPLv2 许可：
;   https://www.autohotkey.com/
; 本程序只做「界面 + 逐键输入逻辑」的封装，不含 AutoHotkey 源码本身。
; 若涉及任何侵权内容，请联系删除。
;
; 界面用 AutoHotkey 内置的 Gui 类，底下全是 Windows 原生控件
; （Edit / Button / DropDownList / CheckBox），不引入任何第三方绘制库。
;
; 热键：F9 开始输入（全局，不必让本窗口在前台）；Esc 中止（仅在本工具工作期间拦截）
; 配置：与程序同目录的 AHK desktop lite.ini
;
; 本文件含中文，必须存成 UTF-8 BOM（只能一个，不能重复加）。
; 字符串一律用单引号——AHK v2 不支持用双写引号转义双引号。
; ================================================================

APP_TITLE := 'AHK desktop lite'
INI_PATH  := A_ScriptDir '\AHK desktop lite.ini'

SPEEDS  := ['慢速 (30 WPM)', '普通程序员 (50 WPM)', '熟练 (70 WPM)', '飞快 (100 WPM)', '自定义']
WPM_OF  := [30, 50, 70, 100, 0]

Busy     := false
StopFlag := false
Syncing  := false

; ---------------- 读配置（没有配置文件就用默认值） ----------------
cfgWpm   := IniRead(INI_PATH, 'settings', 'wpm', 50)
cfgWait  := IniRead(INI_PATH, 'settings', 'wait', 3)
cfgPause := IniRead(INI_PATH, 'settings', 'pauses', 1)
cfgIdx   := IniRead(INI_PATH, 'settings', 'speedidx', 2)

; ---------------- 界面 ----------------
g := Gui('+MinSize544x500 -MaximizeBox', APP_TITLE)
g.SetFont('s10', 'Microsoft YaHei')

g.Add('Text',     'x12 y12 w520', '要输入的内容（可以直接整段粘进来）：')
txtBody := g.Add('Edit', 'x12 y34 w520 h200 Multi WantReturn VScroll')

btnOpen  := g.Add('Button', 'x12 y242 w96 h28', '从文件载入')
btnClear := g.Add('Button', 'x114 y242 w72 h28', '清空')
lblCount := g.Add('Text',   'x196 y248 w200', '(0 字)')

g.Add('Text',     'x12 y282 w76', '打字速度：')
ddlSpeed := g.Add('DropDownList', 'x92 y278 w200 Choose' cfgIdx, SPEEDS)
edWpm    := g.Add('Edit', 'x300 y278 w56 Number', cfgWpm)
g.Add('Text',     'x362 y282 w60', 'WPM')

g.Add('Text',     'x12 y316 w76', '开始前等待：')
edWait   := g.Add('Edit', 'x92 y312 w50 Number', cfgWait)
g.Add('Text',     'x150 y316 w280', '秒（留出时间切到目标窗口）')

cbPauses := g.Add('CheckBox', 'x12 y348 w520 ' (cfgPause ? 'Checked' : ''), '停顿节奏（标点后稍慢 + 每 25 字偶发停顿）')

lblStatus := g.Add('Text', 'x12 y382 w520', '就绪。把内容填上，然后点下面的按钮。')

btnStart := g.Add('Button', 'x12 y412 w160 h36 Default', '开始输入  (F9)')
btnStop  := g.Add('Button', 'x180 y412 w110 h36 Disabled', '停止  (Esc)')

lblHint  := g.Add('Text', 'x12 y460 w520', '提示：点“开始输入”后，请在等待时间内把光标点到目标输入框。全程不碰剪贴板。')

btnOpen.OnEvent('Click',  (*) => PickFile())
btnClear.OnEvent('Click', (*) => ClearBody())
btnStart.OnEvent('Click', (*) => StartRun())
btnStop.OnEvent('Click',  (*) => AbortRun())
txtBody.OnEvent('Change', (*) => RefreshCount())
ddlSpeed.OnEvent('Change', (*) => SyncFromDDL())
edWpm.OnEvent('Change',   (*) => SyncToDDL())
g.OnEvent('Close', (*) => CloseApp())

g.Show('w544 h500')

; ---------------- 热键 ----------------
F9::StartRun()

#HotIf Busy
Esc::AbortRun()
#HotIf

; ---------------- 配置读写（配置文件就在程序目录下） ----------------
SaveSettings() {
    global INI_PATH, edWpm, edWait, cbPauses, ddlSpeed
    try {
        IniWrite(edWpm.Value,    INI_PATH, 'settings', 'wpm')
        IniWrite(edWait.Value,   INI_PATH, 'settings', 'wait')
        IniWrite(cbPauses.Value, INI_PATH, 'settings', 'pauses')
        IniWrite(ddlSpeed.Value, INI_PATH, 'settings', 'speedidx')
    }
}

CloseApp() {
    SaveSettings()
    ExitApp()
}

; ---------------- 界面逻辑 ----------------
ShowStatus(msg) {
    global lblStatus
    lblStatus.Text := msg
}

RefreshCount(*) {
    global txtBody, lblCount
    lblCount.Text := '(' StrLen(txtBody.Value) ' 字)'
}

ClearBody() {
    global txtBody
    txtBody.Value := ''
    RefreshCount()
    ShowStatus('已清空。')
}

PickFile() {
    global txtBody
    picked := FileSelect('', '', '选择要输入的文本文件', '文本文件 (*.txt;*.md;*.csv;*.log)')
    if (picked = '')
        return
    try
        raw := FileRead(picked, 'UTF-8')
    catch as e {
        ShowStatus('读取失败：' e.Message)
        return
    }
    ; 去掉可能存在的 UTF-8 BOM，否则开头会多出一个看不见的怪字符
    if (SubStr(raw, 1, 1) = Chr(0xFEFF))
        raw := SubStr(raw, 2)
    txtBody.Value := raw
    RefreshCount()
    ShowStatus('已载入：' picked)
}

SyncFromDDL(*) {
    global ddlSpeed, edWpm, Syncing, WPM_OF
    if (Syncing)
        return
    Syncing := true
    i := ddlSpeed.Value
    if (i >= 1 && i <= 4)
        edWpm.Value := WPM_OF[i]
    Syncing := false
}

SyncToDDL(*) {
    global ddlSpeed, edWpm, Syncing, WPM_OF
    if (Syncing)
        return
    Syncing := true
    v := edWpm.Value + 0
    hit := 0
    for i, w in WPM_OF {
        if (i <= 4 && w = v) {
            hit := i
            break
        }
    }
    ddlSpeed.Value := (hit = 0) ? 5 : hit
    Syncing := false
}

; ---------------- 执行流程 ----------------
StartRun() {
    global Busy, StopFlag, Counter, txtBody, edWait, btnStart, btnStop
    if (Busy)
        return
    if (Trim(txtBody.Value) = '') {
        ShowStatus('内容为空，先写点东西或从文件载入。')
        return
    }
    SaveSettings()
    Busy := true
    StopFlag := false
    btnStart.Enabled := false
    btnStop.Enabled  := true
    Counter := edWait.Value + 0
    if (Counter < 0)
        Counter := 0
    TickCountdown()
}

TickCountdown() {
    global Busy, StopFlag, Counter
    if (StopFlag) {
        EndRun(false)
        return
    }
    if (Counter > 0) {
        ShowStatus('还有 ' Counter ' 秒 —— 请把光标点到目标输入框…')
        Counter -= 1
        SetTimer(TickCountdown, -1000)
    } else {
        DoTyping()
    }
}

DoTyping() {
    global txtBody, edWpm, cbPauses
    content := txtBody.Value
    wpm := edWpm.Value + 0
    if (wpm <= 0)
        wpm := 50
    ShowStatus('输入中…  (Esc 停止)')
    ok := TypeHuman(content, wpm, cbPauses.Value)
    EndRun(ok)
}

EndRun(ok) {
    global Busy, StopFlag, btnStart, btnStop, txtBody
    Busy := false
    StopFlag := false
    btnStart.Enabled := true
    btnStop.Enabled  := false
    if (ok)
        ShowStatus('完成，共 ' StrLen(txtBody.Value) ' 字。')
    else
        ShowStatus('已停止。')
}

AbortRun() {
    global StopFlag
    StopFlag := true
    ShowStatus('正在停止…')
}

; ---------------- 逐键输入 ----------------
; 匀速逐字符发送，全程不碰剪贴板。
; pauses = 1 时额外加「标点后稍慢」和「每 25 字偶发停顿」，让手感自然；
; 不加随机抖动 —— 挨得太近的按键容易被个别网页当成重复输入。
TypeHuman(text, wpm, pauses) {
    global StopFlag
    baseMs := 60000 / (wpm * 5)
    if (baseMs < 40)
        baseMs := 40          ; 间隔托底：太快容易被网页吞字或判成重复
    idx := 0
    for ch in StrSplit(text) {
        if (StopFlag)
            return false
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
        if (pauses) {
            if (ch ~= '[,，。.、；;：:！!？?）)】]')
                gap += baseMs * Random(0.6, 1.4)
            if (Mod(idx, 25) = 0 && Random(1, 100) <= 50)
                gap += Random(400, 1000)
        }
        Sleep(Round(gap))
    }
    return true
}
