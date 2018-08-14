;~ *****************************************************************************
;~ ******************* READ EVERYTHING WITHIN ASTERISKS ************************
;~ *****************************************************************************
;~ ******** Alter the games in the Arcade Soak Saftey Settings.ini file. *******
;~ *** You can create the .ini file, in the same name above, if it is lost. ****
;~ *** Place on Desktop "C:\Users\Peter\Desktop\Arcade Safety Settings.ini" ****
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
#include <WinAPI.au3>
#include <Misc.au3>

Global $readFEPexe = IniRead("Arcade Safety Settings.ini", "FrontEndProgram", "FEPexe", "Error")
Global $readFEPwindow = IniRead("Arcade Safety Settings.ini", "FrontEndProgram", "FEPwindow", "Error")
Global $readQuantity = IniRead("Arcade Safety Settings.ini", "GameQuantity", "GQ", "Error")
Global $readDelay = IniRead("Arcade Safety Settings.ini", "ExecutionDelayInMilliseconds", "ED", "Error")
Global $exitCG = IniRead("Arcade Safety Settings.ini", "ExitCurrentGame", "ECG", "Error")

Global $hDLL = DllOpen("user32.dll")
Global $gameList[0]

ConsoleWrite($readFEPexe  & @CRLF)
ConsoleWrite($readFEPwindow & @CRLF)
ConsoleWrite($readQuantity & @CRLF)

For $i = 0 To $readQuantity - 1

   Global $readGame = IniRead("Arcade Safety Settings.ini", "GameListStartsAtZero", "G" & $i, "Error")
   _ArrayAdd($gameList, $readGame)

Next

_ArrayDisplay($gameList)

Run($readFEPexe)

While ProcessExists($readFEPexe)

   For $i = 0 To UBound ($gameList) - 1
	  $gamePID = ProcessExists($gameList[$i])

	  If $gamePID <> 0 Then
		 WinActivate("[CLASS:UnityWndClass]", "")
		 ConsoleWrite($gameList[$i] & " = " & $gamePID & @CRLF)

		 If(_Timer_GetIdleTime()>$readDelay) Then
			WinActivate($readFEPwindow)
			ProcessClose($gamePID)
			ConsoleWrite("^ Process Closed ^" & @CRLF)

		 Else If _IsPressed("33", $hDLL) Then
			WinActivate($readFEPwindow)
			ProcessClose($gamePID)

		 EndIf

	  ElseIf $gamePID == 0 Then
		 WinActivate($readFEPwindow)
		 ConsoleWrite($gameList[$i] & " = Not Found! " & @CRLF)

	  EndIf

   Next
   ConsoleWrite(@CRLF)
Wend