Enemy = class('Enemy', Entity)

function Enemy:initialize(position)
    Entity.initialize(self)
    self.color = {231, 76, 60, 255}
    self.radius = 15
    self.sides = 4

    self.position = position
    self.moveAwayVector = vector(0, 0)
    self.touchDamage = player.maxHealth/5

    self.health = 100
    self.maxHealth = 100
end

function Enemy:update(dt)
    self.moveAway = vector(0, 0)
    self.moveTowardsPlayer = (player.position - self.position):normalized()

    -- enemy fades away as it loses health
    self.color[4] = math.max(32, 255*(self.health/self.maxHealth))

    if self.health <= 0 then
        self.destroy = true
        game.particleSystem:setPosition(self.position.x, self.position.y)
        game.particleSystem:setColors(255, 0, 0, 255, 0, 0, 0, 0)
        game.particleSystem:emit(50)
        game:shakeScreen(1, 75)
    elseif self.health > self.maxHealth then
        self.health = self.maxHealth
    end

    self:checkCollision(self.handleCollision)

    self.acceleration = (self.moveTowardsPlayer + self.moveAway):normalized() * self.speed
    self:physicsUpdate(dt)
end

function Enemy:handleCollision(obj)
    if obj:isInstanceOf(Enemy) and not obj:isInstanceOf(LineEnemy) then
        if self.position:dist(obj.position) < self.radius + obj.radius then
            v = vector(self.x - obj.x, self.y - obj.y)
            self.moveAway = self.moveAway + v:normalized()
        end
    end

    if obj:isInstanceOf(Bullet) then
        if self.position:dist(obj.position) < self.radius + obj.radius then
            self.health = self.health - obj.damage
            game.particleSystem:setColors(255, 0, 0, 255, 0, 0, 0, 0)
            game.particleSystem:setPosition(self.position.x, self.position.y)
            game.particleSystem:emit(10)
            game:removeBullet(obj)
            game:shakeScreen(1, 25)
        end
    end
end

function Enemy:keypressed(key, isrepeat)

end

LineEnemy = class('LineEnemy', Entity)

function LineEnemy:initialize(start, finish)
    Entity.initialize(self)
    self.color = {241, 196, 0}
    self.radius = 18
    self.sides = 3

    self.position = start
    self.start = start
    self.finish = finish
    self.target = finish
    self.speed = 2500

    self.touchDamage = player.maxHealth/2

    self.health = 50
    self.maxHealth = 50
end

function LineEnemy:update(dt)
    if self.health <= 0 then
        self.destroy = true
        game.particleSystem:setPosition(self.position.x, self.position.y)
        game.particleSystem:setColors(255, 255, 0, 255, 0, 0, 0, 0)
        game.particleSystem:emit(50)
    elseif self.health > self.maxHealth then
        self.health = self.maxHealth
    end

    if self.position:dist(self.target) < 2 then
        if self.target == self.finish then
            self.target = self.start
        else
            self.target = self.finish
        end
    end

    self:checkCollision(self.handleCollision)

    self.acceleration = (self.target - self.position):normalized() * self.speed
    self:physicsUpdate(dt)
end

function LineEnemy:handleCollision(obj)
    if obj:isInstanceOf(Bullet) then
        if self.position:dist(obj.position) < self.radius + obj.radius then
            self.health = self.health - obj.damage
            game.particleSystem:setColors(255, 255, 0, 255, 0, 0, 0, 0)
            game.particleSystem:setPosition(self.position.x, self.position.y)
            game.particleSystem:emit(10)
            game:removeBullet(obj)
        end
    end
end