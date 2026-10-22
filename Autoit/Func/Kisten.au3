Func Kistenholen()
	;auf $pmax angepasst 23.10.2025

	GK_Screen()

	ConsoleWrite(_NowTime() & " Start Kisten holen" & @CRLF)
	Local $sStartTime = _NowCalc()

	Local $Kistenpos0[5][2] = [[0, 0], [151, 164], [259, 164], [148, 320], [277, 320]] ;OL OR UL UR ; Kistenpos für: Kiste mitte
	Local $Kistenpos1[5][2] = [[0, 0], [151, 194], [259, 194], [148, 350], [277, 350]] ;OL OR UL UR ; Kistenpos für: Kiste da?
	Local $Kistenpos2[5][2] = [[0, 0], [208, 102], [312, 102], [205, 258], [329, 236]] ;OL OR UL UR ; Kistenpos für: Timer läuft
	Local $Kistenpos3[5][2] = [[0, 0], [151, 096], [259, 096], [147, 243], [277, 244]] ;OL OR UL UR ; Kistenpos für: Kisten fertig
	Local $Kistenpos4[5][6] = [[0, 0, 0, 0, 0, 0], [113, 188, 113, 164, 113, 141], [227, 188, 227, 164, 227, 141], [113, 348, 113, 324, 113, 301], [237, 348, 237, 324, 237, 301]] ;Kronen

;~ 	Local $Kisten  	;0 P1 P2 P3 etc..., 0=Nein 1=Da 3=Timer läuft 5=Fertig
;~ 	Local $Kistenk 	;0 P1 P2 P3 etc..., 0 3K 2K 3K 1K

	Local $Kisten = InitArrayWithZeros($pmax + 1, 6)
	Local $Kistenk = InitArrayWithZeros($pmax + 1, 5)

	Local $Color[$pmax + 1][5]
	Local $Kistenpos[5][2] = [[428, 410], _ ;Kiste öffnen mitte (Button)
			[575, 098], _ ;Kiste schliessen
			[281, 329], _ ;Einsammeln links
			[356, 320], _ ;Einsammeln mitte
			[427, 243]] ;Kiste öffnen Mitte

	Local $Duell = 0
	Local $count = 0
	Local $weiter = 0
	Global $skip_Duell = InitArrayWithZeros($pmax + 1)

;~ 	$Kisten[0][0] = 0 ;wenn eine Kiste fertig ist
	$skip_Duell[0] = ($kisten_option1 = 1) ? 1 : 0 ; Duell
	$Kisten[0][1] = ($kisten_option2 = 0) ? 1 : 0 ; Kisten aktivieren
	$Kisten[0][2] = ($kisten_option3 = 0) ? 1 : 0 ; Kisten holen

;~ 	Kistenslots prüfen
	For $p = 1 To $pmax
		If $skip[$p] = 1 Then ContinueLoop
		For $k = 1 To 4 ; Kisten OL,OR,UL,UR
			$Color[$p][0] = PixelGetColor($W_P[$p][1] + $Kistenpos0[$k][0], $W_P[$p][2] + $Kistenpos0[$k][1])
			$Color[$p][1] = PixelGetColor($W_P[$p][1] + $Kistenpos1[$k][0], $W_P[$p][2] + $Kistenpos1[$k][1])
			$Color[$p][2] = PixelGetColor($W_P[$p][1] + $Kistenpos2[$k][0], $W_P[$p][2] + $Kistenpos2[$k][1])
			$Color[$p][3] = PixelGetColor($W_P[$p][1] + $Kistenpos3[$k][0], $W_P[$p][2] + $Kistenpos3[$k][1])
;~ 			ConsoleWrite(Hex($Color[$p][0],6) & " ")
;~ 			ConsoleWrite(Hex($Color[$p][1],6) & " ")
;~ 			ConsoleWrite(Hex($Color[$p][2],6) & " ")
;~ 			ConsoleWrite(Hex($Color[$p][3],6) & " ")

			; Kistenslots zuordnen
			If $skip[$p] = 1 Then ContinueLoop
			If $Color[$p][1] > 0x6A0000 Then $Kisten[$p][$k] = 1 ;_Kiste da		(1)
			If $Color[$p][3] > 0xFB0000 Then $Kisten[$p][$k] = 5 ; Kiste fertig	(5)
			If $Color[$p][2] = 0xFFE3C3 Then $Kisten[$p][$k] = 3 ; Timer läuft	(3)
		Next
	Next

;~ 	Kronenckeck
	For $p = 1 To $pmax
		If $skip[$p] = 1 Then ContinueLoop
		For $k = 1 To 4 ; Kisten OL,OR,UL,UR
			$Color[$p][1] = PixelGetColor($W_P[$p][1] + $Kistenpos4[$k][0], $W_P[$p][2] + $Kistenpos4[$k][1])
			$Color[$p][2] = PixelGetColor($W_P[$p][1] + $Kistenpos4[$k][2], $W_P[$p][2] + $Kistenpos4[$k][3])
			$Color[$p][3] = PixelGetColor($W_P[$p][1] + $Kistenpos4[$k][4], $W_P[$p][2] + $Kistenpos4[$k][5])
;~ 				if $p = 4 and $k = 3 Then
;~ 					ConsoleWrite("Spieler " & $p & " Kiste " & $k & " Krone 1-2-3: ")
;~ 					ConsoleWrite(Hex($iColor[$p][1],6) & " ")
;~ 					ConsoleWrite(Hex($iColor[$p][2],6) & " ")
;~ 					ConsoleWrite(Hex($iColor[$p][3],6) & " ")
;~ 					ConsoleWrite(@CRLF)
;~ 				EndIf
			; 			Kronen zuordnen
			If $skip[$p] = 1 Then ContinueLoop
			If $Color[$p][1] > 0xB00000 Then $Kistenk[$p][$k] = 1
			If $Color[$p][2] > 0xB00000 Then $Kistenk[$p][$k] = 2
			If $Color[$p][3] > 0xB00000 Then $Kistenk[$p][$k] = 3
		Next
	Next

	;Auswertung ausgeben
	For $p = 1 To UBound($Kisten) - 1
		If $skip[$p] = 1 Then ContinueLoop
		ConsoleWrite("P" & $p & " hat folgende Kisten: ")
		For $j = 1 To UBound($Kisten, 2) - 2
			ConsoleWrite($Kisten[$p][$j] & "-" & $Kistenk[$p][$j] & " ")
		Next
		ConsoleWrite(@CRLF)
	Next

;~ exit

	;0 keine da, 1 da, 3 Timer läuft, 5 fertig, 4 fertig aber nicht öffnen,

	For $p = 1 To $pmax
		For $k = 1 To 4
			If $skip[$p] = 1 Then $skip_Duell[$p] = 1
			If $skip[$p] = 1 Then ContinueLoop
			If $Kisten[$p][$k] = 5 Then $Duell = 1 ;wenn eine Kiste fertig ist
			If $Kisten[$p][$k] = 5 Then $Kisten[0][0] = 5 ;wenn eine Kiste fertig ist
			If $Kisten[$p][$k] = 5 Then $Kisten[$p][5] = 5 ;wenn eine Kiste fertig ist
			If $Kisten[$p][$k] = 5 Then $Kistenk[$p][$k] = 3 ;wenn eine Kiste fertig ist	 --> 3K
			If $Kisten[$p][$k] = 3 Then $Kistenk[$p][$k] = 3 ;wenn eine Kiste läuft		 --> 3K
			If $Kisten[$p][$k] < 3 And $Kistenk[$p][$k] < 3 Then $Duell = 1
			If $Kisten[$p][$k] = 3 Then $Kisten[$p][0] = 3 ;Timer läuft für diesen Spieler
			$count += $Kistenk[$p][$k]
		Next
 		If $count = 12 Then $skip_Duell[$p] = 1
;		If $count = 12 Then $skip_Duell[$p] = 0 ; immer Duell ......
;~ 		ConsoleWrite($p & " " & $count & @CRLF) ;Anzahl Kronen Total
		If $skip_Duell[$p] = 1 And $Kisten[$p][5] = 5 And $kisten_option3 = 0 Then $skip_Duell[$p] = 0 ;Duell aktivieren da Kisten geholt werden
;~ 		If $skip_Duell[$p] = 1 Then ConsoleWrite("skip Duell P" & $p & @CRLF)
		$count = 0
	Next

	For $i = 0 To UBound($skip_Duell) - 1
		$sum += $skip_Duell[$i]
	Next
	If $sum = $pmax Then $Duell = 0
	$sum = 0

	For $k = 1 To 4 ; Kisten OL,OR,UL,UR
;~ 		ConsoleWrite("----Kiste " & $k & " ----" & @CRLF)
		;Timer starten
		For $p = 1 To $pmax
			If $skip[$p] = 1 Then ContinueLoop
			If $Kisten[0][1] = 0 Then ContinueLoop
			If $Kisten[$p][0] = 3 Then ContinueLoop
			If $Kistenk[$p][$k] = 3 And $Kisten[$p][$k] = 1 Then
				ConsoleWrite("Timer aktivieren von Kiste " & $k & " von Spieler " & $p & @CRLF)
				MouseClick("", $W_P[$p][1] + $Kistenpos0[$k][0], $W_P[$p][2] + $Kistenpos0[$k][1], 1, 0) ;Kiste öffnen (eine von 4) [aktivieren]
				Sleep(1000)
				MouseClick("", $W_P[$p][1] + $Kistenpos[0][0], $W_P[$p][2] + $Kistenpos[0][1], 1, 0) ;Kiste öffnen (gross in Mitte)
				Sleep(1000)
				MouseClick("", $W_P[$p][1] + $Kistenpos[1][0], $W_P[$p][2] + $Kistenpos[1][1], 1, 0) ;Kiste schliessen
				$Kisten[$p][0] = 3 ;Timer läuft für diesen Spieler
			EndIf
		Next

		;Kiste öffnen
		For $p = 1 To $pmax
			If $skip[$p] = 1 Then ContinueLoop
			If $Kisten[$p][$k] = 5 And $Kisten[0][2] = 1 Then MouseClick("", $W_P[$p][1] + $Kistenpos0[$k][0], $W_P[$p][2] + $Kistenpos0[$k][1], 1, 0) ;Kiste öffnen (eine von 4)
		Next

		;Kiste nehmen
		Do
			For $p = 1 To $pmax
				If $skip[$p] = 1 Then ContinueLoop
				If $Kisten[$p][$k] = 5 And $Kisten[0][2] = 1 Then MouseClick("", $W_P[$p][1] + $Kistenpos[4][0], $W_P[$p][2] + $Kistenpos[4][1], 1, 0)
			Next

			If $weiter > 1 Then ConsoleWrite($weiter)

;~ 	If $Kisten[0][2] = 1 And ($Kisten[1][$k] = 5 Or $Kisten[2][$k] = 5 Then Sleep(1000)
;~ 	If $Kisten[1][$k] <> 5 And $Kisten[2][$k] <> 5 Then $weiter = 15
;~ 	If $Kisten[0][2] = 0 Then $weiter = 15
;~ 	$weiter = $weiter + 1

			; Prüfen ob Kisten da sind
			Local $Kistenda = False
			For $i = 1 To $pmax
				If $Kisten[$i][$k] = 5 Then
					$Kistenda = True
					ExitLoop
				EndIf
			Next
			; Sleep nur wenn Kisten da sind
			If $Kisten[0][2] = 1 And $Kistenda Then Sleep(1000)

			; Setze Weiter basierend auf Status
			$weiter = ($Kisten[0][2] = 0 Or Not $Kistenda) ? 15 : $weiter + 1

		Until $weiter > 14

		$weiter = 0

		If $Kisten[0][0] = 5 Then
			For $p = 1 To $pmax
				If $skip[$p] = 1 Then ContinueLoop
				If $Kisten[$p][$k] = 5 And $Kisten[0][2] = 1 Then
					ConsoleWrite(@CRLF & "Einsammeln ")
					$d = 1
					Do
						$Color[0][0] = PixelGetColor($W_P[$p][1] + $Kistenpos[2 + $b][0], $W_P[$p][2] + $Kistenpos[2 + $b][1] + $a) ; 0xD22325
						$a = $a + 5
						If $Color[0][0] = 0xD22325 Then MouseClick("", $W_P[$p][1] + $Kistenpos[2 + $b][0], $W_P[$p][2] + $Kistenpos[2 + $b][1] + $a, 1, 10)
						ConsoleWrite(" " & $a)
;~ 						Sleep(200)

						If $a = 170 And $b = 0 Then
							$b = 1
							$a = 0
						EndIf
						If $a = 180 Then ConsoleWrite(" Timeout " & $c & @CRLF)
						If $a = 180 Then Exit
					Until $Color[0][0] = 0xD22325
					$b = 0
				EndIf
				$a = 0
			Next

			If $d = 1 Then
				ConsoleWrite(@CRLF)
				Sleep(200) ;16.10.2025 deaktiviert ;weil Bonus Film Kiste übersehen wird 11.11.25
				ConsoleWrite("warum 200") ;weil Bonus Film Kiste übersehen wird
				For $p = 1 To $pmax
					$Color[$p][0] = PixelGetColor($W_P[$p][1] + $iPosx07, $W_P[$p][2] + $iPosy07) ;
					If $Color[$p][0] = 0xECDFD3 Then MouseClick("", $W_P[$p][1] + 574, $W_P[$p][2] + 99, 1, 5) ;Bonus Film Kiste eXit
					Sleep(1000)
					$d = 0
				Next
			EndIf
		EndIf
	Next

	If $skip_Duell[0] = 1 Then $Duell = 0
	If $Duell = 1 Then
		$Duell = 0
		Global $ns = 0
		MainScreen()
		If $ns = 0 Then Duell()
		If $ns = 0 Then Kistenholen()
		ConsoleWrite("Kistensammeln End (Duell = 1)" & @CRLF)
	EndIf

	Local $sEndTime = _NowCalc()
	Local $iTotalSeconds = _DateDiff('s', $sStartTime, $sEndTime)
	; Sekunden in Millisekunden umrechnen und _TicksToTime aufrufen
	Local $iHours, $iMins, $iSecs
	_TicksToTime($iTotalSeconds * 1000, $iHours, $iMins, $iSecs)
	ConsoleWrite("Vergangene Zeit: " & $iMins & " Minuten und " & $iSecs & " Sekunden" & @CRLF)
	ConsoleWrite(_NowTime() & " Kisten holen end" & @CRLF)
	Sleep(3000)

EndFunc   ;==>Kistenholen


Func SteevysKisten()

	$Kistennummer = 0
	$weiter = 0
	$ans = -1

	For $p = 1 To $pmax
		If $skip[$p] = 1 Then ContinueLoop
		MouseClick("", $W_P[$p][1] + $iPosx04, $W_P[$p][2] + $iPosy04, 1, 0) ;Einkaufswagen
	Next
	Sleep(1000)

	For $p = 1 To $pmax
		If $skip[$p] = 1 Then ContinueLoop
		MouseMove($W_P[$p][1] + $iPosx05, $W_P[$p][2] + $iPosy05) ;oberste Auswahl
		MouseWheel($MOUSE_WHEEL_DOWN, 9) ;Scroolen zu Kisten
		Sleep(1000)
		MouseWheel($MOUSE_WHEEL_DOWN, 9) ;Scroolen zu Kisten
		Sleep(500)
		MouseClick("", $W_P[$p][1] + $iPosx05, $W_P[$p][2] + $iPosy05, 1, 0) ;Kisten
	Next
	Sleep(1000)

	For $p = 1 To $pmax
		If $skip[$p] = 1 Then ContinueLoop
;~ 		MouseMove($W_P[$p][1] + 830, $W_P[$p][2] + 140) ;schieben zu Kisten
		MouseClickDrag($MOUSE_CLICK_LEFT, $W_P[$p][1] + 830, $W_P[$p][2] + 140, $W_P[$p][1] + 9, $W_P[$p][2] + 140, 40)
	Next
	Sleep(1000)

	; Optional - Prüfen ob Kistentimer läuft oder ob [Gold Schraubenschlüssel 50] da ist --> wenn nicht skip....

	For $p = 1 To $pmax
		If $skip[$p] = 1 Then ContinueLoop
		Local $iColor = PixelGetColor($W_P[$p][1] + 533, $W_P[$p][2] + 344) ; roter Button Hintergrund)
		If $iColor = 0xECDFD3 Then ;D22325 --> Rot
			$skip[$p] = 1 ;_Kiste schon geholt
			ConsoleWrite("P" & $p & " hat schon, ist raus." & @CRLF)
		EndIf
	Next
	Sleep(1000)

	Do
		$Kistennummer = $Kistennummer + 1

		For $p = 1 To $pmax
			If $skip[$p] = 1 Then ContinueLoop
			MouseClick("", $W_P[$p][1] + $iPosx06, $W_P[$p][2] + $iPosy06, 1, 0) ;Steevys Kiste
		Next
		Sleep(4 * 1000) ; No 2000 , no 3000

		For $p = 1 To $pmax
			If $skip[$p] = 1 Then ContinueLoop
			MouseClick("", $W_P[$p][1] + 430, $W_P[$p][2] + 260, 1, 0) ;Steevys Kiste öffnen
		Next
		Sleep(2 * 1000)

		Do
			If $Kistennummer = 1 Then $Loop = 1
			$Loop += 1
			Local $ergebnisse = SteevysKisten_Wahl() ; Entscheidungen abrufen
			For $p = 1 To $pmax
				If $skip[$p] = 1 Then ContinueLoop
				If $ergebnisse[$p] = "Links" Then
					MouseClick("", $W_P[$p][1] + 265, $W_P[$p][2] + 281, 1, 0) ; Klick auf Linke Kiste
				Else
					MouseClick("", $W_P[$p][1] + 584, $W_P[$p][2] + 281, 1, 0) ; Klick auf Rechte Kiste
				EndIf
			Next
			Sleep(2 * 1000)

			For $p = 1 To $pmax
				If $skip[$p] = 1 Then ContinueLoop
				MouseClick("", $W_P[$p][1] + 428, $W_P[$p][2] + 243, 1, 0) ;Steevys Kiste Belohnung nehmen (mitte)
			Next
			Sleep(2 * 1000)

		Until $Loop = 2
		$Loop = 0


		For $p = 1 To $pmax
			If $skip[$p] = 1 Then ContinueLoop
			MouseClick("", $W_P[$p][1] + 428, $W_P[$p][2] + 243, 1, 0) ;Liga Ticket
		Next
		Sleep(2 * 1000)

		For $p = 1 To $pmax
			If $skip[$p] = 1 Then ContinueLoop
			MouseClick("", $W_P[$p][1] + 428, $W_P[$p][2] + 395, 1, 0) ;Einsammeln
		Next
		Sleep(3 * 1000)

		If $Kistennummer = 1 Then
			For $p = 1 To $pmax
				If $skip[$p] = 1 Then ContinueLoop
				MouseClick("", $W_P[$p][1] + 574, $W_P[$p][2] + 99, 1, 0) ;Bonus Film Kiste eXit
;~ 		If $iColor1 = 0xECDFD3 Then MouseClick("",$W_P[1][1] + 574, $W_P[1][2] + 99,1,5) ;Bonus Film Kiste eXit
			Next
			Sleep(2 * 1000)
		EndIf

	Until $Kistennummer = 3
	$Kistennummer = 0

	;zurück
	For $p = 1 To $pmax
		If $skip[$p] = 1 Then ContinueLoop
		MouseClick("", $W_P[$p][1] + 55, $W_P[$p][2] + 447, 1, 0) ;Zurück unten links
	Next

	Sleep(1 * 1000)
	ConsoleWrite("ENDE SteevysKisten" & @CRLF)

EndFunc   ;==>SteevysKisten


Func SteevysKisten_Wahl()

	Local $playerChoices[5] ; Array für 4 Spieler (Index 1-4)
	For $p = 1 To 4
		If $skip[$p] = 1 Then ContinueLoop
		$ans = MsgBox(262177, "Spieler " & $p, "Links nehmen?", 5) ; MsgBox mit 5-Sekunden-Timeout
		Switch $ans
			Case 1 ; OK-Button (Links)
				$playerChoices[$p] = "Links"
			Case 2 ; Cancel-Button (Rechts)
				$playerChoices[$p] = "Rechts"
			Case -1 ; Timeout
				$playerChoices[$p] = "Links"
		EndSwitch
	Next
	Return $playerChoices ; Array mit Entscheidungen zurückgeben
EndFunc   ;==>SteevysKisten_Wahl
