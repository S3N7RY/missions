//WEST:0, EAST:1, INDI:2
scrambleArray = [[],[],[]];
scrambleMarshal = {
	private[ "_q"];

};

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

[opfor1, "INDI"] call addScrambleJet;