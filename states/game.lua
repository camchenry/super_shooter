game = {}
objects = {}
bullets = {}

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

        for j, obj in ipairs(tabl) do
            if obj.destroy then
                self:remove(obj)
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
    
    self.camera:lockPosition(nx, ny) -- aim the camera at the player
    
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

    if key == "p" or key == "escape" then
        state.switch(pause)
    end
end

function game:mousepressed(x, y, mbutton)

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
