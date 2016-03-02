game = {}
objects = {}
bullets = {}

-- displays general debug info
DEBUG = false

-- Debug tools
PRESS_KEY_TO_PAUSE = "pause" -- stops game updates with a single keypress
DRAW_COLLISION_BODIES = false -- draws collision bodies around all entities
DRAW_PHYSICS_VECTORS = false -- draws acceleration and velocity headers
TRACK_ENTITIES = false -- enables entity inspector (right click on entity)
TIME_MULTIPLIER = 1.0

function game:add(obj, tabl)
    if tabl == nil then
        tabl = objects
    end
    for i, v in pairs(tabl) do
        assert(v ~= obj)
    end
    table.insert(tabl, obj)

    -- Do not add the object to the quadtree on the first frame
    -- This avoids an error where they aren't placed correctly

    return obj
end
function game:addBullet(obj)
    return self:add(obj, bullets)
end

function game:remove(obj, tabl)
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
    self:remove(obj, bullets)
end

function game:init()
    self:compileShaders()
    self.particles = Particles:new()
    self.screenShake = ScreenShake:new()
    self.hurt = Hurt:new()
    self.floatingMessages = FloatingMessages:new()
    self.highScore = HighScore:new()
    highscoreList:init()

	self.camera = Camera(0, 0)
	self.camera.scale = self.cameraZoom
end

function game:reset()
    options:load()
    self.worldSize = vector(3000, 2000)

    objects = {}
    bullets = {}
    quadtree = QuadTree:new(-self.worldSize.x/2-25, -self.worldSize.y/2-25, self.worldSize.x+50, self.worldSize.y+50)
    quadtree:subdivide()
    quadtree:subdivide()
    quadtree:subdivide()
	-- player will be added later, in character select

    self.time = 0

    if self.currentMode == nil then
        self.currentMode = Survival
    end
    self.mode = self.currentMode:new()
    self.mode:reset()

    self:compileShaders()
    self:toggleEffects()
    self.background = GridBackground:new()

	self.camera.scale = self.cameraZoom
	self.camera.smoother = function (dx, dy)
        local dt = love.timer.getDelta() * self.camera.scale * 1.5
        return dx*dt, dy*dt
    end
	self.camera.smooth.damped(.1)

    signal.emit('newGame')

    -- Debug options
    self.paused = false
    self.activeEntity = false
end

function game:enter(prev, mode)
    love.keyboard.setKeyRepeat(true)
    love.mouse.setVisible(true)
    love.mouse.setCursor(crosshair)

    self:compileShaders()

    if mode then
        self.currentMode = mode
    end

    if prev ~= pause then
	    state.push(charSelect)
        self:reset()
    end
end

function game:compileShaders()
    local shaders = {
        bloom = shine.bloom{
            samples = 4,
            quality = 1,
        },
        chroma = shine.separate_chroma{
            radius = -1,
            angle = 5*math.pi/4
        },
        blur = shine.gaussianblur{
            sigma = 4
        },
    }

    pause_effect = shaders.bloom:chain(shaders.blur)
    default_effect = shaders.bloom
    post_effect = default_effect
end

function game:update(dt)
    -- even if the game is paused, debug camera should update
    if self.paused and DEBUG and TRACK_ENTITIES then self:updateCamera(dt) end
    if self.paused then return end

    dt = dt * TIME_MULTIPLIER
    self.time = self.time + dt

    if player.health <= 0 then
        state.switch(restart)
    end

    local toUpdate = {objects, bullets}
    for i, tabl in ipairs(toUpdate) do
        for j, obj in ipairs(tabl) do
            obj:update(dt)
            quadtree:updateObject(obj)
        end

        for j = #tabl, 1, -1 do
            local obj = tabl[j]
            if obj.destroy then
              self:remove(obj, tabl)
            end
        end
    end

    self.mode:update(dt)
    self:updateCamera(dt)

    if self.particlesEnabled then
        self.particles:update(dt)
    end
    self.screenShake:update(dt)
    self.hurt:update(dt)
    self.background:update(dt)
    self.floatingMessages:update(dt)
    self.highScore:update(dt)

    if DEBUG and TRACK_ENTITIES and self.activeEntity then
        if self.activeEntity.destroy then
            self.activeEntity = nil
        end
    end
end

function game:updateCamera(dt)
    -- baddddd
    local scale = 1/self.camera.scale

    local width, height = love.graphics.getWidth(), love.graphics.getHeight()
    local scalarHalfWidth = width * scale / 2
    local scalarHalfHeight = height * scale / 2

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

    if DEBUG and TRACK_ENTITIES and self.activeEntity then
        self.camera:lockPosition(self.activeEntity.x, self.activeEntity.y)
    else
        self.camera:lockPosition(nx, ny) -- aim the camera at the player
    end

    if width * scale >= self.worldSize.x then
        self.camera.x = 0
    end
    if height * scale >= self.worldSize.y then
        self.camera.y = 0
    end
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

    if state.current() ~= game then
        post_effect = pause_effect
    else
        post_effect = default_effect
    end
end

function game:keypressed(key, isrepeat)
    for i,v in ipairs(objects) do
        if v.keypressed then
            v:keypressed(key, isrepeat)
        end
    end

    -- debug pause
    if DEBUG and PRESS_KEY_TO_PAUSE and key == PRESS_KEY_TO_PAUSE then
        self.paused = not self.paused
    end

    -- game pause
    if key == "p" or key == "escape" then
        state.switch(pause)
    end
end

function game:mousepressed(x, y, mbutton)
    if DEBUG and TRACK_ENTITIES and mbutton == 2 then
        -- stop tracking last enemy
        self.activeEntity = nil
        local mx = x + self.camera.x - love.graphics.getWidth()/2
        local my = y + self.camera.y - love.graphics.getHeight()/2
        for i, object in pairs(objects) do
            if object:isUnder(mx, my, 15) then
                self.activeEntity = object
                break
            end
        end
        -- if no entity found clicked yet, go over bullets table
        if not self.activeEntity then
            for i, object in pairs(bullets) do
                if object:isUnder(mx, my, 15) then
                    self.activeEntity = object
                    break
                end
            end
        end
    end
end

function game:draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.setLineWidth(1)

    self:toggleEffects()


    -- start post effect
    post_effect(function()

        local dx, dy = self.screenShake:getOffset()
        love.graphics.translate(dx, dy)
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

        if DEBUG and DRAW_COLLISION_BODIES then
            self:drawCollisionBodies()
        end

        if DEBUG and DRAW_PHYSICS_VECTORS then
            self:drawPhysicsVectors()
        end

        -- Debug enemy inspector, displays a bunch of info about an enemy
        -- TODO: this doesn't work with camera zoom yet
        if DEBUG and TRACK_ENTITIES and self.activeEntity then
            self:drawEntityInspectorInfo()
        end

        self.floatingMessages:drawDynamic()
        self:drawWorldBorders()

    	self.camera:detach()

        self.mode:draw()

        -- HUD
        self.highScore:draw()
        self.hurt:draw()
        self.floatingMessages:drawStatic()

        if self.displayFPS then
            self:drawFPS()
        end

        if DEBUG then
            love.graphics.setColor(255, 255, 255, 255)
            love.graphics.print("Memory usage: " .. math.floor(collectgarbage("count")/1000) .. "MB", 5, 25)
        end

    end) -- end post effect
end

function game:drawFPS()
    love.graphics.setFont(font[16])
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print(love.timer.getFPS() .. " FPS", 5, 5)
end

function game:drawWorldBorders()
    love.graphics.setColor(255, 255, 255)
    love.graphics.setLineWidth(4)
    love.graphics.line(-self.worldSize.x/2, -self.worldSize.y/2,
                        self.worldSize.x/2, -self.worldSize.y/2,
                        self.worldSize.x/2,  self.worldSize.y/2,
                       -self.worldSize.x/2,  self.worldSize.y/2,
                       -self.worldSize.x/2, -self.worldSize.y/2)
end

function game:drawEntityInspectorInfo()
    local entity = self.activeEntity
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.circle("line", entity.position.x, entity.position.y, entity.radius)

    -- width and height lines
    -- width
    local padding = 15
    local f = love.graphics.getFont()
    love.graphics.line(entity.position.x - entity.radius,
                       entity.position.y + entity.radius*2,
                       entity.position.x + entity.radius,
                       entity.position.y + entity.radius*2)
    local text = entity.width
    love.graphics.print(text, entity.position.x - f:getWidth(text)/2, entity.position.y + entity.radius*2 - f:getHeight(text)/2 + padding )

    -- height
    love.graphics.line(entity.position.x - entity.radius*2,
                       entity.position.y - entity.radius,
                       entity.position.x - entity.radius*2,
                       entity.position.y + entity.radius)
    local text = entity.height
    love.graphics.print(text, entity.position.x - entity.radius*2 - f:getWidth(text) - padding, entity.position.y - f:getHeight(text)/2)

    -- velocity heading
    self:drawVectors(entity)
    
    love.graphics.setColor(0, 0, 0, 128)
    love.graphics.rectangle("fill", entity.position.x + entity.radius + 25, entity.position.y - 25, 510, 500)

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setFont(fontBold[24])
    love.graphics.print(tostring(entity.class), entity.position.x + entity.radius + 35, entity.position.y - 25)
    love.graphics.setFont(font[18])
    local debugString = "Position: " .. tostring(entity.position) .. "\n" ..
                        "Velocity: " .. tostring(entity.velocity) .. "\n" ..
                        "Acceleration: " .. tostring(entity.acceleration) .. "\n" ..
                        "Speed: " .. tostring(entity.speed) .. "\n" .. 
                        "Friction: " .. tostring(entity.friction) .. "\n" .. 
                        "Radius: " .. tostring(entity.radius) .. "\n"

    if entity:isInstanceOf(Bullet) then
        debugString = debugString .. "\n" .. 
            "Fired by: " .. tostring(entity.source) .. "\n" ..
            "Lifetime: " .. tostring(entity.life) .. "" .. "\n" ..
            "Damage: " .. math.floor(entity.damage) .. ", Max: " .. entity.originalDamage .. ", Min: " .. entity.originalDamage - entity.dropoffAmount .. "\n" ..
            "Distance traveled: " .. math.floor(entity.distanceTraveled) .. "\n"

        -- bullet target
        love.graphics.setColor(18, 87, 233, 200)
        love.graphics.circle("line", entity.target.x, entity.target.y, 15)

        -- bullet source
        love.graphics.setColor(255, 255, 255, 64)
        love.graphics.line(entity.position.x, entity.position.y, entity.source.x, entity.source.y)
    end

    if entity:isInstanceOf(Enemy) or entity:isInstanceOf(Player) then
        debugString = debugString .. "\n" .. 
            "Health: " .. entity.health .. " / " .. entity.maxHealth .. " (" .. math.floor(entity.health/entity.maxHealth*100) .. "%)\n" ..
            "Touch Damage: " .. tostring(entity.touchDamage) .. "\n" ..
            "Invincible: " .. tostring(entity.invincible) .. "\n" ..
            "Knockback Resist: " .. tostring(entity.knockbackResistance) .. "\n" ..
            "Damage Resist: " .. tostring(entity.damageResistance) .. "\n"
    end

    if entity:isInstanceOf(Player) then
        debugString = debugString .. 
            "Regen timer: " .. tostring(entity.regenWaitAfterHurt) .. " sec, current: " .. tostring(entity.regenTimer) .. "\n" ..
            "Rate of fire: " .. tostring(entity.shotsPerSecond) .. " shots per sec\n" ..
            "Bullet damage: " .. tostring(entity.bulletDamage) .. "\n" ..
            "Bullet velocity: " .. tostring(entity.bulletVelocity) .. "\n" ..
            "Damage multiplier: " .. tostring(entity.damageMultiplier) .. "\n" ..
            "Crit chance: " .. tostring(entity.criticalChance) .. "\n" ..
            "Crit multiplier: " .. tostring(entity.criticalMultiplier) .. "\n"
    end

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.printf(debugString, entity.position.x + entity.radius + 35, entity.position.y, 500)
end

function game:drawCollisionBodies()
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setLineWidth(1)
    for i, object in ipairs(objects) do
        love.graphics.circle("line", object.position.x, object.position.y, object.radius)
    end
    for i, object in ipairs(bullets) do
        love.graphics.circle("line", object.position.x, object.position.y, object.radius)
    end
end

function game:drawPhysicsVectors()
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setLineWidth(1)
    for i, object in ipairs(objects) do
        self:drawVectors(object)
    end
    for i, object in ipairs(bullets) do
        self:drawVectors(object)
    end
end

function game:drawVectors(object)
    if object.velocity then
        love.graphics.setColor(255, 207, 24, 200)
        love.graphics.line(object.position.x, 
                           object.position.y,
                           object.position.x + object.velocity.x,
                           object.position.y + object.velocity.y)
    end

    -- acceleration heading
    if object.acceleration then 
        love.graphics.setColor(18, 87, 233, 200)
        love.graphics.line(object.position.x, 
                           object.position.y,
                           object.position.x + object.acceleration.x, 
                           object.position.y + object.acceleration.y)
    end
end