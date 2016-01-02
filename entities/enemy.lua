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

    self.flashTime = 0
end

function Enemy:randomizeAppearance(color, radius)
    local colorVariance = color or 0.1
    self.originalColor[1] = self.originalColor[1] + math.random(0, self.originalColor[1]*colorVariance) * math.random(-1, 1)
    self.originalColor[2] = self.originalColor[2] + math.random(0, self.originalColor[2]*colorVariance) * math.random(-1, 1)
    self.originalColor[3] = self.originalColor[3] + math.random(0, self.originalColor[3]*colorVariance) * math.random(-1, 1)
    
    self.originalColor[1] = math.min(self.originalColor[1], 255) 
    self.originalColor[2] = math.min(self.originalColor[2], 255)
    self.originalColor[3] = math.min(self.originalColor[3], 255)
    
    local radiusVariance = radius or 0.1
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
    self.color[4] = math.floor(math.max(64, 255*(self.health/self.maxHealth)))

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
			if not self.invincible then
				self.health = self.health - obj.damage
				signal.emit('enemyHit', self, obj.damage, obj.critical)
				self.flashTime = 20/1000
                self.velocity = self.velocity + 0.5 * obj.velocity * (1 - self.knockbackResistance)
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

    self:randomizeAppearance(0.3, 0.1)

    self.speed = 600

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

LineEnemy = class('LineEnemy', Enemy)

function LineEnemy:initialize(start, finish)
    Enemy.initialize(self, start)
    self.originalColor = {241, 196, 0, 255}
    self.radius = 18
    self.sides = 3
    self:randomizeAppearance()

    self.position = start
    self.start = start
    self.finish = finish
    self.target = finish
    self.speed = 2500
    self.friction = 3

    self.touchDamage = player.maxHealth/2

    self.health = 50
    self.maxHealth = 50
end

function LineEnemy:update(dt)
    Enemy.update(self, dt)

    if self.position:dist(self.target) < 10 then
        if self.target == self.finish then
            self.target = self.start
        else
            self.target = self.finish
        end
    end

    self.acceleration = (self.target - self.position):normalized() * self.speed
end

function LineEnemy:handleCollision(obj)

end

Healer = class('Healer', Enemy)

function Healer:initialize(position)
    Enemy.initialize(self, position)
    self.originalColor = {77, 214, 79, 255}
    self.radius = 11
    self.sides = 5
    self:randomizeAppearance()

    self.speed = 345

    self.position = position
    self.touchDamage = player.maxHealth/10

    self.maxHealth = 125
    self.health = self.maxHealth
	
	self.healRate = 20
    self.healRadius = 130
end

function Healer:update(dt)
    Enemy.update(self, dt)
    self.moveTowardsPlayer = (player.position - self.position):normalized()
    self.moveTowardsEnemy = vector(0, 0)

    for i, o in pairs(quadtree:getCollidableObjects(self, true)) do
        if o:isInstanceOf(Enemy) then
            if o.position:dist(self.position) <= self.healRadius then
                if o.health >= 0 then
                    o.health = o.health + self.healRate * dt
                end
            end
            self.moveTowardsEnemy = self.moveTowardsEnemy + (o.position - self.position)
        end
    end

    self.acceleration = (self.moveTowardsPlayer + self.moveAway + self.moveTowardsEnemy*0.01):normalized() * self.speed
end

function Healer:handleCollision(obj)
    if obj:isInstanceOf(Enemy) then

    end
end

function Healer:draw()
    Enemy.draw(self)
end

Tank = class('Tank', Enemy)

function Tank:initialize(position)
    Enemy.initialize(self, position)
    self.originalColor = {122, 214, 210, 255}
    self.radius = 20
    self.sides = 6
    self:randomizeAppearance()

    self.speed = 350
    self.knockbackResistance = 0.8

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

        local num = math.random(2, 4)
        for i=1, num do
            local d = -1 * obj.velocity -- incoming vector
            local n = obj.position - self.position -- vector to reflect off of
            local r = d:mirrorOn(n) -- result vector
            r:rotate_inplace(math.rad(math.random(-90, 90)))

            local offset = vector(WINDOW_OFFSET.x, WINDOW_OFFSET.y) + r

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
    self.originalColor = {127, 127, 127, 127}
    self.radius = 15 + math.random(-2, 2)
    self.sides = 4

    self:randomizeAppearance(0.05, 0.1)
    self.speed = 750
    self.doTeleport = false

    self.position = position
    self.touchDamage = player.maxHealth/5

    self.health = 100
    self.maxHealth = 100
end

function Ninja:update(dt)
    Enemy.update(self, dt)
    if self.doTeleport then
        local teleport = vector(math.random(-200, 200),
                                math.random(-200, 200))
        self.position = self.position + teleport
        self.position = self.position + (self.position - player.position):normalized()*250
        self.doTeleport = false
    end

    self.moveTowardsPlayer = (player.position - self.position):normalized()

    self.acceleration = (self.moveTowardsPlayer + self.moveAway):normalized() * self.speed
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
                self.drawTeleportLine = true
                self.drawTeleportLineTime = 0.5
                self.oldPosition = self.position
            end
        end
    end
end

function Ninja:draw()
    Enemy.draw(self)

    if self.drawTeleportLine then
        love.graphics.setLineWidth(3)
        love.graphics.setColor(self.originalColor)
        love.graphics.line(self.oldPosition.x, self.oldPosition.y, self.position.x, self.position.y)
        self.drawTeleportLine = false
    end
end