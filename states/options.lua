options = {}
-- this is out here because it needs to be accessible before options:init() is called
options.file = 'config.txt'

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
	
    self.vsync = Checkbox:new('VERTICAL SYNC', self.leftAlign, 150+175)
	self.vsync.selected = config.display.flags.vsync
	
	self.fullscreen = Checkbox:new('FULLSCREEN', self.leftAlign, 190+175)
	self.fullscreen.selected = config.display.flags.fullscreen
	
	self.borderless = Checkbox:new('BORDERLESS', self.leftAlign, 230+175)
	self.borderless.selected = config.display.flags.borderless
	
	self.desktopFullscreen = Checkbox:new('DESKTOP FULLSCREEN', self.leftAlign, 270+175)
	self.desktopFullscreen.selected = config.display.flags.fullscreentype == "desktop"
	
	self.highdpi = Checkbox:new('HIGH-DPI', self.leftAlign, 310+175)
	self.highdpi.selected = config.display.flags.highdpi

	self.shaderEffects = Checkbox:new('SHADER EFFECTS', self.leftAlign, 360+175)
	self.shaderEffects.selected = config.graphics.shaderEffects

	self.particles = Checkbox:new('PARTICLES', self.leftAlign, 400+175)
	self.particles.selected = config.graphics.particles
	
	self.displayFPS = Checkbox:new('SHOW FPS', self.leftAlign, 440+175)
	self.displayFPS.selected = config.graphics.displayFPS

	self.trackpad = Checkbox:new('TRACKPAD MODE', self.leftAlign, 480+175)
	self.trackpad.selected = config.input.trackpadMode
	
	-- Takes all available resolutions
	local resTable = love.window.getFullscreenModes(1)
	local resolutions = {}
	for k, res in pairs(resTable) do
		if res.width > 800 then -- cuts off any resolutions with a width under 800
			table.insert(resolutions, {res.width, res.height})
		end
	end

	-- sort resolutions from smallest to biggest
	table.sort(resolutions, function(a, b) return a[1]*a[2] < b[1]*b[2] end)
	
	self.resolution = List:new('RESOLUTION: ', resolutions, self.leftAlign, 50+175, 400)
	self.resolution.listType = 'resolution'
	self.resolution:selectTable({config.display.width, config.display.height})
	self.resolution:setText('{1}x{2}')
	
	local msaaOptions = {0, 2, 4, 8, 16}
	self.msaa = List:new('ANTIALIASING: ', msaaOptions, self.leftAlign, 90+175, 400)
	self.msaa:selectValue(config.display.flags.msaa)
	self.msaa:setText('{}x')

	self.musicVolume = Slider:new("MUSIC VOLUME: %d", 0, 100, config.audio.musicVolume, self.leftAlign+450, 50+175, 275, 50, font[24])
	self.musicVolume.changed = function() signal.emit('musicChanged', self.musicVolume.ratio) end
	self.soundVolume = Slider:new("SOUND VOLUME: %d",0, 100, config.audio.soundVolume, self.leftAlign+450, 150+175, 275, 50, font[24])
	self.soundVolume.changed = function() signal.emit('soundChanged', self.soundVolume.ratio) end
	
	-- applies current config settings
	self.back = Button:new("< BACK", self.leftAlign, love.graphics.getHeight()-80)
	self.back.activated = function()
		state.switch(menu) -- options can be accessed from multiple places in the game
	end

	self.apply = Button:new('APPLY CHANGES', self.leftAlign+170, love.graphics.getHeight()-80)
	self.apply.activated = function ()
		self:applyChanges()
		self.back.y = love.graphics.getHeight()-80
		self.apply.y = love.graphics.getHeight()-80
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
		self.desktopFullscreen:mousepressed(x, y)
		self.highdpi:mousepressed(x, y)
		self.shaderEffects:mousepressed(x, y)
		self.particles:mousepressed(x, y)
		self.displayFPS:mousepressed(x, y)
		self.trackpad:mousepressed(x, y)
	end

	self.musicVolume:mousepressed(x, y, button)
	self.soundVolume:mousepressed(x, y, button)
	
	self.resolution:mousepressed(x, y, button)
	self.msaa:mousepressed(x, y, button)
	
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
	self.desktopFullscreen:update(dt)
	self.highdpi:update(dt)
	self.shaderEffects:update(dt)
	self.particles:update(dt)
	self.displayFPS:update(dt)
	self.trackpad:update(dt)

	self.musicVolume:update(dt)
	self.soundVolume:update(dt)

	self.resolution:update(dt)
	self.msaa:update(dt)

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
	self.desktopFullscreen:draw()
	self.highdpi:draw()
	self.shaderEffects:draw()
	self.particles:draw()
	self.displayFPS:draw()
	self.trackpad:draw()

	self.musicVolume:draw()
	self.soundVolume:draw()

	self.resolution:draw()
	self.msaa:draw()

	self.back:draw()
	self.apply:draw()
end

function options:getDefaultConfig()
	local o = {
		display = {
			width = 1024,
			height = 768,

			-- these are the standard flags for love.window.setMode
			flags = {
				vsync = false,
				fullscreen = false,
				fullscreentype = "desktop",
				highdpi = false,
				borderless = false,
				msaa = 0,
			},
		},
		graphics = {
			shaderEffects = true,
			particles = true,
			displayFPS = false,
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
	local fullscreenType = "desktop"
	if not self.desktopFullscreen.selected then
		fullscreenType = "exclusive"
	end

	local o = {
		display = {
			width = self.resolution.options[self.resolution.selected][1],
			height = self.resolution.options[self.resolution.selected][2],

			-- these are the standard flags for love.window.setMode
			flags = {
				vsync = self.vsync.selected,
				fullscreen = self.fullscreen.selected,
				borderless = self.borderless.selected,
				fullscreentype = fullscreenType,
				highdpi = self.highdpi.selected,
				msaa = self.msaa.options[self.msaa.selected],
			},
		},
		graphics = {
			shaderEffects = self.shaderEffects.selected,
			particles = self.particles.selected,
			displayFPS = self.displayFPS.selected,
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
		config.display.flags.fullscreen = true
		if self.fullscreen then
			self.fullscreen.selected = true
		end
		reload = true
	end
	
	if reload then -- only reloads the window if needed
		love.window.setMode(config.display.width, config.display.height, config.display.flags)
	end

	game.effectsEnabled = config.graphics.shaderEffects
	game.particlesEnabled = config.graphics.particles
	game.displayFPS = config.graphics.displayFPS

	game.trackpadMode = config.input.trackpadMode

	soundControl.soundVolume = config.audio.soundVolume/100
	soundControl.musicVolume = config.audio.musicVolume/100

	return true
end

function options:getConfig()
	assert(love.filesystem.exists(self.file), 'Tried to load config file, but it does not exist.')
	return love.filesystem.load(self.file)()
end