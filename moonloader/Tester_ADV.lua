local sampev = require 'lib.samp.events'
local glob = require "lib.game.globals"
local imgui = require 'imgui'
local key = require 'vkeys'

script_name("Tester_ADV")
script_description("Pic civili simulator")
script_version_number(3)
script_version("v1.4")
script_authors("AgapeIoan")

-- Chestii esentiale

de_dat_tog = {}
de_dat_tog["Newbie Chat"] = "/togn"
de_dat_tog["Faction Chat"] = "/togf"
de_dat_tog["Walkie Talkie"] = "/togwt"
de_dat_tog["News"] = "/tognews"
de_dat_tog["Clan"] = "/togc"
de_dat_tog["Auction"] = "/togbid"
nume_factiune = ""
nume_factiune_scurt = ""
--- Mai sus facui pe mai multe randuri sa arate mai frumix + mai ez de manageriat

intrebari = {}
raspunsuri = {}
timpi = {}
intrebare_raspuns = {}
ULTIMUL_RASPUNS_TRIMIS = ""
NICKNAME_APLICANT = ""
TOTAL_GRESELI = 0
INTREBARE_CURENTA = 1
STOP_TIMER = false
ESTE_INTREBARE_ACTIVA = false
ZIS_FELICITAT = false
INTRO_ACTIV = false
NICKNAME_TESTER = ""
color = 16766720

--- Facem ceva functii aka micunelte, o sa ne ajuta mai tarziu

function split_spaces(text)
    local splitted_string = {}
    local string_to_add = ""
    for c in text:gmatch"." do
        if c ~= " " then
            string_to_add = string_to_add .. c
        else
            table.insert(splitted_string, string_to_add)
            string_to_add = ""
        end
    end
    table.insert(splitted_string, string_to_add) -- Sa adaugam si ultimul cuvant
    return splitted_string
end

function starts_with(str, start)
    return str:sub(1, #start) == start
end

function ends_with(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end

function print_r(arr, indentLevel)
    local str = ""
    local indentStr = "#"

    if(indentLevel == nil) then
        print(print_r(arr, 0))
        return
    end

    for i = 0, indentLevel do
        indentStr = indentStr.."\t"
    end

    for index,value in pairs(arr) do
        if type(value) == "table" then
            str = str..indentStr..index..": \n"..print_r(value, (indentLevel + 1))
        else
            str = str..indentStr..index..": "..value.."\n"
        end
    end
    return str
end

function magiclines(s)
	if s:sub(-1)~="\n" then s=s.."\n" end
	return s:gmatch("(.-)\n")
end

-- see if the file exists
function file_exists(file)
	local f = io.open(file, "rb")
	if f then f:close() end
	return f ~= nil
  end

  -- get all lines from a file, returns an empty
  -- list/table if the file does not exist
function lines_from(file)
	if not file_exists(file) then return {} end
	lines = {}
	for line in io.lines(file) do
	  lines[#lines + 1] = line
	end
	return lines
  end

-- dam split la string aka intrebare hatz
function split_lines(text)
	local text_2 = text
    local words = {}
	local propozitii = {}
	if type(text) ~= "string" then
		print_r(text)
	end

    for w in text_2:gmatch("%w+") do
		print(w)
		if w == "BB" then -- E urat rau ce am facut aici dar ayaye bag pl
        	table.insert(propozitii, words)
			words = {}
		else
			table.insert(words, w)
		end
    end

	print_r(words, 2)
    return propozitii
end

function load_questions()
	local file_intrebari = 'moonloader\\TesterCMD\\intrebari.txt'
	local file_raspunsuri = 'moonloader\\TesterCMD\\raspunsuri.txt'
	local file_timpi = 'moonloader\\TesterCMD\\timpiDeRaspuns.txt'
	local file_faction_name = 'moonloader\\TesterCMD\\faction_name.txt'
	LISTA_INTREBARI = lines_from(file_intrebari)
	LISTA_RASPUNSURI = lines_from(file_raspunsuri)
	LISTA_TIMPI = lines_from(file_timpi)
	LISTA_FACTION_NAME = lines_from(file_faction_name)
	-- TODO TREBUIE FACUT CUMVA SA LINKUIESC INTREBARILE CU RASPUNSURILE
	-- CA DACA DAU SHUFFLE SE AMESTECA CUM VOR ELE SI NU E BN
end

load_questions()

FINAL_INTREBARI = table.getn(LISTA_INTREBARI)
FINAL_RASPUNSURI = table.getn(LISTA_RASPUNSURI)

nume_factiune = LISTA_FACTION_NAME[1]
nume_factiune_scurt = LISTA_FACTION_NAME[2]

-- Init timpi
for i=1, 100 do
	if LISTA_TIMPI[i] == nil then
		LISTA_TIMPI[i] = "60"
	end
end

-- Initializam intrebarile
for i=1, FINAL_INTREBARI do
	intrebari[i] = function()
		sampSendChat("/cw " .. i .. ". " .. LISTA_INTREBARI[i])
		init_timer_intrebare(tonumber(LISTA_TIMPI[i]))
	end
end

-- Initializam raspunsurile
for i=1, FINAL_RASPUNSURI do
	local marea_intrebare_adevarata = LISTA_RASPUNSURI[i]

	if marea_intrebare_adevarata:find("BB", 1, true) then -- Daca avem BB atunci trebe sa dam split
		raspunsuri[i] = function ()
			-- sampAddChatMessage("{0073e6}Timp de raspuns: {3792cb}" .. LISTA_TIMPI[i] .. " de secunde.", color)
			lua_thread.create(function()
				wait(500)
				sampSendChat("/cw Timp de raspuns: " .. LISTA_TIMPI[i] .. " de secunde.")
			end)
			local trimis = true
			if type(marea_intrebare_adevarata) == "string" then
				-- E ceva bug ciudat aicia, string-ul se transforma in tablou bidimensional (probabil mostenit dupa prelucrarea din split_tables)
				-- insa daca fac sa verific mai intai datatype-ul si sa transform doar la nevoie, aparent se rezolva problema
				marea_intrebare_adevarata = split_lines(marea_intrebare_adevarata)
			end
			for _, propozitie in pairs(marea_intrebare_adevarata) do
				local propozitie_adevarata_se_stie = ''
				for _, cuvant in pairs(propozitie) do
					propozitie_adevarata_se_stie = propozitie_adevarata_se_stie .. cuvant .. " "
				end
				if trimis then
					sampAddChatMessage("{F6D56D}Raspunsuri ".. tostring(i) .. ": {3792cb}" .. propozitie_adevarata_se_stie, color)
					ULTIMUL_RASPUNS_TRIMIS = propozitie_adevarata_se_stie
					trimis = false
				else
					sampAddChatMessage("{3792cb}" .. propozitie_adevarata_se_stie, color)
					ULTIMUL_RASPUNS_TRIMIS = propozitie_adevarata_se_stie
				end
			end
		end
	else
		raspunsuri[i] = function()
			-- sampAddChatMessage("{F6D56D}Timp de raspuns: {3792cb}" .. LISTA_TIMPI[i] .. " de secunde.", color)
			lua_thread.create(function()
				wait(500)
				sampSendChat("/cw Timp de raspuns: " .. LISTA_TIMPI[i] .. " de secunde.")
			end)

			sampAddChatMessage("{F6D56D}Raspuns ".. tostring(i) .. ": {3792cb}" .. marea_intrebare_adevarata, color)
			ULTIMUL_RASPUNS_TRIMIS = marea_intrebare_adevarata
		end
	end
end

-- Hatz pregatim comenzile pentru intrebari/raspunsuri
for i=1, FINAL_RASPUNSURI do
	intrebare_raspuns[i] = function()
		if ESTE_INTREBARE_ACTIVA then
			sampAddChatMessage("{FF0000}(!) Nu te grabi mane, vezi mai intai daca a dat civilu' raspuns. Daca a raspuns, dai [/st].", color)
			return
		end
		raspunsuri[i]()
		intrebari[i]()
	end
end

-- imgui
do
	show_main_window = imgui.ImBool(false)
	local show_imgui_example = imgui.ImBool(false)
	local slider_float = imgui.ImInt(2000)
	local clear_color = imgui.ImVec4(0.45, 0.55, 0.60, 1.00)
	local show_test_window = imgui.ImBool(false)
	local show_another_window = imgui.ImBool(false)
	local show_moon_imgui_tutorial = {imgui.ImBool(false), imgui.ImBool(false), imgui.ImBool(false)}
	local moonimgui_text_buffer = imgui.ImBuffer('test', 256)
	local sampgui_texture = nil
	local cb_render_in_menu = imgui.ImBool(imgui.RenderInMenu)
	local cb_render_in_menu_2 = imgui.ImBool(imgui.RenderInMenu)
	local cb_lock_player = imgui.ImBool(imgui.LockPlayer)
	local cb_show_cursor = imgui.ImBool(imgui.ShowCursor)
	local font_changed = false
	local glyph_ranges_cyrillic = nil
	function imgui.OnDrawFrame()
		-- Main Window
		if show_main_window.v then
			local sw, sh = getScreenResolution()
			-- center
			imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.SetNextWindowSize(imgui.ImVec2(690 + 420 / 3, 360), imgui.Cond.FirstUseEver)
			imgui.Begin('TesterCMD v1.3 | ' .. nume_factiune, show_main_window)
			imgui.Text(
				'- [/intro] - incepi testul\n' ..
				'- [/intrebare] - pui intrebare pana ajungi la practic\n' ..
				'- [/gg] - ii spui la civil ca nu mai e civil\n' .. 
				'- [/gr] - acorzi 1/3 greseli\n' ..
				'- [/grp] - acorzi 0.5/3 greseli\n' ..
				'- [/gr05] - acorzi 0.5/3 greseli, insa nu specifici motivul\n' .. 
				'- [/st] - sari peste intrebare *\n' ..
				'- [/w1] => [/w20] - pui intrebarea manual\n' ..
				'- [/teoretic] - zici manual ca a trecut teoreticul\n' ..
				'- [/ocolire] - acorzi 0.5/3 greseli pentru ocolire\n' ..
				'- [/locatie] - acorzi 1/3 greseli pentru necunoasterea locatiei\n' ..
				'Daca aplicantul acumuleaza mai mult de 3/3 greseli, va primi automat mesaj cum ca a picat testul.\n\n' ..
				'*Daca se intampla sa nu poti trece la intrebare urmatoare, foloseste [/st] pentru a trece peste restrictiile impuse de CMD.'
			)
			local btn_size = imgui.ImVec2(-0.1, 0)

			if imgui.Button('Exit', btn_size) then
				show_main_window.v = not show_main_window.v
			end
			imgui.End()
		end
		
		if show_test_window.v then
			imgui.SetNextWindowPos(imgui.ImVec2(650, 20), imgui.Cond.FirstUseEver)
			imgui.ShowTestWindow(show_test_window)
		end
	end

end


-- Avem comenzi mai jos
function clearchat()
	lua_thread.create(function()
		for i=1, 50 do
			sampAddChatMessage("")
		end
	end)
end

function togall_off()
	lua_thread.create(function() --- Facem un thread sa mearga wait inafara lui main
		sampSendChat('/tog')
		wait(1000)
		text = sampGetDialogText()
		sampCloseCurrentDialogWithButton(0)


	-- Debug
	-- file = io.open("dialog.txt", "a")
	-- io.output(file)
	-- io.write(text)
	-- io.close(file)

		sampSendChat("/turn off")
		wait(500)
		for line in magiclines(text) do
			for k, v in pairs(de_dat_tog) do
				if string.match(line, k) and not string.match(line, "dezactivat") then
					sampSendChat(v)
					wait(500)
				end
			end
		end
		
		sampAddChatMessage("{FF0000}Nu uita de [/togpremium] si [/togvip], dupa caz.")
	end)
end

function togall_on()
	lua_thread.create(function() --- Facem un thread sa mearga wait inafara lui main
		sampSendChat('/tog')
		wait(500)
		text = sampGetDialogText()
		sampCloseCurrentDialogWithButton(0)

		sampSendChat("/turn on")
		wait(500)
		for line in magiclines(text) do
			for k, v in pairs(de_dat_tog) do
				if string.match(line, k) and string.match(line, "dezactivat") then
					sampSendChat(v)
					wait(500)
				end
			end
		end

		sampAddChatMessage("{FF0000}Nu uita de [/togpremium] si [/togvip], dupa caz.")
	end)
end

function bugat() -- Aici testez chestii, nu ma astept sa imi amintesc ce scrisai xdd
	-- local skema = "CEVA STRING JMEK BB ALT STRING JMEK RAU BB"
	-- local skema_si_mai_mare = split_lines(skema)
	-- for _, propozitie in pairs(skema_si_mai_mare) do
	-- 	propozitie_adevarata_se_stie = ""
	-- 	for _, cuvant in pairs(propozitie) do
	-- 		propozitie_adevarata_se_stie = propozitie_adevarata_se_stie .. cuvant .. " "
	-- 	end
	-- 	sampAddChatMessage("{FF0000}" .. propozitie_adevarata_se_stie)

	-- end
	sampAddChatMessage("{FF0000} DONE DEBUG")
end

function greseala()
	STOP_TIMER = true
	TOTAL_GRESELI = TOTAL_GRESELI + 1
	lua_thread.create(function ()
		sampAddChatMessage("{DC143C}(!) Jucatorul a primit 1/3 greseli. Totalul este de " .. TOTAL_GRESELI .. "/3 greseli.", 14423100)
		sampSendChat("/cw Raspunsul este gresit. Ai acumulat in total " .. TOTAL_GRESELI .. "/3 greseli.")
		wait(420)
		sampSendChat("/cw Raspunsul corect este: " .. ULTIMUL_RASPUNS_TRIMIS)

		if TOTAL_GRESELI >= 3 then
			wait(420)
			sampSendChat("/cw Din pacate, ai picat testul deoarece ai acumulat " .. TOTAL_GRESELI .. "/3 greseli.")
		end
	end)
end

function greseala_partiala()
	STOP_TIMER = true
	TOTAL_GRESELI = TOTAL_GRESELI + 0.5
	lua_thread.create(function ()
		sampAddChatMessage("{DC143C}(!) Jucatorul a primit 0.5/3 greseli. Totalul este de " .. TOTAL_GRESELI .. "/3 greseli.", 14423100)
		sampSendChat("/cw Raspunsul este partial gresit. Ai acumulat in total " .. TOTAL_GRESELI .. "/3 greseli.")
		wait(420)
		sampSendChat("/cw Raspunsul corect este: " .. ULTIMUL_RASPUNS_TRIMIS)

		if TOTAL_GRESELI >= 3 then
			wait(420)
			sampSendChat("/cw Din pacate, ai picat testul deoarece ai acumulat " .. TOTAL_GRESELI .. "/3 greseli.")
		end
	end)
end

function greseala_partiala_fara_motiv()
	STOP_TIMER = true
	TOTAL_GRESELI = TOTAL_GRESELI + 0.5
	lua_thread.create(function ()
		sampAddChatMessage("{DC143C}(!) Jucatorul a primit 0.5/3 greseli. Totalul este de " .. TOTAL_GRESELI .. "/3 greseli.", 14423100)
		sampSendChat("/cw Primesti 0.5/3 greseli. Ai acumulat in total " .. TOTAL_GRESELI .. "/3 greseli.")

		if TOTAL_GRESELI >= 3 then
			wait(420)
			sampSendChat("/cw Din pacate, ai picat testul deoarece ai acumulat " .. TOTAL_GRESELI .. "/3 greseli.")
		end
	end)
end

function init_timer_intrebare(timp)
	ESTE_INTREBARE_ACTIVA = true
	lua_thread.create(function ()
		for i=1, timp*10 do
			-- print("DEBUG: Au trecut " .. tostring(i) .. "ms.")
			if STOP_TIMER then
				STOP_TIMER = false
				ESTE_INTREBARE_ACTIVA = false
				-- sampAddChatMessage("{FF000}AM AVANSAT CU O BUCATA INTREBARE")
				avanseaza_intrebarea_curenta()
				return
			end
			wait(100)
		end
		sampAddChatMessage("{FF0000}(!) Vezi sa nu fi trecut timpul de raspuns la intrebare.", color)
		ESTE_INTREBARE_ACTIVA = false
		avanseaza_intrebarea_curenta()
	end)
end

function stop_timer_intrebare()
	STOP_TIMER = true
	sampAddChatMessage("{00FF00}Am sarit peste intrebare!", color)
end

function get_nickname_command(param)
	local id = string.match(param, '(%d+)')
	if id ~= nil then
	  local name = sampGetPlayerNickname(id)
	  print(name)
	  NICKNAME_APLICANT = name
	end
end

function mare_intro_test()
	INTRO_ACTIV = true 
	INTREBARE_CURENTA = 1

	--- Hazz aici e skema de luam numele nostru
	local PLAYER_HANDLE = getGameGlobal(glob.PLAYER_CHAR)
	local result, ped = getPlayerChar(PLAYER_HANDLE)
	local result, playerid = sampGetPlayerIdByCharHandle(ped)
	TESTER_NAME = sampGetPlayerNickname(playerid)
	
	lua_thread.create(function()
		sampSendChat("/f Test, dau /togf.")
		wait(666)
		sampSendChat("/cw Salut! Eu sunt " .. TESTER_NAME .. ", iar impreuna vom sustine testul de intrare in " .. nume_factiune_scurt .. ".")
		wait(666)
		sampSendChat("/cw Pe toata perioada testului, trebuie sa ai telefonul inchis si sa folosesti [/cw] ca mijloc de comunicare.")
		wait(666)
		sampSendChat("/cw Timpul de raspuns variaza, incepand de la 60 de secunde pana la 180.", color)
		wait(666)
		sampSendChat("/cw Se va specifica la fiecare intrebare cat timp ai la dispozitie sa raspunzi.", color)
		wait(666)
		sampSendChat("/cw Daca vei fi AFK mai mult de 15 secunde sau vei iesi de pe joc cu [/q], vei fi picat automat.", color)
		wait(1000)

		togall_off()
	end)

	INTRO_ACTIV = false
end

function avanseaza_intrebarea_curenta()
	INTREBARE_CURENTA = INTREBARE_CURENTA + 1
end

function gege_mane_a_mers_telefonul_ala()
	sampSendChat("/cw Felicitari! Ai trecut testul de intrare in factiunea " .. nume_factiune .. " cu " .. TOTAL_GRESELI .. "/3 greseli.")
	lua_thread.create(function()
		wait(1000)
		togall_on()
	end)
end

function vrei_sa_ma_faci_de_bani_mane()
	TOTAL_GRESELI = TOTAL_GRESELI + 0.5
	lua_thread.create(function ()
		sampAddChatMessage("{DC143C}(!) Jucatorul a primit 0.5/3 greseli. Totalul este de " .. TOTAL_GRESELI .. "/3 greseli.", 14423100)
		sampSendChat("/cw Primesti 0.5/3 pentru ocolire. Ai acumulat in total " .. TOTAL_GRESELI .. "/3 greseli.")

		if TOTAL_GRESELI >= 3 then
			wait(420)
			sampSendChat("/cw Din pacate, ai picat testul deoarece ai acumulat " .. TOTAL_GRESELI .. "/3 greseli.")
		end
	end)
end

function nu_stii_mapa_mane()
	TOTAL_GRESELI = TOTAL_GRESELI + 1
	lua_thread.create(function ()
		sampAddChatMessage("{DC143C}(!) Jucatorul a primit 1/3 greseli. Totalul este de " .. TOTAL_GRESELI .. "/3 greseli.", 14423100)
		sampSendChat("/cw Primesti 1/3 deoarece nu cunosti locatia. Ai acumulat in total " .. TOTAL_GRESELI .. "/3 greseli.")

		if TOTAL_GRESELI >= 3 then
			wait(420)
			sampSendChat("/cw Din pacate, ai picat testul deoarece ai acumulat " .. TOTAL_GRESELI .. "/3 greseli.")
		end
	end)
end

function gata_teoreticu_fortat()
	lua_thread.create(function()
		ZIS_FELICITAT = true
		sampSendChat("/cw Felicitari! Ai trecut testul teoretic. Urmeaza cel practic.")
		wait(1000)
		sampSendChat("/cw Daca ocolesti, primesti 0.5/3 greseli.")
		wait(420)
		sampSendChat("/cw Daca nu cunosti locatia, primesti 1/3 greseli.")
		wait(420)
		sampSendChat("/cw Continuam cu " .. TOTAL_GRESELI .. "/3 greseli.")
	end)
end

function pune_intrebarea_bos()
	if INTREBARE_CURENTA == FINAL_RASPUNSURI + 1 and not ZIS_FELICITAT then
		lua_thread.create(function()
			ZIS_FELICITAT = true
			sampSendChat("/cw Felicitari! Ai trecut testul teoretic. Urmeaza cel practic.")
			wait(1000)
			sampSendChat("/cw Daca ocolesti, primesti 0.5/3 greseli.")
			wait(420)
			sampSendChat("/cw Daca nu cunosti locatia, primesti 1/3 greseli.")
			wait(420)
			sampSendChat("/cw Continuam cu " .. TOTAL_GRESELI .. "/3 greseli.")
		end)

		return
	end

	if not ZIS_FELICITAT then
		-- sampAddChatMessage("{ff0000}" .. INTREBARE_CURENTA)
		intrebare_raspuns[INTREBARE_CURENTA]() -- Punem intrebarea
	end
end

function seteaza_nickname_tester_manual(param)
	NICKNAME_TESTER = param
	sampAddChatMessage("{ff0000}Nickname-ul a fost setat cu succes!", color)
	sampAddChatMessage(param)
end

--- Hatz aici e skema de porneste scriptu
function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end

	sampAddChatMessage("{ff0000}TesterCMD by AgapeIoan v1.4 | {ff0000}Pic civili simulator")
	--- Dar macar daca furi citu, da si credite ms

	--- Mai jos aicia lista cu comenzi
  sampRegisterChatCommand("togon", togall_on)
  sampRegisterChatCommand("togoff", togall_off)
  sampRegisterChatCommand(".cc", clearchat)
  sampRegisterChatCommand("gr", greseala)
  sampRegisterChatCommand("grp", greseala_partiala)
  sampRegisterChatCommand("gr05", greseala_partiala_fara_motiv)
  -- sampRegisterChatCommand("bugat", bugat) -- DEBUGGING, TESTAM CHESTII AICI
  -- sampRegisterChatCommand("gn", get_nickname_command)
  -- sampRegisterChatCommand("timer", init_timer_intrebare)
  sampRegisterChatCommand("st", stop_timer_intrebare)
  sampRegisterChatCommand("intro", mare_intro_test)
  sampRegisterChatCommand("intrebare", pune_intrebarea_bos)
  sampRegisterChatCommand("gg", gege_mane_a_mers_telefonul_ala)
  sampRegisterChatCommand("ocolire", vrei_sa_ma_faci_de_bani_mane)
  sampRegisterChatCommand("locatie", nu_stii_mapa_mane)
  sampRegisterChatCommand("tester", tester_helper_3000)
  sampRegisterChatCommand("teoretic", gata_teoreticu_fortat)
  sampRegisterChatCommand("nicknametester", seteaza_nickname_tester_manual)
  


  for i=1,FINAL_RASPUNSURI do
	sampRegisterChatCommand("w"..tostring(i), intrebare_raspuns[i])
  end

  while true do
	imgui.Process = show_main_window.v
	wait(0)
  end

end

function tester_helper_3000()
    show_main_window.v = not show_main_window.v
end

function sampev.onServerMessage(color, text)
	local avem_mesaj_de_la_tester = false -- TODO Sa fac sa ia numele cand da /intro, ca stim 100% ca e mesaj de la tester acolo
	local skema = nil

	if text ~= nil then
		if INTRO_ACTIV then
			-- Pe toata perioada testului, trebuie sa ai telefonul inchis si sa folosesti [/cw] ca mijloc de comunicare.
			if string.find(text, "iar impreuna vom sustine testul de intrare in") then
				text_array = split_spaces(text)
				NICKNAME_TESTER = text_array[3]
			end
		end
		if string.find(text, "(Car whisper)") then
			skema = true
			if string.find(text, NICKNAME_TESTER) then
				-- print(LISTA_TESTERI[i])
				avem_mesaj_de_la_tester = true
			end
		end
	else
		return
	end

	if skema and not avem_mesaj_de_la_tester then STOP_TIMER = true end
end

--  sampGetPlayerNickname(int id)
