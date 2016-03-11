options = {}
-- this is out here because it needs to be accessible before options:init() is called
options.file = 'config.txt'
options.version = 2

function options:init()
	self.leftAlign = 75
end

function options:enter()
	local config = nil
	if not love.filesystem.exists(self.file) then
		config = self:getDefaultConfig()
	else
		config = self:getConfig()
	end
	
	local y = 365 -- starting point
	local sep = 40 -- how much to seperate each item by
	
	-- basic screen settings
    self.vsync = Checkbox:new('VERTICAL SYNC', self.leftAlign, y)
	self.vsync.selected = config.display.flags.vsync
	
	y = y+sep
	
	self.fullscreen = Checkbox:new('FULLSCREEN', self.leftAlign, y)
	self.fullscreen.selected = config.display.flags.fullscreen
	
	y = y+sep
	
	self.borderless = Checkbox:new('BORDERLESS', self.leftAlign, y)
	self.borderless.selected = config.display.flags.borderless
	
	y = y+sep
	
	self.highdpi = Checkbox:new('HIGH-DPI', self.leftAlign, y)
	self.highdpi.selected = config.display.flags.highdpi
	
	y = y+sep

	y = y + 20 -- extra space between groups
	
	
	-- graphics and game settings
	self.shaderEffects = Checkbox:new('SHADER EFFECTS', self.leftAlign, y)
	self.shaderEffects.selected = config.graphics.shaderEffects
	
	self.azerty = Checkbox:new('AZERTY KEYBOARD', self.leftAlign + 300, y)
	self.azerty.selected = config.graphics.azerty
	
	y = y+sep

	self.particles = Checkbox:new('PARTICLES', self.leftAlign, y)
	self.particles.selected = config.graphics.particles
	
	y = y+sep
	
	self.displayFPS = Checkbox:new('SHOW FPS', self.leftAlign, y)
	self.displayFPS.selected = config.graphics.displayFPS
	
	y = y+sep

	self.trackpad = Checkbox:new('TRACKPAD MODE', self.leftAlign, y)
	self.trackpad.selected = config.input.trackpadMode
	
	
	-- list items
	
	-- Takes all available resolutions
	local resTable = love.window.getFullscreenModes(1)
	local resolutions = {}
	--local screenWidth, screenHeight = love.graphics.getDesktopDimensions() -- finish this
	for k, res in pairs(resTable) do
		--if res.width > 800 then -- cuts off any resolutions with a width under 800
		--if res.width <= screenWidth and res.height <= screenHeight then
			table.insert(resolutions, {res.width, res.height})
		--end
	end
	
	-- add a resolution for an experimental feature to play across multiple monitors
	local windowCount = love.window.getDisplayCount()
	--[[
	local multiWidth = 0
	local multiHeight = 0
	if windowCount > 1 then
		for i = 1, windowCount do
			local width, height = love.window.getDesktopDimensions(i)
			multiWidth = multiWidth + width -- add together the width of all connected monitors
			if height > multiHeight then -- find the largest monitor height
				if multiHeight > 0 then
					table.insert(resolutions, {multiWidth, multiHeight})
				end
				multiHeight = height
			end
		end
		table.insert(resolutions, {multiWidth, multiHeight})
	end
	]]
	
	--self.multiHeight = multiHeight

	-- sort resolutions from smallest to biggest
	table.sort(resolutions, function(a, b) return a[1]*a[2] < b[1]*b[2] end)
	
	local optionWidth = 120
	y = 225
	
	self.resolution = List:new('RESOLUTION: ', resolutions, self.leftAlign, y, 400)
	self.resolution:selectTable({config.display.width, config.display.height})
	self.resolution:setText('{1}x{2}')
	self.resolution:setOptionWidth(optionWidth)
	
	y = y+sep
	
	local msaaOptions = {0, 2, 4, 8, 16}
	self.msaa = List:new('ANTIALIASING: ', msaaOptions, self.leftAlign, y, 400)
	self.msaa:selectValue(config.display.flags.msaa)
	self.msaa:setText('{}x')
	self.msaa:setOptionWidth(optionWidth)
	
	y = y+sep
	
	local fullscreenOptions = {"desktop", "exclusive"}
	self.fullscreenMode = List:new("FULLSCREEN TYPE: ", fullscreenOptions, self.leftAlign, y, 400)
	self.fullscreenMode:selectValue(config.display.flags.fullscreentype)
	self.fullscreenMode:setText('{}')
	self.fullscreenMode:setOptionWidth(optionWidth)
	
	local monitorOptions = {}
	for i = 1, windowCount do
		table.insert(monitorOptions, i)
	end
	self.monitorSelect = List:new("DISPLAY MONITOR: ", monitorOptions, self.leftAlign, y+400, 400)
	self.monitorSelect:selectValue(config.display.flags.display)
	self.monitorSelect:setText('{}')
	self.monitorSelect:setOptionWidth(optionWidth)
	
	y = y+sep
	
	
	local x = self.leftAlign+450
	y = 225
	sep = 100
	
	-- SLIDER ITEMS
	self.musicVolume = Slider:new("MUSIC VOLUME: %d", 0, 100, config.audio.musicVolume, x, y, 275, 50, font[24])
	self.musicVolume.changed = function() signal.emit('musicChanged', self.musicVolume.ratio) end
	
	y = y + sep
	
	self.soundVolume = Slider:new("SOUND VOLUME: %d", 0, 100, config.audio.soundVolume, x, y, 275, 50, font[24])
	self.soundVolume.changed = function() signal.emit('soundChanged', self.soundVolume.ratio) end
	
	y = y + sep
	
	self.cameraZoom = Slider:new("CAMERA ZOOM: %.1f", .7, 2, config.graphics.cameraZoom, x, y, 275, 50, font[24])
	--self.cameraZoom.changed = function() signal.emit('zoomChanged', self.cameraZoom.ratio) end
	-- not ideal
	self.cameraZoom.roundTo = 1
	--self.cameraZoom.changed = function() game.cameraZoom = self.cameraZoom.value end
	
	local bottomMargin = 60
	
	-- applies current config settings
	self.back = Button:new("< BACK", self.leftAlign, love.graphics.getHeight() - bottomMargin)
	self.back.activated = function()
		state.switch(menu) -- options can be accessed from multiple places in the game
	end

	self.apply = Button:new('APPLY CHANGES', self.leftAlign+170, love.graphics.getHeight()-bottomMargin)
	self.apply.activated = function ()
		self:applyChanges()
		self.back.y = love.graphics.getHeight()-bottomMargin
		self.apply.y = love.graphics.getHeight()-bottomMargin
	end

	self:save()
end

function options:leave()
	self:load()
end

function options:applyChanges()
    self:save()
    self:load()

	return true
end

function options:mousepressed(x, y, button)
	if button == 1 then
		self.vsync:mousepressed(x, y)
		self.fullscreen:mousepressed(x, y)
		self.borderless:mousepressed(x, y)
		self.highdpi:mousepressed(x, y)
		self.shaderEffects:mousepressed(x, y)
		self.particles:mousepressed(x, y)
		self.displayFPS:mousepressed(x, y)
		self.trackpad:mousepressed(x, y)
		self.azerty:mousepressed(x, y)
	end

	self.musicVolume:mousepressed(x, y, button)
	self.soundVolume:mousepressed(x, y, button)
	self.cameraZoom:mousepressed(x, y, button)
	
	self.resolution:mousepressed(x, y, button)
	self.msaa:mousepressed(x, y, button)
	self.fullscreenMode:mousepressed(x, y, button)
	self.monitorSelect:mousepressed(x, y, button)
	
	self.back:mousepressed(x, y, button)
	self.apply:mousepressed(x, y, button)
end

function options:keypressed(key)
	if key == "escape" then
		state.pop()
	end
end

function options:update(dt)
	self.vsync:update(dt)
	self.fullscreen:update(dt)
	self.borderless:update(dt)
	self.highdpi:update(dt)
	self.shaderEffects:update(dt)
	self.particles:update(dt)
	self.displayFPS:update(dt)
	self.trackpad:update(dt)
	self.azerty:update(dt)

	self.musicVolume:update(dt)
	self.soundVolume:update(dt)
	self.cameraZoom:update(dt)

	self.resolution:update(dt)
	self.msaa:update(dt)
	self.fullscreenMode:update(dt)
	self.monitorSelect:update(dt)

	self.back:update(dt)
	self.apply:update(dt)
	
	
	-- update volumes without applying changes
	soundControl.musicVolume = self.musicVolume.ratio
	soundControl.soundVolume = self.soundVolume.ratio
end

function options:draw()
	love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 120+55)

    love.graphics.setFont(fontBold[72])
    love.graphics.setColor(0, 0, 0)
    love.graphics.print('OPTIONS', 75, 70)

	self.vsync:draw()
	self.fullscreen:draw()
	self.borderless:draw()
	self.highdpi:draw()
	self.shaderEffects:draw()
	self.particles:draw()
	self.displayFPS:draw()
	self.trackpad:draw()
	self.azerty:draw()

	self.musicVolume:draw()
	self.soundVolume:draw()
	self.cameraZoom:draw()

	self.resolution:draw()
	self.msaa:draw()
	self.fullscreenMode:draw()
	self.monitorSelect:draw()

	self.back:draw()
	self.apply:draw()
end

function options:getDefaultConfig()
	local o = {
		version = 0,
		display = {
			width = 1024,
			height = 768,

			-- these are the standard flags for love.window.setMode
			flags = {
				vsync = false,
				fullscreen = false,
				fullscreentype = "desktop",
				display = 1,
				highdpi = false,
				borderless = false,
				msaa = 0,
			},
		},
		graphics = {
			shaderEffects = true,
			particles = true,
			displayFPS = false,
			azerty = false,
			cameraZoom = 1,
		},
		audio = {
			soundVolume = 100,
			musicVolume = 80,
		},
		input = {
			trackpadMode = false,
		},
	}
	return o
end

function options:save()
	local o = {
		version = self.version,
		display = {
			width = self.resolution.options[self.resolution.selected][1],
			height = self.resolution.options[self.resolution.selected][2],

			-- these are the standard flags for love.window.setMode
			flags = {
				vsync = self.vsync.selected,
				fullscreen = self.fullscreen.selected,
				borderless = self.borderless.selected,
				highdpi = self.highdpi.selected,
				msaa = self.msaa.options[self.msaa.selected],
				fullscreentype = self.fullscreenMode.options[self.fullscreenMode.selected],
				display = self.monitorSelect.options[self.monitorSelect.selected],
			},
		},
		graphics = {
			shaderEffects = self.shaderEffects.selected,
			particles = self.particles.selected,
			displayFPS = self.displayFPS.selected,
			azerty = self.azerty.selected,
			cameraZoom = self.cameraZoom.value,
		},
		audio = {
			musicVolume = self.musicVolume.value,
			soundVolume = self.soundVolume.value,
		},
		input = {
			trackpadMode = self.trackpad.selected,
		},
	}
	love.filesystem.write(self.file, serialize(o))
end

function options:load()
	local config = self:getConfig()

	-- old config file
	if (config.version == nil) or (self.version > config.version) then
		local newConfig = self:getDefaultConfig()

		-- this will port over old config values to a new config file, based on the default
		-- if there are missing values, it replaces them with the default setting
		for i, category in pairs(newConfig) do
			if type(category) == 'table' then
				for j, value in pairs(category) do
					if config[i][j] == nil then
						config[i][j] = value

					-- table within a table (right now this should only be the window flags)
					elseif type(value) == 'table' then
						for k, flag in pairs(value) do
							if config[i][j][k] == nil then
								config[i][j][k] = flag
							end
						end
					end
				end
			end
		end
	end

	-- detects if any window settings are changed
	local reload = false
	local width, height, flags = love.window.getMode()
	if width ~= config.display.width or height ~= config.display.height then
		reload = true
	elseif flags.fullscreen ~= config.display.flags.fullscreen then
		reload = true
	elseif flags.vsync ~= config.display.flags.vsync then
		reload = true
	elseif flags.msaa ~= config.display.flags.msaa then
		reload = true
	elseif flags.borderless ~= config.display.flags.borderless then
		reload = true
	elseif flags.highdpi ~= config.display.flags.highdpi then
		reload = true
	elseif flags.fullscreentype ~= config.display.flags.fullscreentype then
		reload = true
	elseif flags.display ~= config.display.flags.display then
		reload = true
	end
	
	if love.window.getDisplayCount() > 1 then
		local width, height = love.window.getDesktopDimensions(flags.display)
		if config.display.width > width then
			config.display.flags.x = 0
			if self.multiHeight then
				--config.display.flags.y = (self.multiHeight - height) * -1
			end
		end
	end
	
	if reload then -- only reloads the window if needed
		love.window.setMode(config.display.width, config.display.height, config.display.flags)
	end

	game.effectsEnabled = config.graphics.shaderEffects
	game.particlesEnabled = config.graphics.particles
	game.displayFPS = config.graphics.displayFPS
	game.azertyMode = config.graphics.azerty
	game.cameraZoom = config.graphics.cameraZoom
	game.trackpadMode = config.input.trackpadMode

	soundControl.soundVolume = config.audio.soundVolume/100
	soundControl.musicVolume = config.audio.musicVolume/100

	return true
end

function options:getConfig()
	if not self:configFileExists() then
		return self:getDefaultConfig()
	else
		return love.filesystem.load(self.file)()
	end
end

function options:configFileExists()
	return love.filesystem.exists(self.file)
end