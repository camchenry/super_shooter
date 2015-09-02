options = {}

function options:init()
	self.saveFile = 'config.txt'
end

function options:enter()
	local width, height, flags = love.window.getMode()
	
    self.vsync = Checkbox:new('VERTICAL SYNC', 25, 50)
	self.vsync.selected = flags.vsync
	
	self.fullscreen = Checkbox:new('FULLSCREEN', 25, 90)
	self.fullscreen.selected = flags.fullscreen
	
	self.borderless = Checkbox:new('BORDERLESS', 25, 130)
	self.borderless.selected = flags.borderless
	
	-- Takes all available resolutions
	local resTable = love.window.getFullscreenModes(1)
	local resolutions = {}
	for k, res in pairs(resTable) do
		if res.width > 800 then -- cuts off any resolutions with a with under 800
			table.insert(resolutions, {res.width, res.height})
		end
	end

	-- sort resolutions from smallest to biggest
	table.sort(resolutions, function(a, b) return a[1]*a[2] < b[1]*b[2] end)
	
	self.resolution = List:new('RESOLUTION: ', resolutions, 25, 170, 275)
	self.resolution.listType = 'resolution'
	self.resolution:selectTable({width, height})
	self.resolution:setText('{1}x{2}')
	
	
	local fsaaOptions = {0, 2, 4, 8, 16}
	self.fsaa = List:new('ANTIALIASING: ', fsaaOptions, 25, 210, 275)
	self.fsaa:selectValue(flags.fsaa)
	self.fsaa:setText('{}x')
	
	-- applies current config settings
	self.back = Button:new("< BACK", 25, love.window.getHeight()-80)
	self.back.activated = function()
		state.pop() -- options can be accessed from multiple places in the game
	end

	self.apply = Button:new('APPLY', 170, love.window.getHeight()-80)
	self.apply.activated = function ()
		self:applyChanges()
		--if self:applyChanges() then
		--	fx.text(3.5, "CHANGES APPLIED", 25, love.graphics.getHeight()-120, {127, 127, 127})
		--end

		self.back.y = love.window.getHeight()-80
		self.apply.y = love.window.getHeight()-80
	end
end

function options:leave()
	--fx.reset()
end

function options:applyChanges()
	local width = self.resolution.options[self.resolution.selected][1]
	local height = self.resolution.options[self.resolution.selected][2]
	
	local fsaa = self.fsaa.options[self.fsaa.selected]
	
	local vsync = self.vsync.selected
	local fullscreen = self.fullscreen.selected
	local borderless = self.borderless.selected
	
	local success = love.window.setMode(width, height, {vsync = vsync, fullscreen = fullscreen, borderless = borderless, fsaa = fsaa})
	
	local width, height, flags = love.window.getMode()
	if fsaa ~= flags.fsaa then -- Notifies the player if the fsaa value is invalid
		--fx.text(5, 'fsaa value not supported', 25, love.window.getHeight()-120, {255, 0, 0})
		fsaa = 0 -- If the selected fsaa value is not supported, then it will store the value as 0
	end
	
	--self:save(width, height, vsync, fullscreen, borderless, fsaa)

	return success
end

function options:mousepressed(x, y, button)
	if button == 'l' then
		self.vsync:mousepressed(x, y)
		self.fullscreen:mousepressed(x, y)
		self.borderless:mousepressed(x, y)
	end
	
	self.resolution:mousepressed(x, y, button)
	self.fsaa:mousepressed(x, y, button)
	
	self.apply:mousepressed(x, y, button)
	self.back:mousepressed(x, y, button)
end

function options:keypressed(key)
	if key == "escape" then
		state.pop()
	end
end

function options:draw()
	self.vsync:draw()
	self.fullscreen:draw()
	self.borderless:draw()
	
	self.resolution:draw()
	self.fsaa:draw()
	
	self.apply:draw()
	self.back:draw()
end


function options:save(width, height, vsync, fullscreen, borderless, fsaa)
	local str = ''
	
	-- prepares config save data
	
	-- resolution
	str = str.. 'screen width: ' ..tostring(width).. '\n'
	str = str.. 'screen height: ' ..tostring(height).. '\n'
	
	-- checkboxes
	str = str.. 'vsync: ' ..tostring(vsync).. '\n'
	str = str.. 'fullscreen: '..tostring(fullscreen).. '\n'
	str = str.. 'borderless: '..tostring(borderless).. '\n'
	
	-- fsaa
	str = str.. 'fsaa: ' ..tostring(fsaa).. '\n'
	

	love.filesystem.write(self.saveFile, str)
end

function options:load()
	local saveFile = 'config.txt'
	-- self.saveFile variable couldn't be accessed from love.load where this is called

	if love.filesystem.exists(saveFile) then
		local config = {}
		local width, height = 1024, 768 -- default if a width/height not found, but the file exists

		-- iterates through each line of the config file, removes extra line data
		for line in love.filesystem.lines(saveFile) do
			if string.find(line, 'screen width: ') then width = string.gsub(line, 'screen width: ', '')
			elseif string.find(line, 'screen height: ') then height = string.gsub(line, 'screen height: ', '')
			
			elseif string.find(line, 'vsync: ') then config.vsync = string.gsub(line, 'vsync: ', '')
			elseif string.find(line, 'fullscreen: ') then config.fullscreen = string.gsub(line, 'fullscreen: ', '')
			elseif string.find(line, 'borderless: ') then config.borderless = string.gsub(line, 'borderless: ', '')
			
			
			elseif string.find(line, 'fsaa: ') then config.fsaa = string.gsub(line, 'fsaa: ', '')
			end
		end
		
		-- converts strings to booleans
		if config.vsync == "true" then config.vsync = true
		else config.vsync = false end
		
		if config.fullscreen == "true" then config.fullscreen = true
		else config.fullscreen = false end
		
		if config.borderless == "true" then config.borderless = true
		else config.borderless = false end
		
		if config.fsaa then config.fsaa = tonumber(config.fsaa) end
		
		love.window.setMode(tonumber(width), tonumber(height), config)
		
		-- returns true if a config file exists
		return true
	end
end