Func TogglePause()
	$Paused = Not $Paused
	While $Paused
		Sleep(200)
		ToolTip('Script is "Paused"', -400, 1050)
	WEnd
	ToolTip("")
EndFunc   ;==>TogglePause


Func _End()
	ConsoleWrite(" END ")
	Global $terminate = 1
EndFunc   ;==>_End


Func _Exit()
	Exit 0
EndFunc   ;==>_Exit


Func _Example()
	Local $sStartTime = _NowCalc()
	Sleep(Random(1000, 3000, 1))
	Local $sEndTime = _NowCalc()
	Local $iDiff = _DateDiff('s', $sStartTime, $sEndTime)
	Local $iDiff = _DateDiff('m', $sStartTime, $sEndTime)
	ConsoleWrite("StartTime --> " & $sStartTime & @CRLF)
	ConsoleWrite("EndTime   --> " & $sEndTime & @CRLF)
	ConsoleWrite("DiffSecs  --> " & $iDiff & " Sekunde" & ($iDiff > 1 ? "n" : '') & @CRLF)
	ConsoleWrite("DiffSecs  --> " & $iDiff & " Minuten" & ($iDiff > 1 ? "n" : '') & @CRLF)
EndFunc   ;==>_Example


Func Combo()

;~ 	Gangkaempfe()

	Kistenholen()

	Teileverkaufen()

	Kistenholen()


EndFunc   ;==>Combo


Func MainScreen()

	Local $AllgPos[4][2] = [[859, 010], [833, 133], [445, 435], [000, 000]] ;WLan Weiss; Cats.Ison; Neuverbindunf; leer;
	Local $iColor0[3] = [0, 0, 0]

;~ 	Absturtz Check
	For $c = 0 To 2
		$p = $c + 1 ; Player
		$iColor0[$c] = PixelGetColor($W_P[$p][1] + $AllgPos[0][0], $W_P[$p][2] + $AllgPos[0][1])
		If $iColor0[$c] = 0xFFFFFF Then
			Global $ns = 1
			ConsoleWrite("Ohhh Jeee Player " & $p & " muss neustarten" & @CRLF)
			MouseClick("", $W_P[$p][1] + $AllgPos[1][0], $W_P[1][2] + $AllgPos[1][1], 1, 5) ;Cats start
			Sleep(20 * 1000)
			MouseClick("", $W_P[$p][1] + $AllgPos[2][0], $W_P[1][2] + $AllgPos[2][1], 1, 5) ;Neuverbinndung
		EndIf
	Next
EndFunc   ;==>MainScreen


Func Now()
	Return StringFormat("%04i-%02i-%02i %02i:%02i;%02i", @YEAR, @MON, @MDAY, @HOUR, @MIN, @SEC)
EndFunc   ;==>Now


Func InitArrayWithZeros($rows, $cols = 0)
	If $cols = 0 Then
		; Eindimensionales Array
		Local $arr[$rows]
		For $i = 0 To $rows - 1
			$arr[$i] = 0
		Next
	Else
		; Zweidimensionales Array
		Local $arr[$rows][$cols]
		For $i = 0 To $rows - 1
			For $j = 0 To $cols - 1
				$arr[$i][$j] = 0
			Next
		Next
	EndIf
	Return $arr
EndFunc   ;==>InitArrayWithZeros
