Func Duell()

	ConsoleWrite($p & "Duell " & @ScriptLineNumber & @CRLF)

;~  	ConsoleWrite(@CRLF & _NowTime() & " Duell Start" & @CRLF)
	ConsoleWrite(@CRLF & StringFormat("%02i:%02i;%02i", @HOUR, @MIN, @SEC) & " Duell Start" & @CRLF)

	Local $Duell_B = [[00, 000, 000], _ ;leer
			[01, 729, 376], _ ;Duell Button
			[02, 430, 438], _ ;SIEG OK Button
			[03, 312, 438], _ ;NIEDERLAGE AUFGEBEN Button
			[04, 038, 434], _ ;Unten rechts Retour Button
			[05, 000, 000], _ ;leer
			[06, 000, 000], _ ;leer
			[07, 000, 000]] _ ;leer

	Local $Duell_BC = [[00, 0x3F0000], _ ;$Duell_Button1
			[01, 0xE90000], _ ;$Duell_Button2
			[02, 0xD22325], _ ;Rot
			[03, 0x000000]] _ ;leer

	Local $Duell_c = InitArrayWithZeros($pmax + 1, $pmax + 1)

	For $p = 1 To $pmax
		$Duell_c[0][$p] = $skip[$p]
		If $skip[$p] = 1 Then $skip_Duell[$p] = 1
		If $skip_Duell[$p] = 1 Then $skip[$p] = 1
;~ 		ConsoleWrite($p & " " & $skip_Duell[$p] & @CRLF)
	Next

;~ Exit

	$zaehler = 0

	Do
		$zaehler = $zaehler + 1

		For $p = 1 To $pmax
			If $skip[$p] = 1 Then ContinueLoop
			For $c = 1 To 4
				$Duell_c[$p][$c] = PixelGetColor($W_P[$p][1] + $Duell_B[$c][1], $W_P[$p][2] + $Duell_B[$c][2])
			Next
		Next

		If $zaehler < $Anz_Duell - 10 Then
			For $p = 1 To $pmax
				If $skip[$p] = 1 Then ContinueLoop
				If Hex($Duell_c[$p][1], 6) > Hex($Duell_BC[0][1], 6) And Hex($Duell_c[$p][1], 6) < Hex($Duell_BC[1][1], 6) _
						Then MouseClick("", $W_P[$p][1] + $Duell_B[1][1], $W_P[$p][2] + $Duell_B[1][2], 1, 0)
			Next
		EndIf

		For $p = 1 To $pmax
			If $skip[$p] = 1 Then ContinueLoop
			If Hex($Duell_c[$p][4], 6) = Hex($Duell_BC[2][1], 6) Then MouseClick("", $W_P[$p][1] + $Duell_B[1][1], $W_P[$p][2] + $Duell_B[1][2], 1, 0)
		Next

		For $p = 1 To $pmax
			If $skip[$p] = 1 Then ContinueLoop
			For $c = 2 To 3
				If Hex($Duell_c[$p][$c], 6) = Hex($Duell_BC[2][1], 6) Then MouseClick("", $W_P[$p][1] + $Duell_B[$c][1], $W_P[$p][2] + $Duell_B[$c][2], 1, 0)
			Next
		Next

;~ 		ConsoleWrite(@HOUR & "-" & @MIN & "-" & @SEC & " Zähler " & $zaehler & @CRLF)
		ConsoleWrite(" " & $zaehler)
		If Mod($zaehler, 20) = 0 Then ConsoleWrite(@CRLF)

		Sleep(1000)

	Until $zaehler = $Anz_Duell

	For $p = 1 To $pmax
		$skip[$p] = $Duell_c[0][$p]
	Next

;~ 	ConsoleWrite(_NowTime() & " Duell end" & @CRLF)
	ConsoleWrite(StringFormat("%02i:%02i;%02i", @HOUR, @MIN, @SEC) & " Duell End" & @CRLF)

EndFunc   ;==>Duell
