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
assert(res, "Библиотека SAMP Event не найдена")

local res, imgui = pcall(require, "imgui")
assert(res, "Библиотека Imgui не найдена")

local res, fa = pcall(require, 'faIcons')
assert(res, "Библиотека faIcons не найдена")

local res, rkeys = pcall(require, 'rkeys')
assert(res, "Библиотека Rkeys не найдена")

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
chgName.org 		= {u8"Больница ЛС", u8"Больница СФ", u8"Больница ЛВ"}
chgName.rank 		= {u8"Санитар", u8"Интерн", u8"Терапевт", u8"Нарколог", u8"Стоматолог", u8"Психиатр", u8"Хирург", u8"Завед. отделением", u8"Зам.Гл.Врача", u8"Глав.Врач"}

local list_org_BL 	= {"Больница LS", "Больница SF", "Больница LV"} 
local list_org		= {u8"Больница ЛС", u8"Больница СФ", u8"Больница ЛВ"}
local list_org_en 	= {"Los-Santos Medical Center", "San-Fierro Medical Center", "Las-Venturas Medical Center"}
local list_sex		= {fa.ICON_MALE .. u8" Мужской", fa.ICON_FEMALE .. u8" Женский"}
local list_rank		= {u8"Санитар", u8"Интерн", u8"Терапевт", u8"Нарколог", u8"Стоматолог", u8"Психиатр", u8"Хирург", u8"Завед. отделением", u8"Зам.Гл.Врача", u8"Глав.Врач"}

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
		return u8"Не указаны"
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
[name]=Выдача мед.карты
[1]=Полностью здоровый
Отыгровка №1
Отыгровка №2
[2]=Имеются отклонения 
Отыгровка №1
Отыгровка №2
{dialogEnd}
]]
helpd.key = {
	{k = "MBUTTON", n = 'Кнопка мыши'},
	{k = "XBUTTON1", n = 'Боковая кнопка мыши 1'},
	{k = "XBUTTON2", n = 'Боковая кнопка мыши 2'},
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
	{k = "LEFT", n = 'Стрелка влево'},
	{k = "UP", n = 'Стрелка вверх'},
	{k = "RIGHT", n = 'Стрелка вправо'},
	{k = "DOWN", n = 'Стрелка вниз'},
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
	{k = "LSHIFT", n = 'Левый Shift'},
	{k = "RSHIFT", n = 'Правый Shift'},
	{k = "LCONTROL", n = 'Левый Ctrl'},
	{k = "RCONTROL", n = 'Правый Ctrl'},
	{k = "LMENU", n = 'Левый Alt'},
	{k = "RMENU", n = 'Правый Alt'},
	{k = "OEM_1", n = '; :'},
	{k = "OEM_PLUS", n = '= +'},
	{k = "OEM_MINUS", n = '- _'},
	{k = "OEM_COMMA", n = ', <'},
	{k = "OEM_PERIOD", n = '. >'},
	{k = "OEM_2", n = '/ ?'},
	{k = "OEM_4", n = ' { '},
	{k = "OEM_6", n = ' } '},
	{k = "OEM_5", n = '\\ |'},
	{k = "OEM_8", n = '! §'},
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

local week = {"Воскресенье", "Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота"}
local month = {"Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"}
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
		desc = "Главное меню скрипта",
		rank = 1
	},
	[2] = {
		cmd = "/r",
		key = {},
		desc = "Команда для вызова рации с тегом (если прописан)",
		rank = 1
	},
	[3] = {
		cmd = "/rb",
		key = {},
		desc = "Команда для написания НонРп сообщения в рацию. ",
		rank = 1
	},
	[4] = {
		cmd = "/mb",
		key = {},
		desc = "Сокращённая команда /members",
		rank = 1
	},
	[5] = {
		cmd = "/hl",
		key = {},
		desc = "Лечение с автоматической РП отыгровкой",
		rank = 1
	},
	[6] = {
		cmd = "/ts",
		key = {},
		desc = "Быстрый скриншот с автоматическим вводом /time",
		rank = 1
	},
	[7] = {
		cmd = "/exp",
		key = {},
		desc = "Исключение игрока из помещения больницы",
		rank = 1
	},
	[8] = {
		cmd = "/osm",
		key = {},
		desc = "Произвести медицинский осмотр",
		rank = 1
	},
	[9] = {
		cmd = "/cur",
		key = {},
		desc = "Поднять человека без создание",
		rank = 1
	},
	[10] = {
		cmd = "/mc",
		key = {},
		desc = "Выдача или обновление мед.карты",
		rank = 3
	},
	[11] = {
		cmd = "/vc",
		key = {},
		desc = "Установить вакцину",
		rank = 3
	},
	[12] = {
		cmd = "/narko",
		key = {},
		desc = "Лечение от наркозависимости",
		rank = 4
	},
	[13] = {
		cmd = "/rec",
		key = {},
		desc = "Выдача рецептов",
		rank = 4
	},
	[14] = {
		cmd = "/antb",
		key = {},
		desc = "Выдача антибиотиков",
		rank = 4
	},
	[15] = {
		cmd = "/minsur",
		key = {},
		desc = "Выписка страховки",
		rank = 4
	},
	[16] = {
		cmd = "/tatu",
		key = {},
		desc = "Удаление татуировки",
		rank = 7
	},
	[17] = {
		cmd = "/sob",
		key = {},
		desc = "Меню собеседования с человеком",
		rank = 8
	},
	[18] = {
		cmd = "/+warn",
		key = {},
		desc = "Выдача выговора сотруднику",
		rank = 8
	},
	[19] = {
		cmd = "/-warn",
		key = {},
		desc = "Снять выговор сотруднику",
		rank = 8
	},
	[20] = {
		cmd = "/+mute",
		key = {},
		desc = "Выдать мут сотруднику",
		rank = 8
	},
	[21] = {
		cmd = "/-mute",
		key = {},
		desc = "Снять мут сотруднику",
		rank = 8
	},
	[22] = {
		cmd = "/gr",
		key = {},
		desc = "Изменить ранг (должность) сотруднику",
		rank = 9
	},
	[23] = {
		cmd = "/inv",
		key = {},
		desc = "Принять в организацию игрока",
		rank = 9
	},
	[24] = {
		cmd = "/unv",
		key = {},
		desc = "Уволить сотрудника из организации",
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
		print("{FF2525}Ошибка: {FFD825}Отсутствует изображение logo-medicalhelper.png");
		download_id = downloadUrlToFile('https://github.com/Dev-Filatov/MedicalHelper/blob/main/logo-medicalhelper.png?raw=true', 'moonloader/MedicalHelper/logo-medicalhelper.png', function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				print("{FF2525}Ошибка: {FFD825}Изображение загружено");
				logoMH = imgui.CreateTextureFromFile(dirml.."/MedicalHelper/logo-medicalhelper.png")
			end
		end)
	else
		logoMH = imgui.CreateTextureFromFile(dirml.."/MedicalHelper/logo-medicalhelper.png")
	end
	if not doesDirectoryExist(dirml.."/MedicalHelper/Binder/") then
		print("{F54A4A}Ошибка. Отсутствует папка. {82E28C}Создание папки для биндера.")
		createDirectory(dirml.."/MedicalHelper/Binder/")
	end
	if not doesDirectoryExist(dirml.."/MedicalHelper/Шпаргалки/") then
		print("{F54A4A}Ошибка. Отсутствует папка. {82E28C}Создание папки для шпор")
		createDirectory(dirml.."/MedicalHelper/Шпаргалки/")
	end
	if doesFileExist(dirml.."/MedicalHelper/MainSetting.json") then
	print("{82E28C}Чтение настроек...")
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
			print("{F54A4A}Ошибка. Файл настроек повреждён.")
			print("{82E28C}Создание новых собственных настроек...")
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
		print("{F54A4A}Ошибка. Файл настроек не найден.")
		print("{82E28C}Создание собственных настроек...")
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
	print("{82E28C}Чтение настроек команд...")
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
			print("{F54A4A}Ошибка. Файл настроек команд повреждён.")
			print("{82E28C}Применины стандартные настройки")
			os.remove(dirml.."/MedicalHelper/cmdSetting.json")
		end
	else
		print("{F54A4A}Ошибка. Файл настроек команд не найден.")
		print("{82E28C}Применины стандартные настройки")
	end
	print("{82E28C}Чтение настроек биндера...")
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
			print("{F54A4A}Ошибка. Файл настроек биндера повреждён.")
			print("{82E28C}Применины стандартные настройки")
		end
	else 
		print("{F54A4A}Ошибка. Файл настроек биндера не найден.")
		print("{82E28C}Применины стандартные настройки")
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
			sampAddChatMessage("{FFFFFF}["..script_names.."]: Данная команда Вам недоступна. Поменяйте должность в настройках скрипта, если это требуется.", 0xEE4848)
			return
		end
		if Vaccine[3] ~= -1 then
			sampAddChatMessage("{FFFFFF}["..script_names.."]: Вы отменили сеанс вакцинирование с "..tostring(sampGetPlayerNickname(Vaccine[3]):gsub("_", " ")).."", 0xEE4848)
			Vaccine = {0, 0, -1}
		else
			sampAddChatMessage("{FFFFFF}["..script_names.."]: Вы ещё не начинали сеанс", 0xEE4848)
		end
	end)
	sampRegisterChatCommand("mh", function()
		if sobWin.v then
			sampAddChatMessage("{FFFFFF}["..script_names.."]: Закройте первее меню собеседование главное меню, потом открывайте главное меню.", 0xEE4848)
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
			sampAddChatMessage("{FFFFFF}["..script_names.."]: Данная команда Вам недоступна. Поменяйте должность в настройках скрипта, если это требуется.", 0xEE4848)
			return
		end
		if mainWin.v then
			sampAddChatMessage("{FFFFFF}["..script_names.."]: Закройте первее главное меню, потом открывайте меню собеседование.", 0xEE4848)
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
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Вы успешно удалили скрипт.", 0xEE4848)
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Выгрузка скрипта из игры...", 0xEE4848)
		os.remove(scr.path)
		showCursor(false);
		scr:reload()
	end)

	sampAddChatMessage("{FFFFFF}["..script_names.."]: Скрипт инициализирован.", 0xEE4848)
	repeat wait(100) until sampIsLocalPlayerSpawned()
	resNickName, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	if resNickName then
		myNick = sampGetPlayerNickname(myid)
	end
	sampAddChatMessage(string.format("{FFFFFF}["..script_names.."]: Приветствую, %s. Для активации главного меню пропишите в чат {22E9E3}/mh.", tostring(u8:decode(buf_nick.v))), 0xEE4848)
	wait(200)
	if buf_nick.v == "" then 
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Похоже у тебя не настроена основная информация. ", 0xEE4848)
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Зайди в главном меню в раздел \"Настройки\" и настрой себе всё по \"фэн-шую\".", 0xEE4848)
	end
	lua_thread.create(funCMD.updateCheck)
	while true do
		wait(0)
		if isKeyDown(VK_LMENU) and isKeyJustPressed(VK_K) and not sampIsChatInputActive() then
			mainWin.v = not mainWin.v 
		end
		if thread:status() ~= "dead" and not isGamePaused() then 
			renderFontDrawText(font, "Отыгровка: [{F25D33} Page Down {FFFFFF}] - Приостановить", 20, sy-30, 0xFFFFFFFF)
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
	if imgui.InputText(u8"Имя и Фамилия: ", buf_nick, imgui.InputTextFlags.CallbackCharFilter, filter(1, "[а-Я%s]+")) then
		needSave = true
	end
		if not imgui.IsItemActive() and buf_nick.v == "" then
			imgui.SameLine()
			ShowHelpMarker(u8"Имя и Фамилия заполняется на \nрусском без нижнего подчёркивания.\n\n  Пример: Кевин Хатико")
			imgui.SameLine()
			imgui.SetCursorPosX(30)
			imgui.TextColored(imgui.ImColor(200, 200, 200, 200):GetVec4(), u8"Введите Ваше Имя и Фамилию");
		else
		imgui.SameLine()
		ShowHelpMarker(u8"Имя и Фамилия заполняется на \nрусском без нижнего подчёркивания.\n\n  Пример: Кевин Хатико")
	end
	if imgui.InputText(u8"Тег в рацию ", buf_teg) then
		needSave = true
	end
	imgui.SameLine();
	ShowHelpMarker(u8"Тег для рации может быть необязательным,\n уточните у других сотрудников или Лидера.\n\nПример: [Ваш Тег]")
	imgui.PushItemWidth(278);
	imgui.PushStyleVar(imgui.StyleVar.FramePadding, imgui.ImVec2(1, 3))
		if imgui.Button(fa.ICON_COG.."##1", imgui.ImVec2(21,20)) then
			chgName.inp.v = chgName.org[num_org.v+1]
			imgui.OpenPopup(u8"MH | Изменение названия больницы")
		end
	imgui.PopStyleVar(1)
	imgui.SameLine(22)
	if imgui.Combo(u8"Организация ", num_org, chgName.org) then
		needSave = true
	end
	imgui.PushStyleVar(imgui.StyleVar.FramePadding, imgui.ImVec2(1, 3))
		if imgui.Button(fa.ICON_COG.."##2", imgui.ImVec2(21,20)) then
			chgName.inp.v = chgName.rank[num_rank.v+1]
			imgui.OpenPopup(u8"MH | Изменение названия должности")
		end
	imgui.PopStyleVar(1)
	imgui.SameLine(22)
	if imgui.Combo(u8"Должность ", num_rank, chgName.rank) then
		needSave = true
	end
	imgui.PopItemWidth()						
	if imgui.Combo(u8"Ваш пол ", num_sex, list_sex) then
		needSave = true
	end
	imgui.PopItemWidth()
	imgui.EndGroup()
	if imgui.BeginPopupModal(u8"MH | Изменение названия больницы", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
		imgui.Text(u8"Название больницы будет применено к текущему названию")
		imgui.PushItemWidth(390)
		imgui.InputText(u8"##inpcastname", chgName.inp, 512, filter(1, "[%s%a%-]+"))
		imgui.PopItemWidth()
		if imgui.Button(u8"Сохранить", imgui.ImVec2(126, 23)) then
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
		if imgui.Button(u8"Сбросить", imgui.ImVec2(128,23)) then
			chgName.org[num_org.v+1] = list_org[num_org.v+1]
			needSave = true
			imgui.CloseCurrentPopup()
		end
		imgui.SameLine()
		if imgui.Button(u8"Отмена", imgui.ImVec2(126,23)) then
			imgui.CloseCurrentPopup()
		end
		imgui.EndPopup()
	end
	if imgui.BeginPopupModal(u8"MH | Изменение названия должности", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
		imgui.Text(u8"Название должности будет применено к текущему названию")
		imgui.PushItemWidth(200)
		imgui.InputText(u8"##inpcastname", chgName.inp, 512, filter(1, "[%s%a%-]+"))
		imgui.PopItemWidth()
		if imgui.Button(u8"Сохранить", imgui.ImVec2(126, 23)) then
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
		if imgui.Button(u8"Сбросить", imgui.ImVec2(128,23)) then
			chgName.rank[num_rank.v+1] = list_rank[num_rank.v+1]
			needSave = true
			imgui.CloseCurrentPopup()
		end
		imgui.SameLine()
		if imgui.Button(u8"Отмена", imgui.ImVec2(126,23)) then
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
		if ButtonMenu(fa.ICON_USERS .. u8"  Главное", select_menu[1]) then
			select_menu = {true, false, false, false, false, false, false};
		end
		imgui.Spacing()
		imgui.Separator()
		imgui.Spacing()
		if ButtonMenu(fa.ICON_WRENCH .. u8"  Настройки", select_menu[2]) then
			select_menu = {false, true, false, false, false, false, false}
		end
		imgui.Spacing()
		imgui.Separator()
		imgui.Spacing()
		if ButtonMenu(fa.ICON_FOLDER_OPEN .. u8"  Устав", select_menu[7]) then
			select_menu = {false, false, false, false, false, false, true}
		end
		imgui.Spacing()
		imgui.Separator()
		imgui.Spacing()
		if ButtonMenu(fa.ICON_FILE .. u8"  Шпоры", select_menu[3]) then 
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
		if ButtonMenu(fa.ICON_TERMINAL .. u8"  Команды", select_menu[4]) then
			select_menu = {false, false, false, true , false, false, false}
		end	
		imgui.Spacing()
		imgui.Separator()
		imgui.Spacing()
		if ButtonMenu(fa.ICON_KEYBOARD_O .. u8"  Биндер", select_menu[5]) then
			select_menu = {false, false, false, false, true, false, false}
		end
		imgui.Spacing()
		imgui.Separator()
		imgui.Spacing()
		if ButtonMenu(fa.ICON_CODE .. u8"  О скрипте", select_menu[6]) then
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
			imgui.Text(u8"Информаия о сотруднике");
			imgui.Dummy(imgui.ImVec2(0, 25))
			imgui.Indent(10)

			imgui.Text(fa.ICON_ADDRESS_CARD .. u8"  Имя Фамилия сотрудника: ");
			imgui.SameLine();
			imgui.TextColored(colorInfo, PlayerSet.name())
			imgui.Dummy(imgui.ImVec2(0, 5))

			imgui.Text(fa.ICON_HOSPITAL_O .. u8"  Состоит в организации: ");
			imgui.SameLine();
			imgui.TextColored(colorInfo, PlayerSet.org());
			imgui.Dummy(imgui.ImVec2(0, 5))

			imgui.Text(fa.ICON_USER .. u8"  Должность: ");
			imgui.SameLine();
			imgui.TextColored(colorInfo, PlayerSet.rank());
			imgui.Dummy(imgui.ImVec2(0, 5))

			imgui.Text(fa.ICON_TRANSGENDER .. u8"  Пол: ");
			imgui.SameLine();
			imgui.TextColored(colorInfo, PlayerSet.sex())
			imgui.EndGroup()
		end
		if select_menu[7] then
			imgui.SameLine()
			imgui.BeginGroup()
			imgui.BeginChild("ustav", imgui.ImVec2(0, 412), true)
			imgui.Text(fa.ICON_ANGLE_RIGHT .. u8" Устав Министерства Здравоохранения");
			imgui.Separator()
			imgui.Dummy(imgui.ImVec2(0, 3))
			if imgui.CollapsingHeader(u8"Глава 1 - Общие положения") then
				imgui.Spacing()
				imgui.TextWrapped(u8"1.1. Статьи, изложенные в Уставе, являются обязательными к исполнению.")
				if imgui.IsItemClicked(0) then
					setClipboardText("1.1. Статьи, изложенные в Уставе, являются обязательными к исполнению.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"1.2. За нарушение статей и правил, изложенных в уставе, нарушители обязаны быть наказаны.")
				if imgui.IsItemClicked(0) then
					setClipboardText("1.2. За нарушение статей и правил, изложенных в уставе, нарушители обязаны быть наказаны.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"1.3. Работа сотрудника Министерства Здравоохранения основывается на постоянной ответственностью за здоровье и жизнь других людей, ежедневном контакте с различными человеческими характерами, необходимости правильного и срочного принятия решений, самодисциплине.")
				if imgui.IsItemClicked(0) then
					setClipboardText("1.3. Работа сотрудника Министерства Здравоохранения основывается на постоянной ответственностью за здоровье и жизнь других людей, ежедневном контакте с различными человеческими характерами, необходимости правильного и срочного принятия решений, самодисциплине.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"1.4. Моральным кодексом для сотрудника Министерства Здравоохранения является Клятва Гиппократа.")
				if imgui.IsItemClicked(0) then
					setClipboardText("1.4. Моральным кодексом для сотрудника Министерства Здравоохранения является Клятва Гиппократа.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"1.5. Нарушение клятвы Гиппократа может быть причиной серьезного наказания для нарушителя, на усмотрение начальства.")
				if imgui.IsItemClicked(0) then
					setClipboardText("1.5. Нарушение клятвы Гиппократа может быть причиной серьезного наказания для нарушителя, на усмотрение начальства.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"1.7. Электронное заявление по трудоустройству в учреждения Здравоохранения, может быть отклонено по следующим причинам: ")
				if imgui.IsItemClicked(0) then
					setClipboardText("1.7. Электронное заявление по трудоустройству в учреждения Здравоохранения, может быть отклонено по следующим причинам: ")
				end
				imgui.Spacing()
				imgui.Bullet()
				imgui.TextColoredRGB("{f7cc46}Низкая законопослушность гражданина?")
				imgui.Bullet()
				imgui.TextColoredRGB("{f7cc46}Проживание в Штате менее 5 лет?")
				imgui.Bullet()
				imgui.TextColoredRGB("{f7cc46}Наличие отклонений в мед. карте (Наркозависимость, лечение в специализированных диспансерах")
				imgui.Bullet()
				imgui.TextColoredRGB("{f7cc46}Вы находитесь в Черном Списке Гос.Структур или Министерства?")
				imgui.Bullet()
				imgui.TextColoredRGB("{f7cc46}Невыполнение минимум 1 критерия по трудоустройству?")
				imgui.Bullet()
				imgui.TextColoredRGB("{f7cc46}По решению Глав.Врача/Министра/Федерального правительства.")
				imgui.Spacing()
				imgui.TextColoredRGB("1.8 За многократное или грубое нарушение устава вы можете быть занесены в чёрный список.")
				if imgui.IsItemClicked(0) then
					setClipboardText("1.8 За многократное или грубое нарушение устава вы можете быть занесены в чёрный список.")
				end
			end
			imgui.Dummy(imgui.ImVec2(0, 5)) 
			if imgui.CollapsingHeader(u8"Глава 2 - Дисциплина") then
				imgui.Spacing()
				imgui.TextWrapped(u8"2.1. Общение между сотрудниками Министерства Здравоохранения, независимо от должности сотрудника, происходит на уважительных тонах, соблюдая элементарные правила субординации.")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.1. Общение между сотрудниками Министерства Здравоохранения, независимо от должности сотрудника, происходит на уважительных тонах, соблюдая элементарные правила субординации.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"2.1.1. В общении между сотрудниками Министерства Здравоохранения и гражданами штата строго запрещается нецензурная лексика, унижения, оскорбления и т.д., т.п.")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.1.1. В общении между сотрудниками Министерства Здравоохранения и гражданами штата строго запрещается нецензурная лексика, унижения, оскорбления и т.д., т.п.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"2.1.1.2. Запрещено нарушать Иерархию мед.центра, игнорировать указания старшего состава мед.центра сотрудниками младшего состава, а также руководства Министерства Здравоохранения")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.1.1.2. Запрещено нарушать Иерархию мед.центра, игнорировать указания старшего состава мед.центра сотрудниками младшего состава, а также руководства Министерства Здравоохранения")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"2.1.1.2. При отсутствии в Штате сотрудников руководящего состава мед.центра, временная ответственность за руководство мед.центром находится у сотрудника 8 порядковой должности")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.1.1.2. При отсутствии в Штате сотрудников руководящего состава мед.центра, временная ответственность за руководство мед.центром находится у сотрудника 8 порядковой должности")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"2.2. Запрещено нарушать законы штата, а также законы Федерального правительства (Правила сервера)")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.2. Запрещено нарушать законы штата, а также законы Федерального правительства (Правила сервера)")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"2.3. Сотруднику Министерства Здравоохранения запрещено употреблять алкогольные и табачные изделия в учреждениях Здравоохранения, а также близлежащих территориях.")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.3. Сотруднику Министерства Здравоохранения запрещено употреблять алкогольные и табачные изделия в учреждениях Здравоохранения, а также близлежащих территориях.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"2.4. Выполнение всех без исключений требований/поручений старшего состава и руководства")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.4. Выполнение всех без исключений требований/поручений старшего состава и руководства")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"2.4.1. Если сотрудник Министерства Здравоохранения получил заведомо преступное указание, оно должно быть отклонено, после чего , получивший приказ должен записать доказательства и отправить их на рассмотрение Министру.")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.4.1. Если сотрудник Министерства Здравоохранения получил заведомо преступное указание, оно должно быть отклонено, после чего , получивший приказ должен записать доказательства и отправить их на рассмотрение Министру.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("2.5. Запрещено нарушать установленные нормы отдыха [АФК]. За нарушение данного пункта сотрудник\nполучит {FF0000}[выговор]{FFFFFF}")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.5. Запрещено нарушать установленные нормы отдыха [АФК]. За нарушение данного пункта сотрудник получит [выговор].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"2.6. Запрещено вводить в заблуждение руководство/коллег [Лгать о присутствии в Мед.Центре/вызове]")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.6. Запрещено вводить в заблуждение руководство/коллег [Лгать о присутствии в Мед.Центре/вызове]")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"2.7. Запрещено создавать помеху для прохода/проезда парковкой своего личного транспорта.")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.7. Запрещено создавать помеху для прохода/проезда парковкой своего личного транспорта.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"2.8. Медицинскому работнику категорически запрещено хранить/употреблять наркотические вещества, сотрудника увольняют независимо от его должности.")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.8. Медицинскому работнику категорически запрещено хранить/употреблять наркотические вещества, сотрудника увольняют независимо от его должности.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("2.9. Сотрудник Министерства Здравоохранения обязан сохранять здравый ум в любое время суток\nпри любой ситуации.Запрещено проявлять неадекватность в поведении в любом виде. [МГ, нонРП]\nЗа это сотрудник получит {FF0000}[выговор]{FFFFFF}, за более жесткое поведение - увольнение.")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.9. Сотрудник Министерства Здравоохранения обязан сохранять здравый ум в любое время суток при любой ситуации. Запрещено проявлять неадекватность в поведении в любом виде. [МГ, нонРП] За это сотрудник получит [выговор], за более жесткое поведение - увольнение.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"2.10. Запрещено подделывать документы в целях собственной выгоды, фальсификации фактов и действительности. [Отчёт, премия и.т.п] За нарушение данного пункта сотрудник увольнение.")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.10. Запрещено подделывать документы в целях собственной выгоды, фальсификации фактов и действительности. [Отчёт, премия и.т.п] За нарушение данного пункта сотрудник увольнение.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"2.11. Медицинскому работнику строго запрещено передвигаться с периодическими прыжками для более быстрого передвижения.")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.11. Медицинскому работнику строго запрещено передвигаться с периодическими прыжками для более быстрого передвижения.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("2.11.1. Запрещено бегать/прыгать/танцевать в Мед.Центре. Исключение: бегать можно в том\nслучае если идёт очень важная операция где каждая секунда важна. За нарушение данного\nпункта сотрудник получит {f7cc46}[предупреждение]{FFFFFF}, многократно нарушение данного пункта - {FF0000}[выговор]{FFFFFF}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.11.1. Запрещено бегать/прыгать/танцевать в Мед.Центре. Исключение: бегать можно в том случае если идёт очень важная операция где каждая секунда важна. За нарушение данного пункта сотрудник получит [предупреждение], многократно нарушение данного пункта - [выговор].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("2.12 Максимальное количество выдачи рецептов: не более 5 рецептов в час. (Для одного пациента).\nЗа нарушение данного пункта, сотрудник получит {f7cc46}[предупреждение]{FFFFFF}, многократное нарушение\nданного пункта - {FF0000}[Выговор/Увольнение]{FFFFFF}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.12 Максимальное количество выдачи рецептов: не более 5 рецептов в час. (Для одного пациента). За нарушение данного пункта, сотрудник получит [предупреждение], многократное нарушение данного пункта - [Выговор/Увольнение].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("2.13. Запрещено выгонять людей из Мед.Центра, к которым присутствует личная неприязнь.\nЗа это сотрудник получит {FF0000}[выговор]{FFFFFF}, за более жесткое - увольнение.")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.13. Запрещено выгонять людей из Мед.Центра, к которым присутствует личная неприязнь. За это сотрудник получит [выговор], за более жесткое - увольнение.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("2.14. Запрещено ношение бронежилета в здании Мед.Центра. За нарушение данного пункта сотрудник\nполучит {FF0000}[выговор]{FFFFFF}. [Исключение ЧС-ТЕРРАКТ]")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.14. Запрещено ношение бронежилета в здании Мед.Центра. За нарушение данного пункта сотрудник получит [выговор]. [Исключение ЧС-ТЕРРАКТ]")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("2.15. Сотруднику запрещено заходить без разрешения в кабинет Главного врача,\nза нарушение - {FF0000}[выговор]{FFFFFF}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.15. Сотруднику запрещено заходить без разрешения в кабинет Главного врача, за нарушение - [выговор].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"2.16. Сотрудник Министерства Здравоохранения обязан общаться с гражданами штата строго на Вы")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.16. Сотрудник Министерства Здравоохранения обязан общаться с гражданами штата строго на Вы")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"2.17. Запрещено использование любого вида оружия. (Пример: огнестрельное оружие, холодное оружие)")
				if imgui.IsItemClicked(0) then
					setClipboardText("2.17. Запрещено использование любого вида оружия. (Пример: огнестрельное оружие, холодное оружие)")
				end
			end
			imgui.Dummy(imgui.ImVec2(0, 5)) 
			if imgui.CollapsingHeader(u8"Глава 3. - Оказание медицинской помощи больным людям") then
				imgui.Spacing()
				imgui.TextColoredRGB("3.1. Запрещено повышать цены на лечение,мед.карты/рецепты/сеансы. Занижать цены разрешается.\nЗа нарушение данного пункта сотрудник получит {FF0000}[выговор]{FFFFFF}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("3.1. Запрещено повышать цены на лечение,мед.карты/рецепты/сеансы. Занижать цены разрешается.\nЗа нарушение данного пункта сотрудник получит [выговор].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"3.2. Медицинский работник обязан оказать медицинскую помощь нуждающемуся в ней, независимо от его положения в обществе, материального положения, расовой/религиозной/политической принадлежности.")
				if imgui.IsItemClicked(0) then
					setClipboardText("3.2. Медицинский работник обязан оказать медицинскую помощь нуждающемуся в ней, независимо от его положения в обществе, материального положения, расовой/религиозной/политической принадлежности.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("3.4. Категорически запрещено лечить без определения диагноза и выписки рецепта и препаратов\n[Категорически запрещено лечить без отыгровки РП] За нарушение данного пункта сотрудник\nполучит {FF0000}[выговор]{FFFFFF}, за более жесткое нарушение данного пункта - {FF0000}увольнение{FFFFFF}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("3.4. Категорически запрещено лечить без определения диагноза и выписки рецепта и препаратов [Категорически запрещено лечить без отыгровки РП] За нарушение данного пункта сотрудник получит [выговор], за более жесткое нарушение данного пункта - увольнение.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"3.5. Сотрудник Министерства Здравоохранения имеет право выезжать на вызов начиная с 3 порядковой должности в мед.центре, выезд на территории контроля банд должен осуществляться вдвоем.")
				if imgui.IsItemClicked(0) then
					setClipboardText("3.5. Сотрудник Министерства Здравоохранения имеет право выезжать на вызов начиная с 3 порядковой должности в мед.центре, выезд на территории контроля банд должен осуществляться вдвоем.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("3.5.1. В случае, если сотрудник принял вызов, и не приехал на него - он получит {FF0000}[выговор]{FFFFFF}.\nЕсли ситуация по которой он не приехал будет не серьезной - сотрудник будет оправдан.")
				if imgui.IsItemClicked(0) then
					setClipboardText("3.5.1. В случае, если сотрудник принял вызов, и не приехал на него - он получит [выговор]. Если ситуация по которой он не приехал будет не серьезной - сотрудник будет оправдан.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"3.6. Сотрудник Министерства Здравоохранения, обязавшийся провести операцию и имеющий 7 порядковую должность в мед.центрах Штата, обязан взять с собой сотрудника ниже его по должности для оказания помощи и получения опыта в качестве операционного медицинского брата или медицинской сестры")
				if imgui.IsItemClicked(0) then
					setClipboardText("3.6. Сотрудник Министерства Здравоохранения, обязавшийся провести операцию и имеющий 7 порядковую должность в мед.центрах Штата, обязан взять с собой сотрудника ниже его по должности для оказания помощи и получения опыта в качестве операционного медицинского брата или медицинской сестры")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"3.6.1. В обязанности младшего будет входить безукоризненное, точное выполнение инструкций старшего и помощь ему на операции")
				if imgui.IsItemClicked(0) then
					setClipboardText("3.6.1. В обязанности младшего будет входить безукоризненное, точное выполнение инструкций старшего и помощь ему на операции")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"3.7. Категорически запрещено проводить операции, не определив вид травмы.")
				if imgui.IsItemClicked(0) then
					setClipboardText("3.7. Категорически запрещено проводить операции, не определив вид травмы.")
				end
				imgui.TextColoredRGB("{f7cc46}[Категорически запрещено проводить операции с Биндером/АХК. Строго от руки!]")
			end
			imgui.Dummy(imgui.ImVec2(0, 5)) 
			if imgui.CollapsingHeader(u8"Глава 4. - Специализированный транспорт") then
				imgui.Spacing()
				imgui.TextColoredRGB("4.1. Транспорт разрешено брать исключительно в рабочих целях. За нарушение данного правил\nсотрудник получит - {FF0000}[выговор]{FFFFFF}")
				if imgui.IsItemClicked(0) then
					setClipboardText("4.1. Транспорт разрешено брать исключительно в рабочих целях. За нарушение данного правил сотрудник получит - [выговор]")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"4.2. Сотрудник при патрулировании города, находящийся не на вызове обязан соблюдать ПДД.")
				if imgui.IsItemClicked(0) then
					setClipboardText("4.2. Сотрудник при патрулировании города, находящийся не на вызове обязан соблюдать ПДД.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"4.2.1. Ответственность за транспорт при возникновения случаев ДТП, когда выезжаете либо возвращаетесь с вызова лежит на сотруднике, который управлял каретой.")
				if imgui.IsItemClicked(0) then
					setClipboardText("4.2.1. Ответственность за транспорт при возникновения случаев ДТП, когда выезжаете либо возвращаетесь с вызова лежит на сотруднике, который управлял каретой.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"4.2.2. Категорически запрещена стоянка посреди проезжей части.")
				if imgui.IsItemClicked(0) then
					setClipboardText("4.2.2. Категорически запрещена стоянка посреди проезжей части.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"4.3. Каждая карета оснащена спец. сигналами. По правилам ПДД каждый гражданский обязан способствовать передвижению сотрудников Мин. Здравоохранения при включенных спец. сигналах, а именно уступить им дорогу на вызов.")
				if imgui.IsItemClicked(0) then
					setClipboardText("4.3. Каждая карета оснащена спец. сигналами. По правилам ПДД каждый гражданский обязан способствовать передвижению сотрудников Мин. Здравоохранения при включенных спец. сигналах, а именно уступить им дорогу на вызов.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"4.3.1. Задействовать спец.сигналы водитель может только если он спешит на вызов, либо везет пациента в Мед.Центр.")
				if imgui.IsItemClicked(0) then
					setClipboardText("4.3.1. Задействовать спец.сигналы водитель может только если он спешит на вызов, либо везет пациента в Мед.Центр.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"4.3.2. Использование спец.сигналов в личных и других целях запрещено.")
				if imgui.IsItemClicked(0) then
					setClipboardText("4.3.2. Использование спец.сигналов в личных и других целях запрещено.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"3.7. Категорически запрещено проводить операции, не определив вид травмы.")
				if imgui.IsItemClicked(0) then
					setClipboardText("3.7. Категорически запрещено проводить операции, не определив вид травмы.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("4.4. Категорически запрещено спать {f7cc46}[АФК]{FFFFFF} в карете посреди проезжей части.")
				if imgui.IsItemClicked(0) then
					setClipboardText("4.4. Категорически запрещено спать [АФК] в карете посреди проезжей части.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("4.5. Запрещено топить/взрывать транспорт. [Запрещено респавнить карету] За нарушение данного\nпункта сотрудник получит - {FF0000}[выговор]{FFFFFF}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("4.5. Запрещено топить/взрывать транспорт. [Запрещено респавнить карету] За нарушение данного пункта сотрудник получит - [выговор].")
				end
			end
			imgui.Dummy(imgui.ImVec2(0, 5)) 
			if imgui.CollapsingHeader(u8"Глава 5. - Понижения/Повышения/Выговоры/Увольнение") then
				imgui.Spacing()
				imgui.TextColoredRGB("5.1. Запрещено намекать на повышение [Каким-либо образом]. Выпрашивание повышения или намёки\nна прохождения экзамена для повышения, недопустимо. За нарушение данного пункта сотрудник\nполучит {FF0000}[выговор]{FFFFFF}, многократное нарушение данного пункта - {FF0000}[увольнение]{FFFFFF}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("5.1. Запрещено намекать на повышение [Каким-либо образом]. Выпрашивание повышения или намёки на прохождения экзамена для повышения, недопустимо. За нарушение данного пункта сотрудник получит [выговор], многократное нарушение данного пункта - [увольнение].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("5.2. Наличие 3 выговоров карается увольнением. Снять {FF0000}[выговор]{FFFFFF} можно через специальный раздел на\nоф.портале Штата ''Система снятия выговоров''")
				if imgui.IsItemClicked(0) then
					setClipboardText("5.2. Наличие 3 выговоров карается увольнением. Снять [выговор] можно через специальный раздел на оф.портале Штата ''Система снятия выговоров''")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"5.3. Медицинский работник может быть уволен за: жалобы, плохую работу, несоблюдение Устава МЗ/Клятвы Гиппократа,Закона об МЗ, низкий уровень квалификации, по решению руководства, а также по собственному желанию.")
				if imgui.IsItemClicked(0) then
					setClipboardText("5.3. Медицинский работник может быть уволен за: жалобы, плохую работу, несоблюдение Устава МЗ/Клятвы Гиппократа,Закона об МЗ, низкий уровень квалификации, по решению руководства, а также по собственному желанию.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("5.4. Если сотрудник увольняется с должности {f7cc46}'Интерн / (1 Ранг)'{FFFFFF}, то он заносится в Чёрный список того\nМед.Центра, с которого он уволился.")
				if imgui.IsItemClicked(0) then
					setClipboardText("5.4. Если сотрудник увольняется с должности 'Интерн / (1 Ранг)', то он заносится в Чёрный список того Мед.Центра, с которого он уволился.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"5.5. Запрещено выпрашивать и намекать на снятие выговора. За несоблюдение последует увольнение!")
				if imgui.IsItemClicked(0) then
					setClipboardText("5.5. Запрещено выпрашивать и намекать на снятие выговора. За несоблюдение последует увольнение!")
				end
				imgui.Spacing()
				imgui.TextColoredRGB("{f7cc46}[Правило действует на оба чата. За сообщение типа: ''сними {FF0000}[выговор]{f7cc46} in ic'' сотрудник получает\n{f7cc46}еще один выговор 'in ic']")
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"5.6. Медицинский работник старшего состава имеет право на повышение в должности только после оставленного отчёта.")
				if imgui.IsItemClicked(0) then
					setClipboardText("5.6. Медицинский работник старшего состава имеет право на повышение в должности только после оставленного отчёта.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("5.7. Медицинский работник, являющийся заместителем главного врача в праве выдавать {FF0000}[выговоры]{FFFFFF} или\nустные {f7cc46}[предупреждения]{FFFFFF} представителям старшего персонала Мед.Центра.")
				if imgui.IsItemClicked(0) then
					setClipboardText("5.7. Медицинский работник, являющийся заместителем главного врача в праве выдавать [выговоры] или устные [предупреждения] представителям старшего персонала Мед.Центра.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"5.8.Запрещён блат в любом его виде карается увольнением с занесением в чёрный список Министерства Здравоохранения.")
				if imgui.IsItemClicked(0) then
					setClipboardText("5.8.Запрещён блат в любом его виде карается увольнением с занесением в чёрный список Министерства Здравоохранения.")
				end
			end
			imgui.Dummy(imgui.ImVec2(0, 5)) 
			if imgui.CollapsingHeader(u8"Глава 6. - Отпуск") then
				imgui.Spacing()
				imgui.TextWrapped(u8"6.1. Заявление на отпуск можно подать один раз в 14 дней [отсчет дней начинается с момента выхода из отпуска].")
				if imgui.IsItemClicked(0) then
					setClipboardText("6.1. Заявление на отпуск можно подать один раз в 14 дней [отсчет дней начинается с момента выхода из отпуска].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("6.2. В отпуск можно уходить только с {f7cc46}5{FFFFFF}-ой должности.")
				if imgui.IsItemClicked(0) then
					setClipboardText("6.2. В отпуск можно уходить только с 5-ой должности.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"6.3. Максимальный срок отпуска составляет - 7 дней [Заместители/Лидеры, не могут брать отпуск, только неактив].")
				if imgui.IsItemClicked(0) then
					setClipboardText("6.3. Максимальный срок отпуска составляет - 7 дней [Заместители/Лидеры, не могут брать отпуск, только неактив].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"6.4. В отпуск можно уходить отработав 7 дней в Мед.Центре.")
				if imgui.IsItemClicked(0) then
					setClipboardText("6.4. В отпуск можно уходить отработав 7 дней в Мед.Центре.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("6.5. В отпуск допускается уходит сотрудникам, которые имеют не более 1 письменного {FF0000}[выговоры]{FFFFFF}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("6.5. В отпуск допускается уходит сотрудникам, которые имеют не более 1 письменного [выговора].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"6.6. Если по истечению отпуска, сотрудник не приступил к своим прямым обязанностям, его должность аннулируется и восстановление возможно, лишь на должность [Интерн / (1 Ранг)].")
				if imgui.IsItemClicked(0) then
					setClipboardText("6.6. Если по истечению отпуска, сотрудник не приступил к своим прямым обязанностям, его должность аннулируется и восстановление возможно, лишь на должность [Интерн / (1 Ранг)].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"6.7. Во время отпуска запрещается вступать в другие государственные и нелегальные организации.")
				if imgui.IsItemClicked(0) then
					setClipboardText("6.7. Во время отпуска запрещается вступать в другие государственные и нелегальные организации.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"6.8. В отпуск можно уйти только по заявлению и только при наличии на заявлении одобрения Управляющего Мед.Центром вашего города.")
				if imgui.IsItemClicked(0) then
					setClipboardText("6.8. В отпуск можно уйти только по заявлению и только при наличии на заявлении одобрения Управляющего Мед.Центром вашего города.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"6.8.1. Уходя в отпуск, мед.работник обязан сдать форму, рацию и бейджик на время отпуска [Уволиться, предварительно написав заявление на форуме, в специальном разделе].")
				if imgui.IsItemClicked(0) then
					setClipboardText("6.8.1. Уходя в отпуск, мед.работник обязан сдать форму, рацию и бейджик на время отпуска [Уволиться, предварительно написав заявление на форуме, в специальном разделе].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"6.9. В случае, если мед.работник возвращается в указанный срок, его должность восстанавливается.")
				if imgui.IsItemClicked(0) then
					setClipboardText("6.9. В случае, если мед.работник возвращается в указанный срок, его должность восстанавливается.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"6.10. В случае, если мед.работник не возвращается в указанный срок, его должность окончательно аннулируется.")
				if imgui.IsItemClicked(0) then
					setClipboardText("6.10. В случае, если мед.работник не возвращается в указанный срок, его должность окончательно аннулируется.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"6.11. В заявлении на отпуск обязательно нужно указать дату начала отпуска и дату конца. В противном случае, в отпуске будет отказано.")
				if imgui.IsItemClicked(0) then
					setClipboardText("6.11. В заявлении на отпуск обязательно нужно указать дату начала отпуска и дату конца. В противном случае, в отпуске будет отказано.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"6.12. Разрешено возвращаться из отпуска раньше указанного срока.")
				if imgui.IsItemClicked(0) then
					setClipboardText("6.12. Разрешено возвращаться из отпуска раньше указанного срока.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"6.13. По окончанию отпуска, вы должны связаться с глав.врачом своего Мед.Центра.")
				if imgui.IsItemClicked(0) then
					setClipboardText("6.13. По окончанию отпуска, вы должны связаться с глав.врачом своего Мед.Центра.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"6.14. Если сотрудник во время отпуска был наказан Федеральным правительством [warn/ban], то восстановлению не подлежит.")
				if imgui.IsItemClicked(0) then
					setClipboardText("6.14. Если сотрудник во время отпуска был наказан Федеральным правительством [warn/ban], то восстановлению не подлежит.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"6.15. В случае вашего выхода из отпуска, Главный врач имеет право понизить вас в должности, если есть на то основания.")
				if imgui.IsItemClicked(0) then
					setClipboardText("6.15. В случае вашего выхода из отпуска, Главный врач имеет право понизить вас в должности, если есть на то основания.")
				end
			end
			imgui.Dummy(imgui.ImVec2(0, 5)) 
			if imgui.CollapsingHeader(u8"Глава 7. - Общение по рации") then
				imgui.Spacing()
				imgui.TextColoredRGB("7.1. Запрещено кричать, материться или нести чушь в рацию сотрудников (/r), на первый раз у\nсотрудника отберут рацию, при повторных случаях {FF0000}[Выговор/Увольнение]{FFFFFF}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("7.1. Запрещено кричать, материться или нести чушь в рацию сотрудников (/r), на первый раз у сотрудника отберут рацию, при повторных случаях [Выговор/Увольнение].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("7.2. Запрещено говорить в общую волну [/d] без уважительной причины. За несоблюдение данного\nправила сотрудник получит {FF0000}[выговор]{FFFFFF}, при многократном нарушении сотрудник получит {FF0000}[увольнение]{FFFFFF}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("7.2. Запрещено говорить в общую волну [/d] без уважительной причины. За несоблюдение данного правила сотрудник получит [выговор], при многократном нарушении сотрудник получит [увольнение].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"7.3. Запрещено выяснять отношения в рации организации и общей рации.")
				if imgui.IsItemClicked(0) then
					setClipboardText("7.3. Запрещено выяснять отношения в рации организации и общей рации.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"7.5. Запрещено рекламировать любую вещь в рацию.")
				if imgui.IsItemClicked(0) then
					setClipboardText("6.15. В случае вашего выхода из отпуска, Главный врач имеет право понизить вас в должности, если есть на то основания.")
				end
				imgui.TextColoredRGB("{f7cc46}[Правило действует на оба чата. За сообщение по типу: 'Продам дом in ic' сотрудник получает {FF0000}[Выговор]{f7cc46}.")
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"7.6. Сотрудник всегда имеет право высказать своё мнение Гл. врачу или его заместителю по телефону или в личном кабинете, по не по рации, т.к это будут слышать все сотрудники Мед.Центра.")
				if imgui.IsItemClicked(0) then
					setClipboardText("7.6. Сотрудник всегда имеет право высказать своё мнение Гл. врачу или его заместителю по телефону или в личном кабинете, по не по рации, т.к это будут слышать все сотрудники Мед.Центра.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"7.7. В рации сотрудник обязан соблюдать субординацию.")
				if imgui.IsItemClicked(0) then
					setClipboardText("7.7. В рации сотрудник обязан соблюдать субординацию.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("7.7.1. За не соблюдения субординации к старшим, руководящему составу - сотрудник может\nполучит {FF0000}[Выговор]{ffffff}. Если кто-то общается не уважительно к вам, то вы вправе написать жалобу на этого\nигрока лидеру или заму, после чего игрок понесет наказание.")
				if imgui.IsItemClicked(0) then
					setClipboardText("7.7.1. За не соблюдения субординации к старшим, руководящему составу - сотрудник может получит [Выговор]. Если кто-то общается не уважительно к вам, то вы вправе написать жалобу на этого игрока лидеру или заму, после чего игрок понесет наказание.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("7.8.2. За брань, засорении эфира рации и прочее неадекватство - игрок на 1 раз получает\n[устное предупреждение], во 2 раз получает заглушку чата или {FF0000}[Выговор]{ffffff}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("7.8.2. За брань, засорении эфира рации и прочее неадекватство - игрок на 1 раз получает [устное предупреждение], во 2 раз получает заглушку чата или [Выговор].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("7.9. Запрещено проводить лекции в рацию более 1 раза в час (от всех сотрудников)\nЗа нарушенияданного пункта сотрудник получит {FF0000}[Выговор]{ffffff}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("7.9. Запрещено проводить лекции в рацию более 1 раза в час (от всех сотрудников) За нарушения данного пункта сотрудник получит [Выговор].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"7.9.1 Лекции проведение в рацию не могут быть приняты в отчете на повышение/снятие выговора.")
				if imgui.IsItemClicked(0) then
					setClipboardText("7.9.1 Лекции проведение в рацию не могут быть приняты в отчете на повышение/снятие выговора.")
				end
			end
			imgui.Dummy(imgui.ImVec2(0, 5)) 
			if imgui.CollapsingHeader(u8"Глава 8. - Рабочее время") then
				imgui.Spacing()
				imgui.TextColoredRGB("8.1. В рабочее время сотруднику запрещено участвовать [находится] на мероприятиях [Серверных и\nот администрации]. За нарушение {FF0000}[Выговор]{FFFFFF}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("8.1. В рабочее время сотруднику запрещено участвовать [находится] на мероприятиях [Серверных и от администрации]. За нарушение [Выговор].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("8.1.2. В рабочее время и не в рабочее время в форме сотруднику запрещено посещать\nЦентральный рынок, Центральный Банк, Автобазар,Автосалон,Казино. За нарушение {FF0000}[Выговор]{FFFFFF}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("8.1.2. В рабочее время и не в рабочее время в форме сотруднику запрещено посещать Центральный рынок, Центральный Банк, Автобазар,Автосалон,Казино. За нарушение [Выговор].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("8.1.3. За прогул в форме в любое время сотрудник будет уволен. С 4-ой должности и выше сотрудник\nполучает {FF0000}[Выговор]{FFFFFF}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("8.1.3. За прогул в форме в любое время сотрудник будет уволен. С 4-ой должности и выше сотрудник получает [Выговор].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"8.2. Рабочее время установлено графиком, указанным в Кодексе Министерства Здравоохранения.")
				if imgui.IsItemClicked(0) then
					setClipboardText("8.2. Рабочее время установлено графиком, указанным в Кодексе Министерства Здравоохранения.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"8.2.1. Рабочий график:")
				imgui.Spacing()
				imgui.TextColoredRGB("{f7cc46}Рабочий день:")
				imgui.TextColoredRGB("{f7cc46}» Понедельник - Пятница: 10:00 - 21:00")
				imgui.TextColoredRGB("{f7cc46}» Суббота - Воскресенье: 11:00 - 19:00")
				imgui.TextColoredRGB("{f7cc46}» Обеденный Перерыв: 13:00 - 14:00")
				imgui.TextColoredRGB("{f7cc46}» Вечерний Перерыв: 18:00 - 19:00 (Кроме Субботы и Воскресенья)")
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"8.3. Каждый сотрудник имеет право на обеденный перерыв [Который установлен графиком].")
				if imgui.IsItemClicked(0) then
					setClipboardText("8.3. Каждый сотрудник имеет право на обеденный перерыв [Который установлен графиком].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"8.3.1. В обеденное время, несколько сотрудников должно находится на своих постах в Мед.Центре.")
				if imgui.IsItemClicked(0) then
					setClipboardText("8.3.1. В обеденное время, несколько сотрудников должно находится на своих постах в Мед.Центре.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"8.4. Запрещено покидать Мед.Центр в рабочее время [Исключения: выполнение работы организации, поручений старших, отгул со стороны руководства].")
				if imgui.IsItemClicked(0) then
					setClipboardText("8.4. Запрещено покидать Мед.Центр в рабочее время [Исключения: выполнение работы организации, поручений старших, отгул со стороны руководства].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"8.5. Если в штате есть 1 сотрудник выше 2-ой должности, он обязан находится в Мед.Центре и оказывать медицинскую помощь даже если всего лишь 1 сотрудник в штате")
				if imgui.IsItemClicked(0) then
					setClipboardText("8.5. Если в штате есть 1 сотрудник выше 2-ой должности, он обязан находится в Мед.Центре и оказывать медицинскую помощь даже если всего лишь 1 сотрудник в штате")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"8.6. Запрещено подрабатывать на какой-либо работе в рабочее время.")
				if imgui.IsItemClicked(0) then
					setClipboardText("8.6. Запрещено подрабатывать на какой-либо работе в рабочее время.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"8.7. Сотруднику запрещено носить рабочую форму находясь не в Мед.Центре своего города [Исключение: РП/МП среди организаций].")
				if imgui.IsItemClicked(0) then
					setClipboardText("8.7. Сотруднику запрещено носить рабочую форму находясь не в Мед.Центре своего города [Исключение: РП/МП среди организаций].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("8.7.1. Если Министр Здравоохранения или иной сотрудник гос.организации увидит где-либо, кроме\nМед.Центра без причины [Участие в РП / МП среди гос/мафий или просто РП ситуация] в рабочей форме\nво время рабочего дня сотрудников старшего состава - на первый раз просто передает информацию\nГлав.врачу. На второй - {FF0000}выговор{FFFFFF}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("8.7.1. Если Министр Здравоохранения или иной сотрудник гос.организации увидит где-либо, кроме Мед.Центра без причины [Участие в РП / МП среди гос/мафий или просто РП ситуация] в рабочей форме во время рабочего дня сотрудников старшего состава - на первый раз просто передает информацию Глав.врачу. На второй - выговор.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("8.7.2. Если руководство мед.центров будет обнаружено в форме за территорией мед.центра без\nвесомых причин, единожды - предупреждение,повторные нарушения для Заместителя - выговор,\nдля Глав.Врача - {54acd2}3 Штрафных очка от Министра")
				if imgui.IsItemClicked(0) then
					setClipboardText("8.7.2. Если руководство мед.центров будет обнаружено в форме за территорией мед.центра без весомых причин, единожды - предупреждение,повторные нарушения для Заместителя - выговор, для Глав.Врача - 3 Штрафных очка от Министра")
				end
			end
			imgui.Dummy(imgui.ImVec2(0, 5)) 
			if imgui.CollapsingHeader(u8"Глава 9. - Кабинеты и посты") then
				imgui.Spacing()
				imgui.TextWrapped(u8"9.1. Сотрудник министерства здравоохранения может выписывать мед.карты и рецепты только за стойкой на первом этаже. Лечить наркозависимость - в операционной на первом этаже.")
				if imgui.IsItemClicked(0) then
					setClipboardText("9.1. Сотрудник министерства здравоохранения может выписывать мед.карты и рецепты только за стойкой на первом этаже. Лечить наркозависимость - в операционной на первом этаже.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"9.2 Сотрудники министерства здравоохранения обязаны лечить пациентов в палате,карете скорой помощи, а также лечение разрешается в операционной если оказывается срочная мед.помощь или заболевания пациента имеют тяжелый характер (Перелом, Операция, Кровотечение).")
				if imgui.IsItemClicked(0) then
					setClipboardText("9.2 Сотрудники министерства здравоохранения обязаны лечить пациентов в палате,карете скорой помощи, а также лечение разрешается в операционной если оказывается срочная мед.помощь или заболевания пациента имеют тяжелый характер (Перелом, Операция, Кровотечение).")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("9.2.1 Лечение в других местах, производятся только в случаях невозможности транспортировки\nпациента, за нарушение данного правила сотрудник получит - {FF0000}выговор{FFFFFF}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("9.2.1 Лечение в других местах, производятся только в случаях невозможности транспортировки пациента, за нарушение данного правила сотрудник получит - {FF0000}выговор{FFFFFF}.")
				end
			end
			imgui.Dummy(imgui.ImVec2(0, 5)) 
			if imgui.CollapsingHeader(u8"Глава 10. - Дресс-код сотрудников МЗ") then
				imgui.Spacing()
				imgui.TextWrapped(u8"10.1. Сотрудник, который зашел в операционную, обязать снять с себя все аксессуары. За исключением пункта 10.1.1")
				if imgui.IsItemClicked(0) then
					setClipboardText("10.1. Сотрудник, который зашел в операционную, обязать снять с себя все аксессуары. За исключением пункта 10.1.1")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"10.1.1 Сотруднику разрешено находится в операционной в очках с прозрачными линзами, маской от коронавируса, респиратором")
				if imgui.IsItemClicked(0) then
					setClipboardText("10.1.1 Сотруднику разрешено находится в операционной в очках с прозрачными линзами, маской от коронавируса, респиратором")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"10.2 Любому сотруднику МЗ запрещено носить аксессуары, которые закрывают лицо:")
				imgui.TextColoredRGB("{f7cc46}Маски, Банданы, Маски развлекательные (например: маска петуха), Шлема, Рога, Шлем S.W.A.T. и\n{f7cc46}полицейский значок [только для МЮ и МО], Бронежилеты [только для МЮ и МО]\n{f7cc46}[Исключение: можно носить на улице];")
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"10.3. Любому сотруднику МЗ разрешено носить такие аксессуары:")
				imgui.TextColoredRGB("{f7cc46}Головной убор(За искл. п.10.2.), Повязка на шею, Усы, Борода, Респиратор, Очки, Крест, Часы, Дреды,\n{f7cc46}Череп на грудь, Сердце на грудь, Трость, Маска от коронавируса, Патрон на грудь, Доллар на грудь,\n{f7cc46}Монокль, Замок на грудь,  Рубашка на грудь, Любые кейсы/чемоданы.")
			end
			imgui.Dummy(imgui.ImVec2(0, 5)) 
			if imgui.CollapsingHeader(u8"Глава 11 - Рабочее авто") then
				imgui.Spacing()
				imgui.TextColoredRGB("11.1 Авто Ambulance можно брать с [{f7cc46}3{FFFFFF}] порядковой должности.")
				if imgui.IsItemClicked(0) then
					setClipboardText("11.1 Авто Ambulance можно брать с [3] порядковой должности.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("11.2 Авто Premier можно брать с [{f7cc46}5{FFFFFF}] порядковой должности.")
				if imgui.IsItemClicked(0) then
					setClipboardText("11.2 Авто Premier можно брать с [5] порядковой должности.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("11.3 Авто Dodge Grand Caravan можно брать с [{f7cc46}6{FFFFFF}] порядковой должности.")
				if imgui.IsItemClicked(0) then
					setClipboardText("11.3 Авто Dodge Grand Caravan можно брать с [6] порядковой должности.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("11.4 Авто Ford F150 можно брать с [{f7cc46}6{FFFFFF}] порядковой должности.")
				if imgui.IsItemClicked(0) then
					setClipboardText("11.4 Авто Ford F150 можно брать с [6] порядковой должности.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("11.5 Авто Ford Explorer можно брать с [{f7cc46}7{FFFFFF}] порядковой должности.")
				if imgui.IsItemClicked(0) then
					setClipboardText("11.5 Авто Ford Explorer можно брать с [7] порядковой должности.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("11.6 Авто Dodge Charger можно брать с [{f7cc46}8{FFFFFF}] порядковой должности.")
				if imgui.IsItemClicked(0) then
					setClipboardText("11.6 Авто Dodge Charger можно брать с [8] порядковой должности.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("11.7 Вертолет Maverick можно брать с [{f7cc46}8{FFFFFF}] порядковой должности.")
				if imgui.IsItemClicked(0) then
					setClipboardText("11.7 Вертолет Maverick можно брать с [8] порядковой должности.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("11.8 Авто Tesla Model X можно брать с [{f7cc46}7{FFFFFF}] порядковой должности.")
				if imgui.IsItemClicked(0) then
					setClipboardText("11.8 Авто Tesla Model X можно брать с [7] порядковой должности.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"11.9 Автомобили разрешается брать не по должности, если Руководство разрешило использовать транспортное средство.")
				if imgui.IsItemClicked(0) then
					setClipboardText("11.9 Автомобили разрешается брать не по должности, если Руководство разрешило использовать транспортное средство.")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextColoredRGB("11.9.1 За нарушение одного из правил, сотрудник получит - {FF0000}[выговор]{FFFFFF}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("11.9.1 За нарушение одного из правил, сотрудник получит - [выговор]")
				end
			end
			imgui.Dummy(imgui.ImVec2(0, 5)) 
			if imgui.CollapsingHeader(u8"Глава 12 - Использование объектов") then
				imgui.Spacing()
				imgui.TextColoredRGB("12.1 Запрещено использовать спец. объекты Мед.Центра не по назначению (Пример: брать батуты и\nстроить друг на друга, создавая помеху) строго запрещено! На первый раз сотрудник получит {FF0000}[выговор]{FFFFFF},\nпри повторных случаях, сотрудник будет {FF0000}[уволен]{FFFFFF}.")
				if imgui.IsItemClicked(0) then
					setClipboardText("12.1 Запрещено использовать спец. объекты Мед.Центра не по назначению (Пример: брать батуты и строить друг на друга, создавая помеху) строго запрещено! На первый раз сотрудник получит [Выговор], при повторных случаях, сотрудник будет [Уволен].")
				end
				imgui.Spacing()
				imgui.Separator()
				imgui.Spacing()
				imgui.TextWrapped(u8"12.2 Использовать спец. объекты Мед.Центра, можно только в экстренных ситуациях.")
				if imgui.IsItemClicked(0) then
					setClipboardText("12.2 Использовать спец. объекты Мед.Центра, можно только в экстренных ситуациях.")
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
			imgui.Text(fa.ICON_ANGLE_RIGHT .. u8" Данный раздел предназначен для полной настройки скрипта под свой вкус");
			imgui.Separator()
			imgui.Dummy(imgui.ImVec2(0, 5))
			imgui.Indent(10)
			if imgui.CollapsingHeader(u8"Основная информация") then
				mainSet()
			end
			imgui.Dummy(imgui.ImVec2(0, 3))
			if imgui.CollapsingHeader(u8"Настройки") then
				imgui.SetCursorPosX(25)
				imgui.BeginGroup()
				if imgui.Checkbox(u8"Скрыть объявления", cb_chat1) then
					needSave = true 
				end
				if imgui.Checkbox(u8"Скрыть подсказки сервера", cb_chat2) then
					needSave = true
				end
				if imgui.Checkbox(u8"Скрыть новости СМИ", cb_chat3) then
					needSave = true
				end
				imgui.EndGroup()
			end
			imgui.Dummy(imgui.ImVec2(0, 5)) 
			if imgui.CollapsingHeader(u8"Ценовая политика") then
				imgui.SetCursorPosX(25);
				imgui.BeginGroup()
				imgui.PushItemWidth(60); 
				imgui.Spacing()
				if imgui.InputText(u8"Лечение", buf_lec, imgui.InputTextFlags.CharsDecimal) then
					needSave = true
				end
				imgui.Spacing()
				if imgui.InputText(u8"Выдача рецептов", buf_rec, imgui.InputTextFlags.CharsDecimal) then
					needSave = true
				end
				imgui.Spacing()
				if imgui.InputText(u8"Лечение от наркозависимости", buf_narko, imgui.InputTextFlags.CharsDecimal) then
					needSave = true
				end
				imgui.Spacing()
				if imgui.InputText(u8"Сведение тату", buf_tatu, imgui.InputTextFlags.CharsDecimal) then
					needSave = true
				end
				imgui.Spacing()
				if imgui.InputText(u8"Выдача антибиотика", buf_antb, imgui.InputTextFlags.CharsDecimal) then
					needSave = true
				end
				imgui.Spacing()
				imgui.Spacing()
				if imgui.InputText(u8"Цена мед карты на 7 дней", buf_medcard1, imgui.InputTextFlags.CharsDecimal) then
					needSave = true
				end
				imgui.Spacing()
				if imgui.InputText(u8"Цена мед карты на 14 дней", buf_medcard2, imgui.InputTextFlags.CharsDecimal) then
					needSave = true
				end
				imgui.Spacing()
				if imgui.InputText(u8"Цена мед карты на 30 дней", buf_medcard3, imgui.InputTextFlags.CharsDecimal) then
					needSave = true
				end
				imgui.Spacing()
				if imgui.InputText(u8"Цена мед карты на 60 дней", buf_medcard4, imgui.InputTextFlags.CharsDecimal) then
					needSave = true
				end
				imgui.Spacing()
				imgui.PopItemWidth()
				imgui.EndGroup();
				imgui.Spacing()
				imgui.TextWrapped(u8"Более подробно можете узнать на форуме по пути forum.arizona-rp.com -> Игровые сервра: Ваш текущий сервер -> Гос. стурктуры -> Мин.Здрав.")
			end
			imgui.EndChild();
			imgui.PushStyleColor(imgui.Col.Button, needSaveColor)
			if imgui.Button(u8"Сохранить", imgui.ImVec2(688, 20)) then
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
				sampAddChatMessage("{FFFFFF}["..script_names.."]: Настройки сохранены.", 0xEE4848)
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
			imgui.Text(u8"Список шпаргалок")
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
			if imgui.Button(u8"Добавить", imgui.ImVec2(140, 20)) then
				if #spur.list ~= 20 then
					for i = 1, 20 do
						if not table.concat(spur.list, "|"):find("Шпаргалка '"..i.."'") then
							table.insert(spur.list, "Шпаргалка '"..i.."'")
							spur.edit = true
							spur.select_spur = #spur.list
							spur.name.v = ""
							spur.text.v = ""
							spurBig.v = false
							local f = io.open(dirml.."/MedicalHelper/Шпаргалки/Шпаргалка '"..i.."'.txt", "w")
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
				imgui.Text(u8"Поле для заполнения")
				imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(70, 70, 70, 200):GetVec4())
				imgui.InputTextMultiline("##spur", spur.text, imgui.ImVec2(525, 284))
				imgui.PopStyleColor(1)
				imgui.PushItemWidth(400)
				if imgui.Button(u8"Открыть большой редактор/просмотр", imgui.ImVec2(525, 20)) then
					spurBig.v = not spurBig.v
				end
				imgui.Spacing() 
				imgui.InputText(u8"Название шпоры", spur.name, imgui.InputTextFlags.CallbackCharFilter, filter(1, "[%wа-Я%+%№%#%(%)]"))
				imgui.Spacing()
				imgui.PopItemWidth()
				if imgui.Button(u8"Удалить", imgui.ImVec2(260, 20)) then
					if doesFileExist(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt") then
						os.remove(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt")
					end
					table.remove(spur.list, spur.select_spur) 
					spur.edit = false
					spur.select_spur = -1
					spur.name.v = ""
					spur.text.v = ""
				end
				imgui.SameLine()
				if imgui.Button(u8"Сохранить", imgui.ImVec2(260, 20)) then
					local name = ""
					local bool = false
					if spur.name.v ~= "" then 
							name = u8:decode(spur.name.v)
							if doesFileExist(dirml.."/MedicalHelper/Шпаргалки/"..name..".txt") and spur.list[spur.select_spur] ~= name then
								bool = true
								imgui.OpenPopup(u8"Ошибка")
							else
								os.remove(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt")
								spur.list[spur.select_spur] = u8:decode(spur.name.v)
							end
					else
						name = spur.list[spur.select_spur]
					end
					if not bool then
						local f = io.open(dirml.."/MedicalHelper/Шпаргалки/"..name..".txt", "w")
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
					imgui.TextColoredRGB("Включено большое окно")
				elseif not spurBig.v and (spur.select_spur >= 1 and spur.select_spur <= 20) then
					imgui.Dummy(imgui.ImVec2(0, 150))
					imgui.SetCursorPosX(515)
					imgui.Text(u8"Выберете действие")
					imgui.Spacing()
					imgui.Spacing()
					imgui.SetCursorPosX(490)
					if imgui.Button(u8"Открыть для просмотра", imgui.ImVec2(170, 20)) then
						spurBig.v = true
					end
					imgui.Spacing()
					imgui.SetCursorPosX(490)
					if imgui.Button(u8"Редактировать", imgui.ImVec2(170, 20)) then
						spur.edit = true
						local f = io.open(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt", "r")
						spur.text.v = u8(f:read("*a"))
						f:close()
						spur.name.v = u8(spur.list[spur.select_spur])
					end
					imgui.Spacing()
					imgui.SetCursorPosX(490)
					if imgui.Button(u8"Удалить", imgui.ImVec2(170, 20)) then
						if doesFileExist(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt") then
							os.remove(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt")
						end
						table.remove(spur.list, spur.select_spur) 
						spur.select_spur = -1
					end
				else
				imgui.Dummy(imgui.ImVec2(0, 150))
				imgui.SetCursorPosX(400)
				imgui.TextColoredRGB("Нажмите на кнопку {FF8400}\"Добавить\"{FFFFFF}, чтобы создать новую шпоргалку\n\t\t\t\t\t\t\t\t\tили выберете уже существующий.")
			end
			imgui.EndGroup()
		end
		if select_menu[4] then
			imgui.SameLine()
			imgui.BeginGroup()
			imgui.Text(u8"Здесь находится список новых команд, к которым можете применить клавишу активации.")
			imgui.Separator();
			imgui.Dummy(imgui.ImVec2(0, 5))
			imgui.BeginChild("cmd list", imgui.ImVec2(0, 313), true)
			imgui.Columns(3, "keybinds", true); 
			imgui.SetColumnWidth(-1, 80); 
			imgui.Text(u8"Команда"); 
			imgui.NextColumn();
			imgui.SetColumnWidth(-1, 450); 
			imgui.Text(u8"Описание"); 
			imgui.NextColumn(); 
			imgui.Text(u8"Клавиша"); 
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
						imgui.Text(u8"Нет")
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
						imgui.Text(u8"Нет")
					else
						imgui.Text(table.concat(rkeys.getKeysName(v.key), " + "))
					end	
					imgui.NextColumn()
					imgui.PopStyleColor(1)
				end
			end
			imgui.EndChild();
			if cmdBind[selected_cmd].rank <= num_rank.v+1 then
				imgui.Text(u8"Выберете сначала интересующую Вас команду, после чего можете производить редактирование.")
				if imgui.Button(u8"Назначить клавишу", imgui.ImVec2(140, 20)) then 
					imgui.OpenPopup(u8"MH | Установка клавиши для активации");
					lockPlayerControl(true)
					editKey = true
				end
				imgui.SameLine();
				if imgui.Button(u8"Очистить активацию", imgui.ImVec2(145, 20)) then 
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
				imgui.Text(u8"Данная команда Вам недоступна. Доступна только от " .. cmdBind[selected_cmd].rank .. u8" ранга")
				imgui.Text(u8"Если Ваш ранг соответствует требованиям, пожалуйста измените должность в настройках.")
			end
			imgui.EndGroup()
		end
		if select_menu[5] then
			imgui.SameLine()
			imgui.BeginGroup()
			imgui.BeginChild("bind list", imgui.ImVec2(195, 380), true)
			imgui.SetCursorPosX(20)
			imgui.Text(u8"Список биндов")
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
			if imgui.Button(u8"Добавить", imgui.ImVec2(196, 20)) then
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
				imgui.Text(u8"Поле для заполнения")
				imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(70, 70, 70, 200):GetVec4())
				imgui.InputTextMultiline("##bind", binder.text, imgui.ImVec2(525, 271))
				imgui.PopStyleColor(1)
				imgui.PushItemWidth(150)
				imgui.InputText(u8"Название бинда", binder.name, imgui.InputTextFlags.CallbackCharFilter, filter(1, "[%wа-Я%+%№%#%(%)]"))
				if imgui.Button(u8"Назначить клавишу", imgui.ImVec2(150, 20)) then 
					imgui.OpenPopup(u8"MH | Установка клавиши для активации")
					editKey = true
				end 
				imgui.SameLine()
				imgui.TextColoredRGB("Активация: "..table.concat(rkeys.getKeysName(binder.key), " + "))
				imgui.DragFloat("##sleep", binder.sleep, 0.1, 0.5, 10.0, u8"Задержка = %.1f сек.")
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
				imgui.Text(u8"Интервал времени между строк")
				if imgui.Button(u8"Удалить", imgui.ImVec2(110, 20)) then
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
				if imgui.Button(u8"Сохранить", imgui.ImVec2(110, 20)) then
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
								imgui.OpenPopup(u8"Ошибка")
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
				if imgui.Button(u8"Тег-функции", imgui.ImVec2(110, 20)) then
					paramWin.v = not paramWin.v
				end
				imgui.SameLine()
				if imgui.Button(u8"Функционал", imgui.ImVec2(110, 20)) then
					profbWin.v = not profbWin.v
				end
			else
				imgui.Dummy(imgui.ImVec2(0, 150))
				imgui.SetCursorPosX(450)
				imgui.TextColoredRGB("Нажмите на кнопку {FF8400}\"Добавить\"{FFFFFF}, чтобы создать новый бинд\n\t\t\t\t\t\t\t\tили выберете уже существующий.")
			end
			imgui.EndGroup()
		end
			if select_menu[6] then
			imgui.SameLine()
			imgui.BeginChild("about", imgui.ImVec2(0, 0), true)
			imgui.SetCursorPosX(280)
			imgui.Text(u8"Medical Helper")
			imgui.Spacing()
			imgui.TextWrapped(u8"Скрипт был разработан для проекта Ariona RP. Благодаря этому приложению Вы получите полный комплекс автоматизации многих действий и наслаждение от пользования.\nОбновления выходят по мере добавления нововведений и исправлений ошибок.")
			imgui.Dummy(imgui.ImVec2(0, 10))
			imgui.Bullet()
			imgui.TextColoredRGB("Разработчик - {FFB700}Ministries of Health")
			imgui.Bullet()
			imgui.TextColoredRGB("Версия скрипта - {FFB700}".. scr.version)
			imgui.Dummy(imgui.ImVec2(0, 20))
			imgui.SetCursorPosX(20)
			imgui.Text(fa.ICON_BUG)
			imgui.SameLine()
			imgui.TextColoredRGB("Нашли баг или ошибку, или же хотите видеть что-то новое, напиши в группу");
			imgui.SameLine();
			imgui.Text(fa.ICON_ARROW_DOWN)
			imgui.SetCursorPosX(20)
			imgui.Text(fa.ICON_LINK)
			imgui.SameLine()
			imgui.TextColoredRGB("Для связи: VK: {74BAF4}vk.com/medhelperarz)
			if imgui.IsItemHovered() then
				imgui.SetTooltip(u8"Кликните ЛКМ, чтобы скопировать, или ПКМ, чтобы открыть в браузере")
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
			if imgui.Button(u8"Отключить", imgui.ImVec2(160, 20)) then
				showCursor(false);
				scr:unload()
			end
			imgui.SameLine()
			imgui.SetCursorPosX(260)
			if imgui.Button(u8"Перезагрузить", imgui.ImVec2(160, 20)) then
				showCursor(false);
				scr:reload()
			end
			imgui.SameLine()
			imgui.SetCursorPosX(430)
			if imgui.Button(u8"Удалить скрипт", imgui.ImVec2(160, 20)) then 
				addOneOffSound(0, 0, 0, 1058)
				sampAddChatMessage("", 0xEE4848)
				sampAddChatMessage("", 0xEE4848)
				sampAddChatMessage("", 0xEE4848)
				sampAddChatMessage("{FFFFFF}["..script_names.."]: Внимание! Подтвердите удаление командой {77DF63}/mh-delete.", 0xEE4848)
				mainWin.v = false
			end
			imgui.EndChild()
		end
		imgui.PushStyleColor(imgui.Col.PopupBg, imgui.ImVec4(0.06, 0.06, 0.06, 0.94))
		if imgui.BeginPopupModal(u8"MH | Установка клавиши для активации", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
			imgui.Text(u8"Нажмите на клавишу или сочетание клавиш для установки активации.");
			imgui.Separator()
			imgui.Text(u8"Допускаются клавиши:")
			imgui.Bullet()	imgui.TextDisabled(u8"Клавиши для сочетаний - Alt, Ctrl, Shift")
			imgui.Bullet()	imgui.TextDisabled(u8"Английские буквы")
			imgui.Bullet()	imgui.TextDisabled(u8"Функциональные клавиши F1-F12")
			imgui.Bullet()	imgui.TextDisabled(u8"Цифры верхней панели")
			imgui.Bullet()	imgui.TextDisabled(u8"Боковая панель Numpad")
			imgui.Checkbox(u8"Использовать ПКМ в комбинации с клавишами", cb_RBUT)
			imgui.Separator()
			if imgui.TreeNode(u8"Для пользователей 5-кнопочной мыши") then
				imgui.Checkbox(u8"X Button 1", cb_x1)
				imgui.Checkbox(u8"X Button 2", cb_x2)
				imgui.Separator()
				imgui.TreePop();
			end
			imgui.Text(u8"Текущая клавиша(и): ");
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
				imgui.TextColored(imgui.ImColor(45, 225, 0, 200):GetVec4(), u8"Данный бинд уже существует!")
			end
			if imgui.Button(u8"Установить", imgui.ImVec2(150, 0)) then
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
			if imgui.Button(u8"Закрыть", imgui.ImVec2(150, 0)) then 
				imgui.CloseCurrentPopup(); 
				currentKey = {"",{}}
				cb_RBUT.v = false
				cb_x1.v, cb_x2.v = false, false
				lockPlayerControl(false)
				isHotKeyDefined = false
				editKey = false
			end 
			imgui.SameLine()
			if imgui.Button(u8"Очистить", imgui.ImVec2(150, 0)) then
				currentKey = {"",{}}
				cb_x1.v, cb_x2.v = false, false
				cb_RBUT.v = false
				isHotKeyDefined = false
			end
			imgui.EndPopup()
		end
		if imgui.BeginPopupModal(u8"Ошибка", null, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove) then
			imgui.Text(u8"Данное название уже существует")
			imgui.SetCursorPosX(60)
			if imgui.Button(u8"Ок", imgui.ImVec2(120, 20)) then
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

		imgui.Begin(u8"Код-параметры для биндера", paramWin, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize);
		imgui.SetWindowFontScale(1.1)
		imgui.SetCursorPosX(50)
		imgui.TextColoredRGB("[center]{FFFF41}Кликни мышкой по самому тегу, чтобы скопировать его.", imgui.GetMaxWidthByText("Кликни мышкой по самому тегу, чтобы скопировать его."))
		imgui.Dummy(imgui.ImVec2(0, 15))

		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myID}")
		imgui.SameLine()
		if imgui.IsItemHovered(0) then
			setClipboardText("{myID}")
		end
		imgui.TextColoredRGB("{C1C1C1} - Ваш id - {ACFF36}"..tostring(myid))

		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myNick}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then
			setClipboardText("{myNick}")
		end
		imgui.TextColoredRGB("{C1C1C1} - Ваш полный ник (по анг.) - {ACFF36}"..tostring(myNick:gsub("_", " ")))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myRusNick}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then
			setClipboardText("{myRusNick}")
		end
		imgui.TextColoredRGB("{C1C1C1} - Ваш ник, указанный в настройках - {ACFF36}"..tostring(u8:decode(buf_nick.v)))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myHP}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then
			setClipboardText("{myHP}")
		end
		imgui.TextColoredRGB("{C1C1C1} - Ваш уровень ХП - {ACFF36}"..tostring(getCharHealth(PLAYER_PED)))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myArmo}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then
			setClipboardText("{myArmo}")
		end
		imgui.TextColoredRGB("{C1C1C1} - Ваш текущий уровень брони - {ACFF36}"..tostring(getCharArmour(PLAYER_PED)))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myHosp}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then
			setClipboardText("{myHosp}")
		end
		imgui.TextColoredRGB("{C1C1C1} - название Вашей больницы - {ACFF36}"..tostring(u8:decode(chgName.org[num_org.v+1])))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myHospEn}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then
			setClipboardText("{myHospEn}")
		end
		imgui.TextColoredRGB("{C1C1C1} - полное название Вашей больницы на анг. - {ACFF36}"..tostring(u8:decode(list_org_en[num_org.v+1])))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myTag}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then
			setClipboardText("{myTag}")
		end
		imgui.TextColoredRGB("{C1C1C1} - Ваш тег  - {ACFF36}"..tostring(u8:decode(buf_teg.v)))
		
		imgui.Spacing()		
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{myRank}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then
			setClipboardText("{myRank}")
		end
		imgui.TextColoredRGB("{C1C1C1} - Ваша текущая должность - {ACFF36}"..tostring(u8:decode(chgName.rank[num_rank.v+1])))
		
		imgui.Spacing()	
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{time}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then
			setClipboardText("{time}")
		end
		imgui.TextColoredRGB("{C1C1C1} - время в формате часы:минуты:секунды - {ACFF36}"..tostring(os.date("%X")))
		
		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{day}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then
			setClipboardText("{day}")
		end
		imgui.TextColoredRGB("{C1C1C1} - текущий день месяца - {ACFF36}"..tostring(os.date("%d")))

		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{week}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then
			setClipboardText("{week}")
		end
		imgui.TextColoredRGB("{C1C1C1} - текущая неделя - {ACFF36}"..tostring(week[tonumber(os.date("%w"))+1]))

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
		imgui.TextColoredRGB("{C1C1C1} - получает Ник игрока на которого последний раз целился.")

		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{target}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then setClipboardText("{target}")
		end
		imgui.TextColoredRGB("{C1C1C1} - последний ID игрока, на которого целился (наведена мышь) - {ACFF36}"..tostring(targID))

		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), "{pause}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then
			setClipboardText("{pause}")
		end
		imgui.TextColoredRGB("{C1C1C1} - создание паузы между отправки строки в чат. {EC3F3F}Прописывать отдельно, т.е. с новой строки.")

		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), u8"{sleep:время}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then
			setClipboardText("{sleep:1000}")
		end
		imgui.TextColoredRGB("{C1C1C1} - Задаёт свой интервал времени между строчками. \n\tПример: {sleep:2500}, где 2500 время в мс (1 сек = 1000 мс)")

		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), u8"{sex:текст1|текст2}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then
			setClipboardText("{sex:text1|text2}")
		end
		imgui.TextColoredRGB("{C1C1C1} - Возвращает текст в зависимости от выбранного пола.  \n\tПример, {sex:понял|поняла}, вернёт 'понял', если выбран мужской пол или 'поняла', если женский")
		
		imgui.Spacing()
		imgui.TextColored(imgui.ImVec4(1,0.52,0,1), u8"{getNickByID:ид игрока}")
		imgui.SameLine()
		if imgui.IsItemClicked(0) then
			setClipboardText("{getNickByID:}")
		end
		imgui.TextColoredRGB("{C1C1C1} - Возращает ник игрока по его ID. \n\tПример, {getNickByID:25}, вернёт ник игрока под ID 25.)")
		imgui.End()
	end
	if spurBig.v then
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(1098, 790), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Редактор Шпаргалки", spurBig, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar);
		if spur.edit then
			imgui.SetCursorPosX(350)
			imgui.Text(u8"Большое окно для редактирования шпоргалок")
			imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(70, 70, 70, 200):GetVec4())
			imgui.InputTextMultiline("##spur", spur.text, imgui.ImVec2(1081, 715))
			imgui.PopStyleColor(1)
			if imgui.Button(u8"Сохранить", imgui.ImVec2(357, 20)) then
				local name = ""
				local bool = false
				if spur.name.v ~= "" then 
					name = u8:decode(spur.name.v)
					if doesFileExist(dirml.."/MedicalHelper/Шпаргалки/"..name..".txt") and spur.list[spur.select_spur] ~= name then
						bool = true
						imgui.OpenPopup(u8"Ошибка")
					else
						os.remove(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt")
						spur.list[spur.select_spur] = u8:decode(spur.name.v)
					end
				else
					name = spur.list[spur.select_spur]
				end
				if not bool then
					local f = io.open(dirml.."/MedicalHelper/Шпаргалки/"..name..".txt", "w")
					f:write(u8:decode(spur.text.v))
					f:flush()
					f:close()
					spur.text.v = ""
					spur.name.v = ""
					spur.edit = false
				end
			end
			imgui.SameLine()
			if imgui.Button(u8"Удалить", imgui.ImVec2(357, 20)) then
				spur.text.v = ""
				table.remove(spur.list, spur.select_spur) 
				spur.select_spur = -1
				if doesFileExist(dirml.."/MedicalHelper/Шпаргалки/"..u8:decode(spur.select_spur)..".txt") then
					os.remove(dirml.."/MedicalHelper/Шпаргалки/"..u8:decode(spur.select_spur)..".txt")
				end
				spur.name.v = ""
				spurBig.v = false
				spur.edit = false
			end
			imgui.SameLine()
			if imgui.Button(u8"Включить просмотр", imgui.ImVec2(357, 20)) then
				spur.edit = false
			end
			if imgui.Button(u8"Закрыть", imgui.ImVec2(1081, 20)) then
				spurBig.v = not spurBig.v
			end
		else
			imgui.SetCursorPosX(390)
			imgui.Text(u8"Большое окно для просмотра шпоргалок")
			imgui.BeginChild("spur spec", imgui.ImVec2(1081, 715), true)
			if doesFileExist(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt") then
				for line in io.lines(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt") do
					imgui.TextWrapped(u8(line))
				end
			end
			imgui.EndChild()
			if imgui.Button(u8"Включить редактирование", imgui.ImVec2(530, 20)) then 
				spur.edit = true
				local f = io.open(dirml.."/MedicalHelper/Шпаргалки/"..spur.list[spur.select_spur]..".txt", "r")
				spur.text.v = u8(f:read("*a"))
				f:close()
			end
			imgui.SameLine()
			if imgui.Button(u8"Закрыть", imgui.ImVec2(530, 20)) then
				spurBig.v = not spurBig.v
			end
		end
		imgui.End()
	end
	if sobWin.v then
		local sw, sh = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(253, 496), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Меню для собеседования", sobWin, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize);
		imgui.BeginGroup()
		imgui.PushItemWidth(135)
		imgui.InputText("##id", sobes.selID, imgui.InputTextFlags.CallbackCharFilter + imgui.InputTextFlags.EnterReturnsTrue, filter(1, "%d+"))
		imgui.PopItemWidth()
		if not imgui.IsItemActive() and sobes.selID.v == "" then
			imgui.SameLine()
			imgui.SetCursorPosX(20)
			imgui.TextDisabled(u8"Укажите id игрока") 
		end
		imgui.SameLine()
		imgui.SetCursorPosX(162)
		if imgui.Button(u8"Начать", imgui.ImVec2(75, 20)) then
			if sobes.selID.v ~= "" then
				sobes.num = sobes.num + 1
				threadS = lua_thread.create(sobesRP, sobes.num);
			else
				sampAddChatMessage("{FFFFFF}["..script_names.."]: Укажите id игрока для начала собеседования.", 0xEE4848)
			end
		end
		imgui.BeginChild("pass player", imgui.ImVec2(223, 233), true)
		imgui.SetCursorPosX(37)
		imgui.Text(u8"Информация о игроке:")
		imgui.Separator()
		imgui.Text(u8"Имя:")
		if sobes.player.name == "" then
			imgui.SameLine()
			imgui.TextColoredRGB("{F55534}нет")
		else
			imgui.SameLine()
			imgui.TextColoredRGB("{FFCD00}"..sobes.player.name)
		end
		imgui.Text(u8"Лет в штате:")
		if sobes.player.let == 0 then
			imgui.SameLine()
			imgui.TextColoredRGB("{F55534}нет")
		else
			if sobes.player.let >= 3 then
				imgui.SameLine()
				imgui.TextColoredRGB("{17E11D}"..sobes.player.let.."/3")
			else
				imgui.SameLine()
				imgui.TextColoredRGB("{F55534}"..sobes.player.let.."{17E11D}/3")
			end
		end
		imgui.Text(u8"Законопослушность:")
		if sobes.player.zak == 0 then
			imgui.SameLine()
			imgui.TextColoredRGB("{F55534}нет")
		else
			if sobes.player.zak >= 35 then
				imgui.SameLine()
				imgui.TextColoredRGB("{17E11D}"..sobes.player.zak.."/35")
			else
				imgui.SameLine()
				imgui.TextColoredRGB("{F55534}"..sobes.player.zak.."{17E11D}/35")
			end
		end
		imgui.Text(u8"Имеет работу:")
		if sobes.player.work == "" then
			imgui.SameLine()
			imgui.TextColoredRGB("{F55534}нет")
		else
			if sobes.player.work == "Без работы" then
				imgui.SameLine()
				imgui.TextColoredRGB("{17E11D}"..sobes.player.work)
			else
				imgui.SameLine()
				imgui.TextColoredRGB("{F55534}"..sobes.player.work)
			end
		end
		imgui.Text(u8"Состоит в ЧС:")
		if sobes.player.bl == "" then
			imgui.SameLine()
			imgui.TextColoredRGB("{F55534}нет")
		else
			if sobes.player.bl == "Не найден(а)" then
				imgui.SameLine()
				imgui.TextColoredRGB("{17E11D}"..sobes.player.bl)
			else
				imgui.SameLine()
				imgui.TextColoredRGB("{F55534}"..sobes.player.bl)
			end
		end
		imgui.Text(u8"Лицензия на авто:")
		if sobes.player.lic == "Нету" then
			imgui.SameLine()
			imgui.TextColoredRGB("{F55534}нет")
		else
			if sobes.player.lic == "Есть" then
				imgui.SameLine()
				imgui.TextColoredRGB("{17E11D}есть")
			else
				imgui.SameLine()
				imgui.TextColoredRGB("{F55534}нет")
			end
		end
		imgui.Text(u8"Здоровье:")
		if sobes.player.heal == "" then
			imgui.SameLine()
			imgui.TextColoredRGB("{F55534}нет")
		else
			if sobes.player.heal == "Здоров" then
				imgui.SameLine()
				imgui.TextColoredRGB("{17E11D}"..sobes.player.heal)
			else
				imgui.SameLine()
				imgui.TextColoredRGB("{F55534}"..sobes.player.heal)
			end
		end
		imgui.Text(u8"Наркозависимость:")
		if sobes.player.narko == 0.1 then
			imgui.SameLine()
			imgui.TextColoredRGB("{F55534}нет")
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
		if imgui.Button(u8"Внеочередной вопрос", imgui.ImVec2(223, 30)) then
			imgui.OpenPopup("sobQN")
		end
		imgui.Spacing()
		if sobes.nextQ then
			if imgui.Button(u8"Дальше вопрос", imgui.ImVec2(223, 30)) then
				sobes.num = sobes.num + 1
				lua_thread.create(sobesRP, sobes.num); 
			end
		else
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(156, 156, 156, 200):GetVec4())
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(156, 156, 156, 200):GetVec4())
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(156, 156, 156, 200):GetVec4())
			imgui.Button(u8"Дальше вопрос", imgui.ImVec2(223, 30))
			imgui.PopStyleColor(3)
		end
		imgui.Spacing()
		if sobes.selID.v ~= "" then
			if imgui.Button(u8"Определить годность", imgui.ImVec2(223, 30)) then
				imgui.OpenPopup("sobEnter")
			end
		else
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImColor(156, 156, 156, 200):GetVec4())
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImColor(156, 156, 156, 200):GetVec4())
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImColor(156, 156, 156, 200):GetVec4())
			imgui.Button(u8"Определить годностьс", imgui.ImVec2(223, 30))
			imgui.PopStyleColor(3)
		end
		imgui.Spacing()
		if sobes.selID.v ~= "" then 
			if imgui.Button(u8"Остановить/Очистить", imgui.ImVec2(223, 30)) then
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
			imgui.Button(u8"Остановить/Очистить", imgui.ImVec2(223, 30))
			imgui.PopStyleColor(3)
		end
		imgui.EndGroup()
		imgui.PushStyleColor(imgui.Col.PopupBg, imgui.ImVec4(0.06, 0.06, 0.06, 0.94)) 
		if imgui.BeginPopup("sobEnter") then
			if imgui.MenuItem(u8"Принять") then
				lua_thread.create(sobesRP, 4)
			end
			if imgui.BeginMenu(u8"Отклонить") then
				if imgui.MenuItem(u8"Отпечатка в паспорте (Ник)") then
					lua_thread.create(sobesRP, 5)
				end
				if imgui.MenuItem(u8"Мало лет проживания") then
					lua_thread.create(sobesRP, 6)
				end
				if imgui.MenuItem(u8"Проблемы с законом") then
					lua_thread.create(sobesRP, 7)
				end
				if imgui.MenuItem(u8"Имеет работу") then
					lua_thread.create(sobesRP, 8)
				end
				if imgui.MenuItem(u8"Состоит в ЧС") then
					lua_thread.create(sobesRP, 9)
				end
				if imgui.MenuItem(u8"Проблемы со здоровьем") then
					lua_thread.create(sobesRP, 10)
				end
				if imgui.MenuItem(u8"Имеет наркозависимость") then
					lua_thread.create(sobesRP, 11)
				end
				imgui.EndMenu()
			end
			imgui.EndPopup()
		end
		if imgui.BeginPopup("sobQN") then
			if imgui.MenuItem(u8"Попросить документы") then 
				sampSendChat("Предъявите пожалуйста Ваш пакет документов, а именно: паспорт и мед.карту.")
			end
			if imgui.MenuItem(u8"Выбор больницы") then 
				sampSendChat("Почему Вы выбрали именно нашу больницу для трудоустройства?")
			end
			if imgui.MenuItem(u8"Рассказать о себе") then 
				sampSendChat("Расскажите, пожалуйста, немного о себе.")
			end
			if imgui.MenuItem(u8"Имеет ли Discord") then 
				sampSendChat("Имеется ли у Вас спец.рация \"Discord\"?")
			end
			if imgui.BeginMenu(u8"Вопросы на психику:") then
				if imgui.MenuItem(u8"МГ") then 
					sampSendChat("Что может означать аббревиатура 'МГ'?")
				end
				if imgui.MenuItem(u8"ДМ") then 
					sampSendChat("Что может означать аббревиатура 'ДМ'?")
				end
				if imgui.MenuItem(u8"ТК") then 
					sampSendChat("Что может означать аббревиатура 'ТК'?")
				end
				if imgui.MenuItem(u8"РП") then 
					sampSendChat("Как Вы думаете, что может означать аббревиатура 'РП'?")							
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
		imgui.Begin(u8"Продвинутое пользование биндера", profbWin, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize);
		imgui.SetWindowFontScale(1.1)
		local vt1 = [[
Помимо стандартного использования биндера для последовательного проигрывания строчек
текста возможно использовать больший функционал для расширения возможностей.

{FFCD00}1. Система переменных{FFFFFF}
	Для создание переменных используется символ решётки {ACFF36}#{FFFFFF}, после которого идёт название
переменной. Название переменной может содержать только английские символы и цифры,
иначе будет пропущено. 
	После названия переменной ставится равно {ACFF36}={FFFFFF} и далее пишется любой текст, который
необходимо присвоить этой переменной. Текст может содержать любые символы.
		Пример: {ACFF36}#price=10.000$.{FFFFFF}
	Теперь, используя переменную {ACFF36}#price{FFFFFF}, можно её вставить куда вам захочется, и она будет
автоматически заменена во время проигрывания отыгровки на значение, которое было 
указано после равно.

{FFCD00}2. Комментирование текста{FFFFFF}
	С помощью комментирования можно сделать для себя пометку или описание чего-либо
при этом сам комментарий не будет отображаться. Комментарий создаётся двойным слешом //,
после которого пишется любой текст.
	Пример: {ACFF36}Здравствуйте, чем Вам помочь // Приветствие{FFFFFF}
Комментарий {ACFF36}// Приветствие{FFFFFF} во время отыгровки удалится и не будет виден.

{FFCD00}3. Система диалогов{FFFFFF}
	С помощью диалогов можно создавать разветвления отыгровок, с помощью которых можно
реализовывать более сложные варианты их.
Структура диалога:
	{ACFF36}{dialog}{FFFFFF} 		- начало структуры диалога
	{ACFF36}[name]=Текст{FFFFFF}- имя диалога. Задаётся после равно =. Оно не должно быть особо большим
	{ACFF36}[1]=Текст{FFFFFF}		- варианты для выбора дальшейших действий, где в скобках 1 - это
клавиша активация. Можно устанавливать помимо цифр, другие значения, например, [X], [B],
[NUMPAD1], [NUMPAD2] и т.д. Список доступных клавиш можно посмотреть здесь. После равно
прописывается имя, которое будет отображаться при выборе. 
	После того, как задали имя варианта, со следующей строки пишутся уже сами отыгровки.
	{ACFF36}Текст отыгровки...
	{ACFF36}[2]=Текст{FFFFFF}	
	{ACFF36}Текст отыгровки...
	{ACFF36}{dialogEnd}{FFFFFF}		- конец структуры диалога
		]]
		local vt2 = [[
									{E45050}Особенности:
1. Имена диалога и вариантов задавать не обязательно, но 
рекомендуется для визуального понимания;
2. Можно создавать диалоги внутри диалогов, создавая 
конструкции внутри вариантов;
3. Можно использовать все выше перечисленные системы 
(переменные, комментарии, теги и т.п.)
		]]
		local vt3 = [[
{FFCD00}4. Использование тегов{FFFFFF}
Список тегов можно открыть в меню редактирования отыгровки или в разделе биндера.
Теги предназначены для автоматическеской замены на значение, которые они имеют.
Имеются два вида тегов:
1. Спростые теги - теги, которые просто заменяют себя на значение, которые они
постоянно имеют, например, {ACFF36}{myID}{FFFFFF} - возвращает Ваш текущий ID.
2. Тег-функция - специальные теги, которые требуют дополнительных параметров.
К ним относятся:
{ACFF36}{sleep:[время]}{FFFFFF} - Задаёт свой интервал времени между строчками. 
Время задаётся в миллисекундах. Пример: {ACFF36}{sleep:2000}{FFFFFF} - задаёт интервал в 2 сек
1 секунда = 1000 миллисекунд

{ACFF36}{sex:текст1|текст2}{FFFFFF} - Возвращает текст в зависимости от выбранного пола.
Больше предназначено, если создаётся отыгровка для публичного использования.
Где {6AD7F0}текст1{FFFFFF} - для мужской отыгровки, {6AD7F0}текст2{FFFFFF} - для женской. Разделяется вертикальной чертой.
Пример: {ACFF36}Я {sex:пришёл|пришла} сюда.

{ACFF36}{getNickByID:ид игрока}{FFFFFF} - Возращает ник игрока по его ID.
Пример: На сервере игрок {6AD7F0}Nick_Name{FFFFFF} с id - 25.
{ACFF36}{getNickByID:25}{FFFFFF} вернёт - {6AD7F0}Nick Name.
		]]
		imgui.TextColoredRGB(vt1)
		imgui.BeginGroup()
		imgui.TextDisabled(u8"					Пример")
		imgui.PushStyleColor(imgui.Col.FrameBg, imgui.ImColor(70, 70, 70, 200):GetVec4())
		imgui.InputTextMultiline("##dialogPar", helpd.exp, imgui.ImVec2(220, 180), 16384)
		imgui.PopStyleColor(1)
		imgui.TextDisabled(u8"Для копирования используйте\nCtrl + C. Вставка - Ctrl + V")
		imgui.EndGroup()
		imgui.SameLine()
		imgui.BeginGroup()
		imgui.TextColoredRGB(vt2)
		if imgui.Button(u8"Список клавиш", imgui.ImVec2(150,25)) then
			imgui.OpenPopup("helpdkey")
		end
		imgui.EndGroup()
		imgui.TextColoredRGB(vt3)
		if imgui.BeginPopup("helpdkey") then
			imgui.BeginChild("helpdkey", imgui.ImVec2(290,320))
				imgui.TextColoredRGB("{FFCD00}Кликните, чтобы скопировать")
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
		sampSendChat("Вы прийшли на собеседование?")
		wait(1700)
		sampSendChat("Предъявите пожалуйста Ваш пакет документов, а именно: паспорт, мед.карту и лицензии.")
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
					if dText:find("Лет в штате") and dText:find("Законопослушность") then
					HideDialogInTh()
					if dText:find("Организация") then
						sobes.player.work = "Работает"
					else
						sobes.player.work = "Без работы"
					end
						if dText:match("Имя: {FFD700}(%S+)") == sobes.player.name then
							sobes.player.let = tonumber(dText:match("Лет в штате: {FFD700}(%d+)"))
							sobes.player.zak = tonumber(dText:match("Законопослушность: {FFD700}(%d+)"))
							sampSendChat("/me посмотрел"..chsex("", "а").." информацию в паспорте, после чего отдал"..chsex("", "а").." его человеку напротив")
							if sobes.player.let >= 3 then
								if sobes.player.zak >= 35 then
									if not dText:find("{FF6200} "..list_org_BL[num_org.v+1]) then
										sobes.player.bl = "Не найден(а)"
										if sobes.player.narko == 0.1 then
											sampSendChat("Хорошо, теперь мед.карту.")
											wait(1700)
											sampSendChat("/n /showmc "..tostring(myid))
										elseif sobes.player.lic == "" then
											sampSendChat("Хорошо, теперь лицензии.")
											wait(1700)
											sampSendChat("/n /showlic "..tostring(myid))
										end
									else
										sampSendChat("Извиняюсь, но Вы нам не подходите.")
										wait(1700)
										sampSendChat("Вы состоите в Чёрном списке "..u8:decode(chgName.org[num_org.v+1]))
										sobes.player.bl = list_org_BL[num_org.v+1]
										return
									end
								else
									sampSendChat("Извиняюсь, но Вы нам не подходите.")
									wait(1700)
									sampSendChat("У Вас проблемы с законом.")
									wait(1700)
									sampSendChat("/n Необходимо законопослушнось 35+")
									wait(1700)
									sampSendChat("Приходите в следующий раз.")
									return
								end
							else
								sampSendChat("Извиняюсь, но Вы нам не подходите.")
								wait(1700)
								sampSendChat("Необходимо как минимум проживать 3 года в штате.")
								wait(1700)
								sampSendChat("Приходите в следующий раз.")
								return
							end
						end 
					end
					if dText:find("Наркозависимость") then
						HideDialogInTh()
						if dText:match("Имя: (%S+)") == sobes.player.name then
							sampSendChat("/me посмотрел"..chsex("", "посмотрела").." информацию в мед.карте, после чего отдал"..chsex("", "а").." его человеку напротив")
							sobes.player.narko = tonumber(dText:match("Наркозависимость: (%d+)"));
							if dText:find("Полностью здоровый") then
								if sobes.player.narko == 0 then
									sobes.player.heal = "Здоров"
									if sobes.player.zak == 0 then
										sampSendChat("Хорошо, теперь паспорт.")
										wait(1700)
										sampSendChat("/n /showpass "..tostring(myid))
									elseif sobes.player.lic == "" then
										sampSendChat("Хорошо, теперь лицензии.")
										wait(1700)
										sampSendChat("/n /showlic "..tostring(myid))
									end
								else
									sobes.player.heal = "Здоров"
									if sobes.player.zak == 0 then
										sampSendChat("Хорошо, ваш паспорт пожалуйста.")
										wait(1700)
										sampSendChat("/n /showpass "..tostring(myid))
									elseif sobes.player.lic == "" then
										sampSendChat("Хорошо, теперь лицензии.")
										wait(1700)
										sampSendChat("/n /showlic "..tostring(myid))
									end
								end
							else 
								sampSendChat("Извиняюсь, но У Вас проблемы со здоровьем.")
								wait(1700)
								sampSendChat("У Вас проблемы со здоровьем. Имеются психическое растройство.")
								sobes.player.heal = "Имеются отклонения"
							end
						end 
					end
					if dText:find("Лицензия на авто:") then
						HideDialogInTh()
						sampSendChat("/me посмотрел"..chsex("", "а").." лицензии, после чего отдал"..chsex("", "а").." его человеку напротив")
						if dText:find("{FFFFFF}Лицензия на авто: \t\t{10F441}Есть") then
							sobes.player.lic = "Есть";
						elseif dText:find("{FFFFFF}Лицензия на авто: \t\t{FF6347}Нет") then
							sobes.player.lic = "Нету";
						end
						if sobes.player.lic == "Есть" then
							if sobes.player.zak == 0 then
								sampSendChat("Хорошо, теперь паспорт.")
								wait(1700)
								sampSendChat("/n /showpass "..tostring(myid))
							elseif sobes.player.narko == 0.1 then
								sampSendChat("Хорошо, теперь мед.карту.")
								wait(1700)
								sampSendChat("/n /showmc "..tostring(myid))
							end
						else
							if sobes.player.zak == 0 then
								sampSendChat("Хорошо, теперь паспорт.")
								wait(1700)
								sampSendChat("/n /showpass "..tostring(myid))
							elseif sobes.player.narko == 0.1 then
								sampSendChat("Хорошо, теперь мед.карту.")
								wait(1700)
								sampSendChat("/n /showmc "..tostring(myid))
							end
						end
					end
				end
			end
		end
		wait(1700)
		if sobes.player.lic == "Нету" then
			sampSendChat("Извените, но у вас нету лицензии на вождение.")
			sobes.nextQ = false
			return
		elseif sobes.player.work == "Без работы" then
			sampSendChat("Отлично, у Вас всё в порядке с документами.")
			sobes.nextQ = true
			return
		else
			sampSendChat("Отлично, у Вас всё в порядке с документами.")
			wait(1700)
			sampSendChat("Но Вы работаете на другой государственной работе, требуется оставить форму своему работодателю.")
			wait(1700)
			sampSendChat("/n Увольтесь из работы, в который Вы сейчас состоите")
			wait(1700)
			sampSendChat("/n Уволиться с помощью команды /out при налчии Titan VIP или попросите в рацию.")
			sobes.nextQ = true
			return
		end
	end
	if id == 2 then
		sampSendChat("Теперь я задам Вам несколько вопросов.")
		wait(1700)
		sampSendChat("С какой целью Вы решили устроиться к нам в Больницу?")
	end
	if id == 3 then
		sampSendChat("У вас есть опыт в данной сфере?")
	end
	if id == 4 then
	sampSendChat("Отлично, Вы приняты к нам на работу.")
	sobes.nextQ = false
		if num_rank.v+1 <= 8 then
			wait(1700)
			sampSendChat("Подойдите, пожалуйста, к Зам.Главного врача или Главному врачу")
			sobes.input.v = ""
			sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", lic = "", narko = 0.1}
			sobes.selID.v = ""
			sobes.nextQ = false
			sobes.num = 0
		else
			wait(1700)
			sampSendChat("Сейчас я выдам Вам ключи от шкафчика с формой и другими вещами.")
			wait(1700)
			sampSendChat("/do В кармане халата находятся ключи отшкафчиков.")
			wait(1700)
			sampSendChat("/me потянувшись во внутренний карман халата, достал"..chsex("", "а").." оттуда ключ.")
			wait(1700)
			sampSendChat("/me передал"..chsex("", "а").." ключ от шкафчика №"..sobes.selID.v.." с формой Интерна человеку напротив.")
			wait(1700)
			sampSendChat("/invite "..sobes.selID.v)
			wait(1700)
			sampSendChat("/r Гражданину с порядковым номером №"..sobes.selID.v.." была выдана форма с ключами и пропуском.")
			sobes.input.v = ""
			sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", lic = "", narko = 0.1}
			sobes.selID.v = ""
			sobes.nextQ = false
			sobes.num = 0
		end
	end
	if id == 5 then
		wait(1700)
		sampSendChat("Извиняюсь, но у Вас отпечатка в паспорте")
		wait(1700)
		sampSendChat("/n НонРП ник или другая причина.")
		sobes.input.v = ""
		sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", lic = "", narko = 0.1}
		sobes.selID.v = ""
		sobes.nextQ = false
		sobes.num = 0
	end
	if id == 6 then
		wait(1700)
		sampSendChat("Извиняюсь, но требуется проживать в штате как минимум 3 года.")
		sobes.input.v = ""
		sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", lic = "", narko = 0.1}
		sobes.selID.v = ""
		sobes.nextQ = false
		sobes.num = 0
	end
	if id == 7 then
		wait(1700)
		sampSendChat("Извиняюсь, но у Вас проблемы с законом.")
		wait(1700)
		sampSendChat("/n Требуется минимум 35 законопослушности.")
		sobes.input.v = ""
		sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", lic = "", narko = 0.1}
		sobes.selID.v = ""
		sobes.nextQ = false
		sobes.num = 0
	end
	if id == 8 then
		wait(1700)
		sampSendChat("Извиняюсь, Вы работаете на другой государственной работе.")
		wait(1700)
		sampSendChat("/n Увольтесь из работы, в который Вы сейчас состоите")
		wait(1700)
		sampSendChat("/n Уволиться с помощью команды /out при налчии Titan VIP или попросите в рацию.")
		sobes.input.v = ""
		sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", lic = "", narko = 0.1}
		sobes.selID.v = ""
		sobes.nextQ = false
		sobes.num = 0
	end
	if id == 9 then
		wait(1700)
		sampSendChat("Извиняюсь, но Вы состоите в Черном Списке нашей больнице.")
		wait(1700)
		sampSendChat("/n Для вынесения из ЧС требуется оставить заявку на форуме в разделе Мин.Здрав.")
		sobes.input.v = ""
		sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", lic = "", narko = 0.1}
		sobes.selID.v = ""
		sobes.nextQ = false
		sobes.num = 0
	end
	if id == 10 then
		wait(1700)
		sampSendChat("Извиняюсь, но у Вас проблемы со здоровьем.")
		sobes.input.v = ""
		sobes.player = {name = "", let = 0, zak = 0, work = "", bl = "", heal = "", lic = "", narko = 0.1}
		sobes.selID.v = ""
		sobes.nextQ = false
		sobes.num = 0
	end
	if id == 11 then
		wait(1700)
		sampSendChat("Извиняюсь, но у Вас имеется наркозависимость.")
		wait(1700)
		sampSendChat("Для лечения этого можете купить таблетку в магазине или вылечиться у нас.")
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
		sampAddChatMessage("{FFFFFF}["..script_names.."]: В данный момент проигрывается отыгровка.", 0xEE4848)
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
			sampAddChatMessage("{FFFFFF}["..script_names.."]: Файл с текстом бинда не обнаружен. ", 0xEE4848)
		elseif #tb.debug.close > 0 then
			sampAddChatMessage("{FFFFFF}["..script_names.."]: Диалог, начало которого является строка №"..tb.debug.close[#tb.debug.close]..", не закрыт тегом {dialogEnd}", 0xEE4848)
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
					local len = renderGetFontDrawTextLength(font, "{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить")
					while true do
						wait(0)
						if not isGamePaused() then
							renderFontDrawText(font, "Ожидание...\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить", sx-len-10, sy-60, 0xFFFFFFFF)
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
    local search, name = findFirstFile("moonloader/MedicalHelper/Шпаргалки/*.txt")
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
				sampAddChatMessage("{FFFFFF}[{EE4848}MH:Ошибка{FFFFFF}]: Параметр {getNickByID:ID} не смог вернуть ник игрока. Возможно игрок не в сети.", 0xEE4848)
				par = par:gsub(v,"")
			end
		end
	end
	if par:find("{sex:[%w%sа-яА-Я]*|[%w%sа-яА-Я]*}") then	
		for v in par:gmatch("{sex:[%w%sа-яА-Я]*|[%w%sа-яА-Я]*}") do
			local m, w = v:match("{sex:([%w%sа-яА-Я]*)|([%w%sа-яА-Я]*)}")
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
			sampAddChatMessage("{FFFFFF}[{EE4848}MH:Ошибка{FFFFFF}]: Параметр {getNickByTarget} не смог вернуть ник игрока. Возможно Вы не целились на игрока, либо он не в сети.", 0xEE4848)
			par = par:gsub("{getNickByTarget}", tostring(""))
		end
	end
	return par
end

funCMD = {} 
function funCMD.lec(id)
	if thread:status() ~= "dead" then
		sampAddChatMessage("{FFFFFF}["..script_names.."]: В данный момент проигрывается отыгровка.", 0xEE4848)
		return
	end
	if not u8:decode(buf_nick.v):find("[а-яА-Я]+%s[а-яА-Я]+") then
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Подождите-ка, сначала нужно заполнить базовую информацию. {90E04E}/mh > Настройки > Основная информация", 0xEE4848)
		return
	end
	if id:find("%d+") then
		if GetPlayerDistance(id) or id == tostring(myid) then
			thread = lua_thread.create(function()
				if id ~= tostring(myid) then
					sampSendChat(string.format("Я, %s - %s.", tostring(u8:decode(chgName.rank[num_rank.v+1])), u8:decode(buf_nick.v)))
					wait(1700)
					sampSendChat("Вижу вам плохо, сейчас постараюсь вам чем-то помочь!")
					wait(1700)
				end
				sampSendChat("/do Cумка весит на плече правой руки.")
				wait(1700)
				sampSendChat("/me правой рукой расстегнул"..chsex("", "а").." медицинскую сумку и достал"..chsex("", "а").." нужное лекарство")
				wait(1700)
				if id ~= tostring(myid) then
					sampSendChat("/todo Вот, держите*передавая лекарство человеку напротив")
					wait(1700)
				end
				sampSendChat("/heal "..id.." "..buf_lec.v)
				wait(1700)
				if id ~= tostring(myid) then
					sampSendChat("Вот принимайте эти таблетки, и через некоторое время вам станет лучше")
				end
			end)
		else
			sampAddChatMessage("{FFFFFF}["..script_names.."]: Этого человек нету около вас.", 0xEE4848)
		end
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Используйте команду /hl [id игрока].", 0xEE4848)
	end
end
function funCMD.med(id)
	if thread:status() ~= "dead" then
		return sampAddChatMessage("{FFFFFF}["..script_names.."]: В данный момент проигрывается отыгровка.", 0xEE4848)
	end
	if not u8:decode(buf_nick.v):find("[а-яА-Я]+%s[а-яА-Я]+") then
		return sampAddChatMessage("{FFFFFF}["..script_names.."]: Подождите-ка, сначала нужно заполнить базовую информацию. {90E04E}/mh > Настройки > Основная информация", 0xEE4848)
	end
	if num_rank.v+1 < 3 then
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Данная команда Вам недоступна. Поменяйте должность в настройках скрипта, если это требуется.", 0xEE4848)
		return
	end
	if id:find("%d+") then
		if GetPlayerDistance(id) then
			thread = lua_thread.create(function()
				sampSendChat(string.format("Я, %s - %s.", tostring(u8:decode(chgName.rank[num_rank.v+1])), u8:decode(buf_nick.v)))
				wait(1700)
				sampSendChat("Вы хотите получить медицинскую карту впервые или обновить существующую?")
				wait(1700)
				sampSendChat("Предоставьте, пожалуйста, Ваш паспорт")
				wait(1700)
				sampSendChat("/n /showpass "..tostring(myid))
				wait(1700)
				sampAddChatMessage("{FFFFFF}["..script_names.."]: Нажмите на цифру верхней панели для выбора вида мед.услуги.", 0xEE4848)
				addOneOffSound(0, 0, 0, 1058)
				local len = renderGetFontDrawTextLength(font, "Выдача мед.карты: {8ABCFA}Статус")
				while true do
					wait(0)
					renderFontDrawText(font, "Выдача мед.карты: {8ABCFA}Статус\n{FFFFFF}[{67E56F}1{FFFFFF}] - Выдача новой\n[{67E56F}2{FFFFFF}] - Обновление", sx-len-10, sy-80, 0xFFFFFFFF)
					if isKeyJustPressed(VK_1) and not sampIsChatInputActive() and not sampIsDialogActive() then 
						sampSendChat("Хорошо, я Вас понял"..chsex("", "а")..". Вам нужно оформить новую мед.карту.")
						wait(1700)
						sampSendChat("Для оформления карты необходимо мне узнать на сколько дней вам нужна мед.карта.")
						break
					end
					if isKeyJustPressed(VK_2) and not sampIsChatInputActive() and not sampIsDialogActive() then 
						sampSendChat("Хорошо, я Вас понял"..chsex("", "а")..". Вам нужно обновить данные в мед.карте.")
						wait(1700)
						sampSendChat("Для обновления данных необходимо мне узнать на сколько дней вам нужна мед.карта.")
						break
					end
				end
				wait(1700)
				sampSendChat("На 7 дней - "..buf_medcard1.v.."$, на 14 дней - "..buf_medcard2.v.."$")
				wait(1700)
				sampSendChat("На 30 дней - "..buf_medcard3.v.."$, на 60 дней - "..buf_medcard4.v.."$.")
				wait(1700)
				sampSendChat("/n Оплачивать не требуется, сервер сам предложит")
				addOneOffSound(0, 0, 0, 1058)
				local len = renderGetFontDrawTextLength(font, "Выдача мед.карты: {8ABCFA}Срок мед.карты")
				while true do
					wait(0)
					renderFontDrawText(font, "Выдача мед.карты: {8ABCFA}Срок мед.карты\n{FFFFFF}[{67E56F}1{FFFFFF}] - 7 дней\n[{67E56F}2{FFFFFF}] - 14 дней\n[{67E56F}3{FFFFFF}] - 30 дней\n[{67E56F}4{FFFFFF}] - 60 дней", sx-len-10, sy-120, 0xFFFFFFFF)
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
				sampSendChat("Хорошо, тогда приступим к оформлению.")
				wait(1700)
				sampSendChat("/me вытащил"..chsex("", "а").." из нагрудного кармана шариковую ручку")
				wait(1700)
				sampSendChat("/do Ручка в правой руке.")
				wait(1700)
				sampSendChat("/me открыл"..chsex("", "а").." шкафчик, достал"..chsex("", "а").." оттуда пустые бланки для мед.карты")
				wait(1700)
				sampSendChat("/me разложил"..chsex("", "а").." пальцами правой руки паспорт на нужной страничке и начал"..chsex("", "начаала").." переписывать данные в бланк")
				wait(1700)
				sampSendChat("/me открыл"..chsex("", "а").." пустую мед.карту и паспорт, затем начал"..chsex("", "а").." переписывать данные из паспорта")
				wait(1700)
				sampSendChat("/do Спустя минуту данные паспорта были переписаны на бланк.")
				wait(1700)
				sampSendChat("/me отложил"..chsex("", "а").." паспорт в сторону его хозяина и "..chsex("приготовился", "приготовилась").." к продолжению занесения информации")
				wait(1700)
				sampSendChat("Так, сейчас задам несколько вопросов касаемо здоровья...")
				wait(1700)
				sampSendChat("Жалобы на здоровье имеются?")
				local len = renderGetFontDrawTextLength(font, "Выдача мед.карты: {8ABCFA}Ответ человека")
				while true do
					wait(0)
					renderFontDrawText(font, "Выдача мед.карты: {8ABCFA}Ответ человека\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить", sx-len-10, sy-55, 0xFFFFFFFF)
					if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then
						break
					end
				end
				sampSendChat("Имеются ли вредные привычки, а также аллергические реакции?")
				while true do
					wait(0)
					renderFontDrawText(font, "Выдача мед.карты: {8ABCFA}Ответ человека\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить", sx-len-10, sy-55, 0xFFFFFFFF)
					if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then
						break
					end
				end
				sampSendChat("/me записал"..chsex("", "а").." все сказанное пациентом в мед.карту")
				local len = renderGetFontDrawTextLength(font, "Выдача мед.карты: {8ABCFA}Псих. состояние")
				addOneOffSound(0, 0, 0, 1058)
				while true do
					wait(0)
					renderFontDrawText(font, "Выдача мед.карты: {8ABCFA}Псих. состояние\n{FFFFFF}[{67E56F}0{FFFFFF}] - Не определен\n[{67E56F}1{FFFFFF}] - Полноcтью здоров(ая)\n[{67E56F}2{FFFFFF}] - Наблюдаются отклоненияются\n[{67E56F}3{FFFFFF}] - Психически не здоров(ая)", sx-len-10, sy-125, 0xFFFFFFFF)
					if isKeyJustPressed(VK_0) and not sampIsChatInputActive() and not sampIsDialogActive() then
						heal = 0;
						sampSendChat("/me сделал"..chsex("", "а").." запись напротив пункта 'Псих. Здоровье.' - 'Не определен(ая).'")
						break
					end	
					if isKeyJustPressed(VK_1) and not sampIsChatInputActive() and not sampIsDialogActive() then
						heal = 3;
						sampSendChat("/me сделал"..chsex("", "а").." запись напротив пункта 'Псих. Здоровье.' - 'Полностью здоров(ая).'")
						break
					end				
					if isKeyJustPressed(VK_2) and not sampIsChatInputActive() and not sampIsDialogActive() then
						heal = 2;
						sampSendChat("/me сделал"..chsex("", "а").." запись напротив пункта 'Псих. Здоровье.' - 'Имеются отклонения.'")
						break
					end				
					if isKeyJustPressed(VK_3) and not sampIsChatInputActive() and not sampIsDialogActive() then
						heal = 1;
						sampSendChat("/me сделал"..chsex("", "а").." запись напротив пункта 'Псих. Здоровье.' - 'Псих. нездоров(ая).'")
						break
					end
				end
				sampSendChat("/me взял"..chsex("", "а").." штамп "..tostring(u8:decode(list_org_en[num_org.v+1])).." в правую руку из ящика стола и нанес"..chsex("", "ла").." оттиск в углу бланка")
				wait(1700)
				sampSendChat("/do Печать нанесена.")			
				wait(1700)
				sampSendChat("/me отложив штамп в сторону и поставил"..chsex("", "а").." свою подпись, и сегодняшнюю дату")			
				wait(1700)
				sampSendChat("/do Страница мед.карты заполнена.")	
				wait(1700)
				sampSendChat("Всё готово, держите свою мед.карту, не болейте.")	
				wait(1700)
				sampSendChat("Удачного дня.")
				wait(1700)
				sampSendChat("/medcard "..id.." "..heal.." "..time.." "..money)
			end)
		else
			sampAddChatMessage("{FFFFFF}["..script_names.."]: Этого человек нету около вас.", 0xEE4848)
		end
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Используйте команду: /mc [id игрока].", 0xEE4848)
	end
end
function funCMD.narko(id)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}["..script_names.."]: В данный момент проигрывается отыгровка.", 0xEE4848)
		return 
	end
	if num_rank.v+1 < 4 then
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Данная команда Вам недоступна. Поменяйте должность в настройках скрипта, если это требуется.", 0xEE4848)
		return
	end
	if id:find("(%d+)") then
		if GetPlayerDistance(id) then
			thread = lua_thread.create(function()
				sampSendChat(string.format("Я, %s - %s.", tostring(u8:decode(chgName.rank[num_rank.v+1])), u8:decode(buf_nick.v)))
				wait(1700)
				sampSendChat("Смотрю, Вы решили излечиться от наркозависимости, это хорошо")
				wait(1700)
				sampSendChat("Стоимость сеанса составляет "..buf_narko.v.."$, Вы согласны?")
				wait(1700)
				sampSendChat("/n Оплачивать не требуется, сервер сам предложит")
				wait(1700)
				sampSendChat("Если Вы согласны, садитесь на кушетку и закатайте рукав")
				wait(1700)
				sampSendChat("/do На столе лежит ватка, жгут и шприц с вакциной.")
				wait(1700)
				sampSendChat("/me взял".. chsex("", "а") .." со стола жгут")
				wait(1700)
				sampSendChat("/me затянул".. chsex("", "а") .." жгут на плече пациента")
				wait(1700)
				sampSendChat("/do Жгут сильно затянут.")
				wait(1700)
				sampSendChat("Работайте кулаком.")
				wait(1700)
				sampSendChat("/me взял".. chsex("", "а") .." ватку и смочил".. chsex("", "а") .." её спиртом")
				wait(1700)
				sampSendChat("/me протёр".. chsex("", "ла") .." ваткой локтевой изгиб")
				wait(1700)
				sampSendChat("/todo Не волнуйтесь,будет не больно*взял".. chsex("", "а") .." со стола шприц с вакциной")
				wait(1700)
				sampSendChat("/me плавным движением правой руки делает укол")
				wait(1700)
				sampSendChat("/healbad "..id)
				wait(1700)
				sampSendChat("/todo Держите ватку*положив ватку на место укола")
				wait(1700)
				sampSendChat("/me снял".. chsex("", "а") .." жгут и положил".. chsex("", "а") .." его на стол")
				wait(1700)
				sampSendChat("/me выкинул".. chsex("", "а") .." шприц в специальную урну")
				wait(1700)
				sampSendChat("Всего Вам доброго.")
			end)
		else
			sampAddChatMessage("{FFFFFF}["..script_names.."]: Этого человек нету около вас.", 0xEE4848)
		end
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Используйте команду /narko [id игрока].", 0xEE4848)
	end
end
function funCMD.rec(id)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}["..script_names.."]: В данный момент проигрывается отыгровка.", 0xEE4848)
		return 
	end
	if num_rank.v+1 < 4 then
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Данная команда Вам недоступна. Поменяйте должность в настройках скрипта, если это требуется.", 0xEE4848)
		return
	end
	if id:find("(%d+)") then
		if GetPlayerDistance(id) then
			thread = lua_thread.create(function()
				sampSendChat(string.format("Я, %s - %s.", tostring(u8:decode(chgName.rank[num_rank.v+1])), u8:decode(buf_nick.v)))
				wait(1700)
				sampSendChat("Вам нужен рецепт?")
				wait(1700)
				sampSendChat("Хорошо, стоимость одного рецепта "..buf_rec.v.."$.")
				wait(1700)
				sampSendChat("Скажите сколько Вам требуется рецептов, после чего мы продолжим.")
				wait(1700)
				sampSendChat("/n Внимание! В течении часа выдаётся максимум 5 рецептов на руки.")
				wait(500)
				sampAddChatMessage("{FFFFFF}["..script_names.."]: Нажмите на цифру верхней цифровой панели равная количеству выдаваемых рецептов.", 0xEE4848)
				local len = renderGetFontDrawTextLength(font, "Выдача рецептов: {8ABCFA}Выбор кол-ва")
				while true do
				wait(0)
					renderFontDrawText(font, "Выдача рецептов: {8ABCFA}Выбор кол-ва\n{FFFFFF}[{67E56F}1{FFFFFF}] - 1 шт.\n{FFFFFF}[{67E56F}2{FFFFFF}] - 2 шт.\n{FFFFFF}[{67E56F}3{FFFFFF}] - 3 шт.\n{FFFFFF}[{67E56F}4{FFFFFF}] - 4 шт.\n{FFFFFF}[{67E56F}5{FFFFFF}] - 5 шт.", sx-len-10, sy-150, 0xFFFFFFFF)					
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
				sampSendChat("/do На плече весит мед. сумка.")
				wait(1700)
				sampSendChat("/me снял".. chsex("", "а") .." мед. сумку с плеча, после чего открыл".. chsex("", "а") .." ее")
				wait(1700)
				sampSendChat("/me достал"..chsex("", "а").." бланки")
				wait(1700)
				sampSendChat("/me заполняет бланки на оформление лекарств")
				wait(1700)
				sampSendChat("/do Бланки заполнены.")
				wait(1700)
				sampSendChat("/me поставил".. chsex("", "а") .." печать "..u8:decode(chgName.org[num_org.v+1]))
				wait(1700)
				sampSendChat("/me оформил"..chsex("", "а").." рецепт")
				wait(1700)
				sampSendChat("/me закрыл".. chsex("", "а") .." мед. сумку")
				wait(1700)
				sampSendChat("/me повесил"..chsex("", "а").." мед. сумку на плечо")
				wait(1700)
				sampSendChat("/do Мед. сумка на плече.")
				wait(1700)
				sampSendChat("/recept "..id.." "..countRec)
				sampSendChat("Вот Ваши рецепты, всего доброго.")
			end)
		else
			sampAddChatMessage("{FFFFFF}["..script_names.."]: Этого человек нету около вас.", 0xEE4848)
		end
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Используйте команду /rec [id игрока].", 0xEE4848)
	end
end
function funCMD.tatu(id)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}["..script_names.."]: В данный момент проигрывается отыгровка.", 0xEE4848)
		return 
	end
	if num_rank.v+1 < 7 then
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Данная команда Вам недоступна. Поменяйте должность в настройках скрипта, если это требуется.", 0xEE4848)
		return
	end
	if id:find("(%d+)") then
		if GetPlayerDistance(id) then
			thread = lua_thread.create(function()
				sampSendChat(string.format("Я, %s - %s.", tostring(u8:decode(chgName.rank[num_rank.v+1])), u8:decode(buf_nick.v)))
				wait(1700)
				sampSendChat("Вы по поводу сведения татуировки?")
				wait(3000)
				sampSendChat("Покажите Ваш паспорт, пожалуйста.")
				wait(1700)
				local len = renderGetFontDrawTextLength(font, "Сведение тату: {8ABCFA}Паспорт")
				while true do
				wait(0)
					renderFontDrawText(font, "Сведение тату: {8ABCFA}Паспорт\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить", sx-len-10, sy-60, 0xFFFFFFFF)
					if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then
						break
					end
				end
				sampSendChat("/me принял"..chsex("", "а").." с рук обратившегося паспорт")
				wait(1700)
				sampSendChat("/do Паспорт обратившегося в правой руке.")
				wait(1700)
				sampSendChat("/me ознакомившись с паспортом обратившегося, вернул"..chsex("", "а").." его обратно")
				wait(1700)
				sampSendChat("Стоимость выведения татуировки составит "..buf_tatu.v.."$, Вы согласны?")
				wait(1700)
				sampSendChat("/n Оплачивать не требуется, сервер сам предложит")
				wait(1700)
				sampSendChat("/n Покажите татуировки с помощью команды /showtatu")
				addOneOffSound(0, 0, 0, 1058)
				local len = renderGetFontDrawTextLength(font, "Сведение тату: {8ABCFA}Соглашение")
				while true do
				wait(0)
					renderFontDrawText(font, "Сведение тату: {8ABCFA}Соглашение\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить", sx-len-10, sy-60, 0xFFFFFFFF)
					if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then
						break
					end
				end
				sampSendChat("Я смотрю, вы готовы, тогда снимайте с себя рубашку, чтоб я вывел"..chsex("", "а").." вашу татуировку.")
				wait(1700)
				sampSendChat("/do У стены стоит инструментальный столик с подносом.")
				wait(1700)
				sampSendChat("/do Аппарат для выведения тату на подносе.")
				wait(1700)
				sampSendChat("/me взял"..chsex("", "а").." аппарат для выведения татуировки с подноса")
				wait(1700)
				sampSendChat("/me осмотрев пациента, "..chsex("принялся", "принялась").." выводить его татуировку")
				wait(1700)
				sampSendChat("/unstuff "..id.." "..buf_tatu.v)
				wait(5000)
				sampSendChat("Всё, ваш сеанс закончен. Всего Вам хорошего!?")
			end)
		else
			sampAddChatMessage("{FFFFFF}["..script_names.."]: Этого человек нету около вас.", 0xEE4848)
		end
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Используйте команду /tatu [id игрока].", 0xEE4848)
	end	
end
function funCMD.antb(id)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}["..script_names.."]: В данный момент проигрывается отыгровка.", 0xEE4848)
		return 
	end
	if num_rank.v+1 < 4 then
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Данная команда Вам недоступна. Поменяйте должность в настройках скрипта, если это требуется.", 0xEE4848)
		return
	end
	if id:find("(%d+)") then
		if GetPlayerDistance(id) then
			thread = lua_thread.create(function()
				sampSendChat(string.format("Я, %s - %s.", tostring(u8:decode(chgName.rank[num_rank.v+1])), u8:decode(buf_nick.v)))
				wait(1700)
				sampSendChat("Вы хотите купить антибиотики?")
				wait(1700)
				sampSendChat("Цена антибиотика "..buf_antb.v.." за шт.")
				wait(1700)
				sampSendChat("Покажите мне вашу мед. карту и я вам скажу сколько вам нужно")
				wait(1700)
				sampSendChat("/n /showmc "..tostring(myid))
				sampAddChatMessage("{FFFFFF}["..script_names.."]: Вы можете пропустить осмотр мед карты (по стандарту будет ставится 5 антибиотиков).", 0xEE4848)
				local len = renderGetFontDrawTextLength(font, "Выдача антибиотиков: {8ABCFA}Пропустить")
				while true do
				wait(0)
					renderFontDrawText(font, "Выдача антибиотиков: {8ABCFA}Пропустить\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить", sx-len-10, sy-60, 0xFFFFFFFF)
					if sampIsDialogActive() then
						local dId = sampGetCurrentDialogId()
						if dId == 1234 then
							local dText = sampGetDialogText()
							if dText:find("Коронавирус:") then
								tempcountAntb = tonumber(dText:match("Коронавирус: %d/100"))/3
								countAntb = tempcountAntb+1
								HideDialogInTh()
								sampSendChat("Я так вижу вам нужно "..countAntb)
								break
							else
								HideDialogInTh()
								sampSendChat("Извините но у вас нету коронавируса, и я не могу вам просто так продать их!")
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
				sampSendChat("/do Рецепты на антибиотик находятся в сумке у врача.")
				wait(1700)
				sampSendChat("/me достал"..chsex("", "а").." рецепт из сумки")
				wait(1700)
				sampSendChat("/do Рецепты в руках.")
				wait(1700)
				sampSendChat("/me поставил"..chsex("", "а").." печати")
				wait(1700)
				sampSendChat("/antibiotik "..id.." "..countAntb)
				wait(1700)
				sampSendChat("/todo Держите ваши рецепты*передавая человеку напроти")
				wait(1700)
				sampSendChat("Пейте их каждые 5 минут, и вы вылечитесь от COVID-19.")
				wait(1700)
				sampSendChat("А после приходите на вакцинацию.")
			end)
		else
			sampAddChatMessage("{FFFFFF}["..script_names.."]: Этого человек нету около вас.", 0xEE4848)
		end
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Используйте команду /antb [id игрока].", 0xEE4848)
	end	
end
function funCMD.cur(id)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}["..script_names.."]: В данный момент проигрывается отыгровка.", 0xEE4848)
		return 
	end
	if num_rank.v+1 < 4 then
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Данная команда Вам недоступна. Поменяйте должность в настройках скрипта, если это требуется.", 0xEE4848)
		return
	end
	if id:find("(%d+)") then
		if GetPlayerDistance(id) then
			thread = lua_thread.create(function()
				sampSendChat("/todo Что-то ему вообще не хорошо*снимая медицинскую сумку с плеча")
				wait(1700)
				sampSendChat("/me ставит медицинскую сумку возле пострадавшего")
				wait(1700)
				sampSendChat("/do Мед. сумка на земле.")
				wait(1700)
				sampSendChat("/me наклоняется над телом, затем прощупывает пульс на сонной артерии")
				wait(1700)
				sampSendChat("/do Пульс слабый.")
				wait(1700)
				sampSendChat("/me начинает непрямой массаж сердца, время от времени проверяя пульс")
				wait(1700)
				sampSendChat("/cure "..id)
				wait(1700)
				sampSendChat("/do Сердце пациента начало биться.")
			end)
		else
			sampAddChatMessage("{FFFFFF}["..script_names.."]: Этого человек нету около вас.", 0xEE4848)
		end
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Используйте команду /cur [id игрока].", 0xEE4848)
	end	
end
function funCMD.minsur(id)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}["..script_names.."]: В данный момент проигрывается отыгровка.", 0xEE4848)
		return 
	end
	if num_rank.v+1 < 4 then
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Данная команда Вам недоступна. Поменяйте должность в настройках скрипта, если это требуется.", 0xEE4848)
		return
	end
	if id:find("(%d+)") then
		if GetPlayerDistance(id) then
			thread = lua_thread.create(function()
				sampSendChat(string.format("Я, %s - %s.", tostring(u8:decode(chgName.rank[num_rank.v+1])), u8:decode(buf_nick.v)))
				wait(1700)
				sampSendChat("Вы хотите оформить страховку?")
				wait(1700)
				sampSendChat("Тогда мне понадобится ваш паспорт и мед.карта.")
				sampAddChatMessage("{FFFFFF}["..script_names.."]: Нажмите на  {23E64A}Enter{FFFFFF} для продолжения или {23E64A}Page Down{FFFFFF}, чтобы закончить диалог.", 0xEE4848)
				addOneOffSound(0, 0, 0, 1058)
				local len = renderGetFontDrawTextLength(font, "Выдача страховки: {8ABCFA}Соглашение")
				while true do
				wait(0)
					renderFontDrawText(font, "Выдача страховки: {8ABCFA}Соглашение\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить.", sx-len-10, sy-60, 0xFFFFFFFF)
					if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then
						break
					end
				end
				sampSendChat("/todo Благодарю*взяв документы и открыв их на нужной странице")
				wait(1700)
				sampSendChat("Первый раз оформляете страховку?")
				wait(1700)
				sampSendChat("Пока заполняю документы объясню суть страховки.")
				wait(1700)
				sampSendChat("Вы можете бесплатно проходить обследования, лечения у врачей.")
				wait(1700)
				sampSendChat("/n лечение от врачей + лечение на метке происходит бесплатно!")
				wait(1700)
				sampSendChat("/do Читает информацию с документов.")
				wait(1700)
				sampSendChat("/me открыв шкафчик достал от туда готовый бланк полиса ОМС.")
				wait(1700)
				sampSendChat("/do На столе лежит ручка.")
				wait(1700)
				sampSendChat("/me схватился за ручку на столе и начал записывать информацию в бланк с документов.")
				wait(1700)
				sampSendChat("На какой период вы хотите оформить страховку.")
				wait(1700)
				sampSendChat("От срока зависит цена:")
				wait(1700)
				sampSendChat("1 неделя - 400.000")
				wait(1700)
				sampSendChat("2 недели - 800.000")
				wait(1700)
				sampSendChat("3 недели - 1.200.000")
				addOneOffSound(0, 0, 0, 1058)
				local len = renderGetFontDrawTextLength(font, "Выдача страховки: {8ABCFA}Выбор срока")
				while true do
				wait(0)
					renderFontDrawText(font, "Выдача страховки: {8ABCFA}Выбор срока\n{FFFFFF}[{67E56F}1{FFFFFF}] - 1 неделю.\n{FFFFFF}[{67E56F}2{FFFFFF}] - 2 недели.\n{FFFFFF}[{67E56F}3{FFFFFF}] - 3 недели.", sx-len-10, sy-90, 0xFFFFFFFF)					
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
				sampSendChat("/todo Хорошо*записывая информацию в бланк.")
				wait(1700)
				sampSendChat("/me записав всю информацию в бланк достал печать из шкафчика.")
				wait(1700)
				sampSendChat("/me открыв защитную крышку нанес печать на д.окумент.")
				wait(1700)
				sampSendChat("/do На документе печать "..tostring(u8:decode(list_org_en[num_org.v+1]))..".")
				wait(1700)
				sampSendChat("/todo Ваша страховка готова, прошу*передавая документ человеку напротив.")
				wait(1700)
				sampAddChatMessage("{FFFFFF}["..script_names.."]: Игрок выбрал на "..week.." недель цена составляет "..cost.."$", 0xEE4848)
				wait(1700)
				sampSendChat("/givemedinsurance "..id)
				wait(1700)
				sampSendChat("Удачного дня и не болейте")
			end)
		else
			sampAddChatMessage("{FFFFFF}["..script_names.."]: Этого человек нету около вас.", 0xEE4848)
		end
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Используйте команду /minsur [id игрока].", 0xEE4848)
	end	
end
function funCMD.vc(id)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}["..script_names.."]: В данный момент проигрывается отыгровка.", 0xEE4848)
		return 
	end
	if num_rank.v+1 < 3 then
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Данная команда Вам недоступна. Поменяйте должность в настройках скрипта, если это требуется.", 0xEE4848)
		return
	end
	if id:find("(%d+)") then
		if GetPlayerDistance(id) then
			if Vaccine[3] == id or Vaccine[3] == -1 then
				if Vaccine[2] == 0 then
					thread = lua_thread.create(function()
						if Vaccine[1] ~= 1 then
							sampSendChat(string.format("Я, %s - %s.", tostring(u8:decode(chgName.rank[num_rank.v+1])), u8:decode(buf_nick.v)))
							wait(1700)
							sampSendChat("Вы пришли на вакцинацию?")
							wait(1700)
							sampSendChat("В общей сумме стоимость вакцинирования составляет 150.000$")
							wait(1700)
							sampSendChat("/n Оплачивать не требуется, сервер сам предложит")
							wait(1700)
							sampSendChat("Хорошо, передайте мне пожалуйста вашу мед.карту.")
							wait(1700)
							sampSendChat("/n /showmc "..tostring(myid))
							wait(1700)
							while true do
							wait(0)
								if sampIsDialogActive() then
									local dId = sampGetCurrentDialogId()
									if dId == 1234 then
										local dText = sampGetDialogText()
										if dText:find("Коронавирус:") then
											HideDialogInTh()
											sampSendChat("/todo Благодарю*взяв мед.карту и открыв её на нужной странице")
											wait(1700)
											sampSendChat("Извините но у вас коронавирус!")
											wait(1700)
											sampSendChat("Вы можете купить антибиотики в нашей больнице или на центрольном рынке!")
											return
										elseif dText:find("{31B404}Вакцина от коронавируса:\n Имеется") then
											HideDialogInTh()
											sampSendChat("/todo Благодарю*взяв мед.карту и открыв её на нужной странице")
											sampSendChat("Извините но у вас уже есть вакцина!")
											return
										else
											HideDialogInTh()
											sampSendChat("/todo Благодарю*взяв мед.карту и открыв её на нужной странице")
											break
										end
									end
								end
							end
							sampSendChat("/me достал"..chsex("", "а").." из мед.сумки шприц с вакциной, положил"..chsex("", "а").." его на стол")
							wait(1700)
							sampSendChat("/me просунул"..chsex("", "а").." руку в правый карман куртки достал"..chsex("", "а").." из него пару перчаток, затем одел"..chsex("", "а").." их")
							wait(1700)
							sampSendChat("/me достал"..chsex("", "а").." из левого кармана анти-септик, тщательно обработал"..chsex("", "а").." им руки")
							wait(1700)
							sampSendChat("/do В шприцу находиться нужная доза вакцины.")
							wait(1700)
							sampSendChat("/me снял"..chsex("", "а").." защитный колпачок, выдавил"..chsex("", "а").." воздух из шприца")
							wait(1700)
							sampSendChat("/me достал"..chsex("", "а").." из мед.сумки ватки и спирт, обмакнул ватку в спирт затем обработал"..chsex("", "а").." область укола")
							wait(1700)
							sampSendChat("/todo Сейчас не дёргайтесь, будет немного не приятно*смотря на область укола")
							wait(1700)
							sampSendChat("/me аккуратным движением руки ввёл"..chsex("", "а").." шприц в руку, затем вакцину")
							wait(1700)
							sampSendChat("/vaccine "..id)
							wait(1700)
							sampSendChat("/todo Вот и всё, держите ватку*передавая ватку человеку")
							wait(1700)
							sampSendChat("/todo выкинув"..chsex("", "а").." шприц в урну*Ждите 2 минуты прежде чем вводить вторую вакцину.")
							Vaccine = {1, 120, id}
							return
						elseif Vaccine[1] == 1 then
							sampSendChat("/do Медицинская сумка на плече.")
							wait(1700)
							sampSendChat("/me начал"..chsex("", "а").." доставать новый шприц с вакциной")
							wait(1700)
							sampSendChat("/do Шприц с вакциной в правой руке.")
							wait(1700)
							sampSendChat("/me аккуратно начинает вводить прививку человеку на против")
							wait(1700)
							sampSendChat("/do В шприцу находиться нужная доза вакцины.")
							wait(1700)
							sampSendChat("/vaccine "..id)
							wait(1700)
							sampSendChat("/do Вакцина введена.")
							wait(1700)
							sampSendChat("/me начал"..chsex("", "а").." убирать использованный шприц в сумку")
							wait(1700)
							sampSendChat("Могу Вас поздравить с успешным вакцинированием.")
							wait(1700)
							sampSendChat("Если будут жалобы на самочувствие – сразу же обратитесь к нам.")
							Vaccine = {0, 0, -1}
						end
					end)
				else
					sampAddChatMessage("{FFFFFF}["..script_names.."]: У этого игрока ещё не пройшёл час, осталось "..Vaccine[2].." сек.", 0xEE4848)
				end
			else
				sampAddChatMessage("{FFFFFF}["..script_names.."]: Вы ещё не закончили сеанс вакцинирование с "..tostring(sampGetPlayerNickname(Vaccine[3]):gsub("_", " ")).."", 0xEE4848)
				sampAddChatMessage("{FFFFFF}["..script_names.."]: Чтобы отменить сеанс вакцинирование /canclevc", 0xEE4848)
			end
		else
			sampAddChatMessage("{FFFFFF}["..script_names.."]: Этого человек нету около вас.", 0xEE4848)
		end
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Используйте команду /vc [id игрока].", 0xEE4848)
	end	
end
function funCMD.warn(text)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}["..script_names.."]: В данный момент проигрывается отыгровка.", 0xEE4848)
		return 
	end
	if num_rank.v+1 < 8 then
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Данная команда Вам недоступна. Поменяйте должность в настройках скрипта, если это требуется.", 0xEE4848)
		return
	end
	if text:find("(%d+)%s(%X+)") then
		local id, reac = text:match("(%d+)%s(%X+)")
		thread = lua_thread.create(function()
			sampSendChat("/do В левом кармане лежит КПК.")
			wait(1700)
			sampSendChat("/me достав КПК из левого кармана, после чего ".. chsex("зашёл", "зашла") .." в базу данных "..u8:decode(chgName.org[num_org.v+1]))
			wait(1700)
			sampSendChat("/me изменил"..chsex("", "а").." информацию о сотруднике.")
			wait(1700)
			sampSendChat("/fwarn "..id.." "..reac)
			wait(1700)
			sampSendChat("/r Сотруднику с бейджиком №"..id.." был выдан выговор по причине: "..reac)
		end)
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Используйте команду /+warn [id игрока] [причина].", 0xEE4848)
	end
end
function funCMD.uwarn(id)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}["..script_names.."]: В данный момент проигрывается отыгровка.", 0xEE4848)
		return 
	end
	if num_rank.v+1 < 8 then
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Данная команда Вам недоступна. Поменяйте должность в настройках скрипта, если это требуется.", 0xEE4848)
		return
	end
	if id:find("(%d+)") then
		thread = lua_thread.create(function()
			sampSendChat("/do В левом кармане лежит КПК.")
			wait(1700)
			sampSendChat("/me достав КПК из левого кармана, после чего ".. chsex("зашёл", "зашла") .." в базу данных "..u8:decode(chgName.org[num_org.v+1]))
			wait(1700)
			sampSendChat("/me изменил"..chsex("", "а").." информацию о сотруднике.")
			wait(1700)
			sampSendChat("/unfwarn "..id)
		end)
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Используйте команду /-warn [id игрока].", 0xEE4848)
	end
end
function funCMD.inv(id)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}["..script_names.."]: В данный момент проигрывается отыгровка.", 0xEE4848)
		return 
	end
	if num_rank.v+1 < 9 then
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Данная команда Вам недоступна. Поменяйте должность в настройках скрипта, если это требуется.", 0xEE4848)
		return
	end
	if id:find("(%d+)") then
		if GetPlayerDistance(id) then
			thread = lua_thread.create(function()
				sampSendChat("/do В кармане халата находятся ключи отшкафчиков.")
				wait(1700)
				sampSendChat("/me потянувшись во внутренний карман халата, достал"..chsex("", "а").." оттуда ключ.")
				wait(1700)
				sampSendChat("/me передал"..chsex("", "а").." ключ от шкафчика №"..id.." с формой человеку напротив.")
				wait(1700)
				sampSendChat("/invite "..id)
				wait(1700)
				sampSendChat("/r Гражданину с порядковым номером №"..id.." была выдана форма с ключами и пропуском.")
			end)
		else
			sampAddChatMessage("{FFFFFF}["..script_names.."]: Этого человек нету около вас.", 0xEE4848)
		end
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Используйте команду /inv [id игрока].", 0xEE4848)
	end
end
function funCMD.unv(text)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}["..script_names.."]: В данный момент проигрывается отыгровка.", 0xEE4848)
		return 
	end
	if num_rank.v+1 < 9 then
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Данная команда Вам недоступна. Поменяйте должность в настройках скрипта, если это требуется.", 0xEE4848)
		return
	end
	if text:find("(%d+)%s(%X+)") then
		local id, reac = text:match("(%d+)%s(%X+)")
		lua_thread.create(function()
			sampSendChat("/do В левом кармане лежит КПК.")
			wait(1700)
			sampSendChat("/me достав КПК из левого кармана, после чего ".. chsex("зашёл", "зашла") .." в базу данных "..u8:decode(chgName.org[num_org.v+1]))
			wait(1700)
			sampSendChat("/me изменил"..chsex("", "а").." информацию о сотруднике.")
			wait(1700)
			sampSendChat("/uninvite "..id.." "..reac)
			wait(1200)
			sampSendChat("/r Сотрудник с бейджиком №"..id.." был уволен по причине: "..reac)
		end)
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Используйте команду /unv [id игрока] [причина].", 0xEE4848)
	end
end
function funCMD.mute(text)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}["..script_names.."]: В данный момент проигрывается отыгровка.", 0xEE4848)
		return 
	end
	if num_rank.v+1 < 8 then
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Данная команда Вам недоступна. Поменяйте должность в настройках скрипта, если это требуется.", 0xEE4848)
		return
	end
	if text:find("(%d+)%s(%d+)%s(%X+)") then
		local id, timem, reac = text:match("(%d+)%s(%d+)%s(%X+)")
		thread = lua_thread.create(function()
			sampSendChat("/do Рация весит на поясе.")
			wait(1700)		
			sampSendChat("/me снял".. chsex("", "а") .." рацию с пояса")
			wait(1700)
			sampSendChat("/me ".. chsex("зашел", "зашёл") .." в настройки локальных частот вещания рации")
			wait(1700)					
			sampSendChat("/me заглушил".. chsex("", "а") .." локальную частоту вещания с порядковым номером "..id)
			wait(1700)
			sampSendChat("/fmute "..id.." "..timem.." "..reac)
			wait(1700)
			sampSendChat("/r Сотруднику с бейджиком №"..id.." была отключена рация по причине: "..reac)
			wait(1700)		
			sampSendChat("/me повесил".. chsex("", "а") .." обратно рация на пояс")
		end)
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Используйте команду /+mute [id игрока] [время в минутах] [причина].", 0xEE4848)
	end
end
function funCMD.umute(id)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}["..script_names.."]: В данный момент проигрывается отыгровка.", 0xEE4848)
		return 
	end
	if num_rank.v+1 < 8 then
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Данная команда Вам недоступна. Поменяйте должность в настройках скрипта, если это требуется.", 0xEE4848)
		return
	end
	if id:find("(%d+)") then
		if GetPlayerDistance(id) then
			thread = lua_thread.create(function()
				sampSendChat("/do Рация весит на поясе.")
				wait(1700)		
				sampSendChat("/me снял рацию с пояса")
				wait(1700)
				sampSendChat("/me ".. chsex("зашёл", "зашла") .." в настройки локальных частот вещания рации")
				wait(1700)					
				sampSendChat("/me освободил локальную частоту вещания с порядковым номером "..id)
				wait(1700)
				sampSendChat("/funmute "..id)
				wait(1700)		
				sampSendChat("/me повесил обратно рация на пояс")
			end)
		else
			sampAddChatMessage("{FFFFFF}["..script_names.."]: Этого человек нету около вас.", 0xEE4848)
		end
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Используйте команду /-mute [id игрока].", 0xEE4848)
	end
end
function funCMD.rank(text)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}["..script_names.."]: В данный момент проигрывается отыгровка.", 0xEE4848)
		return 
	end
	if num_rank.v+1 < 9 then
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Данная команда Вам недоступна. Поменяйте должность в настройках скрипта, если это требуется.", 0xEE4848)
		return
	end
		if text:find("(%d+)%s([1-9])") then
		local id, rankNum = text:match("(%d+)%s(%d)")
		id = tonumber(id); rankNum = tonumber(rankNum);
		if GetPlayerDistance(id) then
			thread = lua_thread.create(function()
				sampSendChat("/do В кармане халата находится футляр с ключами от шкафчиков с формой.")
				wait(1700)
				sampSendChat("/me потянувшись во внутренний карман халата, достал".. chsex("", "а"))
				wait(1700)
				sampSendChat("/me открыв футляр, достал".. chsex("", "а") .." от туда ключ c номером '"..id.."'")
				wait(1700)
				sampSendChat("/me передал".. chsex("", "а") .." ключ от шкафчика №"..id.." с формой "..u8:decode(chgName.rank[rankNum]).."а человеку напротив")
				wait(1700)
				sampSendChat("/giverank "..id.." "..rankNum)
				wait(1700)
				sampSendChat("/r Сотруднику с бейджиком №"..id.." была выдана новая форма.")
			end)
		else
			sampAddChatMessage("{FFFFFF}["..script_names.."]: Этого человек нету около вас.", 0xEE4848)
		end
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Используйте команду /gr [id игрока] [номер ранга].", 0xEE4848)
	end
end
function funCMD.osm(id)
	if thread:status() ~= "dead" then 
		sampAddChatMessage("{FFFFFF}["..script_names.."]: В данный момент проигрывается отыгровка.", 0xEE4848)
		return 
	end
	if id:find("(%d+)") then
		if GetPlayerDistance(id) then
			thread = lua_thread.create(function()
				sampAddChatMessage("{FFFFFF}["..script_names.."]: Нажмите на {23E64A}Enter{FFFFFF}, если готовы начать осмотр.", 0xEE4848)
				addOneOffSound(0, 0, 0, 1058)
				local len = renderGetFontDrawTextLength(font, "{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить")
				while true do
				wait(0)
					renderFontDrawText(font, "Осмотр: {8ABCFA}Начать\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить", sx-len-10, sy-60, 0xFFFFFFFF)
					if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then
						break
					end
				end
				sampSendChat("Сейчас я проведу для Вас небольшое мед.обследование.")
				wait(1700)
				sampSendChat("Пожалуйста, предоставьте Вашу мед.карту.")
				local len = renderGetFontDrawTextLength(font, "Осмотр: {8ABCFA}Ожидание ответа")
				addOneOffSound(0, 0, 0, 1058)
				while true do
				wait(0)
					renderFontDrawText(font, "Осмотр: {8ABCFA}Ожидание ответа\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить", sx-len-10, sy-60, 0xFFFFFFFF)
					if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then
						break
					end
				end
				sampSendChat("/me взял"..chsex("", "а").." мед.карту из рук человек")
				wait(1700)
				sampSendChat("/do Мед.карта в руках. ")
				wait(1700)
				sampSendChat("/do Ручка и печать в руках.")
				wait(1700)
				sampSendChat("Итак, сейчас я задам некоторые вопросы для оценки состояния здоровья.")
				wait(1700)
				sampSendChat("Давно ли Вы болели? Если да, то какими болезнями.")
				addOneOffSound(0, 0, 0, 1058)
				while true do
				wait(0)
					renderFontDrawText(font, "Осмотр: {8ABCFA}Ожидание ответа\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить", sx-len-10, sy-60, 0xFFFFFFFF)
					if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then
						break
					end
				end
				sampSendChat("Были ли у Вас травмы?")
				addOneOffSound(0, 0, 0, 1058)
				while true do
				wait(0)
					renderFontDrawText(font, "Осмотр: {8ABCFA}Ожидание ответа\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить", sx-len-10, sy-60, 0xFFFFFFFF)
					if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then
						break
					end
				end
				wait(1700)
				sampSendChat("Имеются ли какие-то аллергические реакции?")
				addOneOffSound(0, 0, 0, 1058)
				while true do
				wait(0)
					renderFontDrawText(font, "Осмотр: {8ABCFA}Ожидание ответа\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить", sx-len-10, sy-60, 0xFFFFFFFF)
					if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then
						break
					end
				end
				sampSendChat("/me сделал"..chsex("", "а").." записи в мед. карте")
				wait(1700)
				sampSendChat("Так, откройте рот.")
				wait(1700)
				sampSendChat("/n /me открыл(а) рот")
				addOneOffSound(0, 0, 0, 1058)
				while true do
				wait(0)
					renderFontDrawText(font, "Осмотр: {8ABCFA}Ожидание ответа\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить", sx-len-10, sy-60, 0xFFFFFFFF)
					if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then
						break
					end
				end
				sampSendChat("/do В кармане фонарик.")
				wait(1700)
				sampSendChat("/me достал"..chsex("", "а").." фонарик из кармана и включил его")
				wait(1700)
				sampSendChat("/me осмотрел"..chsex("", "а").." горло пациента")
				wait(1700)
				sampSendChat("Можете закрыть рот.")
				wait(3000)
				sampSendChat("/me проверил"..chsex("", "а").." реакция зрачков пациента на свет, посветив в глаза")
				wait(1700)
				sampSendChat("/do Зрачоки глаз обследуемого сузились.")
				wait(1700)
				sampSendChat("/me выключил"..chsex("", "а").." фонарик и убрал"..chsex("", "а").." его в карман")
				wait(1700)
				sampSendChat("Присядьте, пожалуйста, на корточки и коснитесь кончиком пальца до носа.")
				addOneOffSound(0, 0, 0, 1058)
				local len = renderGetFontDrawTextLength(font, "Осмотр: {8ABCFA}Ожидание действия")
				while true do
				wait(0)
					renderFontDrawText(font, "Осмотр: {8ABCFA}Ожидание действия\n{FFFFFF}[{67E56F}Enter{FFFFFF}] - Продолжить", sx-len-10, sy-60, 0xFFFFFFFF)
					if isKeyJustPressed(VK_RETURN) and not sampIsChatInputActive() and not sampIsDialogActive() then
						break
					end
				end
				sampSendChat("Вставайте.")
				wait(1700)
				sampSendChat("/me сделал"..chsex("", "а").." записи в мед. карте")
				wait(1700)
				sampSendChat("/me вернул"..chsex("", "а").." мед.карту человеку напротив")
				sampSendChat("Спасибо, можете быть свободны")
			end)
		else
			sampAddChatMessage("{FFFFFF}["..script_names.."]: Этого человек нету около вас.", 0xEE4848)
		end
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Используйте команду /osm [id игрока].", 0xEE4848)
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
		sampAddChatMessage("{FFFFFF}["..script_names.."]: В данный момент проигрывается отыгровка.", 0xEE4848)
		return 
	end
	if id:find("(%d+)") then
		if GetPlayerDistance(id) then
			thread = lua_thread.create(function()
				sampSendChat("/me резким движением руки "..chsex("ухватился", "ухватилась").." за воротник нарушителя")
				wait(1700)
				sampSendChat("/todo Я вынужден"..chsex("", "а").." вывести вас из здания*направляясь к выходу.")
				wait(1700)
				sampSendChat("/me движением левой руки открыл"..chsex("", "а").." входную дверь, после чего вытолкнул"..chsex("", "а").." нарушителя")
				addOneOffSound(0, 0, 0, 1058)
				local len = renderGetFontDrawTextLength(font, "{FFFFFF}[{67E56F}2{FFFFFF}] - Нарушение правил Мед.Центра")
				while true do
				wait(0)
					renderFontDrawText(font, "Выгнать из больницы: {8ABCFA}Выбор причины\n{FFFFFF}[{67E56F}1{FFFFFF}] - Неадекватное поведение\n{FFFFFF}[{67E56F}2{FFFFFF}] - Нарушение правил Мед.Центра", sx-len-10, sy-80, 0xFFFFFFFF)
					if isKeyJustPressed(VK_1) and not sampIsChatInputActive() and not sampIsDialogActive() then
						reas = "Неадекватное поведение"
						break
					end
					if isKeyJustPressed(VK_2) and not sampIsChatInputActive() and not sampIsDialogActive() then
						reas = "Нарушение правил Мед.Центра"
						break
					end
				end
				wait(1700)
				sampSendChat("/expel "..id.." "..reas)
			end)
		else
			sampAddChatMessage("{FFFFFF}["..script_names.."]: Этого человек нету около вас.", 0xEE4848)
		end
	else
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Используйте команду /exp [id игрока].", 0xEE4848)
	end
end
function funCMD.update()
	if newversion == scr.version then
		sampAddChatMessage("{FFFFFF}["..script_names.."]: Вы используете самую новую версию скрипта.", 0xEE4848)
	else
		local dir = dirml.."/MedicalHelper for Ministries of Health.lua"
		local url = "https://github.com/Dev-Filatov/MedicalHelper/blob/main/MedicalHelper%20by%20Kyle_Miller%20for%20GILBERT.lua?raw=true"
		downloadUrlToFile(url, dir, function(id, status, p1, p2)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
				if updates == nil then 
					print("{FF0000}Ошибка при попытке скачать файл.") 
					addOneOffSound(0, 0, 0, 1058)
				end
			end
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				updates = true
				sampAddChatMessage("{FFFFFF}["..script_names.."]: Скачивание завершено, перезагрузка библиотек...", 0xEE4848)
				reloadScripts()
				showCursor(false)
			end
		end)
	end
end
function funCMD.updateCheck()
	sampAddChatMessage("{FFFFFF}["..script_names.."]: Проверяем наличие обновлений...", 0xEE4848)
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
							sampAddChatMessage("{FFFFFF}["..script_names.."]: Всё отлично, Вы используете самую новую версию скрипта.", 0xEE4848)
						else
							sampAddChatMessage("{FFFFFF}["..script_names.."]: {4EEB40}Имеется обновление.{FFFFFF} Напиши {22E9E3}/update{FFFFFF} для закачки.", 0xEE4848)
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
		if mes:find("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~") or mes:find("- Основные команды сервера: /menu /help /gps /settings") or mes:find("- Пригласи друга и получи бонус в размере $250 000!") or mes:find("- Донат и получение дополнительных средств arizona-rp.com/donate") or mes:find("Подробнее об обновлениях сервера") or mes:find("Радио Аризона, прямые эфиры") then 
			return false
		end
	end
	if cb_chat3.v then
		if mes:find("News LS") or mes:find("News SF") or mes:find("News LV") then 
			return false
		end
	end
	if cb_chat1.v then
		if mes:find("Объявление:") or mes:find("Отредактировал сотрудник") then
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
		if mes:find(sobes.player.name.."%[%d+%]%sговорит:") then
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
