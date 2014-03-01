
posAir = [14307,15998];
posHanger = [14400,16225];
posIsland1 = [16810,13615];
posIsland2 = [16595,13580];
posHill1 = [18600,13950];
posHill2 = [16562,10936];
posTown = [17500,13300];
solCentre = createCenter EAST;
solGroup = createGroup EAST;
tgtGroup = [];
aaGroup = [];
sptGroup =[];
trigCount = 0;
nxtIndex = 0;
distSupplySpawn = 850; // distance from supported unit that support unit spawns
distResupply = 50; // distance from supported unit that support unit needs to be to resupply unit
distBuffer = 20; // buffer between unit spacing and supply trigger distance

//AA resupply trigger times
minSupplyTime = 40;
avgSupplyTime = 50;
maxSupplyTime = 80;

// "[14307,15998] air strip, [16810,13615] island";

vclPlayer = "I_Plane_Fighter_03_CAS_F";
truckRes = ["O_Truck_02_covered_F", "O_Truck_02_fuel_F", "O_Truck_02_Ammo_F", "O_Truck_02_box_F"];
apcRes = ["O_APC_Wheeled_02_rcws_F", "O_APC_Tracked_02_cannon_F"];
aaRes = ["O_APC_Tracked_02_AA_F"];
vclRes = truckRes + apcRes;

// "function to return the vehicle name at _num in _arr; if _num > _arr size, cycles from beginning";
selectVehicle = {
	private ["_arr", "_num"];
	_arr = _this select 0;
	_num = _this select 1;
	_arr select (_num % (count _arr));
};

spawnVehicles = {
	private ["_arr", "_num", "_pos"];
	_arr = _this select 0;
	_num = _this select 1;
	_pos = _this select 2;
	_spc = _this select 3;
	_reqgun = _this select 4;
	_ret_array = [];
	for "_x" from 1 to _num do {
		_vhclName = [_arr, _x] call selectVehicle;
		_vhcl = createVehicle [_vhclName , _pos , [], _spc, "drive"];
		[_vhcl] join grpNull;
		_unit = solGroup createUnit ["O_Engineer_F", _pos, [], 0, "NONE"];
		_unit moveInDriver _vhcl;
		if (_reqgun) then {
			_unit1 = solGroup createUnit ["O_Soldier_F", _pos, [], 0, "NONE"];
			_unit1 moveInGunner _vhcl;			
			_unit2 = solGroup createUnit ["O_Soldier_F", _pos, [], 0, "NONE"];
			_unit2 moveInCommander _vhcl;			
		};
		if (_x > 1) then {
			[_vhcl] join group (_ret_array select 0);
		};
		_ret_array set [_x -1, _vhcl];
	};
	doStop _ret_array;
	_ret_array
};

verifyStatus = {
	private ["_ary"];
	_ary = tgtGroup select trigCount;
	_dmgcount = {canMove _x && typeOf vehicle _x in vclRes} count _ary;
	// 'hint ("test: " + str(_dmgcount) + "groups: " + str(count tgtGroup));';
	_dmgcount == 0;
};

assignCurrentTask = {
	private ["_dsc", "_ttl", "_mkr", "_pos", "_mbl", "_imt"];
	nam = _this select 0;
	_dsc = _this select 1;
	_ttl = _this select 2;
	_mkr = _this select 3;
	_pos = _this select 4;
	_mbl = _this select 5;
	_imt = _this select 6;
	nxt = _this select 7;

	if (_mbl) then {
		[player, nam, [_dsc, _ttl, _mkr], getPos ((tgtGroup select trigCount) select 0) , _imt, _imt] call BIS_fnc_taskCreate;
	} else {
		[player, nam, [_dsc, _ttl, _mkr], _pos , _imt, _imt]	call BIS_fnc_taskCreate;
	};	
	if (count nxt > 0) then {
		_trg = createTrigger ["EmptyDetector", _pos];
		_trg setTriggerActivation ["NONE", "NOT PRESENT", false];
		_trg setTriggerStatements ["call verifyStatus;", "[nam,'Succeeded', true] call BIS_fnc_taskSetState; trigCount = trigCount + 1; nxt call assignCurrentTask;", ""];
	} else {
		_trg2 = createTrigger ["EmptyDetector", _pos];
		_trg2 setTriggerActivation ["GUER", "PRESENT", false];
		_trg2 setTriggerArea [20, 20, 44, false];
		_trg2 setTriggerStatements ["this && speed vehicle player < 2;", "[nam,'Succeeded', true] call BIS_fnc_taskSetState; hint 'Mission Accomplished';", ""];
		_trg2 setTriggerType "END1";		
	};
};

testFunc = {hint "this is bullshit";};

/*getNearestRoadLocation = {
	private ["_unit", "_road", "_roadPos"];
	_unit = _this select 0;
	_road = (_unit nearRoads 200) select 0;
	_roadPos = getPos _road;
	_roadPos;
};

genJet = {
	_newCar = "O_Truck_02_covered_F" createVehicle [11111,11111];
	_vjet = "I_Plane_Fighter_03_CAS_F" createVehicle getNearestRoadLocation
};
call genJet;

tracePath = {
	private ["_roads", "_options", "_seek", "_threshold", "_curX", "_curY"];
	_roads = _this select 0;
	_options = _this select 1;
	_seek = _this select 2;
	{	
		
	
	} forEach _roads
};
*/

withinBounds = {
	private ["_tgt", "_ogn", "_can", "_res", "_tgtX", "_tgtY", "_ognX", "_ognY", "_canX", "_canY"];
	_tgt = this select 0;
	_ogn = this select 1;
	_can = this select 2;
	_res = false;
	_tgtX = (getPos _tgt) select 0;
	_tgtY = (getPos _tgt) select 1;
	_ognX = (getPos _ogn) select 0;
	_ognX = (getPos _ogn) select 1;
	_canX = (getPos _can) select 0;
	_canX = (getPos _can) select 1;
	if ( ( ((_tgtX - _canX) < 0) && ((_tgtX - _ognX) < 0) ) || ( ((_tgtX - _canX) >= 0) && ((_tgtX - _ognX) >= 0) ) ) then {
		if ( ( ((_tgtY - _canY) < 0) && ((_tgtY - _ognY) < 0) ) || ( ((_tgtY - _canY) >= 0) && ((_tgtY - _ognY) >= 0) ) ) then {
			_res = true;
		};
	};
	_res
};

buildRoute = {
	private ["_roads", "_curRoad", "_destRoad", "_curCandidate", "_curX", "_curY", "_xX", "_xY", "_res"];
	_roads = _this select 0;
	_curRoad = _this select 1;
	_destRoad = _this select 2;
	_curCandidate = objNull;
	_res = objNull;
	{	
		if (isNull _curCandidate) then {
			if ([_x, _curRoad, _destRoad] call withinBounds) then {
				_curCandidate = _x;			
			}
		} else {
			_curX = (getPos _curCandidate) select 0;
			_curY = (getPos _curCandidate) select 1;
			_xX = (getPos _x) select 0;
			_xY = (getPos _x) select 1;
			if ((_x distance _destRoad < _curCandidate distance _destRoad) && ([_x, _curRoad, _destRoad] call withinBounds)) then {
				_curCandidate = _x;
			}
		}
	} forEach _roads	
};

generateATrucks = {
	private ["_truck", "_trg"];
	
	if (count aaGroup > 0) then {
		hint "truck dispatched";
		{	_y = _x;
			_lx = getPos _y select 0;
			_ly = getPos _y select 1;
			hint (format ["x: %1 y: %2", _lx, _ly]);
			_truck = ([truckRes, 1, [((getPos _y) select 0) + distSupplySpawn, (getPos _y) select 1], 15, false] call spawnVehicles) select 0;
			_curAA = aaGroup select _forEachIndex;
			sptGroup set [_forEachIndex, _truck];
			
			
			createMarker ["Truck1", position _truck];
			"Truck1" setMarkerType "o_armor";
			//hint (format ["truck x out of loop: %1", getPos _truck select 0]);
			//hint (format ["distance %1", _truck distance _curAA]);
			//while { ( _truck distance _curAA ) > ( distResupply + distBuffer ) } do {
			//	"Truck1" setMarkerPos position _truck; 
				//hint (format ["truck x in loop: %1", getPos _truck select 0]);
			//};
			[_truck] joinSilent (group _curAA);
			_truck doMove position _curAA;
			//_truck doFollow _curAA;
			_trg = createTrigger ["EmptyDetector", getPos _y];
			//_trg setTriggerStatements ["true", "hint 'AA rearmed';", ""];
			//( ( sptGroup select 0 ) distance  ( aaGroup select 0 ) ) < 50 && (( aaGroup select 0 ) ammo 'missiles_titan' < 1)
			_trg setTriggerStatements ["( ( ( sptGroup select " + str(_forEachIndex) + " ) distance ( aaGroup select " + str(_forEachIndex) + " ) ) < " + str(distResupply) + " ) && (( aaGroup select " + str(_forEachIndex) + " ) ammo 'missiles_titan' < 1);", 
										"(aaGroup select " + str(_forEachIndex) + ") setVehicleAmmo 1;hint 'AA rearmed';", ""];
			_trg setTriggerActivation ["NONE", "NOT PRESENT", true];
			_trg setTriggerTimeout [minSupplyTime, avgSupplyTime, maxSupplyTime, true];
			//
		hint "trigger created";
		}	forEach aaGroup
	};
};
//hint ( format["loafding %1", mission_mode] );
isAmmoFull = {
	private ["_vhcl", "_ammostats", "_full"];
	_vhcl = _this select 0;
	_ammostats = [_vhcl] call getAmmoStats;
	_full = true;
	{if (_x select 0 != _x select 1) then {_full = false;}} forEach _ammostats;
	_full
};

getAmmoStats = {
	private ["_vhcl", "_ammo_details", "_currentStats"];
	_vhcl = _this select 0;
	_ammo_details = magazinesDetail vehicle player;
	_currentStats = [];
	{ _arr = [_x] call getAmmoStatsFromString; _currentStats set [_forEachIndex, _arr] } forEach _ammo_details;
	_currentStats
};

getAmmoStatsFromString = {
	private ["_string", "_arr", "_splits", "_default", "_current"];
	_string = _this select 0;
	_splits = "(/)";
	_arr = [_string, _splits] call BIS_fnc_splitString;
	_default = _arr select (count _arr) -2;
	_current = _arr select (count _arr) -3;
	[_default, _current]
};

setArrayFuel = {
	_u = _this select 0; //unit array to set fuel for
	_l = _this select 1; //fuel level to set 0-1
	{ _x setFuel _l; } forEach _u;
};

landTask = ["landatbase", "Land back at base", "Land", "Land", posAir, false, 1, []];
vehicleTask = ["killtrucks", "Destroy all trucks at the given location", "Destroy Trucks", "Trucks", posIsland2, true, 1, []];
vehicleTask2 = ["killapc", "Destroy APC/s at the given location", "Destroy APCs", "APCs", posIsland2, true, 1, []];

switch (mission_mode) do {
	
	case 1: {
		trucks1 = [truckRes, 3, posIsland1, 15, false] call spawnVehicles;
		trucks2 = [truckRes, 1, posIsland2, 10, false] call spawnVehicles;
		trucks = trucks1 + trucks2;
		tgtGroup set [0, trucks];
		vehicleTask set [7, landTask];
		vehicleTask call assignCurrentTask;	
	};
	
	case 2: {
		landTask set [4, posHanger];
		trucks1 = [truckRes, 2, posIsland1, 25, false] call spawnVehicles;
		trucks2 = [truckRes, 3, posIsland2, 25, false] call spawnVehicles;
		aa = [aaRes, 1, posHill2, 25, true] call spawnVehicles;
		apc = [apcRes, 2, posIsland2, 25, true] call spawnVehicles;
		trucks = trucks1 + trucks2;
		
		//tgtGroup set [0, trucks];
		//tgtGroup set [1, apc];
		tgtGroup = [trucks, apc];
		
		aaGroup = aa;
		[aaGroup, 0] call setArrayFuel;
		//(aaGroup select 0) setVehicleAmmo 0;
		
		vehicleTask2 set [7, landTask];
		vehicleTask set [7, vehicleTask2];
		vehicleTask call assignCurrentTask;
		
		call generateATrucks;
	};
	
	case 3: {
		landTask set [4, posHanger];
		apc1 = [apcRes, 3, posIsland2, 40, true] call spawnVehicles;
		apc2 = [apcRes, 4, posIsland1, 25, false] call spawnVehicles;
		trucks1 = [truckRes, 2, posIsland1, 25, false] call spawnVehicles;
		trucks2 = [truckRes, 3, posIsland2, 25, false] call spawnVehicles;
		trucks3 = [truckRes, 2, posTown, 25, false] call spawnVehicles;
		trucks = trucks1 + trucks2;
		apcs = apc1 + apc2;
		aa1 = [aaRes, 1, posHill1, 50, true] call spawnVehicles;
		aa2 = [aaRes, 1, posHill2, 25, true] call spawnVehicles;
		aa3 = [aaRes, 1, posTown, 50, true] call spawnVehicles;
		
		tgtGroup set [0, trucks];
		tgtGroup set [1, trucks3];
		tgtGroup set [2, apcs];
		
		aaGroup = [] + aa1 + aa2 + aa3;
		[aaGroup, 0] call setArrayFuel;

		vehicleTask3 = []+vehicleTask;
		
		vehicleTask3 set [7, landTask];
		vehicleTask2 set [7, vehicleTask3];
		vehicleTask set [7, vehicleTask2];
		vehicleTask call assignCurrentTask;		
	};
};

