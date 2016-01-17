game = {}
objects = {}
bullets = {}

WINDOW_OFFSET = vector(love.graphics.getWidth()/2, love.graphics.getHeight()/2) -- used for screen size

function game:addObject(obj, tabl)
    if tabl == nil then
        tabl = objects
    end
    for i, v in pairs(tabl) do
        assert(v ~= obj)
    end
    table.insert(tabl, obj)
    --quadtree:addObject(obj) -- do not add the object to the quadtree on the first frame to avoid an error where they aren't placed correctly
    return obj
end
function game:addBullet(obj)
    return self:addObject(obj, bullets)
end

function game:removeObject(obj, tabl)
    if tabl == nil then
        tabl = objects
    end
    for i, v in ipairs(tabl) do
        if v == obj then
            table.remove(tabl, i)
            break
        end
    end
    quadtree:removeObject(obj, true)
    quadtree:removeObject(obj, false) -- this properly deletes enemies when they are on the border between 2 quads. it will check to delete for both the current pos and last pos. this is for a case where an enemy leaves a quad the frame before it dies
end
function game:removeBullet(obj)
    self:removeObject(obj, bullets)
end

function game:init()
    self:compileShaders()
    self.particles = Particles:new()
    self.screenShake = ScreenShake:new()
    self.hurt = Hurt:new()
    self.floatingMessages = FloatingMessages:new()
    self.highScore = HighScore:new()
    if highscoreList and highscoreList.init then
        highscoreList:init()
    end

    signal.emit('waveEnded')
	
	self.camera = Camera(0, 0)
	self.camera.scale = self.cameraZoom
end

function game:reset()
	self.worldSize = vector(3000, 2000)
	
    objects = {}
    bullets = {}
    quadtree = QuadTree:new(-self.worldSize.x/2-25, -self.worldSize.y/2-25, self.worldSize.x+50, self.worldSize.y+50)
    quadtree:subdivide()
    quadtree:subdivide()
	-- player will be added later, in character select

    if self.effectsEnabled == nil then
        self.effectsEnabled = false
    end

    if self.trackpadMode == nil then
        self.trackpadMode = false
    end

    self:compileShaders()
	
	if self.displayFPS == nil then
		self.displayFPS = false
	end
	if self.azertyMode == nil then
		self.azertyMode = false
	end
	if self.cameraZoom == nil then
		self.cameraZoom = 1
	end
	
	self.camera.scale = self.cameraZoom

    self:toggleEffects()

    self.background = GridBackground:new()

    self.time = 0
    self.firstWave = true
    self.startingWave = 0
    self.wave = self.startingWave
    self.timeToNextWave = 3
	self.waveTime = 0
    self._postWaveCalled = false
    self._preWaveCalled = false
    self.boss = nil
	
	
	self.camera.smoother = Camera.smooth.linear(200*self.camera.scale)
	self.camera.smooth.damped(.1)

    self.waveTimer = nil
    self:setupWaves()

    signal.emit('newGame')
end

function game:enter(prev)
    love.keyboard.setKeyRepeat(true)
    love.mouse.setVisible(true)
    love.mouse.setCursor(crosshair)

    self:compileShaders()

    if prev ~= pause then
	    state.push(charSelect)
        self:reset()
    end
end

function game:compileShaders()
    shaders = {}

    local bloom = shine.bloom()
    bloom.parameters = {
        samples = 4,
        quality = 1,
    }
    shaders.bloom = bloom

    local chroma = shine.separate_chroma()
    chroma.parameters = {
        radius = -1,
        angle = 5*math.pi/4
    }
    shaders.chroma = chroma

    local blur = shine.gaussianblur()
    blur.parameters = {
        sigma = 4
    }
    shaders.blur = blur

    pause_effect = bloom:chain(blur)
    default_effect = bloom
    post_effect = default_effect
end

function game:resized()
    --local dx = WINDOW_OFFSET.x*2 - love.graphics.getWidth()
    --local dy = WINDOW_OFFSET.y*2 - love.graphics.getHeight()
    --quadtree:resize(dx, dy)

    WINDOW_OFFSET = vector(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
end

function game:update(dt)
    -- this triggers when the game resolution changes
    --if WINDOW_OFFSET.x ~= love.graphics.getWidth()/2 or WINDOW_OFFSET.y ~= love.graphics.getHeight()/2 or
    --quadtree.width ~= love.graphics.getWidth()+50 or quadtree.height ~= love.graphics.getHeight()+50 then
     --   self:resized()
    --end
    
    if player.health <= 0 then -- death condition
        state.switch(restart)
    end

    for i,v in ipairs(objects) do
        v:update(dt)
        quadtree:updateObject(v)
    end

    for i, v in ipairs(objects) do
        if v.destroy then
            self:removeObject(v)
        end
    end

    for i,v in ipairs(bullets) do
        v:update(dt)
        quadtree:updateObject(v)
    end

    for i, v in ipairs(bullets) do
        if v.destroy then
            self:removeBullet(v)
        end
    end

    self.time = self.time + dt

    if self.waveTimer then
        self.prevT = self.waveTimer.running

        if math.floor(self.prevT) ~= math.floor(self.prevT+dt) then
            signal.emit('waveCountdown')
        end

        self.waveTimer:update(dt)
    end

    if self.particlesEnabled then
        self.particles:update(dt)
    end
    self.screenShake:update(dt)
    self.hurt:update(dt)
    self.background:update(dt)
    self.floatingMessages:update(dt)
    self.highScore:update(dt)

    if self.boss then
        if self.boss.health <= 0 then
            self.boss = nil
        end
    end

    if #objects == 1 and self.waves[self.wave+1] == nil and not (player.health <= 0) then
        state.switch(gameover)
    end

    if #objects == 1 and not self.waveTimer and self.boss == nil then
        if not self._postWaveCalled then
            self:onWaveEnd()
        end
    end

	
	-- baddddd
	local scale = 1/self.camera.scale
	
	local width, height = love.graphics.getWidth()/2, love.graphics.getHeight()/2
	local scalarHalfWidth = width * scale
	local scalarHalfHeight = height * scale
	
	local px, py = player.position.x, player.position.y
	
	
	local nx, ny = px, py
	
	if px + scalarHalfWidth > self.worldSize.x/2 then
		nx = self.worldSize.x/2 - scalarHalfWidth
	elseif px - scalarHalfWidth < -self.worldSize.x/2 then
		nx = -self.worldSize.x/2 + scalarHalfWidth
	end
	
	if py + scalarHalfHeight > self.worldSize.y/2 then
		ny = self.worldSize.y/2 - scalarHalfHeight
	elseif py - scalarHalfHeight < -self.worldSize.y/2 then
		ny = -self.worldSize.y/2 + scalarHalfHeight
	end
	
	self.camera:lockPosition(nx, ny) -- aim the camera at the player
	
	if love.graphics.getWidth() * scale >= self.worldSize.x then
		self.camera.x = 0
	end
	if love.graphics.getHeight() * scale >= self.worldSize.y then
		self.camera.y = 0
	end
end


function game:onWaveStart()
    if self._preWaveCalled then return end

    self.firstWave = false

    self:startWave()
    self.waveTimer = nil

    if self.boss ~= nil then
        signal.emit('bossSpawn')
    end

    self._postWaveCalled = false
    self._preWaveCalled = true
end

function game:onWaveEnd()
    if self._postWaveCalled then return end

    player.health = player.health + player.health * 0.1 + 1

    if self.waves[self.wave+1] ~= nil then
        if self.waves[self.wave+1].boss ~= nil then
            signal.emit('bossIncoming')
        end
    end

    self.waveTimer = cron.after(self.timeToNextWave, function()
        if not self._preWaveCalled then
            self:onWaveStart()
        end
    end)
	
	local waveTime = 0
	if self.waveStartTime then
		waveTime = self.time - self.waveStartTime
	end
    signal.emit('waveEnded', self.wave, waveTime)

    self._postWaveCalled = true
    self._preWaveCalled = false
end

function game:toggleEffects()
    if not self.effectsEnabled then
        old_post_effect = post_effect
        post_effect = function(func)
            func()
        end
    else
        if old_post_effect then
            post_effect = old_post_effect
        end
    end
end

function game:keypressed(key, isrepeat)
    for i,v in ipairs(objects) do
        if v.keypressed then
            v:keypressed(key, isrepeat)
        end
    end

    if key == "p" or key == "escape" then
        state.switch(pause)
    end
end

function game:mousepressed(x, y, mbutton)

end

function game:draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.setLineWidth(1)

    if state.current() ~= game then
        post_effect = pause_effect
    else
        post_effect = default_effect
    end

    self:toggleEffects()

    -- start post effect
    post_effect(function()

    local dx, dy = self.screenShake:getOffset()
	self.camera:attach()

    self.background:draw()

    if self.particlesEnabled then
        self.particles:draw()
    end

    for i,v in ipairs(objects) do
        v:draw()
    end
    for i,v in ipairs(bullets) do
        v:draw()
    end
	
    self.floatingMessages:drawDynamic()
	
	-- draws borders of the world
    love.graphics.setColor(255, 255, 255)
    love.graphics.setLineWidth(4)
	love.graphics.line(-self.worldSize.x/2, -self.worldSize.y/2, self.worldSize.x/2, -self.worldSize.y/2, self.worldSize.x/2, self.worldSize.y/2, -self.worldSize.x/2, self.worldSize.y/2, -self.worldSize.x/2, -self.worldSize.y/2)
	
	self.camera:detach()
	
    self.floatingMessages:drawStatic()

    self.hurt:draw()

    if self.waveText ~= nil and self.wave > 0 then
        self:drawPrimaryText()
    end

    if self.boss ~= nil then
        self:drawBossHealthBar()
    end 

    self:drawPlayerHealthBar()
    self:drawBossIncoming()
	
	self.highScore:draw()

    love.graphics.setFont(font[16])
	if self.displayFPS then
		love.graphics.print(love.timer.getFPS() .. " FPS", 5, 5)
	end

    end) -- end post effect
end

function game:drawBossIncoming()
    love.graphics.setFont(font[48])
    if self.waveTimer ~= nil and self.waveTimer.time - self.waveTimer.running <= 3 and #objects == 1 then
        local t = self.waveTimer.time - self.waveTimer.running
        love.graphics.print(math.ceil(t), love.graphics.getWidth()/2 - love.graphics.getFont():getWidth(math.ceil(t))/2, 150)

        if self.waves[self.wave+1] ~= nil then
            if self.waves[self.wave+1].boss ~= nil then
                love.graphics.print("BOSS INCOMING", love.graphics.getWidth()/2 - love.graphics.getFont():getWidth("BOSS INCOMING")/2, 100)
            end
        end

    end
end

function game:drawPlayerHealthBar()
    if state.current() ~= game then return end

    local height = 10
    local multiplier = player.health / player.maxHealth
    local width = love.graphics.getWidth() * multiplier

    love.graphics.setColor(204, 15, 10, 255)
    love.graphics.rectangle("fill", love.graphics.getWidth()/2 - width/2, love.graphics.getHeight()-height, width/2, height)
    love.graphics.rectangle("fill", love.graphics.getWidth()/2, love.graphics.getHeight()-height, width/2, height)
    love.graphics.setColor(255, 255, 255)
end

function game:drawBossHealthBar()
    love.graphics.setColor(255, 255, 255)
    local multiplier = self.boss.health/self.boss.maxHealth
    love.graphics.rectangle("fill", 50, 50, (love.graphics.getWidth()-100)*multiplier, 25)

    local text = string.upper(self.boss.name)
    love.graphics.setFont(fontLight[24])
    love.graphics.print(text, love.graphics.getWidth()/2-love.graphics.getFont():getWidth(text)/2, 10)
end

function game:setPrimaryText(text)
    self.waveText = text
    self.waveTextTime = 3
end

function game:drawPrimaryText()
    if self.waveTextTime <= 0 or self.firstWave then return end
    self.waveTextTime = self.waveTextTime - love.timer.getDelta()

    love.graphics.setLineWidth(1)
    love.graphics.setFont(font[48])
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print(self.waveText, love.graphics.getWidth()/2 - love.graphics.getFont():getWidth(self.waveText)/2, 100)
end

function game:setupWaves()
    self.waves = {}
    self.waves[1] = {
        blobs = 15,
        sweepers = 0,
		healers = 0,
		tanks = 0,
    }
    self.waves[2] = {
        blobs = 25,
        sweepers = 0,
		tanks = 1,
    }
    self.waves[3] = {
        blobs = 18,
        sweepers = 3,
    }
    self.waves[4] = {
        blobs = 25,
        sweepers = 0,
        healers = 2,
    }
    self.waves[5] = {
        blobs = 25,
        tanks = 3,
        healers = 2,
    }
    self.waves[6] = {
        blobs = 35,
		sweepers = 6,
    }
    self.waves[7] = {
        tanks = 5,
        healers = 3,
    }
    self.waves[8] = {
        blobs = 30,
        healers = 3,
        tanks = 4,
    }
    self.waves[9] = {
        blobs = 25,
        healers = 3,
        tanks = 3,
        sweepers = 8,
    }
    self.waves[10] = {
        boss = Megabyte,
    }
end

function game:startWave()
    self.waveTimer = nil
	self.waveStartTime = self.time -- set the wave start time to the game time

    if self.wave == nil then
        self.wave = self.startingWave
    elseif self.waves[self.wave+1] == nil then
        state.switch(gameover)
    else
        self.wave = self.wave + 1
    end

    self:setPrimaryText("WAVE "..self.wave)

    if self.waves[self.wave] ~= nil and self.wave ~= self.startingWave then
        self:spawnEnemies()
    end
end

function game:spawnEnemies(w)
    local wave = nil
    if w ~= nil then
        wave = w
    else
        wave = self.wave
    end
    local currentWave = self.waves[wave]

    if currentWave.blobs ~= nil then
        for i=1, currentWave.blobs do
            local p = vector(math.random(-self.worldSize.x/2, self.worldSize.x/2), 
                             math.random(-self.worldSize.y/2, self.worldSize.y/2))
            p = p + (p - player.position):normalized()*150
            local b = Blob:new(p)
            self:addObject(b)
        end
    end

    if currentWave.sweepers ~= nil then
        -- number of line enemies to spawn
        local num = currentWave.sweepers
        -- margin from the sides of the screen
        local margin = 25
        local w = (self.worldSize.x)
        local h = (self.worldSize.y-margin*2)/num
        local leftEdge = margin
        local rightEdge = w - margin

        for i=1, num do
            local y = h*(i-1) + margin + h/2

            self:addObject(Sweeper:new(
                vector(leftEdge - self.worldSize.x/2, y - self.worldSize.y/2),
                vector(rightEdge - self.worldSize.x/2, y - self.worldSize.y/2)
            ))
        end
    end
	
	if currentWave.healers ~= nil then
        for i=1, currentWave.healers do
            local p = vector(math.random(-self.worldSize.x/2, self.worldSize.x/2), 
                             math.random(-self.worldSize.y/2, self.worldSize.y/2))
            p = p + (p - player.position):normalized()*250
            local b = Healer:new(p)
            self:addObject(b)
        end
    end
	
	if currentWave.tanks ~= nil then
        for i=1, currentWave.tanks do
            local p = vector(math.random(-self.worldSize.x/2, self.worldSize.x/2), 
                             math.random(-self.worldSize.y/2, self.worldSize.y/2))
            p = p + (p - player.position):normalized()*150
            local b = Tank:new(p)
            self:addObject(b)
        end
    end

    if currentWave.ninjas ~= nil then
        for i=1, currentWave.ninjas do
            local p = vector(math.random(-self.worldSize.x/2, self.worldSize.x/2), 
                             math.random(-self.worldSize.y/2, self.worldSize.y/2))
            p = p + (p - player.position):normalized()*150
            local b = Ninja:new(p)
            self:addObject(b)
        end
    end

    if currentWave.boss ~= nil then
        local b = currentWave.boss:new()
        self.boss = self:addObject(b)
    end
end