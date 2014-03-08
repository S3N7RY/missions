SY_SPAWN_SAFE_ZONE = 10;		//radius of area-check to prevent spawning on top of existing units
SY_INSPECTION_OFFSET = 15;		//offset for waypoints surrounding aircraft 
SY_LAUNCH_RADIUS = 2000;

//WEST:0, EAST:1, INDI:2
scrambleArray = [[],[],[]];
scrambleMarshal = {
	private[ "_q"];
};

SY_INDI_PILOT = "I_pilot_F";
SY_INDI_ROLES = ["CAS", "AA"];
SY_INDI_AC = ["I_Plane_Fighter_03_CAS_F", "I_Plane_Fighter_03_AA_F"];

sy_getACTypeByRole = {
	private ["_role", "_side", "_ret"];
	_role = [_this, 0, "AA", [""], [1]] call BIS_fnc_param;
	_side = [_this, 1, resistance, [resistance], [1]] call BIS_fnc_param;
	_ret = "";
	switch (_side) do {
		case resistance: {
			{ if (_x == _role) exitWith {_ret = SY_INDI_AC select _forEachIndex};
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

SY_STRATIS_AB_PKS = [[[1520,4970], 15], [[1670,5060], -75],[[1665,5025], -75], 
						[[1700, 5200], -75], [[1710, 5235], -75]];
SY_STRATIS_AB = [[1675,5550], 10000];

sy_spawnJets = {
	private ["_side", "_acrole", "_qty"];
	_side = [_this, 0, resistance, [resistance], [1]] call BIS_fnc_param;
	_acrole = [_this, 1, "CAS", [""], [1]] call BIS_fnc_param;
	_qty = [_this, 2, 1, [0], [1]] call BIS_fnc_param;
	for "_i" from 0 to _qty -1 do {
		_types = [_side] call sy_getEntityInfo;
		_ac = [_acrole, _side] call sy_getACTypeByRole;
		_pk = SY_STRATIS_AB_PKS select _i;
		[_pk select 0, _pk select 1, _types select 0, _side, _ac] call sy_spawnJet;
	};
	//_target = [_this, 0, objNull, [objNull,[]], [2,3]] call BIS_fnc_param;
};

sy_spawnJet = {
	private ["_loc", "_or", "_utype", "_side", "_actype"];	
	_loc = [_this, 0, [0,1500], [[]], [2]] call BIS_fnc_param;
	_or = [_this, 1, 0, [0], [1]] call BIS_fnc_param;
	_utype = [_this, 2, "B_pilot_F", [""], [1]] call BIS_fnc_param;
	_side = [_this, 3, resistance, [resistance], [1]] call BIS_fnc_param;
	_actype = [_this, 4, "I_Plane_Fighter_03_CAS_F", [""], [1]] call BIS_fnc_param;
	//hint format ["%1", count (_loc nearEntities [["Man", "Air", "Car", "Motorcycle", "Tank"], 5])];
	if (count (_loc nearEntities [["Man", "Air", "Car", "Motorcycle", "Tank"], 
				SY_SPAWN_SAFE_ZONE]) == 0) then {
		_xpos = _loc select 0;
		_ypos = _loc select 1;
		_ne = [ _xpos + SY_INSPECTION_OFFSET, _ypos +SY_INSPECTION_OFFSET ]; //north east waypoint
		_se = [ _xpos + SY_INSPECTION_OFFSET, _ypos -SY_INSPECTION_OFFSET ]; //south east waypoint
		_sw = [ _xpos - SY_INSPECTION_OFFSET, _ypos -SY_INSPECTION_OFFSET ]; //south west waypoint
		_nw = [ _xpos - SY_INSPECTION_OFFSET, _ypos +SY_INSPECTION_OFFSET ]; //north west waypoint
		_g = createGroup _side;
		_utype createUnit [_ne, _g];
		_j =  _actype createVehicle _loc;
		_j setDir _or;
		leader _g moveInDriver _j;
		_j setFuel 0;
	};
	[_u, _j]
};
