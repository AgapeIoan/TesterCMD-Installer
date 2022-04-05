local miti = require "mitifuncs"

local debug = {} -- Functii debug
local tester = {} -- Functii tester
local intrebari = {} -- Functie afisare intrebare
local raspunsuri = {} -- Functie afisare raspuns
local intrebare_raspuns = {} -- Functie ce combina intrebare si raspuns si le executa concomitent
local STOP_TIMER = false
local ESTE_INTREBARE_ACTIVA = false
local INTRO_ACTIV = false
local COLOR_CHAT = 16766720
ULTIMUL_RASPUNS_TRIMIS = ""

-- TOG LIST:
local de_dat_tog = {}
de_dat_tog["Newbie Chat"] = "/togn"
de_dat_tog["Faction Chat"] = "/togf"
de_dat_tog["Walkie Talkie"] = "/togwt"
de_dat_tog["News"] = "/tognews"
de_dat_tog["Clan"] = "/togc"
de_dat_tog["Auction"] = "/togbid"

-- Loading questions
local file_intrebari = 'moonloader\\TesterCMD\\intrebari.txt'
local file_raspunsuri = 'moonloader\\TesterCMD\\raspunsuri.txt'
local file_timpi = 'moonloader\\TesterCMD\\timpiDeRaspuns.txt'
local file_faction_name = 'moonloader\\TesterCMD\\faction_name.txt'
local LISTA_INTREBARI = miti.lines_from(file_intrebari)
local LISTA_RASPUNSURI = miti.lines_from(file_raspunsuri)
local LISTA_TIMPI = miti.lines_from(file_timpi)
local LISTA_FACTION_NAME = miti.lines_from(file_faction_name)

local FINAL_INTREBARI = table.getn(LISTA_INTREBARI)
local FINAL_RASPUNSURI = table.getn(LISTA_RASPUNSURI)

function tester.check_questions_integrity(FINAL_INTREBARI, FINAL_RASPUNSURI)
	if FINAL_INTREBARI > FINAL_RASPUNSURI then -- Listele de intrebari si raspunsuri nu sunt facute cum trebuie.
		sampAddChatMessage("[TesterCMD.lua] Eroare: Numarul de intrebari este mai mare decat numarul de raspunsuri!", COLOR_CHAT)
		if FINAL_INTREBARI - 1 == FINAL_RASPUNSURI then
			sampAddChatMessage("[TesterCMD.lua] Eroare: Intrebarea " .. FINAL_INTREBARI .. " va fi ignorata deoarece nu are un raspuns pereche!", COLOR_CHAT)
		else
			sampAddChatMessage("[TesterCMD.lua] Eroare: Intrebarile " .. FINAL_RASPUNSURI + 1 .. "-" .. FINAL_INTREBARI .. " vor fi ignorate deoarece nu au un raspuns pereche!", COLOR_CHAT)
		end
		FINAL_INTREBARI = FINAL_RASPUNSURI
	elseif FINAL_INTREBARI < FINAL_RASPUNSURI then
		sampAddChatMessage("[TesterCMD.lua] Eroare: Numarul de raspunsuri este mai mare decat numarul de intrebari!", COLOR_CHAT)
		if FINAL_INTREBARI - 1 == FINAL_RASPUNSURI then
			sampAddChatMessage("[TesterCMD.lua] Eroare: Raspunsul " .. FINAL_RASPUNSURI .. " va fi ignorat deoarece nu are o intrebare pereche!", COLOR_CHAT)
		else
			sampAddChatMessage("[TesterCMD.lua] Eroare: Raspunsurile " .. FINAL_INTREBARI + 1 .. "-" .. FINAL_RASPUNSURI .. " vor fi ignorate deoarece nu au intrebari pereche!", COLOR_CHAT)
		end
		FINAL_RASPUNSURI = FINAL_INTREBARI
	end

	return FINAL_INTREBARI, FINAL_RASPUNSURI
end

-- Initializam timpii de raspuns
for i=1, FINAL_INTREBARI do -- Luam nr intrebari ca referinta
	if LISTA_TIMPI[i] == nil then
		LISTA_TIMPI[i] = "60" -- valoare default, 60 de secunde
	end
end

local nume_factiune = LISTA_FACTION_NAME[1]
local nume_factiune_scurt = LISTA_FACTION_NAME[2]

-- if nume_factiune == nil or nume_factiune_scurt == nil then
--     sampAddChatMessage("[TesterCMD.lua] Eroare: Nu s-a putut incarca numele factiunii! Acesta va fi setat cu o denumire generica pentru buna functionare a CMD-ului.", COLOR_CHAT)
--     nume_factiune = "aceasta factiune"
--     nume_factiune_scurt = "aceasta factiune"
-- end

-- Initializam intrebarile
for i=1, FINAL_INTREBARI do
	intrebari[i] = function()
		sampSendChat("/cw " .. i .. ". " .. LISTA_INTREBARI[i])
	end
end

-- Initializam raspunsurile
for i=1, FINAL_RASPUNSURI do
	raspunsuri[i] = function()
		-- sampAddChatMessage("{F6D56D}Timp de raspuns: {3792cb}" .. LISTA_TIMPI[i] .. " de secunde.", COLOR_CHAT)
		lua_thread.create(function()
			wait(500)
			sampSendChat("/cw Timp de raspuns: " .. LISTA_TIMPI[i] .. " de secunde.")
		end)

		sampAddChatMessage("{F6D56D}Raspuns ".. tostring(i) .. ": {3792cb}" .. LISTA_RASPUNSURI[i], COLOR_CHAT)
		ULTIMUL_RASPUNS_TRIMIS = LISTA_RASPUNSURI[i]
	end
end

-- Hatz pregatim comenzile pentru intrebari/raspunsuri
for i=1, FINAL_RASPUNSURI do
	intrebare_raspuns[i] = function(RESPONSE_TIMEOUT)
		if RESPONSE_TIMEOUT == false then
			sampAddChatMessage("{FF0000}(!) Nu te grabi mane, vezi mai intai daca a dat civilu' raspuns. Daca a raspuns, dai [/st].", COLOR_CHAT)
			return false
		end
		raspunsuri[i]()
		intrebari[i]()
		return true
	end
end


-- Debugging things
function debug.seteaza_nickname_tester_manual(param)
	sampAddChatMessage(NICKNAME_TESTER)
	-- NICKNAME_TESTER = param
	sampAddChatMessage("{ff0000}Nickname-ul a fost setat cu succes!", COLOR_CHAT)
	sampAddChatMessage(param)
end

-- Tester funcs
function tester.pic_civili(total_greseli)
    if total_greseli >= 3 then
        -- Atentie !!! Este nevoie de un wait pentru a trimite mesajul pe server imediat dupa reminderu cu greseala
        sampSendChat("/cw Din pacate, ai picat testul deoarece ai acumulat " .. total_greseli .. "/3 greseli.")
    end
end

function tester.increment_greseli(total_greseli, greseli_de_adaugat)
	total_greseli = total_greseli + greseli_de_adaugat
    sampAddChatMessage("{DC143C}(!) Jucatorul a primit " .. tostring(greseli_de_adaugat) ..  "/3 greseli. Totalul este de " .. tostring(total_greseli) .. "/3 greseli.", 14423100)
    return total_greseli
end

function tester.incepem_proba_practica(total_greseli, are_proba_practica)
    lua_thread.create(function()
		if are_proba_practica then
			sampSendChat("/cw Felicitari! Ai trecut testul teoretic. Urmeaza cel practic.")
			wait(1000)
			sampSendChat("/cw Daca ocolesti, primesti 0.5/3 greseli.")
			wait(420)
			sampSendChat("/cw Daca nu cunosti locatia, primesti 1/3 greseli.")
			wait(420)
			sampSendChat("/cw Continuam cu " .. tostring(total_greseli) .. "/3 greseli.")
		else
			sampAddChatMessage("[TesterCMD.lua] (!) Am ajuns la finalul intrebarilor. Daca totul este in regula, tasteaza comanda [/gg].", COLOR_CHAT)
		end
	end)
end

function tester.get_nickname_passager() -- Functie trasa pe dreapta din taxist_suprem.luac dar nu zicem
	if isCharInAnyCar(PLAYER_PED) then
		local masina_noastra = storeCarCharIsInNoSave(PLAYER_PED)
		local _, numar_pasageri = getNumberOfPassengers(masina_noastra)
		
		if numar_pasageri > 0 then
			for i=1, numar_pasageri do
				local scaun = isCarPassengerSeatFree(masina_noastra, i)
				if scaun then break end
			end

			local pasager = getCharInCarPassengerSeat(masina_noastra, scaun)
			local _, player_id = sampGetPlayerIdByCharHandle(pasager)
			local nickname = sampGetPlayerNickname(player_id)

			return nickname
		end

		return nil -- In caz ca navem pasager
	end

	return nil
end

return {
    de_dat_tog = de_dat_tog,
    nume_factiune = nume_factiune,
    nume_factiune_scurt = nume_factiune_scurt,
    color = COLOR_CHAT,
    LISTA_INTREBARI = LISTA_INTREBARI,
    LISTA_RASPUNSURI = LISTA_RASPUNSURI,
    LISTA_TIMPI = LISTA_TIMPI,
    FINAL_INTREBARI = FINAL_INTREBARI,
    FINAL_RASPUNSURI = FINAL_RASPUNSURI,
    ZIS_FELICITAT = false,
    TOTAL_GRESELI = 0,
    INTREBARE_CURENTA = 1,
    intrebari = intrebari,
    raspunsuri = raspunsuri,
    intrebare_raspuns = intrebare_raspuns,
    TIMP_INITIAL = os.time(),
    tester = tester,
    TIMP_INTREBARE = 31536000, -- 1 an, default ca sa nu dam trigger la comparatia din main
	NICKNAME_TESTER = ""
}