; ----------------------------------------------------------------------------
;
;                          ,--,       ,--.
;      ,---,             ,--.'|   ,--/  /|
;     '  .' \         ,--,  | :,---,': / '
;    /  ;    '.    ,---.'|  : ':   : '/ /
;   :  :       \   |   | : _' ||   '   ,
;   :  |   /\   \  :   : |.'  |'   |  /
;   |  :  ' ;.   : |   ' '  ; :|   ;  ;
;   |  |  ;/  \   \'   |  .'. |:   '   \
;   '  :  | \  \ ,'|   | :  | '|   |    '
;   |  |  '  '--'  '   : |  : ;'   : |.  \
;   |  :  :        |   | '  ,/ |   | '_\.'
;   |  | ,'        ;   : ;--'  '   : |
;   `--''          |   ,/      ;   |,'
;                  '---'       '---'
;
;  Autohotkey Keybindings
; 
;  Sets up the hotkey bindings for Windows.
;
;  ---
;
;  Author:  
;  Eugene Ching (eugene@enegue.com)
;  www.codejury.com
;  @eugeneching
;
; ----------------------------------------------------------------------------

; Modifier keys:
;   # - Win
;   ^ - Ctrl
;   ! - Alt
;   + - Shift


;-----------------------------------------------------------------------------
; Initialization / Globals
;-----------------------------------------------------------------------------

; Detect 32-bit or 64-bit Windows

WIN64 := ""
IfExist, C:\Program Files (x86)\*
  WIN64 := "yes"


; Environment paths

EnvGet, ENV_LOCALAPPDATA, LOCALAPPDATA
EnvGet, ENV_APPDATA, APPDATA
EnvGet, ENV_PATH, PATH

if (WIN64) {
  ; Windows 64-bit
  BITS := " (x86)"
  ENV_PROGRAMFILES32 := "C:\Program Files (x86)"
  ENV_PROGRAMFILES64 := "C:\Program Files"
  ENV_WINDIR := "C:\windows"

} else {
  ; Windows 32-bit
  BITS := ""
  ENV_PROGRAMFILES32 := "C:\Program Files"
  ENV_WINDIR := "C:\windows"
}


; Working directory

if (InStr(FileExist("H:\"),"D"))
  SetWorkingDir, H:\
else
  SetWorkingDir, C:\


; Application paths

BROWSER_CHROME := "C:\Program Files" . BITS . "\Google\Chrome\Application\chrome.exe"
BROWSER_CANARY := ENV_LOCALAPPDATA . "\Google\Chrome SxS\Application\chrome.exe"

EDITOR_VIM := "C:\Program Files" . BITS . "\Vim\vim74\gvim.exe"
EDITOR_EMACS := "C:\Program Files" . BITS . "\Emacs\emacs-24.3\bin\emacsclientw -c -a runemacs.exe"
EDITOR_SUBLIME := "C:\Program Files\Sublime Text 2\sublime_text.exe"
EDITOR := EDITOR_EMACS

IDA_X86 := "C:\Program Files" . BITS . "\IDA\idaq.exe"
IDA_X64 := "C:\Program Files" . BITS . "\IDA\idaq64.exe"

DEBUGGER_X86 := "C:\Program Files (x86)\Windows Kits\8.0\Debuggers\x86\windbg.exe"
DEBUGGER_X64 := "C:\Program Files\Windows Kits\8.0\Debuggers\x64\windbg.exe"
DEBUGGER2_X86 := "C:\Program Files" . BITS . "\Ollydbg\ollydbg.exe"
DEBUGGER2_X64 := "C:\Program Files" . BITS . "\Ollydbg\ollydbg.exe"

HEXEDITOR := "C:\Program Files" . BITS . "\010 Editor\010Editor.exe"
EVERYTHING := "C:\Program Files" . BITS . "\Everything\Everything.exe"
PUTTY := "C:\Program Files" . BITS . "\PuTTy\putty.exe"

IfExist, C:\Program Files\Far Manager
  COMMANDPROMPT := "C:\Program Files\Far Manager\ConEmu64.exe"
Else
  IfExist, C:\Program Files\ConEmu
    COMMANDPROMPT := "C:\Program Files\ConEmu\ConEmu64.exe"
  Else
    COMMANDPROMPT := "cmd.exe"

IfExist, C:\Program Files\GPSoftware\Directory Opus
  EXPLORER := "C:\Program Files\GPSoftware\Directory Opus\dopus.exe"
Else
  EXPLORER := "explorer.exe"

;-----------------------------------------------------------------------------
; Key bindings (Windows)
;-----------------------------------------------------------------------------

;; Win-U (disable it)
#u::
  Return

; Change Capslock to Hyper and Escape

*CapsLock::
  ; Depress all the modifiers
  Send {Blind}{Ctrl DownTemp}{Shift DownTemp}{Alt DownTemp}{LWin DownTemp}
  cDown := A_TickCount
  Return

*CapsLock up::
  Send {Blind}{Ctrl Up}{Shift Up}{Alt Up}{LWin Up}

  ; If ((A_TickCount-cDown)<300)  ; Modify press time as needed (milliseconds)
  ;   ; Send escape key only
  ;   Send {Blind}{Ctrl Up}{Shift Up}{Alt Up}{LWin Up}{Esc}
  ; Else
  ;   ; Release all the modifiers
  ;   Send {Blind}{Ctrl Up}{Shift Up}{Alt Up}{LWin Up}
  Return

^+!#n::
  Run, notepad.exe

;-----------------------------------------------------------------------------
; Window movement
;-----------------------------------------------------------------------------

; Dynamic computation of horizontal delta for different monitor sizes.
ComputeDeltaX() {
  delta := A_ScreenWidth // 64
  if (delta < 20) 
    delta := 20
  if (delta > 60) 
    delta := 60
  return delta
}

; Dynamic computation of vertical delta for different monitor sizes.
ComputeDeltaY() {
  delta := A_ScreenHeight // 64
  if (delta < 20) 
    delta := 20
  if (delta > 60) 
    delta := 60
  return delta
}

; Move window to the left
MoveWindowLeft() {
  SetWinDelay, 10
  SysGet, workarea, MonitorWorkArea
  SysGet, virtualScreenWidth, 78
  SysGet, virtualScreenStartX, 76
  SysGet, virtualScreenStartY, 77

  ; Compute delta based on screen size
  delta := ComputeDeltaX()

  win:=WinExist("a")
  xStart%win%:=x, yStart%win%:=y
  WinGetPos, x, y, w, h

  if (x <= virtualScreenStartX)
    Return
  x := x - delta
  if (x < virtualScreenStartX)
    x := virtualScreenStartX

  WinMove,,, x, y
  Sleep, 150

  while GetKeyState("h", "P") or GetKeyState("Left", "P") {
    if (x <= virtualScreenStartX)
      Return
    x := x - delta
    if (x < virtualScreenStartX)
      x := virtualScreenStartX
    WinMove,,, x, y
  }
  Return
}

; Move window to the bottom
MoveWindowDown() {
  SetWinDelay, 10
  SysGet, workarea, MonitorWorkArea
  SysGet, virtualScreenWidth, 78
  SysGet, virtualScreenStartX, 76
  SysGet, virtualScreenStartY, 77
  virtualScreenHeight := workareaBottom

  ; Compute delta based on screen size
  delta := ComputeDeltaY()

  win:=WinExist("a")
  xStart%win%:=x, yStart%win%:=y
  WinGetPos, x, y, w, h

  if (y+h >= virtualScreenHeight)
    Return
  y := y + delta
  if (y+h > virtualScreenHeight)
    y := virtualScreenHeight-h

  WinMove,,, x, y
  Sleep, 150

  while GetKeyState("j", "P") or GetKeyState("Down", "P") {
    if (y+h >= virtualScreenHeight)
      Return
    y := y + delta
    if (y+h > virtualScreenHeight)
      y := virtualScreenHeight-h
    WinMove,,, x, y
  }
  Return
}

; Move window to the top
MoveWindowUp() {
  SetWinDelay, 10
  SysGet, workarea, MonitorWorkArea
  SysGet, virtualScreenWidth, 78
  SysGet, virtualScreenStartX, 76
  SysGet, virtualScreenStartY, 77

  ; Compute delta based on screen size
  delta := ComputeDeltaY()

  win:=WinExist("a")
  xStart%win%:=x, yStart%win%:=y
  WinGetPos, x, y, w, h

  if (y <= 0)
    Return
  y := y - delta
  if (y < 0)
    y := 0

  WinMove,,, x, y
  Sleep, 150

  while GetKeyState("k", "P") or GetKeyState("Up", "P") {
    if (y <= 0)
      Return
    y := y - delta
    if (y < 0)
      y := 0
    WinMove,,, x, y
  }
  Return
}

; Move window to the right
MoveWindowRight() {
  SetWinDelay, 10
  SysGet, workarea, MonitorWorkArea
  SysGet, virtualScreenWidth, 78
  SysGet, virtualScreenStartX, 76
  SysGet, virtualScreenStartY, 77

  ; Compute delta based on screen size
  delta := ComputeDeltaX()

  win:=WinExist("a")
  xStart%win%:=x, yStart%win%:=y
  WinGetPos, x, y, w, h

  if (x+w >= virtualScreenStartX + virtualScreenWidth)
    Return
  x := x + delta
  if (x+w > virtualScreenStartX + virtualScreenWidth)
    x := virtualScreenStartX + virtualScreenWidth-w

  WinMove,,, x, y
  Sleep, 150

  while GetKeyState("l", "P") or GetKeyState("Right", "P") {
    if (x+w >= virtualScreenStartX + virtualScreenWidth)
      Return
    x := x + delta
    if (x+w > virtualScreenStartX + virtualScreenWidth)
      x := virtualScreenStartX + virtualScreenWidth-w
    WinMove,,, x, y
  }
  Return
}

; ;; Move window left
; ^+#Left::
; ^+#h::
;   MoveWindowLeft()
;   Return
; 
; ;; Move window down
; ^+#Down::
; ^+#j::
;   MoveWindowDown()
;   Return
; 
; ;; Move window up
; ^+#Up::
; ^+#k::
;   MoveWindowUp()
;   Return
; 
; ;; Move window right
; ^+#Right::
; ^+#l::
;   MoveWindowRight()
;   Return
; 
; ;; Switch window to monitor right
; #+h::
;   SendInput #+{Left}
;   Return
; 
; ;; Switch window to monitor left
; #+l::
;   SendInput #+{Right}
;   Return
; 
; ;; Maximize window
; #k::
;   SendInput #{Up}
;   Return
; 
; ;; Minimize window
; #j::
;   SendInput #{Down}
;   Return
; 
; ;; Minimize all windows
; #m::
;   WinGet, hWnd, List
; 
;   Loop, %hWnd% {
;     currentHWnd := hWnd%A_Index%
;     WinGet, isMinimized, MinMax, currentHWnd
;     if (!isMinimized) {
;       WinMinimize, ahk_id %currentHWnd%
;     }
;   }
;   Return


;-----------------------------------------------------------------------------
; Helper functions
;-----------------------------------------------------------------------------

GetText(ByRef MyText = "") {
  SavedClip := ClipboardAll
  Clipboard =
  Send, ^c
  ClipWait 0.1
  If ERRORLEVEL {
    Clipboard := SavedClip
    MyText =
    ERRORLEVEL := 1
    Return
  }
  MyText := Clipboard
  Clipboard := SavedClip
  Return MyText
}


;-----------------------------------------------------------------------------
; Autohotkey
;-----------------------------------------------------------------------------

;; Reload current script
#F1::
  Reload
  Return

#!F1::
  Run %EDITOR_EMACS% f:\dropbox\_\journal.org f:\dropbox\_\todo.org
  Return


;-----------------------------------------------------------------------------
; Terminal
;-----------------------------------------------------------------------------

;; PuTTY (Ctrl-F7)
#F7::
  Run %PUTTY%
  Return


;-----------------------------------------------------------------------------
; REPL
;-----------------------------------------------------------------------------

;; Clojure (Ctrl-Shift-F7)
#^F7::
  if (InStr(COMMANDPROMPT, "ConEmu")) {
    ; Use ConEmu
    Run, %COMMANDPROMPT% "C:\clojure\clojure.bat"
  } else {
    ; Use cmd.exe
    Run %COMMANDPROMPT% /c "C:\clojure\clojure.bat"
  }
  Return

;; Clojure (Ctrl-Shift-Alt-F7)
#^!F7::
  if (InStr(COMMANDPROMPT, "ConEmu")) {
    ; Use ConEmu
    Run, %COMMANDPROMPT% "lein repl"
  } else {
    ; Use cmd.exe
    Run %COMMANDPROMPT% /c "lein repl"
  }
  Return


;-----------------------------------------------------------------------------
; Editors
;-----------------------------------------------------------------------------

; Open in editor

$F4::
  if winactive("ahk_class ExploreWClass") or WinActive("ahk_class CabinetWClass") or WinActive("ahk_class dopus.lister") or WinActive("ahk_class WorkerW") or WinActive("ahk_class Progman") or WinActive("ahk_class EVERYTHING") {
    GetText(tmpvar)
    if (tmpvar != "") {
      ; Files have been selected
      ; Open editor with the selected files

      ; Get the file names
      StringSplit, files, tmpvar, `n,`r
      allFilenames =
      Loop, %files0% {
        filename := files%a_index%
        allFilenames .= """" . filename . """"
        allFilenames .= " "
      }
      
      ; Run the editor
      Run, %EDITOR% %allFilenames%
    }

    else {
      ; We are in a directory (no files selected)
      ; Open editor in file choosing mode
      
      ; Get the current working directory
      wingetclass explorerclass, a
      ControlGetText current_path, Edit1, ahk_class %explorerclass%
      quoted_path := """" . current_path . """"

      ; Run the editor
      Run, %EDITOR% %quoted_path%
    } 
  } else {
    SendInput {F4}
  }
  Return

; Open in IDA
#+F4::
  if winactive("ahk_class ExploreWClass") or WinActive("ahk_class CabinetWClass") or WinActive("ahk_class dopus.lister") or WinActive("ahk_class Progman") or WinActive("ahk_class EVERYTHING") {
    GetText(tmpvar)
    if (tmpvar != "")
       Run, %IDA_x86% "%tmpvar%"
    Return
  }
  Return

;; Text Editors (Ctrl-F9: Sublime Text, Alt-F9: Vim)
#F9::
  Run %EDITOR_EMACS% 
  Return


;-----------------------------------------------------------------------------
; Search
;-----------------------------------------------------------------------------

;; Everything (Ctrl-F6)
#F6::
  Run %EVERYTHING%
  Return

;; Search Google (Ctrl-F8)
#F8::
  SavedClip := ClipboardAll
  Clipboard =
  Send, ^{Ins}
  ClipWait 0.1
  Sleep 50
  Run, http://www.google.com/search?q=%clipboard%
  Clipboard := SavedClip
  Return

;; Open from Everything in Explorer (F8)
$F8::
  if WinActive("ahk_class EVERYTHING") {
    SavedClip := ClipboardAll
    Clipboard =
    Send {AppsKey}
    KeyWait RButton
    Send "f"
    dir = %Clipboard%
    Run, %EXPLORER% "%dir%"
    Clipboard := SavedClip
  } else {
    SendInput {F8}
  }
  Return

;-----------------------------------------------------------------------------
; Explorer
;-----------------------------------------------------------------------------
#-::
  ; Dopus
  if WinExist("ahk_class dopus.lister") {
    WinActivate
  }

  ; Everything else
  else if WinExist("ahk_class ExploreWClass") or WinExist("ahk_class CabinetWClass") {
    WinActivate
  }
  Return


;-----------------------------------------------------------------------------
; Command prompt
;-----------------------------------------------------------------------------

;; Command Prompt (Ctrl-F10)
#F10::
  Run %COMMANDPROMPT%
  Return


;; Command Prompt in Directory (Ctrl-Alt-Shift-/)
!+^/::
  WinGetClass explorerclass, a

  if (explorerclass != "") {
    ; Dopus
    if winactive("ahk_class dopus.lister") {
      ControlGetText current_path, Edit1, ahk_class %explorerclass%
    }

    ; Everything else
    else if winactive("ahk_class ExploreWClass") or winactive("ahk_class CabinetWClass") or winactive("ahk_class progman") or winactive("ahk_class everything") {
      WinGetText, current_path, A
  
      ; Split on newline and extract the address location (path)
      StringSplit, word_array, current_path, `n
      Loop, %word_array0% {
        IfInString, word_array%A_Index%, Address 
        {
          current_path := word_array%A_Index%
          break
        }
      }  
     
      ; Strip off 'Address' to get bare path
      current_path := RegExReplace(current_path, "^Address: ", "")
  
      ; Remove all carriage returns (`r)
      StringReplace, current_path, current_path, `r, , all

      ; Check for special paths
      if (RegExMatch(current_path, "^Libraries")) {
        current_path := RegExReplace(current_path, "^Libraries", "%appdata%\Microsoft\Windows\Libraries")
      }
    }

    if (InStr(COMMANDPROMPT, "Far")) {
      ; Use ConEmu with Far Manager
      Run, %COMMANDPROMPT% "far.exe %current_path%"
    } else {
      if (InStr(COMMANDPROMPT, "ConEmu")) {
        ; Use ConEmu
        Run, %COMMANDPROMPT% /dir "%current_path%"
      } else {
        ; Use cmd.exe
        Run, %COMMANDPROMPT% /k "cd /d %current_path%"
      }
    }
    Return
  }
  Return


;-----------------------------------------------------------------------------
; Browsers
;-----------------------------------------------------------------------------

;; Chrome (Ctrl-F11)
#F11::
  Run, %BROWSER_CHROME%
  ; Run, http://
  Sleep, 200
  WinWait, ahk_class Chrome_WidgetWin_1
  WinActivate, ahk_class Chrome_WidgetWin_1
  IfWinNotActive, ahk_class Chrome_WidgetWin_1,, WinActivate, ahk_class Chrome_WidgetWin_1,
  WinWaitActive, ahk_class Chrome_WidgetWin_1
  Return

;; Chrome Canary (Ctrl-Shift-F11)
#+F11::
  Run, %BROWSER_CANARY% --purge-memory-button,,pid
  Sleep, 200
  WinWait, ahk_class Chrome_WidgetWin_1
  WinActivate, ahk_class Chrome_WidgetWin_1
  IfWinNotActive, ahk_class Chrome_WidgetWin_1,, WinActivate, ahk_class Chrome_WidgetWin_1,
  WinWaitActive, ahk_class Chrome_WidgetWin_1
  Return


;-----------------------------------------------------------------------------
; Programming
;-----------------------------------------------------------------------------

;; Visual Studio Command Prompt (Alt-F10: x64, Shift-Alt-F10: x86)
!F10::
  Run %comspec% /k ""C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\vcvarsall.bat"" amd64
  Return

+!F10::
  Run %comspec% /k ""C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\vcvarsall.bat"" x86
  Return


;-----------------------------------------------------------------------------
; Reversing
;-----------------------------------------------------------------------------

;; IDA (Win-F12)
#+F12::
  Run %IDA_X86%
  Return

;; Debugger (Win-Shift-F12)
#F12::
  Run %DEBUGGER_X86%
  Return

F1::
 ; Send {Ctrl down}D{Ctrl up}Con{Down}{Enter}
  SetKeyDelay, 10
  SendInput {Ctrl down}d{Ctrl up}
  Sleep 400
  Send con{Down}{Tab}{Tab}12{Enter}
  Return



