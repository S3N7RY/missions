//WEST:0, EAST:1, INDI:2
scrambleArray = [[],[],[]];
scrambleMarshal = {
	private[ "_q"];

};
/*
addScrambleJet = {
	private ["_jet", "_side"];
	_jet = _this select 0;
	_side = _this select 1;

	_jet engineOn false;
	hint typeof _jet;
	switch(_side) do {
		case "WEST": { scrambleArray set [ 0, scrambleArray select 0 + [_jet] ]};
		case "EAST": { scrambleArray set [ 1, scrambleArray select 1 + [_jet] ]};
		case "INDI": { scrambleArray set [ 2, scrambleArray select 2 + [_jet] ]};
	};
};

[opfor1, "INDI"] call addScrambleJet;*/
SY_INDI_PILOT = "I_pilot_F";
SY_INDI_ROLES = ["CAS", "AA"];
SY_INDI_AC = ["I_Plane_Fighter_03_CAS_F", "I_Plane_Fighter_03_AA_F"];

SY_STRATIS_AB = [[[1670,5060], -75],[[1665,5025], -75],[[1520,4970], -15]];

spawnJets = {
	private ["_side", "_acrole", "_qty"];
	_side = [_this, 0, "INDI", [""], [1]] call BIS_fnc_param;
	_acrole = [_this, 1, "CAS", [""], [1]] call BIS_fnc_param;
	_qty = [_this, 2, 1, [0], [1]] call BIS_fnc_param;
	for "_i" from 0 to _qty -1 do {
		
	};
	//_target = [_this, 0, objNull, [objNull,[]], [2,3]] call BIS_fnc_param;
};

//	_g = createGroup resistance;
//	"I_Plane_Fighter_03_CAS_F" createVehicle [1660,5060];

spawnJet = {
	private ["_loc", "_or", "_utype", "_side", "_actype"];	
	_loc = [_this, 0, [0,1500], [[]], [2]] call BIS_fnc_param;
	_or = [_this, 1, 0, [0], [1]] call BIS_fnc_param;
	_utype = [_this, 2, "B_pilot_F", [""], [1]] call BIS_fnc_param;
	_side = [_this, 3, west, [west], [1]] call BIS_fnc_param;
	_actype = [_this, 4, "I_Plane_Fighter_03_CAS_F", [""], [1]] call BIS_fnc_param;
	
	_g = createGroup _side;
	_utype createUnit [[(_loc select 0) + 10, (_loc select 1)], _g];
	_j =  _actype createVehicle _loc;
	_u setDir _or;
	_j setDir _or;
	[_u, _j]
};
