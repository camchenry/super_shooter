Enemy = class('Enemy', Entity)

function Enemy:initialize(position)
    Entity.initialize(self, position)
    self.originalColor = {231, 76, 60, 255}
    self.radius = 15
    self.sides = 4

    self.position = position
    self.x, self.y = self.position:unpack()
    self.touchDamage = player.maxHealth/5

    self.health = 100
    self.maxHealth = 100
	self.invincible = false
    self.knockbackResistance = 0.0
    self.damageResistance = 0.0
	
	--self.minimumAlpha = 100
	
	self.hue = 0
	self.saturation = 100
	self.lightness = 40
	self.minLightness = 25

    self.flashTime = 0
end

function Enemy:randomizeAppearance(hueDiff, saturationDiff, lightnessDiff, radiusDiff)
    local hueVariance = hueDiff or 5
    local saturationVariance = saturationDiff or 5
    local lightnessVariance = lightnessDiff or 5
    local radiusVariance = radiusDiff or 0.1
	
	self.hue = self.hue + math.random(-hueVariance, hueVariance)
	self.saturation = self.saturation + math.random(-saturationVariance, saturationVariance)
	self.lightness = self.lightness + math.random(-lightnessVariance, lightnessVariance)
    
    self.radius = self.radius + math.random(-self.radius*radiusVariance, self.radius*radiusVariance)
end

function Enemy:update(dt)
    self.moveAway = vector(0, 0)
    self.moveTowardsPlayer = (player.position - self.position):normalized()

    Entity.physicsUpdate(self, dt)

    if self.health <= 0 then
        self.destroy = true
        self.color = self.originalColor
        signal.emit('enemyDeath', self)
    elseif self.health > self.maxHealth then
        self.health = self.maxHealth
    end

    -- enemy fades away as it loses health
    self.color = self.originalColor
	-- switch to HSL for enemy color degredation
    --self.color[4] = math.floor((255-self.minimumAlpha)*(self.health/self.maxHealth) + self.minimumAlpha)
	local saturation = self.saturation * self.health/self.maxHealth
	local lightness = (self.lightness - self.minLightness) * self.health/self.maxHealth + self.minLightness
	
	local r, g, b = husl.husl_to_rgb(self.hue, saturation, lightness)
	self.color = {r*255, g*255, b*255, self.color[4]}

    if self.flashTime > 0 then
        self.color = {255, 255, 255, 255}
        self.flashTime = self.flashTime - dt
    end

    self:checkCollision(self._handleCollision)

end

-- this is a private collision function specifically for common enemy effects that aren't supposed
-- to be overridden
function Enemy:_handleCollision(obj)
    if obj:isInstanceOf(Enemy) then
        if self.position:dist(obj.position) < self.radius + obj.radius then
            v = vector(self.x - obj.x, self.y - obj.y)
            self.moveAway = self.moveAway + v:normalized()
        end
    end

    if obj:isInstanceOf(Bullet) then
        if obj.source ~= nil and obj.source:isInstanceOf(self.class) then return end
        if self.boss ~= nil then
            if obj.source == self.boss then return end
        end

		-- check for proximity and invincible
        if self.position:dist(obj.position) < self.radius + obj.radius then
            game:removeBullet(obj)
			if not self.invincible and not obj.destroy then
                local dmg = obj.damage * (1 - self.damageResistance)
				self.health = self.health - dmg
                local death = self.health <= 0
				signal.emit('enemyHit', self, dmg, obj.critical, obj.source, death)
				self.flashTime = 20/1000
                self.velocity = self.velocity + 0.5 * obj.velocity * (1 - self.knockbackResistance)
				obj.destroy = true
			end
        end
    end
end

Blob = class('Blob', Enemy)

function Blob:initialize(position)
    Enemy.initialize(self, position)
    self.originalColor = {231, 76, 60, 255}
    self.radius = 15 + math.random(-2, 2)
    self.sides = 4

	self.hue = 10
	self.saturation = 80
	self.lightness = 50
	
    self:randomizeAppearance(15, 15, 10, .2)

    self.speed = 750

    self.position = position
    self.touchDamage = player.maxHealth/5

    self.health = 100
    self.maxHealth = 100
end

function Blob:update(dt)
    Enemy.update(self, dt)
    self.moveTowardsPlayer = (player.position - self.position):normalized()

    self.acceleration = (self.moveTowardsPlayer + self.moveAway):normalized() * self.speed
end

function Blob:handleCollision(obj)
    
end

Sweeper = class('Sweeper', Enemy)

function Sweeper:initialize(start, percent, num)
    Enemy.initialize(self, start)
    self.originalColor = {241, 196, 0, 255}
    self.radius = 18
    self.sides = 3
	
	self.hue = 65
	self.saturation = 80
	self.lightness = 80
	
    self:randomizeAppearance(5, 10, 5, .2)

    self.position = start
    self.start = start
    self.target = finish
    self.speed = 900
    self.friction = 3
    self.knockbackResistance = 1
	
	self.percent = percent
	self.rotateSpeed = 1/8
	self.countSimilar = num

    --self.touchDamage = player.maxHealth
	self.touchDamage = 0

    self.health = 75
    self.maxHealth = 75
	
	signal.register('enemyDeath', function(enemy)
        if enemy.class == Sweeper then
			self.countSimilar = self.countSimilar - 1
		end
    end)
end

function Sweeper:update(dt)
    Enemy.update(self, dt)
	--[[
    if self.position:dist(self.target) < 9 then
        if self.target == self.finish then
            self.target = self.start
        else
            self.target = self.finish
        end
        self.velocity.x = 0
    end

    self.acceleration = (self.target - self.position):normalized() * self.speed
	]]
	
	
	local radius = 20 * self.countSimilar + 40
	local offset = vector(math.cos(self.percent * math.pi * 2), math.sin(self.percent * math.pi * 2)) * radius
	
    self.moveTowardsPlayer = (player.position - self.position + offset):normalized()
	
    self.acceleration = (self.moveTowardsPlayer):normalized() * self.speed
	
	self.percent = self.percent + dt * self.rotateSpeed
end

function Sweeper:handleCollision(obj)

end

function Sweeper:draw()
    Enemy.draw(self)

    love.graphics.setColor(255, 255, 255)
    --love.graphics.circle("fill", self.start.x, self.start.y, 10)
    --love.graphics.circle("fill", self.finish.x, self.finish.y, 10)
end

Healer = class('Healer', Enemy)

function Healer:initialize(position)
    Enemy.initialize(self, position)
    self.originalColor = {77, 214, 79, 255}
    self.radius = 11
    self.sides = 5
	
	self.hue = 125
	self.saturation = 80
	self.lightness = 50
	
    self:randomizeAppearance(15, 15, 10, .2)

    self.speed = 325

    self.position = position
    self.touchDamage = player.maxHealth/10

    self.maxHealth = 80
    self.health = self.maxHealth
    self.knockbackResistance = 0.5
	
	self.healRate = 15
    self.healRadius = 130
end

function Healer:update(dt)
    Enemy.update(self, dt)
    self.moveTowardsPlayer = (player.position - self.position):normalized()
    self.moveTowardsEnemy = vector(0, 0)

    for i, o in pairs(quadtree:getCollidableObjects(self, true)) do
        if o:isInstanceOf(Enemy) then
            if o.position:dist(self.position) <= self.healRadius and o ~= self then
                if o.health >= 0 then
                    o.health = o.health + self.healRate * dt
                end
            end
            self.moveTowardsEnemy = self.moveTowardsEnemy + (o.position - self.position)
        end
    end

    self.acceleration = (self.moveTowardsPlayer + self.moveAway + self.moveTowardsEnemy*0.1):normalized() * self.speed
end

function Healer:handleCollision(obj)
    if obj:isInstanceOf(Enemy) then

    end
end

function Healer:draw()
    Enemy.draw(self)

    love.graphics.setColor(77, 214, 79, 70)

    for i, o in pairs(quadtree:getCollidableObjects(self, true)) do
        if o:isInstanceOf(Enemy) then
            if o.position:dist(self.position) <= self.healRadius and o ~= self then
                love.graphics.line(self.position.x, self.position.y, o.position.x, o.position.y)
            end
        end
    end

    love.graphics.setColor(255, 255, 255)
end

Tank = class('Tank', Enemy)

function Tank:initialize(position)
    Enemy.initialize(self, position)
    self.originalColor = {122, 214, 210, 255}
    self.radius = 20
    self.sides = 6
	
	self.hue = 230
	self.saturation = 80
	self.lightness = 50
	
    self:randomizeAppearance(20, 15, 10, .2)

    self.speed = 350
    self.knockbackResistance = 0.8
    self.damageResistance = 0.1

    self.position = position
    self.touchDamage = player.maxHealth/2

    self.maxHealth = 750
    self.health = self.maxHealth
end

function Tank:update(dt)
    Enemy.update(self, dt)
    self.moveTowardsPlayer = (player.position - self.position):normalized()

    self.acceleration = (self.moveTowardsPlayer + self.moveAway):normalized() * self.speed
end

function Tank:handleCollision(obj)
    if obj:isInstanceOf(Bullet) then
        if obj.source == self then return end
        if obj.source:isInstanceOf(Tank) then return end
        if obj.alreadyCollided then return end

		-- bullets have ~1/4 chance of not bouncing
        --if math.random() > .75 then return end

        local num = math.random(1, 3)
        for i=1, num do
            local d = -1 * obj.velocity -- incoming vector
            local n = obj.position - self.position -- vector to reflect off of
            local r = d:mirrorOn(n) -- result vector
            r:rotate_inplace(math.rad(math.random(-90, 90)))

            local offset = r
			
            local b = game:addBullet(Bullet:new(
                obj.position,
                player.position + offset,
                self.velocity)
            )
			
            b:setSource(self)
            b:setDamage(obj.damage*0.08)
            b:setSpeed(obj.velocity:len()*1.4)
            b:setRadius(math.random(3, 4))
            obj.alreadyCollided = true
        end
    end
end

Ninja = class('Ninja', Enemy)

function Ninja:initialize(position)
    Enemy.initialize(self, position)
    self.originalColor = {255, 255, 255, 200}
    self.radius = 15 + math.random(-2, 2)
    self.sides = 4

	self.hue = 280
	self.saturation = 20
	self.lightness = 50
	
    self:randomizeAppearance(10, 15, 10, .2)
	
    self.speed = 800
    self.doTeleport = false
    self.drawTeleportLineTime = 0

    self.sprintCooldownMax = 5
    self.sprintCooldown = self.sprintCooldownMax + math.random(2, 7)
    -- what time to start telegraphing the attack
    -- stop the enemy, shake, change color, etc
    self.sprintTelegraphTime = 3
    -- for how long sprint is considered activated
    self.sprintActivatedTime = 1

    self.position = position
    self.touchDamage = player.maxHealth/4

    self.health = 500
    self.maxHealth = 500
end

function Ninja:update(dt)
    Enemy.update(self, dt)

    if self.doTeleport and self.health > 0 and not self.sprinting then
        local teleport = vector(math.random(-200, 200),
                                math.random(-200, 200))
        self.position = self.position + teleport
        self.position = self.position + (self.position - player.position):normalized()*250
        self.doTeleport = false
    end

    for i, o in pairs(quadtree:getCollidableObjects(self, true)) do
        if o:isInstanceOf(Bullet) then
            if not self.sprinting then
                self.velocity = self.velocity - (o.position - self.position):perpendicular():normalized()
            end
        end
    end

    self.drawTeleportLineTime = self.drawTeleportLineTime - dt
    self.sprintCooldown = self.sprintCooldown - dt

    local t = self.position:dist(player.position) / self.speed
    local predictedPosition = player.position + player.velocity * t
    self.moveTowards = (predictedPosition - self.position):normalized()
    self.acceleration = (self.moveTowards + self.moveAway):normalized() * self.speed

    -- start the attack
    if self.sprintCooldown < self.sprintActivatedTime then
        self.speed = 5000
        self.touchDamage = player.maxHealth * 3
    -- start telegraphing the attack
    elseif self.sprintCooldown < self.sprintTelegraphTime then
        self.sprinting = true
        self.acceleration = vector(0, 0)
        self.position = self.position + vector((math.random()-0.5)*2, (math.random()-0.5)*2)/2
        self.damageResistance = -0.5
    else
        self.speed = 800
        self.touchDamage = player.maxHealth / 4
        self.damageResistance = 0
    end

    if self.sprintCooldown < 0 then
        self.sprinting = false
        self.sprintCooldown = self.sprintCooldownMax
    end
end

function Ninja:handleCollision(obj)
    if obj:isInstanceOf(Bullet) then
        if obj.source ~= nil and obj.source:isInstanceOf(self.class) then return end
        if self.boss ~= nil then    
            if obj.source == self.boss then return end
        end

        -- check for proximity and invincible
        if self.position:dist(obj.position) < self.radius + obj.radius then
            if not self.invincible then
                self.doTeleport = true
                self.drawTeleportLineTime = 35/1000
                self.oldPosition = self.position
            end
        end
    end
end

function Ninja:draw()
    Enemy.draw(self)

    if self.oldPosition and self.drawTeleportLineTime > 0 then
        love.graphics.setLineWidth(3)
        love.graphics.setColor(self.originalColor)
        love.graphics.line(self.oldPosition.x, self.oldPosition.y, self.position.x, self.position.y)
        self.drawTeleportLine = false
    end

    if self.sprintCooldown < self.sprintTelegraphTime then
        -- goes from 0 to 1 when sprint cooldown is 0
        local scale = (self.sprintTelegraphTime - self.sprintCooldown + self.sprintActivatedTime)/(self.sprintTelegraphTime + self.sprintActivatedTime)

        love.graphics.setColor(self.originalColor)
        love.graphics.circle("fill", self.position.x, self.position.y, scale*self.radius, self.sides)
    end
end