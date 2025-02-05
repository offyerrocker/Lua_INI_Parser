-- original file from https://github.com/Dynodzzo/Lua_INI_Parser/pull/2/commits/addf72fcc01274ca72d00b61fd390d06f2191662

--edited by offyerrocker to sort alphabetically or by provided order table

--[[
	Copyright (c) 2012 Carreras Nicolas
	
	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
	
	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
--]]
--- Lua INI Parser.
-- It has never been that simple to use INI files with Lua.
--@author Dynodzzo

local LIP = {};

--- Returns a table containing all the data from the INI file.
--@param fileName The name of the INI file to parse. [string]
--@return The table containing all data from the INI file. [table]
function LIP.load(fileName)
	assert(type(fileName) == 'string', 'Parameter "fileName" must be a string.');
	local file = assert(io.open(fileName, 'r'), 'Error loading file : ' .. fileName);
	local data = {};
	local section;
	for line in file:lines() do
		local tempSection = line:match('^%[([^%[%]]+)%]$');
		if(tempSection)then
			section = tonumber(tempSection) and tonumber(tempSection) or tempSection;
			data[section] = data[section] or {};
		end
		local param, value = line:match('^([%w|_]+)%s*=%s*(.*)[\r]?$');
		if(param and value ~= nil)then
			value = value:match('^(.-)%s-;.-$') or value:match('^(.-)%s-$');
			if(tonumber(value))then
				value = tonumber(value);
			elseif(value == 'true')then
				value = true;
			elseif(value == 'false')then
				value = false;
			end
			if(tonumber(param))then
				param = tonumber(param);
			end
			data[section][param] = value;
		end
	end
	file:close();
	return data;
end

--- Saves all the data from a table to an INI file.
--@param fileName The name of the INI file to fill. [string]
--@param data The table containing all the data to store. [table]
function LIP.save(fileName, data, sort)
	assert(type(fileName) == 'string', 'Parameter "fileName" must be a string.');
	assert(type(data) == 'table', 'Parameter "data" must be a table.');
	local file = assert(io.open(fileName, 'w+b'), 'Error loading file :' .. fileName);
	local contents = '';
	if(sort and type(sort) == "table")then 
		for section, param in pairs(data) do
			--add keys in given sorted order
			contents = contents .. ('[%s]\n'):format(section);
			for i,key in ipairs(sort) do
				local value = param[key];
				if(value ~= nil) then --must be able to distinguish between false/nil
					contents = contents .. ('%s=%s\n'):format(key, tostring(value));
				end
			end
			--any unsorted pairs (ie not listed in the provided sort table) are then added alphabetically at the end
			local unsorted_values = {};
			for key,value in pairs(param) do 
				if not(table.contains(sort,key))then 
					table.insert(unsorted_values,key);
				end
			end
			table.sort(unsorted_values,function(a,b) return a < b end)
			for _,key in ipairs(unsorted_values) do 
				local value = param[key]
				if(value ~= nil)then
					contents = contents .. ('%s=%s\n'):format(key, tostring(value));
				end
			end
			contents = contents .. '\n';
		end
	else
		for section, param in pairs(data) do
			contents = contents .. ('[%s]\n'):format(section);
			for key, value in pairs(param) do
				contents = contents .. ('%s=%s\n'):format(key, tostring(value));
			end
			contents = contents .. '\n';
		end
	end
	file:write(contents);
	file:close();
end

return LIP;
