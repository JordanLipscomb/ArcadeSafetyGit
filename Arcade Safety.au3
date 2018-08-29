;~ *****************************************************************************
;~ ******************* READ EVERYTHING WITHIN ASTERISKS ************************
;~ *****************************************************************************
;~ ******** Alter the games in the Arcade Soak Saftey Settings.ini file. *******
;~ *** You can create the .ini file, in the same name above, if it is lost. ****
;~ *** Place at "C:\Emulators\Games\ArcadeSafety\Arcade Safety Settings.ini" ***
;~ ************* Example of settings in the .ini file is below. ****************
;~ *****************************************************************************
;~ ******** [FrontEndProgram]                                        ***********
;~ ******** FEPexe="C:\Emulators\Programs\mala\MaLa174\MaLa174\MaLa" ***********
;~ ******** FEPrunning="MaLa.exe"	                                 ***********
;~ ******** FEPwindow="MaLa"                                         ***********
;~ ********                                                          ***********
;~ ******** [ExecutionDelayInMilliseconds]                           ***********
;~ ******** ED="30000"                                               ***********
;~ ********                                                          ***********
;~ ******** [ExitCurrentGameKey]                                     ***********
;~ ********	ECGK="33"                                                ***********
;~ ********                                                          ***********
;~ ********	[WindowCLASSQuantity]                                    ***********
;~ ******** WCQ="1"                                                  ***********
;~ ********                                                          ***********
;~ ******** [WindowCLASSstartsAtZero]                                ***********
;~ ******** WC0="[CLASS:UnityWndClass]"                              ***********
;~ ********                                                          ***********
;~ ******** [GameQuantity]                                           ***********
;~ ******** GQ="2"                                                   ***********
;~ ********                                                          ***********
;~ ******** [GameListStartsAtZero]                                   ***********
;~ ******** G0="BattleBuddies.exe"                                   ***********
;~ ******** G1="Balloon Burst.exe"                                   ***********
;~ *****************************************************************************
;~ ********* !!!!! DO NOT CHANGE ANY CODE BELOW THIS POINT!!!!! ****************
;~ *****************************************************************************

;~ Libraries
#include <Timers.au3>
#include <Array.au3>
#include <Misc.au3>
#Include <WinAPI.au3>

;~ Reads single data items from the .ini and sets as variables.
Global $readFEPexe = IniRead("C:\Emulators\ArcadeSafety\Arcade Safety Settings.ini", "FrontEndProgram", "FEPexe", "Error")
Global $readFEPrunning = IniRead("C:\Emulators\ArcadeSafety\Arcade Safety Settings.ini", "FrontEndProgram", "FEPrunning", "Error")
Global $readFEPwindow = IniRead("C:\Emulators\ArcadeSafety\Arcade Safety Settings.ini", "FrontEndProgram", "FEPwindow", "Error")
Global $readDelay = IniRead("C:\Emulators\ArcadeSafety\Arcade Safety Settings.ini", "ExecutionDelayInMilliseconds", "ED", "Error")
Global $readECGK = IniRead("C:\Emulators\ArcadeSafety\Arcade Safety Settings.ini", "ExitCurrentGameKey", "ECGK", "Error")
Global $readWCQ = IniRead("C:\Emulators\ArcadeSafety\Arcade Safety Settings.ini", "WindowCLASSQuantity", "WCQ", "Error")
Global $readQuantity = IniRead("C:\Emulators\ArcadeSafety\Arcade Safety Settings.ini", "GameQuantity", "GQ", "Error")

;~ Variables
Global $gameName
Global $gamePID
Global $windowClass
Global $stageFlag = 0
Global $gameList[0]
Global $windowClasses[0]
Global $hDLL

;~ Debugging
;~ ConsoleWrite($readFEPexe  & @CRLF)
;~ ConsoleWrite($readFEPrunning  & @CRLF)
;~ ConsoleWrite($readFEPwindow & @CRLF)
;~ ConsoleWrite($readQuantity & @CRLF)

;~ Adds game .exe data from .ini file to the $gameList array.
For $i = 0 To $readQuantity - 1
   Global $readGame = IniRead("C:\Emulators\ArcadeSafety\Arcade Safety Settings.ini", "GameListStartsAtZero", "G" & $i, "Error")
   _ArrayAdd($gameList, $readGame)
Next

;~ Adds window class data from .ini file to the $windowClasses array.
For $i = 0 To $readWCQ - 1
   Global $readWC = IniRead("C:\Emulators\ArcadeSafety\Arcade Safety Settings.ini", "WindowCLASSstartsAtZero", "WC" & $i, "Error")
   _ArrayAdd($windowClasses, $readWC)
Next

;~ Debugging
;~ _ArrayDisplay($gameList)
;~ _ArrayDisplay($windowClasses)

;~ Starts running MaLa and sets it as focus window after a delay.
Run($readFEPexe)
Sleep(30000)
WinActivate($readFEPwindow)

;~ Checks for certian conditions while MaLa is running.
While ProcessExists($readFEPrunning)

;~    Stage 0: Find a running game stage.
   If $stageFlag = 0 Then

;~ 	  Finds a running game from the game list.
	  For $i = 0 To UBound ($gameList) - 1
		 If ProcessExists($gameList[$i]) <> 0 Then
			$gamePID = ProcessExists($gameList[$i])
			$gameName = $gameList[$i]
			$stageFlag = 1
			ExitLoop
		 EndIf
	  Next
   EndIf

;~    Stage 1: Find game window and focus it.
   If $stageFlag = 1 Then

;~ 	  Find runnings game's window.
	  For $j = 0 To UBound ($windowClasses) - 1
		 If WinActive($windowClasses[$j]) <> 0 Then
			$windowClass = WinActive($windowClasses[$j])
			WinActivate($windowClass, "")
			$hDLL = DllOpen("user32.dll")
			$stageFlag = 2
			ExitLoop
		 EndIf
	  Next
   EndIf

;~    Stage 2: Game is running and checks for exit conditions.
   If $stageFlag = 2 Then

;~    Set running game as focus window.
	  WinActivate($windowClass, "")

;~ 	  If exit key is pressed while game is running, close game and focus MaLa.
	  If _IsPressed($readECGK, $hDLL) And $gamePID <> 0 Then
		 ProcessClose($gamePID)
		 WinActivate($readFEPwindow)
		 $windowClass = 0
		 $gamePID = 0
		 $gameName = 0
		 $stageFlag = 0
		 DllClose($hDLL)
;~ 		 ConsoleWrite("Exit key pressed" & @CRLF)

;~ 	  If game closes abruptly, close game and focus MaLa.
	  ElseIf ProcessExists($gameName) = 0 Then
		 ProcessClose($gamePID)
		 WinActivate($readFEPwindow)
		 $windowClass = 0
		 $gamePID = 0
		 $gameName = 0
		 $stageFlag = 0
		 DllClose($hDLL)
;~ 		 ConsoleWrite("Game closed abruptly." & @CRLF)
	  EndIf

;~ 	  If inactivity time has been reached while game is running, close game and focus MaLa.
	  If(_Timer_GetIdleTime()>$readDelay) And $gamePID <> 0 Then
		 ProcessClose($gamePID)
		 WinActivate($readFEPwindow)
		 $windowClass = 0
		 $gamePID = 0
		 $gameName = 0
		 $stageFlag = 0
		 DllClose($hDLL)
;~ 		 ConsoleWrite("Inactivity time reached" & @CRLF)
	  EndIf
   EndIf

;~ Debugging
;~    $hWnd = WinGetHandle("SA Build")
;~    ConsoleWrite(_WinAPI_GetClassName($hWnd) & @CRLF)
;~    ConsoleWrite($gameName & @CRLF)
;~    ConsoleWrite($gamePID & @CRLF)
;~    ConsoleWrite($windowClass & @CRLF)
WEnd