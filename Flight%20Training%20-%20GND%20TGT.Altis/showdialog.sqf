_ok = createDialog "DifDialog"; 
waitUntil { !dialog };
call {execVM 'missionfile.sqf'};