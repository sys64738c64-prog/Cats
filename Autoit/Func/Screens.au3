Func Liga_Screen()
EndFunc

Func KDS_Screen()
EndFunc

Func GK_Screen()
EndFunc


; ============================================================
; SCREEN-WECHSELSYSTEM
; 5 Screens, Pixel-Erkennung und frei kombinierbare Mausklicks
; ============================================================

Global $Toleranz = 2

; ------------------------------------------------------------
; 1. SCREENS
; Aufbau: [Screen][0] Name
;                  [1] Pixel-X
;                  [2] Pixel-Y
;                  [3] Erkennungsfarbe
; ------------------------------------------------------------

Global $Screens[6][4]

$Screens[1][0] = "Rot" ;Retour unten links
$Screens[1][1] = 037
$Screens[1][2] = 437
$Screens[1][3] = 0xD22325

$Screens[2][0] = "Home" ;Gelb oben links
$Screens[2][1] = 78
$Screens[2][2] = 28
$Screens[2][3] = 0xEC5800

$Screens[3][0] = "Liga" ;Violett oben links
$Screens[3][1] = 78
$Screens[3][2] = 28
$Screens[3][3] = 0x4D419B

$Screens[4][0] = "KDS" ;Rot oberhalb Pokal rechts
$Screens[4][1] = 825
$Screens[4][2] = 65
$Screens[4][3] = 0x9E2523

; ------------------------------------------------------------
; 2. MAUSKLICK-POSITIONEN - Button_Position
; Alle Koordinaten relativ zum jeweiligen Fenster
; ##, PosX, PosY, Func
; ------------------------------------------------------------

Global $B_P = [[000, 051, 447, "Back"], _
			[001, 051, 447, "Back unten links"], _
			[002, 818, 326, "Pfeil nach Oben/Unten"], _
			[003, 766, 030, "KDS"], _ ;oben rechts
			[004, 818, 326, "leer"], _
			[005, 818, 326, "leer"], _
			[009, 000, 000, "END"]]

; ------------------------------------------------------------
; 3. WECHSEL-ABLAEUFE
; [AusgangsScreen][ZielScreen][Schritt]
;
; 0 = Ende der Klickfolge
; ------------------------------------------------------------

Global $Wechsel[5][5][5]

; Home -> Liga
$Wechsel[2][3][0] = 2

; Liga -> Home
$Wechsel[3][2][0] = 2

; Home -> KDS
$Wechsel[2][4][0] = 3

; Anywhere -> Home
$Wechsel[4][1][0] = 1
$Wechsel[4][1][1] = 1
$Wechsel[4][1][2] = 1

; ------------------------------------------------------------
; 4. SCREEN ERKENNEN
; ------------------------------------------------------------

Func Screen_Erkennen($p)

    Local $Versuch = 0

    While $Versuch < 3

        $Versuch += 1

        For $s = 1 To 4

            Local $X = $W_P[$p][1] + $Screens[$s][1]
            Local $Y = $W_P[$p][2] + $Screens[$s][2]

            Local $Farbe = PixelGetColor($X, $Y)

            ;MouseMove($X, $Y)
            ;Sleep(2000)

            ConsoleWrite("P" & $p & _
                " Versuch: " & $Versuch & _
                " Screen: " & $Screens[$s][0] & _
                " Pos: " & $Screens[$s][1] & " " & $Screens[$s][2] & _
                " Farbe: " & Hex($Farbe, 6) & @CRLF)

            If FarbePasst($Farbe, $Screens[$s][3], $Toleranz) Then

				if $s = 1 Then
					MouseClick("", $W_P[$p][1] + $B_P[1][1], $W_P[$p][2] + $B_P[1][2], 1, 5)
					Sleep(1000)
				EndIf

                ConsoleWrite("P" & $p & _
                    " Screen erkannt: " & $Screens[$s][0] & _
                    " Farbe: " & Hex($Farbe, 6) & @CRLF)

                if $s <>1 Then Return $s

            EndIf

        Next

        ConsoleWrite("P" & $p & " Screen nicht erkannt! Versuch " & $Versuch & " von 3" & @CRLF)
        ConsoleWrite("P" & $p & " Back unten links" & @CRLF)
        MouseClick("", $W_P[$p][1] + $B_P[1][1], $W_P[$p][2] + $B_P[1][2], 1, 5)
        If $Versuch < 3 Then Sleep(1000)
		MouseClick("", $W_P[$p][1] + $B_P[1][1], $W_P[$p][2] + $B_P[1][2], 1, 5)
		If $Versuch < 3 Then Sleep(1000)


    WEnd

    ConsoleWrite("P" & $p & _
        " Screen nach 3 Versuchen nicht erkannt. Funktion beendet." & @CRLF)

    Return 0

EndFunc ;==>Screen_Erkennen


; ------------------------------------------------------------
; 5. MAUSKLICK NACH NUMMER
; ------------------------------------------------------------

Func MouseClick_Nummer($p, $Nummer)

    If $Nummer < 1 Or $Nummer > 5 Then Return

    Local $X = $W_P[$p][1] + $B_P[$Nummer][1]
    Local $Y = $W_P[$p][2] + $B_P[$Nummer][2]

    ConsoleWrite("P" & $p & " MouseClick " & $Nummer & " X=" &  $B_P[$Nummer][1] & " Y=" &  $B_P[$Nummer][2] & @CRLF)
;~ 	ConsoleWrite("P" & $p & " MouseClick " & $Nummer & " X=" & $X & " Y=" & $Y & @CRLF)

    MouseClick("", $X, $Y, 1, 5)

EndFunc ;==>MouseClick_Nummer


; ------------------------------------------------------------
; 6. SCREEN WECHSELN
; ------------------------------------------------------------

Func Screen_Wechseln($ZielScreen, $NurP = 0)

	If $ZielScreen < 1 Or $ZielScreen > 5 Then Return

	For $p = 1 To $pmax

    ; Wenn ein bestimmter Spieler angegeben wurde,
    ; alle anderen überspringen
    If $NurP <> 0 And $p <> $NurP Then ContinueLoop

    ; Übersprungene Spieler weiterhin berücksichtigen
    If $skip[$p] = 1 Then ContinueLoop


        ; Ausgangs-Screen erkennen
        Local $AktuellerScreen = Screen_Erkennen($p)

        If $AktuellerScreen = 0 Then ContinueLoop

        ConsoleWrite("P" & $p & ": " & _
            $Screens[$AktuellerScreen][0] & " -> " & _
            $Screens[$ZielScreen][0] & @CRLF)

        ; Bereits am Ziel?
        If $AktuellerScreen = $ZielScreen Then
            ConsoleWrite("P" & $p & ": Bereits im Ziel-Screen." & @CRLF)
            ContinueLoop
        EndIf

        ; Klickfolge aus dem Array auslesen
        For $i = 0 To 4

            Local $Nummer = $Wechsel[$AktuellerScreen][$ZielScreen][$i]

            If $Nummer = 0 Then ExitLoop

            MouseClick_Nummer($p, $Nummer)

            ; 2 Sekunden Pause zwischen Klicks
            If $i < 4 And _
                $Wechsel[$AktuellerScreen][$ZielScreen][$i + 1] <> 0 Then
                Sleep(2000)
            EndIf

        Next

        Sleep(4000)

        ; Ergebnis prüfen
        Local $NeuerScreen = Screen_Erkennen($p)

        If $NeuerScreen = $ZielScreen Then
            ConsoleWrite("P" & $p & ": Wechsel erfolgreich!" & @CRLF)
        Else
            ConsoleWrite("P" & $p & ": Ziel nicht bestaetigt!" & @CRLF)
        EndIf

    Next

EndFunc ;==>Screen_Wechseln


; ------------------------------------------------------------
; 7. FARBVERGLEICH MIT TOLERANZ
; ------------------------------------------------------------

Func FarbePasst($Farbe, $Ziel, $Toleranz)

    Local $r1 = BitAND(BitShift($Farbe, 16), 0xFF)
    Local $g1 = BitAND(BitShift($Farbe, 8), 0xFF)
    Local $b1 = BitAND($Farbe, 0xFF)

    Local $r2 = BitAND(BitShift($Ziel, 16), 0xFF)
    Local $g2 = BitAND(BitShift($Ziel, 8), 0xFF)
    Local $b2 = BitAND($Ziel, 0xFF)

    Return (Abs($r1 - $r2) <= $Toleranz And _
            Abs($g1 - $g2) <= $Toleranz And _
            Abs($b1 - $b2) <= $Toleranz)

EndFunc ;==>FarbePasst
