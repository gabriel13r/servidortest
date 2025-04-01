-- Definição de SERVER e CLIENT
SERVER = IsDuplicityVersion()
CLIENT = not SERVER

-- Função para encontrar o maior índice numérico em uma tabela
function table.maxn(t)
	local max = 0
	for k, v in pairs(t) do
		local n = tonumber(k)
		if n and n > max then max = n end
	end
	return max
end

-- Implementação do carregamento de módulos
local modules = {}
function module(rsc, path)
	if path == nil then
		path = rsc
		rsc = "vrp"
	end

	local key = rsc .. path
	local module = modules[key]
	if module then
		return module
	else
		local code = LoadResourceFile(rsc, path .. ".lua")
		if code then
			local f, err = load(code, rsc .. "/" .. path .. ".lua")
			if f then
				local ok, res = xpcall(f, debug.traceback)
				if ok then
					modules[key] = res
					return res
				else
					error("error loading module " .. rsc .. "/" .. path .. ": " .. res)
				end
			else
				error("error parsing module " .. rsc .. "/" .. path .. ": " .. debug.traceback(err))
			end
		else
			error("resource file " .. rsc .. "/" .. path .. ".lua not found")
		end
	end
end

-- Funções assíncronas usando Promises
local function wait(self)
	local rets = Citizen.Await(self.p)
	if not rets then
		rets = self.r
	end
	return table.unpack(rets, 1, #rets)
end

local function areturn(self, ...)
	self.r = { ... }
	self.p:resolve(self.r)
end

function async(func)
	if func then
		Citizen.CreateThread(func)  -- Alterado para a função correta
	else
		return setmetatable({ wait = wait, p = promise.new() }, { __call = areturn })
	end
end

-- Funções de parsing
function parseInt(v)
	local n = tonumber(v)
	if n == nil then
		return 0
	else
		return math.floor(n)
	end
end

function parseDouble(v)
	local n = tonumber(v)
	if n == nil then n = 0 end
	return n
end

function parseFloat(v)
	return parseDouble(v)
end

-- Função para sanitizar strings
local sanitize_tmp = {}
function sanitizeString(str, strchars, allow_policy)
	local r = ""
	local chars = sanitize_tmp[strchars]
	if chars == nil then
		chars = {}
		local size = string.len(strchars)
		for i = 1, size do
			local char = string.sub(strchars, i, i)
			chars[char] = true
		end
		sanitize_tmp[strchars] = chars
	end

	local size = string.len(str)
	for i = 1, size do
		local char = string.sub(str, i, i)
		if (allow_policy and chars[char]) or (not allow_policy and not chars[char]) then
			r = r .. char
		end
	end
	return r
end

-- Funções para manipulação de strings
function splitString(str, sep)
	if sep == nil then sep = "%s" end

	local t = {}
	for substr in string.gmatch(str, "([^" .. sep .. "]+)") do
		table.insert(t, substr)
	end

	return t
end

function joinStrings(list, sep)
	if sep == nil then sep = "" end

	local str = ""
	local size = #list
	for i, v in ipairs(list) do
		str = str .. v
		if i < size then
			str = str .. sep
		end
	end
	return str
end
