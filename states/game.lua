game = {}
objects = {}
bullets = {}

WINDOW_OFFSET = vector(love.graphics.getWidth()/2, love.graphics.getHeight()/2)

function game:addObject(obj, tabl)
    if tabl == nil then
        tabl = objects
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
    for i, b in pairs(tabl) do
        if b == obj then
            table.remove(tabl, i)
        end
    end
    quadtree:removeObject(obj, true)
end
function game:removeBullet(obj)
    return self:removeObject(obj, bullets)
end

function game:enter()
    love.keyboard.setKeyRepeat(true)
    love.mouse.setVisible(false)

    cursorImage = love.graphics.newImage("img/cursor.png")
    local bloom = shine.bloom()
    bloom.parameters = {
        samples = 4,
        quality = 1,
    }

    local chroma = shine.separate_chroma()
    chroma.parameters = {
        radius = 0.5,
        angle = 5*math.pi/4
    }

    local blur = shine.gaussianblur()
    blur.parameters = {
        sigma = 3
    }

    default_effect = bloom
    pause_effect = bloom:chain(blur)
    post_effect = default_effect

    self.particleSystem = love.graphics.newParticleSystem(love.graphics.newImage("img/particle.png"), 256)
    self.particleSystem:setRadialAcceleration(500, 600)
    self.particleSystem:setParticleLifetime(2)
    self.particleSystem:setSpeed(150, 450)
    self.particleSystem:setSpread(2*math.pi)
    self.particleSystem:setSizeVariation(1)
    self.particleSystem:setColors(255, 0, 0, 255, 0, 0, 0, 0)

    quadtree = QuadTree:new(-WINDOW_OFFSET.x-25, -WINDOW_OFFSET.y-25, love.graphics.getWidth()+50, love.graphics.getHeight()+50)
    quadtree:subdivide()
    quadtree:subdivide()
    player = self:addObject(Player:new())

    self.effectsEnabled = true
    self.paused = false

    self:setupWaves()
    self:startWave()
end

function game:update(dt)
    if self.paused then return end

    prevObjects = objects

    for i,v in ipairs(objects) do
        quadtree:updateObject(v)
        v:update(dt)
    end

    for i,v in ipairs(bullets) do
        quadtree:updateObject(v)
        v:update(dt)
    end

    if self.waveTimer then
        self.waveTimer:update(dt)
    end

    self.particleSystem:update(dt)

    if self.boss then
        if self.boss.health <= 0 then
            self.boss = nil
        end
    end

    if #objects == 1 and not self.waveTimer and self.boss == nil and self.waves[self.wave+1] ~= nil then
        self.waveTimer = cron.after(3, function() 
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

    post_effect(function()

    love.graphics.translate(love.graphics.getWidth()/2, love.graphics.getHeight()/2)

    love.graphics.draw(self.particleSystem)

    for i,v in ipairs(objects) do
        v:draw()
    end
    for i,v in ipairs(bullets) do
        v:draw()
    end

    love.graphics.setColor(160, 160, 160, 16)
    quadtree:draw()

    love.graphics.translate(-love.graphics.getWidth()/2, -love.graphics.getHeight()/2)

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(cursorImage, love.mouse.getX()-cursorImage:getWidth()/2, love.mouse.getY()-cursorImage   :getHeight()/2)

    if self.waveText ~= nil and self.wave > 0 then
        self:drawPrimaryText()
    end

    if self.boss ~= nil then
        self:drawBossHealthBar()
    end 

    self:drawPlayerHealthBar()

    love.graphics.setFont(font[16])
    love.graphics.print(love.timer.getFPS(), 5, 5)

    love.graphics.setFont(font[32])
    if self.waveTimer ~= nil and self.waveTimer.time - self.waveTimer.running > 0 and #objects == 1 then
        local t = self.waveTimer.time - self.waveTimer.running
        love.graphics.print(math.ceil(t), love.graphics.getWidth()/2 - love.graphics.getFont():getWidth(math.ceil(t))/2, 150)

        if self.waves[self.wave+1] ~= nil then
            if self.waves[self.wave+1].boss ~= nil then
                love.graphics.print("BOSS INCOMING", love.graphics.getWidth()/2 - love.graphics.getFont():getWidth("BOSS INCOMING")/2, 50)
            end
        end

    end
    end)

    if self.paused then
        love.graphics.setColor(0, 0, 0, 80)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

        love.graphics.setColor(255, 255, 255)
        love.graphics.setFont(fontBold[100])
        love.graphics.print("PAUSED", love.graphics.getWidth()/2 - love.graphics.getFont():getWidth("PAUSED")/2, love.graphics.getHeight()/2 - love.graphics.getFont():getHeight("PAUSED")/2)
    end
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

    love.graphics.setFont(font[32])
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(r, g, b)
    love.graphics.print(self.waveText, love.graphics.getWidth()/2 - love.graphics.getFont():getWidth(self.waveText)/2, 100)
end

function game:setupWaves()
    self.waves = {}
    self.waves[1] = {
        enemies = 10,
    }
    self.waves[2] = {
        enemies = 15,
    }
    self.waves[3] = {
        enemies = 20,
        sweepers = 4,
    }
    self.waves[4] = {
        enemies = 25,
        sweepers = 6,
    }
    self.waves[5] = {
        boss = Megabyte,
    }
end

function game:startWave()
    if self.wave == nil then
        self.wave = 0
    elseif self.wave <= 5
        self.wave = self.wave + 1
    elseif self.wave >= 6 then
        return
    end

    self:setPrimaryText("WAVE "..self.wave)

    if self.waves[self.wave] ~= nil then
        self:spawnEnemies()
    end
end

function game:spawnEnemies()
    local currentWave = self.waves[self.wave]

    if currentWave.enemies ~= nil then
        for i=1, self.waves[self.wave].enemies do
            self:addObject(Enemy:new(
                vector(math.random(0, love.graphics.getWidth())-WINDOW_OFFSET.x, math.random(0, love.graphics.getHeight())-WINDOW_OFFSET.y)
            ))
        end
    end

    if currentWave.sweepers ~= nil then
        -- number of line enemies to spawn
        local num = self.waves[self.wave].sweepers
        -- margin from the sides of the screen
        local margin = 100
        local h = (love.graphics.getHeight()-margin)/num
        local w = (love.graphics.getWidth()-margin)
        for i=1, num do
            self:addObject(LineEnemy:new(
                vector(margin-WINDOW_OFFSET.x, (margin+h*(i-1))-WINDOW_OFFSET.y),
                vector(w-WINDOW_OFFSET.x-margin, (margin+h*(i-1))-WINDOW_OFFSET.y)
            ))
        end
    end

    if currentWave.boss ~= nil then
        local b = currentWave.boss:new()
        self.boss = self:addObject(b)
    end
end