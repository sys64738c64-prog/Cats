Func KDS_Scan($p, $Gang) ; 1, Killemall
	Screen_Wechseln(2, $p) ;Home, $p1
	ConsoleWrite(_NowTime() & " Start KDS_Scan: P" & $p & " - " & $Gang & @CRLF)
	WinActivate("(" & $P_Name[$p][1] & ")")
	WinMove("(" & $P_Name[$p][1] & ")", "", -1920, 000, 899, 517)
	Sleep(2000)
	MouseClick("", -1150, 58, 1, 0) ;KDS
	Sleep(1000)
	MouseClick("", -1108, 15, 1, 0) ;Fullscreen
	Sleep(1000)
	WinMove("(" & $P_Name[$p][0] & ")", "", -1920, 0000, 1920, 1080)
	ConsoleWrite(_NowTime() & " Start" & @CRLF)
	RunWait('python.exe "Y:\Cats\Cats_Fz_Status_v5.0.py" ' & $Gang)
	ConsoleWrite(_NowTime() & " End" & @CRLF)
	Sleep(2000)
	MouseClick("", -0085, 15, 1, 0) ;Fullscreen back
	Sleep(2000)
	MouseClick("", $W_P[$p][1] + 53, $W_P[$p][2] + 447, 1, 0) ;Meisterschaft
	Sleep(2000)
	WinActivate("(" & $P_Name[$p][1] & ")")
	WinMove("(" & $P_Name[$p][1] & ")", "", $Win_Pos[$P_Name[$p][0]][1], $Win_Pos[$P_Name[$p][0]][2], $Win_Pos[$P_Name[$p][0]][3], $Win_Pos[$P_Name[$p][0]][4])
	Sleep(3000)
	ConsoleWrite(_NowTime() & " End KDS_Scan: P" & $p & " - " & $Gang & @CRLF)
EndFunc
