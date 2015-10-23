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

	self.shaderEffects = Checkbox:new('SHADER EFFECTS', self.leftAlign, 310+175)
	self.shaderEffects.selected = config.graphics.shaderEffects

	self.particles = Checkbox:new('PARTICLES', self.leftAlign, 350+175)
	self.particles.selected = config.graphics.particles
	
	self.displayFPS = Checkbox:new('SHOW FPS', self.leftAlign, 390+175)
	self.displayFPS.selected = config.graphics.displayFPS
	
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
	
	local fsaaOptions = {0, 2, 4, 8, 16}
	self.fsaa = List:new('ANTIALIASING: ', fsaaOptions, self.leftAlign, 90+175, 400)
	self.fsaa:selectValue(config.display.flags.fsaa)
	self.fsaa:setText('{}x')

	self.musicVolume = Slider:new("MUSIC VOLUME: %d", 0, 100, config.audio.musicVolume, self.leftAlign+450, 50+175, 275, 50, font[24])
	self.musicVolume.changed = function() signal.emit('musicChanged', self.musicVolume.ratio) end
	self.soundVolume = Slider:new("SOUND VOLUME: %d",0, 100, config.audio.soundVolume, self.leftAlign+450, 150+175, 275, 50, font[24])
	self.soundVolume.changed = function() signal.emit('soundChanged', self.soundVolume.ratio) end
	
	-- applies current config settings
	self.back = Button:new("< BACK", self.leftAlign, love.window.getHeight()-80)
	self.back.activated = function()
		state.switch(menu) -- options can be accessed from multiple places in the game
	end

	self.apply = Button:new('APPLY CHANGES', self.leftAlign+170, love.window.getHeight()-80)
	self.apply.activated = function ()
		self:applyChanges()
		self.back.y = love.window.getHeight()-80
		self.apply.y = love.window.getHeight()-80
	end

	self:save()
end

function options:leave()
	local config = self:getConfig()

	signal.emit('soundChanged', config.audio.soundVolume/100)
	signal.emit('musicChanged', config.audio.musicVolume/100)
end

function options:applyChanges()
    self:save()
    self:load()

	return true
end

function options:mousepressed(x, y, button)
	if button == 'l' then
		self.vsync:mousepressed(x, y)
		self.fullscreen:mousepressed(x, y)
		self.borderless:mousepressed(x, y)
		self.shaderEffects:mousepressed(x, y)
		self.particles:mousepressed(x, y)
		self.displayFPS:mousepressed(x, y)
	end

	self.musicVolume:mousepressed(x, y, button)
	self.soundVolume:mousepressed(x, y, button)
	
	self.resolution:mousepressed(x, y, button)
	self.fsaa:mousepressed(x, y, button)
	
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
	self.shaderEffects:update(dt)
	self.particles:update(dt)
	self.displayFPS:update(dt)

	self.musicVolume:update(dt)
	self.soundVolume:update(dt)

	self.resolution:update(dt)
	self.fsaa:update(dt)

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
	self.shaderEffects:draw()
	self.particles:draw()
	self.displayFPS:draw()

	self.musicVolume:draw()
	self.soundVolume:draw()

	self.resolution:draw()
	self.fsaa:draw()

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
				borderless = false,
				fsaa = 0,
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
	}
	return o
end

function options:save()
	local o = {
		display = {
			width = self.resolution.options[self.resolution.selected][1],
			height = self.resolution.options[self.resolution.selected][2],

			-- these are the standard flags for love.window.setMode
			flags = {
				vsync = self.vsync.selected,
				fullscreen = self.fullscreen.selected,
				borderless = self.borderless.selected,
				fsaa = self.fsaa.options[self.fsaa.selected],
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
	elseif flags.fsaa ~= config.display.flags.fsaa then
		reload = true
	elseif flags.borderless ~= config.display.flags.borderless then
		reload = true
	end
	
	if reload then -- only reloads the window if needed
		love.window.setMode(config.display.width, config.display.height, config.display.flags)
	end

	game.effectsEnabled = config.graphics.shaderEffects
	game.particlesEnabled = config.graphics.particles
	game.displayFPS = config.graphics.displayFPS

	soundControl.soundVolume = config.audio.soundVolume/100
	soundControl.musicVolume = config.audio.musicVolume/100

	return true
end

function options:getConfig()
	assert(love.filesystem.exists(self.file), 'Tried to load config file, but it does not exist.')
	return love.filesystem.load(self.file)()
end