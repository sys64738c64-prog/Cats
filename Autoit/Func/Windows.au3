Func WindowsPositionieren()
	For $p = 1 To 8
		WinActivate("(" & $P_Name[$p][1] & ")")
;~ WinMove("(" & $W_P[$p][0] & ")", "", $Win_Pos[$p][1], $Win_Pos[$p][2], $Win_Pos[$p][3], $Win_Pos[$p][4])
		WinMove("(" & $P_Name[$p][1] & ")", "", $Win_Pos[$P_Name[$p][0]][1], $Win_Pos[$P_Name[$p][0]][2], $Win_Pos[$P_Name[$p][0]][3], $Win_Pos[$P_Name[$p][0]][4])
	Next

EndFunc   ;==>WindowsPositionieren
