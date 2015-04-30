#include <Constants.au3>
#include <InetConstants.au3>
#include <GUIConstantsEx.au3>

Global $sWindowName, $g_idChrome, $g_idFirefox, $cShortcutChar


_CheckIfLivestreamerInstalled()

_SelectBrowser()
_SelectHotkey()
_Main()

Func _Main()
   AutoItSetOption("WinTitleMatchMode", 2) ; Set WinActivate Partial Name matching, instead of from Start (default)

   HotKeySet("^" & $cShortcutChar, "_OnHotkey")

   TrayTip("Waiting", "I'm waiting for your CTRL+" & $cShortcutChar, 10)

   While 1
	  Sleep(500)
   WEnd

EndFunc

Func _OnHotkey()
   TrayTip("Activated!", "Hotkey triggered!", 1)

   WinActivate($sWindowName) ; Opens minimized window
   WinWaitActive($sWindowName) ; Waits for it to open

   sleep(500) ; Sleep .5s

   Send("^l") ; Select URL
   Send("^c") ; Copy

   Run("livestreamer " & ClipGet() & " best") ; ClipGet() -> Get clipboard (Paste)
EndFunc

Func _SelectBrowser()
   GUICreate("Browser Choice", 250, 50)

   GUICtrlCreateLabel("Please select your Browser", 60, 10)

   $g_idChrome = GUICtrlCreateButton("Chrome", 60, 25)
   $g_idFirefox = GUICtrlCreateButton("Firefox", 150, 25)

;   GUICtrlSetOnEvent($g_idChrome, "_onChrome")
;   GUICtrlSetOnEvent($g_idFirefox, "_onFirefox")

   GUISetState()

   While 1
	  Local $idMsg = GUIGetMsg()

	  Switch($idMsg)
		 Case $GUI_EVENT_CLOSE
			Exit
		 Case $g_idChrome
			$sWindowName = "Chrome"
			ExitLoop
		 Case $g_idFirefox
			$sWindowName = "Firefox"
			ExitLoop
	  EndSwitch
   WEnd

   GUIDelete()
EndFunc

Func _SelectHotkey()
   $cShortcutChar = InputBox("Custom Shortcut", "Please type the letter you want to use" & @CRLF & "as a shortcut with CTRL")
   While StringLen($cShortcutChar) > 1
	  MsgBox($MB_SYSTEMMODAL, "Error!", "Please type only 1 character")
	  _SelectHotkey()
   WEnd
EndFunc

Func _CheckIfLivestreamerInstalled()
   Local $bFolderExists = FileExists( EnvGet("appdata") & "\livestreamer")
   if Not $bFolderExists Then	; Folder doesn't exist!
	  Local $idOption = MsgBox($MB_OKCANCEL, "Error!", "LiveStreamer wasn't detected!" & @CRLF & @CRLF & "Would you like to Download it now?")
	  if $idOption = $IDOK Then
		 Local $hDownload = InetGet( "https://github.com/chrippa/livestreamer/releases/download/v1.12.1/livestreamer-v1.12.1-win32-setup.exe", EnvGet("userprofile")&"\Desktop\livestreamer_Setup.exe", $INET_FORCERELOAD, $INET_DOWNLOADBACKGROUND)
		 if @error Then
			MsgBox($MB_SYSTEMMODAL, "Error!", "WTF?")
		 EndIf

		 Do
			TrayTip( "Downloading!", "KBytes: " & InetGetInfo($hDownload, $INET_DOWNLOADREAD)/1024 & "/" & InetGetInfo($hDownload, $INET_DOWNLOADSIZE)/1024, 5)
			Sleep(250)
		 Until InetGetInfo($hDownload, $INET_DOWNLOADCOMPLETE)

		 Local $sExeLocation = EnvGet("userprofile") & "\Desktop\livestreamer_Setup.exe"
		 ShellExecute($sExeLocation)
		 TrayTip("Waiting...", "The script will wait until Livestreamer Setup is finished.", 5)
		 WinActivate("Livestreamer")
		 WinWaitActive("Livestreamer")
		 WinWaitClose("Livestreamer")
		 _CheckIfLivestreamerInstalled()
	  Else
		 Exit
	  EndIf
   EndIf
EndFunc