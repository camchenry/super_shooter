Enemy = class('Enemy')

function Enemy:initialize(position)
    self.color = {231, 76, 60}
    self.radius = 15
    self.sides = 4

    self.position = position or vector(0, 0)
    self.velocity = vector(0, 0)
    self.moveAwayVector = vector(0, 0)
    self.dragFactor = 0.15
    self.acceleration = vector(0, 0)
    self.accelConstant = 850
    self.heat = 0
    self.rateOfFire = 20 -- 4 shots per second

    self.touchDamage = player.maxHealth/5

    self.health = 100
    self.maxHealth = 100

    self.width = self.radius * 2
    self.height = self.radius * 2
    self.x, self.y = self.position:unpack()
    self.prev_x, self.prev_y = self.position:unpack()
end

function Enemy:update(dt)
    self.width, self.height = self.radius*2, self.radius*2
    self.moveAway = vector(0, 0)
    self.moveTowardsPlayer = (player.position - self.position):normalized()

    if self.health <= 0 then
        game:removeObject(self)
        game.particleSystem:setPosition(self.position.x, self.position.y)
        game.particleSystem:setColors(255, 0, 0, 255, 0, 0, 0, 0)
        game.particleSystem:emit(50)
    elseif self.health > self.maxHealth then
        self.health = self.maxHealth
    end

    local collidableObjects = quadtree:getCollidableObjects(self, true)
    for i, obj in pairs(collidableObjects) do
        if obj:isInstanceOf(Enemy) and not obj:isInstanceOf(LineEnemy) then
            if self.position:dist(obj.position) < self.radius + obj.radius + 10 then
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
            end
        end
    end

    self.prev_x, self.prev_y = self.position:unpack()
    self.acceleration = (self.moveTowardsPlayer + self.moveAway):normalized() * self.accelConstant
    self.acceleration = self.acceleration - (self.acceleration * self.dragFactor)
    self.velocity = self.velocity - (self.velocity * self.dragFactor)
    self.velocity = self.velocity + self.acceleration * dt
    self.position = self.position + self.velocity * dt
    self.x, self.y = self.position:unpack()
end

function Enemy:keypressed(key, isrepeat)

end

function Enemy:draw()
    if self.lineWidth then
        love.graphics.setLineWidth(self.lineWidth)
    else
        love.graphics.setLineWidth(1)
    end
    love.graphics.push()
    local rgba = {love.graphics.getColor()}
    local alpha = 255*(self.health/self.maxHealth)
    table.insert(self.color, 4, math.min(math.max(alpha, 64), 255))
    love.graphics.setColor(self.color)
    love.graphics.circle("line", self.position.x, self.position.y, self.radius, self.sides)
    if self.invincible ~= nil and self.invincible then
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.circle("line", self.position.x, self.position.y, self.radius+5, self.sides)
    end
    love.graphics.setColor(rgba)
    love.graphics.pop()
    love.graphics.setLineWidth(1)
end

LineEnemy = class('LineEnemy', Enemy)

function LineEnemy:initialize(start, finish)
    self.color = {241, 196, 0}
    self.radius = 18
    self.sides = 3

    self.position = start or vector(0, 0)
    self.start = start
    self.finish = finish
    self.target = finish
    self.velocity = vector(0, 0)
    self.moveAwayVector = vector(0, 0)
    self.dragFactor = 0.15
    self.acceleration = vector(0, 0)
    self.accelConstant = 2500
    self.heat = 0
    self.rateOfFire = 20 -- 4 shots per second

    self.touchDamage = player.maxHealth/2

    self.health = 50
    self.maxHealth = 50

    self.width = self.radius * 2
    self.height = self.radius * 2
    self.x, self.y = self.position:unpack()
    self.prev_x, self.prev_y = self.position:unpack()
end

function LineEnemy:update(dt)
    self.width, self.height = self.radius*2, self.radius*2
    self.moveTowardsPoint = (self.target - self.position):normalized()

    if self.health <= 0 then
        game:removeObject(self)
        game.particleSystem:setPosition(self.position.x, self.position.y)
        game.particleSystem:setColors(255, 255, 0, 255, 0, 0, 0, 0)
        game.particleSystem:emit(50)
    elseif self.health > self.maxHealth then
        self.health = self.maxHealth
    end

    if self.position:dist(self.target) < 5 then
        if self.target == self.finish then
            self.target = self.start
        else
            self.target = self.finish
        end
    end

    self.prev_x, self.prev_y = self.position:unpack()
    self.acceleration = self.moveTowardsPoint:normalized() * self.accelConstant
    self.acceleration = self.acceleration - (self.acceleration * self.dragFactor)
    self.velocity = self.velocity - (self.velocity * self.dragFactor)
    self.velocity = self.velocity + self.acceleration * dt
    self.position = self.position + self.velocity * dt
    self.x, self.y = self.position:unpack()

    local collidableObjects = quadtree:getCollidableObjects(self, true)
    for i, obj in pairs(collidableObjects) do
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
end