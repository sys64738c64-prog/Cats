Func Teilelauf()

	ConsoleWrite(_NowTime() & " Teilelauf Start ")

	Local $TL_Pos = [[00, 215, 415], _ ;TL_Start
			[01, 800, 444], _ ;Start_B_R
			[02, 430, 400], _ ;Nehmen_B_R & Meisterschaftsverlauf dieser Spieler ist direkt Aufgestiegen
			[03, 800, 460], _ ;Kämpfen
			[04, 430, 200], _ ;Ansehen
			[05, 455, 430], _ ;Ergebnisse --> OK & Verteidigungen...
			[06, 033, 444], _ ;Back UL_B_R
			[07, 430, 400], _ ;Belohnung Nehmen ??? 3x
			[08, 400, 430], _ ;Ergebnis *[OK] B_R
			[09, 430, 280], _ ;Einsammeln
			[10, 455, 430]] ;

	Local $TL_BC = [[00, 0xD22325], _ ;Rot
			[01, 0xE90000], _ ;leer
			[02, 0xD22325], _ ;leer
			[03, 0x000000]] _ ;leer

	Local $TL_Ablauf = [-1, 0, 1, 2, 2, 3, 4, 5, 5, 6, 7, 7, 9, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 9, 7, 6, 6, -1]

	For $a = 1 To 50

		ConsoleWrite($TL_Ablauf[$a])
		$wert = $TL_Ablauf[$a]
		If $wert = -1 Then ExitLoop

		For $p = 1 To $pmax
			If $skip[$p] = 1 Then ContinueLoop
			MouseClick("", $W_P[$p][1] + $TL_Pos[$wert][1], $W_P[$p][2] + $TL_Pos[$wert][2], 1, 0)
		Next
		Sleep(3000)
		If $wert = 4 Then
			$wert = 08
			Do
				$ready[0] += 1
				For $p = 1 To $pmax
					If $skip[$p] = 1 Then $ready[$p] = 1
					If $skip[$p] = 1 Or $ready[$p] = 1 Then ContinueLoop
					$Color[$p] = PixelGetColor($W_P[$p][1] + $TL_Pos[$wert][1], $W_P[$p][2] + $TL_Pos[$wert][2])
					If $Color[$p] = $TL_BC[0][1] Then $ready[$p] = 1
					If $Color[$p] = $TL_BC[0][1] Then ConsoleWrite("P" & $p)
					If $ready[0] > 40 And $ready[$p] = 0 Then ConsoleWrite("P" & $p & " Error ") ; & @ScriptLineNumber)
					If $ready[0] > 40 And $ready[$p] = 0 Then $ready[$p] = 1
				Next
				Sleep(5000)
				ConsoleWrite(".")

				$sum = 0
				For $i = 1 To UBound($ready) - 1
					$sum += $ready[$i]
				Next

			Until $sum = 8

			ConsoleWrite("->" & $ready[0] & "<-")
		EndIf
	Next
	Global $ready = InitArrayWithZeros($pmax + 1)



	$sum = 0
;~ 	ConsoleWrite(@CRLF)
	ConsoleWrite(" " & _NowTime() & " Teilelauf End" & @CRLF)
	Sleep(5000)

EndFunc   ;==>Teilelauf
