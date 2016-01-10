Player = class('Player')

function Player:initialize()
    self.color = {255, 255, 255}
    self.radius = 15

    self.position = vector(-100, 100)
    self.oldVelocity = vector(0, 0)
    self.velocity = vector(0, 0)
    self.friction = 5
    self.acceleration = vector(0, 0)
    self.speed = 1350
    self.heat = 0
    self.shotsPerSecond = 4
    self.rateOfFire = (1/self.shotsPerSecond)
    self.canShoot = true
    self.bulletVelocity = 300
    self.bulletDamage = 60
    self.bulletDropoffAmount = 30
    self.bulletDropoffDistance = 100
    self.damageMultiplier = 1.0
    self.touchDamage = 0
    self.bulletLife = 1.5
    self.bulletRadius = 5
    self.healthRegen = 0
    self.regenWaitAfterHurt = 5
    self.maxHealth = 115
    self.health = self.maxHealth
    self.damageResistance = 0.0
    self.criticalChance = 0.01
    self.criticalMultiplier = 2.0

	self.offScreenDamage = self.maxHealth/20
    self.regenTimer = 0
    signal.register('playerHurt', function()
        self.regenTimer = self.regenWaitAfterHurt
    end)

    self.width = self.radius * 2
    self.height = self.radius * 2
    self.x, self.y = self.position:unpack()
    self.prev_x, self.prev_y = self.position:unpack()
end

function Player:update(dt)
    self.width, self.height = self.radius*2, self.radius*2
    self.x, self.y = self.position:unpack()

    self.acceleration = vector(0, 0)

    if love.keyboard.isDown("w", "up") then
        self.acceleration.y = -self.speed
    elseif love.keyboard.isDown("s", "down") then
        self.acceleration.y = self.speed
    end

    if love.keyboard.isDown("a", "left") then
        self.acceleration.x = -self.speed
    elseif love.keyboard.isDown("d", "right") then
        self.acceleration.x = self.speed
    end
    
    local dist = math.huge
    local closest = nil

    for i, enemy in ipairs(objects) do    
        local d = self.position:dist(enemy.position)

        if d < dist and enemy ~= player then
            dist = d
            closest = enemy
        end
    end
    self.closestEnemy = closest

    if love.mouse.isDown(1) and self.canShoot then
		if game.time > .25 then -- prevents a bullet from being shot when the game starts
			if self.heat <= 0 then
				signal.emit('playerShot')

                local target = nil
                -- trackpad shooting mode
                if game.trackpadMode and self.closestEnemy ~= player and self.closestEnemy ~= nil then
                    target = self.closestEnemy.position + vector(math.random(-35, 35), math.random(-35, 35)) + WINDOW_OFFSET
                else
                    target = vector(love.mouse.getX(), love.mouse.getY())
                end
                local bullet = game:addBullet(Bullet:new(
                    self.position,
                    target,
                    self.velocity
                ))
                bullet:setSource(self)
                -- critical hits
                if math.random() <= self.criticalChance then
                    bullet:setDamage(self.bulletDamage * self.damageMultiplier * self.criticalMultiplier)
                    bullet.critical = true
                else
                    bullet:setDamage(self.bulletDamage * self.damageMultiplier)
                    bullet.critical = false
                end 
                bullet:setSpeed(self.bulletVelocity)
                bullet:setRadius(self.bulletRadius)
                bullet:setLife(self.bulletLife)
                bullet.dropoffDistance = self.bulletDropoffDistance
                bullet.dropoffAmount = self.bulletDropoffAmount

				self.heat = self.rateOfFire
			end
		end
	end

    if self.heat > 0 then
        self.heat = self.heat - dt
    end

    self.rateOfFire = (1/self.shotsPerSecond)

	if math.abs(self.x) >= WINDOW_OFFSET.x or math.abs(self.y) >= WINDOW_OFFSET.y then
		self.health = self.health - self.offScreenDamage * dt
	end

    self.regenTimer = self.regenTimer - dt
    if self.regenTimer <= 0 then
        self.health = self.health + self.healthRegen * dt
	end

    if self.health <= 0 then
        game:removeObject(self)
        signal.emit('playerDeath')
    elseif self.health > self.maxHealth then
        self.health = self.maxHealth
    end

    self.maxHealth = math.max(1, self.maxHealth)

    local collidableObjects = quadtree:getCollidableObjects(self, true)
    for i, obj in pairs(collidableObjects) do
        if self.position:dist(obj.position) < self.radius + obj.radius then
            if obj:isInstanceOf(Bullet) then
                if (obj.source ~= self) then
                    self.health = self.health - obj.damage * (1 - self.damageResistance)
                    game:removeBullet(obj)
                    signal.emit('playerHurt')
                end
            elseif obj:isInstanceOf(Enemy) then
                self.health = self.health - obj.touchDamage * dt * (1 - self.damageResistance)
                signal.emit('playerHurt')
            end
        end
    end

    self.prev_x, self.prev_y = self.position:unpack()
    -- verlet integration, much more accurate than euler integration for constant acceleration and variable timesteps
    self.acceleration = self.acceleration:normalized() * self.speed
    self.oldVelocity = self.velocity
    self.velocity = self.velocity + (self.acceleration - self.friction*self.velocity) * dt
    self.position = self.position + (self.oldVelocity + self.velocity) * 0.5 * dt

    self.x, self.y = self.position:unpack()
end

function Player:keypressed(key, isrepeat)

end

function Player:draw()
    local rgba = {love.graphics.getColor()}
    love.graphics.setColor(self.color)
    love.graphics.circle("line", self.position.x, self.position.y, self.radius)
    love.graphics.setColor(rgba)

    if self.closestEnemy ~= nil then
        
    end
end

function Player:getX()
    return self.position.x
end

function Player:getY()
    return self.position.y
end