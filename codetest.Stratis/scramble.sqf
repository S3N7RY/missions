SY_SPAWN_SAFE_ZONE 		= 10;		//radius of area-check to prevent spawning on top of existing units
SY_INSPECTION_OFFSET 	= 15;		//offset for waypoints surrounding aircraft 
SY_LAUNCH_RADIUS 		= 2000;		//default aircraft launch radius
SY_QTY 					= 5;		//default number of aircraft to spawn

SY_STRATIS_AB_PKS = [
[[[1520,4970], 15]], 
[[[1665,5030], -75], [[1670,5060], -75], [[1700, 5203], -75], [[1710, 5234], -75]], 
[[[1700,5053], -75], [[1730,5195], -75], [[1740,5226], -75]]
];
SY_STRATIS_AB = [[1675,5550], SY_LAUNCH_RADIUS];

SY_INDI_PILOT = "I_pilot_F";
SY_INDI_ROLES = ["CAS", "AA"];
SY_INDI_AC = ["I_Plane_Fighter_03_CAS_F", "I_Plane_Fighter_03_AA_F"];

SY_BLU_PILOT = "B_pilot_F";
SY_BLU_ROLES = ["CAS", "AA"];
SY_BLU_AC = ["I_Plane_Fighter_03_CAS_F", "I_Plane_Fighter_03_AA_F"];

SY_OP_PILOT = "O_pilot_F";
SY_OP_ROLES = ["CAS", "AA"];
SY_OP_AC = ["I_Plane_Fighter_03_CAS_F", "I_Plane_Fighter_03_AA_F"];

sy_setLaunchRadius = {
	private ["_base", "_val"];
	_base = [_this, 0, SY_STRATIS_AB, [SY_STRATIS_AB], [1]] call BIS_fnc_param;
	_val = [_this, 1, SY_LAUNCH_RADIUS, [SY_LAUNCH_RADIUS], [1]] call BIS_fnc_param;
	switch (_base) do {
		//case SY_STRATIS_AB: {SY_STRATIS_AB set [1, _val];};
		default {SY_STRATIS_AB set [1, _val];};
	};
};

sy_getACTypeByRole = {
	private ["_role", "_side", "_ret"];
	_role = [_this, 0, "AA", [""], [1]] call BIS_fnc_param;
	_side = [_this, 1, resistance, [resistance], [1]] call BIS_fnc_param;
	_ret = "";
	switch (_side) do {
		case resistance: {
			{ if (_x == _role) exitWith { _ret = SY_INDI_AC select _forEachIndex };
			} forEach SY_INDI_ROLES
		};
	};
	_ret
};

sy_getEntityInfo = {
	private ["_side", "_ret"];
	_side = [_this, 0, resistance, [resistance], [1]] call BIS_fnc_param;
	_ret = [];
	switch (_side) do {
		case resistance:  {
			_ret set [0, SY_INDI_PILOT];
			_ret set [1, SY_INDI_ROLES];
			_ret set [2, SY_INDI_AC];
		};
	};
	_ret
};

sy_getBaseACParks = {
	private ["_base", "_ret"];
	_base = [_this, 0, SY_STRATIS_AB, [[]], [2]] call BIS_fnc_param;
	_ret = [];
	switch (_base) do {
		//case SY_STRATIS_AB: { _ret = SY_STRATIS_AB_PKS; };
		default { _ret = SY_STRATIS_AB_PKS; };
	};
	_ret
};

sy_spawnJet = {
	private ["_loc", "_or", "_utype", "_side", "_actype"];	
	_loc = [_this, 0, [0,1500], [[]], [2]] call BIS_fnc_param;
	_or = [_this, 1, 0, [0], [1]] call BIS_fnc_param;
	_utype = [_this, 2, "B_pilot_F", [""], [1]] call BIS_fnc_param;
	_side = [_this, 3, resistance, [resistance], [1]] call BIS_fnc_param;
	_actype = [_this, 4, "I_Plane_Fighter_03_CAS_F", [""], [1]] call BIS_fnc_param;
	//hint format ["%1", count (_loc nearEntities [["Man", "Air", "Car", "Motorcycle", "Tank"], 5])];
	if (count (_loc nearEntities [["Man", "Air", "Car", "Motorcycle", "Tank"], SY_SPAWN_SAFE_ZONE]) == 0) then {
		_xpos = _loc select 0;
		_ypos = _loc select 1;
		_ne = [ (_xpos + SY_INSPECTION_OFFSET), (_ypos + SY_INSPECTION_OFFSET) ]; //north east waypoint
		_se = [ (_xpos + SY_INSPECTION_OFFSET), (_ypos - SY_INSPECTION_OFFSET) ]; //south east waypoint
		_sw = [ (_xpos - SY_INSPECTION_OFFSET), (_ypos - SY_INSPECTION_OFFSET) ]; //south west waypoint
		_nw = [ (_xpos - SY_INSPECTION_OFFSET), (_ypos + SY_INSPECTION_OFFSET) ]; //north west waypoint
		_g = createGroup _side;
		_utype createUnit [_ne, _g];
		_j =  _actype createVehicle _loc;
		_j setDir _or;
		leader _g moveInDriver _j;
		_j setFuel 0;
	};
	[_u, _j]
};

sy_addTriggers = {
	private ["_base", "_jetarr"];
	_base = 	[_this, 0, SY_STRATIS_AB, [SY_STRATIS_AB], [2]] call BIS_fnc_param;	
	_jetarr = 	[_this, 1, objNull, [ObjNull,[]], [1]] call BIS_fnc_param;
	
};

sy_spawnJets = {
	private ["_side", "_acrole", "_qty", "_bases", "_opts", "_runwayOpt", "_openOpt", "_hangerOpt", "_retarray", "_cur"];
	_side = 	[_this, 0, resistance, [resistance], [1]] call BIS_fnc_param;
	_acrole = 	[_this, 1, "AA", [""], [1]] call BIS_fnc_param;
	_qty = 		[_this, 2, 1, [0], [1]] call BIS_fnc_param;
	_bases = 	[_this, 3, [SY_STRATIS_AB] call sy_getBaseACParks, [[]], [1,8]] call BIS_fnc_param;
	_opts = 	[_this, 4, [true,true,true], [[]], [3]] call BIS_fnc_param;
	_runwayOpt = _opts select 0;
	_openOpt = _opts select 1;
	_hangerOpt = _opts select 2;
	_retarray = [];
	_cur = 0;
	while { _cur < _qty } do {
		_types = [_side] call sy_getEntityInfo;
		_ac = [_acrole, _side] call sy_getACTypeByRole;
		{
			_jetarray = [];
			if (_runwayOpt && _cur == 0) then {
				_pk = ((_x call sy_getBaseACParks) select 0) select 0;
				_jetarray set [count _jetarray, 
				[ _pk select 0, _pk select 1, _types select 0, _side, _ac ] call sy_spawnJet ];
				_cur = _cur + 1;
			};
			if (_openOpt && _cur < _qty) then {
				_pks = _x call sy_getBaseACParks select 1;
				for "_a" from 0 to count _pks -1 do {
					if (_cur < _qty) then {
						_pk = _pks select _a;
						_jetarray set [count _jetarray, 
						[ _pk select 0, _pk select 1, _types select 0, _side, _ac ] call sy_spawnJet ];
						_cur = _cur + 1;
					}
				}
			};		
			if (_hangerOpt && _cur < _qty) then {
				_pks = _x call sy_getBaseACParks select 2;
				for "_a" from 0 to count _pks -1 do {
					if (_cur < _qty) then {
						_pk = _pks select _a;
						_jetarray set [count _jetarray, 
						[ _pk select 0, _pk select 1, _types select 0, _side, _ac ] call sy_spawnJet ];
						_cur = _cur + 1;
					}
				}		
			};
			_retarray set [count _retarray, _jetarray];
		} forEach _bases;
	};
	_retarray
};
