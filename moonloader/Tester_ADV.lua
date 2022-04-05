local sampev = require 'lib.samp.events'
local glob = require "lib.game.globals"
local imgui = require 'imgui'
local key = require 'vkeys'
local testerfuncs = require 'testerfuncs'
local miti = require 'mitifuncs'

script_name("Tester_ADV")
script_description("Pic civili simulator")
script_version_number(2)
script_version("v2.0")
script_authors("AgapeIoan")

RESPONSE_TIMEOUT = true
FACTION_SETTINGS = decodeJson(io.open(getWorkingDirectory().."\\TesterCMD\\faction_settings.json", "r"):read("*all"))
-- Key: "practica" reprezinta daca factiunea respectiva are proba practica sau nu.
-- Atentie! La mafii nu stiu daca mai exista sau nu proba practica, astfel am lasat pe fals valoarea. Daca vrea mafiotu 1v1 deagle ca proba practica ayaye scrie manual in chat deocamdata.

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
			imgui.Begin('TesterCMD v2.0 | ' .. testerfuncs.nume_factiune, show_main_window)
			imgui.Text(
				'- [/intro] - incepi testul\n' ..
				'- [/intrebare] - pui intrebare pana ajungi la practic\n' ..
				'- [/gg] - ii spui la civil ca nu mai e civil\n' .. 
				'- [/gr] - acorzi 1/3 greseli\n' ..
				'- [/grp] - acorzi 0.5/3 greseli\n' ..
				'- [/gr05] - acorzi 0.5/3 greseli, insa nu specifici motivul\n' .. 
				'- [/st] - sari peste intrebare *\n' ..
				'- [/w1] => [/w20] - pui intrebarea manual, fara /intrebare (/w20 este doar un exemplu, numarul reprezinta intrebarea)\n' ..
				'Factiunile de tip taxi mai dispun de urmatoarele comenzi:\n' ..
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
	for i=1, 50 do
		sampAddChatMessage("")
	end
end

function togall_off() -- Trebuie sa ruleze in lua_thread pentru wait
	sampSendChat('/tog')
	wait(1000)
	text = sampGetDialogText()
	sampCloseCurrentDialogWithButton(0)
	sampSendChat("/turn off")
	wait(500)
	for line in miti.magiclines(text) do
		for k, v in pairs(testerfuncs.de_dat_tog) do
			if string.match(line, k) and not string.match(line, "dezactivat") then
				sampSendChat(v)
				wait(500)
			end
		end
	end
	
	sampAddChatMessage("{FF0000}(!) Nu uita de [/togpremium] si [/togvip], dupa caz.", testerfuncs.color)
end

function togall_on() -- Trebuie sa ruleze in lua_thread pentru wait
	sampSendChat('/tog')
	wait(500)
	text = sampGetDialogText()
	sampCloseCurrentDialogWithButton(0)
	sampSendChat("/turn on")
	wait(500)
	for line in miti.magiclines(text) do
		for k, v in pairs(testerfuncs.de_dat_tog) do
			if string.match(line, k) and string.match(line, "dezactivat") then
				sampSendChat(v)
				wait(500)
			end
		end
	end

	sampAddChatMessage("{FF0000}Nu uita de [/togpremium] si [/togvip], dupa caz.", testerfuncs.color)
end

function greseala()
	RESPONSE_TIMEOUT = true
	lua_thread.create(function ()
		testerfuncs.TOTAL_GRESELI = testerfuncs.tester.increment_greseli(testerfuncs.TOTAL_GRESELI, 1)
		sampSendChat("/cw Raspunsul este gresit. Ai acumulat in total " .. testerfuncs.TOTAL_GRESELI .. "/3 greseli.")
		wait(420)
		sampSendChat("/cw Raspunsul corect este: " .. ULTIMUL_RASPUNS_TRIMIS)
		wait(420)
		testerfuncs.tester.pic_civili(testerfuncs.TOTAL_GRESELI)
	end)
end

function greseala_partiala()
	RESPONSE_TIMEOUT = true
	lua_thread.create(function ()
		testerfuncs.TOTAL_GRESELI = testerfuncs.tester.increment_greseli(testerfuncs.TOTAL_GRESELI, 0.5)
		sampSendChat("/cw Raspunsul este partial gresit. Ai acumulat in total " .. testerfuncs.TOTAL_GRESELI .. "/3 greseli.")
		wait(420)
		sampSendChat("/cw Raspunsul corect este: " .. ULTIMUL_RASPUNS_TRIMIS)
		wait(420)
		testerfuncs.tester.pic_civili(testerfuncs.TOTAL_GRESELI)
	end)
end

function greseala_partiala_fara_motiv()
	RESPONSE_TIMEOUT = true
	lua_thread.create(function ()
		testerfuncs.TOTAL_GRESELI = testerfuncs.tester.increment_greseli(testerfuncs.TOTAL_GRESELI, 0.5)
		sampSendChat("/cw Primesti 0.5/3 greseli. Ai acumulat in total " .. testerfuncs.TOTAL_GRESELI .. "/3 greseli.")
		wait(420)
		testerfuncs.tester.pic_civili(testerfuncs.TOTAL_GRESELI)
	end)
end

function mare_intro_test()
	testerfuncs.INTREBARE_CURENTA = 1
	testerfuncs.TOTAL_GRESELI = 0

	--- Hazz aici e skema de luam numele nostru
	local PLAYER_HANDLE = getGameGlobal(glob.PLAYER_CHAR)
	local result, ped = getPlayerChar(getGameGlobal(glob.PLAYER_CHAR))
	local result, playerid = sampGetPlayerIdByCharHandle(ped)
	TESTER_NAME = sampGetPlayerNickname(playerid)
	CIVIL_NAME = testerfuncs.tester.get_nickname_passager()
	
	lua_thread.create(function()
		if CIVIL_NAME == nil then
			sampSendChat("/f Test, dau /togf.")
		else
			sampSendChat("/f Test cu " .. CIVIL_NAME .. ", dau /togf.")
		end
		wait(700)
		sampSendChat("/cw Salut! Eu sunt " .. TESTER_NAME .. ", iar impreuna vom sustine testul de intrare in " .. testerfuncs.nume_factiune_scurt .. ".")
		wait(700)
		sampSendChat("/cw Pe toata perioada testului, trebuie sa ai telefonul inchis si sa folosesti [/cw] ca mijloc de comunicare.")
		wait(700)
		sampSendChat("/cw Se va specifica dupa fiecare intrebare cat timp ai la dispozitie sa raspunzi.")
		wait(700)
		sampSendChat("/cw Daca vei fi AFK mai mult de 15 secunde sau vei iesi de pe joc cu [/q], vei fi picat automat.")
		wait(1000)
		-- (Car whisper) AgapeIoan (102): asd
		for i=99, 90, -1 do
			text, prefix, color, pcolor = sampGetChatString(i)
			print(text)
			if string.find(text, "(Car whisper)") then
				text_array = miti.split_spaces(text)
				if string.find(TESTER_NAME, text_array[3]) then
					testerfuncs.NICKNAME_TESTER = text_array[3]
					print(testerfuncs.NICKNAME_TESTER)
					break
				end
			end
		end
		togall_off()
	end)
end

function gege_mane_a_mers_telefonul_ala() -- bitza 2021
	sampSendChat("/cw Felicitari! Ai trecut testul de intrare in factiunea " .. testerfuncs.nume_factiune .. " cu " .. testerfuncs.TOTAL_GRESELI .. "/3 greseli.")
	lua_thread.create(function()
		wait(1000)
		togall_on()
	end)
end

function vrei_sa_ma_faci_de_bani_mane() -- Ocolire
	lua_thread.create(function ()
		testerfuncs.TOTAL_GRESELI = testerfuncs.tester.increment_greseli(testerfuncs.TOTAL_GRESELI, 0.5)
		sampSendChat("/cw Primesti 0.5/3 pentru ocolire. Ai acumulat in total " .. testerfuncs.TOTAL_GRESELI .. "/3 greseli.")
		wait(420)
		testerfuncs.tester.pic_civili(testerfuncs.TOTAL_GRESELI)
	end)
end

function nu_stii_mapa_mane() -- Locatie
	lua_thread.create(function ()
		testerfuncs.TOTAL_GRESELI = testerfuncs.tester.increment_greseli(testerfuncs.TOTAL_GRESELI, 1)
		sampSendChat("/cw Primesti 1/3 deoarece nu cunosti locatia. Ai acumulat in total " .. testerfuncs.TOTAL_GRESELI .. "/3 greseli.")
		wait(420)
		testerfuncs.tester.pic_civili(testerfuncs.TOTAL_GRESELI)
	end)
end

function gata_teoreticu_fortat()
	testerfuncs.tester.incepem_proba_practica(testerfuncs.TOTAL_GRESELI, FACTION_SETTINGS[testerfuncs.nume_factiune]["proba_practica"])
end

function init_timer_intrebare(timp)
	testerfuncs.TIMP_INTREBARE = tonumber(timp)
	testerfuncs.TIMP_INITIAL = os.time()
	RESPONSE_TIMEOUT = false
end

function stop_timer_intrebare()
	sampAddChatMessage("{00FF00}Poti sari la urmatoarea intrebare!", testerfuncs.color)
    RESPONSE_TIMEOUT = true
end

function pune_intrebarea_bos()
	if testerfuncs.INTREBARE_CURENTA == testerfuncs.FINAL_RASPUNSURI + 1 then
		testerfuncs.tester.incepem_proba_practica(testerfuncs.TOTAL_GRESELI, FACTION_SETTINGS[testerfuncs.nume_factiune]["proba_practica"])
		testerfuncs.INTREBARE_CURENTA = testerfuncs.INTREBARE_CURENTA + 1
		return
	elseif testerfuncs.INTREBARE_CURENTA < testerfuncs.FINAL_RASPUNSURI + 1 then
		if testerfuncs.intrebare_raspuns[testerfuncs.INTREBARE_CURENTA](RESPONSE_TIMEOUT) then -- Am pus cu succes intrebarea in acelasi timp in care am verificat conditia
			init_timer_intrebare(testerfuncs.LISTA_TIMPI[testerfuncs.INTREBARE_CURENTA])
			testerfuncs.INTREBARE_CURENTA = testerfuncs.INTREBARE_CURENTA + 1 -- Pregatim urmatoarea intrebare
		end
	end
end

function seteaza_test_manual(param)
	local file_intrebari = 'moonloader\\TesterCMD\\intrebari'..tostring(param)..'.txt'
	local file_raspunsuri = 'moonloader\\TesterCMD\\raspunsuri'..tostring(param)..'.txt'
	local file_timpi = 'moonloader\\TesterCMD\\timpiDeRaspuns'..tostring(param)..'.txt'

	miti.copyfile(file_intrebari, 'moonloader\\TesterCMD\\intrebari.txt')
	miti.copyfile(file_raspunsuri, 'moonloader\\TesterCMD\\raspunsuri.txt')
	miti.copyfile(file_timpi, 'moonloader\\TesterCMD\\timpiDeRaspuns.txt')

	sampAddChatMessage("Am pregatit setul de intrebari " .. tostring(param) .. ". Tasteaza comanda [/reloadall] pentru ca schimbarea sa aiba efect.", testerfuncs.color)
end

--- Hatz aici e skema de porneste scriptu
function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end

	sampAddChatMessage("TesterCMD.lua v2.0 | Pic civili simulator", testerfuncs.color)
	testerfuncs.FINAL_INTREBARI, testerfuncs.FINAL_RASPUNSURI = testerfuncs.tester.check_questions_integrity(testerfuncs.FINAL_INTREBARI, testerfuncs.FINAL_RASPUNSURI)
	--- Dar macar daca furi citu, da si credite ms

	--- Mai jos aicia lista cu comenzi
  sampRegisterChatCommand(".cc", clearchat)
  sampRegisterChatCommand("gr", greseala)
  sampRegisterChatCommand("grp", greseala_partiala)
  sampRegisterChatCommand("gr05", greseala_partiala_fara_motiv)
  sampRegisterChatCommand("st", stop_timer_intrebare)
  sampRegisterChatCommand("intro", mare_intro_test)
  sampRegisterChatCommand("intrebare", pune_intrebarea_bos)
  sampRegisterChatCommand("gg", gege_mane_a_mers_telefonul_ala)
  sampRegisterChatCommand("ocolire", vrei_sa_ma_faci_de_bani_mane)
  sampRegisterChatCommand("locatie", nu_stii_mapa_mane)
  sampRegisterChatCommand("tester", tester_helper_3000)
  sampRegisterChatCommand("teoretic", gata_teoreticu_fortat)
  sampRegisterChatCommand("nicknametester", seteaza_nickname_tester_manual)
  sampRegisterChatCommand("settest", seteaza_test_manual)
  
  
  sampRegisterChatCommand("inputjson", function(input)
    local f = io.open(getWorkingDirectory().."\\config\\TesterCMD.json", "w")

    f:write(encodeJson({["string"]=input}))
    f:close()
end)

sampRegisterChatCommand("printjson", function()
	local t = FACTION_SETTINGS[nume_factiune]["proba_practica"]
	for k,v in pairs(t) do
		sampAddChatMessage(k.." "..tostring(v["practica"]), testerfuncs.color)
	end
    sampAddChatMessage(f:read(), -1)
    f:close()
end)


  for i=1,testerfuncs.FINAL_RASPUNSURI do
	sampRegisterChatCommand("w"..tostring(i), testerfuncs.intrebare_raspuns[i])
  end

  while true do
	imgui.Process = show_main_window.v
	if os.time() - testerfuncs.TIMP_INITIAL > testerfuncs.TIMP_INTREBARE and RESPONSE_TIMEOUT == false then -- A trecut timpul de raspuns
		-- Doar anuntam testerul si il lasam pe el sa decida daca da greseala sau nu
		sampAddChatMessage("{FF0000}(!) Vezi sa nu fi trecut timpul de raspuns la intrebare.", testerfuncs.color)
		RESPONSE_TIMEOUT = true
	end
	wait(0)
  end

end

function tester_helper_3000()
    show_main_window.v = not show_main_window.v
end

function sampev.onServerMessage(color, text)
	local avem_mesaj_de_la_tester = false
	local skema = nil

	if text ~= nil then
		if string.find(text, "(Car whisper)") then
			skema = true -- avem mesaj de /cw
			if string.find(text, testerfuncs.NICKNAME_TESTER) then
				-- print(LISTA_TESTERI[i])
				avem_mesaj_de_la_tester = true
			end
		end
	else 
		return 
	end

	if skema and not avem_mesaj_de_la_tester then RESPONSE_TIMEOUT = true end -- a dat civilu raspuns pe /cw
end