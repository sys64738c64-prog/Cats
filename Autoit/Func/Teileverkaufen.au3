Func Teileverkaufen()

	; definition von Buttons --> Teile 5x Chassis, Waffe, Rad, Gadget, Tool ;
	Local $TVB = [[00, 000, 000], _ ;leer
			[01, 055, 447], _ ;Retour
			[02, 648, 027, "Chassis"], _ ;Chassis
			[03, 693, 027, "Waffen"], _ ;Waffen
			[04, 737, 027, "Räder"], _ ;Räder
			[05, 781, 027, "Gadget"], _ ;Gadget
			[06, 829, 027, "Tools"], _ ;Tools
			[07, 475, 320], _ ;Fz mitte
			[08, 229, 380], _ ;Info
			[09, 686, 088], _ ;Info X
			[10, 000, 000], _ ;leer
			[11, 470, 390], _ ;Verkaufen JA NEIN (Nein Rot)
			[12, 370, 390], _ ;Verkaufen JA NEIN (Ja Rot)
			[13, 041, 117], _ ;<<
			[14, 819, 117], _ ;>>
			[15, 150, 400], _ ;Stufe x Meisterschaft
			[16, 427, 427], _ ;Nehmen
			[17, 427, 408], _ ;Nehmen Spieler sind ausgestiegen 2 (+-35) 379 - 438 (360-460)
			[18, 427, 364], _ ;Nehmen
			[19, 660, 200], _ ;Karte
			[20, 660, 200], _ ;Karte
			[21, 041, 117], _ ;<<
			[22, 819, 117]] _ ;>>

	Local $TVS = [[00, 041, 117, 0], _ ;<<
			[01, 075, 117, 0], _ ;Solt 1
			[02, 213, 117, 0], _ ;Solt 2
			[03, 352, 117, 0], _ ;Solt 3
			[04, 490, 117, 0], _ ;Solt 4
			[05, 629, 117, 0], _ ;Solt 5
			[06, 768, 117, 0], _ ;Solt 6
			[07, 819, 117, 0], _ ;>>
			[08, 777, 444, 0], _ ;verkaufen UR
			[09, 005, 268, 0], _ ;Karte L
			[10, 850, 268, 0], _ ;Karte R
			[11, 819, 117, 0], _ ;>>
			[12, 819, 117, 0], _ ;>>
			[13, 819, 117, 0], _ ;>>
			[14, 777, 444, 0]] _ ;verkaufen UR

	Local $TVC = [[00, 000, 000, 0xD22325], _ ;Rot
			[01, 500, 364, 0xF29200], _ ;+120% (Gelb)
			[02, 500, 364, 0xF29200], _ ;
			[03, 000, 000, 0x000000], _ ;
			[04, 000, 000, 0x000000], _ ;
			[05, 000, 000, 0x000000], _ ;
			[06, 000, 000, 0x000000], _ ;
			[07, 000, 000, 0x000000], _ ;
			[08, 000, 000, 0x000000], _ ;
			[09, 000, 000, 0x000000]] _ ;leer

	Local $a = 0, $b = 0, $c = 0, $d = 0, $e = 0, $f = 0, $g = 0, $h = 0, $i = 0, $k = 0, $x = 0, $s_c = 1, $iColor1 = 0, $iColor2 = 0

	Local $Stufe = [[0, 10, 09, 0, 0, 0, 0, 0], _	 ;P,		Stufe akt,	Stufe sell,	Chassi,	Weapon, ...; 	5 Holz	10 Metall	15 Militär	 20 Gold
			[1, 11, 10, 1, 1, 1, 1, 0], _	 ;P1,	Holz weg, Chassi
			[2, 01, 00, 1, 1, 1, 1, 0], _	 ;P2,	Holz weg, Chassi
			[3, 09, 08, 1, 1, 1, 1, 0], _	 ;P3,	Holz weg, Chassi
			[4, 19, 18, 1, 1, 1, 1, 0]] ;P4,	Holz weg, Chassi

	;Stufe bestimmen
	For $p = 1 To $pmax
		If $Stufe[$p][3] + $Stufe[$p][4] + $Stufe[$p][5] + $Stufe[$p][6] + $Stufe[$p][7] = 0 Then $skip[$p] = 1
		If $skip[$p] = 1 Then ContinueLoop
;~ 		If $skip[$p] = 0 Then ContinueLoop ;Stufe bestimmen überspringen

;~ 		;Meisterschaft,Mitte.....,Karte,
		For $a = 15 To 19
			MouseClick("", $W_P[$p][1] + $TVB[$a][1], $W_P[$p][2] + $TVB[$a][2], 1, 5)
			$Color = PixelGetColor($W_P[$p][1] + 660, $W_P[$p][2] + 200)
			If $Color <> 0xD22325 Then MouseWheel($MOUSE_WHEEL_UP, 2) ;Scroolen zu Kisten
			If $Color <> 0xD22325 Then Sleep(3 * 1000)
;~ 		ConsoleWrite(@ScriptLineNumber & @CRLF)
		Next

		For $c = 1 To 4
			MouseClickDrag($MOUSE_CLICK_LEFT, $W_P[$p][1] + $TVS[9][1], $W_P[$p][2] + $TVS[9][2], $W_P[$p][1] + $TVS[10][1], $W_P[$p][2] + $TVS[10][2], 20)
			MouseMove($W_P[$p][1] + $TVS[9][1], $W_P[$p][2] + $TVS[9][2], 0)
			Sleep(500)
		Next

		;Rang analysieren
		Local $s = 0, $c = 0

		Do
			For $x = 50 To 670

				$Color = PixelGetColor($W_P[$p][1] + $x, $W_P[$p][2] + 268)
;~ 		 			MouseMove($W_P[$p][1] + $x, $W_P[$p][2] + 268); ACHTUNG ZEIT-FRESSER +8MinM
;~ 					ConsoleWrite($x & " " &Hex($Color, 6) & " " & $b & @CRLF)
				If $Color = 0xECDFD3 Then $c = $c + 1
				If $Color = 0xB10A0A Then $s = $s + 1
;~ 					if $Color = 0xB10A0A Then ConsoleWrite("Rang " & $s & "(" &$b &" " &$x &")"& @CRLF)
				If $Color = 0xB10A0A Then $x = $x + 140
				If $c = 40 Then $x = 1
				If $c = 40 Then ExitLoop
			Next

			If $x = 1 Then ExitLoop
			$c = 0
			$b = $b + 1
			MouseMove($W_P[$p][1] + 800, $W_P[$p][2] + 268, 0)
			If $b = 1 Then MouseClickDrag($MOUSE_CLICK_LEFT, $W_P[$p][1] + 800, $W_P[$p][2] + 268, $W_P[$p][1] + 220, $W_P[$p][2] + 268, 40)
			If $b > 1 Then MouseClickDrag($MOUSE_CLICK_LEFT, $W_P[$p][1] + 800, $W_P[$p][2] + 268, $W_P[$p][1] + 080, $W_P[$p][2] + 268, 40)

		Until $b = 5

		If $s < 6 Then $s = $s + 1
		MouseClick("", $W_P[$p][1] + 55, $W_P[$p][2] + 444, 1) ;Retour UL
		Sleep(2 * 1000)
		MouseClick("", $W_P[$p][1] + 55, $W_P[$p][2] + 444, 1) ;Retour UL
		ConsoleWrite("P" & $p & " Stufe " & $s & @CRLF)
		$Stufe[$p][1] = $s
		$Stufe[$p][2] = $Stufe[$p][1] - 1
	Next
	;Stufe bestimmen end

	Exit

;~ #cs

	;Teile verkaufen
	For $p = 1 To $pmax
		If $skip[$p] Then ContinueLoop
		ConsoleWrite(_NowTime() & " TV Start")

		$a = 7 ;FZ mitte
		MouseClick("", $W_P[$p][1] + $TVB[$a][1], $W_P[$p][2] + $TVB[$a][2], 1, 20)
;~ 		ConsoleWrite(@ScriptLineNumber & @CRLF)
		Sleep(3000)

		For $c = 3 To 7
			$e = 0
			;Kategorie wählen
			$a = $Stufe[$p][$c]
			ConsoleWrite(@CRLF & "P" & $p & " " & $TVB[$c - 1][3] & " ")
;~ 			ConsoleWrite("P" &$p &" " &$TVB[$c-1][3] & @CRLF)

			If $a = 0 Then ContinueLoop
			$a = $c - 1
			MouseClick("", $W_P[$p][1] + $TVB[$a][1], $W_P[$p][2] + $TVB[$a][2], 1, 20)

			$a = 13 ;<<
			MouseClick("", $W_P[$p][1] + $TVB[$a][1], $W_P[$p][2] + $TVB[$a][2], 1, 20)


			Do ;

				;Item Band analysieren
				Sleep(1000)
				Sleep(1000)
				Local $b = 0, $d = 0
				Local $TVSatus[5][2] = [[0, 0], [0, 0], [0, 0], [0, 0], [0, 0]] ;[$p][anz. solts full,weiter]

				For $x = 76 To 771 Step 139
					$d += 1
					$iColor1 = PixelGetColor($W_P[$p][1] + $x + 00, $W_P[$p][2] + 112) ;Sterne 1,3,5 	(3)
					$iColor2 = PixelGetColor($W_P[$p][1] + $x + 12, $W_P[$p][2] + 112) ;Sterne 2,4 	(4)
;~ 			 		MouseMove($W_P[$p][1] + $x, $W_P[$p][2] + 112); ACHTUNG ZEIT-FRESSER +8MinM
;~ 					ConsoleWrite($x & " " &Hex($iColor1, 6) & " " & $b & @CRLF)
;~ 					ConsoleWrite("Slot " &$d & " C1 " &Hex($iColor1, 6) & " " & $x+00 & @CRLF)
;~ 					ConsoleWrite("Slot " &$d & " C2 " &Hex($iColor2, 6) & " " & $x+12 & @CRLF)
;~ 					If StringLeft(Hex($iColor1, 6), 2) < "70" and StringLeft(Hex($iColor2, 6), 2) < "70" Then ConsoleWrite("Slot " &$c &" leer" & @CRLF)
;~ 					If StringLeft(Hex($iColor1, 6), 2) < "70" and StringLeft(Hex($iColor2, 6), 2) < "70" Then $TVSatus[$p][0] = $d
;~ 					If StringLeft(Hex($iColor1, 6), 2) > "75" or StringLeft(Hex($iColor2, 6), 2) > "75" Then ConsoleWrite("Slot" &$d &" full" & @CRLF)
					If StringLeft(Hex($iColor1, 6), 2) > "75" Or StringLeft(Hex($iColor2, 6), 2) > "75" Then $TVSatus[$p][0] = $d
				Next
;~ 				ConsoleWrite("Status Band:" &$TVSatus[$p][0] & @CRLF)

;~ 				If $TVSatus[$p][0] < 6 Then $TVSatus[$p][1] = 1 ;kein nach links schieben...
				;Item Band analysieren end


				Sleep(1 * 1000)
				$s_c = 1

				Do ;Slot 1...6
					$e += 1
					ConsoleWrite($e & "-")

					$s = -2
					$a = $s_c ;Slot x
					MouseClick("", $W_P[$p][1] + $TVS[$a][1], $W_P[$p][2] + $TVS[$a][2], 1, 5)
					Sleep(1 * 500)

					$a = 8 ;info
					MouseClick("", $W_P[$p][1] + $TVB[$a][1], $W_P[$p][2] + $TVB[$a][2], 1, 5)
					Sleep(1 * 500)
;~ #ce
;~ $p = 1
;~ $s = -2
					;Sterne analysieren 152  E3D8C7        509-535  538-565  567-594  596-625  627-653
					$b = 0
					For $x = 656 To 508 Step -1
						$iColor2 = $iColor1
						$iColor1 = PixelGetColor($W_P[$p][1] + $x, $W_P[$p][2] + 152)
;~ 			 			MouseMove($W_P[$p][1] + $x, $W_P[$p][2] + 152); ACHTUNG ZEIT-FRESSER +8MinM
						If $iColor2 = $iColor1 And $iColor1 = 0xE3D8C7 Then $x -= 30
;~ 						if $iColor2 <> $iColor1 Then ConsoleWrite($x & " " &Hex($iColor1, 6) & " " & $b & @CRLF)
;~ 						ConsoleWrite($x & " " &Hex($iColor1, 6) & " " & $b & @CRLF)

						If StringLeft(Hex($iColor1, 6), 4) = "FEB5" Then $s = 0 ;Holz
						If StringRight(Hex($iColor1, 6), 3) = "DDA" Then $s = 4 ;Metal
						If StringRight(Hex($iColor1, 6), 3) = "410" Then $s = 9 ;Militär
						If StringRight(Hex($iColor1, 6), 4) = "FF62" Then $s = 14 ;Gold
						If StringRight(Hex($iColor1, 6), 3) = "E69" Then $s = 19 ;Karbon
						If $s > -2 Then ExitLoop
					Next

					;Sterne auswerten
					If $x > 630 Then
						$s += 5
					ElseIf $x > 610 Then
						$s += 4
					ElseIf $x > 570 Then
						$s += 3
					ElseIf $x > 540 Then
						$s += 2
					ElseIf $x > 510 Then
						$s += 1 ; Optional: Kann weggelassen werden, da +0 keine Änderung bewirkt
					ElseIf $x < 510 Then
						ConsoleWrite(" noStar ")
						$s_c += 1 ;$s_c = 6 ;versuch mit +1 21.4.25
						$b = 1
;~ 						Exit
;~ 						ExitLoop
					EndIf

;~ 					ConsoleWrite("-->" &$s &"<--")
					ConsoleWrite($s)
;~ Exit
;~ #cs
					$a = 9 ;info x
					MouseClick("", $W_P[$p][1] + $TVB[$a][1], $W_P[$p][2] + $TVB[$a][2], 1, 5)
					Sleep(1000)

					;slot x verkaufen
					If $s < $Stufe[$p][2] And $b = 0 Then
;~ 						ConsoleWrite("Slot " & $s_c & " verkaufen ")
						ConsoleWrite("x")
						MouseMove($W_P[$p][1] + $TVS[$s_c][1], $W_P[$p][2] + $TVS[$s_c][2])
						MouseDown($MOUSE_CLICK_LEFT)
						MouseMove($W_P[$p][1] + $TVS[$s_c][1], $W_P[$p][2] + $TVS[$s_c][2] + 60) ;min 53
						MouseMove($W_P[$p][1] + $TVS[8][1], $W_P[$p][2] + $TVS[8][2])
						MouseUp($MOUSE_CLICK_LEFT)
						Sleep(1000)
						;120% nicht verkaufen
						$a = 12 ;11 = Nein ;12 = Ja ;(Verkaufen)
						$iColor1 = PixelGetColor($W_P[$p][1] + $TVB[$a][1], $W_P[$p][2] + $TVB[$a][2])
						If $iColor1 = $TVC[0][3] Then
							If $a = 11 Then ConsoleWrite("So nöd 120% ")
							MouseClick("", $W_P[$p][1] + $TVB[$a][1], $W_P[$p][2] + $TVB[$a][2], 1, 5)
;~ 				$slot[$s_c] = 1
							If $a = 11 Then $s_c += 1
						EndIf

					Else
;~ 						ConsoleWrite("Slot " & $s_c & " behalten ")
						ConsoleWrite(".")
;~ 					$slot[$s_c] = 1
						$s_c += 1
						$d = 0
						$b = 0

					EndIf


					Sleep(100)
;~ 					ConsoleWrite(@CRLF)
				Until $s_c > $TVSatus[$p][0]
				$d = 0
;~ 				ConsoleWrite("Until $s_c erreicht" & @CRLF)

				;Moving 6....1

				If $TVSatus[$p][0] < 6 Then ExitLoop
				Sleep(1000)
				$Color[1] = PixelGetColor($W_P[$p][1] + 75, $W_P[$p][2] + 95)
				$Color[2] = PixelGetColor($W_P[$p][1] + 77, $W_P[$p][2] + 95)
				$Color[3] = PixelGetColor($W_P[$p][1] + 79, $W_P[$p][2] + 95)
				MouseClickDrag($MOUSE_CLICK_LEFT, $W_P[$p][1] + $TVS[6][1], $W_P[$p][2] + $TVS[6][2], $W_P[$p][1] + $TVS[1][1], $W_P[$p][2] + $TVS[1][2], 40)
				Sleep(1000)
				$Color[4] = PixelGetColor($W_P[$p][1] + 75, $W_P[$p][2] + 95)
				$Color[5] = PixelGetColor($W_P[$p][1] + 77, $W_P[$p][2] + 95)
				$Color[6] = PixelGetColor($W_P[$p][1] + 79, $W_P[$p][2] + 95)

				If $Color[1] = $Color[4] Then $d += 1
				If $Color[2] = $Color[5] Then $d += 1
				If $Color[3] = $Color[6] Then $d += 1
				If $d = 3 Then
					ConsoleWrite(" Ja ist gleich ")
					$TVSatus[$p][1] = 1
				EndIf
				$d = 0

			Until $TVSatus[$p][1] = 1
;~ 			ConsoleWrite(@CRLF)
		Next

		MouseClick("", $W_P[$p][1] + 55, $W_P[$p][2] + 444, 1, 1) ;Retour UL

		Sleep(2 * 1000)

		ConsoleWrite(_NowTime() & " TV End P" & $p & @CRLF)

	Next

;~ #ce

EndFunc   ;==>Teileverkaufen
