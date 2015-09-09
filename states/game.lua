game = {}
objects = {}
bullets = {}

WINDOW_OFFSET = vector(love.graphics.getWidth()/2, love.graphics.getHeight()/2)

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

    self.particles = Particles:new()
    self.screenShake = ScreenShake:new()

    quadtree = QuadTree:new(-WINDOW_OFFSET.x-25, -WINDOW_OFFSET.y-25, love.graphics.getWidth()+50, love.graphics.getHeight()+50)
    quadtree:subdivide()
    quadtree:subdivide()
    player = self:addObject(Player:new())

    self.paused = false

    if self.effectsEnabled == nil then
        self.effectsEnabled = false
        self:toggleEffects()
    else
        self:toggleEffects()
    end

    self.time = 0
    self.ptime = 0
    self.deltaTimeMultiplier = 1

    self.startingWave = 0
    self.timeToNextWave = 2
    self._postWaveCalled = false
    self._preWaveCalled = false

    self:setupWaves()
    self:startWave()
end

function game:enter(prev)
    love.keyboard.setKeyRepeat(true)
    love.mouse.setVisible(true)

    crosshairImage = love.graphics.newImage("img/crosshair.png")
    cursorImage = love.graphics.newImage("img/cursor.png")
    crosshair = love.mouse.newCursor(crosshairImage:getData(), 16, 16)
    cursor = love.mouse.newCursor(cursorImage:getData(), 12, 12)
    love.mouse.setCursor(crosshair)

    if self.deltaTimeMultiplier < 1 then
        tween(.75, self, {deltaTimeMultiplier=1}, 'inQuad', function() end)
    end

    if not self._postWaveCalled then
        self:onWaveEnd()
    else
        self:onWaveStart()
    end
end

function game:update(dt)
    if self.paused then return end
    if self.ptime > 0 then
        self.ptime = self.ptime - dt
        return
    end

    -- this triggers when the game resolution changes
    if WINDOW_OFFSET.x ~= love.graphics.getWidth()/2 or WINDOW_OFFSET.y ~= love.graphics.getHeight()/2 then
        local dx = WINDOW_OFFSET.x*2 - love.graphics.getWidth()
        local dy = WINDOW_OFFSET.y*2 - love.graphics.getHeight()
        quadtree:resize(dx, dy)

        WINDOW_OFFSET = vector(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
    end
    
    dt = dt * self.deltaTimeMultiplier

    self.time = self.time + dt * 0.75

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

    if self.waveTimer then
        self.waveTimer:update(dt)
    end

    if self.particlesEnabled then
        self.particles:update(dt)
    end
    self.screenShake:update(dt)

    if self.boss then
        if self.boss.health <= 0 then
            self.boss = nil
        end
    end

    if #objects == 1 and not self.waveTimer and self.boss == nil and self.waves[self.wave+1] ~= nil then
        if not self._postWaveCalled then
            self:onWaveEnd()
        end
    end
end

function game:onWaveStart()
    if self._preWaveCalled then return end

    self:startWave()
    self.waveTimer = nil

    self._postWaveCalled = false
    self._preWaveCalled = true
end

function game:onWaveEnd()
    if self._postWaveCalled then return end

    self.waveTimer = cron.after(self.timeToNextWave, function()
        if not self._preWaveCalled then
            self:onWaveStart()
        end
    end)

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

    if key == "b" then
        self.effectsEnabled = not self.effectsEnabled

        self:toggleEffects()
    end

    if key == "p" then
        self.paused = not self.paused
    end
end

function game:mousepressed(x, y, mbutton)

end

function game:draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.setLineWidth(1)

    if self.effectsEnabled then
        if self.paused then
            post_effect = pause_effect
        else
            post_effect = default_effect
        end
    end

    local dx, dy = self.screenShake:getOffset()

    -- start post effect
    post_effect(function()

    love.graphics.translate(love.graphics.getWidth()/2+dx, love.graphics.getHeight()/2+dy)

    if self.particlesEnabled then
        self.particles:draw()
    end

    for i,v in ipairs(objects) do
        v:draw()
    end
    for i,v in ipairs(bullets) do
        v:draw()
    end

	love.graphics.setColor(160, 160, 160, 16*math.abs(math.cos(self.time))+12)
    quadtree:draw()
	
    love.graphics.translate(-love.graphics.getWidth()/2, -love.graphics.getHeight()/2)

    love.graphics.setColor(255, 255, 255, 255)

    if self.waveText ~= nil and self.wave > 0 then
        self:drawPrimaryText()
    end

    if self.boss ~= nil then
        self:drawBossHealthBar()
    end 

    self:drawPlayerHealthBar()

    love.graphics.setFont(font[16])
    love.graphics.print(love.timer.getFPS(), 5, 5)
    love.graphics.print(MOUSE_VALUE*1000 .. "ms", 5, 20)

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
    end) -- end post effect

    if self.paused then
        love.graphics.setColor(0, 0, 0, 80)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

        love.graphics.setColor(255, 255, 255)
        love.graphics.setFont(fontBold[20])
        love.graphics.print("PAUSED", love.graphics.getWidth()/2 - love.graphics.getFont():getWidth("PAUSED")/2, love.graphics.getHeight()/2 - love.graphics.getFont():getHeight("PAUSED")/2)
    end
end

function game:shakeScreen(time, strength)
    self.screenShake:shake(time, strength)
end

function game:drawPlayerHealthBar()
    local height = 8
    local multiplier = player.health / player.maxHealth

    love.graphics.setColor(204, 15, 10, 128)
    love.graphics.rectangle("fill", 0, love.graphics.getHeight()-height, love.graphics.getWidth()*multiplier, height)
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
    if self.waveTextTime <= 0 then return end
    self.waveTextTime = self.waveTextTime - love.timer.getDelta()

    love.graphics.setFont(font[48])
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(r, g, b)
    love.graphics.print(self.waveText, love.graphics.getWidth()/2 - love.graphics.getFont():getWidth(self.waveText)/2, 100)
end

function game:setupWaves()
    self.waves = {}
    self.waves[1] = {
        blobs = 10,
        sweepers = 0,
		healers = 3,
		tanks = 4,
    }
    self.waves[2] = {
        blobs = 15,
        sweepers = 2,
    }
    self.waves[3] = {
        blobs = 20,
        sweepers = 4,
    }
    self.waves[4] = {
        blobs = 25,
        sweepers = 6,
    }
    self.waves[5] = {
        blobs = 50,
    }
    self.waves[6] = {
        blobs = 25,
        sweepers = 12,
    }
    self.waves[7] = {
        boss = Megabyte,
    }
end

function game:startWave()
    self.waveTimer = nil

    if self.wave == nil then
        self.wave = self.startingWave
    elseif self.waves[self.wave+1] == nil then
        return
    else
        self.wave = self.wave + 1
    end

    self:setPrimaryText("WAVE "..self.wave)

    if self.waves[self.wave] ~= nil then
        self:spawnEnemies()
    end
end

function game:spawnEnemies()
    local currentWave = self.waves[self.wave]

    if currentWave.blobs ~= nil then
        for i=1, self.waves[self.wave].blobs do
            local b = Blob:new(
                vector(math.random(0, love.graphics.getWidth())-WINDOW_OFFSET.x, math.random(0, love.graphics.getHeight())-WINDOW_OFFSET.y)
            )
            self:addObject(b)
        end
    end

    if currentWave.sweepers ~= nil then
        -- number of line enemies to spawn
        local num = self.waves[self.wave].sweepers
        -- margin from the sides of the screen
        local margin = 25
        local h = (love.graphics.getHeight()-margin)/num
        local w = (love.graphics.getWidth()-margin)
        for i=1, num do
            self:addObject(LineEnemy:new(
                vector(margin-WINDOW_OFFSET.x, (margin*2+h*(i-1))-WINDOW_OFFSET.y),
                vector(w-WINDOW_OFFSET.x-margin, (margin*2+h*(i-1))-WINDOW_OFFSET.y)
            ))
        end
    end
	
	if currentWave.healers ~= nil then
        for i=1, self.waves[self.wave].healers do
            local b = Healer:new(
                vector(math.random(0, love.graphics.getWidth())-WINDOW_OFFSET.x, math.random(0, love.graphics.getHeight())-WINDOW_OFFSET.y)
            )
            self:addObject(b)
        end
    end
	
	if currentWave.tanks ~= nil then
        for i=1, self.waves[self.wave].tanks do
            local b = Tank:new(
                vector(math.random(0, love.graphics.getWidth())-WINDOW_OFFSET.x, math.random(0, love.graphics.getHeight())-WINDOW_OFFSET.y)
            )
            self:addObject(b)
        end
    end

    if currentWave.boss ~= nil then
        local b = currentWave.boss:new()
        self.boss = self:addObject(b)
    end
end

function game:addAllObjectsToQuadtree()
    for i, o in ipairs(objects) do
        quadtree:addObject(o)
    end

    for i, o in ipairs(bullets) do
        quadtree:addObject(o)
    end

    quadtree:addObject(player)
end