--// SomewhatMay \\--
--// BiArray Class \\--

local biArray = {}
biArray.__index = biArray

function biArray:Get(column: number, row: number)
	local index = ((column - 1) * self.Columns) + row
	return self.Array[index]
end

function biArray:Set(column: number, row: number, value: any)
	local index = ((column - 1) * self.Columns) + row
	self.Array[index] = value
end

function biArray:Iterate(func: Function)
	for column = 1, self.Columns, 1 do
		for row = 1, self.Rows, 1 do
			func(column, row, self:Get(column, row))
		end
	end
end

function biArray:Fill(value: Function | any)
	local isFunction = false

	if typeof(value) == "function" then
		isFunction = true
	end

	for column = 1, self.Columns, 1 do
		for row = 1, self.Rows, 1 do
			if isFunction then
				self:Set(column, row, value(column, row))
			else
				self:Set(column, row, value)
			end
		end
	end
end

function biArray:Destroy()
	self.Array = nil
	self.Columns = nil
	self.Rows = nil
	setmetatable(self, nil)
end

function biArray.new(columns, rows, value)
	local self = {
		Array = {};
		Columns = columns;
		Rows = rows;
	}
	
	setmetatable(self, biArray)
	
	if value then
		self:Fill(value)
	end
	
	return self
end

return biArray 
