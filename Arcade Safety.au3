;~ *****************************************************************************
;~ ******************* READ EVERYTHING WITHIN ASTERISKS ************************
;~ *****************************************************************************
;~ ******** Alter the games in the Arcade Soak Saftey Settings.ini file. *******
;~ *** You can create the .ini file, in the same name above, if it is lost. ****
;~ *** Place on Desktop "C:\Users\Peter\Desktop\Arcade Safety Settings.ini" ****3
;~ ************* Example of settings in the .ini file is below. ****************
;~ *****************************************************************************
;~ ******** [FrontEndProgram]              *************************************
;~ ******** FEPexe="MaLa.exe"              *************************************
;~ ******** FEPwindow="MaLa"               *************************************
;~ ******** [ExecutionDelayInMilliseconds] *************************************
;~ ******** ED="30000"                     *************************************
;~ ******** [GameQuantity]                 *************************************
;~ ******** GQ="2"                         *************************************
;~ ******** [GameListStartsAtZero]         *************************************
;~ ******** G0="AGHR_SVAD.exe"             *************************************
;~ ******** G1="BattleBuddies.exe"         *************************************
;~ *****************************************************************************
;~ ********* !!!!! DO NOT CHANGE ANY CODE BELOW THIS POINT!!!!! ****************
;~ *****************************************************************************

#include <Timers.au3>
#include <Array.au3>
#include <Misc.au3>

;~ Variables
Global $readFEPexe = IniRead("Arcade Safety Settings.ini", "FrontEndProgram", "FEPexe", "Error")
Global $readFEPwindow = IniRead("Arcade Safety Settings.ini", "FrontEndProgram", "FEPwindow", "Error")
Global $readECGK = IniRead("Arcade Safety Settings.ini", "ExitCurrentGameKey", "ECGK", "Error")
Global $readQuantity = IniRead("Arcade Safety Settings.ini", "GameQuantity", "GQ", "Error")
Global $readWCQ = IniRead("Arcade Safety Settings.ini", "WindowCLASSQuantity", "WCQ", "Error")
Global $readDelay = IniRead("Arcade Safety Settings.ini", "ExecutionDelayInMilliseconds", "ED", "Error")

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

;~ Adds game .exe from .ini file to the array.
For $i = 0 To $readQuantity - 1

   Global $readGame = IniRead("Arcade Safety Settings.ini", "GameListStartsAtZero", "G" & $i, "Error")
   _ArrayAdd($gameList, $readGame)

Next

For $i = 0 To $readWCQ - 1

   Global $readWC = IniRead("Arcade Safety Settings.ini", "WindowCLASSstartsAtZero", "WC" & $i, "Error")
   _ArrayAdd($windowClasses, $readWC)

Next

;~ Debugging
_ArrayDisplay($gameList)
_ArrayDisplay($windowClasses)

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

;~ 		 Sets running game as active window.
		 For $j = 0 To UBound ($windowClasses) - 1
			WinActivate($windowClasses[$j], "")

;~ 			Condition: If current game closes abruptly set MaLa as active window.
			If WinExists($windowClasses[$j], "") == 0 Then
			   WinActivate($readFEPwindow)
			   ProcessClose($gamePID)
			   $gameRunningFlag = 0

			EndIf
		 Next

;~ 		 Condition: If inactivity time has been reached then game closes and sets MaLa as active window.
		 If(_Timer_GetIdleTime()>$readDelay) Then
			WinActivate($readFEPwindow)
			ProcessClose($gamePID)
			$gameRunningFlag = 0

		 EndIf
		 ExitLoop

;~ 	  Condition: If no game is running, set MaLa as active window.
	  ElseIf $gameRunningFlag = 0 Then
		 WinActivate($readFEPwindow)
;~ 		 ProcessClose($gamePID)
		 $printFlag = 0

	  EndIf
   Next

;~ Debugging
   If $printFlag = 1 Then
	  ConsoleWrite($gameList[$i] & " = " & $gamePID & @CRLF)
   ElseIf $printFlag = 0 Then
	  ConsoleWrite("No game started." & @CRLF)
   EndIf
   ConsoleWrite(@CRLF)

WEnd

;~ Checks is exit game key has been pressed.
Func exitGameKey()
   While 1
;~    If exit game key has been pressed the game closes and sets MaLa as active window.
	  If _IsPressed($readECGK, $hDLL) Then
		 While _IsPressed($readECGK, $hDLL)
			WinActivate($readFEPwindow)
			ProcessClose($gamePID)

		 WEnd
	  $gameRunningFlag = 0
	  EndIf
	  ExitLoop
   WEnd
EndFunc

DllClose($hDLL)