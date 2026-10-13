; ================================================================
; AHK desktop lite - Inno Setup 打包脚本
;
; 编译：  "D:\Inno Setup 6\ISCC.exe" AHK-desktop-lite.iss
; 产物：  ..\dist\AHK_desktop_lite_Setup.exe
;
; 说明：本程序不含 AutoHotkey 源码，安装包内附 AutoHotkey 官方运行时
;       （AutoHotkey64.exe）及其 license.txt，遵循其 GPLv2 许可。
; ================================================================

#define MyAppName "AHK desktop lite"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Personal project (self-use)"

[Setup]
AppId={{4CE48646-E346-430B-8FC2-5E891E941CF9}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppSupportURL=https://www.autohotkey.com/
DefaultDirName={localappdata}\Programs\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
OutputDir=..\dist
OutputBaseFilename=AHK_desktop_lite_Setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
UninstallDisplayName={#MyAppName}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "..\autohotkey\AutoHotkey64.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\autohotkey\license.txt";      DestDir: "{app}"; DestName: "LICENSE-AutoHotkey.txt"; Flags: ignoreversion
Source: "..\scripts\gui.ahk";             DestDir: "{app}"; Flags: ignoreversion
Source: "..\scripts\type_text.ahk";       DestDir: "{app}"; Flags: ignoreversion
Source: "..\README.md";                   DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}";         Filename: "{app}\AutoHotkey64.exe"; Parameters: """{app}\gui.ahk"""; WorkingDir: "{app}"
Name: "{autodesktop}\{#MyAppName}";   Filename: "{app}\AutoHotkey64.exe"; Parameters: """{app}\gui.ahk"""; WorkingDir: "{app}"

[Run]
Filename: "{app}\AutoHotkey64.exe"; Parameters: """{app}\gui.ahk"""; Description: "Launch {#MyAppName}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: files; Name: "{app}\AHK desktop lite.ini"
