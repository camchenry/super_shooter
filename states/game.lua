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
    quadtree:addObject(obj)
    return obj
end
function game:addBullet(obj)
    return self:addObject(obj, bullets)
end

function game:removeObject(obj, tabl)
    if tabl == nil then
        tabl = objects
    end
    for i, v in pairs(tabl) do
        if v == obj then
            table.remove(tabl, i)
            break
        end
    end
    quadtree:removeObject(obj, true)
end
function game:removeBullet(obj)
    self:removeObject(obj, bullets)
end

function game:enter()
    love.keyboard.setKeyRepeat(true)
    love.mouse.setVisible(true)

    cursorImage = love.graphics.newImage("img/cursor.png")
    cursor = love.mouse.newCursor(cursorImage:getData(), 16, 16)
    love.mouse.setCursor(cursor)
    local bloom = shine.bloom()
    bloom.parameters = {
        samples = 4,
        quality = 1,
    }

    local chroma = shine.separate_chroma()
    chroma.parameters = {
        radius = -1,
        angle = 5*math.pi/4
    }

    local blur = shine.gaussianblur()
    blur.parameters = {
        sigma = 3
    }

    default_effect = chroma:chain(bloom)
    pause_effect = bloom:chain(blur)
    post_effect = default_effect

    self.particles = Particles:new()
    self.screenShake = ScreenShake:new()

    quadtree = QuadTree:new(-WINDOW_OFFSET.x-25, -WINDOW_OFFSET.y-25, love.graphics.getWidth()+50, love.graphics.getHeight()+50)
    quadtree:subdivide()
    quadtree:subdivide()
    player = self:addObject(Player:new())

    self.effectsEnabled = true
    self.paused = false
    
    self.time = 0

    self.startingWave = 0
    self.timeToNextWave = 4

    self:setupWaves()
    self:startWave()
end

function game:update(dt)
    if self.paused then return end

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

    self.particles:update(dt)
    self.screenShake:update(dt)

    if self.boss then
        if self.boss.health <= 0 then
            self.boss = nil
        end
    end

    if #objects == 1 and not self.waveTimer and self.boss == nil and self.waves[self.wave+1] ~= nil then
        self.waveTimer = cron.after(self.timeToNextWave, function() 
            self:startWave()
            self.waveTimer = nil
        end)
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

    self.particles:draw()

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
    love.graphics.print(#bullets, 5, 20)
    love.graphics.print(#objects, 5, 35)

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
        love.graphics.setFont(fontBold[100])
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
        blobs = 25,
        sweepers = 2,
    }
    self.waves[2] = {
        blobs = 50,
        sweepers = 2,
    }
    self.waves[3] = {
        blobs = 15,
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
            self:addObject(Blob:new(
                vector(math.random(0, love.graphics.getWidth())-WINDOW_OFFSET.x, math.random(0, love.graphics.getHeight())-WINDOW_OFFSET.y)
            ))
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

    if currentWave.boss ~= nil then
        local b = currentWave.boss:new()
        self.boss = self:addObject(b)
    end
end