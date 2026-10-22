Func Piloten()
	ConsoleWrite(_NowTime() & " Piloen Start" & @CRLF)
	$sStartTime = _NowCalc()

	Local $a = 0, $b = 0, $c = 0, $d = 0, $e = 0, $f = 0, $g = 0, $h = 0, $i = 0

	For $p = 1 To $pmax
		If $skip[$p] = 1 Then ContinueLoop
		ConsoleWrite("P" & $p & @CRLF)

		Do
			$a = $a + 1
			MouseClick("", $W_P[$p][1] + 637, $W_P[$p][2] + 323, 1, 0) ;Tippen für Missionen
			Sleep(2000)
			$iColor11 = PixelGetColor($W_P[$p][1] + 424, $W_P[$p][2] + 388) ; Rot [Neu Laden]
			If $iColor11 = 0xD22325 Then
				ConsoleWrite("Rot")
				MouseClick("", $W_P[$p][1] + 424, $W_P[$p][2] + 388, 1, 0) ;Neu Laden
				Sleep(6000)
				MouseClick("", $W_P[$p][1] + 637, $W_P[$p][2] + 323, 1, 0) ;Tippen für Missionen
			Else
;~ 			ConsoleWrite("Nicht Rot")
			EndIf

			Do
				$b = $b + 1
				Do ; links or rechts runter
					$e = $e + 1

					If $e = 1 Then $f = 313 ;links
					If $e = 2 Then $f = 541 ;rechts
					$c = 174 ;oben (210 auf 185)
;~ 				$c = 451 				;Turbo zum testen

					Do ;runter
						$c = $c + 5 ; 8 geht nicht

						Local $iColor11 = PixelGetColor($W_P[$p][1] + $f, $W_P[$p][2] + $c) ; Y 140 bis 481 (oben bis unten)
;~ 					MouseMove($W_P[2][1] + $f, $W_P[2][2] + $c); ACHTUNG ZEIT-FRESSER +8Min
						If $iColor11 = 0x53A507 Then $d = 1 ;wenn Grün
						If $iColor11 = 0x53A507 Then ConsoleWrite(@CRLF & "Grün")
						If $iColor11 = 0xD22325 Then ;wenn Rot
							ConsoleWrite(@CRLF & "Rot+$d=1")
							MouseClick("", $W_P[$p][1] + $f, $W_P[$p][2] + $c + 5, 1, 0) ;Annehmen + Nehmen
							Local $iColor12 = PixelGetColor($W_P[$p][1] + $f + 88, $W_P[$p][2] + $c + 5) ; Grün neben Nehmen_Button ?
							If $iColor12 = 0x53A507 Then $d = 1 ;wenn Grün
							If $d = 1 Then $h += 1
							If $d = 1 Then ConsoleWrite(" nehmen ")
							Sleep(3 * 1000)
							If $d = 0 Then
								MouseClick("", $W_P[$p][1] + 424, $W_P[$p][2] + 445, 1, 0) ;Senden
								ConsoleWrite(" senden ")
								$i += 1
								$d = 0
								Sleep(3 * 1000)
							EndIf
;~ 						$c = 482
						EndIf

					Until $c > 481

					$d = 0

				Until $e = 2
;~ 		ConsoleWrite(@CRLF & @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & "-" & @MIN & "-" & @SEC & " Ende Co-Piloten" & @CRLF)

				$e = 0

				MouseMove($W_P[$p][1] + 431, $W_P[$p][2] + 469) ; unten Mitte
				MouseDown($MOUSE_CLICK_LEFT)
				Sleep(1000)
				MouseMove($W_P[$p][1] + 431, $W_P[$p][2] + 141, 30) ; nach oben
				MouseUp($MOUSE_CLICK_LEFT)
;~ ConsoleWrite("#3 a=" & $a & " b=" & $b & " c=" & $c & " d=" & $d & " e=" & $e & " f=" & $f & " g=" & $g & @CRLF)
			Until $b = 2 ;Anzahl Src up (def. 4)

			$b = 0
			MouseClick("", $W_P[$p][1] + 53, $W_P[$p][2] + 448, 1, 0) ;Unten links [Back]
			Sleep(3000)

;~ ConsoleWrite("#4 a=" & $a & " b=" & $b & " c=" & $c & " d=" & $d & " e=" & $e & " f=" & $f & " g=" & $g & @CRLF)
		Until $a = 1 ; Anzahl durchgänge pro Spieler (def. 2)

		ConsoleWrite($h & " nehmen " & $i & " senden ")
		Local $a = 0, $h = 0, $i = 0

	Next

	ConsoleWrite(@CRLF & @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & "-" & @MIN & "-" & @SEC & " Ende Co-Piloten" & @CRLF)

;~ 	$sEndTime = _NowCalc()
;~     $iDiffSecs = _DateDiff('s', $sStartTime, $sEndTime)
;~     ConsoleWrite("$ $sStartTime --> " & $sStartTime & @CRLF)
;~     ConsoleWrite("$ $sEndTime   --> " & $sEndTime & @CRLF)
;~     ConsoleWrite("> $iDiffSecs  --> " & $iDiffSecs & ' Sekunde' & ($iDiffSecs > 1 ? 'n' : '') & @CRLF)
EndFunc   ;==>Piloten
