SY_SPAWN_SAFE_ZONE 		= 10;		//radius of area-check to prevent spawning on top of existing units
SY_INSPECTION_OFFSET 	= 15;		//offset for waypoints surrounding aircraft 
SY_LAUNCH_RADIUS 		= 3000;		//default aircraft launch radius
SY_LAUNCH_RADIUS_AA 	= 3000;		//default aircraft launch radius Air-to-Air
SY_LAUNCH_RADIUS_AG 	= 2500;		//default aircraft launch radius Air-to-Ground
SY_LAUNCH_QTY 			= 2;		//default number of aircraft to launch on detection of enemy
SY_QTY 					= 5;		//default number of aircraft to spawn
SY_SCRAMBLERS			= [];		//global array holding scramble jets
sy_unit_count			= 1;

SY_STRATIS_AB_PKS = [
[[[1520,4970], 15]], 
[[[1665,5030], -75], [[1670,5060], -75], [[1700, 5203], -75], [[1710, 5234], -75]], 
[[[1700,5053], -75], [[1730,5195], -75], [[1740,5226], -75]]
];

SY_TGT_TYPES = [["Tank", "Car"],["Helicopter", "Plane"]];

//AIRBASE DETAILS - LOCATION, AA_LAUNCH_RADIUS, AG_LAUNCH_RADIUS
SY_STRATIS_AB = [[1675,5550], SY_LAUNCH_RADIUS_AA, SY_LAUNCH_RADIUS_AG];

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
	_role = [_this, 0, "RANDOM", [""], [1]] call BIS_fnc_param;
	_side = [_this, 1, str(resistance), [""], [1]] call BIS_fnc_param;
	_ret = "";

	switch (_side) do {
		case str(resistance): {
			{
				if (_role == "RANDOM") exitWith { _ret = SY_INDI_AC select (floor random (count SY_INDI_AC)) };
				if (_x == _role) exitWith { _ret = SY_INDI_AC select _forEachIndex };
			} forEach SY_INDI_ROLES
		};
	};
	_ret
};

sy_getACRoleByTargetType = {
	private ["_tgt", "_side", "_ret", "_i", "_j"];
	_tgt = [_this, 0, "", [""], [1]] call BIS_fnc_param;
	_side = [_this, 1, str(resistance), [""], [1]] call BIS_fnc_param;
	_found = false;
	_ret = SY_INDI_ROLES select _i;
	for "_i" from 0 to count SY_TGT_TYPES -1 do {
		for "_j" from 0 to count ( SY_TGT_TYPES select _i )-1 do {
			if ((SY_TGT_TYPES select _i) select _j iskindOf _tgt) exitWith {
				_found = true;
			}
		};
		if ( _found ) exitWith {
			switch ( _side ) do {
				case str(resistance): { _ret = SY_INDI_ROLES select _i; };
				default {_ret = SY_INDI_ROLES select _i};
			};
		};
	};
	//hint format ["ret: %1",_ret];
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
	private ["_loc", "_or", "_utype", "_side", "_actype", "_g"];	
	_loc = [_this, 0, [0,1500], [[]], [2]] call BIS_fnc_param;
	_or = [_this, 1, 0, [0], [1]] call BIS_fnc_param;
	_utype = [_this, 2, "B_pilot_F", [""], [1]] call BIS_fnc_param;
	_side = [_this, 3, resistance, [resistance], [1]] call BIS_fnc_param;
	_actype = [_this, 4, "I_Plane_Fighter_03_CAS_F", [""], [1]] call BIS_fnc_param;
	if (count (_loc nearEntities [["Man", "Air", "Car", "Motorcycle", "Tank"], 
				SY_SPAWN_SAFE_ZONE]) == 0) then {
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
		_name = "unit" + str(sy_unit_count);
		leader _g setName _name;
		sy_unit_count = sy_unit_count + 1;
	};
	_g
};

sy_validTarget = {
	private ["_list", "_tgttype", "_ret"];
	_list = [_this, 0, [], [[]], [0,1]] call BIS_fnc_param;	
	_tgttype = [_this, 1, "Air", [""], [1]] call BIS_fnc_param;
	_ret = false;
	//hint format ["ttype:%1 list: %2", _tgttype, _list];
	{
		if (_x isKindOf _tgttype) exitWith {
			_ret = true;
		};
	} forEach _list;
	_ret
};

sy_addTriggers = {
	private ["_base", "_index", "_enemyside", "_qty", "_tgttypes", "_side"];
	_base = [_this, 0, SY_STRATIS_AB, [SY_STRATIS_AB], [2]] call BIS_fnc_param;	
	_index = [_this, 1, 0, [0], [1]] call BIS_fnc_param;
	_enemyside = [_this, 2, "WEST", [""], [1]] call BIS_fnc_param;
	_qty = [_this, 3, 2, [0], [1]] call BIS_fnc_param;
	_tgttypes = [_this, 4, ["Air"], [[]], [1,3]] call BIS_fnc_param;
	_side = [_this, 5, resistance, [resistance], [1]] call BIS_fnc_param;
	for "_i" from 0 to count _tgttypes do {
		_trg = createTrigger["EmptyDetector", _base select 0];
		_trg setTriggerArea[_base select (_i + 1), _base select (_i + 1), 0, false];
		_trg setTriggerActivation[_enemyside, "PRESENT", true];
		_trgActString = "[ " + str(_qty) + ", " + str(_index) + ", [['" +
							(_tgttypes select _i) + "', '" + str(_side) + 
							"'] call sy_getACRoleByTargetType, '" + str(_side) + 
							"'] call sy_getACTypeByRole] call sy_launchAC; ";
		_trg setTriggerStatements[ "this && [thislist, '" + (_tgttypes select _i) + "'] call sy_validTarget", _trgActString, 
								"hint 'area clear - "+(_tgttypes select _i)+"';"];
	}
};

sy_launchAC = {
	private ["_qty", "_index", "_type"];
	_qty = [_this, 0, 2, [0], [1]] call BIS_fnc_param;	
	_index = [_this, 1, 0, [0], [1]] call BIS_fnc_param;
	_type = [_this, 2, "", [""], [1]] call BIS_fnc_param;
	_pool = SY_SCRAMBLERS select _index;
	_count = 0;
	//hint format ["%1",count _pool];
	//hint format ["%1", _type];
	for "_j" from 0 to (count _pool) -1 do {
		{
		_u = leader(_x);
		_v = vehicle _u;
		if (_count < _qty && damage _v < 0.5 && speed _v == 0) then {
			//hint format ["type: %1", _type];
			if ( _type == "" ) then {
				hint "null";
				_v setFuel 1;
				_count = _count + 1;		
			} else {	
				//hint format ["%1",typeOf _v];
				//_actype = [_type, str(side _u)] call sy_getACTypeByRole;
				if ((typeOf _v) == _type) then {
					hint format ["isoftype %1", _type];
					_v setFuel 1;
					_count = _count + 1;
				};
			};

		};
		} forEach _pool;
	};	
};

sy_spawnJets = {
	private ["_side", "_acrole", "_qty", "_bases", "_opts", 
				"_runwayOpt", "_openOpt", "_hangerOpt", "_retarray", "_cur"];
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
		_ac = [_acrole, str(_side)] call sy_getACTypeByRole;
		{
			_jetarray = [];
			if (_runwayOpt && _cur == 0) then {
				if (_acrole == "RANDOM") then { _ac = [_acrole, str(_side)] call sy_getACTypeByRole; };
				_pk = ((_x call sy_getBaseACParks) select 0) select 0;
				_jetarray set [count _jetarray, 
				[ _pk select 0, _pk select 1, _types select 0, _side, _ac ] call sy_spawnJet ];
				_cur = _cur + 1;
			};
			if (_openOpt && _cur < _qty) then {
				_pks = _x call sy_getBaseACParks select 1;
				for "_a" from 0 to count _pks -1 do {
					if (_cur < _qty) then {
						if (_acrole == "RANDOM") then { _ac = [_acrole, str(_side)] call sy_getACTypeByRole; };
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
						if (_acrole == "RANDOM") then { _ac = [_acrole, str(_side)] call sy_getACTypeByRole; };
						_pk = _pks select _a;
						_jetarray set [count _jetarray, 
						[ _pk select 0, _pk select 1, _types select 0, _side, _ac ] call sy_spawnJet ];
						_cur = _cur + 1;
					}
				}		
			};
			_retarray set [count _retarray, _jetarray];
			[ _x, _forEachIndex, "WEST", SY_LAUNCH_QTY, ["Air", "Land"], _side] call sy_addTriggers;
		} forEach _bases;
	};
	SY_SCRAMBLERS = _retarray;
	_retarray
};
