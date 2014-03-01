noVehiclesOfType = {
	private ["_list", "_types", "_extant"];
	_list = _this select 0;
	_types = _this select 1;
	_extant = true;
	{
		_v = _x;
		for "_i" from 0 to (count _types) -1 do {
			if (typeOf _x == (_types select _i)) exitWith {
				hint typeOf _x;
					_extant = false;
			};
		};
	} forEach _list;
	_extant
}