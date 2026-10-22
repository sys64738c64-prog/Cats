Func AllStars()

	Local $AS_Pos_B[5][2] =    [[200, 400], _ 	 ;0 All-Stars! 5/6...
								[430, 420], _ 	 ;1 Button OK unten mitte
								[044, 444], _ 	 ;2 Button Beenden
								[000, 000], _ 	 ;3
								[000, 000]] ;4

	Local $AS_Pos_C =		   [[106, 426], _ 	 ;0 Verlassen or Beenden
								[750, 426], _	 ;1 Normaler Zugang or Fortfahren
								[485, 426], _	 ;2 x5 3Bat.
								[427, 461], _	 ;3 Gewonnen Farbe unter OK
								[279, 374], _	 ;4 verlohren
								[330, 374]] _	 ;5 verlohren

	Local $Fahrzeuge[9] = [1, 1, 1, 1, 1, 1, 1, 1, 1]

	$sum = 0
	$Runde = 0 ; Default 0,
	$Gegner = 0
	$counter = 0
	$seconds = 100
	$Batterie = 40
	$AS_Mod = 3 ; 1 or 3 or 9


	Liga_Screen()

	;AS Start Button
	For $p = 1 To $pmax
		If $skip[$p] = 1 Then ContinueLoop
		If $skip[$p] = 0 Then MouseClick("", $W_P[$p][1] + $AS_Pos_B[0][0], $W_P[$p][2] + $AS_Pos_B[0][1], 1, 0) ;All-Stars!
	Next

	ConsoleWrite(@HOUR & "-" & @MIN & "-" & @SEC & " AllStars" & @CRLF)
	Sleep(3000)

	;Farbe definieren von All Stars Button
	For $p = 1 To $pmax
		If $skip[$p] = 1 Then ContinueLoop
		If $skip[$p] = 0 Then $AS_Button_Color = PixelGetColor($W_P[$p][1] + $AS_Pos_C[0][0], $W_P[$p][2] + $AS_Pos_C[0][1])
		ConsoleWrite(Hex($AS_Button_Color, 6) & @CRLF)
	Next

;~ 	$AS_Button_Color = 0x2D7F01
;~ 	Exit

	Do ;Until $Batterie < 1

		For $p = 1 To $pmax
			$lose[$p] = $skip[$p]
			$skip[$p] = $lose[$p]
		Next

;~ if $Batterie > 2 Then $AS_Mod = 3
;~ if $Batterie < 2 Then $AS_Mod = 9
		;Mod Auswahl

		Do
			For $p = 1 To $pmax
				If $lose[$p] = 1 Then ContinueLoop
				If $AS_Mod = 9 Then MouseClick("", $W_P[$p][1] + 312, $W_P[$p][2] + 446, 1, 0) ;Batterie 2x
				If $AS_Mod = 3 Then MouseClick("", $W_P[$p][1] + 500, $W_P[$p][2] + 446, 1, 0) ;Batterie 3x
				If $AS_Mod = 1 Then MouseClick("", $W_P[$p][1] + 688, $W_P[$p][2] + 446, 1, 0) ;Batterie 1x
			Next

			For $p = 1 To $pmax
				If $lose[$p] = 1 Then ContinueLoop
				If $AS_Mod = 9 Then Sleep(45 * 1000)
				If $AS_Mod = 9 Then MouseClick("", $W_P[$p][1] + 833, $W_P[$p][2] + 26, 1, 0) ;Batterie 2x
				If $AS_Mod = 9 Then Sleep(5 * 1000)
				If $AS_Mod = 9 Then MouseClick("", $W_P[$p][1] + 833, $W_P[$p][2] + 26, 1, 0) ;Batterie 2x
			Next

			Sleep(3 * 1000)

;~ 			For $p = 1 To $pmax
;~ 				If $lose[$p] = 1 Then ContinueLoop
;~ 				$Color1[$p] = PixelGetColor($W_P[$p][1] + $AS_Pos_C[3][0], $W_P[$p][2] + $AS_Pos_C[3][1]) ;Farbe unter OK
;~ 			Next

			;Batterie Check
			For $p = 1 To $pmax
				If $lose[$p] = 1 Then ContinueLoop
				$Color2[$p] = PixelGetColor($W_P[$p][1] + $AS_Pos_B[1][0], $W_P[$p][2] + $AS_Pos_B[1][1]) ;Keine Batterien mehr?
				$Color3[$p] = PixelGetColor($W_P[$p][1] + $AS_Pos_B[2][0], $W_P[$p][2] + $AS_Pos_B[2][1]) ;Beenden Button da?

				If $Color3[$p] = $AS_Button_Color Then
					$weiter[$p] = 1
;~ 					ConsoleWrite ("--- Start oder Runde schon da bei P" & $p & @CRLF)
				EndIf

				If $Color2[$p] = $AS_Button_Color Then
					$lose[$p] = 1
					$weiter[$p] = 1
					ConsoleWrite("Batterie leer P" & $p & " ist Raus" & @CRLF)
					MouseClick("", $W_P[$p][1] + $AS_Pos_B[1][0], $W_P[$p][2] + $AS_Pos_B[1][1], 1, 0) ;OK (Keine Batterien mehr)
				EndIf
			Next

			$sum = 0
			$Sumlose = 0
			For $p = 1 To $pmax
				If $lose[$p] = 1 Then $weiter[$p] = 1
				$sum = $sum + $weiter[$p]
				$Sumlose = $Sumlose + $lose[$p]
			Next
		Until $pmax = $sum
;~ 		ConsoleWrite("Batterie check done" & @CRLF)
		If $Sumlose = $pmax Then ExitLoop
		Local $weiter = InitArrayWithZeros($pmax + 1)

;~ 		Exit

;~ 		$Runde = 7
		ConsoleWrite("ScriptLineNumber " & @ScriptLineNumber & @CRLF)

		Do ;Start Runden
			$Runde += 1

			ConsoleWrite("Runde " & $Runde & ": ")

			Local $RundenGegner = [[00, 0], _
					[01, 2], _
					[02, 2], _
					[03, 1], _
					[04, 2], _
					[05, 2], _
					[06, 1], _
					[07, 3], _
					[08, 1], _
					[09, 1], _
					[10, 1], _
					[11, 2], _
					[12, 3], _
					[13, 1], _
					[14, 1], _
					[15, 1], _
					[16, 1], _
					[17, 1], _
					[18, 1], _
					[19, 1], _
					[20, 1]]

			$Gegner = $RundenGegner[$Runde][1]

			;			Gegner auswählen _start_
			Do ; Kampf
				Do ; Gegner wählen
					$counter += 1

					If $Gegner >= 1 And $Gegner <= 3 Then
						Local $yOffset = 188 + ($Gegner - 1) * 80
						For $p = 1 To $pmax
							If $lose[$p] = 1 Then ContinueLoop
;~ 							If Eval("win" & $p) <> 1 And $lose[$p] = 0 Then
							If $win[$p] <> 1 And $lose[$p] = 0 Then
								MouseClick("", $W_P[$p][1] + 600, $W_P[$p][2] + $yOffset, 2, 10)
							EndIf
						Next
					EndIf

					Sleep(500)

					;Button Fortfahren
					For $p = 1 To $pmax
						If $lose[$p] = 1 Then ContinueLoop
						$iColor[$p] = PixelGetColor($W_P[$p][1] + 705, $W_P[$p][2] + 465)
;~ 						ConsoleWrite($p & " " & Hex($iColor[$p], 6) & " = " & Hex($AS_Button_Color, 6) & @CRLF)
						If $iColor[$p] = $AS_Button_Color Then $weiter[$p] = 1
						If $p = 5 And $iColor[$p] = 0x006FC4 Then $weiter[$p] = 1 ; Warum ??? keine Zeit für Analyse
						If $p = 5 And $iColor[$p] = 0x006FC4 Then ConsoleWrite("braucht es P5" & @ScriptLineNumber)
						If $p = 6 And $iColor[$p] = 0x006FC4 Then $weiter[$p] = 1 ; Warum ??? keine Zeit für Analyse
						If $p = 6 And $iColor[$p] = 0x006FC4 Then ConsoleWrite("braucht es P6" & @ScriptLineNumber)
						If $p = 7 And $iColor[$p] = 0x006FC4 Then $weiter[$p] = 1 ; Warum ??? keine Zeit für Analyse
						If $p = 7 And $iColor[$p] = 0x006FC4 Then ConsoleWrite("braucht es P7" & @ScriptLineNumber)

						If $lose[$p] = 1 Or $win[$p] = 1 Then $weiter[$p] = 1
					Next

					;braucht es nicht
					If $counter = 100 Then
						ConsoleWrite("braucht es nicht " & @ScriptLineNumber)
						For $p = 1 To $pmax
							If $lose[$p] = 1 Then ContinueLoop
							If $weiter[$p] = 0 Then Exit ;$lose[$p] = 1
						Next
					EndIf

					$sum = 0
					For $p = 1 To $pmax
						If $lose[$p] = 1 Then $weiter[$p] = 1
						$sum = $sum + $weiter[$p]
					Next

				Until $pmax = $sum

				Local $weiter = InitArrayWithZeros($pmax + 1)
				$counter = 0
				;Gegner auswählen _end_

;~ 			If $Gegner = 1 Then ConsoleWrite("-1 ")
;~ 			If $Gegner = 2 Then ConsoleWrite("-2 ")
;~ 			If $Gegner = 3 Then ConsoleWrite("-3 ")

				If $lose[1] = 0 Or $lose[2] = 0 Or $lose[3] = 0 Then Sleep(1 * 1000)
				If $lose[5] = 0 Or $lose[6] = 0 Or $lose[7] = 0 Then Sleep(1 * 1000)

				If $Runde >= $AS_gegneranayse And $Runde <= 15 Then

					AS_Gegnererkennung()

					ConsoleWrite(" AS_Gegnererkennung done ")

					For $p = 1 To $pmax
						If $lose[$p] = 1 Then ContinueLoop
						If $AS_Pos_E[$p][0] = 1 Then MouseClick("", $W_P[$p][1] + 703, $W_P[$p][2] + 188, 2, 10) ;Gegner 1 oben
						If $AS_Pos_E[$p][0] = 2 Then MouseClick("", $W_P[$p][1] + 703, $W_P[$p][2] + 268, 2, 10) ;Gegner 2 mitte
						If $AS_Pos_E[$p][0] = 3 Then MouseClick("", $W_P[$p][1] + 703, $W_P[$p][2] + 348, 2, 10) ;Gegner 3 unten
					Next

					Local $remainingTime = 600 ; 600 => 10Min (Angabe in Sek.)
					Local $dll = DllOpen("user32.dll") ; Für Tastenabfrage benötigt

					While $remainingTime > 0
						; Space-Taste gedrückt?
						If _IsPressed("20", $dll) Then ; 20 ist der Hex-Code für Space
							$remainingTime = 0 ; Auf 3 Sekunden zurücksetzen
							ToolTip("") ; Aktuelles Tooltip löschen
							Sleep(300) ; Entprell-Pause
						EndIf

						; Countdown-Anzeige
						Local $mousePos = MouseGetPos()
						Local $minutes = Int($remainingTime / 60)
						Local $seconds = $remainingTime - ($minutes * 60)
						Local $countdownText = StringFormat("⏱ %02d:%02d", $minutes, $seconds)

						ToolTip($countdownText, $mousePos[0] + 20, $mousePos[1] + 20)
						Sleep(500)
						$remainingTime -= 1
					WEnd

					DllClose($dll)
					ToolTip("") ; Tooltip entfernen

				EndIf

				If $Runde >= $AS_pause Then TogglePause() ;ab 8 z.B.

				;			Abfrage weiter oder aufhören _end_
				For $p = 1 To $pmax
					If $lose[$p] = 1 Then ContinueLoop
					If $win[$p] = 0 And $lose[$p] = 0 Then MouseClick("", $W_P[$p][1] + 760, $W_P[$p][2] + 451, 1, 0) ;Fortfahren
				Next

				If $lose[1] = 0 Or $lose[2] = 0 Or $lose[3] = 0 Or $lose[4] = 0 Then Sleep(3 * 1000)
				If $lose[5] = 0 Or $lose[6] = 0 Or $lose[7] = 0 Or $lose[8] = 0 Then Sleep(3 * 1000)

				For $p = 1 To $pmax
					If $win[$p] = 0 And $lose[$p] = 0 Then MouseClick("", $W_P[$p][1] + 430, $W_P[$p][2] + 207, 1, 0) ;Ansehen
					Sleep(100)
					If $win[$p] = 0 And $lose[$p] = 0 Then MouseClick("", $W_P[$p][1] + 430, $W_P[$p][2] + 207, 1, 5) ;Ansehen
				Next

				BlockInput($BI_ENABLE) ;Eingabe zulassen

;~ 			ConsoleWrite(" Ansehen ")
				If $lose[1] = 0 Or $lose[2] = 0 Or $lose[3] = 0 Or $lose[4] = 0 Then Sleep(3 * 1000)
				If $lose[5] = 0 Or $lose[6] = 0 Or $lose[7] = 0 Or $lose[8] = 0 Then Sleep(3 * 1000)

				Local $iColor[24 + 1] ;neu 19.12.24
				Local $seconds = 80
				Local $weiter = InitArrayWithZeros($pmax + 1)


				;Auswertung Sieg or Niederlage
				Do

					$seconds -= 1

					;Pixel aufnehmen start
					For $p = 1 To $pmax
						If $lose[$p] = 1 Then ContinueLoop
						$Color1[$p] = PixelGetColor($W_P[$p][1] + $AS_Pos_C[3][0], $W_P[$p][2] + $AS_Pos_C[3][1]) ;Farbe unter OK
					Next

					Sleep(200)

					For $p = 1 To $pmax
						If $lose[$p] = 1 Then ContinueLoop
						$Color2[$p] = PixelGetColor($W_P[$p][1] + $AS_Pos_C[3][0], $W_P[$p][2] + $AS_Pos_C[3][1]) ;Farbe unter OK
					Next

					For $p = 1 To $pmax
						If $lose[$p] = 1 Then ContinueLoop
						$Color3[$p] = PixelGetColor($W_P[$p][1] + $AS_Pos_C[4][0], $W_P[$p][2] + $AS_Pos_C[4][1]) ;verlohren?
						$Color4[$p] = PixelGetColor($W_P[$p][1] + $AS_Pos_C[5][0], $W_P[$p][2] + $AS_Pos_C[5][1]) ;verlohren?
					Next
					;Pixel aufnehmen end

					For $p = 1 To $pmax
						If $lose[$p] = 1 Then $weiter[$p] = 1
						If $lose[$p] = 1 Then ContinueLoop
						If $win[$p] = 1 Then ContinueLoop

						If $Color1[$p] = $Color2[$p] And $Color1[$p] = $AS_Button_Color And $weiter[$p] = 0 Then
							ConsoleWrite("P" & $p & "-win ")
							MouseClick("", $W_P[$p][1] + 427, $W_P[$p][2] + 440, 1, 0) ;SIEG - OK
							$win[$p] = 1
							$weiter[$p] = 1
						EndIf

;~ 						ConsoleWrite("P" & $p & "color 3 v 4 : C3-> " & $Color3[$p] & " :C4-> " & $Color4[$p] & " - $AS_Button_Color: " & $AS_Button_Color & @CRLF)
						If ($Color3[$p] = $AS_Button_Color Or $Color4[$p] = $AS_Button_Color) And $weiter[$p] = 0 Then
							ConsoleWrite("P" & $p & "-lose ")
							MouseClick("", $W_P[$p][1] + 570, $W_P[$p][2] + 380, 1, 20) ;Niederlage - Verlassen
							Sleep(3000)
							MouseClick("", $W_P[$p][1] + 430, $W_P[$p][2] + 435, 1, 20) ;Wertung - OK
							$lose[$p] = 1
							$weiter[$p] = 1
						EndIf
					Next


				Until $weiter[1] + $weiter[2] + $weiter[3] + $weiter[4] + $weiter[5] + $weiter[6] + $weiter[7] + $weiter[8] = 8

				ConsoleWrite(" Auswertung done" & @CRLF)

				$sum = 0
				For $p = 1 To $pmax
					If $lose[$p] = 1 Then $weiter[$p] = 1
					$sum = $sum + $weiter[$p]
;~ 						If $weiter[$p] = 1 Then
					If $weiter[$p] = 0 Then Sleep(500)
					If $lose[$p] = 1 Then ContinueLoop
;~ 						If $weiter[$p] = 0 And $lose[$p] = 0 Then MouseClick("", $W_P[$p][1] + 456, $W_P[$p][2] + 465, 1, 20) ;Casino-Edition(Rangliste)
					If $weiter[$p] = 0 Then $lose[$p] = 1
					If $weiter[$p] = 0 Then ConsoleWrite("kann nicht sein P" & $weiter[$p] & @CRLF)
					If $lose[$p] = 1 Then ContinueLoop
				Next

				If $lose[1] = 1 And $lose[2] = 1 And $lose[3] = 1 And $lose[4] = 1 And $lose[5] = 1 And $lose[6] = 1 And $lose[7] = 1 And $lose[8] = 1 Then $Runde = 20

			Until $pmax = $sum

			Local $weiter = InitArrayWithZeros($pmax + 1)

;~ 			ConsoleWrite("Chk 2"& @CRLF)

			Local $win = InitArrayWithZeros($pmax + 1)

;~ 			ConsoleWrite(_Now() & "until aussteigen" & @CRLF)

		Until $Runde >= $AS_aussteigen ; 9 ; 12 ; 15 ; 18 ; Aussteigen nach Runde

		ConsoleWrite("aussteigen" & @CRLF)

		Sleep(5 * 1000)
		If $Runde < 20 Then
			For $p = 1 To $pmax
				If $lose[$p] = 0 Then MouseClick("", $W_P[$p][1] + 044, $W_P[$p][2] + 444, 1, 0) ;aussteigen und Preis behalten
			Next

			Sleep(3000)
			For $p = 1 To $pmax
				If $lose[$p] = 0 Then MouseClick("", $W_P[$p][1] + 366, $W_P[$p][2] + 388, 1, 0) ;Bestätiging - JA
			Next
		EndIf

		Sleep(3000)

		For $p = 1 To $pmax
			If $Runde >= 20 Then
				If $lose[$p] = 0 Then MouseClick("", $W_P[$p][1] + 425, $W_P[$p][2] + 425, 1, 0) ;Herausforderung erfüllt
			EndIf
		Next

		Sleep(3000)

		For $p = 1 To $pmax
			If $lose[$p] = 0 Then MouseClick("", $W_P[$p][1] + 425, $W_P[$p][2] + 435, 1, 0) ;...(Rangliste) - OK
		Next

		ConsoleWrite("Runden Ende" & @CRLF)

;~ 		BlockInput($BI_ENABLE)

		Local $lose = InitArrayWithZeros($pmax + 1)
		$Batterie -= $AS_Mod
		$Runde = 0

	Until $Batterie < 10

	For $p = 1 To $pmax
		MouseClick("", $W_P[$p][1] + 111, $W_P[$p][2] + 444, 1, 0) ;All-Stars verlassen!
	Next

	Sleep(1000)

	For $p = 1 To $pmax
		MouseClick("", $W_P[$p][1] + 820, $W_P[$p][2] + 330, 1, 15) ;Main Screen wechseln
	Next

	ConsoleWrite(_Now() & " AllStars done!" & @CRLF)

	BlockInput($BI_ENABLE)

	Local $win = InitArrayWithZeros($pmax + 1)

EndFunc   ;==>AllStars


Func AS_Gegnererkennung()

;~ ConsoleWrite(_NowTime() & " AS Test Start" & @CRLF)

	Local $a = 0, $b = 0, $c = 0, $d = 0, $e = 0, $f = 0, $g = 0, $h = 0, $i = 0, $k = 0, $g1 = 0

	Local $AS_Pos_D[7][3] = [[000, 000, 000], [1095, 1228, 345], [1089, 1222, 400], [1074, 1207, 512], [1067, 1200, 568], [1055, 1188, 678], [1048, 1181, 734]] ;6 Linien Full

	For $p = 1 To $pmax
		If $lose[$p] = 1 Then ContinueLoop

;~ 		$p = 2

		If $p = 1 Then WinActivate("(Tigy)")
		If $p = 1 Then WinMove("(Tigy)", "", 0, 0, 1920, 1040)
		If $p = 1 Then ConsoleWrite(@CRLF & "Tigy ")

		If $p = 2 Then WinActivate("(Sigy)")
		If $p = 2 Then WinMove("(Sigy)", "", 0, 0, 1920, 1040)
		If $p = 2 Then ConsoleWrite(@CRLF & "Sigy ")

		If $p = 3 Then WinActivate("(Stefan)")
		If $p = 3 Then WinMove("(Stefan)", "", 0, 0, 1920, 1040)
		If $p = 3 Then ConsoleWrite(@CRLF & "Stefan ")

		If $p = 4 Then WinActivate("(Rob2)")
		If $p = 4 Then WinMove("(Rob2)", "", 0, 0, 1920, 1040)
		If $p = 4 Then ConsoleWrite(@CRLF & "Rob2 ")

		MouseClick("", 1833, 15, 1, 0) ;Fullscreen

		For $l = 1 To 6 ; 1 to 6

			For $g = 0 To 40 ;(-1 -- 22)

;~ 			 	MouseClick("", $W_P[1][1] + $c, $W_P[1][2] + $AS_Pos_D[$l][2], 1, 0) ;
				ConsoleWrite(@CRLF & $p & " Linie " & $l & " " & $AS_Pos_D[$l][2]+$g & " " & $g)
				For $c = $AS_Pos_D[$l][0] To $AS_Pos_D[$l][1] ; Step 5
					If $k = 0 Then
						MouseClick("", $W_P[0][1] + $c - 50, $W_P[0][2] + $AS_Pos_D[$l][2], 1, 0) ;
						Sleep(1000)
						$k = 1
					EndIf
					$iColor1 = PixelGetColor($W_P[0][1] + $c, $W_P[0][2] + $AS_Pos_D[$l][2] + $g)
			 		MouseMove($W_P[0][1] + $c, $W_P[0][2] + $AS_Pos_D[$l][2]+$g); ACHTUNG ZEIT-FRESSER +8Min
;~ 			 		ConsoleWrite(Hex($iColor1, 6) & @CRLF)
					if $iColor1 = 0xFFFFFF Then ConsoleWrite(".")
					if $iColor1 < 0xFFFFFF Then ConsoleWrite("o")

					If $iColor1 = 0xFFFFFF Then $h = $h + 1
					If $iColor1 < 0xFFFFFF Then $a = $a + 1

					If $iColor1 = 0xFFFFFF Then
						If $a >= 5 Then $b = $b + 1
						If $a > 21 Then $b = $b + 1
						If $a > 42 Then $b = $b + 1
						If $a > 63 Then $b = $b + 1
						If $a > 84 Then $b = $b + 1
						If $a > 105 Then $b = $b + 1
						If $a > 130 Then $b = $b + 1

						$a = 0
					EndIf
					If $h > 20 And $b = 0 Then ExitLoop
					If $c = $AS_Pos_D[$l][1] And $iColor1 < 0xFFFFFF Then $a = 0
				Next ; Linie...150...
				$h = 0

				If $b > 0 And $b < 17 Then ExitLoop ; 7 auf 17

			Next ; Zeilen pro Zahl

			$AS_Pos_E[$p][$l] = $b
;~ 				ConsoleWrite(" " & $b)
			$b = 0

			$k = $k - 0.5

		Next ; Lienien 1...6

		Sleep(500)
		WindowsPositionieren()
		Sleep(500)
		MouseClick("", $W_P[$p][1] + 811, $W_P[$p][2] - 16, 1, 0) ;Fensterinhalt anpassen
		Sleep(500)
		WindowsPositionieren()
		Sleep(500)

	Next ;Spieler

	;Auswertung
	For $p = 1 To $pmax
		If $skip[$p] = 1 Then ContinueLoop
		; Summen für die aktuelle Zeile berechnen
		Local $sum1 = $AS_Pos_E[$p][1] + $AS_Pos_E[$p][2]
		Local $sum2 = $AS_Pos_E[$p][3] + $AS_Pos_E[$p][4]
		Local $sum3 = $AS_Pos_E[$p][5] + $AS_Pos_E[$p][6]

		; Kleinste Summe ermitteln
		Local $minIndex = 1
		Local $minSum = $sum1

		If $sum2 < $minSum Then
			$minSum = $sum2
			$minIndex = 2
		EndIf

		If $sum3 < $minSum Then
			$minIndex = 3
		EndIf

		; Wert in die erste Spalte der aktuellen Zeile schreiben
		$AS_Pos_E[$p][0] = $minIndex

		ConsoleWrite("Spieler" & $p & " --> " & $AS_Pos_E[$p][0] & @CRLF)

	Next

EndFunc   ;==>AS_Gegnererkennung
