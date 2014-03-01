ROAD_RADIUS = 150;	//initial search radius for roads
INCREMENT = 50;		//increment value for search-radius increase
MIN_RADIUS = 500;		//used to determine whether found segment is close enough to target
BOUNDS_THRESHOLD = 8;//number of meters outside bounds to allow road segments to be added
NEXT_SEG_DEPTH = 120;
mkr_count = 0;
max_iterations = 1000;
iterations = 0;
findNearestRoad = {
	private ["_point","_rr","_candidate"];
	_point = _this select 0;
	_rr = ROAD_RADIUS - INCREMENT; //set initial road radius, but will expand if no roads are found
	_candidate = objNull;

	while { isNull _candidate } do {
		_rr = _rr + INCREMENT;
		_candidate = (_point nearRoads _rr) select 0;
		//_candidate call BIS_fnc_log ;
	};
	_candidate
};

withinBounds = {
	private ["_tgt", "_ogn", "_can", "_res", "_tgtX", "_tgtY", "_ognX", "_ognY", "_canX", "_canY"];
	_tgt = _this select 0;
	_ogn = _this select 1;
	_can = _this select 2;
	_res = false;
	_tgtX = (getPos _tgt) select 0;
	_tgtY = (getPos _tgt) select 1;
	_ognX = (getPos _ogn) select 0;
	_ognY = (getPos _ogn) select 1;
	_canX = _can select 0;
	_canY = _can select 1;
	if ( ( ((_tgtX - _canX) < 0 + BOUNDS_THRESHOLD) && ((_tgtX - _ognX) < 0 + BOUNDS_THRESHOLD) ) || 
		( ((_tgtX - _canX) >= 0 - BOUNDS_THRESHOLD) && ((_tgtX - _ognX) >= 0 - BOUNDS_THRESHOLD) ) ) then {
		if ( ( ((_tgtY - _canY) < 0 + BOUNDS_THRESHOLD) && ((_tgtY - _ognY) < 0 + BOUNDS_THRESHOLD) ) || 
			( ((_tgtY - _canY) >= 0 - BOUNDS_THRESHOLD) && ((_tgtY - _ognY) >= 0 - BOUNDS_THRESHOLD) ) ) then {
			_res = true;
		};
	};
	_res call BIS_fnc_log ;
	_res
};


getLastPoints = {
	private ["_arr", "_ret", "_last"];
	_arr = _this select 0;
	_ret = _this select 1;
	_last = [] + _arr select ((count _arr) -1);

	while { typeName _last != "OBJECT" } do {
		_arr resize (count _arr) -1;
		_ret = ([_last, []] call getLastPoints);
		_last = [] + _arr select ((count _arr) -1);
	};	
	_ret set [count _ret, _arr select ((count _arr) -1)];
	_ret
};

getNextOpts = {
	private ["_road", "_exists", "_dest", "_search", "_curRoad", "_found", "_add", "_bch"];
	_road = _this select 0;
	_exists = _this select 1;
	_dest = _this select 2;
	_search = roadsConnectedTo _road;
	_bch = [];
	if ( count _search > 2 ) then {
		{
			["flag", _x, "hd_dot"] call setWay;
		} forEach _search;
		{
			if (!(_x in _exists) && !(_x in _bch)) then {
				_bch set [count _bch, _x];
			};
 		} forEach _search;
	};
	if (!isNull _road && ((_dest distance _road) > MIN_RADIUS)) then {
		while { count _search > 0 } do {
			_found = false;
			_add = _search select ((count _search) - 1);
			if (!(_add in _exists)) then {
				_exists set [(count _exists), _add];
			};
			_search resize ((count _search) -1);
		};
	};
	if (count _exists < NEXT_SEG_DEPTH && count _exists > 0 && ((_dest distance _road) > MIN_RADIUS) && iterations < max_iterations) then {
	"yep" + str(iterations) call BIS_fnc_log;
		_exists = [_exists select ((count _exists) -1), _exists, _dest] call getNextOpts;
		
		{
		_exists set [count _exists, ([_bch select ((count _bch) -1), [], _dest] call getNextOpts)];
		} forEach _bch;
	};
	iterations = iterations + 1;
	_exists call BIS_fnc_log;
	_exists
};

/*nextSegment = {
	private ["_roads", "_curRoad", "_destRoad", "_curCandidate", "_curX", "_curY", "_xX", "_xY", "_res"];
	_roads = _this select 0;
		
	//"ROADS" + str(_roads) call BIS_fnc_log ;	
	_curRoad = _this select 1;
	_destRoad = _this select 2;
	_curCandidate = objNull;
	_res = objNull;
	{	
		if (isNull _curCandidate) then {
			//if ([_x, _curRoad, _destRoad] call withinBounds) then {
				_curCandidate = _x;	
"from null" call BIS_fnc_log ;					
			//}
		} else {
			_curX = (getPos _curCandidate) select 0;
			_curY = (getPos _curCandidate) select 1;
			_xX = (getPos _x) select 0;
			_xY = (getPos _x) select 1;
			if ((_x distance _curRoad < _curCandidate distance _curRoad) && 
				([_x, _curRoad, _destRoad] call withinBounds)) then {
				_curCandidate = _x;
				"from obj" call BIS_fnc_log ;					
			}
		}
	} forEach _roads;
	["mkr", _curCandidate, "mil_destroy"] call setWay;
	_curCandidate
};*/

setWay = {
	private ["_pre", "_obj", "_typ", "_nam"];
	_pre = _this select 0;
	_obj = _this select 1;
	_typ = _this select 2;
	_nam = _pre + str(mkr_count);
	"OBJ: " + str(_obj) call BIS_fnc_log;
	createMarker [_nam , getPos _obj];
	_nam setMarkerType _typ;
	_nam setMarkerPos getPos _obj;
	mkr_count = mkr_count + 1;
};

markWays = {
	private ["_arr"];
	_arr = _this select 0;
	{ ["mkr", _x, "mil_destroy"] call setWay;
	} forEach _arr;
};

getClosest = {
	private ["_opts", "_tgt", "_best","_tmp"];
	_opts = _this select 0;
	_tgt = _this select 1;
	_best = _opts select 0;
	for "_i" from 1 to (count _opts) -1 do {
		_tmp = (_opts select _i) distance _tgt;
		if (_tmp < (_best distance _tgt)) then {
			_best = _opts select _i;
		};
	};
	[_best] call markWays;
	_best
};

buildPath = {
	private ["_init", "_dest", "_curBest", "_destArr", "_tmpArray"];

	_init = _this select 0;
	_dest = _this select 1;
	_destArr = [];
	_init = [_init] call findNearestRoad;
	//_nextInit call BIS_fnc_log;
	_dest = [_dest] call findNearestRoad;
	_tmpArray = [_init, _dest];
	[_tmpArray] call markWays;
	
	_tmpArray = [_init, [], _dest] call getNextOpts;

	_tmpArray = [_tmpArray] call getLastPoints;
	_tmpArray call BIS_fnc_log;
	_curBest = [_tmpArray, _dest] call getClosest;
	"init_best: " + str(_curBest) call BIS_fnc_log;

	_destArr = [_curBest];
	
	while {(_curBest distance _dest) > MIN_RADIUS} do {
		_tmpArray = [_curBest, []] call getNextOpts;
		_curBest = [_tmpArray, _dest] call getClosest;
		_destArr set [count _destArr, _curBest];
		["yeaf", _curBest, "mil_destroy"] call setWay;
		_destArr call BIS_fnc_log;
	};
	
	_destArr call BIS_fnc_log;
	_destArr
};

//test = [[180361 ,180361 ,180612 ,183610 ,180240, [180613 ,180611 ,180612,[180361 ,180361 ,180612 ,183610]], [180361 ,180361]],[]] call getLastPoints;
//test = [1803613: ,1803611: ,1803612: ,1803610: ,1802540: ,1803609: ,1303852: bridge_asphalt_f.p3d,1803141: ,1803140: ,1803139: ,1803138: ,1803137: ,1803136: ,1803135: ,1803134: ,1803133: ,1803132: ,1803131: ,1803130: ,1803129: ,[1803610: ,1802539: ,1802540: ,1802538: ,1802537: ,1802536: ,1802535: ,1802534: ,1802533: ,1802532: ,1802531: ,1802530: ,1802529: ,1802528: ,1802527: ,1802526: ,1802525: ,1802524: ,1802523: ,1802522: ],[1803610: ,1802539: ,1802540: ,1802538: ,1802537: ,1802536: ,1802535: ,1802534: ,1802533: ,1802532: ,1802531: ,1802530: ,1802529: ,1802528: ,1802527: ,1802526: ,1802525: ,1802524: ,1802523: ,1802522: ]] call getLastPoints;
//test call BIS_fnc_log;
ways = ([[7380,11100],[4015,12250]] call buildPath);
