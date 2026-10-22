Func Ligakaempfe()

	Local $PlayerWagen[$pmax + 1][4]
	Local $DiaLiga[$pmax + 1]
	Local $noTicket[$pmax + 1]
	Local $punkten[$pmax + 1] = [0, 1, 1, 1, 1, 1, 1, 1, 1] ;(0=Nein, 1=Ja) [0 = bei 19 raus]

	$Runden = 0

	Liga_Screen()

	ConsoleWrite(_NowTime() & " Liga Start" & @CRLF)

	While $terminate = 0

		$Sum = 0
		$Runden = $Runden + 1
		ConsoleWrite("Ticket " & $Runden & @CRLF)

		; Tickes vorhanden? wenn Ja Ligakämpfe starten
		For $p = 1 To $pmax
			If $skip[$p] = 1 Then $lose[$p] = 1
			If $noTicket[$p] = 1 Then $lose[$p] = 1
			If $lose[$p] = 1 Then ContinueLoop
			$Color[$p] = PixelGetColor($W_P[$p][1] + 584, $W_P[$p][2] + 384)
			If $Color[$p] > 0xE70000 Then
;~ 				ConsoleWrite("P" &$p &";Button Ligakämpfe starten" & @CRLF)
				MouseClick("", $W_P[$p][1] + 555, $W_P[$p][2] + 418, 1, 0)
				$weiter[0] = 1
			EndIf
		Next

		Sleep(3000)

		;Keine Tickets mehr
		;mit Dias starten... or not
		For $p = 1 To $pmax
			If $lose[$p] = 1 Then ContinueLoop
			$Color[$p] = PixelGetColor($W_P[$p][1] + 575, $W_P[$p][2] + 92)
;~ 	ConsoleWrite("P" &$p & " " & Hex($Color[$p],6) & @CRLF)
			If $Color[$p] = 0xD22325 Then
				If $DiaLiga[$p] >= 1 Then
					MouseClick("", $W_P[$p][1] + 357, $W_P[$p][2] + 406, 1, 0) ;5 für 50Dias
					$weiter[0] = 1
				Else
					ConsoleWrite("P" & $p & ";Keine Tickets mehr X" & @CRLF)
					MouseClick("", $W_P[$p][1] + 573, $W_P[$p][2] + 108, 1, 0) ;Keine Tickets mehr X
					$lose[$p] = 1
					$noTicket[$p] = 1
				EndIf
			EndIf
		Next

		;Bediengungen zum starten / weitermachen
		Do
			$f += 1
			Sleep(1000)
			If $f > 15 Then
				For $p = 1 To $pmax
					If $lose[$p] Then ContinueLoop
					If $weiter[$p] = 0 Then $lose[$p] = 1
				Next
			EndIf

			;ein Wagen angewählt? (Ansehen)
;~ 			ConsoleWrite("P" &$p &" Ansehen???????" & @CRLF)
			For $p = 1 To $pmax
				If $lose[$p] Then ContinueLoop
				For $c = 1 To 3
					$PlayerWagen[$p][$c] = PixelGetColor($W_P[$p][1] + (57 + $c * 61), $W_P[$p][2] + 362)
				Next
				;Button Sieg
				$Color[$p] = PixelGetColor($W_P[$p][1] + $iPosx01, $W_P[$p][2] + $iPosy01)
				If $Color[$p] = 0xD22325 Then $weiter[$p] = 1
				If $Color[$p] = 0xD22325 Then $weiter[0] = 1
				;Button Fortfahren
				$Color[$p] = PixelGetColor($W_P[$p][1] + $iPosx03, $W_P[$p][2] + $iPosy03)
				If $Color[$p] = 0xD22325 Then $weiter[$p] = 1
				If $Color[$p] = 0xD22325 Then $weiter[0] = 1
			Next

;~ 			Sleep(200)

			For $p = 1 To $pmax
				For $c = 1 To 3
					If $PlayerWagen[$p][$c] = 0xFFFFFF Then $weiter[$p] = 1
					If $PlayerWagen[$p][$c] = 0xFFFFFF Then $weiter[0] = 1
				Next
				If $lose[$p] = 1 Then $weiter[$p] = 1
			Next

			If $weiter[0] = 0 Then ConsoleWrite("$Weiter[0]=0" & @CRLF)
			If $weiter[0] = 0 Then ExitLoop
			$weiter[0] = 1

			;alle $weiter = 1 ?
			$pass = True
			For $i = 0 To UBound($weiter) - 1
				if $weiter[$i] <> 1 Then $pass = False
				if $weiter[$i] <> 1 Then ConsoleWrite("Spieler " &$i  & " noch nicht" & @CRLF)
				if $weiter[$i] <> 1 Then ExitLoop
			Next
;~ 		ConsoleWrite("noch nicht" & @CRLF)
		Until $pass

		For $i = 0 To UBound($lose) - 1
			if $lose[$i] <> 1 Then $pass = False
			$Sum += $lose[$i]
		Next
		If $Sum = 8 Then ExitLoop
		$Sum = 0

		Local $weiter = InitArrayWithZeros($pmax + 1)

		$f = 0
;~ 		Sleep(1000)

		For $p = 1 To $pmax
;~ 			ConsoleWrite("Player " &$p & " lose " & $lose[$p] & @CRLF)
			$DiaLiga[$p] -= 1
		Next

		Local $hTimer = TimerInit()

		;Rundenschleife
		For $zaehler = 1 To 20
			If $zaehler = 1 Then ConsoleWrite("Runde ")
			ConsoleWrite($zaehler)
;~ 			ProgressOn("Progress Meter", "Gegner", "0 Gegner")
;~ 			ProgressSet($zaehler * 5, $zaehler & " Gegner")
;~ 			WinMove("Progress Meter", "", -346, 555)

			;Kampf starten
			For $c = 1 To 3
				For $p = 1 To $pmax
					If $lose[$p] = 1 Then ContinueLoop
					If $win[$p] >= 20 Then ContinueLoop
					; If $zaehler >= $Liga_exit[$p] Then ContinueLoop

					MouseClick("", $W_P[$p][1] + $iPosx03, $W_P[$p][2] + $iPosy03, 1, 0) ;Button Fortfahren
					Sleep(100) ;300 --> Niederlager falsch+
					MouseClick("", $W_P[$p][1] + 430, $W_P[$p][2] + 208, 1, 0) ;Ansehen

					If $punkten[$p] = 0 And $win[$p] > 17 Then   ;And $c = 1
						ConsoleWrite("P" & $p & " " & $win[$p] & @CRLF)
						Sleep(500)
						MouseClick("", $W_P[$p][1] + 55, $W_P[$p][2] + 444, 1, 1) ;Retour UL
						Sleep(2000)
						;neu 10.5.26
						$lose[$p] = 1
						ConsoleWrite(" --> P" & $p & " lose <-- ") ;ConsoleWrite("P-n " &$p &"-Niederlage ")
						MouseClick("", $W_P[$p][1] + $iPosx08, $W_P[$p][2] + $iPosy08, 1, 50)
						Sleep(2000)
						MouseClick("", $W_P[$p][1] + 430, $W_P[$p][2] + 425, 1, 50)
						Sleep(2000)
						;neu end
					EndIf
				Next
				If $c > 1 Then Sleep(1000) ;Wartezeit Kampfbeginn
			Next

			;Kampfergebniss ermitteln
			Local $seconds = 80

			Do
				$seconds -= 1
;~ 				ConsoleWrite($seconds & " ")
				For $p = 1 To $pmax
					If $win[$p] >= 20 Then ContinueLoop
					If $lose[$p] = 1 Then $weiter[$p] = 1
					If $lose[$p] = 1 Then ContinueLoop
					If $weiter[$p] = 1 Then ContinueLoop
					$Color[$p] = PixelGetColor($W_P[$p][1] + 18, $W_P[$p][2] + 25) ;Wagenenergie da?
					If $Color[$p] = 0xFFFFFF Then
						$ready[$p] = 0
;~ 						ConsoleWrite("P" &$p &" NOT!Ready ")
					Else
						$ready[$p] = 1
;~ 						ConsoleWrite("P" &$p &" Ready ")
					EndIf

					$Color[$p] = PixelGetColor($W_P[$p][1] + 430, $W_P[$p][2] + 455)
					$Color1[$p] = PixelGetColor($W_P[$p][1] + 288, $W_P[$p][2] + 288)

;~ 					ConsoleWrite("P" &$p & " " & Hex($Color[$p],6) & @CRLF)
					Sleep(200)
				Next

				For $p = 1 To $pmax
					If $weiter[$p] = 1 Then ContinueLoop

					;Sieg
					If $Color[$p] = 0xD22325 And $ready[$p] = 1 Then
;~ 							ConsoleWrite("P" &$p &" "Sieg & @CRLF)
;~ 							ConsoleWrite(" P" &$p)
						$win[$p] += 1
						MouseClick("", $W_P[$p][1] + 430, $W_P[$p][2] + 434, 1, 0) ;OK
						$weiter[$p] = 1
						Sleep(100)

						If $zaehler >= $Liga_exit[$p] Then
							Sleep(2000)	; 1000 --> 2000  (29.3.2026)
							MouseClick("", $W_P[$p][1] + $iPosx09, $W_P[$p][2] + $iPosy09, 1, 0) ;Liga verlassen
							Sleep(4000)
							ConsoleWrite(" P" & $p & " leave ")
;~ 							$lose[$P] = 1
							$win[$p] = 20
						EndIf

					EndIf

					;Niederlage
					If $Color1[$p] = 0xECDFD3 And $Color[$p] < 0x0C0000 And $ready[$p] = 1 Then

						$Color[$p] = PixelGetColor($W_P[$p][1] + 430, $W_P[$p][2] + 455)
						$Color1[$p] = PixelGetColor($W_P[$p][1] + 288, $W_P[$p][2] + 288)

						If $Color1[$p] = 0xECDFD3 And $Color[$p] < 0x0C0000 And $ready[$p] = 1 Then

;~ 							MouseMove($W_P[$p][1] + $iPosx08, $W_P[$p][2] + $iPosy08)
;~ 							Sleep(2000)
							ConsoleWrite(" --> P" & $p & " lose <-- ") ;ConsoleWrite("P-n " &$p &"-Niederlage ")
							MouseClick("", $W_P[$p][1] + $iPosx08, $W_P[$p][2] + $iPosy08, 1, 50)
							Sleep(2000)
							MouseClick("", $W_P[$p][1] + 430, $W_P[$p][2] + 425, 1, 50)
							Sleep(2000)
							$weiter[$p] = 1
							$lose[$p] = 1
							$win[$p] += 1

						Else
							ConsoleWrite(".N.")
						EndIf

					EndIf

					If $weiter[$p] = 1 And $lose[$p] = 0 Then MouseClick("", $W_P[$p][1] + $iPosx03, $W_P[$p][2] + $iPosy03, 1, 0) ;Button Fortfahren

				Next

;~ 					ConsoleWrite(@CRLF)
;~ 					ConsoleWrite(" " & $seconds & @CRLF)
				If $seconds = 40 Then
					ConsoleWrite("Sec 40!!")
					For $p = 1 To $pmax
						If $lose[$p] = 0 Then MouseClick("", $W_P[$p][1] + 430, $W_P[$p][2] + 208, 1, 0) ;Ansehen
					Next
				EndIf

				If $seconds = 5 Then
					For $p = 1 To $pmax
						If $lose[$p] = 0 And $weiter[$p] = 0 Then ConsoleWrite(_Now() & " lose " & $p & @CRLF)
						If $weiter[$p] = 0 Then $lose[$p] = 1
					Next
				EndIf

				If $seconds = 1 Then Exit ;fehler

				;wenn alle $weiter 1 sind dann...
				If _ArraySearch($weiter, 0, 1, $pmax) < 0 Then $seconds = -1

				;wenn alle $win 20 sind dann...
				For $p = 1 To $pmax
					If $win[$p] <> 20 Then ExitLoop
				Next
				If $p > $pmax Then $seconds = -1

			Until $seconds < 0

			Local $weiter = InitArrayWithZeros($pmax + 1)
			Local $ready = InitArrayWithZeros($pmax + 1)

			Sleep(500)

			;Auswertung
;~ 				ConsoleWrite("Auswertung" & @CRLF)
			For $p = 1 To $pmax
				If $lose[$p] = 1 Then ContinueLoop
				If $win[$p] < 20 Then
					$Color[$p] = PixelGetColor($W_P[$p][1] + 424, $W_P[$p][2] + 90)
;~ 					ConsoleWrite("--->P" &$p & " " & Hex($Color[$p],6) & @CRLF)
					If $Color[$p] = 0xE93A2D Then $win[$p] = 20
					If $Color[$p] = 0xE93A2D Then ConsoleWrite("P" & $p & " Wins=20" & @CRLF)
				EndIf
				If $win[$p] = 20 Then Sleep(1000)
				If $win[$p] = 20 Then MouseClick("", $W_P[$p][1] + 425, $W_P[$p][2] + 425, 1, 5) ;Herausforderung Erfüllt
				If $win[$p] = 20 Then $lose[$p] = 1
			Next

			If _ArraySearch($win, 20, 1, $pmax) > 0 Then Sleep(4000) ;nach 16 Runden fehler.... 5sek.

			For $p = 1 To $pmax
				If $win[$p] = 20 Then Sleep(1000)
				If $win[$p] = 20 Then MouseClick("", $W_P[$p][1] + 436, $W_P[$p][2] + 423, 1, 10) ;Liga
				If $win[$p] = 20 Then $weiter[$p] = 1
;~ 			if $win[$p] = 20 Then $win[$p] = 21
			Next

			If _ArraySearch($win, 20, 1, $pmax) > 0 Then Sleep(1000)
			If _ArraySearch($lose, 0, 1, $pmax) < 0 Then ExitLoop ; wenn keine 0 gefunden wird dann -1 --> also alle sind 1

		Next

		ProgressOff()

		Local $fDiff = TimerDiff($hTimer)
		$sektotal = Round(($fDiff / 1000), 0)
		$minutes = Floor($sektotal / 60)
		$sek = ($sektotal - ($minutes * 60))
		ConsoleWrite(@CRLF)
		ConsoleWrite($minutes & " Minuten " & $sek & " Sek." & "  Ticket: " & $Runden & "  " & $win[1] & "  " & $win[2] & "  " & $win[3] & "  " & $win[4] & " " & $win[5] & "  " & $win[6] & "  " & $win[7] & "  " & $win[8] & " " & @CRLF)

		$sIni = "Y:\cats.ini"
		$sData = @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & "-" & @MIN & "-" & @SEC & " " & $Runden & "  " & $win[1] & "  " & $win[2] & " " & $win[3] & " " & $win[4]
		IniWriteSection($sIni, @ComputerName, $sData)

		MsgBox($MB_SYSTEMMODAL, "Info", "Nächstes Ticket", 2)

		Local $weiter = InitArrayWithZeros($pmax + 1)
		Local $ready = InitArrayWithZeros($pmax + 1)
		Local $lose = InitArrayWithZeros($pmax + 1)
		Local $win = InitArrayWithZeros($pmax + 1)

		If $terminate = 1 Then ExitLoop
		If $Runden = $Runden_End Then ExitLoop
	WEnd

;~ 	Sleep(1000)
	GK_Screen()
	ConsoleWrite(_Now() & " Liga Ende" & @CRLF)

EndFunc   ;==>Ligakaempfe
