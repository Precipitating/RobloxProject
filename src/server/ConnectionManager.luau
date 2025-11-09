local ConnectionManager = {}

local connections = {}

-- adds a connection to a key
function ConnectionManager.Add(key, signal, handler)
	if not connections[key] then
		connections[key] = {}
	end
	local conn = signal:Connect(function(...)
		task.spawn(handler, ...)
	end)
	table.insert(connections[key], conn)
	return conn
end

-- clears all connections for a key
function ConnectionManager.Clear(key)
	if connections[key] then
		for _, conn in ipairs(connections[key]) do
			conn:Disconnect()
		end
		connections[key] = nil
	end
end

-- clears all connections for all keys
function ConnectionManager.ClearAll()
	for key, _ in pairs(connections) do
		ConnectionManager.Clear(key)
	end
end

return ConnectionManager
