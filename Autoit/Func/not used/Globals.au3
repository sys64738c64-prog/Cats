Global $P_Name = [[0, "(leer)"], _
		[1, "Tigy"], _
		[2, "Sigy"], _
		[3, "Stefan"], _
		[4, "Wiederda"], _
		[5, "leer"], _
		[6, "leer"], _
		[7, "leer"], _
		[8, "leer"]] _

#comments-start
		[8, "Wiederda"], _
		[8, "Rigy"], _
		[8, "Uigy"], _

#comments-end

Local $iRows = UBound($P_Name)

Global $Win_Pos[9][7] = [[0, 0000, 0000, 000, 000, 0000, 0000], _
		[1, -1920, 0000, 899, 517, -1920, 0032], _
		[2, -1021, 0000, 899, 517, -1021, 0032], _
		[3, -1920, 0517, 899, 517, -1920, 0549], _
		[4, -1021, 0517, 899, 517, -1021, 0549], _
		[5, 0000, 0000, 899, 517, 0000, 0032], _
		[6, 0899, 0000, 899, 517, 0899, 0032], _
		[7, 0000, 0517, 899, 517, 0000, 0549], _
		[8, 0899, 0517, 899, 517, 0899, 0549]]

; Mapping von ID zu Position in $P_Name erstellen
Global $ID_To_Index[$iRows+1]

For $i = 0 To UBound($P_Name) - 1
	$id = $P_Name[$i][0]
	$ID_To_Index[$id] = $i
Next


; $W_P dynamisch erstellen - jetzt in der Reihenfolge der IDs 1-8
Global $W_P[9][3]
For $i = 0 To 8
	$id = $i ; ID entspricht dem Index
	$index_in_p_name = $ID_To_Index[$id]

	$W_P[$i][0] = $P_Name[$index_in_p_name][1] ; Name
	$W_P[$i][1] = $Win_Pos[$id][5] ; X-Position
	$W_P[$i][2] = $Win_Pos[$id][6] ; Y-Position
Next
;~ WinMove("(" & $W_P[$p][0] & ")", "", $W_P[$p][1], $W_P[$p][2], 899, 517)

Global $pmax = 8
Global $a = 0, $b = 0, $c = 0, $d = 0, $e = 0, $f = 0, $l = 0, $x = 0

Global $iColor[20]
Global $Color[20]
Global $Color1[$pmax + 1]
Global $Color2[$pmax + 1]
Global $Color3[$pmax + 1]
Global $Color4[$pmax + 1]

Global $Paused
Global $limit = 0
Global $wait = 0
Global $terminate = 0
Global $sleep = 0

Global $iPosx01 = 415, $iPosy01 = 415 ;Liga Sieg oder Niederlage [OK] äöü
Global $iPosx02 = 816, $iPosy02 = 317 ;Hauptscreen oder Ligascreen
Global $iPosx03 = 660, $iPosy03 = 408 ;Liga Herausforderung [Fortfahren]
Global $iPosx04 = 040, $iPosy04 = 027 ;Einkaufswagen
Global $iPosx05 = 080, $iPosy05 = 090 ;Einkaufswagen Symbol oberstes
Global $iPosx06 = 525, $iPosy06 = 350 ;STEEVYS KISTE 50, 100, 200
Global $iPosx07 = 277, $iPosy07 = 089 ;BonusKisten Ansehen oben links	0xECDFD3
Global $iPosx08 = 606, $iPosy08 = 125 ;Liga Niederlage X (oben rechts)
Global $iPosx09 = 190, $iPosy09 = 430 ;Liga Sieg Beenden (unten rechts)

Global $AS_Pos_E[5][7] = [[0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0]] ;6 Linien Full

Global $p[$pmax + 1] ;Liag, GK, AS
Global $win[$pmax + 1] ;Liag, GK, AS
Global $lose[$pmax + 1] ;Liag, GK, AS
Global $skip[$pmax + 1] = [1, 0, 0, 0, 1, 1, 1, 1, 1] ;Liag, GK, AS, TV
Global $ready[$pmax + 1] ;Liga, TL
Global $weiter[$pmax + 1] ;Liga, GK,
Global $Liga_exit[$pmax + 1] = [0, 20, 20, 20, 20, 20, 20, 20, 8] ;Liag
Global $winSum
Global $loseSum

;Optionen

Global $Runden_End = 5 ;Rundenende in Liga

Global $AS_pause = 7
Global $AS_gegneranayse = 6
Global $AS_aussteigen = 20 ; 9 ; 12 ...20; Aussteigen nach Runde x
Global $AS_aussteigen = 109 ; 6 ; 9 ; 12 ...20; Aussteigen nach Runde x

Global $sum = 0
Global $scan = 0
Global $timer = 0
Global $scando = 0

Global $kisten_option1 = 0
Global $kisten_option2 = 0
Global $kisten_option3 = 0

Global $Anz_Duell = 3000 ; Default 300

