Enemy = class('Enemy', Entity)

function Enemy:initialize(position)
    Entity.initialize(self, position)
    self.originalColor = {255, 76, 60, 255}
    self.radius = 15
    self.sides = 4

    self.position = position
    self.x, self.y = self.position:unpack()
    self.touchDamage = 25

    self.health = 100
    self.maxHealth = 100
	self.invincible = false
    self.knockbackResistance = 0.0
    self.damageResistance = 0.0

    self.healthRadius = self.radius*self.health/self.maxHealth

	self.hue = 0
	self.saturation = 100
	self.lightness = 40
	self.minLightness = 25
    self:randomizeAppearance(5, 5, 5, .3)

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

    self.color = self.originalColor
	-- switch to HSL for enemy color degredation
    local saturation = self.saturation
	local lightness = (self.lightness - self.minLightness) * self.health/self.maxHealth + self.minLightness

	local r, g, b = husl.husl_to_rgb(self.hue, saturation, lightness)
	self.color = {r*255, g*255, b*255, self.color[4]}

    if self.flashTime > 0 then
        self.color = {255, 255, 255, 255}
        self.flashTime = self.flashTime - dt
    end
end

-- this is a private collision function specifically for common enemy effects that aren't supposed
-- to be overridden
function Enemy:_handleCollision(collision)
    local obj = collision.other

    if obj:isInstanceOf(Enemy) then
        if self.position:dist(obj.position) < self.radius + obj.radius then
            local actualX, actualY = game.world:move(self, self.velocity.x, self.velocity.y)
            self.acceleration = self.acceleration + vector(actualX, actualY)
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

                self.healthTween = tween(.4, self, {healthRadius = self.radius*self.health/self.maxHealth}, "inOutCubic")
			end
        end
    end
end

Blob = class('Blob', Enemy)

function Blob:initialize(position)
    Enemy.initialize(self, position)
    self.originalColor = {231, 76, 60, 255}
    self.sides = 4

	self.hue = 10
	self.saturation = 80
	self.lightness = 50

    local radiusOrig = 15
    self.radius = radiusOrig

    self.speed = math.sqrt(750 * 1/(self.radius/radiusOrig)) * 20
    self.touchDamage = 25 * (self.radius/radiusOrig)

    self.position = position
    self.health = 100
    self.maxHealth = 100
    self.healthRadius = self.radius*self.health/self.maxHealth
end

function Blob:update(dt)
    Enemy.update(self, dt)
    self.moveTowardsPlayer = player.position - self.position

    self.acceleration = (self.acceleration + self.moveTowardsPlayer):normalized() * self.speed
end

function Blob:handleCollision(collision)

end

Sweeper = class('Sweeper', Enemy)

function Sweeper:initialize(start, percent, num, radius)
    Enemy.initialize(self, start)
    self.originalColor = {241, 196, 0, 255}
    self.sides = 3

    self.hue = 65
    self.saturation = 80
    self.lightness = 80

    local radiusOrig = 18
    self.radius = radiusOrig

    self.speed = 400 * 1/(self.radius/radiusOrig)
    self.touchDamage = 125 * (self.radius/radiusOrig)

    self.angle = percent * 2 * math.pi
    self.orbitRadius = radius or math.random(100, math.min(game.worldSize.x/2, game.worldSize.y/2))
  	self.rotateSpeed = math.min(0.25, math.max(1.2, 1 - math.random() * math.random() + math.random())) -- revolutions per second
  	self.countSimilar = num

    self.rotateSpeed = 50*self.rotateSpeed/math.sqrt(self.orbitRadius) -- temporary decrease

    self.start = start
    self.target = finish
    self.friction = 3
    self.knockbackResistance = 1

    self.health = 75
    self.maxHealth = 75
    self.healthRadius = self.radius*self.health/self.maxHealth

	signal.register('enemyDeath', function(enemy)
      if enemy.class == Sweeper then
		      self.countSimilar = self.countSimilar - 1
		  end
    end)
end

function Sweeper:update(dt)
    Enemy.update(self, dt)

    local position = vector(
        math.cos(self.angle) * self.orbitRadius,
        math.sin(self.angle) * self.orbitRadius
    )

    self.moveTowardsPosition = (self.start - self.position + position):normalized()
    local speed = math.atan2(self.position.y-self.moveTowardsPosition.y, self.position.x-self.moveTowardsPosition.x) + 5
    self.acceleration = (self.moveTowardsPosition):normalized()*speed

  	self.angle = self.angle + dt * self.rotateSpeed
end

function Sweeper:handleCollision(collision)

end

function Sweeper:draw()
    Enemy.draw(self)

    love.graphics.setColor(255, 255, 255, 64)
    love.graphics.setLineWidth(1)
    love.graphics.circle("line", self.start.x, self.start.y, self.orbitRadius)

    love.graphics.setColor(255, 255, 255)
end

Healer = class('Healer', Enemy)

function Healer:initialize(position)
    Enemy.initialize(self, position)
    self.originalColor = {77, 214, 79, 255}
    self.sides = 5

	  self.hue = 125
	  self.saturation = 80
	  self.lightness = 50

    local radiusOrig = 11
    self.radius = radiusOrig

    self.speed = 325 * 1/(self.radius/radiusOrig)
    self.touchDamage = 12 * (self.radius/radiusOrig)

    self.position = position

    self.maxHealth = 80
    self.health = self.maxHealth
    self.healthRadius = self.radius*self.health/self.maxHealth

    self.knockbackResistance = 0.5

  	self.healRate = 15
    self.healRadius = 130
end

function Healer:update(dt)
    Enemy.update(self, dt)
    self.moveTowardsPlayer = (player.position - self.position):normalized()
    self.moveTowardsEnemy = vector(0, 0)

    for i, o in pairs(objects) do
        if o:isInstanceOf(Enemy) and o ~= self then
            if o.position:dist(self.position) <= self.healRadius and o ~= self then
                if o.health >= 0 then
                    o.health = o.health + self.healRate * dt
                end
            end
            self.moveTowardsEnemy = self.moveTowardsEnemy + (o.position - self.position)
            if o:isInstanceOf(Healer) then
              self.moveTowardsEnemy = self.moveTowardsEnemy * -.1
            end
        end
    end

    self.acceleration = (self.moveTowardsPlayer + self.moveAway + self.moveTowardsEnemy*0.1):normalized() * self.speed
end

function Healer:handleCollision(collision)

end

function Healer:draw()
    Enemy.draw(self)

    love.graphics.setColor(77, 214, 79, 70)

    for i, o in pairs(objects) do
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
    self.sides = 6

  	self.hue = 230
  	self.saturation = 80
  	self.lightness = 50

    local radiusOrig = 20
    self.radius = radiusOrig

    self.speed = 350 * 1/(self.radius/radiusOrig)
    self.touchDamage = 65 * (self.radius/radiusOrig)

    self.knockbackResistance = 0.8
    self.damageResistance = 0.1

    self.position = position

    self.maxHealth = 750
    self.health = self.maxHealth
    self.healthRadius = self.radius*self.health/self.maxHealth
end

function Tank:update(dt)
    Enemy.update(self, dt)
    self.moveTowardsPlayer = (player.position - self.position):normalized()

    self.acceleration = (self.moveTowardsPlayer + self.moveAway):normalized() * self.speed
end

function Tank:handleCollision(collision)
    local obj = collision.other

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
    self.sides = 4

  	self.hue = 280
  	self.saturation = 20
  	self.lightness = 50

    local radiusOrig = 15
    self.radius = radiusOrig

    self.speed = 800 * 1/(self.radius/radiusOrig)
    self.touchDamage = 45 * (self.radius/radiusOrig)

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

    self.health = 500
    self.maxHealth = 500
    self.healthRadius = self.radius*self.health/self.maxHealth
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

    self.drawTeleportLineTime = self.drawTeleportLineTime - dt
    self.sprintCooldown = self.sprintCooldown - dt

    local t = self.position:dist(player.position) / self.speed
    local predictedPosition = player.position + player.velocity * t
    self.moveTowards = (predictedPosition - self.position):normalized()
    self.acceleration = (self.moveTowards + self.moveAway):normalized() * self.speed

    -- start the attack
    if self.sprintCooldown < self.sprintActivatedTime then
        self.speed = 5000
        self.touchDamage = 375
    -- start telegraphing the attack
    elseif self.sprintCooldown < self.sprintTelegraphTime then
        self.sprinting = true
        self.acceleration = vector(0, 0)
        self.position = self.position + vector((math.random()-0.5)*2, (math.random()-0.5)*2)/2
        self.damageResistance = -0.5
    else
        self.speed = 800
        self.touchDamage = 40
        self.damageResistance = 0
    end

    if self.sprintCooldown < 0 then
        self.sprinting = false
        self.sprintCooldown = self.sprintCooldownMax
    end
end

function Ninja:handleCollision(collision)
    local obj = collision.other

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
