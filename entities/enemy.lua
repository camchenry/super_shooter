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

    self.flashTime = 0
end

function Enemy:update(dt)
    self.moveAway = vector(0, 0)
    self.moveTowardsPlayer = (player.position - self.position):normalized()

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

    self:physicsUpdate(dt)

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
			if not self.invincible then
				self.health = self.health - obj.damage
				signal.emit('enemyHit', self)
				game:removeBullet(obj)
				self.flashTime = 20/1000
			end
        end
    end
end

Blob = class('Blob', Enemy)

function Blob:initialize(position)
    Enemy.initialize(self, position)
    self.originalColor = {231, 76, 60, 255}
    self.radius = 15
    self.sides = 4

    self.speed = 400

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

    self.speed = 300

    self.position = position
    self.touchDamage = player.maxHealth/10

    self.maxHealth = 100
    self.health = self.maxHealth
	
	self.healRate = 20
    self.healRadius = 100
end

function Healer:update(dt)
    Enemy.update(self, dt)
    self.moveTowardsPlayer = (player.position - self.position):normalized()

    self.acceleration = (self.moveTowardsPlayer + self.moveAway):normalized() * self.speed

    for i, o in pairs(quadtree:getCollidableObjects(self, true)) do
        if o:isInstanceOf(Enemy) then
            if o.position:dist(self.position) <= self.healRadius then
                if o.health >= 0 then
                    o.health = o.health + self.healRate * dt
                end
            end
        end
    end
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

    self.speed = 200

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
        if math.random() > .75 then return end

        local randOffset = vector(math.random(-100, 100), math.random(-100, 100))

        game:addBullet(Bullet:new(
            obj.position,
            player.position + vector(WINDOW_OFFSET.x, WINDOW_OFFSET.y) + randOffset,
            self.velocity)
        ):setSource(self):setDamage(obj.damage*0.25):setSpeed(obj.velocity:len()*1.25)
        obj.alreadyCollided = true
		obj.life = 0
    end
end