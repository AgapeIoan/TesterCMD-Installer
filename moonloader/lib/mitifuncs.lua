local miti = {}

-- Micunelte secrete ce ne ajuta sa nu scriem spaghetti code

function miti.split_spaces(text)
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

function miti.starts_with(str, start)
    return str:sub(1, #start) == start
end

function miti.ends_with(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end

function miti.print_r(arr, indentLevel)
    local str = ""
    local indentStr = "#"

    if(indentLevel == nil) then
        -- print(miti.print_r(arr, 0))
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

function miti.magiclines(s)
	if s:sub(-1)~="\n" then s=s.."\n" end
	return s:gmatch("(.-)\n")
end

-- see if the file exists
function miti.file_exists(file)
	local f = io.open(file, "rb")
	if f then f:close() end
	return f ~= nil
  end

  -- get all lines from a file, returns an empty
  -- list/table if the file does not exist
function miti.lines_from(file)
	if not miti.file_exists(file) then return {} end
	lines = {}
	for line in io.lines(file) do
	  lines[#lines + 1] = line
	end
	return lines
  end

-- dam split la string aka intrebare hatz
function miti.split_lines(text)
	local text_2 = text
    local words = {}
	local propozitii = {}
	if type(text) ~= "string" then
		print_r(text)
	end

    for w in text_2:gmatch("%w+") do
		print(w)
		if w == "BB" then -- E urat rau ce am facut aici dar ayaye bag
            -- TODO A trecut cam 1 an de cand am facut treaba asta si nu stiu ce am vrut sa zic prin commentu de mai sus, 
            -- trebe sa rescriu functia ca 100% e ceva ghetto shit ce nu isi are rostul
        	table.insert(propozitii, words)
			words = {}
		else
			table.insert(words, w)
		end
    end

	miti.print_r(words, 2)
    return propozitii
end

function miti.gettimer(time)
    local workTime = os.time() - time
	return string.format("%s:%s:%s", string.format("%s%s", (tonumber(os.date("%H", workTime)) < tonumber(os.date("%H", 0)) and 24 + tonumber(os.date("%H", workTime)) - tonumber(os.date("%H", 0)) or tonumber(os.date("%H", workTime)) - tonumber(os.date("%H", 0))) < 10 and 0 or "", tonumber(os.date("%H", workTime)) < tonumber(os.date("%H", 0)) and 24 + tonumber(os.date("%H", workTime)) - tonumber(os.date("%H", 0)) or tonumber(os.date("%H", workTime)) - tonumber(os.date("%H", 0))), os.date("%M", workTime), os.date("%S", workTime))
end

function miti.copyfile(old_path, new_path)
    local old_file = io.open(old_path, "rb")
    local new_file = io.open(new_path, "wb")
    local old_file_sz, new_file_sz = 0, 0
    if not old_file or not new_file then
      return false
    end
    while true do
      local block = old_file:read(2^13)
      if not block then 
        old_file_sz = old_file:seek( "end" )
        break
      end
      new_file:write(block)
    end
    old_file:close()
    new_file_sz = new_file:seek( "end" )
    new_file:close()
    return new_file_sz == old_file_sz
  end

return miti