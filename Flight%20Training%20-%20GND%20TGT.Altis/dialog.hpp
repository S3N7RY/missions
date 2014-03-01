#define CT_STATIC 0
#define CT_BUTTON 1
#define CT_EDIT 2
#define CT_SLIDER 3
#define CT_COMBO 4
#define CT_LISTBOX 5
#define CT_TOOLBOX 6
#define CT_CHECKBOXES 7
#define CT_PROGRESS 8
#define CT_HTML 9
#define CT_STATIC_SKEW      10
#define CT_ACTIVETEXT 11
#define CT_TREE 12
#define CT_STRUCTURED_TEXT 13
#define CT_CONTEXT_MENU 14
#define CT_CONTROLS_GROUP 15
#define CT_SHORTCUTBUTTON 16
#define CT_XKEYDESC 40
#define CT_XBUTTON          41
#define CT_XLISTBOX 42
#define CT_XSLIDER 43
#define CT_XCOMBO           44
#define CT_ANIMATED_TEXTURE 45
#define CT_OBJECT 80
#define CT_OBJECT_ZOOM 81
#define CT_OBJECT_CONTAINER 82
#define CT_OBJECT_CONT_ANIM 83
#define CT_LINEBREAK 98
#define CT_ANIMATED_USER 99
#define CT_MAP              100
#define CT_MAP_MAIN 101
#define CT_LISTNBOX 102
#define INIT_DIF 1

class RscText { 
	access = 0; 
	type = CT_STATIC; 
	idc = -1; 
	style = ST_LEFT; 
	//w = 0.1; h = 0.05; //x and y are not part of a global class since each rsctext will be positioned 'somewhere' 
			x = 0.20; y = 0.30; 
			w = 0.40; h = 0.05; 
			font = "PuristaMedium"; 
	sizeEx = 0.04; 
	colorBackground[] = {0,0,0,0}; 
	colorText[] = {1,1,1,1}; 
	text = ""; 
	fixedWidth = 0; 
	shadow = 0; 
};

class RscButton { 
	access = 0; 
	type = CT_BUTTON; 
	style = ST_LEFT; 
	x = 0; y = 0; w = 0.3; h = 0.1; 
	text = str(mission_mode); 
	font = "PuristaMedium"; 
	sizeEx = 0.04; 
	colorText[] = {0,0,0,1}; 
	colorDisabled[] = {0.3,0.3,0.3,1}; 
	colorBackground[] = {0.6,0.6,0.6,1}; 
	colorBackgroundDisabled[] = {0.6,0.6,0.6,1}; 
	colorBackgroundActive[] = {1,0.5,0,1}; 
	offsetX = 0.004; offsetY = 0.004; 
	offsetPressedX = 0.002; 
	offsetPressedY = 0.002; 
	colorFocused[] = {0,0,0,1}; 
	colorShadow[] = {0,0,0,1}; 
	shadow = 0; 
	colorBorder[] = {0,0,0,1}; 
	borderSize = 0.008; 
	soundEnter[] = {"",0.1,1}; 
	soundPush[] = {"",0.1,1}; 
	soundClick[] = {"",0.1,1}; 
	soundEscape[] = {"",0.1,1}; 
};

class DifDialog { 
	idd = 500; movingEnable = 0; 
	class controlsBackground { 
		class TxtDifBack: RscText { 
			idc = -1; 
			text = "";
			colorBackground[] = {0.1,0.1,0.1,0.8};
		};
	}; 
	class objects { 
	// define controls here 
	}; 
	class controls { 
		// define controls here 
		class TxtDif: RscText { 
			idc = -1; 
			text = "Please select a difficulty level [1-3]"; 
		};
		
		class BtnDif: RscButton {
			idc = 555;
			text = INIT_DIF;
			action = "mission_mode = (mission_mode % 3) + 1; ctrlSetText [555, str(mission_mode)]; hint ('Difficulty set to ' + str(mission_mode) );";
			x = 0.6; y = 0.30; w = 0.1; h = 0.05;
		};
		
		class BtnDifOK: RscButton {
			idc = 556;
			text = "OK";
			action = "closeDialog 500;";
			x = 0.7; y = 0.30; w = 0.1; h = 0.05;
		};
	}; 
};
