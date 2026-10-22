Func AuswahlButtons()
	Local $msg
	Local $breite = 130
	Local $hoehe = 30
	Local $hoehe_cfg = 15
	Local $abstand = 10
	Local $fensterBreite = 450
	Local $fensterHoehe = 260

	GUICreate("MEmu C.A.T.S", $fensterBreite, $fensterHoehe, 1200, 560)
	Opt("GUICoordMode", 1)

	; Hauptgruppe: Kämpfe und Kisten
	GUICtrlCreateGroup("Kämpfe und Kisten", ($abstand * 2) - 10, $abstand * 2, $breite * 2 + $abstand * 3, 6 * 37)

	; Spalte 1 - Hauptfunktionen
	Local $start_y = 2 * $abstand + 20
	Local $button_spacing = 28 ; Abstand für Buttons
	Local $checkbox_spacing = 15 ; Reduzierter Abstand für Checkboxen

	$Button_01 = GUICtrlCreateButton("Ligakämpfe", 2 * $abstand, $start_y, $breite, $hoehe)
	$Button_02 = GUICtrlCreateButton("Gangkämpfe", 2 * $abstand, $start_y + $button_spacing, $breite, $hoehe)
	$Button_03 = GUICtrlCreateButton("Steevys Kisten holen", 2 * $abstand, $start_y + $button_spacing * 2, $breite, $hoehe)
	$Button_04 = GUICtrlCreateButton("Kisten holen", 2 * $abstand, $start_y + $button_spacing * 3, $breite, $hoehe)
	$Button_05 = GUICtrlCreateButton("Teile verkaufen", 2 * $abstand, $start_y + $button_spacing * 4, $breite, $hoehe)
	$Button_11 = GUICtrlCreateButton("Windows positionieren", 2 * $abstand, $start_y + $button_spacing * 5, $breite, $hoehe)

	; Spalte 2 - Zusatzfunktionen
	Local $spalte2_x = 2 * $abstand + $breite + $abstand
	$Button_06 = GUICtrlCreateButton("AS", $spalte2_x, $start_y, $breite, $hoehe)
	$Button_07 = GUICtrlCreateButton("GP", $spalte2_x, $start_y + $button_spacing, $breite, $hoehe)
	$Button_08 = GUICtrlCreateButton("TL", $spalte2_x, $start_y + $button_spacing * 2, $breite, $hoehe)
	$Button_09 = GUICtrlCreateButton("Test 1", $spalte2_x, $start_y + $button_spacing * 3, $breite, $hoehe)
	$Button_13 = GUICtrlCreateButton("Test 2", $spalte2_x, $start_y + $button_spacing * 4, $breite, $hoehe)
	$Button_14 = GUICtrlCreateButton("KDS_Scan_KeM", $spalte2_x, $start_y + $button_spacing * 5, $breite, $hoehe)
	$Button_10 = GUICtrlCreateButton("Piloten", 2 * $abstand, $start_y + $button_spacing * 6, $breite, $hoehe)
	$Button_12 = GUICtrlCreateButton("EXIT", $spalte2_x, $start_y + $button_spacing * 6, $breite, $hoehe)

	GUICtrlCreateGroup("", -99, -99, 1, 1)

	; Einstellungen rechts
	GUICtrlCreateGroup("Einstellungen", $breite * 2 + $abstand * 5, $abstand * 2, $breite, 250)

	Local $cb_y = $start_y
	$Button_P1Skip = GUICtrlCreateCheckbox("P1 " & $W_P[1][0], $breite * 2 + $abstand * 6, $cb_y, $breite - 20, $hoehe_cfg)
	If $skip[1] = 0 Then GUICtrlSetState($Button_P1Skip, $GUI_CHECKED)
	$Button_P2Skip = GUICtrlCreateCheckbox("P2 " & $W_P[2][0], $breite * 2 + $abstand * 6, $cb_y + $checkbox_spacing, $breite - 20, $hoehe_cfg)
	If $skip[2] = 0 Then GUICtrlSetState($Button_P2Skip, $GUI_CHECKED)
	$Button_P3Skip = GUICtrlCreateCheckbox("P3 " & $W_P[3][0], $breite * 2 + $abstand * 6, $cb_y + 2 * $checkbox_spacing, $breite - 20, $hoehe_cfg)
	If $skip[3] = 0 Then GUICtrlSetState($Button_P3Skip, $GUI_CHECKED)
	$Button_P4Skip = GUICtrlCreateCheckbox("P4 " & $W_P[4][0], $breite * 2 + $abstand * 6, $cb_y + 3 * $checkbox_spacing, $breite - 20, $hoehe_cfg)
	If $skip[4] = 0 Then GUICtrlSetState($Button_P4Skip, $GUI_CHECKED)
	$Button_P5Skip = GUICtrlCreateCheckbox("P5 " & $W_P[5][0], $breite * 2 + $abstand * 6, $cb_y + 4 * $checkbox_spacing, $breite - 20, $hoehe_cfg)
	If $skip[5] = 0 Then GUICtrlSetState($Button_P5Skip, $GUI_CHECKED)
	$Button_P6Skip = GUICtrlCreateCheckbox("P6 " & $W_P[6][0], $breite * 2 + $abstand * 6, $cb_y + 5 * $checkbox_spacing, $breite - 20, $hoehe_cfg)
	If $skip[6] = 0 Then GUICtrlSetState($Button_P6Skip, $GUI_CHECKED)
	$Button_P7Skip = GUICtrlCreateCheckbox("P7 " & $W_P[7][0], $breite * 2 + $abstand * 6, $cb_y + 6 * $checkbox_spacing, $breite - 20, $hoehe_cfg)
	If $skip[7] = 0 Then GUICtrlSetState($Button_P7Skip, $GUI_CHECKED)
	$Button_P8Skip = GUICtrlCreateCheckbox("P8 " & $W_P[8][0], $breite * 2 + $abstand * 6, $cb_y + 7 * $checkbox_spacing, $breite - 20, $hoehe_cfg)
	If $skip[8] = 0 Then GUICtrlSetState($Button_P8Skip, $GUI_CHECKED)
	$Button_Timer = GUICtrlCreateCheckbox("Timer aktivieren", $breite * 2 + $abstand * 6, $cb_y + 8 * $checkbox_spacing, $breite, $hoehe_cfg)
	If $timer = 1 Then GUICtrlSetState($Button_Timer, $GUI_CHECKED)
	$Button_Scan = GUICtrlCreateCheckbox("Scan", $breite * 2 + $abstand * 6, $cb_y + 9 * $checkbox_spacing, $breite, $hoehe_cfg)
	If $scan = 1 Then GUICtrlSetState($Button_Scan, $GUI_CHECKED)

	; Kisten holen Optionen
	Local $kisten_label_y = $cb_y + 10 * $checkbox_spacing
	GUICtrlCreateLabel("Kisten holen:", $breite * 2 + $abstand * 6, $kisten_label_y, $breite - 20, $hoehe_cfg)
	$Button_KistenOption1 = GUICtrlCreateCheckbox("Kein Duell", $breite * 2 + $abstand * 6, $kisten_label_y + $checkbox_spacing, $breite - 20, $hoehe_cfg)
	If $kisten_option1 = 1 Then GUICtrlSetState($Button_KistenOption1, $GUI_CHECKED)
	$Button_KistenOption2 = GUICtrlCreateCheckbox("keine Kisten aktivieren", $breite * 2 + $abstand * 6, $kisten_label_y + 2 * $checkbox_spacing, $breite - 20, $hoehe_cfg)
	If $kisten_option2 = 1 Then GUICtrlSetState($Button_KistenOption2, $GUI_CHECKED)
	$Button_KistenOption3 = GUICtrlCreateCheckbox("keine Kisten holen", $breite * 2 + $abstand * 6, $kisten_label_y + 3 * $checkbox_spacing, $breite - 20, $hoehe_cfg)
	If $kisten_option3 = 1 Then GUICtrlSetState($Button_KistenOption3, $GUI_CHECKED)

	GUICtrlCreateGroup("", -99, -99, 1, 1)

	GUISetState()

	While 1
		$msg = GUIGetMsg()
		Select
			Case $msg = $GUI_EVENT_CLOSE
				ExitLoop

				; Button-Handling
			Case $msg = $Button_01
				Ligakaempfe()
			Case $msg = $Button_02
				Gangkaempfe()
			Case $msg = $Button_03
				SteevysKisten()
			Case $msg = $Button_04
				Kistenholen()
			Case $msg = $Button_05
				Teileverkaufen()
			Case $msg = $Button_06
				AllStars()
			Case $msg = $Button_07
				GrandPrix()
			Case $msg = $Button_08
				Teilelauf()
			Case $msg = $Button_09
				Test1()
			Case $msg = $Button_13
				Test2()
			Case $msg = $Button_14
				KDS_Scan(1, "KILLEMALL") ; Spieler, [Gangparameter in Python]
			Case $msg = $Button_10
				Piloten()
			Case $msg = $Button_11
				WindowsPositionieren()
			Case $msg = $Button_12
				_Exit()

				; Checkbox-Handling
			Case $msg = $Button_Timer
				$timer = (GUICtrlRead($Button_Timer) = $GUI_CHECKED) ? 1 : 0
				ConsoleWrite("Timer --> " & $timer & @CRLF)
			Case $msg = $Button_Scan
				$scan = (GUICtrlRead($Button_Scan) = $GUI_CHECKED) ? 1 : 0
				ConsoleWrite("Scan --> " & $scan & @CRLF)
			Case $msg = $Button_P1Skip
				$skip[1] = (GUICtrlRead($Button_P1Skip) = $GUI_CHECKED) ? 0 : 1
				ConsoleWrite("P1 Skip --> " & $skip[1] & @CRLF)
			Case $msg = $Button_P2Skip
				$skip[2] = (GUICtrlRead($Button_P2Skip) = $GUI_CHECKED) ? 0 : 1
				ConsoleWrite("P2 Skip --> " & $skip[2] & @CRLF)
			Case $msg = $Button_P3Skip
				$skip[3] = (GUICtrlRead($Button_P3Skip) = $GUI_CHECKED) ? 0 : 1
				ConsoleWrite("P3 Skip --> " & $skip[3] & @CRLF)
			Case $msg = $Button_P4Skip
				$skip[4] = (GUICtrlRead($Button_P4Skip) = $GUI_CHECKED) ? 0 : 1
				ConsoleWrite("P4 Skip --> " & $skip[4] & @CRLF)
			Case $msg = $Button_P5Skip
				$skip[5] = (GUICtrlRead($Button_P5Skip) = $GUI_CHECKED) ? 0 : 1
				ConsoleWrite("P5 Skip --> " & $skip[5] & @CRLF)
			Case $msg = $Button_P6Skip
				$skip[6] = (GUICtrlRead($Button_P6Skip) = $GUI_CHECKED) ? 0 : 1
				ConsoleWrite("P6 Skip --> " & $skip[6] & @CRLF)
			Case $msg = $Button_P7Skip
				$skip[7] = (GUICtrlRead($Button_P7Skip) = $GUI_CHECKED) ? 0 : 1
				ConsoleWrite("P7 Skip --> " & $skip[7] & @CRLF)
			Case $msg = $Button_P8Skip
				$skip[8] = (GUICtrlRead($Button_P8Skip) = $GUI_CHECKED) ? 0 : 1
				ConsoleWrite("P8 Skip --> " & $skip[8] & @CRLF)
			Case $msg = $Button_KistenOption1
				$kisten_option1 = (GUICtrlRead($Button_KistenOption1) = $GUI_CHECKED) ? 1 : 0
			Case $msg = $Button_KistenOption2
				$kisten_option2 = (GUICtrlRead($Button_KistenOption2) = $GUI_CHECKED) ? 1 : 0
			Case $msg = $Button_KistenOption3
				$kisten_option3 = (GUICtrlRead($Button_KistenOption3) = $GUI_CHECKED) ? 1 : 0
		EndSelect

;~ 		Zeitgesteuerte Aktionen

;~ 		If $timer = 1 And @HOUR & ":" & @MIN & ":" & @SEC = "01:00:00" Then AllStars()
;~		If @HOUR & ":" & @MIN & ":" & @SEC = "01:10:00" Then AllStars()
;~		If @HOUR & ":" & @MIN & ":" & @SEC = "05:00:00" Then AllStars()
;~ 		If $timer = 1 And @MIN&":"&@SEC = "00:00" Then Kistenholen()
;~  	If $timer = 1 And @MIN&":"&@SEC = "30:00" Then Kistenholen()

		If $timer = 1 And @SEC == "00" And Mod(@MIN, 5) == 0 Then
			Teilelauf()
			If $scan = 1 Then Sleep(30*1000) ; Prevents duplicate runs in the same minute
			If $scan = 1 Then KDS_Scan(1, "KILLEMALL")
			If $scan = 1 Then Sleep(20*1000)
			;If $scan = 1 And @MIN > "50" Then KDS_Scan_KeM()
			Sleep(5000)
		EndIf

;		Scan ausschalten
;~ 		If $scan = 1 And $timer = 0 And @HOUR = 03 And @MIN >= 01 And @MIN <= 11 Then $scan = 0

		If $scan = 1 And $timer = 0 And @SEC == "00" And Mod(@MIN, 10) == 0 Then
			KDS_Scan(1, "KILLEMALL")
			Sleep(1000) ; Prevents duplicate runs in the same minute
		EndIf

;~ 		If $scan = 21 And $scando = 0 Then
;~ 			RunWait("python.exe Y:\RKM1\Discord.bot.ein.py")
;~ 			$scando = 1
;~ 		EndIf
;~ 		If $scan = 0 And $scando = 1 Then
;~ 			RunWait("python.exe Y:\RKM1\Discord.bot.aus.py")
;~ 			$scando = 0
;~ 		EndIf

	WEnd
EndFunc   ;==>AuswahlButtons
