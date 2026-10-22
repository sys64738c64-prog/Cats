Func Gangkaempfe()

	GK_Screen()

	ConsoleWrite(_NowTime() & " Start GK" & @CRLF)
	$StartTime = _NowCalc()

	; Definitionen
	Local $GK_Button_Allg =[["3 Player OR", 			769, 029], _
							["GK", 						573, 026], _
							["Kämpfen", 				727, 444], _
							["Einsammeln", 				430, 344]]

	Local $GK_Color = 	   [["10'er Gold mm",			700, 270], _
							["erneut versuchen/Dias", 	660, 444], _ ;(664 auf 660) 10.5.26
							["links von Belohnung", 	386, 201], _
							["Belohnungen erhalten", 	500, 270]]

	Local $GK_C =		   [["Win",		 				0xF7E7C9], _
							["Lose", 					0xD9CCBE], _
							["Gold", 					0xFFBB00], _
							["Button rot",	 			0xD22325], _
							["Belohnungen erhalten", 	0x8D95A4]]


	$Gegner = 0
	$kampf = 0

	; Spieler oben rechts klicken;
	For $p = 1 To $pmax
		If $skip[$p] = 1 Then $lose[$p] = 1
		If $skip[$p] = 1 Then ContinueLoop
		MouseClick("left", $W_P[$p][1] + $GK_Button_Allg[0][1], $W_P[$p][2] + $GK_Button_Allg[0][2], 1, 0) ;Button Spieler oben rechts
	Next

	Sleep(3000)

	; GK klicken
	For $p = 1 To $pmax
		If $lose[$p] = 1 Then ContinueLoop
		MouseClick("left", $W_P[$p][1] + $GK_Button_Allg[1][1], $W_P[$p][2] + $GK_Button_Allg[1][2], 1, 0) ;Button Gangkämpfe
	Next

	Sleep(3000)

	; Runde 10 abgeschlossen?
	For $p = 1 To $pmax
		If $lose[$p] = 1 Then ContinueLoop
		$Color[$p] = PixelGetColor($W_P[$p][1] + $GK_Color[0][1], $W_P[$p][2] + $GK_Color[0][2]) ;GK_C_0
		If $Color[$p] = $GK_C[2][1] Then $lose[$p] = 1
		If $Color[$p] = $GK_C[2][1] Then ConsoleWrite("P" & $p & " 10-lose " & @CRLF)
	Next

; Alle Belohnungen erhalten?
;~ ConsoleWrite("Alle Belohnungen erhalten?" & @CRLF)
	For $p = 1 To $pmax
		If $lose[$p] = 1 Then ContinueLoop
		$Color[$p] = PixelGetColor($W_P[$p][1] + $GK_Color[3][1], $W_P[$p][2] + $GK_Color[3][2]) ;GK_C_3
;~ 		ConsoleWrite("P  ist:" & $p & " Farbe: " & Hex($Color[$p]) & @CRLF)
		If $Color[$p] = $GK_C[4][1] Then $lose[$p] = 1
		If $Color[$p] = $GK_C[4][1] Then ConsoleWrite("P" & $p & " Alle Belohnungen erhalten " & @CRLF)
	Next

	; Gegner (1 bis 10)
	Do
		$Gegner += 1
		ConsoleWrite(@HOUR & "-" & @MIN & "-" & @SEC & " Gegner " & $Gegner & " ")
		If $Gegner < 10 Then ConsoleWrite(" ")

		; Farbe aufnehmen
		For $p = 1 To $pmax
			If $lose[$p] = 1 Then $weiter[$p] = 1
			If $lose[$p] = 1 Then ContinueLoop
			$Color[$p] = PixelGetColor($W_P[$p][1] + $GK_Color[1][1], $W_P[$p][2] + $GK_Color[1][2]) ;erneut Versuchen?
		Next

		; Farbe analysieren, verloren?
;~ 		ConsoleWrite(@CRLF & "Farbe analysieren, verloren wenn --> " & Hex($GK_C[3][1], 6) & @CRLF)
		For $p = 1 To $pmax
;~ 			ConsoleWrite("P" & $p & " " & Hex($Color[$p], 6) & @CRLF)
			If Hex($Color[$p], 6) = Hex($GK_C[3][1], 6) Then
				$lose[$p] = 1
				$weiter[$p] = 1
				ConsoleWrite("P" & $p & " lose " & @CRLF)
				Exit
			EndIf
		Next

		; kämpfen klicken
		For $p = 1 To $pmax
			If $lose[$p] = 1 Then ContinueLoop
			MouseClick("left", $W_P[$p][1] + $GK_Button_Allg[2][1], $W_P[$p][2] + $GK_Button_Allg[2][2], 1, 0)
		Next

		Sleep(3000)

		Do ;(Kampf 1 bis 3)
			$kampf = $kampf + 1

			; Kampf starten
			For $p = 1 To $pmax
				If $lose[$p] = 1 Then ContinueLoop
				MouseClick("left", $W_P[$p][1] + 430, $W_P[$p][2] + 207, 1, 0) ;Ansehen
			Next

			Sleep(3000)

			; Kampf Auswertung
			For $p = 1 To $pmax
				If $lose[$p] = 1 Then ContinueLoop
				$Color[$p] = PixelGetColor($W_P[$p][1] + $GK_Color[2][1], $W_P[$p][2] + $GK_Color[2][2]) ;Ergebnisse? (Win/Lose)
			Next

			; Timeout --> lose
			If $kampf > 25 Then ; 17 auf 20 (3.1.25 auf 25)
				ConsoleWrite(" TIMEOUT" & @CRLF)
				For $p = 1 To $pmax
					If $win[$p] = 0 Then $lose[$p] = 1
					$weiter[$p] = 1
				Next
			EndIf

			; win
			For $p = 1 To $pmax
				If $lose[$p] = 1 Then ContinueLoop
				If $Color[$p] = $GK_C[0][1] Then
					ConsoleWrite("P" & $p & "-Win ")
					MouseClick("", $W_P[$p][1] + 430, $W_P[$p][2] + 415, 1, 0) ;Sieg - OK
					$weiter[$p] = 1
					$win[$p] = 1
				EndIf

				; wenn lose dann 2.te chance
				If $Color[$p] = $GK_C[1][1] Then $ready[$p] += 1
				If $Color[$p] = $GK_C[1][1] Then ConsoleWrite("P" & $p & " fasle positiv" & $ready[$p] & " ")
				If $Color[$p] = $GK_C[1][1] And $ready[$p] = 2 Then
					ConsoleWrite("P" & $p & " lose ")
					MouseClick("", $W_P[$p][1] + 430, $W_P[$p][2] + 415, 1, 10) ;Niederlage - Ok
					$weiter[$p] = 1
					$lose[$p] = 1
					$ready[$p] = 0
				EndIf
			Next

			$sum = 0
			For $i = 0 To UBound($weiter) - 1
				$sum += $weiter[$i]
			Next
;~ 			ConsoleWrite(@CRLF) & "$sum " &$sum & " $pmax: " & $pmax & @CRLF)

		Until $sum = $pmax
		$sum = 0

		Sleep(1000)

		; reset $weiter
		For $i = 0 To UBound($weiter) - 1
			$weiter[$i] = 0
		Next
		$kampf = 0

		$counter = 18 ; von 7 auf 8 11.9.23 //von 10 auf 11 19.8.24 (3.1.25 --13) (3.1.25 --18)

		Do ;GK Kiste öffnen
			$counter -= 1
;~ 			ConsoleWrite($counter &" ")
			For $p = 1 To $pmax
				If $win[$p] = 1 Then MouseClick("", $W_P[$p][1] + 430, $W_P[$p][2] + 250, 2, 0) ;Kiste
				If $win[$p] = 1 Then $wait = 1
				If $lose[$p] = 1 Then $weiter[$p] = 1
			Next
			If $wait = 1 Then Sleep(3000)
			$wait = 0

			For $p = 1 To $pmax
				If $lose[$p] = 1 Then ContinueLoop
				Do
					$Color[$p] = PixelGetColor($W_P[$p][1] + $GK_Button_Allg[3][1], $W_P[$p][2] + $GK_Button_Allg[3][2] + $a) ;Rot?
					$a = $a + 5
;~ 					ConsoleWrite($a&" ")
					If $Color[$p] = $GK_C[3][1] Then $a = 60
				Until $a = 60
				If $Color[$p] = $GK_C[3][1] Then $weiter[$p] = 1
				$a = 0
			Next

;~ 			ConsoleWrite(@CRLF & "...." & $counter)
			For $i = 0 To UBound($weiter) - 1
				$sum += $weiter[$i]
			Next
			If $sum = $pmax Then $counter = 1
			$sum = 0

		Until $counter <= 1

		; reset $weiter
		For $i = 0 To UBound($weiter) - 1
			$weiter[$i] = 0
		Next

		For $p = 1 To $pmax
			If $win[$p] = 1 Then MouseClick("", $W_P[$p][1] + 430, $W_P[$p][2] + 365, 2, 0) ;Einsammeln ;ANPASSEN!!!!
		Next

		For $i = 0 To UBound($lose) - 1
			$winSum += $win[$i]
			$loseSum += $lose[$i]
		Next
		If $loseSum = $pmax Then $Gegner = 10
		If $winSum > 0 Then Sleep(3000)
		$winSum = 0
		$loseSum = 0

		ConsoleWrite(@CRLF)

;~ 	Until $Gegner = 8
	Until $Gegner = 10

	Sleep(3000)

	; GK verlassen
	For $p = 1 To $pmax
		MouseClick("", $W_P[$p][1] + 53, $W_P[$p][2] + 447, 1, 0) ;Retour unten links
	Next

	ConsoleWrite(@HOUR & "-" & @MIN & "-" & @SEC & " " & "GK END" & @CRLF)

	; reset alle variablen
	For $i = 0 To UBound($win) - 1
		$weiter[$i] = 0
		$ready[$i] = 0
		$lose[$i] = 0
		$win[$i] = 0
	Next

	$EndTime = _NowCalc()
	$TotalSeconds = _DateDiff('s', $StartTime, $EndTime)
	; Sekunden in Millisekunden umrechnen und _TicksToTime aufrufen
	Local $Hours, $Mins, $Secs
	_TicksToTime($TotalSeconds * 1000, $Hours, $Mins, $Secs)
	ConsoleWrite("Vergangene Zeit: " & $Mins & " Minuten und " & $Secs & " Sekunden" & @CRLF)
	ConsoleWrite(_NowTime() & " Ende Kisten holen" & @CRLF)

EndFunc   ;==>Gangkaempfe
