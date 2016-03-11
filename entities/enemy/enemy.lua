Enemy = class('Enemy', Entity)

function Enemy:initialize(position)
    Entity.initialize(self, position)
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

    self.flashTime = 0

    self.collisionPush = 15
    self.moveAway = vector(0, 0)
end

function Enemy:randomizeAppearance(hueDiff, saturationDiff, lightnessDiff, radiusDiff)
    hueDiff = hueDiff or 2
    saturationDiff = saturationDiff or 5
    lightnessDiff = lightnessDiff or 5
    radiusDiff = radiusDiff or 5
	self.hue = self.hue + math.random(-hueDiff, hueDiff)
	self.saturation = self.saturation + math.random(-saturationDiff, saturationDiff)
	self.lightness = self.lightness + math.random(-lightnessDiff, lightnessDiff)
    
    -- color bounds checking
    self.hue = math.min(360, self.hue)
    self.saturation = math.min(100, self.saturation)
    self.lightness = math.min(100, self.lightness)

    self.radius = self.radius + math.random(-self.radius*radiusDiff, self.radius*radiusDiff)
    self.radius = math.max(1, self.radius)
end

function Enemy:update(dt)
    self.moveTowardsPlayer = (player.position - self.position):normalized()

    Entity.physicsUpdate(self, dt)

    if self.health <= 0 then
        self.destroy = true
        signal.emit('enemyDeath', self)
    elseif self.health > self.maxHealth then
        self.health = self.maxHealth
    end

    -- when not taking damage, healing should effect health radius immediately
    if not self.healthTween then
        self.healthRadius = self.radius*self.health/self.maxHealth
    end

	-- switch to HSL for enemy color degredation
--    local saturation = self.saturation
--	local lightness = (self.lightness - self.minLightness) * self.health/self.maxHealth + self.minLightness

	local r, g, b = husl.husl_to_rgb(self.hue, self.saturation, self.lightness)
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
            v = vector(self.x - obj.x, self.y - obj.y)
            self.moveAway = self.moveAway + v*self.collisionPush
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

                self.healthTween = tween(.4, self, {healthRadius = self.radius*self.health/self.maxHealth}, "inOutCubic", function()
                    self.healthTween = nil
                end)
			end
        end
    end
end

function Enemy:draw()
    Entity.draw(self)

    if self.healthRadius then
        love.graphics.setColor(self.color)
        love.graphics.circle("fill", self.position.x, self.position.y, self.healthRadius, self.sides)
    end
end
