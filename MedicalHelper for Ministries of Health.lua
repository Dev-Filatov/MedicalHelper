script_name("MedicalHelper for Ministries of Health")
script_authors("Kyle_Miller")
script_description("Script for the Ministries of Health Arizona RP Gilbert")
script_version("1.0")
 
require "lib.sampfuncs"
require "lib.moonloader"

local script_names = "{E6492D}MedicalHelper for Gilbert{FFFFFF}"

local mem = require "memory"
local vkeys = require "vkeys"
local encoding = require "encoding"
local dlstatus = require("moonloader").download_status

encoding.default = "CP1251"
local u8 = encoding.UTF8

local res, hook = pcall(require, 'lib.samp.events')
assert(res, "���������� SAMP Event �� �������")

local res, imgui = pcall(require, "imgui")
assert(res, "���������� Imgui �� �������")

local res, fa = pcall(require, 'faIcons')
assert(res, "���������� faIcons �� �������")

local res, rkeys = pcall(require, 'rkeys')
assert(res, "���������� Rkeys �� �������")

vkeys.key_names[vkeys.VK_RBUTTON] = "RBut"
vkeys.key_names[vkeys.VK_XBUTTON1] = "XBut1"
vkeys.key_names[vkeys.VK_XBUTTON2] = 'XBut2'
vkeys.key_names[vkeys.VK_NUMPAD1] = 'Num 1'
vkeys.key_names[vkeys.VK_NUMPAD2] = 'Num 2'
vkeys.key_names[vkeys.VK_NUMPAD3] = 'Num 3'
vkeys.key_names[vkeys.VK_NUMPAD4] = 'Num 4'
vkeys.key_names[vkeys.VK_NUMPAD5] = 'Num 5'
vkeys.key_names[vkeys.VK_NUMPAD6] = 'Num 6'
vkeys.key_names[vkeys.VK_NUMPAD7] = 'Num 7'
vkeys.key_names[vkeys.VK_NUMPAD8] = 'Num 8'
vkeys.key_names[vkeys.VK_NUMPAD9] = 'Num 9'
vkeys.key_names[vkeys.VK_MULTIPLY] = 'Num *'
vkeys.key_names[vkeys.VK_ADD] = 'Num +'
vkeys.key_names[vkeys.VK_SEPARATOR] = 'Separator'
vkeys.key_names[vkeys.VK_SUBTRACT] = 'Num -'
vkeys.key_names[vkeys.VK_DECIMAL] = 'Num .Del'
vkeys.key_names[vkeys.VK_DIVIDE] = 'Num /'
vkeys.key_names[vkeys.VK_LEFT] = 'Ar.Left'
vkeys.key_names[vkeys.VK_UP] = 'Ar.Up'
vkeys.key_names[vkeys.VK_RIGHT] = 'Ar.Right'
vkeys.key_names[vkeys.VK_DOWN] = 'Ar.Down'

local dirml = getWorkingDirectory() 
local scr = thisScript()
local font = renderCreateFont("Trebuchet MS", 14, 5)
local sx, sy = getScreenResolution()

local mainWin = imgui.ImBool(false)
local paramWin = imgui.ImBool(false)
local spurBig = imgui.ImBool(false)
local sobWin = imgui.ImBool(false)
local iconwin = imgui.ImBool(false)
local profbWin = imgui.ImBool(false)
local select_menu = {true, false, false, false, false, false, false}

local setting = {
	nick = "",
	teg = "",
	org = 0,
	sex = 0,
	rank = 0,
	time = false,
	rac = false,
	lec = "",
	rec = "",
	narko = "",
	tatu = "",
	antb = "",
	medcard1 = "",
	medcard2 = "",
	medcard3 = "",
	medcard4 = "",
	chat1 = false,
	chat2 = false,
	chat3 = false,
}

local Vaccine = {0, 0, -1}

local buf_nick		= imgui.ImBuffer(256)
local buf_teg 		= imgui.ImBuffer(256)
local num_org		= imgui.ImInt(0)
local num_sex		= imgui.ImInt(0)
local num_rank		= imgui.ImInt(0)
local chgName 		= {}

chgName.inp 		= imgui.ImBuffer(100)
chgName.org 		= {u8"�������� ��", u8"�������� ��", u8"�������� ��"}
chgName.rank 		= {u8"�������", u8"������", u8"��������", u8"��������", u8"����������", u8"��������", u8"������", u8"�����. ����������", u8"���.��.�����", u8"����.����"}

local list_org_BL 	= {"�������� LS", "�������� SF", "�������� LV"} 
local list_org		= {u8"�������� ��", u8"�������� ��", u8"�������� ��"}
local list_org_en 	= {"Los-Santos Medical Center", "San-Fierro Medical Center", "Las-Venturas Medical Center"}
local list_sex		= {fa.ICON_MALE .. u8" �������", fa.ICON_FEMALE .. u8" �������"}
local list_rank		= {u8"�������", u8"������", u8"��������", u8"��������", u8"����������", u8"��������", u8"������", u8"�����. ����������", u8"���.��.�����", u8"����.����"}

local cb_chat1		= imgui.ImBool(false)
local cb_chat2		= imgui.ImBool(false)
local cb_chat3		= imgui.ImBool(false)

local buf_lec		= imgui.ImBuffer(10);
local buf_rec		= imgui.ImBuffer(10);
local buf_narko		= imgui.ImBuffer(10);
local buf_tatu		= imgui.ImBuffer(10);
local buf_antb		= imgui.ImBuffer(10);
local buf_medcard1	= imgui.ImBuffer(10);
local buf_medcard2	= imgui.ImBuffer(10);
local buf_medcard3	= imgui.ImBuffer(10);
local buf_medcard4	= imgui.ImBuffer(10);

local spur = {
	text 				= imgui.ImBuffer(51200),
	name 				= imgui.ImBuffer(256),
	list 				= {},
	select_spur 		= -1,
	edit 				= false
}

local PlayerSet = {}
function PlayerSet.name()
	if buf_nick.v ~= "" then
		return buf_nick.v
	else
		return u8"�� �������"
	end
end
function PlayerSet.org()
	return chgName.org[num_org.v+1]
end
function PlayerSet.rank()
	return chgName.rank[num_rank.v+1]
end
function PlayerSet.sex()
	return list_sex[num_sex.v+1]
end

local selected_cmd = 1
local currentKey = {"", {}}
local cb_RBUT = imgui.ImBool(false)
local cb_x1	= imgui.ImBool(false)
local cb_x2	= imgui.ImBool(false)
local isHotKeyDefined = false
local p_open = false

binder = {
	list = {},
	select_bind,
	edit = false,
	sleep = imgui.ImFloat(0.5),
	name = imgui.ImBuffer(256),
	text = imgui.ImBuffer(51200),
	key = {}
}
local helpd = {}
helpd.exp = imgui.ImBuffer(256)
helpd.exp.v = u8[[
{dialog}
[name]=������ ���.�����
[1]=��������� ��������
��������� �1
��������� �2
[2]=������� ���������� 
��������� �1
��������� �2
{dialogEnd}
]]
helpd.key = {
	{k = "MBUTTON", n = '������ ����'},
	{k = "XBUTTON1", n = '������� ������ ���� 1'},
	{k = "XBUTTON2", n = '������� ������ ���� 2'},
	{k = "BACK", n = 'Backspace'},
	{k = "SHIFT", n = 'Shift'},
	{k = "CONTROL", n = 'Ctrl'},
	{k = "PAUSE", n = 'Pause'},
	{k = "CAPITAL", n = 'Caps Lock'},
	{k = "SPACE", n = 'Space'},
	{k = "PRIOR", n = 'Page Up'},
	{k = "NEXT", n = 'Page Down'},
	{k = "END", n = 'End'},
	{k = "HOME", n = 'Home'},
	{k = "LEFT", n = '������� �����'},
	{k = "UP", n = '������� �����'},
	{k = "RIGHT", n = '������� ������'},
	{k = "DOWN", n = '������� ����'},
	{k = "SNAPSHOT", n = 'Print Screen'},
	{k = "INSERT", n = 'Insert'},
	{k = "DELETE", n = 'Delete'},
	{k = "0", n = '0'},
	{k = "1", n = '1'},
	{k = "2", n = '2'},
	{k = "3", n = '3'},
	{k = "4", n = '4'},
	{k = "5", n = '5'},
	{k = "6", n = '6'},
	{k = "7", n = '7'},
	{k = "8", n = '8'},
	{k = "9", n = '9'},
	{k = "A", n = 'A'},
	{k = "B", n = 'B'},
	{k = "C", n = 'C'},
	{k = "D", n = 'D'},
	{k = "E", n = 'E'},
	{k = "F", n = 'F'},
	{k = "G", n = 'G'},
	{k = "H", n = 'H'},
	{k = "I", n = 'I'},
	{k = "J", n = 'J'},
	{k = "K", n = 'K'},
	{k = "L", n = 'L'},
	{k = "M", n = 'M'},
	{k = "N", n = 'N'},
	{k = "O", n = 'O'},
	{k = "P", n = 'P'},
	{k = "Q", n = 'Q'},
	{k = "R", n = 'R'},
	{k = "S", n = 'S'},
	{k = "T", n = 'T'},
	{k = "U", n = 'U'},
	{k = "V", n = 'V'},
	{k = "W", n = 'W'},
	{k = "X", n = 'X'},
	{k = "Y", n = 'Y'},
	{k = "Z", n = 'Z'},
	{k = "NUMPAD0", n = 'Numpad 0'},
	{k = "NUMPAD1", n = 'Numpad 1'},
	{k = "NUMPAD2", n = 'Numpad 2'},
	{k = "NUMPAD3", n = 'Numpad 3'},
	{k = "NUMPAD4", n = 'Numpad 4'},
	{k = "NUMPAD5", n = 'Numpad 5'},
	{k = "NUMPAD6", n = 'Numpad 6'},
	{k = "NUMPAD7", n = 'Numpad 7'},
	{k = "NUMPAD8", n = 'Numpad 8'},
	{k = "NUMPAD9", n = 'Numpad 9'},
	{k = "MULTIPLY", n = 'Numpad *'},
	{k = "ADD", n = 'Numpad +'},
	{k = "SEPARATOR", n = 'Separator'},
	{k = "SUBTRACT", n = 'Numpad -'},
	{k = "DECIMAL", n = 'Numpad .'},
	{k = "DIVIDE", n = 'Numpad /'},
	{k = "F1", n = 'F1'},
	{k = "F2", n = 'F2'},
	{k = "F3", n = 'F3'},
	{k = "F4", n = 'F4'},
	{k = "F5", n = 'F5'},
	{k = "F6", n = 'F6'},
	{k = "F7", n = 'F7'},
	{k = "F8", n = 'F8'},
	{k = "F9", n = 'F9'},
	{k = "F10", n = 'F10'},
	{k = "F11", n = 'F11'},
	{k = "F12", n = 'F12'},
	{k = "F13", n = 'F13'},
	{k = "F14", n = 'F14'},
	{k = "F15", n = 'F15'},
	{k = "F16", n = 'F16'},
	{k = "F17", n = 'F17'},
	{k = "F18", n = 'F18'},
	{k = "F19", n = 'F19'},
	{k = "F20", n = 'F20'},
	{k = "F21", n = 'F21'},
	{k = "F22", n = 'F22'},
	{k = "F23", n = 'F23'},
	{k = "F24", n = 'F24'},
	{k = "LSHIFT", n = '����� Shift'},
	{k = "RSHIFT", n = '������ Shift'},
	{k = "LCONTROL", n = '����� Ctrl'},
	{k = "RCONTROL", n = '������ Ctrl'},
	{k = "LMENU", n = '����� Alt'},
	{k = "RMENU", n = '������ Alt'},
	{k = "OEM_1", n = '; :'},
	{k = "OEM_PLUS", n = '= +'},
	{k = "OEM_MINUS", n = '- _'},
	{k = "OEM_COMMA", n = ', <'},
	{k = "OEM_PERIOD", n = '. >'},
	{k = "OEM_2", n = '/ ?'},
	{k = "OEM_4", n = ' { '},
	{k = "OEM_6", n = ' } '},
	{k = "OEM_5", n = '\\ |'},
	{k = "OEM_8", n = '! �'},
	{k = "OEM_102", n = '> <'}
}

local sobes = {
	input = imgui.ImBuffer(101),
	player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", narko = 0.1, lic = ""},
	selID = imgui.ImBuffer(5),
	nextQ = false,
	num = 0
}

lua_thread.create(function()
	while true do
		repeat wait(100) until isSampAvailable()
		repeat wait(100) until sampIsLocalPlayerSpawned()
	end
end)

local week = {"�����������", "�����������", "�������", "�����", "�������", "�������", "�������"}
local month = {"������", "�������", "����", "������", "���", "����", "����", "������", "��������", "�������", "������", "�������"}
editKey = false
keysList = {}
needSave = false
needSaveColor = imgui.ImColor(230, 73, 45, 220):GetVec4()

local BlockKeys = {{vkeys.VK_T}, {vkeys.VK_F6}, {vkeys.VK_F8}, {vkeys.VK_RETURN}, {vkeys.VK_OEM_3}, {vkeys.VK_LWIN}, {vkeys.VK_RWIN}}

rkeys.isBlockedHotKey = function(keys)
	local bool, hkId = false, -1
	for k, v in pairs(BlockKeys) do
	   if rkeys.isHotKeyHotKey(keys, v) then
		  bool = true
		  hkId = k
		  break
		end
	end
	return bool, hkId
end

function rkeys.isHotKeyExist(keys)
local bool = false
	for i,v in ipairs(keysList) do
		if table.concat(v,"+") == table.concat(keys, "+") then
			if #keys ~= 0 then
				bool = true
				break
			end
		end
	end
	return bool
end

function unRegisterHotKey(keys)
	for i,v in ipairs(keysList) do
		if v == keys then
			keysList[i] = nil
			break
		end
	end
	local listRes = {}
	for i,v in ipairs(keysList) do
		if #v > 0 then
			listRes[#listRes+1] = v
		end
	end
	keysList = listRes
end


cmdBind = {
	[1] = {
		cmd = "/mh",
		key = {},
		desc = "������� ���� �������",
		rank = 1
	},
	[2] = {
		cmd = "/r",
		key = {},
		desc = "������� ��� ������ ����� � ����� (���� ��������)",
		rank = 1
	},
	[3] = {
		cmd = "/rb",
		key = {},
		desc = "������� ��� ��������� ����� ��������� � �����. ",
		rank = 1
	},
	[4] = {
		cmd = "/mb",
		key = {},
		desc = "����������� ������� /members",
		rank = 1
	},
	[5] = {
		cmd = "/hl",
		key = {},
		desc = "������� � �������������� �� ����������",
		rank = 1
	},
	[6] = {
		cmd = "/ts",
		key = {},
		desc = "������� �������� � �������������� ������ /time",
		rank = 1
	},
	[7] = {
		cmd = "/exp",
		key = {},
		desc = "���������� ������ �� ��������� ��������",
		rank = 1
	},
	[8] = {
		cmd = "/osm",
		key = {},
		desc = "���������� ����������� ������",
		rank = 1
	},
	[9] = {
		cmd = "/cur",
		key = {},
		desc = "������� �������� ��� ��������",
		rank = 1
	},
	[10] = {
		cmd = "/mc",
		key = {},
		desc = "������ ��� ���������� ���.�����",
		rank = 3
	},
	[11] = {
		cmd = "/vc",
		key = {},
		desc = "���������� �������",
		rank = 3
	},
	[12] = {
		cmd = "/narko",
		key = {},
		desc = "������� �� ����������������",
		rank = 4
	},
	[13] = {
		cmd = "/rec",
		key = {},
		desc = "������ ��������",
		rank = 4
	},
	[14] = {
		cmd = "/antb",
		key = {},
		desc = "������ ������������",
		rank = 4
	},
	[15] = {
		cmd = "/minsur",
		key = {},
		desc = "������� ���������",
		rank = 4
	},
	[16] = {
		cmd = "/tatu",
		key = {},
		desc = "�������� ����������",
		rank = 7
	},
	[17] = {
		cmd = "/sob",
		key = {},
		desc = "���� ������������� � ���������",
		rank = 8
	},
	[18] = {
		cmd = "/+warn",
		key = {},
		desc = "������ �������� ����������",
		rank = 8
	},
	[19] = {
		cmd = "/-warn",
		key = {},
		desc = "����� ������� ����������",
		rank = 8
	},
	[20] = {
		cmd = "/+mute",
		key = {},
		desc = "������ ��� ����������",
		rank = 8
	},
	[21] = {
		cmd = "/-mute",
		key = {},
		desc = "����� ��� ����������",
		rank = 8
	},
	[22] = {
		cmd = "/gr",
		key = {},
		desc = "�������� ���� (���������) ����������",
		rank = 9
	},
	[23] = {
		cmd = "/inv",
		key = {},
		desc = "������� � ����������� ������",
		rank = 9
	},
	[24] = {
		cmd = "/unv",
		key = {},
		desc = "������� ���������� �� �����������",
		rank = 9
	},
}

function styleWin()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	local ImVec2 = imgui.ImVec2

	style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
	style.WindowPadding = ImVec2(15, 15)
	style.WindowRounding = 6.0
	style.ChildWindowRounding = 2.0
	style.FramePadding = ImVec2(5, 3)
	style.FrameRounding = 4.0
	style.ItemSpacing = ImVec2(12, 8)
	style.ItemInnerSpacing = ImVec2(8, 6)
	style.IndentSpacing = 25.0
	style.ScrollbarSize = 15.0
	style.ScrollbarRounding = 9.0
	style.GrabMinSize = 5.0
	style.GrabRounding = 3.0
	
	colors[clr.Text] = ImVec4(0.80, 0.80, 0.83, 1.00)
	colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.ChildWindowBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
	colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
	colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.88)
	colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
	colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.TitleBg] = ImVec4(0.76, 0.31, 0.00, 1.00)
	colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75)
	colors[clr.TitleBgActive] = ImVec4(0.80, 0.33, 0.00, 1.00)
	colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
	colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.ComboBg] = ImVec4(0.19, 0.18, 0.21, 1.00)
	colors[clr.CheckMark] = ImVec4(1.00, 0.42, 0.00, 0.53)
	colors[clr.SliderGrab] = ImVec4(1.00, 0.42, 0.00, 0.53)
	colors[clr.SliderGrabActive] = ImVec4(1.00, 0.42, 0.00, 1.00)
	colors[clr.Button] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
	colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
	colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
	colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63)
	colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
	colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63)
	colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
	colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
	colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
end
styleWin()

function ButtonMenu(desk, bool)
	local retBool = false
	if bool then
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(230, 73, 45, 220):GetVec4())
		retBool = imgui.Button(desk, imgui.ImVec2(140, 25))
		imgui.PopStyleColor(1)
	elseif not bool then
		 retBool = imgui.Button(desk, imgui.ImVec2(140, 25))
	end
	return retBool
end

local fa_font = nil
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
function imgui.BeforeDrawFrame()
	if fa_font == nil then
		local font_config = imgui.ImFontConfig()
		font_config.MergeMode = true
		fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/MedicalHelper/Fonts/font-icon.ttf', 15.0, font_config, fa_glyph_ranges)
	end
end


function main()
	repeat wait(100) until isSampAvailable()
	local base = getModuleHandle("samp.dll")
	local sampVer = mem.tohex(base + 0xBABE, 10, true)
	if sampVer == "E86D9A0A0083C41C85C0" then
		sampIsLocalPlayerSpawned = function()
			local res, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
			return sampGetGamestate() == 3 and res and sampGetPlayerAnimationId(id) ~= 0
		end
	end
	thread = lua_thread.create(function()
		return
	end)
	lua_thread.create(function()
		while true do
		wait(1000)
		needSaveColor = imgui.ImColor(230, 73, 45, 220):GetVec4()
			if needSave then
				wait(1000)
				needSaveColor = imgui.ImColor(230, 40, 40, 220):GetVec4()
			end
		end
	end)
	if not doesFileExist(dirml.."/MedicalHelper/logo-medicalhelper.png") then
		print("{FF2525}������: {FFD825}����������� ����������� logo-medicalhelper.png");
		download_id = downloadUrlToFile('https://github.com/Dev-Filatov/MedicalHelper/blob/main/logo-medicalhelper.png?raw=true', 'moonloader/MedicalHelper/logo-medicalhelper.png', function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				print("{FF2525}������: {FFD825}����������� ���������");
				logoMH = imgui.CreateTextureFromFile(dirml.."/MedicalHelper/logo-medicalhelper.png")
			end
		end)
	else
		logoMH = imgui.CreateTextureFromFile(dirml.."/MedicalHelper/logo-medicalhelper.png")
	end
	if not doesDirectoryExist(dirml.."/MedicalHelper/Binder/") then
		print("{F54A4A}������. ����������� �����. {82E28C}�������� ����� ��� �������.")
		createDirectory(dirml.."/MedicalHelper/Binder/")
	end
	if not doesDirectoryExist(dirml.."/MedicalHelper/���������/") then
		print("{F54A4A}������. ����������� �����. {82E28C}�������� ����� ��� ����")
		createDirectory(dirml.."/MedicalHelper/���������/")
	end
	if doesFileExist(dirml.."/MedicalHelper/MainSetting.json") then
	print("{82E28C}������ ��������...")
	local f = io.open(dirml.."/MedicalHelper/MainSetting.json")
		local setf = f:read("*a")
		f:close()
		local res, set = pcall(decodeJson, setf)
		if res and type(set) == "table" then 
			buf_nick.v = u8(set.nick)
			buf_teg.v = u8(set.teg)
			num_org.v = set.org
			num_sex.v = set.sex
			num_rank.v = set.rank
			buf_lec.v = u8(set.lec)
			buf_rec.v = u8(set.rec)
			buf_narko.v = u8(set.narko)
			buf_tatu.v = u8(set.tatu)
			buf_antb.v = u8(set.antb)
			buf_medcard1.v = u8(set.medcard1)
			buf_medcard2.v = u8(set.medcard2)
			buf_medcard3.v = u8(set.medcard3)
			buf_medcard4.v = u8(set.medcard4)
			cb_chat1.v = set.chat1
			cb_chat2.v = set.chat2
			cb_chat3.v = set.chat3
			if set.orgl then
				for i,v in ipairs(set.orgl) do
					chgName.org[tonumber(i)] = u8(v)
				end
			end
			if set.rankl then
				for i,v in ipairs(set.rankl) do
					chgName.rank[tonumber(i)] = u8(v)
				end
			end
		else
			os.remove(dirml.."/MedicalHelper/MainSetting.json")
			print("{F54A4A}������. ���� �������� ��������.")
			print("{82E28C}�������� ����� ����������� ��������...")
			buf_lec.v = "5000"
			buf_narko.v = "6000"
			buf_tatu.v = "15000"
			buf_rec.v = "5000"
			buf_antb.v = "30000"
			buf_medcard1.v = "12500"
			buf_medcard2.v = "25000"
			buf_medcard3.v = "35000"
			buf_medcard4.v = "55000"
		end
	else
		print("{F54A4A}������. ���� �������� �� ������.")
		print("{82E28C}�������� ����������� ��������...")
		buf_lec.v = "5000"
		buf_narko.v = "6000"
		buf_tatu.v = "15000"
		buf_rec.v = "5000"
		buf_antb.v = "30000"
		buf_medcard1.v = "12500"
		buf_medcard2.v = "25000"
		buf_medcard3.v = "35000"
		buf_medcard4.v = "55000"
	end
	print("{82E28C}������ �������� ������...")
	if doesFileExist(dirml.."/MedicalHelper/cmdSetting.json") then
		local f = io.open(dirml.."/MedicalHelper/cmdSetting.json")
		local res, keys = pcall(decodeJson, f:read("*a"))
		f:flush()
		f:close()
		if res and type(keys) == "table" then
			for i, v in ipairs(keys) do
				if #v.key > 0 then
					rkeys.registerHotKey(v.key, true, onHotKeyCMD)
					cmdBind[i].key = v.key
					table.insert(keysList, v.key)
				end
			end
		else
			print("{F54A4A}������. ���� �������� ������ ��������.")
			print("{82E28C}��������� ����������� ���������")
			os.remove(dirml.."/MedicalHelper/cmdSetting.json")
		end
	else
		print("{F54A4A}������. ���� �������� ������ �� ������.")
		print("{82E28C}��������� ����������� ���������")
	end
	print("{82E28C}������ �������� �������...")
	if doesFileExist(dirml.."/MedicalHelper/bindSetting.json") then
		local f = io.open(dirml.."/MedicalHelper/bindSetting.json")
		local res, list = pcall(decodeJson, f:read("*a"))
		f:flush()
		f:close()
		if res and type(list) == "table" then
			binder.list = list
			for i, v in ipairs(binder.list) do
				if #v.key > 0 then
					binder.list[i].key = v.key
					rkeys.registerHotKey(v.key, true, onHotKeyBIND)
					table.insert(keysList, v.key)
				end
			end
		else
			os.remove(dirml.."/MedicalHelper/bindSetting.json")
			print("{F54A4A}������. ���� �������� ������� ��������.")
			print("{82E28C}��������� ����������� ���������")
		end
	else 
		print("{F54A4A}������. ���� �������� ������� �� ������.")
		print("{82E28C}��������� ����������� ���������")
	end
	lockPlayerControl(false)
	sampRegisterChatCommand("hl", funCMD.lec)
	sampRegisterChatCommand("mc", funCMD.med)
	sampRegisterChatCommand("narko", funCMD.narko)
	sampRegisterChatCommand("rec", funCMD.rec)
	sampRegisterChatCommand("tatu", funCMD.tatu)
	sampRegisterChatCommand("antb", funCMD.antb)
	sampRegisterChatCommand("cur", funCMD.cur)
	sampRegisterChatCommand("minsur", funCMD.minsur)
	sampRegisterChatCommand("vc", funCMD.vc)
	sampRegisterChatCommand("+warn", funCMD.warn)
	sampRegisterChatCommand("-warn", funCMD.uwarn)
	sampRegisterChatCommand("gr", funCMD.rank)
	sampRegisterChatCommand("inv", funCMD.inv)
	sampRegisterChatCommand("unv", funCMD.unv)
	sampRegisterChatCommand("+mute", funCMD.mute)
	sampRegisterChatCommand("-mute", funCMD.umute)
	sampRegisterChatCommand("osm", funCMD.osm)
	sampRegisterChatCommand("ts", funCMD.time)
	sampRegisterChatCommand("exp", funCMD.expel)
	sampRegisterChatCommand("update", funCMD.update)
	sampRegisterChatCommand("canclevc", function()
		if num_rank.v+1 < 3 then
			sampAddChatMessage("{FFFFFF}["..script_names.."]: ������ ������� ��� ����������. ��������� ��������� � ���������� �������, ���� ��� ���������.", 0xEE4848)
			return
		end
		if Vaccine[3] ~= -1 then
			sampAddChatMessage("{FFFFFF}["..script_names.."]: �� �������� ����� �������������� � "..tostring(sampGetPlayerNickname(Vaccine[3]):gsub("_", " ")).."", 0xEE4848)
			Vaccine = {0, 0, -1}
		else
			sampAddChatMessage("{FFFFFF}["..script_names.."]: �� ��� �� �������� �����", 0xEE4848)
		end
	end)
	sampRegisterChatCommand("mh", function()
		if sobWin.v then
			sampAddChatMessage("{FFFFFF}["..script_names.."]: �������� ������ ���� ������������� ������� ����, ����� ���������� ������� ����.", 0xEE4848)
			return
		end
		mainWin.v = not mainWin.v
	end)
	
	sampRegisterChatCommand("reload", function()
		showCursor(false);
		scr:reload()
	end)
	
	sampRegisterChatCommand("mb", function() sampSendChat("/members") end)
	
	sampRegisterChatCommand("hme", function()
		local _, plId = sampGetPlayerIdByCharHandle(PLAYER_PED)
		sampSendChat("/heal "..plId)
	end)
	
	sampRegisterChatCommand("sob", function()
		if num_rank.v+1 < 8 then
			sampAddChatMessage("{FFFFFF}["..script_names.."]: ������ ������� ��� ����������. ��������� ��������� � ���������� �������, ���� ��� ���������.", 0xEE4848)
			return
		end
		if mainWin.v then
			sampAddChatMessage("{FFFFFF}["..script_names.."]: �������� ������ ������� ����, ����� ���������� ���� �������������.", 0xEE4848)
			return
		end
		sobWin.v = not sobWin.v
	end)
	
	sampRegisterChatCommand("hlall", function()
		local maxIdInStream = sampGetMaxPlayerId(true)
		for i = 0, maxIdInStream do
		local result, handle = sampGetCharHandleBySampPlayerId(i)
			if result and doesCharExist(handle) then
				local px, py, pz = getCharCoordinates(playerPed)
				local pxp, pyp, pzp = getCharCoordinates(handle)
				local distance = getDistanceBetweenCoords2d(px, py, pxp, pyp)
				if distance <= 4 then
					sampSendChat("/heal "..i.." "..buf_lec.v)
				end
			end
		end
	end)

	sampRegisterChatCommand("mh-delete", function()
		sampAddChatMessage("{FFFFFF}["..script_names.."]: �� ������� ������� ������.", 0xEE4848)
		sampAddChatMessage("{FFFFFF}["..script_names.."]: �������� ������� �� ����...", 0xEE4848)
		os.remove(scr.path)
		showCursor(false);
		scr:reload()
	end)

	sampAddChatMessage("{FFFFFF}["..script_names.."]: ������ ���������������.", 0xEE4848)
	repeat wait(100) until sampIsLocalPlayerSpawned()
	resNickName, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	if resNickName then
		myNick = sampGetPlayerNickname(myid)
	end
	sampAddChatMessage(string.format("{FFFFFF}["..script_names.."]: �����������, %s. ��� ��������� �������� ���� ��������� � ��� {22E9E3}/mh.", tostring(u8:decode(buf_nick.v))), 0xEE4848)
	wait(200)
	if buf_nick.v == "" then 
		sampAddChatMessage("{FFFFFF}["..script_names.."]: ������ � ���� �� ��������� �������� ����������. ", 0xEE4848)
		sampAddChatMessage("{FFFFFF}["..script_names.."]: ����� � ������� ���� � ������ \"���������\" � ������� ���� �� �� \"���-���\".", 0xEE4848)
	end
	lua_thread.create(funCMD.updateCheck)
	while true do
		wait(0)
		if isKeyDown(VK_LMENU) and isKeyJustPressed(VK_K) and not sampIsChatInputActive() then
			mainWin.v = not mainWin.v 
		end
		if thread:status() ~= "dead" and not isGamePaused() then 
			renderFontDrawText(font, "���������: [{F25D33} Page Down {FFFFFF}] - �������������", 20, sy-30, 0xFFFFFFFF)
			if isKeyJustPressed(VK_NEXT) and not sampIsChatInputActive() and not sampIsDialogActive() then
				thread:terminate()
			end
		end
		local resTarg, pedTar = getCharPlayerIsTargeting(PLAYER_HANDLE)
		if resTarg then
			_, targID = sampGetPlayerIdByCharHandle(pedTar)
		end
		imgui.Process = mainWin.v or iconwin.v or sobWin.v
		if Vaccine[2] ~= 0 then
			Vaccine[2] = Vaccine[2] - 1;
			wait(1000)
		end
	end
end
function HideDialog(bool)
	lua_thread.create(function()
		repeat wait(0) until sampIsDialogActive()
		while sampIsDialogActive() do
			local memory = require 'memory'
			memory.setint64(sampGetDialogInfoPtr()+40, bool and 1 or 0, true)
			sampToggleCursor(bool)
		end
	end)
end
imgui.GetIO().FontGlobalScale = 1.1

function mainSet()
	imgui.SetCursorPosX(25)
	imgui.BeginGroup()
	imgui.PushItemWidth(300);
	if imgui.InputText(u8"��� � �������: ", buf_nick, imgui.InputTextFlags.CallbackCharFilter, filter(1, "[�-�%s]+")) then
		needSave = true
	end
		if not imgui.IsItemActive() and buf_nick.v == "" then
			imgui.SameLine()
			ShowHelpMarker(u8"��� � ������� ����������� �� \n������� ��� ������� �������������.\n\n  ������: ����� ������")
			imgui.SameLine()
			imgui.SetCursorPosX(30)
			imgui.TextColored(imgui.ImColor(200, 200, 200, 200):GetVec4(), u8"������� ���� ��� � �������");
		else
		imgui.SameLine()
		ShowHelpMarker(u8"��� � ������� ����������� �� \n������� ��� ������� �������������.\n\n  ������: ����� ������")
	end
	if imgui.InputText(u8"��� � ����� ", buf_teg) then
		needSave = true
	end
	imgui.SameLine();
	ShowHelpMarker(u8"��� ��� ����� ����� ���� ��������������,\n �������� � ������ ����������� ��� ������.\n\n������: [��� ���]")
	imgui.PushItemWidth(278);
	imgui.PushStyleVar(imgui.StyleVar.FramePadding, imgui.ImVec2(1, 3))
		if imgui.Button(fa.ICON_COG.."##1", imgui.ImVec2(21,20)) then
			chgName.inp.v = chgName.org[num_org.v+1]
			imgui.OpenPopup(u8"MH | ��������� �������� ��������")
		end
	imgui.PopStyleVar(1)
	imgui.SameLine(22)
	if imgui.Combo(u8"����������� ", num_org, chgName.org) then
		needSave = true
	end
	imgui.PushStyleVar(imgui.StyleVar.FramePadding, imgui.ImVec2(1, 3))
		if imgui.Button(fa.ICON_COG.."##2", imgui.ImVec2(21,20)) then
			chgName.inp.v = chgName.rank[num_rank.v+1]
			imgui.OpenPopup(u8"MH | ��������� �������� ���������")
		end
	imgui.PopStyleVar(1)
	imgui.SameLine(22)
	if imgui.Combo(u8"��������� ", num_rank, chgName.rank) then
		needSave = true
	end
	imgui.PopItemWidth()						
	if imgui.Combo(u8"��� ��� ", num_sex, list_sex) then
		needSave = true
	end
	imgui.PopItemWidth()
	imgui.EndGroup()
	if imgui.BeginPopupModal(u8"MH | ��������� �������� ��������", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
		imgui.Text(u8"�������� �������� ����� ��������� � �������� ��������")
		imgui.PushItemWidth(390)
		imgui.InputText(u8"##inpcastname", chgName.inp, 512, filter(1, "[%s%a%-]+"))
		imgui.PopItemWidth()
		if imgui.Button(u8"���������", imgui.ImVec2(126, 23)) then
			local exist = false
			for i,v in ipairs(chgName.org) do
				if v == chgName.inp.v and i ~= num_org.v+1 then
					exist = true
				end
			end
			if not exist then
				chgName.org[num_org.v+1] = chgName.inp.v
				needSave = true
				imgui.CloseCurrentPopup()
			end
		end
		imgui.SameLine()
		if imgui.Button(u8"��������", imgui.ImVec2(128,23)) then
			chgName.org[num_org.v+1] = list_org[num_org.v+1]
			needSave = true
			imgui.CloseCurrentPopup()
		end
		imgui.SameLine()
		if imgui.Button(u8"������", imgui.ImVec2(126,23)) then
			imgui.CloseCurrentPopup()
		end
		imgui.EndPopup()
	end
	if imgui.BeginPopupModal(u8"MH | ��������� �������� ���������", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
		imgui.Text(u8"�������� ��������� ����� ��������� � �������� ��������")
		imgui.PushItemWidth(200)
		imgui.InputText(u8"##inpcastname", chgName.inp, 512, filter(1, "[%s%a%-]+"))
		imgui.PopItemWidth()
		if imgui.Button(u8"���������", imgui.ImVec2(126, 23)) then
			local exist = false
			for i,v in ipairs(chgName.rank) do
				if v == chgName.inp.v and i ~= num_rank.v+1 then
					exist = true
				end
			end
			if not exist then
				chgName.rank[num_rank.v+1] = chgName.inp.v
				needSave = true
				imgui.CloseCurrentPopup()
			end
		end
		imgui.SameLine()
		if imgui.Button(u8"��������", imgui.ImVec2(128,23)) then
			chgName.rank[num_rank.v+1] = list_rank[num_rank.v+1]
			needSave = true
			imgui.CloseCurrentPopup()
		end
		imgui.SameLine()
		if imgui.Button(u8"������", imgui.ImVec2(126,23)) then
			imgui.CloseCurrentPopup()
		end
		imgui.EndPopup()
	end
end

function imgui.OnDrawFrame()
	if mainWin.v then
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(900, 465), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(fa.ICON_HEARTBEAT .. "MedicalHelper", mainWin, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize);
		imgui.BeginChild("Mine menu", imgui.ImVec2(170, 0), true)
		imgui.Spacing()
		if ButtonMenu(fa.ICON_USERS .. u8"  �������", select_menu[1]) then
			select_menu = {true, false, false, false, false, false, false};
		end
		imgui.Spacing()
		imgui.Separator()
		imgui.Spacing()
		if ButtonMenu(fa.ICON_WRENCH .. u8"  ���������", select_menu[2]) then
			select_menu = {false, true, false, false, false, false, false}
		end
		imgui.Spacing()
		imgui.Separator()
		imgui.Spacing()
		if ButtonMenu(fa.ICON_FOLDER_OPEN .. u8"  �����", select_menu[7]) then
			select_menu = {false, false, false, false, false, false, true}
		end
		imgui.Spacing()
		imgui.Separator()
		imgui.Spacing()
		if ButtonMenu(fa.ICON_FILE .. u8"  �����", select_menu[3]) then 
			select_menu = {false, false, true, false, false, false, false}; 
			getSpurFile() 
			spur.name.v = ""
			spur.text.v = ""
			spur.edit = false
			spurBig.v = false
			spur.select_spur = -1
		end
		imgui.Spacing()
		imgui.Separator()
		imgui.Spacing()
		if ButtonMenu(fa.ICON_TERMINAL .. u8"  �������", select_menu[4]) then
			select_menu = {false, false, false, true , false, false, false}
		end	
		imgui.Spacing()
		imgui.Separator()
		imgui.Spacing()
		if ButtonMenu(fa.ICON_KEYBOARD_O .. u8"  ������", select_menu[5]) then
			select_menu = {false, false, false, false, true, false, false}
		end
		imgui.Spacing()
		imgui.Separator()
		imgui.Spacing()
		if ButtonMenu(fa.ICON_CODE .. u8"  � �������", select_menu[6]) then
			select_menu = {false, false, false, false, false, true, false}
		end
		imgui.EndChild();
		if select_menu[1] then
			imgui.SameLine()
			imgui.BeginGroup()
			if logoMH then
				imgui.Image(logoMH, imgui.ImVec2(725, 170))
			end
			local colorInfo = imgui.ImColor(240, 170, 40, 255):GetVec4()
			imgui.Separator()
			imgui.SetCursorPosX(425)
			imgui.Text(u8"��������� � ����������");
			imgui.Dummy(imgui.ImVec2(0, 25))
			imgui.Indent(10)

			imgui.Text(fa.ICON_ADDRESS_CARD .. u8"  ��� ������� ����������: ");
			imgui.SameLine();
			imgui.TextColored(colorInfo, PlayerSet.name())
			imgui.Dummy(imgui.ImVec2(0, 5))

			imgui.Text(fa.ICON_HOSPITAL_O .. u8"  ������� � �����������: ");
			imgui.SameLine();
			imgui.TextColored(colorInfo, PlayerSet.org());
			imgui.Dummy(imgui.ImVec2(0, 5))

			imgui.Text(fa.ICON_USER .. u8"  ���������: ");
			imgui.SameLine();
			imgui.TextColored(colorInfo, PlayerSet.rank());
			imgui.Dummy(imgui.ImVec2(0, 5))

			imgui.Text(fa.ICON_TRANSGENDER .. u8"  ���: ");
			imgui.SameLine();
			imgui.TextColored(colorInfo, PlayerSet.sex())
			imgui.EndGroup()
		end
		if select_menu[7] then
			imgui.SameLine()
			imgui.BeginGroup()
			imgui.BeginChild("ustav", imgui.ImVec2(0, 412), true)
			imgui.Text(fa.ICON_ANGLE_RIGHT .. u8" ����� ������������ ���������������");
			imgui.Separator()
			imgui.Dummy(imgui.ImVec2(0, 3))
			if imgui.CollapsingHeader(u8"����� 1 - ����� ���������") then
				imgui.Spacing()
				imgui.TextWrapped(u8"1.1. ������, ���������� � ������, �������� ������������� � ����������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("1.1. ������, ���������� � ������, �������� ������������� � ����������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"1.2. �� ��������� ������ � ������, ���������� � ������, ���������� ������� ���� ��������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("1.2. �� ��������� ������ � ������, ���������� � ������, ���������� ������� ���� ��������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"1.3. ������ ���������� ������������ ��������������� ������������ �� ���������� ���������������� �� �������� � ����� ������ �����, ���������� �������� � ���������� ������������� �����������, ������������� ����������� � �������� �������� �������, ��������������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("1.3. ������ ���������� ������������ ��������������� ������������ �� ���������� ���������������� �� �������� � ����� ������ �����, ���������� �������� � ���������� ������������� �����������, ������������� ����������� � �������� �������� �������, ��������������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"1.4. ��������� �������� ��� ���������� ������������ ��������������� �������� ������ ����������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("1.4. ��������� �������� ��� ���������� ������������ ��������������� �������� ������ ����������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"1.5. ��������� ������ ���������� ����� ���� �������� ���������� ��������� ��� ����������, �� ���������� ����������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("1.5. ��������� ������ ���������� ����� ���� �������� ���������� ��������� ��� ����������, �� ���������� ����������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"1.7. ����������� ��������� �� ��������������� � ���������� ���������������, ����� ���� ��������� �� ��������� ��������: ")
				if imgui.IsItemClicked(0) then
					setClipboardText("1.7. ����������� ��������� �� ��������������� � ���������� ���������������, ����� ���� ��������� �� ��������� ��������: ")
				end
				imgui.Spacing()
				imgui.Bullet()
				imgui.TextColoredRGB("{f7cc46}������ ����������������� ����������?")
				imgui.Bullet()
				imgui.TextColoredRGB("{f7cc46}���������� � ����� ����� 5 ���?")
				imgui.Bullet()
				imgui.TextColoredRGB("{f7cc46}������� ���������� � ���. ����� (����������������, ������� � ������������������ �����������")
				imgui.Bullet()
				imgui.TextColoredRGB("{f7cc46}�� ���������� � ������ ������ ���.�������� ��� ������������?")
				imgui.Bullet()
				imgui.TextColoredRGB("{f7cc46}������������ ������� 1 �������� �� ���������������?")
				imgui.Bullet()
				imgui.TextColoredRGB("{f7cc46}�� ������� ����.�����/��������/������������ �������������.")
				imgui.Spacing()
				imgui.TextColoredRGB("1.8 �� ������������ ��� ������ ��������� ������ �� ������ ���� �������� � ������ ������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("1.8 �� ������������ ��� ������ ��������� ������ �� ������ ���� �������� � ������ ������.")
				end
			end
			imgui.Dummy(imgui.ImVec2(0, 5)) 
			if imgui.CollapsingHeader(u8"����� 2 - ����������") then
				imgui.Spacing()
				imgui.TextWrapped(u8"2.1. ������� ����� ������������ ������������ ���������������, ���������� �� ��������� ����������, ���������� �� ������������ �����, �������� ������������ ������� ������������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.1. ������� ����� ������������ ������������ ���������������, ���������� �� ��������� ����������, ���������� �� ������������ �����, �������� ������������ ������� ������������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"2.1.1. � ������� ����� ������������ ������������ ��������������� � ���������� ����� ������ ����������� ����������� �������, ��������, ����������� � �.�., �.�.")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.1.1. � ������� ����� ������������ ������������ ��������������� � ���������� ����� ������ ����������� ����������� �������, ��������, ����������� � �.�., �.�.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"2.1.1.2. ��������� �������� �������� ���.������, ������������ �������� �������� ������� ���.������ ������������ �������� �������, � ����� ����������� ������������ ���������������")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.1.1.2. ��������� �������� �������� ���.������, ������������ �������� �������� ������� ���.������ ������������ �������� �������, � ����� ����������� ������������ ���������������")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"2.1.1.2. ��� ���������� � ����� ����������� ������������ ������� ���.������, ��������� ��������������� �� ����������� ���.������� ��������� � ���������� 8 ���������� ���������")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.1.1.2. ��� ���������� � ����� ����������� ������������ ������� ���.������, ��������� ��������������� �� ����������� ���.������� ��������� � ���������� 8 ���������� ���������")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"2.2. ��������� �������� ������ �����, � ����� ������ ������������ ������������� (������� �������)")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.2. ��������� �������� ������ �����, � ����� ������ ������������ ������������� (������� �������)")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"2.3. ���������� ������������ ��������������� ��������� ����������� ����������� � �������� ������� � ����������� ���������������, � ����� ����������� �����������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.3. ���������� ������������ ��������������� ��������� ����������� ����������� � �������� ������� � ����������� ���������������, � ����� ����������� �����������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"2.4. ���������� ���� ��� ���������� ����������/��������� �������� ������� � �����������")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.4. ���������� ���� ��� ���������� ����������/��������� �������� ������� � �����������")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"2.4.1. ���� ��������� ������������ ��������������� ������� �������� ���������� ��������, ��� ������ ���� ���������, ����� ���� , ���������� ������ ������ �������� �������������� � ��������� �� �� ������������ ��������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.4.1. ���� ��������� ������������ ��������������� ������� �������� ���������� ��������, ��� ������ ���� ���������, ����� ���� , ���������� ������ ������ �������� �������������� � ��������� �� �� ������������ ��������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("2.5. ��������� �������� ������������� ����� ������ [���]. �� ��������� ������� ������ ���������\n������� {FF0000}[�������]{FFFFFF}")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.5. ��������� �������� ������������� ����� ������ [���]. �� ��������� ������� ������ ��������� ������� [�������].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"2.6. ��������� ������� � ����������� �����������/������ [����� � ����������� � ���.������/������]")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.6. ��������� ������� � ����������� �����������/������ [����� � ����������� � ���.������/������]")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"2.7. ��������� ��������� ������ ��� �������/������� ��������� ������ ������� ����������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.7. ��������� ��������� ������ ��� �������/������� ��������� ������ ������� ����������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"2.8. ������������ ��������� ������������� ��������� �������/����������� ������������� ��������, ���������� ��������� ���������� �� ��� ���������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.8. ������������ ��������� ������������� ��������� �������/����������� ������������� ��������, ���������� ��������� ���������� �� ��� ���������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("2.9. ��������� ������������ ��������������� ������ ��������� ������� �� � ����� ����� �����\n��� ����� ��������.��������� ��������� �������������� � ��������� � ����� ����. [��, �����]\n�� ��� ��������� ������� {FF0000}[�������]{FFFFFF}, �� ����� ������� ��������� - ����������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.9. ��������� ������������ ��������������� ������ ��������� ������� �� � ����� ����� ����� ��� ����� ��������. ��������� ��������� �������������� � ��������� � ����� ����. [��, �����] �� ��� ��������� ������� [�������], �� ����� ������� ��������� - ����������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"2.10. ��������� ����������� ��������� � ����� ����������� ������, ������������� ������ � ����������������. [�����, ������ �.�.�] �� ��������� ������� ������ ��������� ����������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.10. ��������� ����������� ��������� � ����� ����������� ������, ������������� ������ � ����������������. [�����, ������ �.�.�] �� ��������� ������� ������ ��������� ����������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"2.11. ������������ ��������� ������ ��������� ������������� � �������������� �������� ��� ����� �������� ������������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.11. ������������ ��������� ������ ��������� ������������� � �������������� �������� ��� ����� �������� ������������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("2.11.1. ��������� ������/�������/��������� � ���.������. ����������: ������ ����� � ���\n������ ���� ��� ����� ������ �������� ��� ������ ������� �����. �� ��������� �������\n������ ��������� ������� {f7cc46}[��������������]{FFFFFF}, ����������� ��������� ������� ������ - {FF0000}[�������]{FFFFFF}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.11.1. ��������� ������/�������/��������� � ���.������. ����������: ������ ����� � ��� ������ ���� ��� ����� ������ �������� ��� ������ ������� �����. �� ��������� ������� ������ ��������� ������� [��������������], ����������� ��������� ������� ������ - [�������].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("2.12 ������������ ���������� ������ ��������: �� ����� 5 �������� � ���. (��� ������ ��������).\n�� ��������� ������� ������, ��������� ������� {f7cc46}[��������������]{FFFFFF}, ������������ ���������\n������� ������ - {FF0000}[�������/����������]{FFFFFF}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.12 ������������ ���������� ������ ��������: �� ����� 5 �������� � ���. (��� ������ ��������). �� ��������� ������� ������, ��������� ������� [��������������], ������������ ��������� ������� ������ - [�������/����������].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("2.13. ��������� �������� ����� �� ���.������, � ������� ������������ ������ ���������.\n�� ��� ��������� ������� {FF0000}[�������]{FFFFFF}, �� ����� ������� - ����������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.13. ��������� �������� ����� �� ���.������, � ������� ������������ ������ ���������. �� ��� ��������� ������� [�������], �� ����� ������� - ����������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("2.14. ��������� ������� ����������� � ������ ���.������. �� ��������� ������� ������ ���������\n������� {FF0000}[�������]{FFFFFF}. [���������� ��-�������]")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.14. ��������� ������� ����������� � ������ ���.������. �� ��������� ������� ������ ��������� ������� [�������]. [���������� ��-�������]")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("2.15. ���������� ��������� �������� ��� ���������� � ������� �������� �����,\n�� ��������� - {FF0000}[�������]{FFFFFF}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.15. ���������� ��������� �������� ��� ���������� � ������� �������� �����, �� ��������� - [�������].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"2.16. ��������� ������������ ��������������� ������ �������� � ���������� ����� ������ �� ��")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.16. ��������� ������������ ��������������� ������ �������� � ���������� ����� ������ �� ��")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"2.17. ��������� ������������� ������ ���� ������. (������: ������������� ������, �������� ������)")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.17. ��������� ������������� ������ ���� ������. (������: ������������� ������, �������� ������)")
				end
			end
			imgui.Dummy(imgui.ImVec2(0, 5)) 
			if imgui.CollapsingHeader(u8"����� 3. - �������� ����������� ������ ������� �����") then
				imgui.Spacing()
				imgui.TextColoredRGB("3.1. ��������� �������� ���� �� �������,���.�����/�������/������. �������� ���� �����������.\n�� ��������� ������� ������ ��������� ������� {FF0000}[�������]{FFFFFF}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("3.1. ��������� �������� ���� �� �������,���.�����/�������/������. �������� ���� �����������.\n�� ��������� ������� ������ ��������� ������� [�������].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"3.2. ����������� �������� ������ ������� ����������� ������ ������������ � ���, ���������� �� ��� ��������� � ��������, ������������� ���������, �������/�����������/������������ ��������������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("3.2. ����������� �������� ������ ������� ����������� ������ ������������ � ���, ���������� �� ��� ��������� � ��������, ������������� ���������, �������/�����������/������������ ��������������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("3.4. ������������� ��������� ������ ��� ����������� �������� � ������� ������� � ����������\n[������������� ��������� ������ ��� ��������� ��] �� ��������� ������� ������ ���������\n������� {FF0000}[�������]{FFFFFF}, �� ����� ������� ��������� ������� ������ - {FF0000}����������{FFFFFF}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("3.4. ������������� ��������� ������ ��� ����������� �������� � ������� ������� � ���������� [������������� ��������� ������ ��� ��������� ��] �� ��������� ������� ������ ��������� ������� [�������], �� ����� ������� ��������� ������� ������ - ����������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"3.5. ��������� ������������ ��������������� ����� ����� �������� �� ����� ������� � 3 ���������� ��������� � ���.������, ����� �� ���������� �������� ���� ������ �������������� ������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("3.5. ��������� ������������ ��������������� ����� ����� �������� �� ����� ������� � 3 ���������� ��������� � ���.������, ����� �� ���������� �������� ���� ������ �������������� ������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("3.5.1. � ������, ���� ��������� ������ �����, � �� ������� �� ���� - �� ������� {FF0000}[�������]{FFFFFF}.\n���� �������� �� ������� �� �� ������� ����� �� ��������� - ��������� ����� ��������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("3.5.1. � ������, ���� ��������� ������ �����, � �� ������� �� ���� - �� ������� [�������]. ���� �������� �� ������� �� �� ������� ����� �� ��������� - ��������� ����� ��������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"3.6. ��������� ������������ ���������������, ����������� �������� �������� � ������� 7 ���������� ��������� � ���.������� �����, ������ ����� � ����� ���������� ���� ��� �� ��������� ��� �������� ������ � ��������� ����� � �������� ������������� ������������ ����� ��� ����������� ������")
				if imgui.IsItemClicked(0) then
					setClipboardText("3.6. ��������� ������������ ���������������, ����������� �������� �������� � ������� 7 ���������� ��������� � ���.������� �����, ������ ����� � ����� ���������� ���� ��� �� ��������� ��� �������� ������ � ��������� ����� � �������� ������������� ������������ ����� ��� ����������� ������")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"3.6.1. � ����������� �������� ����� ������� ���������������, ������ ���������� ���������� �������� � ������ ��� �� ��������")
				if imgui.IsItemClicked(0) then
					setClipboardText("3.6.1. � ����������� �������� ����� ������� ���������������, ������ ���������� ���������� �������� � ������ ��� �� ��������")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"3.7. ������������� ��������� ��������� ��������, �� ��������� ��� ������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("3.7. ������������� ��������� ��������� ��������, �� ��������� ��� ������.")
				end
				imgui.TextColoredRGB("{f7cc46}[������������� ��������� ��������� �������� � ��������/���. ������ �� ����!]")
			end
			imgui.Dummy(imgui.ImVec2(0, 5)) 
			if imgui.CollapsingHeader(u8"����� 4. - ������������������ ���������") then
				imgui.Spacing()
				imgui.TextColoredRGB("4.1. ��������� ��������� ����� ������������� � ������� �����. �� ��������� ������� ������\n��������� ������� - {FF0000}[�������]{FFFFFF}")
				if imgui.IsItemClicked(0) then
					setClipboardText("4.1. ��������� ��������� ����� ������������� � ������� �����. �� ��������� ������� ������ ��������� ������� - [�������]")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"4.2. ��������� ��� �������������� ������, ����������� �� �� ������ ������ ��������� ���.")
				if imgui.IsItemClicked(0) then
					setClipboardText("4.2. ��������� ��� �������������� ������, ����������� �� �� ������ ������ ��������� ���.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"4.2.1. ��������������� �� ��������� ��� ������������� ������� ���, ����� ��������� ���� ������������� � ������ ����� �� ����������, ������� �������� �������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("4.2.1. ��������������� �� ��������� ��� ������������� ������� ���, ����� ��������� ���� ������������� � ������ ����� �� ����������, ������� �������� �������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"4.2.2. ������������� ��������� ������� ������� �������� �����.")
				if imgui.IsItemClicked(0) then
					setClipboardText("4.2.2. ������������� ��������� ������� ������� �������� �����.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"4.3. ������ ������ �������� ����. ���������. �� �������� ��� ������ ����������� ������ �������������� ������������ ����������� ���. ��������������� ��� ���������� ����. ��������, � ������ �������� �� ������ �� �����.")
				if imgui.IsItemClicked(0) then
					setClipboardText("4.3. ������ ������ �������� ����. ���������. �� �������� ��� ������ ����������� ������ �������������� ������������ ����������� ���. ��������������� ��� ���������� ����. ��������, � ������ �������� �� ������ �� �����.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"4.3.1. ������������� ����.������� �������� ����� ������ ���� �� ������ �� �����, ���� ����� �������� � ���.�����.")
				if imgui.IsItemClicked(0) then
					setClipboardText("4.3.1. ������������� ����.������� �������� ����� ������ ���� �� ������ �� �����, ���� ����� �������� � ���.�����.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"4.3.2. ������������� ����.�������� � ������ � ������ ����� ���������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("4.3.2. ������������� ����.�������� � ������ � ������ ����� ���������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"3.7. ������������� ��������� ��������� ��������, �� ��������� ��� ������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("3.7. ������������� ��������� ��������� ��������, �� ��������� ��� ������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("4.4. ������������� ��������� ����� {f7cc46}[���]{FFFFFF} � ������ ������� �������� �����.")
				if imgui.IsItemClicked(0) then
					setClipboardText("4.4. ������������� ��������� ����� [���] � ������ ������� �������� �����.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("4.5. ��������� ������/�������� ���������. [��������� ���������� ������] �� ��������� �������\n������ ��������� ������� - {FF0000}[�������]{FFFFFF}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("4.5. ��������� ������/�������� ���������. [��������� ���������� ������] �� ��������� ������� ������ ��������� ������� - [�������].")
				end
			end
			imgui.Dummy(imgui.ImVec2(0, 5)) 
			if imgui.CollapsingHeader(u8"����� 5. - ���������/���������/��������/����������") then
				imgui.Spacing()
				imgui.TextColoredRGB("5.1. ��������� �������� �� ��������� [�����-���� �������]. ������������ ��������� ��� �����\n�� ����������� �������� ��� ���������, �����������. �� ��������� ������� ������ ���������\n������� {FF0000}[�������]{FFFFFF}, ������������ ��������� ������� ������ - {FF0000}[����������]{FFFFFF}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("5.1. ��������� �������� �� ��������� [�����-���� �������]. ������������ ��������� ��� ����� �� ����������� �������� ��� ���������, �����������. �� ��������� ������� ������ ��������� ������� [�������], ������������ ��������� ������� ������ - [����������].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("5.2. ������� 3 ��������� �������� �����������. ����� {FF0000}[�������]{FFFFFF} ����� ����� ����������� ������ ��\n��.������� ����� ''������� ������ ���������''")
				if imgui.IsItemClicked(0) then
					setClipboardText("5.2. ������� 3 ��������� �������� �����������. ����� [�������] ����� ����� ����������� ������ �� ��.������� ����� ''������� ������ ���������''")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"5.3. ����������� �������� ����� ���� ������ ��: ������, ������ ������, ������������ ������ ��/������ ����������,������ �� ��, ������ ������� ������������, �� ������� �����������, � ����� �� ������������ �������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("5.3. ����������� �������� ����� ���� ������ ��: ������, ������ ������, ������������ ������ ��/������ ����������,������ �� ��, ������ ������� ������������, �� ������� �����������, � ����� �� ������������ �������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("5.4. ���� ��������� ����������� � ��������� {f7cc46}'������ / (1 ����)'{FFFFFF}, �� �� ��������� � ׸���� ������ ����\n���.������, � �������� �� ��������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("5.4. ���� ��������� ����������� � ��������� '������ / (1 ����)', �� �� ��������� � ׸���� ������ ���� ���.������, � �������� �� ��������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"5.5. ��������� ����������� � �������� �� ������ ��������. �� ������������ ��������� ����������!")
				if imgui.IsItemClicked(0) then
					setClipboardText("5.5. ��������� ����������� � �������� �� ������ ��������. �� ������������ ��������� ����������!")
				end
				imgui.Spacing()
				imgui.TextColoredRGB("{f7cc46}[������� ��������� �� ��� ����. �� ��������� ����: ''����� {FF0000}[�������]{f7cc46} in ic'' ��������� ��������\n{f7cc46}��� ���� ������� 'in ic']")
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"5.6. ����������� �������� �������� ������� ����� ����� �� ��������� � ��������� ������ ����� ������������ ������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("5.6. ����������� �������� �������� ������� ����� ����� �� ��������� � ��������� ������ ����� ������������ ������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("5.7. ����������� ��������, ���������� ������������ �������� ����� � ����� �������� {FF0000}[��������]{FFFFFF} ���\n������ {f7cc46}[��������������]{FFFFFF} �������������� �������� ��������� ���.������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("5.7. ����������� ��������, ���������� ������������ �������� ����� � ����� �������� [��������] ��� ������ [��������������] �������������� �������� ��������� ���.������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"5.8.�������� ���� � ����� ��� ���� �������� ����������� � ���������� � ������ ������ ������������ ���������������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("5.8.�������� ���� � ����� ��� ���� �������� ����������� � ���������� � ������ ������ ������������ ���������������.")
				end
			end
			imgui.Dummy(imgui.ImVec2(0, 5)) 
			if imgui.CollapsingHeader(u8"����� 6. - ������") then
				imgui.Spacing()
				imgui.TextWrapped(u8"6.1. ��������� �� ������ ����� ������ ���� ��� � 14 ���� [������ ���� ���������� � ������� ������ �� �������].")
				if imgui.IsItemClicked(0) then
					setClipboardText("6.1. ��������� �� ������ ����� ������ ���� ��� � 14 ���� [������ ���� ���������� � ������� ������ �� �������].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("6.2. � ������ ����� ������� ������ � {f7cc46}5{FFFFFF}-�� ���������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("6.2. � ������ ����� ������� ������ � 5-�� ���������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"6.3. ������������ ���� ������� ���������� - 7 ���� [�����������/������, �� ����� ����� ������, ������ �������].")
				if imgui.IsItemClicked(0) then
					setClipboardText("6.3. ������������ ���� ������� ���������� - 7 ���� [�����������/������, �� ����� ����� ������, ������ �������].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"6.4. � ������ ����� ������� ��������� 7 ���� � ���.������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("6.4. � ������ ����� ������� ��������� 7 ���� � ���.������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("6.5. � ������ ����������� ������ �����������, ������� ����� �� ����� 1 ����������� {FF0000}[��������]{FFFFFF}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("6.5. � ������ ����������� ������ �����������, ������� ����� �� ����� 1 ����������� [��������].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"6.6. ���� �� ��������� �������, ��������� �� ��������� � ����� ������ ������������, ��� ��������� ������������ � �������������� ��������, ���� �� ��������� [������ / (1 ����)].")
				if imgui.IsItemClicked(0) then
					setClipboardText("6.6. ���� �� ��������� �������, ��������� �� ��������� � ����� ������ ������������, ��� ��������� ������������ � �������������� ��������, ���� �� ��������� [������ / (1 ����)].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"6.7. �� ����� ������� ����������� �������� � ������ ��������������� � ����������� �����������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("6.7. �� ����� ������� ����������� �������� � ������ ��������������� � ����������� �����������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"6.8. � ������ ����� ���� ������ �� ��������� � ������ ��� ������� �� ��������� ��������� ������������ ���.������� ������ ������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("6.8. � ������ ����� ���� ������ �� ��������� � ������ ��� ������� �� ��������� ��������� ������������ ���.������� ������ ������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"6.8.1. ����� � ������, ���.�������� ������ ����� �����, ����� � ������� �� ����� ������� [���������, �������������� ������� ��������� �� ������, � ����������� �������].")
				if imgui.IsItemClicked(0) then
					setClipboardText("6.8.1. ����� � ������, ���.�������� ������ ����� �����, ����� � ������� �� ����� ������� [���������, �������������� ������� ��������� �� ������, � ����������� �������].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"6.9. � ������, ���� ���.�������� ������������ � ��������� ����, ��� ��������� �����������������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("6.9. � ������, ���� ���.�������� ������������ � ��������� ����, ��� ��������� �����������������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"6.10. � ������, ���� ���.�������� �� ������������ � ��������� ����, ��� ��������� ������������ ������������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("6.10. � ������, ���� ���.�������� �� ������������ � ��������� ����, ��� ��������� ������������ ������������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"6.11. � ��������� �� ������ ����������� ����� ������� ���� ������ ������� � ���� �����. � ��������� ������, � ������� ����� ��������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("6.11. � ��������� �� ������ ����������� ����� ������� ���� ������ ������� � ���� �����. � ��������� ������, � ������� ����� ��������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"6.12. ��������� ������������ �� ������� ������ ���������� �����.")
				if imgui.IsItemClicked(0) then
					setClipboardText("6.12. ��������� ������������ �� ������� ������ ���������� �����.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"6.13. �� ��������� �������, �� ������ ��������� � ����.������ ������ ���.������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("6.13. �� ��������� �������, �� ������ ��������� � ����.������ ������ ���.������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"6.14. ���� ��������� �� ����� ������� ��� ������� ����������� �������������� [warn/ban], �� �������������� �� ��������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("6.14. ���� ��������� �� ����� ������� ��� ������� ����������� �������������� [warn/ban], �� �������������� �� ��������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"6.15. � ������ ������ ������ �� �������, ������� ���� ����� ����� �������� ��� � ���������, ���� ���� �� �� ���������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("6.15. � ������ ������ ������ �� �������, ������� ���� ����� ����� �������� ��� � ���������, ���� ���� �� �� ���������.")
				end
			end
			imgui.Dummy(imgui.ImVec2(0, 5)) 
			if imgui.CollapsingHeader(u8"����� 7. - ������� �� �����") then
				imgui.Spacing()
				imgui.TextColoredRGB("7.1. ��������� �������, ���������� ��� ����� ���� � ����� ����������� (/r), �� ������ ��� �\n���������� ������� �����, ��� ��������� ������� {FF0000}[�������/����������]{FFFFFF}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("7.1. ��������� �������, ���������� ��� ����� ���� � ����� ����������� (/r), �� ������ ��� � ���������� ������� �����, ��� ��������� ������� [�������/����������].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("7.2. ��������� �������� � ����� ����� [/d] ��� ������������ �������. �� ������������ �������\n������� ��������� ������� {FF0000}[�������]{FFFFFF}, ��� ������������ ��������� ��������� ������� {FF0000}[����������]{FFFFFF}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("7.2. ��������� �������� � ����� ����� [/d] ��� ������������ �������. �� ������������ ������� ������� ��������� ������� [�������], ��� ������������ ��������� ��������� ������� [����������].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"7.3. ��������� �������� ��������� � ����� ����������� � ����� �����.")
				if imgui.IsItemClicked(0) then
					setClipboardText("7.3. ��������� �������� ��������� � ����� ����������� � ����� �����.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"7.5. ��������� ������������� ����� ���� � �����.")
				if imgui.IsItemClicked(0) then
					setClipboardText("6.15. � ������ ������ ������ �� �������, ������� ���� ����� ����� �������� ��� � ���������, ���� ���� �� �� ���������.")
				end
				imgui.TextColoredRGB("{f7cc46}[������� ��������� �� ��� ����. �� ��������� �� ����: '������ ��� in ic' ��������� �������� {FF0000}[�������]{f7cc46}.")
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"7.6. ��������� ������ ����� ����� ��������� ��� ������ ��. ����� ��� ��� ����������� �� �������� ��� � ������ ��������, �� �� �� �����, �.� ��� ����� ������� ��� ���������� ���.������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("7.6. ��������� ������ ����� ����� ��������� ��� ������ ��. ����� ��� ��� ����������� �� �������� ��� � ������ ��������, �� �� �� �����, �.� ��� ����� ������� ��� ���������� ���.������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"7.7. � ����� ��������� ������ ��������� ������������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("7.7. � ����� ��������� ������ ��������� ������������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("7.7.1. �� �� ���������� ������������ � �������, ������������ ������� - ��������� �����\n������� {FF0000}[�������]{ffffff}. ���� ���-�� �������� �� ����������� � ���, �� �� ������ �������� ������ �� �����\n������ ������ ��� ����, ����� ���� ����� ������� ���������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("7.7.1. �� �� ���������� ������������ � �������, ������������ ������� - ��������� ����� ������� [�������]. ���� ���-�� �������� �� ����������� � ���, �� �� ������ �������� ������ �� ����� ������ ������ ��� ����, ����� ���� ����� ������� ���������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("7.8.2. �� �����, ��������� ����� ����� � ������ ������������� - ����� �� 1 ��� ��������\n[������ ��������������], �� 2 ��� �������� �������� ���� ��� {FF0000}[�������]{ffffff}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("7.8.2. �� �����, ��������� ����� ����� � ������ ������������� - ����� �� 1 ��� �������� [������ ��������������], �� 2 ��� �������� �������� ���� ��� [�������].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("7.9. ��������� ��������� ������ � ����� ����� 1 ���� � ��� (�� ���� �����������)\n�� ���������������� ������ ��������� ������� {FF0000}[�������]{ffffff}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("7.9. ��������� ��������� ������ � ����� ����� 1 ���� � ��� (�� ���� �����������) �� ��������� ������� ������ ��������� ������� [�������].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"7.9.1 ������ ���������� � ����� �� ����� ���� ������� � ������ �� ���������/������ ��������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("7.9.1 ������ ���������� � ����� �� ����� ���� ������� � ������ �� ���������/������ ��������.")
				end
			end
			imgui.Dummy(imgui.ImVec2(0, 5)) 
			if imgui.CollapsingHeader(u8"����� 8. - ������� �����") then
				imgui.Spacing()
				imgui.TextColoredRGB("8.1. � ������� ����� ���������� ��������� ����������� [���������] �� ������������ [��������� �\n�� �������������]. �� ��������� {FF0000}[�������]{FFFFFF}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("8.1. � ������� ����� ���������� ��������� ����������� [���������] �� ������������ [��������� � �� �������������]. �� ��������� [�������].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("8.1.2. � ������� ����� � �� � ������� ����� � ����� ���������� ��������� ��������\n����������� �����, ����������� ����, ���������,���������,������. �� ��������� {FF0000}[�������]{FFFFFF}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("8.1.2. � ������� ����� � �� � ������� ����� � ����� ���������� ��������� �������� ����������� �����, ����������� ����, ���������,���������,������. �� ��������� [�������].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("8.1.3. �� ������ � ����� � ����� ����� ��������� ����� ������. � 4-�� ��������� � ���� ���������\n�������� {FF0000}[�������]{FFFFFF}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("8.1.3. �� ������ � ����� � ����� ����� ��������� ����� ������. � 4-�� ��������� � ���� ��������� �������� [�������].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"8.2. ������� ����� ����������� ��������, ��������� � ������� ������������ ���������������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("8.2. ������� ����� ����������� ��������, ��������� � ������� ������������ ���������������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"8.2.1. ������� ������:")
				imgui.Spacing()
				imgui.TextColoredRGB("{f7cc46}������� ����:")
				imgui.TextColoredRGB("{f7cc46}� ����������� - �������: 10:00 - 21:00")
				imgui.TextColoredRGB("{f7cc46}� ������� - �����������: 11:00 - 19:00")
				imgui.TextColoredRGB("{f7cc46}� ��������� �������: 13:00 - 14:00")
				imgui.TextColoredRGB("{f7cc46}� �������� �������: 18:00 - 19:00 (����� ������� � �����������)")
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"8.3. ������ ��������� ����� ����� �� ��������� ������� [������� ���������� ��������].")
				if imgui.IsItemClicked(0) then
					setClipboardText("8.3. ������ ��������� ����� ����� �� ��������� ������� [������� ���������� ��������].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"8.3.1. � ��������� �����, ��������� ����������� ������ ��������� �� ����� ������ � ���.������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("8.3.1. � ��������� �����, ��������� ����������� ������ ��������� �� ����� ������ � ���.������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"8.4. ��������� �������� ���.����� � ������� ����� [����������: ���������� ������ �����������, ��������� �������, ����� �� ������� �����������].")
				if imgui.IsItemClicked(0) then
					setClipboardText("8.4. ��������� �������� ���.����� � ������� ����� [����������: ���������� ������ �����������, ��������� �������, ����� �� ������� �����������].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"8.5. ���� � ����� ���� 1 ��������� ���� 2-�� ���������, �� ������ ��������� � ���.������ � ��������� ����������� ������ ���� ���� ����� ���� 1 ��������� � �����")
				if imgui.IsItemClicked(0) then
					setClipboardText("8.5. ���� � ����� ���� 1 ��������� ���� 2-�� ���������, �� ������ ��������� � ���.������ � ��������� ����������� ������ ���� ���� ����� ���� 1 ��������� � �����")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"8.6. ��������� ������������� �� �����-���� ������ � ������� �����.")
				if imgui.IsItemClicked(0) then
					setClipboardText("8.6. ��������� ������������� �� �����-���� ������ � ������� �����.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"8.7. ���������� ��������� ������ ������� ����� �������� �� � ���.������ ������ ������ [����������: ��/�� ����� �����������].")
				if imgui.IsItemClicked(0) then
					setClipboardText("8.7. ���������� ��������� ������ ������� ����� �������� �� � ���.������ ������ ������ [����������: ��/�� ����� �����������].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("8.7.1. ���� ������� ��������������� ��� ���� ��������� ���.����������� ������ ���-����, �����\n���.������ ��� ������� [������� � �� / �� ����� ���/����� ��� ������ �� ��������] � ������� �����\n�� ����� �������� ��� ����������� �������� ������� - �� ������ ��� ������ �������� ����������\n����.�����. �� ������ - {FF0000}�������{FFFFFF}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("8.7.1. ���� ������� ��������������� ��� ���� ��������� ���.����������� ������ ���-����, ����� ���.������ ��� ������� [������� � �� / �� ����� ���/����� ��� ������ �� ��������] � ������� ����� �� ����� �������� ��� ����������� �������� ������� - �� ������ ��� ������ �������� ���������� ����.�����. �� ������ - �������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("8.7.2. ���� ����������� ���.������� ����� ���������� � ����� �� ����������� ���.������ ���\n������� ������, �������� - ��������������,��������� ��������� ��� ����������� - �������,\n��� ����.����� - {54acd2}3 �������� ���� �� ��������")
				if imgui.IsItemClicked(0) then
					setClipboardText("8.7.2. ���� ����������� ���.������� ����� ���������� � ����� �� ����������� ���.������ ��� ������� ������, �������� - ��������������,��������� ��������� ��� ����������� - �������, ��� ����.����� - 3 �������� ���� �� ��������")
				end
			end
			imgui.Dummy(imgui.ImVec2(0, 5)) 
			if imgui.CollapsingHeader(u8"����� 9. - �������� � �����") then
				imgui.Spacing()
				imgui.TextWrapped(u8"9.1. ��������� ������������ ��������������� ����� ���������� ���.����� � ������� ������ �� ������� �� ������ �����. ������ ���������������� - � ������������ �� ������ �����.")
				if imgui.IsItemClicked(0) then
					setClipboardText("9.1. ��������� ������������ ��������������� ����� ���������� ���.����� � ������� ������ �� ������� �� ������ �����. ������ ���������������� - � ������������ �� ������ �����.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"9.2 ���������� ������������ ��������������� ������� ������ ��������� � ������,������ ������ ������, � ����� ������� ����������� � ������������ ���� ����������� ������� ���.������ ��� ����������� �������� ����� ������� �������� (�������, ��������, ������������).")
				if imgui.IsItemClicked(0) then
					setClipboardText("9.2 ���������� ������������ ��������������� ������� ������ ��������� � ������,������ ������ ������, � ����� ������� ����������� � ������������ ���� ����������� ������� ���.������ ��� ����������� �������� ����� ������� �������� (�������, ��������, ������������).")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("9.2.1 ������� � ������ ������, ������������ ������ � ������� ������������� ���������������\n��������, �� ��������� ������� ������� ��������� ������� - {FF0000}�������{FFFFFF}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("9.2.1 ������� � ������ ������, ������������ ������ � ������� ������������� ��������������� ��������, �� ��������� ������� ������� ��������� ������� - {FF0000}�������{FFFFFF}.")
				end
			end
			imgui.Dummy(imgui.ImVec2(0, 5)) 
			if imgui.CollapsingHeader(u8"����� 10. - �����-��� ����������� ��") then
				imgui.Spacing()
				imgui.TextWrapped(u8"10.1. ���������, ������� ����� � ������������, ������� ����� � ���� ��� ����������. �� ����������� ������ 10.1.1")
				if imgui.IsItemClicked(0) then
					setClipboardText("10.1. ���������, ������� ����� � ������������, ������� ����� � ���� ��� ����������. �� ����������� ������ 10.1.1")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"10.1.1 ���������� ��������� ��������� � ������������ � ����� � ����������� �������, ������ �� ������������, ������������")
				if imgui.IsItemClicked(0) then
					setClipboardText("10.1.1 ���������� ��������� ��������� � ������������ � ����� � ����������� �������, ������ �� ������������, ������������")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"10.2 ������ ���������� �� ��������� ������ ����������, ������� ��������� ����:")
				imgui.TextColoredRGB("{f7cc46}�����, �������, ����� ��������������� (��������: ����� ������), �����, ����, ���� S.W.A.T. �\n{f7cc46}����������� ������ [������ ��� �� � ��], ����������� [������ ��� �� � ��]\n{f7cc46}[����������: ����� ������ �� �����];")
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"10.3. ������ ���������� �� ��������� ������ ����� ����������:")
				imgui.TextColoredRGB("{f7cc46}�������� ����(�� ����. �.10.2.), ������� �� ���, ���, ������, ����������, ����, �����, ����, �����,\n{f7cc46}����� �� �����, ������ �� �����, ������, ����� �� ������������, ������ �� �����, ������ �� �����,\n{f7cc46}�������, ����� �� �����,  ������� �� �����, ����� �����/��������.")
			end
			imgui.Dummy(imgui.ImVec2(0, 5)) 
			if imgui.CollapsingHeader(u8"����� 11 - ������� ����") then
				imgui.Spacing()
				imgui.TextColoredRGB("11.1 ���� Ambulance ����� ����� � [{f7cc46}3{FFFFFF}] ���������� ���������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("11.1 ���� Ambulance ����� ����� � [3] ���������� ���������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("11.2 ���� Premier ����� ����� � [{f7cc46}5{FFFFFF}] ���������� ���������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("11.2 ���� Premier ����� ����� � [5] ���������� ���������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("11.3 ���� Dodge Grand Caravan ����� ����� � [{f7cc46}6{FFFFFF}] ���������� ���������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("11.3 ���� Dodge Grand Caravan ����� ����� � [6] ���������� ���������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("11.4 ���� Ford F150 ����� ����� � [{f7cc46}6{FFFFFF}] ���������� ���������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("11.4 ���� Ford F150 ����� ����� � [6] ���������� ���������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("11.5 ���� Ford Explorer ����� ����� � [{f7cc46}7{FFFFFF}] ���������� ���������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("11.5 ���� Ford Explorer ����� ����� � [7] ���������� ���������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("11.6 ���� Dodge Charger ����� ����� � [{f7cc46}8{FFFFFF}] ���������� ���������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("11.6 ���� Dodge Charger ����� ����� � [8] ���������� ���������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("11.7 �������� Maverick ����� ����� � [{f7cc46}8{FFFFFF}] ���������� ���������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("11.7 �������� Maverick ����� ����� � [8] ���������� ���������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("11.8 ���� Tesla Model X ����� ����� � [{f7cc46}7{FFFFFF}] ���������� ���������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("11.8 ���� Tesla Model X ����� ����� � [7] ���������� ���������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"11.9 ���������� ����������� ����� �� �� ���������, ���� ����������� ��������� ������������ ������������ ��������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("11.9 ���������� ����������� ����� �� �� ���������, ���� ����������� ��������� ������������ ������������ ��������.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("11.9.1 �� ��������� ������ �� ������, ��������� ������� - {FF0000}[�������]{FFFFFF}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("11.9.1 �� ��������� ������ �� ������, ��������� ������� - [�������]")
				end
			end
			imgui.Dummy(imgui.ImVec2(0, 5)) 
			if imgui.CollapsingHeader(u8"����� 12 - ������������� ��������") then
				imgui.Spacing()
				imgui.TextColoredRGB("12.1 ��������� ������������ ����. ������� ���.������ �� �� ���������� (������: ����� ������ �\n������� ���� �� �����, �������� ������) ������ ���������! �� ������ ��� ��������� ������� {FF0000}[�������]{FFFFFF},\n��� ��������� �������, ��������� ����� {FF0000}[������]{FFFFFF}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("12.1 ��������� ������������ ����. ������� ���.������ �� �� ���������� (������: ����� ������ � ������� ���� �� �����, �������� ������) ������ ���������! �� ������ ��� ��������� ������� [�������], ��� ��������� �������, ��������� ����� [������].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"12.2 ������������ ����. ������� ���.������, ����� ������ � ���������� ���������.")
				if imgui.IsItemClicked(0) then
					setClipboardText("12.2 ������������ ����. ������� ���.������, ����� ������ � ���������� ���������.")
				end
				imgui.Spacing()
			end
			imgui.EndChild()
			imgui.EndGroup();
		end
		if select_menu[2] then 
			imgui.SameLine()
			imgui.BeginGroup()
			imgui.BeginChild("settig", imgui.ImVec2(0, 380), true)
			imgui.Text(fa.ICON_ANGLE_RIGHT .. u8" ������ ������ ������������ ��� ������ ��������� ������� ��� ���� ����");
			imgui.Separator()
			imgui.Dummy(imgui.ImVec2(0, 5))
			imgui.Indent(10)
			if imgui.CollapsingHeader(u8"�������� ����������") then
				mainSet()
			end
			imgui.Dummy(imgui.ImVec2(0, 3))
			if imgui.CollapsingHeader(u8"���������") then
				imgui.SetCursorPosX(25)
				imgui.BeginGroup()
				if imgui.Checkbox(u8"������ ����������", cb_chat1) then
					needSave = true 
				end
				if imgui.Checkbox(u8"������ ��������� �������", cb_chat2) then
					needSave = true
				end
				if imgui.Checkbox(u8"������ ������� ���", cb_chat3) then
					needSave = true
				end
				imgui.EndGroup()
			end
			imgui.Dummy(imgui.ImVec2(0, 5)) 
			if imgui.CollapsingHeader(u8"������� ��������") then
				imgui.SetCursorPosX(25);
				imgui.BeginGroup()
				imgui.PushItemWidth(60); 
				imgui.Spacing()
				if imgui.InputText(u8"�������", buf_lec, imgui.InputTextFlags.CharsDecimal) then
					needSave = true
				end
				imgui.Spacing()
				if imgui.InputText(u8"������ ��������", buf_rec, imgui.InputTextFlags.CharsDecimal) then
					needSave = true
				end
				imgui.Spacing()
				if imgui.InputText(u8"������� �� ����������������", buf_narko, imgui.InputTextFlags.CharsDecimal) then
					needSave = true
				end
				imgui.Spacing()
				if imgui.InputText(u8"�������� ����", buf_tatu, imgui.InputTextFlags.CharsDecimal) then
					needSave = true
				end
				imgui.Spacing()
				if imgui.InputText(u8"������ �����������", buf_antb, imgui.InputTextFlags.CharsDecimal) then
					needSave = true
				end
				imgui.Spacing()
				imgui.Spacing()
				if imgui.InputText(u8"���� ��� ����� �� 7 ����", buf_medcard1, imgui.InputTextFlags.CharsDecimal) then
					needSave = true
				end
				imgui.Spacing()
				if imgui.InputText(u8"���� ��� ����� �� 14 ����", buf_medcard2, imgui.InputTextFlags.CharsDecimal) then
					needSave = true
				end
				imgui.Spacing()
				if imgui.InputText(u8"���� ��� ����� �� 30 ����", buf_medcard3, imgui.InputTextFlags.CharsDecimal) then
					needSave = true
				end
				imgui.Spacing()
				if imgui.InputText(u8"���� ��� ����� �� 60 ����", buf_medcard4, imgui.InputTextFlags.CharsDecimal) then
					needSave = true
				end
				imgui.Spacing()
				imgui.PopItemWidth()
				imgui.EndGroup();
				imgui.Spacing()
				imgui.TextWrapped(u8"����� �������� ������ ������ �� ������ �� ���� forum.arizona-rp.com -> ������� ������: ��� ������� ������ -> ���. ��������� -> ���.�����.")
			end
			imgui.EndChild();
			imgui.PushStyleColor(imgui.Col.Button, needSaveColor)
			if imgui.Button(u8"���������", imgui.ImVec2(688, 20)) then
				setting.nick = u8:decode(buf_nick.v)
				setting.teg = u8:decode(buf_teg.v)
				setting.org = num_org.v
				setting.sex = num_sex.v
				setting.rank = num_rank.v
				setting.lec = buf_lec.v
				setting.rec = buf_rec.v
				setting.narko = buf_narko.v
				setting.tatu = buf_tatu.v
				setting.antb = buf_antb.v
				setting.medcard1 = buf_medcard1.v
				setting.medcard2 = buf_medcard2.v
				setting.medcard3 = buf_medcard3.v
				setting.medcard4 = buf_medcard4.v
				setting.chat1 = cb_chat1.v
				setting.chat2 = cb_chat2.v
				setting.chat3 = cb_chat3.v
				setting.orgl = {}
				setting.rankl = {}
				for i,v in ipairs(chgName.org) do
					setting.orgl[i] = u8:decode(v)
				end
				for i,v in ipairs(chgName.rank) do
					setting.rankl[i] = u8:decode(v)
				end
				local f = io.open(dirml.."/MedicalHelper/MainSetting.json", "w")
				f:write(encodeJson(setting))
				f:flush()
				f:close()
				sampAddChatMessage("{FFFFFF}["..script_names.."]: ��������� ���������.", 0xEE4848)
				needSave = false
			end
			imgui.PopStyleColor(1)
			imgui.EndGroup()
		end
		if select_menu[3] then
			imgui.SameLine()
			imgui.BeginGroup()
			imgui.BeginChild("spur list", imgui.ImVec2(140, 380), true)
			imgui.SetCursorPosX(10)
			imgui.Text(u8"������ ���������")
			imgui.Separator()
			for i,v in ipairs(spur.list) do
				if imgui.Selectable(u8(spur.list[i]), spur.select_spur == i) then 
					spur.select_spur = i 
					spur.text.v = ""
					spur.name.v = ""
					spur.edit = false
					spurBig.v = false
				end
			end
			imgui.EndChild()
			if imgui.Button(u8"��������", imgui.ImVec2(140, 20)) then
				if #spur.list ~= 20 then
					for i = 1, 20 do
						if not table.concat(spur.list, "|"):find("��������� '"..i.."'") then
							table.insert(spur.list, "��������� '"..i.."'")
							spur.edit = true
							spur.select_spur = #spur.list
							spur.name.v = ""
							spur.text.v = ""
							spurBig.v = false
							local f = io.open(dirml.."/MedicalHelper/���������/��������� '"..i.."'.txt", "w")
							f:write("")
							f:flush()
							f:close()
							break
						end
					end
				end
			end
			imgui.EndGroup()
			imgui.SameLine()
			imgui.BeginGroup()
			if spur.edit and not spurBig.v then
				imgui.SetCursorPosX(515)
				imgui.Text(u8"���� ��� ����������")
				imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(70, 70, 70, 200):GetVec4())
				imgui.InputTextMultiline("##spur", spur.text, imgui.ImVec2(525, 284))
				imgui.PopStyleColor(1)
				imgui.PushItemWidth(400)
				if imgui.Button(u8"������� ������� ��������/��������", imgui.ImVec2(525, 20)) then
					spurBig.v = not spurBig.v
				end
				imgui.Spacing() 
				imgui.InputText(u8"�������� �����", spur.name, imgui.InputTextFlags.CallbackCharFilter, filter(1, "[%w�-�%+%�%#%(%)]"))
				imgui.Spacing()
				imgui.PopItemWidth()
				if imgui.Button(u8"�������", imgui.ImVec2(260, 20)) then
					if doesFileExist(dirml.."/MedicalHelper/���������/"..spur.list[spur.select_spur]..".txt") then
						os.remove(dirml.."/MedicalHelper/���������/"..spur.list[spur.select_spur]..".txt")
					end
					table.remove(spur.list, spur.select_spur) 
					spur.edit = false
					spur.select_spur = -1
					spur.name.v = ""
					spur.text.v = ""
				end
				imgui.SameLine()
				if imgui.Button(u8"���������", imgui.ImVec2(260, 20)) then
					local name = ""
					local bool = false
					if spur.name.v ~= "" then 
							name = u8:decode(spur.name.v)
							if doesFileExist(dirml.."/MedicalHelper/���������/"..name..".txt") and spur.list[spur.select_spur] ~= name then
								bool = true
								imgui.OpenPopup(u8"������")
							else
								os.remove(dirml.."/MedicalHelper/���������/"..spur.list[spur.select_spur]..".txt")
								spur.list[spur.select_spur] = u8:decode(spur.name.v)
							end
					else
						name = spur.list[spur.select_spur]
					end
					if not bool then
						local f = io.open(dirml.."/MedicalHelper/���������/"..name..".txt", "w")
						f:write(u8:decode(spur.text.v))
						f:flush()
						f:close()
						spur.text.v = ""
						spur.name.v = ""
						spur.edit = false
					end
				end
				elseif spurBig.v then
					imgui.Dummy(imgui.ImVec2(0, 150))
					imgui.SetCursorPosX(500)
					imgui.TextColoredRGB("�������� ������� ����")
				elseif not spurBig.v and (spur.select_spur >= 1 and spur.select_spur <= 20) then
					imgui.Dummy(imgui.ImVec2(0, 150))
					imgui.SetCursorPosX(515)
					imgui.Text(u8"�������� ��������")
					imgui.Spacing()
					imgui.Spacing()
					imgui.SetCursorPosX(490)
					if imgui.Button(u8"������� ��� ���������", imgui.ImVec2(170, 20)) then
						spurBig.v = true
					end
					imgui.Spacing()
					imgui.SetCursorPosX(490)
					if imgui.Button(u8"�������������", imgui.ImVec2(170, 20)) then
						spur.edit = true
						local f = io.open(dirml.."/MedicalHelper/���������/"..spur.list[spur.select_spur]..".txt", "r")
						spur.text.v = u8(f:read("*a"))
						f:close()
						spur.name.v = u8(spur.list[spur.select_spur])
					end
					imgui.Spacing()
					imgui.SetCursorPosX(490)
					if imgui.Button(u8"�������", imgui.ImVec2(170, 20)) then
						if doesFileExist(dirml.."/MedicalHelper/���������/"..spur.list[spur.select_spur]..".txt") then
							os.remove(dirml.."/MedicalHelper/���������/"..spur.list[spur.select_spur]..".txt")
						end
						table.remove(spur.list, spur.select_spur) 
						spur.select_spur = -1
					end
				else
				imgui.Dummy(imgui.ImVec2(0, 150))
				imgui.SetCursorPosX(400)
				imgui.TextColoredRGB("������� �� ������ {FF8400}\"��������\"{FFFFFF}, ����� ������� ����� ���������\n\t\t\t\t\t\t\t\t\t��� �������� ��� ������������.")
			end
			imgui.EndGroup()
		end
		if select_menu[4] then
			imgui.SameLine()
			imgui.BeginGroup()
			imgui.Text(u8"����� ��������� ������ ����� ������, � ������� ������ ��������� ������� ���������.")
			imgui.Separator();
			imgui.Dummy(imgui.ImVec2(0, 5))
			imgui.BeginChild("cmd list", imgui.ImVec2(0, 313), true)
			imgui.Columns(3, "keybinds", true); 
			imgui.SetColumnWidth(-1, 80); 
			imgui.Text(u8"�������"); 
			imgui.NextColumn();
			imgui.SetColumnWidth(-1, 450); 
			imgui.Text(u8"��������"); 
			imgui.NextColumn(); 
			imgui.Text(u8"�������"); 
			imgui.NextColumn(); 
			imgui.Separator();
			for i,v in ipairs(cmdBind) do
				if num_rank.v+1 >= v.rank then
					if imgui.Selectable(u8(v.cmd), selected_cmd == i, imgui.SelectableFlags.SpanAllColumns) then
						selected_cmd = i
					end
					imgui.NextColumn(); 
					imgui.Text(u8(v.desc)); 
					imgui.NextColumn();
					if #v.key == 0 then
						imgui.Text(u8"���")
					else
						imgui.Text(table.concat(rkeys.getKeysName(v.key), " + "))
					end	
					imgui.NextColumn()
				else
					imgui.PushStyleColor(imgui.Col.Text, imgui.ImColor(228, 70, 70, 202):GetVec4())
					if imgui.Selectable(u8(v.cmd), selected_cmd == i, imgui.SelectableFlags.SpanAllColumns) then
						selected_cmd = i
					end
					imgui.NextColumn(); 
					imgui.Text(u8(v.desc)); 
					imgui.NextColumn(); 
					if #v.key == 0 then
						imgui.Text(u8"���")
					else
						imgui.Text(table.concat(rkeys.getKeysName(v.key), " + "))
					end	
					imgui.NextColumn()
					imgui.PopStyleColor(1)
				end
			end
			imgui.EndChild();
			if cmdBind[selected_cmd].rank <= num_rank.v+1 then
				imgui.Text(u8"�������� ������� ������������ ��� �������, ����� ���� ������ ����������� ��������������.")
				if imgui.Button(u8"��������� �������", imgui.ImVec2(140, 20)) then 
					imgui.OpenPopup(u8"MH | ��������� ������� ��� ���������");
					lockPlayerControl(true)
					editKey = true
				end
				imgui.SameLine();
				if imgui.Button(u8"�������� ���������", imgui.ImVec2(145, 20)) then 
					rkeys.unRegisterHotKey(cmdBind[selected_cmd].key)
					unRegisterHotKey(cmdBind[selected_cmd].key)
					cmdBind[selected_cmd].key = {}
					local f = io.open(dirml.."/MedicalHelper/cmdSetting.json", "w")
					f:write(encodeJson(cmdBind))
					f:flush()
					f:close()
				end
				imgui.SameLine();
			else
				imgui.Text(u8"������ ������� ��� ����������. �������� ������ �� " .. cmdBind[selected_cmd].rank .. u8" �����")
				imgui.Text(u8"���� ��� ���� ������������� �����������, ���������� �������� ��������� � ����������.")
			end
			imgui.EndGroup()
		end
		if select_menu[5] then
			imgui.SameLine()
			imgui.BeginGroup()
			imgui.BeginChild("bind list", imgui.ImVec2(195, 380), true)
			imgui.SetCursorPosX(20)
			imgui.Text(u8"������ ������")
			imgui.Separator()
			for i,v in ipairs(binder.list) do
				if imgui.Selectable(u8(binder.list[i].name), binder.select_bind == i) then 
					binder.select_bind = i;
					binder.name.v = u8(binder.list[binder.select_bind].name)
					binder.sleep.v = binder.list[binder.select_bind].sleep
					binder.key = binder.list[binder.select_bind].key
					if doesFileExist(dirml.."/MedicalHelper/Binder/"..binder.list[binder.select_bind].name..".txt") then
						local f = io.open(dirml.."/MedicalHelper/Binder/"..binder.list[binder.select_bind].name..".txt", "r")
						binder.text.v = u8(f:read("*a"))
						f:flush()
						f:close()
					end
					binder.edit = true 
				end
			end
			imgui.EndChild()
			imgui.SetCursorPosX(197)
			if imgui.Button(u8"��������", imgui.ImVec2(196, 20)) then
				if #binder.list < 100 then
					for i = 1, 100 do
						local bool = false
						for ix,v in ipairs(binder.list) do
							if v.name == "Noname bind '"..i.."'" then
								bool = true
							end
						end
						if not bool then
							binder.list[#binder.list+1] = {name = "Noname bind '"..i.."'", key = {}, sleep = 0.5}
							binder.edit = true
							binder.select_bind = #binder.list
							binder.name.v = ""
							binder.sleep.v = 0.5
							binder.text.v = ""
							binder.key = {}
							break 
						end
					end
				end
			end
			imgui.EndGroup() 
			imgui.SameLine()
			imgui.BeginGroup()
			if binder.edit then
				imgui.SetCursorPosX(550)
				imgui.Text(u8"���� ��� ����������")
				imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(70, 70, 70, 200):GetVec4())
				imgui.InputTextMultiline("##bind", binder.text, imgui.ImVec2(525, 271))
				imgui.PopStyleColor(1)
				imgui.PushItemWidth(150)
				imgui.InputText(u8"�������� �����", binder.name, imgui.InputTextFlags.CallbackCharFilter, filter(1, "[%w�-�%+%�%#%(%)]"))
				if imgui.Button(u8"��������� �������", imgui.ImVec2(150, 20)) then 
					imgui.OpenPopup(u8"MH | ��������� ������� ��� ���������")
					editKey = true
				end 
				imgui.SameLine()
				imgui.TextColoredRGB("���������: "..table.concat(rkeys.getKeysName(binder.key), " + "))
				imgui.DragFloat("##sleep", binder.sleep, 0.1, 0.5, 10.0, u8"�������� = %.1f ���.")
				imgui.SameLine()
				if imgui.Button("-", imgui.ImVec2(20, 20)) and binder.sleep.v ~= 0.5 then
					binder.sleep.v = binder.sleep.v - 0.1
				end
				imgui.SameLine()
				if imgui.Button("+", imgui.ImVec2(20, 20)) and binder.sleep.v ~= 10 then
					binder.sleep.v = binder.sleep.v + 0.1
				end
				imgui.PopItemWidth()
				imgui.SameLine()
				imgui.Text(u8"�������� ������� ����� �����")
				if imgui.Button(u8"�������", imgui.ImVec2(110, 20)) then
					binder.text.v = ""
					binder.sleep.v = 0.5
					binder.name.v = ""
					binder.edit = false 
					rkeys.unRegisterHotKey(binder.key)
					unRegisterHotKey(binder.key)
					binder.key = {}
					if doesFileExist(dirml.."/MedicalHelper/Binder/"..binder.list[binder.select_bind].name..".txt") then
						os.remove(dirml.."/MedicalHelper/Binder/"..binder.list[binder.select_bind].name..".txt")
					end
					table.remove(binder.list, binder.select_bind) 
					local f = io.open(dirml.."/MedicalHelper/bindSetting.json", "w")
					f:write(encodeJson(binder.list))
					f:flush()
					f:close()
					binder.select_bind = -1 
				end
				imgui.SameLine()
				if imgui.Button(u8"���������", imgui.ImVec2(110, 20)) then
					local bool = false
						if binder.name.v ~= "" then
							for i,v in ipairs(binder.list) do
								if v.name == u8:decode(binder.name.v) and i ~= binder.select_bind then
									bool = true
								end
							end
							if not bool then
								binder.list[binder.select_bind].name = u8:decode(binder.name.v)
							else
								imgui.OpenPopup(u8"������")
							end
						end
					if not bool then
						rkeys.registerHotKey(binder.key, true, onHotKeyBIND)
						binder.list[binder.select_bind].key = binder.key
						local sec = string.format("%.1f", binder.sleep.v)
						binder.list[binder.select_bind].sleep = sec
						local text = u8:decode(binder.text.v)
						local saveJS = encodeJson(binder.list) 
						local f = io.open(dirml.."/MedicalHelper/bindSetting.json", "w")
						local ftx = io.open(dirml.."/MedicalHelper/Binder/"..binder.list[binder.select_bind].name..".txt", "w")
						f:write(saveJS)
						ftx:write(text)
						f:flush()
						ftx:flush()
						f:close()
						ftx:close()
					end
				end
				imgui.SameLine()
				if imgui.Button(u8"���-�������", imgui.ImVec2(110, 20)) then
					paramWin.v = not paramWin.v
				end
				imgui.SameLine()
				if imgui.Button(u8"����������", imgui.ImVec2(110, 20)) then
					profbWin.v = not profbWin.v
				end
			else
				imgui.Dummy(imgui.ImVec2(0, 150))
				imgui.SetCursorPosX(450)
				imgui.TextColoredRGB("������� �� ������ {FF8400}\"��������\"{FFFFFF}, ����� ������� ����� ����\n\t\t\t\t\t\t\t\t��� �������� ��� ������������.")
			end
			imgui.EndGroup()
		end
			if select_menu[6] then
			imgui.SameLine()
			imgui.BeginChild("about", imgui.ImVec2(0, 0), true)
			imgui.SetCursorPosX(280)
			imgui.Text(u8"Medical Helper")
			imgui.Spacing()
			imgui.TextWrapped(u8"������ ��� ���������� ��� ������� Ariona RP. ��������� ����� ���������� �� �������� ������ �������� ������������� ������ �������� � ����������� �� �����������.\n���������� ������� �� ���� ���������� ������������ � ����������� ������.")
			imgui.Dummy(imgui.ImVec2(0, 10))
			imgui.Bullet()
			imgui.TextColoredRGB("����������� - {FFB700}Ministries of Health")
			imgui.Bullet()
			imgui.TextColoredRGB("������ ������� - {FFB700}".. scr.version)
			imgui.Dummy(imgui.ImVec2(0, 20))
			imgui.SetCursorPosX(20)
			imgui.Text(fa.ICON_BUG)
			imgui.SameLine()
			imgui.TextColoredRGB("����� ��� ��� ������, ��� �� ������ ������ ���-�� �����, ������ � ������");
			imgui.SameLine();
			imgui.Text(fa.ICON_ARROW_DOWN)
			imgui.SetCursorPosX(20)
			imgui.Text(fa.ICON_LINK)
			imgui.SameLine()
			imgui.TextColoredRGB("��� �����: VK: {74BAF4}vk.com/medhelperarz)
			if imgui.IsItemHovered() then
				imgui.SetTooltip(u8"�������� ���, ����� �����������, ��� ���, ����� ������� � ��������")
			end
			if imgui.IsItemClicked(0) then
				setClipboardText("vk.com/medhelperarz")
			end
			if imgui.IsItemClicked(1) then
				print(shell32.ShellExecuteA(nil, 'open', 'https://vk.com/medhelperarz', nil, nil, 1))
			end
			imgui.Spacing()
			imgui.Dummy(imgui.ImVec2(0, 80))
			imgui.SetCursorPosX(90)
			if imgui.Button(u8"���������", imgui.ImVec2(160, 20)) then
				showCursor(false);
				scr:unload()
			end
			imgui.SameLine()
			imgui.SetCursorPosX(260)
			if imgui.Button(u8"�������������", imgui.ImVec2(160, 20)) then
				showCursor(false);
				scr:reload()
			end
			imgui.SameLine()
			imgui.SetCursorPosX(430)
			if imgui.Button(u8"������� ������", imgui.ImVec2(160, 20)) then 
				addOneOffSound(0, 0, 0, 1058)
				sampAddChatMessage("", 0xEE4848)
				sampAddChatMessage("", 0xEE4848)
				sampAddChatMessage("", 0xEE4848)
				sampAddChatMessage("{FFFFFF}["..script_names.."]: ��������! ����������� �������� �������� {77DF63}/mh-delete.", 0xEE4848)
				mainWin.v = false
			end
			imgui.EndChild()
		end
		imgui.PushStyleColor(imgui.Col.PopupBg, imgui.ImVec4(0.06, 0.06, 0.06, 0.94))
		if imgui.BeginPopupModal(u8"MH | ��������� ������� ��� ���������", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
			imgui.Text(u8"������� �� ������� ��� ��������� ������ ��� ��������� ���������.");
			imgui.Separator()
			imgui.Text(u8"����������� �������:")
			imgui.Bullet()	imgui.TextDisabled(u8"������� ��� ��������� - Alt, Ctrl, Shift")
			imgui.Bullet()	imgui.TextDisabled(u8"���������� �����")
			imgui.Bullet()	imgui.TextDisabled(u8"�������������� ������� F1-F12")
			imgui.Bullet()	imgui.TextDisabled(u8"����� ������� ������")
			imgui.Bullet()	imgui.TextDisabled(u8"������� ������ Numpad")
			imgui.Checkbox(u8"������������ ��� � ���������� � ���������", cb_RBUT)
			imgui.Separator()
			if imgui.TreeNode(u8"��� ������������� 5-��������� ����") then
				imgui.Checkbox(u8"X Button 1", cb_x1)
				imgui.Checkbox(u8"X Button 2", cb_x2)
				imgui.Separator()
				imgui.TreePop();
			end
			imgui.Text(u8"������� �������(�): ");
			imgui.SameLine();
			if imgui.IsMouseClicked(0) then
				lua_thread.create(function()
					wait(500)
					setVirtualKeyDown(3, true)
					wait(0)
					setVirtualKeyDown(3, false)
				end)
			end
			if #(rkeys.getCurrentHotKey()) ~= 0 and not rkeys.isBlockedHotKey(rkeys.getCurrentHotKey()) then
				if not rkeys.isKeyModified((rkeys.getCurrentHotKey())[#(rkeys.getCurrentHotKey())]) then
					currentKey[1] = table.concat(rkeys.getKeysName(rkeys.getCurrentHotKey()), " + ")
					currentKey[2] = rkeys.getCurrentHotKey()
					
				end
			end
			imgui.TextColored(imgui.ImColor(255, 205, 0, 200):GetVec4(), currentKey[1])
			if isHotKeyDefined then
				imgui.TextColored(imgui.ImColor(45, 225, 0, 200):GetVec4(), u8"������ ���� ��� ����������!")
			end
			if imgui.Button(u8"����������", imgui.ImVec2(150, 0)) then
				if select_menu[4] then
					if cb_RBUT.v then
						table.insert(currentKey[2], 1, vkeys.VK_RBUTTON)
					end
					if cb_x1.v then
						table.insert(currentKey[2], vkeys.VK_XBUTTON1)
					end
					if cb_x2.v then
						table.insert(currentKey[2], vkeys.VK_XBUTTON2)
					end
					if rkeys.isHotKeyExist(currentKey[2]) then 
						isHotKeyDefined = true
					else
						rkeys.unRegisterHotKey(cmdBind[selected_cmd].key)
						unRegisterHotKey(cmdBind[selected_cmd].key)
						cmdBind[selected_cmd].key = currentKey[2]
						rkeys.registerHotKey(currentKey[2], true, onHotKeyCMD)
						table.insert(keysList, currentKey[2])
						currentKey = {"",{}}
						lockPlayerControl(false)
						cb_RBUT.v = false
						cb_x1.v, cb_x2.v = false, false
						isHotKeyDefined = false
						imgui.CloseCurrentPopup();
						local f = io.open(dirml.."/MedicalHelper/cmdSetting.json", "w")
						f:write(encodeJson(cmdBind))
						f:flush()
						f:close()
						editKey = false
				end
				elseif select_menu[5] then
					if cb_RBUT.v then
						table.insert(currentKey[2], 1, vkeys.VK_RBUTTON)
					end
					if cb_x1.v then
						table.insert(currentKey[2], vkeys.VK_XBUTTON1)
					end
					if cb_x2.v then
						table.insert(currentKey[2], vkeys.VK_XBUTTON2)
					end
					if rkeys.isHotKeyExist(currentKey[2]) then 
						isHotKeyDefined = true
					else	
						rkeys.unRegisterHotKey(binder.list[binder.select_bind].key)
						unRegisterHotKey(binder.list[binder.select_bind].key)
						binder.key = currentKey[2]
						currentKey = {"",{}}
						lockPlayerControl(false)
						cb_RBUT.v = false
						cb_x1.v, cb_x2.v = false, false
						isHotKeyDefined = false
						imgui.CloseCurrentPopup();
						editKey = false
					end
				end
			end
			imgui.SameLine();
			if imgui.Button(u8"�������", imgui.ImVec2(150, 0)) then 
				imgui.CloseCurrentPopup(); 
				currentKey = {"",{}}
				cb_RBUT.v = false
				cb_x1.v, cb_x2.v = false, false
				lockPlayerControl(false)
				isHotKeyDefined = false
				editKey = false
			end 
			imgui.SameLine()
			if imgui.Button(u8"��������", imgui.ImVec2(150, 0)) then
				currentKey = {"",{}}
				cb_x1.v, cb_x2.v = false, false
				cb_RBUT.v = false
				isHotKeyDefined = false
			end
			imgui.EndPopup()
		end
		if imgui.BeginPopupModal(u8"������", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
			imgui.Text(u8"������ �������� ��� ����������")
			imgui.SetCursorPosX(60)
			if imgui.Button(u8"��", imgui.ImVec2(120, 20)) then
				imgui.CloseCurrentPopup()
			end
			imgui.EndPopup()
		end
		imgui.PopStyleColor(1)
		imgui.End()
	end
	if iconwin.v then
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(250, 900), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin("Icons ", iconwin, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize);
		for i,v in pairs(fa) do
			if imgui.Button(fa[i].." - "..i, imgui.ImVec2(200, 25)) then
				setClipboardText(i)
			end
		end
		imgui.End()
	end
	if paramWin.v then
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(820, 580), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

		imgui.Begin(u8"���-��������� ��� �������", paramWin, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize);
		imgui.SetWindowFontScale(1.1)
		imgui.SetCursorPosX(50)
		imgui.TextColoredRGB("[center]{FFFF41}������ ������ �� ������ ����, ����� ����������� ���.", imgui.GetMaxWidthByText("������ ������ �� ������ ����, ����� ����������� ���."))
		imgui.Dummy(imgui.ImVec2(0, 15))

		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myID}")
		imgui.SameLine()
		if imgui.IsItemHovered(0) then
			setClipboardText("{myID}")
		end
		imgui.TextColoredRGB("{C1C1C1} - ��� id - {ACFF36}"..tostring(myid))

		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myNick}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then
			setClipboardText("{myNick}")
		end
		imgui.TextColoredRGB("{C1C1C1} - ��� ������ ��� (�� ���.) - {ACFF36}"..tostring(myNick:gsub("_", " ")))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myRusNick}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then
			setClipboardText("{myRusNick}")
		end
		imgui.TextColoredRGB("{C1C1C1} - ��� ���, ��������� � ���������� - {ACFF36}"..tostring(u8:decode(buf_nick.v)))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myHP}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then
			setClipboardText("{myHP}")
		end
		imgui.TextColoredRGB("{C1C1C1} - ��� ������� �� - {ACFF36}"..tostring(getCharHealth(PLAYER_PED)))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myArmo}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then
			setClipboardText("{myArmo}")
		end
		imgui.TextColoredRGB("{C1C1C1} - ��� ������� ������� ����� - {ACFF36}"..tostring(getCharArmour(PLAYER_PED)))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myHosp}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then
			setClipboardText("{myHosp}")
		end
		imgui.TextColoredRGB("{C1C1C1} - �������� ����� �������� - {ACFF36}"..tostring(u8:decode(chgName.org[num_org.v+1])))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myHospEn}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then
			setClipboardText("{myHospEn}")
		end
		imgui.TextColoredRGB("{C1C1C1} - ������ �������� ����� �������� �� ���. - {ACFF36}"..tostring(u8:decode(list_org_en[num_org.v+1])))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myTag}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then
			setClipboardText("{myTag}")
		end
		imgui.TextColoredRGB("{C1C1C1} - ��� ���  - {ACFF36}"..tostring(u8:decode(buf_teg.v)))
		
		imgui.Spacing()		
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myRank}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then
			setClipboardText("{myRank}")
		end
		imgui.TextColoredRGB("{C1C1C1} - ���� ������� ��������� - {ACFF36}"..tostring(u8:decode(chgName.rank[num_rank.v+1])))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{time}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then
			setClipboardText("{time}")
		end
		imgui.TextColoredRGB("{C1C1C1} - ����� � ������� ����:������:������� - {ACFF36}"..tostring(os.date("%X")))
		
		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{day}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then
			setClipboardText("{day}")
		end
		imgui.TextColoredRGB("{C1C1C1} - ������� ���� ������ - {ACFF36}"..tostring(os.date("%d")))

		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{week}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then
			setClipboardText("{week}")
		end
		imgui.TextColoredRGB("{C1C1C1} - ������� ������ - {ACFF36}"..tostring(week[tonumber(os.date("%w"))+1]))

		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{month}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then
			setClipboardText("{month}")
		end

		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{getNickByTarget}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then
			setClipboardText("{getNickByTarget}")
		end
		imgui.TextColoredRGB("{C1C1C1} - �������� ��� ������ �� �������� ��������� ��� �������.")

		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{target}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{target}")
		end
		imgui.TextColoredRGB("{C1C1C1} - ��������� ID ������, �� �������� ������� (�������� ����) - {ACFF36}"..tostring(targID))

		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{pause}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then
			setClipboardText("{pause}")
		end
		imgui.TextColoredRGB("{C1C1C1} - �������� ����� ����� �������� ������ � ���. {EC3F3F}����������� ��������, �.�. � ����� ������.")

		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), u8"{sleep:�����}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then
			setClipboardText("{sleep:1000}")
		end
		imgui.TextColoredRGB("{C1C1C1} - ����� ���� �������� ������� ����� ���������. \n\t������: {sleep:2500}, ��� 2500 ����� � �� (1 ��� = 1000 ��)")

		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), u8"{sex:�����1|�����2}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then
			setClipboardText("{sex:text1|text2}")
		end
		imgui.TextColoredRGB("{C1C1C1} - ���������� ����� � ����������� �� ���������� ����.  \n\t������, {sex:�����|������}, ����� '�����', ���� ������ ������� ��� ��� '������', ���� �������")
		
		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), u8"{getNickByID:�� ������}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then
			setClipboardText("{getNickByID:}")
		end
		imgui.TextColoredRGB("{C1C1C1} - ��������� ��� ������ �� ��� ID. \n\t������, {getNickByID:25}, ����� ��� ������ ��� ID 25.)")
		imgui.End()
	end
	if spurBig.v then
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(1098, 790), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"�������� ���������", spurBig, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar);
		if spur.edit then
			imgui.SetCursorPosX(350)
			imgui.Text(u8"������� ���� ��� �������������� ���������")
			imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(70, 70, 70, 200):GetVec4())
			imgui.InputTextMultiline("##spur", spur.text, imgui.ImVec2(1081, 715))
			imgui.PopStyleColor(1)
			if imgui.Button(u8"���������", imgui.ImVec2(357, 20)) then
				local name = ""
				local bool = false
				if spur.name.v ~= "" then 
					name = u8:decode(spur.name.v)
					if doesFileExist(dirml.."/MedicalHelper/���������/"..name..".txt") and spur.list[spur.select_spur] ~= name then
						bool = true
						imgui.OpenPopup(u8"������")
					else
						os.remove(dirml.."/MedicalHelper/���������/"..spur.list[spur.select_spur]..".txt")
						spur.list[spur.select_spur] = u8:decode(spur.name.v)
					end
				else
					name = spur.list[spur.select_spur]
				end
				if not bool then
					local f = io.open(dirml.."/MedicalHelper/���������/"..name..".txt", "w")
					f:write(u8:decode(spur.text.v))
					f:flush()
					f:close()
					spur.text.v = ""
					spur.name.v = ""
					spur.edit = false
				end
			end
			imgui.SameLine()
			if imgui.Button(u8"�������", imgui.ImVec2(357, 20)) then
				spur.text.v = ""
				table.remove(spur.list, spur.select_spur) 
				spur.select_spur = -1
				if doesFileExist(dirml.."/MedicalHelper/���������/"..u8:decode(spur.select_spur)..".txt") then
					os.remove(dirml.."/MedicalHelper/���������/"..u8:decode(spur.select_spur)..".txt")
				end
				spur.name.v = ""
				spurBig.v = false
				spur.edit = false
			end
			imgui.SameLine()
			if imgui.Button(u8"�������� ��������", imgui.ImVec2(357, 20)) then
				spur.edit = false
			end
			if imgui.Button(u8"�������", imgui.ImVec2(1081, 20)) then
				spurBig.v = not spurBig.v
			end
		else
			imgui.SetCursorPosX(390)
			imgui.Text(u8"������� ���� ��� ��������� ���������")
			imgui.BeginChild("spur spec", imgui.ImVec2(1081, 715), true)
			if doesFileExist(dirml.."/MedicalHelper/���������/"..spur.list[spur.select_spur]..".txt") then
				for line in io.lines(dirml.."/MedicalHelper/���������/"..spur.list[spur.select_spur]..".txt") do
					imgui.TextWrapped(u8(line))
				end
			end
			imgui.EndChild()
			if imgui.Button(u8"�������� ��������������", imgui.ImVec2(530, 20)) then 
				spur.edit = true
				local f = io.open(dirml.."/MedicalHelper/���������/"..spur.list[spur.select_spur]..".txt", "r")
				spur.text.v = u8(f:read("*a"))
				f:close()
			end
			imgui.SameLine()
			if imgui.Button(u8"�������", imgui.ImVec2(530, 20)) then
				spurBig.v = not spurBig.v
			end
		end
		imgui.End()
	end
	if sobWin.v then
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(253, 496), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"���� ��� �������������", sobWin, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize);
		imgui.BeginGroup()
		imgui.PushItemWidth(135)
		imgui.InputText("##id", sobes.selID, imgui.InputTextFlags.CallbackCharFilter + imgui.InputTextFlags.EnterReturnsTrue, filter(1, "%d+"))
		imgui.PopItemWidth()
		if not imgui.IsItemActive() and sobes.selID.v == "" then
			imgui.SameLine()
			imgui.SetCursorPosX(20)
			imgui.TextDisabled(u8"������� id ������") 
		end
		imgui.SameLine()
		imgui.SetCursorPosX(162)
		if imgui.Button(u8"������", imgui.ImVec2(75, 20)) then
			if sobes.selID.v ~= "" then
				sobes.num = sobes.num + 1
				threadS = lua_thread.create(sobesRP, sobes.num);
			else
				sampAddChatMessage("{FFFFFF}["..script_names.."]: ������� id ������ ��� ������ �������������.", 0xEE4848)
			end
		end
		imgui.BeginChild("pass player", imgui.ImVec2(223, 233), true)
		imgui.SetCursorPosX(37)
		imgui.Text(u8"���������� � ������:")
		imgui.Separator()
		imgui.Text(u8"���:")
		if sobes.player.name == "" then
			imgui.SameLine()
			imgui.TextColoredRGB("{F55534}���")
		else
			imgui.SameLine()
			imgui.TextColoredRGB("{FFCD00}"..sobes.player.name)
		end
		imgui.Text(u8"��� � �����:")
		if sobes.player.let == 0 then
			imgui.SameLine()
			imgui.TextColoredRGB("{F55534}���")
		else
			if sobes.player.let >= 3 then
				imgui.SameLine()
				imgui.TextColoredRGB("{17E11D}"..sobes.player.let.."/3")
			else
				imgui.SameLine()
				imgui.TextColoredRGB("{F55534}"..sobes.player.let.."{17E11D}/3")
			end
		end
		imgui.Text(u8"�����������������:")
		if sobes.player.zak == 0 then
			imgui.SameLine()
			imgui.TextColoredRGB("{F55534}���")
		else
			if sobes.player.zak >= 35 then
				imgui.SameLine()
				imgui.TextColoredRGB("{17E11D}"..sobes.player.zak.."/35")
			else
				imgui.SameLine()
				imgui.TextColoredRGB("{F55534}"..sobes.player.zak.."{17E11D}/35")
			end
		end
		imgui.Text(u8"����� ������:")
		if sobes.player.work == "" then
			imgui.SameLine()
			imgui.TextColoredRGB("{F55534}���")
		else
			if sobes.player.work == "��� ������" then
				imgui.SameLine()
				imgui.TextColoredRGB("{17E11D}"..sobes.player.work)
			else
				imgui.SameLine()
				imgui.TextColoredRGB("{F55534}"..sobes.player.work)
			end
		end
		imgui.Text(u8"������� � ��:")
		if sobes.player.bl == "" then
			imgui.SameLine()
			imgui.TextColoredRGB("{F55534}���")
		else
			if sobes.player.bl == "�� ������(�)" then
				imgui.SameLine()
				imgui.TextColoredRGB("{17E11D}"..sobes.player.bl)
			else
				imgui.SameLine()
				imgui.TextColoredRGB("{F55534}"..sobes.player.bl)
			end
		end
		imgui.Text(u8"�������� �� ����:")
		if sobes.player.lic == "����" then
			imgui.SameLine()
			imgui.TextColoredRGB("{F55534}���")
		else
			if sobes.player.lic == "����" then
				imgui.SameLine()
				imgui.TextColoredRGB("{17E11D}����")
			else
				imgui.SameLine()
				imgui.TextColoredRGB("{F55534}���")
			end
		end
		imgui.Text(u8"��������:")
		if sobes.player.heal == "" then
			imgui.SameLine()
			imgui.TextColoredRGB("{F55534}���")
		else
			if sobes.player.heal == "������" then
				imgui.SameLine()
				imgui.TextColoredRGB("{17E11D}"..sobes.player.heal)
			else
				imgui.SameLine()
				imgui.TextColoredRGB("{F55534}"..sobes.player.heal)
			end
		end
		imgui.Text(u8"����������������:")
		if sobes.player.narko == 0.1 then
			imgui.SameLine()
			imgui.TextColoredRGB("{F55534}���")
		else
			if sobes.player.narko == 0 then
				imgui.SameLine()
				imgui.TextColoredRGB("{17E11D}"..sobes.player.narko.."/0")
			else
				imgui.SameLine()
				imgui.TextColoredRGB("{F55534}"..sobes.player.narko.."{17E11D}/0")
			end
		end
		imgui.EndChild()
		if imgui.Button(u8"������������ ������", imgui.ImVec2(223, 30)) then
			imgui.OpenPopup("sobQN")
		end
		imgui.Spacing()
		if sobes.nextQ then
			if imgui.Button(u8"������ ������", imgui.ImVec2(223, 30)) then
				sobes.num = sobes.num + 1
				lua_thread.create(sobesRP, sobes.num); 
			end
		else
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(156, 156, 156, 200):GetVec4())
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(156, 156, 156, 200):GetVec4())
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(156, 156, 156, 200):GetVec4())
			imgui.Button(u8"������ ������", imgui.ImVec2(223, 30))
			imgui.PopStyleColor(3)
		end
		imgui.Spacing()
		if sobes.selID.v ~= "" then
			if imgui.Button(u8"���������� ��������", imgui.ImVec2(223, 30)) then
				imgui.OpenPopup("sobEnter")
			end
		else
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(156, 156, 156, 200):GetVec4())
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(156, 156, 156, 200):GetVec4())
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(156, 156, 156, 200):GetVec4())
			imgui.Button(u8"���������� ���������", imgui.ImVec2(223, 30))
			imgui.PopStyleColor(3)
		end
		imgui.Spacing()
		if sobes.selID.v ~= "" then 
			if imgui.Button(u8"����������/��������", imgui.ImVec2(223, 30)) then
				threadS:terminate()
				sobes.input.v = ""
				sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", lic = "", narko = 0.1}
				sobes.selID.v = ""
				sobes.nextQ = false
				sobes.num = 0
			end
		else
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(156, 156, 156, 200):GetVec4())
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(156, 156, 156, 200):GetVec4())
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(156, 156, 156, 200):GetVec4())
			imgui.Button(u8"����������/��������", imgui.ImVec2(223, 30))
			imgui.PopStyleColor(3)
		end
		imgui.EndGroup()
		imgui.PushStyleColor(imgui.Col.PopupBg, imgui.ImVec4(0.06, 0.06, 0.06, 0.94)) 
		if imgui.BeginPopup("sobEnter") then
			if imgui.MenuItem(u8"�������") then
				lua_thread.create(sobesRP, 4)
			end
			if imgui.BeginMenu(u8"���������") then
				if imgui.MenuItem(u8"��������� � �������� (���)") then
					lua_thread.create(sobesRP, 5)
				end
				if imgui.MenuItem(u8"���� ��� ����������") then
					lua_thread.create(sobesRP, 6)
				end
				if imgui.MenuItem(u8"�������� � �������") then
					lua_thread.create(sobesRP, 7)
				end
				if imgui.MenuItem(u8"����� ������") then
					lua_thread.create(sobesRP, 8)
				end
				if imgui.MenuItem(u8"������� � ��") then
					lua_thread.create(sobesRP, 9)
				end
				if imgui.MenuItem(u8"�������� �� ���������") then
					lua_thread.create(sobesRP, 10)
				end
				if imgui.MenuItem(u8"����� ����������������") then
					lua_thread.create(sobesRP, 11)
				end
				imgui.EndMenu()
			end
			imgui.EndPopup()
		end
		if imgui.BeginPopup("sobQN") then
			if imgui.MenuItem(u8"��������� ���������") then 
				sampSendChat("���������� ���������� ��� ����� ����������, � ������: ������� � ���.�����.")
			end
			if imgui.MenuItem(u8"����� ��������") then 
				sampSendChat("������ �� ������� ������ ���� �������� ��� ���������������?")
			end
			if imgui.MenuItem(u8"���������� � ����") then 
				sampSendChat("����������, ����������, ������� � ����.")
			end
			if imgui.MenuItem(u8"����� �� Discord") then 
				sampSendChat("������� �� � ��� ����.����� \"Discord\"?")
			end
			if imgui.BeginMenu(u8"������� �� �������:") then
				if imgui.MenuItem(u8"��") then 
					sampSendChat("��� ����� �������� ������������ '��'?")
				end
				if imgui.MenuItem(u8"��") then 
					sampSendChat("��� ����� �������� ������������ '��'?")
				end
				if imgui.MenuItem(u8"��") then 
					sampSendChat("��� ����� �������� ������������ '��'?")
				end
				if imgui.MenuItem(u8"��") then 
					sampSendChat("��� �� �������, ��� ����� �������� ������������ '��'?")							
				end
				imgui.EndMenu()
			end
			imgui.EndPopup()
		end
		imgui.PopStyleColor(1)
		imgui.End()
	end
	if profbWin.v then
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(710, 450), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"����������� ����������� �������", profbWin, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize);
		imgui.SetWindowFontScale(1.1)
		local vt1 = [[
������ ������������ ������������� ������� ��� ����������������� ������������ �������
������ �������� ������������ ������� ���������� ��� ���������� ������������.

{FFCD00}1. ������� ����������{FFFFFF}
	��� �������� ���������� ������������ ������ ������� {ACFF36}#{FFFFFF}, ����� �������� ��� ��������
����������. �������� ���������� ����� ��������� ������ ���������� ������� � �����,
����� ����� ���������. 
	����� �������� ���������� �������� ����� {ACFF36}={FFFFFF} � ����� ������� ����� �����, �������
���������� ��������� ���� ����������. ����� ����� ��������� ����� �������.
		������: {ACFF36}#price=10.000$.{FFFFFF}
	������, ��������� ���������� {ACFF36}#price{FFFFFF}, ����� � �������� ���� ��� ���������, � ��� �����
������������� �������� �� ����� ������������ ��������� �� ��������, ������� ���� 
������� ����� �����.

{FFCD00}2. ��������������� ������{FFFFFF}
	� ������� ��������������� ����� ������� ��� ���� ������� ��� �������� ����-����
��� ���� ��� ����������� �� ����� ������������. ����������� �������� ������� ������ //,
����� �������� ������� ����� �����.
	������: {ACFF36}������������, ��� ��� ������ // �����������{FFFFFF}
����������� {ACFF36}// �����������{FFFFFF} �� ����� ��������� �������� � �� ����� �����.

{FFCD00}3. ������� ��������{FFFFFF}
	� ������� �������� ����� ��������� ������������ ���������, � ������� ������� �����
������������� ����� ������� �������� ��.
��������� �������:
	{ACFF36}{dialog}{FFFFFF} 		- ������ ��������� �������
	{ACFF36}[name]=�����{FFFFFF}- ��� �������. ������� ����� ����� =. ��� �� ������ ���� ����� �������
	{ACFF36}[1]=�����{FFFFFF}		- �������� ��� ������ ���������� ��������, ��� � ������� 1 - ���
������� ���������. ����� ������������� ������ ����, ������ ��������, ��������, [X], [B],
[NUMPAD1], [NUMPAD2] � �.�. ������ ��������� ������ ����� ���������� �����. ����� �����
������������� ���, ������� ����� ������������ ��� ������. 
	����� ����, ��� ������ ��� ��������, �� ��������� ������ ������� ��� ���� ���������.
	{ACFF36}����� ���������...
	{ACFF36}[2]=�����{FFFFFF}	
	{ACFF36}����� ���������...
	{ACFF36}{dialogEnd}{FFFFFF}		- ����� ��������� �������
		]]
		local vt2 = [[
									{E45050}�����������:
1. ����� ������� � ��������� �������� �� �����������, �� 
������������� ��� ����������� ���������;
2. ����� ��������� ������� ������ ��������, �������� 
����������� ������ ���������;
3. ����� ������������ ��� ���� ������������� ������� 
(����������, �����������, ���� � �.�.)
		]]
		local vt3 = [[
{FFCD00}4. ������������� �����{FFFFFF}
������ ����� ����� ������� � ���� �������������� ��������� ��� � ������� �������.
���� ������������� ��� ����������������� ������ �� ��������, ������� ��� �����.
������� ��� ���� �����:
1. �������� ���� - ����, ������� ������ �������� ���� �� ��������, ������� ���
��������� �����, ��������, {ACFF36}{myID}{FFFFFF} - ���������� ��� ������� ID.
2. ���-������� - ����������� ����, ������� ������� �������������� ����������.
� ��� ���������:
{ACFF36}{sleep:[�����]}{FFFFFF} - ����� ���� �������� ������� ����� ���������. 
����� ������� � �������������. ������: {ACFF36}{sleep:2000}{FFFFFF} - ����� �������� � 2 ���
1 ������� = 1000 �����������

{ACFF36}{sex:�����1|�����2}{FFFFFF} - ���������� ����� � ����������� �� ���������� ����.
������ �������������, ���� �������� ��������� ��� ���������� �������������.
��� {6AD7F0}�����1{FFFFFF} - ��� ������� ���������, {6AD7F0}�����2{FFFFFF} - ��� �������. ����������� ������������ ������.
������: {ACFF36}� {sex:������|������} ����.

{ACFF36}{getNickByID:�� ������}{FFFFFF} - ��������� ��� ������ �� ��� ID.
������: �� ������� ����� {6AD7F0}Nick_Name{FFFFFF} � id - 25.
{ACFF36}{getNickByID:25}{FFFFFF} ����� - {6AD7F0}Nick Name.
		]]
		imgui.TextColoredRGB(vt1)
		imgui.BeginGroup()
		imgui.TextDisabled(u8"					������")
		imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(70, 70, 70, 200):GetVec4())
		imgui.InputTextMultiline("##dialogPar", helpd.exp, imgui.ImVec2(220, 180), 16384)
		imgui.PopStyleColor(1)
		imgui.TextDisabled(u8"��� ����������� �����������\nCtrl + C. ������� - Ctrl + V")
		imgui.EndGroup()
		imgui.SameLine()
		imgui.BeginGroup()
		imgui.TextColoredRGB(vt2)
		if imgui.Button(u8"������ ������", imgui.ImVec2(150,25)) then
			imgui.OpenPopup("helpdkey")
		end
		imgui.EndGroup()
		imgui.TextColoredRGB(vt3)
		if imgui.BeginPopup("helpdkey") then
			imgui.BeginChild("helpdkey", imgui.ImVec2(290,320))
				imgui.TextColoredRGB("{FFCD00}��������, ����� �����������")
				imgui.BeginGroup()
					for _,v in ipairs(helpd.key) do
						if imgui.Selectable(u8("["..v.k.."] 	-	"..v.n)) then
							setClipboardText(v.k)
						end
					end
				imgui.EndGroup()
			imgui.EndChild()
		imgui.EndPopup()
		end
		imgui.End()
	end
end


function sobesRP(id)
	if id == 1 then
		sobes.player.name = sampGetPlayerNickname(tonumber(sobes.selID.v))
		sampSendChat("�� ������� �� �������������?")
		wait(1700)
		sampSendChat("���������� ���������� ��� ����� ����������, � ������: �������, ���.����� � ��������.")
		wait(1700)
		sampSendChat(string.format("/n /showpass %d | /showmc %d | /showlic %d", tostring(myid), tostring(myid), tostring(myid)))
		while true do
			wait(0)
			if sobes.player.zak ~= 0 and sobes.player.heal ~= "" and sobes.player.lic ~= "" then
				break
			end
			if sampIsDialogActive() then
				local dId = sampGetCurrentDialogId()
				if dId == 1234 then
					local dText = sampGetDialogText()
					if dText:find("��� � �����") and dText:find("�����������������") then
					HideDialogInTh()
					if dText:find("�����������") then
						sobes.player.work = "��������"
					else
						sobes.player.work = "��� ������"
					end
						if dText:match("���: {FFD700}(%S+)") == sobes.player.name then
							sobes.player.let = tonumber(dText:match("��� � �����: {FFD700}(%d+)"))
							sobes.player.zak = tonumber(dText:match("�����������������: {FFD700}(%d+)"))
							sampSendChat("/me ���������"..chsex("", "�").." ���������� � ��������, ����� ���� �����"..chsex("", "�").." ��� �������� ��������")
							if sobes.player.let >= 3 then
								if sobes.player.zak >= 35 then
									if not dText:find("{FF6200} "..list_org_BL[num_org.v+1]) then
										sobes.player.bl = "�� ������(�)"
										if sobes.player.narko == 0.1 then
											sampSendChat("������, ������ ���.�����.")
											wait(1700)
											sampSendChat("/n /showmc "..tostring(myid))
										elseif sobes.player.lic == "" then
											sampSendChat("������, ������ ��������.")
											wait(1700)
											sampSendChat("/n /showlic "..tostring(myid))
										end
									else
										sampSendChat("���������, �� �� ��� �� ���������.")
										wait(1700)
										sampSendChat("�� �������� � ׸���� ������ "..u8:decode(chgName.org[num_org.v+1]))
										sobes.player.bl = list_org_BL[num_org.v+1]
										return
									end
								else
									sampSendChat("���������, �� �� ��� �� ���������.")
									wait(1700)
									sampSendChat("� ��� �������� � �������.")
									wait(1700)
									sampSendChat("/n ���������� ���������������� 35+")
									wait(1700)
									sampSendChat("��������� � ��������� ���.")
									return
								end
							else
								sampSendChat("���������, �� �� ��� �� ���������.")
								wait(1700)
								sampSendChat("���������� ��� ������� ��������� 3 ���� � �����.")
								wait(1700)
								sampSendChat("��������� � ��������� ���.")
								return
							end
						end 
					end
					if dText:find("����������������") then
						HideDialogInTh()
						if dText:match("���: (%S+)") == sobes.player.name then
							sampSendChat("/me ���������"..chsex("", "����������").." ���������� � ���.�����, ����� ���� �����"..chsex("", "�").." ��� �������� ��������")
							sobes.player.narko = tonumber(dText:match("����������������: (%d+)"));
							if dText:find("��������� ��������") then
								if sobes.player.narko == 0 then
									sobes.player.heal = "������"
									if sobes.player.zak == 0 then
										sampSendChat("������, ������ �������.")
										wait(1700)
										sampSendChat("/n /showpass "..tostring(myid))
									elseif sobes.player.lic == "" then
										sampSendChat("������, ������ ��������.")
										wait(1700)
										sampSendChat("/n /showlic "..tostring(myid))
									end
								else
									sobes.player.heal = "������"
									if sobes.player.zak == 0 then
										sampSendChat("������, ��� ������� ����������.")
										wait(1700)
										sampSendChat("/n /showpass "..tostring(myid))
									elseif sobes.player.lic == "" then
										sampSendChat("������, ������ ��������.")
										wait(1700)
										sampSendChat("/n /showlic "..tostring(myid))
									end
								end
							else 
								sampSendChat("���������, �� � ��� �������� �� ���������.")
								wait(1700)
								sampSendChat("� ��� �������� �� ���������. ������� ����������� �����������.")
								sobes.player.heal = "������� ����������"
							end
						end 
					end
					if dText:find("�������� �� ����:") then
						HideDialogInTh()
						sampSendChat("/me ���������"..chsex("", "�").." ��������, ����� ���� �����"..chsex("", "�").." ��� �������� ��������")
						if dText:find("{FFFFFF}�������� �� ����: \t\t{10F441}����") then
							sobes.player.lic = "����";
						elseif dText:find("{FFFFFF}�������� �� ����: \t\t{FF6347}���") then
							sobes.player.lic = "����";
						end
						if sobes.player.lic == "����" then
							if sobes.player.zak == 0 then
								sampSendChat("������, ������ �������.")
								wait(1700)
								sampSendChat("/n /showpass "..tostring(myid))
							elseif sobes.player.narko == 0.1 then
								sampSendChat("������, ������ ���.�����.")
								wait(1700)
								sampSendChat("/n /showmc "..tostring(myid))
							end
						else
							if sobes.player.zak == 0 then
								sampSendChat("������, ������ �������.")
								wait(1700)
								sampSendChat("/n /showpass "..tostring(myid))
							elseif sobes.player.narko == 0.1 then
								sampSendChat("������, ������ ���.�����.")
								wait(1700)
								sampSendChat("/n /showmc "..tostring(myid))
							end
						end
					end
				end
			end
		end
		wait(1700)
		if sobes.player.lic == "����" then
			sampSendChat("��������, �� � ��� ���� �������� �� ��������.")
			sobes.nextQ = false
			return
		elseif sobes.player.work == "��� ������" then
			sampSendChat("�������, � ��� �� � ������� � �����������.")
			sobes.nextQ = true
			return
		else
			sampSendChat("�������, � ��� �� � ������� � �����������.")
			wait(1700)
			sampSendChat("�� �� ��������� �� ������ ��������������� ������, ��������� �������� ����� ������ ������������.")
			wait(1700)
			sampSendChat("/n ��������� �� ������, � ������� �� ������ ��������")
			wait(1700)
			sampSendChat("/n ��������� � ������� ������� /out ��� ������ Titan VIP ��� ��������� � �����.")
			sobes.nextQ = true
			return
		end
	end
	if id == 2 then
		sampSendChat("������ � ����� ��� ��������� ��������.")
		wait(1700)
		sampSendChat("� ����� ����� �� ������ ���������� � ��� � ��������?")
	end
	if id == 3 then
		sampSendChat("� ��� ���� ���� � ������ �����?")
	end
	if id == 4 then
	sampSendChat("�������, �� ������� � ��� �� ������.")
	sobes.nextQ = false
		if num_rank.v+1 <= 8 then
			wait(1700)
			sampSendChat("���������, ����������, � ���.�������� ����� ��� �������� �����")
			sobes.input.v = ""
			sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", lic = "", narko = 0.1}
			sobes.selID.v = ""
			sobes.nextQ = false
			sobes.num = 0
		else
			wait(1700)
			sampSendChat("������ � ����� ��� ����� �� �������� � ������ � ������� ������.")
			wait(1700)
			sampSendChat("/do � ������� ������ ��������� ����� �����������.")
			wait(1700)
			sampSendChat("/me ����������� �� ���������� ������ ������, ������"..chsex("", "�").." ������ ����.")
			wait(1700)
			sampSendChat("/me �������"..chsex("", "�").." ���� �� �������� �"..sobes.selID.v.." � ������ ������� �������� ��������.")
			wait(1700)
			sampSendChat("/invite "..sobes.selID.v)
			wait(1700)
			sampSendChat("/r ���������� � ���������� ������� �"..sobes.selID.v.." ���� ������ ����� � ������� � ���������.")
			sobes.input.v = ""
			sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", lic = "", narko = 0.1}
			sobes.selID.v = ""
			sobes.nextQ = false
			sobes.num = 0
		end
	end
	if id == 5 then
		wait(1700)
		sampSendChat("���������, �� � ��� ��������� � ��������")
		wait(1700)
		sampSendChat("/n ����� ��� ��� ������ �������.")
		sobes.input.v = ""
		sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", lic = "", narko = 0.1}
		sobes.selID.v = ""
		sobes.nextQ = false
		sobes.num = 0
	end
	if id == 6 then
		wait(1700)
		sampSendChat("���������, �� ��������� ��������� � ����� ��� ������� 3 ����.")
		sobes.input.v = ""
		sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", lic = "", narko = 0.1}
		sobes.selID.v = ""
		sobes.nextQ = false
		sobes.num = 0
	end
	if id == 7 then
		wait(1700)
		sampSendChat("���������, �� � ��� �������� � �������.")
		wait(1700)
		sampSendChat("/n ��������� ������� 35 �����������������.")
		sobes.input.v = ""
		sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", lic = "", narko = 0.1}
		sobes.selID.v = ""
		sobes.nextQ = false
		sobes.num = 0
	end
	if id == 8 then
		wait(1700)
		sampSendChat("���������, �� ��������� �� ������ ��������������� ������.")
		wait(1700)
		sampSendChat("/n ��������� �� ������, � ������� �� ������ ��������")
		wait(1700)
		sampSendChat("/n ��������� � ������� ������� /out ��� ������ Titan VIP ��� ��������� � �����.")
		sobes.input.v = ""
		sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", lic = "", narko = 0.1}
		sobes.selID.v = ""
		sobes.nextQ = false
		sobes.num = 0
	end
	if id == 9 then
		wait(1700)
		sampSendChat("���������, �� �� �������� � ������ ������ ����� ��������.")
		wait(1700)
		sampSendChat("/n ��� ��������� �� �� ��������� �������� ������ �� ������ � ������� ���.�����.")
		sobes.input.v = ""
		sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", lic = "", narko = 0.1}
		sobes.selID.v = ""
		sobes.nextQ = false
		sobes.num = 0
	end
	if id == 10 then
		wait(1700)
		sampSendChat("���������, �� � ��� �������� �� ���������.")
		sobes.input.v = ""
		sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", lic = "", narko = 0.1}
		sobes.selID.v = ""
		sobes.nextQ = false
		sobes.num = 0
	end
	if id == 11 then
		wait(1700)
		sampSendChat("���������, �� � ��� ������� ����������������.")
		wait(1700)
		sampSendChat("��� ������� ����� ������ ������ �������� � �������� ��� ���������� � ���.")
		sobes.input.v = ""
		sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", lic = "", narko = 0.1}
		sobes.selID.v = ""
		sobes.nextQ = false
		sobes.num = 0
	end
end

function HideDialogInTh(bool)
	repeat wait(0) until sampIsDialogActive()
	while sampIsDialogActive() do
		local memory = require 'memory'
		memory.setint64(sampGetDialogInfoPtr()+40, bool and 1 or 0, true)
		sampToggleCursor(bool)
	end
end

function ShowHelpMarker(stext)
	imgui.TextDisabled(u8"(?)")
	if imgui.IsItemHovered() then
	imgui.SetTooltip(stext)
	end
end


function rkeys.onHotKey(id, keys)
	if sampIsChatInputActive() or sampIsDialogActive() or isSampfuncsConsoleActive() or mainWin.v and editKey then
		return false
	end
end


function onHotKeyCMD(id, keys)
	if thread:status() == "dead" then
		local sKeys = tostring(table.concat(keys, " "))
		for k, v in pairs(cmdBind) do
			if sKeys == tostring(table.concat(v.key, " ")) then
				if k == 1 then
					mainWin.v = not mainWin.v
				elseif k == 2 then
					sampSetChatInputEnabled(true)
					if buf_teg.v ~= "" then
						sampSetChatInputText("/r "..u8:decode(buf_teg.v)..": ")
					else
						sampSetChatInputText("/r ")
					end
				elseif k == 3 then
					sampSetChatInputEnabled(true)
					sampSetChatInputText("/rb ")
				elseif k == 4 then
					sampSendChat("/members")
				elseif k == 5 then
					if targID then
						funCMD.lec(tostring(targID))
					else 
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/hl ")
					end
				elseif k == 6 then
					funCMD.time()
				elseif k == 7 then
					if targID then
						funCMD.expel(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/exp ")
					end
				elseif k == 8 then
					if targID then
						funCMD.osm(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/osm ")
					end
				elseif k == 9 then
					if targID then
						funCMD.cur(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/cur ")
					end
				elseif k == 10 then
					if targID then
						funCMD.med(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/mc ")
					end
				elseif k == 11 then
					if targID then
						funCMD.narko(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/vc ")
					end
				elseif k == 12 then
					if targID then
						funCMD.narko(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/narko ")
					end
				elseif k == 13 then
					if targID then
						funCMD.rec(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/rec ")
					end
				elseif k == 14 then
					if targID then
						funCMD.rec(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/antb ")
					end
				elseif k == 15 then
					if targID then
						funCMD.minsur(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/minsur")
					end
				elseif k == 16 then
					if targID then
						funCMD.tatu(tostring(targID))
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/tatu ")
					end
				elseif k == 17 then
					sobWin.v = not sobWin.v
				elseif k == 18 then
					if targID then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/+warn "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/+warn ")
					end
				elseif k == 19 then
					if targID then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/-warn "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/-warn ")
					end
				elseif k == 20 then
					if targID then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/+mute "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/+mute ")
					end
				elseif k == 21 then
					if targID then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/-mute "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/-mute ")
					end
				elseif k == 22 then
					if targID then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/gr "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/gr ")
					end
				elseif k == 23 then
					if resTatargIDrg then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/inv "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/inv ")
					end
				elseif k == 24 then
					if targID then
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/unv "..targID)
					else
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/unv ")
					end
				end
			end
		end
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: � ������ ������ ������������� ���������.", 0xEE4848)
	end
end

local function strBinderTable(dir)
	local tb = {
		vars = {},
		bind = {},
		debug = {
			file = true,
			close = {}
		},
		sleep = 1000
	}
	if doesFileExist(dir) then
		local l = {{},{},{},{},{}}
		local f1 = io.open(dir)
		local t = {}
		local ln = 0
		for line in f1:lines() do
			if line:find("^//.*$") then
				line = ""
			elseif line:find("//.*$") then
				line = line:match("(.*)//")
			end
			ln = ln + 1
			if #t > 0 then
				if line:find("%[name%]=(.*)$") then
					t[#t].name = line:match("%[name%]=(.*)$")
				elseif line:find("%[[%a%d]+%]=(.*)$") then
					local k, n = line:match("%[([%d%a]+)%]=(.*)$")
					local nk = vkeys["VK_"..k:upper()]
					if nk then
						local a = {n = n, k = nk, kn = k:upper(), t = {}}
						table.insert(t[#t].var, a)
					end
				elseif line:find("{dialogEnd}") then
					if #t > 1 then
						local a = #t[#t-1].var
						table.insert(t[#t-1].var[a].t, t[#t])
						t[#t] = nil
					elseif #t == 1 then
						table.insert(tb.bind, t[1])
						t = {}
					end
					table.remove(tb.debug.close)
				elseif line:find("{dialog}") then
					local b = {}
					b.name = ""
					b.var = {}
					table.insert(tb.debug.close, ln)
					table.insert(t, b)
				elseif #line > 0 and #t[#t].var > 0 then
					local a = #t[#t].var
					table.insert(t[#t].var[a].t, line)
				end
			else
				if line:find("{dialog}") and #t == 0 then
					local b = {} 
					b.name = ""
					b.var = {}
					table.insert(t, b)
					table.insert(tb.debug.close, ln)
				end
				if #tb.debug.close == 0 and #line > 0 then
					table.insert(tb.bind, line)
				end
			end
		end
		f1:close()
		return tb
	else
		tb.debug.file = false
		return tb
	end 
end

local function playBind(tb)
	if not tb.debug.file or #tb.debug.close > 0 then
		if not tb.debug.file then
			sampAddChatMessage("{FFFFFF}["..script_names.."]: ���� � ������� ����� �� ���������. ", 0xEE4848)
		elseif #tb.debug.close > 0 then
			sampAddChatMessage("{FFFFFF}["..script_names.."]: ������, ������ �������� �������� ������ �"..tb.debug.close[#tb.debug.close]..", �� ������ ����� {dialogEnd}", 0xEE4848)
		end
		addOneOffSound(0, 0, 0, 1058)
		return false
	end
	function pairsT(t, var)
		for i,line in ipairs(t) do
			if type(line) == "table" then
				renderT(line, var)
			else
				if line:find("{pause}") then
					local len = renderGetFontDrawTextLength(font, "{FFFFFF}[{67E56F}Enter{FFFFFF}] - ����������")
					while true do
						wait(0)
						if not isGamePaused() then
							renderFontDrawText(font, "��������...\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - ����������", sx-len-10, sy-60, 0xFFFFFFFF)
							if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then
								break
							end
						end
					end
				elseif line:find("{sleep:%d+}") then
					btime = tonumber(line:match("{sleep:(%d+)}"))
				elseif line:find("^%#[%d%a]+=.*$") then
					local var, val = line:match("^%#([%d%a]+)=(.*)$")
					tb.vars[var] = tags(val)			
				else
					wait(i == 1 and 0 or btime or tb.sleep*1000)
					btime = nil
					local str = line
					if var then
						for k,v in pairs(var) do
							str = str:gsub("#"..k, v)
						end
					end
					sampSendChat(tags(str))
				end
			end
		end
	end
	function renderT(t, var)
		local render = true
		local len = renderGetFontDrawTextLength(font, t.name)
		for i,v in ipairs(t.var) do
			local str = string.format("{FFFFFF}[{67E56F}%s{FFFFFF}] - %s", v.kn, v.n)
			if len < renderGetFontDrawTextLength(font, str) then
				len = renderGetFontDrawTextLength(font, str)
			end
		end
		repeat
			wait(0)
			if not isGamePaused() then
				renderFontDrawText(font, t.name, sx-10-len, sy-#t.var*25-30, 0xFFFFFFFF)
				for i,v in ipairs(t.var) do
					local str = string.format("{FFFFFF}[{67E56F}%s{FFFFFF}] - %s", v.kn, v.n)
					renderFontDrawText(font, str, sx-10-len, sy-#t.var*25-30+(25*i), 0xFFFFFFFF)
					if isKeyJustPressed(v.k) and not sampIsChatInputActive() and not sampIsDialogActive() then
						pairsT(v.t, var)
						render = false
					end
				end
			end
		until not render						
	end					
	pairsT(tb.bind, tb.vars)
end

function onHotKeyBIND(id, keys)
	if thread:status() == "dead" then
		local sKeys = tostring(table.concat(keys, " "))
		for k, v in pairs(binder.list) do
			if sKeys == tostring(table.concat(v.key, " ")) then
				thread = lua_thread.create(function()		
					local dir = dirml.."/MedicalHelper/Binder/"..v.name..".txt"	
					local tb = {}
					tb = strBinderTable(dir)
					tb.sleep = v.sleep
					playBind(tb)
					return
				end)
			end
		end
	end
end


function imgui.TextColoredRGB(string, max_float)
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local u8 = require 'encoding'.UTF8
	local function color_imvec4(color)
		if color:upper():sub(1, 6) == 'SSSSSS' then
			return imgui.ImVec4(colors[clr.Text].x, colors[clr.Text].y, colors[clr.Text].z, tonumber(color:sub(7, 8), 16) and tonumber(color:sub(7, 8), 16)/255 or colors[clr.Text].w)
		end
		local color = type(color) == 'number' and ('%X'):format(color):upper() or color:upper()
		local rgb = {}
		for i = 1, #color/2 do
			rgb[#rgb+1] = tonumber(color:sub(2*i-1, 2*i), 16)
		end
		return imgui.ImVec4(rgb[1]/255, rgb[2]/255, rgb[3]/255, rgb[4] and rgb[4]/255 or colors[clr.Text].w)
	end
	local function render_text(string)
		for w in string:gmatch('[^\r\n]+') do
			local text, color = {}, {}
			local render_text = 1
			local m = 1
			if w:sub(1, 8) == '[center]' then
				render_text = 2
				w = w:sub(9)
			elseif w:sub(1, 7) == '[right]' then
				render_text = 3
				w = w:sub(8)
			end
			w = w:gsub('{(......)}', '{%1FF}')
			while w:find('{........}') do
				local n, k = w:find('{........}')
				if tonumber(w:sub(n+1, k-1), 16) or (w:sub(n+1, k-3):upper() == 'SSSSSS' and tonumber(w:sub(k-2, k-1), 16) or w:sub(k-2, k-1):upper() == 'SS') then
					text[#text], text[#text+1] = w:sub(m, n-1), w:sub(k+1, #w)
					color[#color+1] = color_imvec4(w:sub(n+1, k-1))
					w = w:sub(1, n-1)..w:sub(k+1, #w)
					m = n
				else
					w = w:sub(1, n-1)..w:sub(n, k-3)..'}'..w:sub(k+1, #w)
				end
			end
			local length = imgui.CalcTextSize(u8(w))
			if render_text == 2 then
				imgui.NewLine()
				imgui.SameLine(max_float / 2 - ( length.x / 2 ))
			elseif render_text == 3 then
				imgui.NewLine()
				imgui.SameLine(max_float - length.x - 5 )
			end
			if text[0] then
				for i, k in pairs(text) do
					imgui.TextColored(color[i] or colors[clr.Text], u8(k))
					imgui.SameLine(nil, 0)
				end
				imgui.NewLine()
			else
				imgui.Text(u8(w))
			end
		end
	end
	render_text(string)
end

function imgui.GetMaxWidthByText(text)
	local max = imgui.GetWindowWidth()
	for w in text:gmatch('[^\r\n]+') do
		local size = imgui.CalcTextSize(w)
		if size.x > max then
			max = size.x
		end
	end
	return max - 15
end

function getSpurFile()
	spur.list = {}
    local search, name = findFirstFile("moonloader/MedicalHelper/���������/*.txt")
	while search do
		if not name then findClose(search) else
			table.insert(spur.list, tostring(name:gsub(".txt", "")))
			name = findNextFile(search)
			if name == nil then
				findClose(search)
				break
			end
		end
	end
end

function filter(mode, filderChar)
	local function locfil(data)
		if mode == 0 then
			if string.char(data.EventChar):find(filderChar) then 
				return true
			end
		elseif mode == 1 then
			if not string.char(data.EventChar):find(filderChar) then 
				return true
			end
		end
	end 
	
	local cbFilter = imgui.ImCallback(locfil)
	return cbFilter
end

function tags(par)
	par = par:gsub("{myID}", tostring(myid))
	par = par:gsub("{myNick}", tostring(sampGetPlayerNickname(myid):gsub("_", " ")))
	par = par:gsub("{myRusNick}", tostring(u8:decode(buf_nick.v)))
	par = par:gsub("{myHP}", tostring(getCharHealth(PLAYER_PED)))
	par = par:gsub("{myArmo}", tostring(getCharArmour(PLAYER_PED)))
	par = par:gsub("{myHosp}", tostring(u8:decode(chgName.org[num_org.v+1])))
	par = par:gsub("{myHospEn}", tostring(u8:decode(list_org_en[num_org.v+1])))
	par = par:gsub("{myTag}", tostring(u8:decode(buf_teg.v))) 
	par = par:gsub("{myRank}", tostring(u8:decode(chgName.rank[num_rank.v+1])))
	par = par:gsub("{time}", tostring(os.date("%X")))
	par = par:gsub("{day}", tostring(tonumber(os.date("%d"))))
	par = par:gsub("{week}", tostring(week[tonumber(os.date("%w"))]))
	par = par:gsub("{month}", tostring(month[tonumber(os.date("%m"))]))
	
	if targID ~= nil then
		par = par:gsub("{target}", targID)
	end
	if par:find("{getNickByID:%d+}") then
		for v in par:gmatch("{getNickByID:%d+}") do
			local id = tonumber(v:match("{getNickByID:(%d+)}"))
			if sampIsPlayerConnected(id) then
				par = par:gsub(v, tostring(sampGetPlayerNickname(id))):gsub("_", " ")
			else
				sampAddChatMessage("{FFFFFF}[{EE4848}MH:������{FFFFFF}]: �������� {getNickByID:ID} �� ���� ������� ��� ������. �������� ����� �� � ����.", 0xEE4848)
				par = par:gsub(v,"")
			end
		end
	end
	if par:find("{sex:[%w%s�-��-�]*|[%w%s�-��-�]*}") then	
		for v in par:gmatch("{sex:[%w%s�-��-�]*|[%w%s�-��-�]*}") do
			local m, w = v:match("{sex:([%w%s�-��-�]*)|([%w%s�-��-�]*)}")
			if num_sex.v == 0 then
				par = par:gsub(v, m)
			else
				par = par:gsub(v, w)
			end
		end
	end
	if par:find("{getNickByTarget}") then
		if targID ~= nil and targID >= 0 and targID <= 1000 and sampIsPlayerConnected(targID) then
			par = par:gsub("{getNickByTarget}", tostring(sampGetPlayerNickname(targID):gsub("_", " ")))
		else
			sampAddChatMessage("{FFFFFF}[{EE4848}MH:������{FFFFFF}]: �������� {getNickByTarget} �� ���� ������� ��� ������. �������� �� �� �������� �� ������, ���� �� �� � ����.", 0xEE4848)
			par = par:gsub("{getNickByTarget}", tostring(""))
		end
	end
	return par
end

funCMD = {} 
function funCMD.lec(id)
	if thread:status() ~= "dead" then
		sampAddChatMessage("{FFFFFF}["..script_names.."]: � ������ ������ ������������� ���������.", 0xEE4848)
		return
	end
	if not u8:decode(buf_nick.v):find("[�-��-�]+%s[�-��-�]+") then
		sampAddChatMessage("{FFFFFF}["..script_names.."]: ���������-��, ������� ����� ��������� ������� ����������. {90E04E}/mh > ��������� > �������� ����������", 0xEE4848)
		return
	end
	if id:find("%d+") then
		if GetPlayerDistance(id) or id == tostring(myid) then
			thread = lua_thread.create(function()
				if id ~= tostring(myid) then
					sampSendChat(string.format("�, %s - %s.", tostring(u8:decode(chgName.rank[num_rank.v+1])), u8:decode(buf_nick.v)))
					wait(1700)
					sampSendChat("���� ��� �����, ������ ���������� ��� ���-�� ������!")
					wait(1700)
				end
				sampSendChat("/do C���� ����� �� ����� ������ ����.")
				wait(1700)
				sampSendChat("/me ������ ����� ����������"..chsex("", "�").." ����������� ����� � ������"..chsex("", "�").." ������ ���������")
				wait(1700)
				if id ~= tostring(myid) then
					sampSendChat("/todo ���, �������*��������� ��������� �������� ��������")
					wait(1700)
				end
				sampSendChat("/heal "..id.." "..buf_lec.v)
				wait(1700)
				if id ~= tostring(myid) then
					sampSendChat("��� ���������� ��� ��������, � ����� ��������� ����� ��� ������ �����")
				end
			end)
		else
			sampAddChatMessage("{FFFFFF}["..script_names.."]: ����� ������� ���� ����� ���.", 0xEE4848)
		end
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: ����������� ������� /hl [id ������].", 0xEE4848)
	end
end
function funCMD.med(id)
	if thread:status() ~= "dead" then
		return sampAddChatMessage("{FFFFFF}["..script_names.."]: � ������ ������ ������������� ���������.", 0xEE4848)
	end
	if not u8:decode(buf_nick.v):find("[�-��-�]+%s[�-��-�]+") then
		return sampAddChatMessage("{FFFFFF}["..script_names.."]: ���������-��, ������� ����� ��������� ������� ����������. {90E04E}/mh > ��������� > �������� ����������", 0xEE4848)
	end
	if num_rank.v+1 < 3 then
		sampAddChatMessage("{FFFFFF}["..script_names.."]: ������ ������� ��� ����������. ��������� ��������� � ���������� �������, ���� ��� ���������.", 0xEE4848)
		return
	end
	if id:find("%d+") then
		if GetPlayerDistance(id) then
			thread = lua_thread.create(function()
				sampSendChat(string.format("�, %s - %s.", tostring(u8:decode(chgName.rank[num_rank.v+1])), u8:decode(buf_nick.v)))
				wait(1700)
				sampSendChat("�� ������ �������� ����������� ����� ������� ��� �������� ������������?")
				wait(1700)
				sampSendChat("������������, ����������, ��� �������")
				wait(1700)
				sampSendChat("/n /showpass "..tostring(myid))
				wait(1700)
				sampAddChatMessage("{FFFFFF}["..script_names.."]: ������� �� ����� ������� ������ ��� ������ ���� ���.������.", 0xEE4848)
				addOneOffSound(0, 0, 0, 1058)
				local len = renderGetFontDrawTextLength(font, "������ ���.�����: {8ABCFA}������")
				while true do
					wait(0)
					renderFontDrawText(font, "������ ���.�����: {8ABCFA}������\n{FFFFFF}[{67E56F}1{FFFFFF}] - ������ �����\n[{67E56F}2{FFFFFF}] - ����������", sx-len-10, sy-80, 0xFFFFFFFF)
					if isKeyJustPressed(VK_1) and not sampIsChatInputActive() and not sampIsDialogActive() then 
						sampSendChat("������, � ��� �����"..chsex("", "�")..". ��� ����� �������� ����� ���.�����.")
						wait(1700)
						sampSendChat("��� ���������� ����� ���������� ��� ������ �� ������� ���� ��� ����� ���.�����.")
						break
					end
					if isKeyJustPressed(VK_2) and not sampIsChatInputActive() and not sampIsDialogActive() then 
						sampSendChat("������, � ��� �����"..chsex("", "�")..". ��� ����� �������� ������ � ���.�����.")
						wait(1700)
						sampSendChat("��� ���������� ������ ���������� ��� ������ �� ������� ���� ��� ����� ���.�����.")
						break
					end
				end
				wait(1700)
				sampSendChat("�� 7 ���� - "..buf_medcard1.v.."$, �� 14 ���� - "..buf_medcard2.v.."$")
				wait(1700)
				sampSendChat("�� 30 ���� - "..buf_medcard3.v.."$, �� 60 ���� - "..buf_medcard4.v.."$.")
				wait(1700)
				sampSendChat("/n ���������� �� ���������, ������ ��� ���������")
				addOneOffSound(0, 0, 0, 1058)
				local len = renderGetFontDrawTextLength(font, "������ ���.�����: {8ABCFA}���� ���.�����")
				while true do
					wait(0)
					renderFontDrawText(font, "������ ���.�����: {8ABCFA}���� ���.�����\n{FFFFFF}[{67E56F}1{FFFFFF}] - 7 ����\n[{67E56F}2{FFFFFF}] - 14 ����\n[{67E56F}3{FFFFFF}] - 30 ����\n[{67E56F}4{FFFFFF}] - 60 ����", sx-len-10, sy-120, 0xFFFFFFFF)
					if isKeyJustPressed(VK_1) and not sampIsChatInputActive() and not sampIsDialogActive() then
						time = 0;
						money = buf_medcard1.v;
						break
					end
					if isKeyJustPressed(VK_2) and not sampIsChatInputActive() and not sampIsDialogActive() then
						time = 1;
						money = buf_medcard2.v;
						break
					end
					if isKeyJustPressed(VK_3) and not sampIsChatInputActive() and not sampIsDialogActive() then
						time = 2;
						money = buf_medcard3.v;
						break
					end
					if isKeyJustPressed(VK_4) and not sampIsChatInputActive() and not sampIsDialogActive() then
						time = 3;
						money = buf_medcard4.v;
						break
					end
				end
				sampSendChat("������, ����� ��������� � ����������.")
				wait(1700)
				sampSendChat("/me �������"..chsex("", "�").." �� ���������� ������� ��������� �����")
				wait(1700)
				sampSendChat("/do ����� � ������ ����.")
				wait(1700)
				sampSendChat("/me ������"..chsex("", "�").." �������, ������"..chsex("", "�").." ������ ������ ������ ��� ���.�����")
				wait(1700)
				sampSendChat("/me ��������"..chsex("", "�").." �������� ������ ���� ������� �� ������ ��������� � �����"..chsex("", "�������").." ������������ ������ � �����")
				wait(1700)
				sampSendChat("/me ������"..chsex("", "�").." ������ ���.����� � �������, ����� �����"..chsex("", "�").." ������������ ������ �� ��������")
				wait(1700)
				sampSendChat("/do ������ ������ ������ �������� ���� ���������� �� �����.")
				wait(1700)
				sampSendChat("/me �������"..chsex("", "�").." ������� � ������� ��� ������� � "..chsex("������������", "�������������").." � ����������� ��������� ����������")
				wait(1700)
				sampSendChat("���, ������ ����� ��������� �������� ������� ��������...")
				wait(1700)
				sampSendChat("������ �� �������� �������?")
				local len = renderGetFontDrawTextLength(font, "������ ���.�����: {8ABCFA}����� ��������")
				while true do
					wait(0)
					renderFontDrawText(font, "������ ���.�����: {8ABCFA}����� ��������\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - ����������", sx-len-10, sy-55, 0xFFFFFFFF)
					if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then
						break
					end
				end
				sampSendChat("������� �� ������� ��������, � ����� ������������� �������?")
				while true do
					wait(0)
					renderFontDrawText(font, "������ ���.�����: {8ABCFA}����� ��������\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - ����������", sx-len-10, sy-55, 0xFFFFFFFF)
					if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then
						break
					end
				end
				sampSendChat("/me �������"..chsex("", "�").." ��� ��������� ��������� � ���.�����")
				local len = renderGetFontDrawTextLength(font, "������ ���.�����: {8ABCFA}����. ���������")
				addOneOffSound(0, 0, 0, 1058)
				while true do
					wait(0)
					renderFontDrawText(font, "������ ���.�����: {8ABCFA}����. ���������\n{FFFFFF}[{67E56F}0{FFFFFF}] - �� ���������\n[{67E56F}1{FFFFFF}] - �����c��� ������(��)\n[{67E56F}2{FFFFFF}] - ����������� ��������������\n[{67E56F}3{FFFFFF}] - ���������� �� ������(��)", sx-len-10, sy-125, 0xFFFFFFFF)
					if isKeyJustPressed(VK_0) and not sampIsChatInputActive() and not sampIsDialogActive() then
						heal = 0;
						sampSendChat("/me ������"..chsex("", "�").." ������ �������� ������ '����. ��������.' - '�� ���������(��).'")
						break
					end	
					if isKeyJustPressed(VK_1) and not sampIsChatInputActive() and not sampIsDialogActive() then
						heal = 3;
						sampSendChat("/me ������"..chsex("", "�").." ������ �������� ������ '����. ��������.' - '��������� ������(��).'")
						break
					end				
					if isKeyJustPressed(VK_2) and not sampIsChatInputActive() and not sampIsDialogActive() then
						heal = 2;
						sampSendChat("/me ������"..chsex("", "�").." ������ �������� ������ '����. ��������.' - '������� ����������.'")
						break
					end				
					if isKeyJustPressed(VK_3) and not sampIsChatInputActive() and not sampIsDialogActive() then
						heal = 1;
						sampSendChat("/me ������"..chsex("", "�").." ������ �������� ������ '����. ��������.' - '����. ��������(��).'")
						break
					end
				end
				sampSendChat("/me ����"..chsex("", "�").." ����� "..tostring(u8:decode(list_org_en[num_org.v+1])).." � ������ ���� �� ����� ����� � �����"..chsex("", "��").." ������ � ���� ������")
				wait(1700)
				sampSendChat("/do ������ ��������.")			
				wait(1700)
				sampSendChat("/me ������� ����� � ������� � ��������"..chsex("", "�").." ���� �������, � ����������� ����")			
				wait(1700)
				sampSendChat("/do �������� ���.����� ���������.")	
				wait(1700)
				sampSendChat("�� ������, ������� ���� ���.�����, �� �������.")	
				wait(1700)
				sampSendChat("�������� ���.")
				wait(1700)
				sampSendChat("/medcard "..id.." "..heal.." "..time.." "..money)
			end)
		else
			sampAddChatMessage("{FFFFFF}["..script_names.."]: ����� ������� ���� ����� ���.", 0xEE4848)
		end
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: ����������� �������: /mc [id ������].", 0xEE4848)
	end
end
function funCMD.narko(id)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}["..script_names.."]: � ������ ������ ������������� ���������.", 0xEE4848)
		return 
	end
	if num_rank.v+1 < 4 then
		sampAddChatMessage("{FFFFFF}["..script_names.."]: ������ ������� ��� ����������. ��������� ��������� � ���������� �������, ���� ��� ���������.", 0xEE4848)
		return
	end
	if id:find("(%d+)") then
		if GetPlayerDistance(id) then
			thread = lua_thread.create(function()
				sampSendChat(string.format("�, %s - %s.", tostring(u8:decode(chgName.rank[num_rank.v+1])), u8:decode(buf_nick.v)))
				wait(1700)
				sampSendChat("������, �� ������ ���������� �� ����������������, ��� ������")
				wait(1700)
				sampSendChat("��������� ������ ���������� "..buf_narko.v.."$, �� ��������?")
				wait(1700)
				sampSendChat("/n ���������� �� ���������, ������ ��� ���������")
				wait(1700)
				sampSendChat("���� �� ��������, �������� �� ������� � ��������� �����")
				wait(1700)
				sampSendChat("/do �� ����� ����� �����, ���� � ����� � ��������.")
				wait(1700)
				sampSendChat("/me ����".. chsex("", "�") .." �� ����� ����")
				wait(1700)
				sampSendChat("/me �������".. chsex("", "�") .." ���� �� ����� ��������")
				wait(1700)
				sampSendChat("/do ���� ������ �������.")
				wait(1700)
				sampSendChat("��������� �������.")
				wait(1700)
				sampSendChat("/me ����".. chsex("", "�") .." ����� � ������".. chsex("", "�") .." � �������")
				wait(1700)
				sampSendChat("/me �����".. chsex("", "��") .." ������ �������� �����")
				wait(1700)
				sampSendChat("/todo �� ����������,����� �� ������*����".. chsex("", "�") .." �� ����� ����� � ��������")
				wait(1700)
				sampSendChat("/me ������� ��������� ������ ���� ������ ����")
				wait(1700)
				sampSendChat("/healbad "..id)
				wait(1700)
				sampSendChat("/todo ������� �����*������� ����� �� ����� �����")
				wait(1700)
				sampSendChat("/me ����".. chsex("", "�") .." ���� � �������".. chsex("", "�") .." ��� �� ����")
				wait(1700)
				sampSendChat("/me �������".. chsex("", "�") .." ����� � ����������� ����")
				wait(1700)
				sampSendChat("����� ��� �������.")
			end)
		else
			sampAddChatMessage("{FFFFFF}["..script_names.."]: ����� ������� ���� ����� ���.", 0xEE4848)
		end
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: ����������� ������� /narko [id ������].", 0xEE4848)
	end
end
function funCMD.rec(id)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}["..script_names.."]: � ������ ������ ������������� ���������.", 0xEE4848)
		return 
	end
	if num_rank.v+1 < 4 then
		sampAddChatMessage("{FFFFFF}["..script_names.."]: ������ ������� ��� ����������. ��������� ��������� � ���������� �������, ���� ��� ���������.", 0xEE4848)
		return
	end
	if id:find("(%d+)") then
		if GetPlayerDistance(id) then
			thread = lua_thread.create(function()
				sampSendChat(string.format("�, %s - %s.", tostring(u8:decode(chgName.rank[num_rank.v+1])), u8:decode(buf_nick.v)))
				wait(1700)
				sampSendChat("��� ����� ������?")
				wait(1700)
				sampSendChat("������, ��������� ������ ������� "..buf_rec.v.."$.")
				wait(1700)
				sampSendChat("������� ������� ��� ��������� ��������, ����� ���� �� ���������.")
				wait(1700)
				sampSendChat("/n ��������! � ������� ���� ������� �������� 5 �������� �� ����.")
				wait(500)
				sampAddChatMessage("{FFFFFF}["..script_names.."]: ������� �� ����� ������� �������� ������ ������ ���������� ���������� ��������.", 0xEE4848)
				local len = renderGetFontDrawTextLength(font, "������ ��������: {8ABCFA}����� ���-��")
				while true do
				wait(0)
					renderFontDrawText(font, "������ ��������: {8ABCFA}����� ���-��\n{FFFFFF}[{67E56F}1{FFFFFF}] - 1 ��.\n{FFFFFF}[{67E56F}2{FFFFFF}] - 2 ��.\n{FFFFFF}[{67E56F}3{FFFFFF}] - 3 ��.\n{FFFFFF}[{67E56F}4{FFFFFF}] - 4 ��.\n{FFFFFF}[{67E56F}5{FFFFFF}] - 5 ��.", sx-len-10, sy-150, 0xFFFFFFFF)					
					if isKeyJustPressed(VK_1) and not sampIsChatInputActive() and not sampIsDialogActive() then
						countRec = 1;
						break
					end
					if isKeyJustPressed(VK_2) and not sampIsChatInputActive() and not sampIsDialogActive() then
						countRec = 2;
						break
					end
					if isKeyJustPressed(VK_3) and not sampIsChatInputActive() and not sampIsDialogActive() then
						countRec = 3;
						break
					end
					if isKeyJustPressed(VK_4) and not sampIsChatInputActive() and not sampIsDialogActive() then
						countRec = 4;
						break
					end
					if isKeyJustPressed(VK_5) and not sampIsChatInputActive() and not sampIsDialogActive() then
						countRec = 5;
						break
					end
				end
				wait(200)
				sampSendChat("/do �� ����� ����� ���. �����.")
				wait(1700)
				sampSendChat("/me ����".. chsex("", "�") .." ���. ����� � �����, ����� ���� ������".. chsex("", "�") .." ��")
				wait(1700)
				sampSendChat("/me ������"..chsex("", "�").." ������")
				wait(1700)
				sampSendChat("/me ��������� ������ �� ���������� ��������")
				wait(1700)
				sampSendChat("/do ������ ���������.")
				wait(1700)
				sampSendChat("/me ��������".. chsex("", "�") .." ������ "..u8:decode(chgName.org[num_org.v+1]))
				wait(1700)
				sampSendChat("/me �������"..chsex("", "�").." ������")
				wait(1700)
				sampSendChat("/me ������".. chsex("", "�") .." ���. �����")
				wait(1700)
				sampSendChat("/me �������"..chsex("", "�").." ���. ����� �� �����")
				wait(1700)
				sampSendChat("/do ���. ����� �� �����.")
				wait(1700)
				sampSendChat("/recept "..id.." "..countRec)
				sampSendChat("��� ���� �������, ����� �������.")
			end)
		else
			sampAddChatMessage("{FFFFFF}["..script_names.."]: ����� ������� ���� ����� ���.", 0xEE4848)
		end
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: ����������� ������� /rec [id ������].", 0xEE4848)
	end
end
function funCMD.tatu(id)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}["..script_names.."]: � ������ ������ ������������� ���������.", 0xEE4848)
		return 
	end
	if num_rank.v+1 < 7 then
		sampAddChatMessage("{FFFFFF}["..script_names.."]: ������ ������� ��� ����������. ��������� ��������� � ���������� �������, ���� ��� ���������.", 0xEE4848)
		return
	end
	if id:find("(%d+)") then
		if GetPlayerDistance(id) then
			thread = lua_thread.create(function()
				sampSendChat(string.format("�, %s - %s.", tostring(u8:decode(chgName.rank[num_rank.v+1])), u8:decode(buf_nick.v)))
				wait(1700)
				sampSendChat("�� �� ������ �������� ����������?")
				wait(3000)
				sampSendChat("�������� ��� �������, ����������.")
				wait(1700)
				local len = renderGetFontDrawTextLength(font, "�������� ����: {8ABCFA}�������")
				while true do
				wait(0)
					renderFontDrawText(font, "�������� ����: {8ABCFA}�������\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - ����������", sx-len-10, sy-60, 0xFFFFFFFF)
					if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then
						break
					end
				end
				sampSendChat("/me ������"..chsex("", "�").." � ��� ������������� �������")
				wait(1700)
				sampSendChat("/do ������� ������������� � ������ ����.")
				wait(1700)
				sampSendChat("/me ������������� � ��������� �������������, ������"..chsex("", "�").." ��� �������")
				wait(1700)
				sampSendChat("��������� ��������� ���������� �������� "..buf_tatu.v.."$, �� ��������?")
				wait(1700)
				sampSendChat("/n ���������� �� ���������, ������ ��� ���������")
				wait(1700)
				sampSendChat("/n �������� ���������� � ������� ������� /showtatu")
				addOneOffSound(0, 0, 0, 1058)
				local len = renderGetFontDrawTextLength(font, "�������� ����: {8ABCFA}����������")
				while true do
				wait(0)
					renderFontDrawText(font, "�������� ����: {8ABCFA}����������\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - ����������", sx-len-10, sy-60, 0xFFFFFFFF)
					if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then
						break
					end
				end
				sampSendChat("� ������, �� ������, ����� �������� � ���� �������, ���� � �����"..chsex("", "�").." ���� ����������.")
				wait(1700)
				sampSendChat("/do � ����� ����� ���������������� ������ � ��������.")
				wait(1700)
				sampSendChat("/do ������� ��� ��������� ���� �� �������.")
				wait(1700)
				sampSendChat("/me ����"..chsex("", "�").." ������� ��� ��������� ���������� � �������")
				wait(1700)
				sampSendChat("/me �������� ��������, "..chsex("��������", "���������").." �������� ��� ����������")
				wait(1700)
				sampSendChat("/unstuff "..id.." "..buf_tatu.v)
				wait(5000)
				sampSendChat("��, ��� ����� ��������. ����� ��� ��������!?")
			end)
		else
			sampAddChatMessage("{FFFFFF}["..script_names.."]: ����� ������� ���� ����� ���.", 0xEE4848)
		end
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: ����������� ������� /tatu [id ������].", 0xEE4848)
	end	
end
function funCMD.antb(id)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}["..script_names.."]: � ������ ������ ������������� ���������.", 0xEE4848)
		return 
	end
	if num_rank.v+1 < 4 then
		sampAddChatMessage("{FFFFFF}["..script_names.."]: ������ ������� ��� ����������. ��������� ��������� � ���������� �������, ���� ��� ���������.", 0xEE4848)
		return
	end
	if id:find("(%d+)") then
		if GetPlayerDistance(id) then
			thread = lua_thread.create(function()
				sampSendChat(string.format("�, %s - %s.", tostring(u8:decode(chgName.rank[num_rank.v+1])), u8:decode(buf_nick.v)))
				wait(1700)
				sampSendChat("�� ������ ������ �����������?")
				wait(1700)
				sampSendChat("���� ����������� "..buf_antb.v.." �� ��.")
				wait(1700)
				sampSendChat("�������� ��� ���� ���. ����� � � ��� ����� ������� ��� �����")
				wait(1700)
				sampSendChat("/n /showmc "..tostring(myid))
				sampAddChatMessage("{FFFFFF}["..script_names.."]: �� ������ ���������� ������ ��� ����� (�� ��������� ����� �������� 5 ������������).", 0xEE4848)
				local len = renderGetFontDrawTextLength(font, "������ ������������: {8ABCFA}����������")
				while true do
				wait(0)
					renderFontDrawText(font, "������ ������������: {8ABCFA}����������\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - ����������", sx-len-10, sy-60, 0xFFFFFFFF)
					if sampIsDialogActive() then
						local dId = sampGetCurrentDialogId()
						if dId == 1234 then
							local dText = sampGetDialogText()
							if dText:find("�����������:") then
								tempcountAntb = tonumber(dText:match("�����������: %d/100"))/3
								countAntb = tempcountAntb+1
								HideDialogInTh()
								sampSendChat("� ��� ���� ��� ����� "..countAntb)
								break
							else
								HideDialogInTh()
								sampSendChat("�������� �� � ��� ���� ������������, � � �� ���� ��� ������ ��� ������� ��!")
								return
							end
						end
					end
					if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then
						countAntb = 5
						break
					end
				end
				wait(1700)
				sampSendChat("/do ������� �� ���������� ��������� � ����� � �����.")
				wait(1700)
				sampSendChat("/me ������"..chsex("", "�").." ������ �� �����")
				wait(1700)
				sampSendChat("/do ������� � �����.")
				wait(1700)
				sampSendChat("/me ��������"..chsex("", "�").." ������")
				wait(1700)
				sampSendChat("/antibiotik "..id.." "..countAntb)
				wait(1700)
				sampSendChat("/todo ������� ���� �������*��������� �������� �������")
				wait(1700)
				sampSendChat("����� �� ������ 5 �����, � �� ���������� �� COVID-19.")
				wait(1700)
				sampSendChat("� ����� ��������� �� ����������.")
			end)
		else
			sampAddChatMessage("{FFFFFF}["..script_names.."]: ����� ������� ���� ����� ���.", 0xEE4848)
		end
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: ����������� ������� /antb [id ������].", 0xEE4848)
	end	
end
function funCMD.cur(id)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}["..script_names.."]: � ������ ������ ������������� ���������.", 0xEE4848)
		return 
	end
	if num_rank.v+1 < 4 then
		sampAddChatMessage("{FFFFFF}["..script_names.."]: ������ ������� ��� ����������. ��������� ��������� � ���������� �������, ���� ��� ���������.", 0xEE4848)
		return
	end
	if id:find("(%d+)") then
		if GetPlayerDistance(id) then
			thread = lua_thread.create(function()
				sampSendChat("/todo ���-�� ��� ������ �� ������*������ ����������� ����� � �����")
				wait(1700)
				sampSendChat("/me ������ ����������� ����� ����� �������������")
				wait(1700)
				sampSendChat("/do ���. ����� �� �����.")
				wait(1700)
				sampSendChat("/me ����������� ��� �����, ����� ����������� ����� �� ������ �������")
				wait(1700)
				sampSendChat("/do ����� ������.")
				wait(1700)
				sampSendChat("/me �������� �������� ������ ������, ����� �� ������� �������� �����")
				wait(1700)
				sampSendChat("/cure "..id)
				wait(1700)
				sampSendChat("/do ������ �������� ������ ������.")
			end)
		else
			sampAddChatMessage("{FFFFFF}["..script_names.."]: ����� ������� ���� ����� ���.", 0xEE4848)
		end
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: ����������� ������� /cur [id ������].", 0xEE4848)
	end	
end
function funCMD.minsur(id)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}["..script_names.."]: � ������ ������ ������������� ���������.", 0xEE4848)
		return 
	end
	if num_rank.v+1 < 4 then
		sampAddChatMessage("{FFFFFF}["..script_names.."]: ������ ������� ��� ����������. ��������� ��������� � ���������� �������, ���� ��� ���������.", 0xEE4848)
		return
	end
	if id:find("(%d+)") then
		if GetPlayerDistance(id) then
			thread = lua_thread.create(function()
				sampSendChat(string.format("�, %s - %s.", tostring(u8:decode(chgName.rank[num_rank.v+1])), u8:decode(buf_nick.v)))
				wait(1700)
				sampSendChat("�� ������ �������� ���������?")
				wait(1700)
				sampSendChat("����� ��� ����������� ��� ������� � ���.�����.")
				sampAddChatMessage("{FFFFFF}["..script_names.."]: ������� ��  {23E64A}Enter{FFFFFF} ��� ����������� ��� {23E64A}Page Down{FFFFFF}, ����� ��������� ������.", 0xEE4848)
				addOneOffSound(0, 0, 0, 1058)
				local len = renderGetFontDrawTextLength(font, "������ ���������: {8ABCFA}����������")
				while true do
				wait(0)
					renderFontDrawText(font, "������ ���������: {8ABCFA}����������\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - ����������.", sx-len-10, sy-60, 0xFFFFFFFF)
					if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then
						break
					end
				end
				sampSendChat("/todo ���������*���� ��������� � ������ �� �� ������ ��������")
				wait(1700)
				sampSendChat("������ ��� ���������� ���������?")
				wait(1700)
				sampSendChat("���� �������� ��������� ������� ���� ���������.")
				wait(1700)
				sampSendChat("�� ������ ��������� ��������� ������������, ������� � ������.")
				wait(1700)
				sampSendChat("/n ������� �� ������ + ������� �� ����� ���������� ���������!")
				wait(1700)
				sampSendChat("/do ������ ���������� � ����������.")
				wait(1700)
				sampSendChat("/me ������ ������� ������ �� ���� ������� ����� ������ ���.")
				wait(1700)
				sampSendChat("/do �� ����� ����� �����.")
				wait(1700)
				sampSendChat("/me ��������� �� ����� �� ����� � ����� ���������� ���������� � ����� � ����������.")
				wait(1700)
				sampSendChat("�� ����� ������ �� ������ �������� ���������.")
				wait(1700)
				sampSendChat("�� ����� ������� ����:")
				wait(1700)
				sampSendChat("1 ������ - 400.000")
				wait(1700)
				sampSendChat("2 ������ - 800.000")
				wait(1700)
				sampSendChat("3 ������ - 1.200.000")
				addOneOffSound(0, 0, 0, 1058)
				local len = renderGetFontDrawTextLength(font, "������ ���������: {8ABCFA}����� �����")
				while true do
				wait(0)
					renderFontDrawText(font, "������ ���������: {8ABCFA}����� �����\n{FFFFFF}[{67E56F}1{FFFFFF}] - 1 ������.\n{FFFFFF}[{67E56F}2{FFFFFF}] - 2 ������.\n{FFFFFF}[{67E56F}3{FFFFFF}] - 3 ������.", sx-len-10, sy-90, 0xFFFFFFFF)					
					if isKeyJustPressed(VK_1) and not sampIsChatInputActive() and not sampIsDialogActive() then
						week = 1;
						cost = 400000;
						break
					end
					if isKeyJustPressed(VK_2) and not sampIsChatInputActive() and not sampIsDialogActive() then
						week = 2;
						cost = 800000;
						break
					end
					if isKeyJustPressed(VK_3) and not sampIsChatInputActive() and not sampIsDialogActive() then
						week = 3;
						cost = 1200000;
						break
					end
				end
				sampSendChat("/todo ������*��������� ���������� � �����.")
				wait(1700)
				sampSendChat("/me ������� ��� ���������� � ����� ������ ������ �� ��������.")
				wait(1700)
				sampSendChat("/me ������ �������� ������ ����� ������ �� �.�������.")
				wait(1700)
				sampSendChat("/do �� ��������� ������ "..tostring(u8:decode(list_org_en[num_org.v+1]))..".")
				wait(1700)
				sampSendChat("/todo ���� ��������� ������, �����*��������� �������� �������� ��������.")
				wait(1700)
				sampAddChatMessage("{FFFFFF}["..script_names.."]: ����� ������ �� "..week.." ������ ���� ���������� "..cost.."$", 0xEE4848)
				wait(1700)
				sampSendChat("/givemedinsurance "..id)
				wait(1700)
				sampSendChat("�������� ��� � �� �������")
			end)
		else
			sampAddChatMessage("{FFFFFF}["..script_names.."]: ����� ������� ���� ����� ���.", 0xEE4848)
		end
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: ����������� ������� /minsur [id ������].", 0xEE4848)
	end	
end
function funCMD.vc(id)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}["..script_names.."]: � ������ ������ ������������� ���������.", 0xEE4848)
		return 
	end
	if num_rank.v+1 < 3 then
		sampAddChatMessage("{FFFFFF}["..script_names.."]: ������ ������� ��� ����������. ��������� ��������� � ���������� �������, ���� ��� ���������.", 0xEE4848)
		return
	end
	if id:find("(%d+)") then
		if GetPlayerDistance(id) then
			if Vaccine[3] == id or Vaccine[3] == -1 then
				if Vaccine[2] == 0 then
					thread = lua_thread.create(function()
						if Vaccine[1] ~= 1 then
							sampSendChat(string.format("�, %s - %s.", tostring(u8:decode(chgName.rank[num_rank.v+1])), u8:decode(buf_nick.v)))
							wait(1700)
							sampSendChat("�� ������ �� ����������?")
							wait(1700)
							sampSendChat("� ����� ����� ��������� �������������� ���������� 150.000$")
							wait(1700)
							sampSendChat("/n ���������� �� ���������, ������ ��� ���������")
							wait(1700)
							sampSendChat("������, ��������� ��� ���������� ���� ���.�����.")
							wait(1700)
							sampSendChat("/n /showmc "..tostring(myid))
							wait(1700)
							while true do
							wait(0)
								if sampIsDialogActive() then
									local dId = sampGetCurrentDialogId()
									if dId == 1234 then
										local dText = sampGetDialogText()
										if dText:find("�����������:") then
											HideDialogInTh()
											sampSendChat("/todo ���������*���� ���.����� � ������ � �� ������ ��������")
											wait(1700)
											sampSendChat("�������� �� � ��� �����������!")
											wait(1700)
											sampSendChat("�� ������ ������ ����������� � ����� �������� ��� �� ����������� �����!")
											return
										elseif dText:find("{31B404}������� �� ������������:\n �������") then
											HideDialogInTh()
											sampSendChat("/todo ���������*���� ���.����� � ������ � �� ������ ��������")
											sampSendChat("�������� �� � ��� ��� ���� �������!")
											return
										else
											HideDialogInTh()
											sampSendChat("/todo ���������*���� ���.����� � ������ � �� ������ ��������")
											break
										end
									end
								end
							end
							sampSendChat("/me ������"..chsex("", "�").." �� ���.����� ����� � ��������, �������"..chsex("", "�").." ��� �� ����")
							wait(1700)
							sampSendChat("/me ��������"..chsex("", "�").." ���� � ������ ������ ������ ������"..chsex("", "�").." �� ���� ���� ��������, ����� ����"..chsex("", "�").." ��")
							wait(1700)
							sampSendChat("/me ������"..chsex("", "�").." �� ������ ������� ����-������, ��������� ���������"..chsex("", "�").." �� ����")
							wait(1700)
							sampSendChat("/do � ������ ���������� ������ ���� �������.")
							wait(1700)
							sampSendChat("/me ����"..chsex("", "�").." �������� ��������, �������"..chsex("", "�").." ������ �� ������")
							wait(1700)
							sampSendChat("/me ������"..chsex("", "�").." �� ���.����� ����� � �����, �������� ����� � ����� ����� ���������"..chsex("", "�").." ������� �����")
							wait(1700)
							sampSendChat("/todo ������ �� ���������, ����� ������� �� �������*������ �� ������� �����")
							wait(1700)
							sampSendChat("/me ���������� ��������� ���� ���"..chsex("", "�").." ����� � ����, ����� �������")
							wait(1700)
							sampSendChat("/vaccine "..id)
							wait(1700)
							sampSendChat("/todo ��� � ��, ������� �����*��������� ����� ��������")
							wait(1700)
							sampSendChat("/todo �������"..chsex("", "�").." ����� � ����*����� 2 ������ ������ ��� ������� ������ �������.")
							Vaccine = {1, 120, id}
							return
						elseif Vaccine[1] == 1 then
							sampSendChat("/do ����������� ����� �� �����.")
							wait(1700)
							sampSendChat("/me �����"..chsex("", "�").." ��������� ����� ����� � ��������")
							wait(1700)
							sampSendChat("/do ����� � �������� � ������ ����.")
							wait(1700)
							sampSendChat("/me ��������� �������� ������� �������� �������� �� ������")
							wait(1700)
							sampSendChat("/do � ������ ���������� ������ ���� �������.")
							wait(1700)
							sampSendChat("/vaccine "..id)
							wait(1700)
							sampSendChat("/do ������� �������.")
							wait(1700)
							sampSendChat("/me �����"..chsex("", "�").." ������� �������������� ����� � �����")
							wait(1700)
							sampSendChat("���� ��� ���������� � �������� ���������������.")
							wait(1700)
							sampSendChat("���� ����� ������ �� ������������ � ����� �� ���������� � ���.")
							Vaccine = {0, 0, -1}
						end
					end)
				else
					sampAddChatMessage("{FFFFFF}["..script_names.."]: � ����� ������ ��� �� ������� ���, �������� "..Vaccine[2].." ���.", 0xEE4848)
				end
			else
				sampAddChatMessage("{FFFFFF}["..script_names.."]: �� ��� �� ��������� ����� �������������� � "..tostring(sampGetPlayerNickname(Vaccine[3]):gsub("_", " ")).."", 0xEE4848)
				sampAddChatMessage("{FFFFFF}["..script_names.."]: ����� �������� ����� �������������� /canclevc", 0xEE4848)
			end
		else
			sampAddChatMessage("{FFFFFF}["..script_names.."]: ����� ������� ���� ����� ���.", 0xEE4848)
		end
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: ����������� ������� /vc [id ������].", 0xEE4848)
	end	
end
function funCMD.warn(text)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}["..script_names.."]: � ������ ������ ������������� ���������.", 0xEE4848)
		return 
	end
	if num_rank.v+1 < 8 then
		sampAddChatMessage("{FFFFFF}["..script_names.."]: ������ ������� ��� ����������. ��������� ��������� � ���������� �������, ���� ��� ���������.", 0xEE4848)
		return
	end
	if text:find("(%d+)%s(%X+)") then
		local id, reac = text:match("(%d+)%s(%X+)")
		thread = lua_thread.create(function()
			sampSendChat("/do � ����� ������� ����� ���.")
			wait(1700)
			sampSendChat("/me ������ ��� �� ������ �������, ����� ���� ".. chsex("�����", "�����") .." � ���� ������ "..u8:decode(chgName.org[num_org.v+1]))
			wait(1700)
			sampSendChat("/me �������"..chsex("", "�").." ���������� � ����������.")
			wait(1700)
			sampSendChat("/fwarn "..id.." "..reac)
			wait(1700)
			sampSendChat("/r ���������� � ��������� �"..id.." ��� ����� ������� �� �������: "..reac)
		end)
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: ����������� ������� /+warn [id ������] [�������].", 0xEE4848)
	end
end
function funCMD.uwarn(id)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}["..script_names.."]: � ������ ������ ������������� ���������.", 0xEE4848)
		return 
	end
	if num_rank.v+1 < 8 then
		sampAddChatMessage("{FFFFFF}["..script_names.."]: ������ ������� ��� ����������. ��������� ��������� � ���������� �������, ���� ��� ���������.", 0xEE4848)
		return
	end
	if id:find("(%d+)") then
		thread = lua_thread.create(function()
			sampSendChat("/do � ����� ������� ����� ���.")
			wait(1700)
			sampSendChat("/me ������ ��� �� ������ �������, ����� ���� ".. chsex("�����", "�����") .." � ���� ������ "..u8:decode(chgName.org[num_org.v+1]))
			wait(1700)
			sampSendChat("/me �������"..chsex("", "�").." ���������� � ����������.")
			wait(1700)
			sampSendChat("/unfwarn "..id)
		end)
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: ����������� ������� /-warn [id ������].", 0xEE4848)
	end
end
function funCMD.inv(id)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}["..script_names.."]: � ������ ������ ������������� ���������.", 0xEE4848)
		return 
	end
	if num_rank.v+1 < 9 then
		sampAddChatMessage("{FFFFFF}["..script_names.."]: ������ ������� ��� ����������. ��������� ��������� � ���������� �������, ���� ��� ���������.", 0xEE4848)
		return
	end
	if id:find("(%d+)") then
		if GetPlayerDistance(id) then
			thread = lua_thread.create(function()
				sampSendChat("/do � ������� ������ ��������� ����� �����������.")
				wait(1700)
				sampSendChat("/me ����������� �� ���������� ������ ������, ������"..chsex("", "�").." ������ ����.")
				wait(1700)
				sampSendChat("/me �������"..chsex("", "�").." ���� �� �������� �"..id.." � ������ �������� ��������.")
				wait(1700)
				sampSendChat("/invite "..id)
				wait(1700)
				sampSendChat("/r ���������� � ���������� ������� �"..id.." ���� ������ ����� � ������� � ���������.")
			end)
		else
			sampAddChatMessage("{FFFFFF}["..script_names.."]: ����� ������� ���� ����� ���.", 0xEE4848)
		end
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: ����������� ������� /inv [id ������].", 0xEE4848)
	end
end
function funCMD.unv(text)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}["..script_names.."]: � ������ ������ ������������� ���������.", 0xEE4848)
		return 
	end
	if num_rank.v+1 < 9 then
		sampAddChatMessage("{FFFFFF}["..script_names.."]: ������ ������� ��� ����������. ��������� ��������� � ���������� �������, ���� ��� ���������.", 0xEE4848)
		return
	end
	if text:find("(%d+)%s(%X+)") then
		local id, reac = text:match("(%d+)%s(%X+)")
		lua_thread.create(function()
			sampSendChat("/do � ����� ������� ����� ���.")
			wait(1700)
			sampSendChat("/me ������ ��� �� ������ �������, ����� ���� ".. chsex("�����", "�����") .." � ���� ������ "..u8:decode(chgName.org[num_org.v+1]))
			wait(1700)
			sampSendChat("/me �������"..chsex("", "�").." ���������� � ����������.")
			wait(1700)
			sampSendChat("/uninvite "..id.." "..reac)
			wait(1200)
			sampSendChat("/r ��������� � ��������� �"..id.." ��� ������ �� �������: "..reac)
		end)
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: ����������� ������� /unv [id ������] [�������].", 0xEE4848)
	end
end
function funCMD.mute(text)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}["..script_names.."]: � ������ ������ ������������� ���������.", 0xEE4848)
		return 
	end
	if num_rank.v+1 < 8 then
		sampAddChatMessage("{FFFFFF}["..script_names.."]: ������ ������� ��� ����������. ��������� ��������� � ���������� �������, ���� ��� ���������.", 0xEE4848)
		return
	end
	if text:find("(%d+)%s(%d+)%s(%X+)") then
		local id, timem, reac = text:match("(%d+)%s(%d+)%s(%X+)")
		thread = lua_thread.create(function()
			sampSendChat("/do ����� ����� �� �����.")
			wait(1700)		
			sampSendChat("/me ����".. chsex("", "�") .." ����� � �����")
			wait(1700)
			sampSendChat("/me ".. chsex("�����", "�����") .." � ��������� ��������� ������ ������� �����")
			wait(1700)					
			sampSendChat("/me ��������".. chsex("", "�") .." ��������� ������� ������� � ���������� ������� "..id)
			wait(1700)
			sampSendChat("/fmute "..id.." "..timem.." "..reac)
			wait(1700)
			sampSendChat("/r ���������� � ��������� �"..id.." ���� ��������� ����� �� �������: "..reac)
			wait(1700)		
			sampSendChat("/me �������".. chsex("", "�") .." ������� ����� �� ����")
		end)
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: ����������� ������� /+mute [id ������] [����� � �������] [�������].", 0xEE4848)
	end
end
function funCMD.umute(id)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}["..script_names.."]: � ������ ������ ������������� ���������.", 0xEE4848)
		return 
	end
	if num_rank.v+1 < 8 then
		sampAddChatMessage("{FFFFFF}["..script_names.."]: ������ ������� ��� ����������. ��������� ��������� � ���������� �������, ���� ��� ���������.", 0xEE4848)
		return
	end
	if id:find("(%d+)") then
		if GetPlayerDistance(id) then
			thread = lua_thread.create(function()
				sampSendChat("/do ����� ����� �� �����.")
				wait(1700)		
				sampSendChat("/me ���� ����� � �����")
				wait(1700)
				sampSendChat("/me ".. chsex("�����", "�����") .." � ��������� ��������� ������ ������� �����")
				wait(1700)					
				sampSendChat("/me ��������� ��������� ������� ������� � ���������� ������� "..id)
				wait(1700)
				sampSendChat("/funmute "..id)
				wait(1700)		
				sampSendChat("/me ������� ������� ����� �� ����")
			end)
		else
			sampAddChatMessage("{FFFFFF}["..script_names.."]: ����� ������� ���� ����� ���.", 0xEE4848)
		end
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: ����������� ������� /-mute [id ������].", 0xEE4848)
	end
end
function funCMD.rank(text)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}["..script_names.."]: � ������ ������ ������������� ���������.", 0xEE4848)
		return 
	end
	if num_rank.v+1 < 9 then
		sampAddChatMessage("{FFFFFF}["..script_names.."]: ������ ������� ��� ����������. ��������� ��������� � ���������� �������, ���� ��� ���������.", 0xEE4848)
		return
	end
		if text:find("(%d+)%s([1-9])") then
		local id, rankNum = text:match("(%d+)%s(%d)")
		id = tonumber(id); rankNum = tonumber(rankNum);
		if GetPlayerDistance(id) then
			thread = lua_thread.create(function()
				sampSendChat("/do � ������� ������ ��������� ������ � ������� �� ��������� � ������.")
				wait(1700)
				sampSendChat("/me ����������� �� ���������� ������ ������, ������".. chsex("", "�"))
				wait(1700)
				sampSendChat("/me ������ ������, ������".. chsex("", "�") .." �� ���� ���� c ������� '"..id.."'")
				wait(1700)
				sampSendChat("/me �������".. chsex("", "�") .." ���� �� �������� �"..id.." � ������ "..u8:decode(chgName.rank[rankNum]).."� �������� ��������")
				wait(1700)
				sampSendChat("/giverank "..id.." "..rankNum)
				wait(1700)
				sampSendChat("/r ���������� � ��������� �"..id.." ���� ������ ����� �����.")
			end)
		else
			sampAddChatMessage("{FFFFFF}["..script_names.."]: ����� ������� ���� ����� ���.", 0xEE4848)
		end
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: ����������� ������� /gr [id ������] [����� �����].", 0xEE4848)
	end
end
function funCMD.osm(id)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}["..script_names.."]: � ������ ������ ������������� ���������.", 0xEE4848)
		return 
	end
	if id:find("(%d+)") then
		if GetPlayerDistance(id) then
			thread = lua_thread.create(function()
				sampAddChatMessage("{FFFFFF}["..script_names.."]: ������� �� {23E64A}Enter{FFFFFF}, ���� ������ ������ ������.", 0xEE4848)
				addOneOffSound(0, 0, 0, 1058)
				local len = renderGetFontDrawTextLength(font, "{FFFFFF}[{67E56F}Enter{FFFFFF}] - ����������")
				while true do
				wait(0)
					renderFontDrawText(font, "������: {8ABCFA}������\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - ����������", sx-len-10, sy-60, 0xFFFFFFFF)
					if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then
						break
					end
				end
				sampSendChat("������ � ������� ��� ��� ��������� ���.������������.")
				wait(1700)
				sampSendChat("����������, ������������ ���� ���.�����.")
				local len = renderGetFontDrawTextLength(font, "������: {8ABCFA}�������� ������")
				addOneOffSound(0, 0, 0, 1058)
				while true do
				wait(0)
					renderFontDrawText(font, "������: {8ABCFA}�������� ������\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - ����������", sx-len-10, sy-60, 0xFFFFFFFF)
					if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then
						break
					end
				end
				sampSendChat("/me ����"..chsex("", "�").." ���.����� �� ��� �������")
				wait(1700)
				sampSendChat("/do ���.����� � �����. ")
				wait(1700)
				sampSendChat("/do ����� � ������ � �����.")
				wait(1700)
				sampSendChat("����, ������ � ����� ��������� ������� ��� ������ ��������� ��������.")
				wait(1700)
				sampSendChat("����� �� �� ������? ���� ��, �� ������ ���������.")
				addOneOffSound(0, 0, 0, 1058)
				while true do
				wait(0)
					renderFontDrawText(font, "������: {8ABCFA}�������� ������\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - ����������", sx-len-10, sy-60, 0xFFFFFFFF)
					if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then
						break
					end
				end
				sampSendChat("���� �� � ��� ������?")
				addOneOffSound(0, 0, 0, 1058)
				while true do
				wait(0)
					renderFontDrawText(font, "������: {8ABCFA}�������� ������\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - ����������", sx-len-10, sy-60, 0xFFFFFFFF)
					if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then
						break
					end
				end
				wait(1700)
				sampSendChat("������� �� �����-�� ������������� �������?")
				addOneOffSound(0, 0, 0, 1058)
				while true do
				wait(0)
					renderFontDrawText(font, "������: {8ABCFA}�������� ������\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - ����������", sx-len-10, sy-60, 0xFFFFFFFF)
					if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then
						break
					end
				end
				sampSendChat("/me ������"..chsex("", "�").." ������ � ���. �����")
				wait(1700)
				sampSendChat("���, �������� ���.")
				wait(1700)
				sampSendChat("/n /me ������(�) ���")
				addOneOffSound(0, 0, 0, 1058)
				while true do
				wait(0)
					renderFontDrawText(font, "������: {8ABCFA}�������� ������\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - ����������", sx-len-10, sy-60, 0xFFFFFFFF)
					if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then
						break
					end
				end
				sampSendChat("/do � ������� �������.")
				wait(1700)
				sampSendChat("/me ������"..chsex("", "�").." ������� �� ������� � ������� ���")
				wait(1700)
				sampSendChat("/me ��������"..chsex("", "�").." ����� ��������")
				wait(1700)
				sampSendChat("������ ������� ���.")
				wait(3000)
				sampSendChat("/me ��������"..chsex("", "�").." ������� ������� �������� �� ����, �������� � �����")
				wait(1700)
				sampSendChat("/do ������� ���� ������������ ��������.")
				wait(1700)
				sampSendChat("/me ��������"..chsex("", "�").." ������� � �����"..chsex("", "�").." ��� � ������")
				wait(1700)
				sampSendChat("���������, ����������, �� �������� � ��������� �������� ������ �� ����.")
				addOneOffSound(0, 0, 0, 1058)
				local len = renderGetFontDrawTextLength(font, "������: {8ABCFA}�������� ��������")
				while true do
				wait(0)
					renderFontDrawText(font, "������: {8ABCFA}�������� ��������\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - ����������", sx-len-10, sy-60, 0xFFFFFFFF)
					if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then
						break
					end
				end
				sampSendChat("���������.")
				wait(1700)
				sampSendChat("/me ������"..chsex("", "�").." ������ � ���. �����")
				wait(1700)
				sampSendChat("/me ������"..chsex("", "�").." ���.����� �������� ��������")
				sampSendChat("�������, ������ ���� ��������")
			end)
		else
			sampAddChatMessage("{FFFFFF}["..script_names.."]: ����� ������� ���� ����� ���.", 0xEE4848)
		end
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: ����������� ������� /osm [id ������].", 0xEE4848)
	end
end
function funCMD.time()
	lua_thread.create(function()
		sampSendChat("/time")
		wait(1500)
		setVirtualKeyDown(VK_F8, true)
		wait(20)
		setVirtualKeyDown(VK_F8, false)
	end)
end
function funCMD.expel(id)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}["..script_names.."]: � ������ ������ ������������� ���������.", 0xEE4848)
		return 
	end
	if id:find("(%d+)") then
		if GetPlayerDistance(id) then
			thread = lua_thread.create(function()
				sampSendChat("/me ������ ��������� ���� "..chsex("���������", "����������").." �� �������� ����������")
				wait(1700)
				sampSendChat("/todo � ��������"..chsex("", "�").." ������� ��� �� ������*����������� � ������.")
				wait(1700)
				sampSendChat("/me ��������� ����� ���� ������"..chsex("", "�").." ������� �����, ����� ���� ���������"..chsex("", "�").." ����������")
				addOneOffSound(0, 0, 0, 1058)
				local len = renderGetFontDrawTextLength(font, "{FFFFFF}[{67E56F}2{FFFFFF}] - ��������� ������ ���.������")
				while true do
				wait(0)
					renderFontDrawText(font, "������� �� ��������: {8ABCFA}����� �������\n{FFFFFF}[{67E56F}1{FFFFFF}] - ������������ ���������\n{FFFFFF}[{67E56F}2{FFFFFF}] - ��������� ������ ���.������", sx-len-10, sy-80, 0xFFFFFFFF)
					if isKeyJustPressed(VK_1) and not sampIsChatInputActive() and not sampIsDialogActive() then
						reas = "������������ ���������"
						break
					end
					if isKeyJustPressed(VK_2) and not sampIsChatInputActive() and not sampIsDialogActive() then
						reas = "��������� ������ ���.������"
						break
					end
				end
				wait(1700)
				sampSendChat("/expel "..id.." "..reas)
			end)
		else
			sampAddChatMessage("{FFFFFF}["..script_names.."]: ����� ������� ���� ����� ���.", 0xEE4848)
		end
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: ����������� ������� /exp [id ������].", 0xEE4848)
	end
end
function funCMD.update()
	if newversion == scr.version then
		sampAddChatMessage("{FFFFFF}["..script_names.."]: �� ����������� ����� ����� ������ �������.", 0xEE4848)
	else
		local dir = dirml.."/MedicalHelper for Ministries of Health.lua"
		local url = "https://github.com/Dev-Filatov/MedicalHelper/blob/main/MedicalHelper%20by%20Kyle_Miller%20for%20GILBERT.lua?raw=true"
		downloadUrlToFile(url, dir, function(id, status, p1, p2)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if updates == nil then 
					print("{FF0000}������ ��� ������� ������� ����.") 
					addOneOffSound(0, 0, 0, 1058)
				end
			end
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				updates = true
				sampAddChatMessage("{FFFFFF}["..script_names.."]: ���������� ���������, ������������ ���������...", 0xEE4848)
				reloadScripts()
				showCursor(false)
			end
		end)
	end
end
function funCMD.updateCheck()
	sampAddChatMessage("{FFFFFF}["..script_names.."]: ��������� ������� ����������...", 0xEE4848)
	local dir = dirml.."/MedicalHelper/update.json"
	local url = "https://raw.githubusercontent.com/Dev-Filatov/MedicalHelper/main/update.json"
	downloadUrlToFile(url, dir, function(id, status, p1, p2)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			lua_thread.create(function()
				wait(5000)
				if doesFileExist(dirml.."/MedicalHelper/update.json") then
					local f = io.open(dirml.."/MedicalHelper/update.json", "r")
					local upd = decodeJson(f:read("*a"))
					f:close()
					if type(upd) == "table" then
						newversion = upd.version
						if upd.version == scr.version then
							sampAddChatMessage("{FFFFFF}["..script_names.."]: �� �������, �� ����������� ����� ����� ������ �������.", 0xEE4848)
						else
							sampAddChatMessage("{FFFFFF}["..script_names.."]: {4EEB40}������� ����������.{FFFFFF} ������ {22E9E3}/update{FFFFFF} ��� �������.", 0xEE4848)
							wait(5000)
						end
					end
				end
			end)
		end
	end)
end

function hook.onServerMessage(mesColor, mes)
	if cb_chat2.v then
		if mes:find("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~") or mes:find("- �������� ������� �������: /menu /help /gps /settings") or mes:find("- �������� ����� � ������ ����� � ������� $250 000!") or mes:find("- ����� � ��������� �������������� ������� arizona-rp.com/donate") or mes:find("��������� �� ����������� �������") or mes:find("����� �������, ������ �����") then 
			return false
		end
	end
	if cb_chat3.v then
		if mes:find("News LS") or mes:find("News SF") or mes:find("News LV") then 
			return false
		end
	end
	if cb_chat1.v then
		if mes:find("����������:") or mes:find("�������������� ���������") then
		return false
		end
	end
	local function stringN(str, color)
		if str:len() > 72 then
			local str1 = str:sub(1, 70)
			local str2 = str:sub(71, str:len())
			return str1.."\n".."{"..color.."}"..str2
		else 
			return str
		end
	end
	if sobes.selID.v ~= "" and sobes.player.name ~= "" then
		if mes:find(sobes.player.name.."%[%d+%]%s�������:") then
			addOneOffSound(0, 0, 0, 1058)
			local mesLog = mes:match("{B7AFAF}%s(.+)")
			print(mesLog)
			local mesLog = stringN(mesLog, "B7AFAF")
		end
		if mes:find(sobes.player.name.."%[%d+%]%s%(%(") then
			local mesLog = mes:match("}(.+){")
			local mesLog = stringN(mesLog, "B7AFAF")
		end
		if mes:find(sobes.player.name.."%[%d+%]%s[%X%w]+") and mesColor == -6684673 then
			local mesLog = mes:match("%[%d+%]%s([%X%w]+)")
			local mesLog = stringN(mesLog, "F35373")
		end
		if mes:find("%-%s%|%s%s"..sobes.player.name.."%[%d+%]") then
			local mesLog = mes:match("([%X%w]+)%s%s%-%s%|%s%s"..sobes.player.name)
			local mesLog = stringN(mesLog, "2679FF")
		end
	end
end

function hook.onSendSpawn()
	_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	myNick = sampGetPlayerNickname(myid)
end

function chsex(textMan, textWoman)
	if num_sex.v then
		return textMan
	else
		return textWoman
	end
end

function GetPlayerDistance(id)
	result, ids = sampGetCharHandleBySampPlayerId(id)
	if result then
		local px, py, _ = getCharCoordinates(PLAYER_PED)
		local pxp, pyp, _ = getCharCoordinates(ids)
		local distance = getDistanceBetweenCoords2d(px, py, pxp, pyp)
		if distance <= 3 then
			return distance
		end
	end
end

function onWindowMessage(msg, wparam, lparam)
    if msg == 0x100 or msg == 0x101 then
        if (wparam == vkeys.VK_ESCAPE) then
			if(mainWin.v) and not isPauseMenuActive() then
				consumeWindowMessage(true, false)
				if msg == 0x101 then
					mainWin.v = false
				end
			end
		end
	end
end
