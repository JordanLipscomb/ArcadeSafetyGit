;~ *****************************************************************************
;~ ******************* READ EVERYTHING WITHIN ASTERISKS ************************
;~ *****************************************************************************
;~ ******** Alter the games in the Arcade Soak Saftey Settings.ini file. *******
;~ *** You can create the .ini file, in the same name above, if it is lost. ****
;~ *** Place at "C:\Emulators\Games\ArcadeSafety\Arcade Safety Settings.ini" ***
;~ ************* Example of settings in the .ini file is below. ****************
;~ *****************************************************************************
;~ ******** [FrontEndProgram]              *************************************
;~ ******** FEPexe="MaLa.exe"              *************************************
;~ ******** FEPwindow="MaLa"               *************************************
;~ ********                                *************************************
;~ ******** [ExecutionDelayInMilliseconds] *************************************
;~ ******** ED="30000"                     *************************************
;~ ********                                *************************************
;~ ******** [ExitCurrentGameKey]           *************************************
;~ ********	ECGK="33"                      *************************************
;~ ********                                *************************************
;~ ********	[WindowCLASSQuantity]          *************************************
;~ ******** WCQ="1"                        *************************************
;~ ********                                *************************************
;~ ******** [WindowCLASSstartsAtZero]      *************************************
;~ ******** WC0="[CLASS:UnityWndClass]"    *************************************
;~ ********                                *************************************
;~ ******** [GameQuantity]                 *************************************
;~ ******** GQ="2"                         *************************************
;~ ********                                *************************************
;~ ******** [GameListStartsAtZero]         *************************************
;~ ******** G0="BattleBuddies.exe"         *************************************
;~ ******** G1="Balloon Burst.exe"         *************************************
;~ *****************************************************************************
;~ ********* !!!!! DO NOT CHANGE ANY CODE BELOW THIS POINT!!!!! ****************
;~ *****************************************************************************

;~ Libraries
#include <Timers.au3>
#include <Array.au3>
#include <Misc.au3>
#Include <WinAPI.au3>

;~ Reads single data items from the .ini and sets as variables.
Global $readFEPexe = IniRead("C:\Emulators\Games\ArcadeSafety\Arcade Safety Settings.ini", "FrontEndProgram", "FEPexe", "Error")
Global $readFEPwindow = IniRead("C:\Emulators\Games\ArcadeSafety\Arcade Safety Settings.ini", "FrontEndProgram", "FEPwindow", "Error")
Global $readDelay = IniRead("C:\Emulators\Games\ArcadeSafety\Arcade Safety Settings.ini", "ExecutionDelayInMilliseconds", "ED", "Error")
Global $readECGK = IniRead("C:\Emulators\Games\ArcadeSafety\Arcade Safety Settings.ini", "ExitCurrentGameKey", "ECGK", "Error")
Global $readWCQ = IniRead("C:\Emulators\Games\ArcadeSafety\Arcade Safety Settings.ini", "WindowCLASSQuantity", "WCQ", "Error")
Global $readQuantity = IniRead("C:\Emulators\Games\ArcadeSafety\Arcade Safety Settings.ini", "GameQuantity", "GQ", "Error")

;~ Variables
Global $gamePID
Global $printFlag = 0
Global $gameRunningFlag = 0
Global $hDLL = DllOpen("user32.dll")
Global $gameList[0]
Global $windowClasses[0]

;~ Debugging
ConsoleWrite($readFEPexe  & @CRLF)
ConsoleWrite($readFEPwindow & @CRLF)
ConsoleWrite($readQuantity & @CRLF)
ConsoleWrite(@CRLF)

;~ Shortcut Key
HotKeySet($readECGK, "exitGameKey")

;~ Adds game .exe data from .ini file to the $gameList array.
For $i = 0 To $readQuantity - 1
   Global $readGame = IniRead("C:\Emulators\Games\ArcadeSafety\Arcade Safety Settings.ini", "GameListStartsAtZero", "G" & $i, "Error")
   _ArrayAdd($gameList, $readGame)
Next

;~ Adds window class data from .ini file to the $windowClasses array.
For $i = 0 To $readWCQ - 1
   Global $readWC = IniRead("C:\Emulators\Games\ArcadeSafety\Arcade Safety Settings.ini", "WindowCLASSstartsAtZero", "WC" & $i, "Error")
   _ArrayAdd($windowClasses, $readWC)
Next

;~ Debugging
;~ _ArrayDisplay($gameList)
;~ _ArrayDisplay($windowClasses)

;~ Starts running MaLa.
Run($readFEPexe)

;~ Checks for certian conditions while MaLa is running; "Conditions" in the comments below.
While ProcessExists($readFEPexe)

   For $i = 0 To UBound ($gameList) - 1

;~ 	  Finds a running game from the game list.
	  If ProcessExists($gameList[$i]) <> 0 Then
		 $gamePID = ProcessExists($gameList[$i])
		 $gameRunningFlag = 1
		 $printFlag = 1

		 For $j = 0 To UBound ($windowClasses) - 1

;~ 			Sets running game as focus window.
			WinActivate($windowClasses[$j], "")
			If WinActive($windowClasses[$j], "") <> 0 Then
			   ExitLoop
			EndIf
		 Next

;~ 	  Condition: If no game is running, set MaLa as focus window.
	  ElseIf $gameRunningFlag = 0 Then
		 WinActivate($readFEPwindow)
		 $printFlag = 0

;~ 	  Condition: If inactivity time has been reached, then the active game closes.
	  ElseIf(_Timer_GetIdleTime()>$readDelay) Then
		 ProcessClose($gamePID)
		 $gameRunningFlag = 0

;~ 	  Condition: If no game windows are open set MaLa as focus window.
	  Else
		 For $i = 0 To UBound ($windowClasses) - 1
			If WinActive($windowClasses[$i], "") = 0 Then
			   $gameRunningFlag = 0
			EndIf
		 Next
	  EndIf
   Next

;~ Debugging
;~    $hWnd = WinGetHandle("SlowDown")
;~    ConsoleWrite(_WinAPI_GetClassName($hWnd) & @CRLF)

;~    If $printFlag = 1 Then
;~ 	  ConsoleWrite("Game on!" & @CRLF)
;~    ElseIf $printFlag = 0 Then
;~ 	  ConsoleWrite("No game started." & @CRLF)
;~    EndIf
;~    ConsoleWrite(@CRLF)
WEnd

;~ Checks if exit game key has been pressed.
Func exitGameKey()
   While 1
;~    If exit game key has been pressed the active game closes.
	  If _IsPressed($readECGK, $hDLL) Then
		 While _IsPressed($readECGK, $hDLL)
			ProcessClose($gamePID)
		 WEnd
	  $gameRunningFlag = 0
	  EndIf
	  ExitLoop
   WEnd
EndFunc

DllClose($hDLL)