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
Global $gamePID
Global $windowClass
Global $gameList[0]
Global $windowClasses[0]
Local $hDLL = DllOpen("user32.dll")

;~ Debugging
ConsoleWrite($readFEPexe  & @CRLF)
ConsoleWrite($readFEPrunning  & @CRLF)
ConsoleWrite($readFEPwindow & @CRLF)
ConsoleWrite($readQuantity & @CRLF)

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

;~ Starts running MaLa.
Run($readFEPexe)
;~ Sleep(10000)
;~ WinActivate($readFEPwindow)

;~ Checks for certian conditions while MaLa is running; "Conditions" in the comments below.
While ProcessExists($readFEPrunning)

;~    Finds a running game from the game list.
   For $i = 0 To UBound ($gameList) - 1
	  If ProcessExists($gameList[$i]) <> 0 Then
		 $gamePID = ProcessExists($gameList[$i])

;~ 		 If running game is found, sets current game as focus window.
		 For $j = 0 To UBound ($windowClasses) - 1
			If WinActive($windowClasses[$j]) <> 0 Then
			   $windowClass = WinActive($windowClasses[$j])
			   WinActivate($windowClass, "")
			   ExitLoop
			EndIf
		 Next
		 ExitLoop
	  EndIf
   Next

;~    Condition: If exit key is pressed while game is running, close game and focus MaLa
   If _IsPressed($readECGK, $hDLL) And $gamePID <> 0 Then
	  ProcessClose($gamePID)
	  WinActivate($readFEPwindow)
	  $windowClass = 0
	  $gamePID = 0
;~ 	  ConsoleWrite("Exit key pressed" & @CRLF)
   EndIf


;~ 	  Condition: If inactivity time has been reached while game is running, close game and focus MaLa
   If(_Timer_GetIdleTime()>$readDelay) And $gamePID <> 0 Then
	  ProcessClose($gamePID)
	  WinActivate($readFEPwindow)
	  $windowClass = 0
	  $gamePID = 0
;~ 	  ConsoleWrite("Inactivity time reached" & @CRLF)
   EndIf

;~ Debugging
;~    $hWnd = WinGetHandle("SlowDown")
;~    ConsoleWrite(_WinAPI_GetClassName($hWnd) & @CRLF)
;~    ConsoleWrite($gamePID & @CRLF)
;~    ConsoleWrite($windowClass & @CRLF)
WEnd
DllClose($hDLL)