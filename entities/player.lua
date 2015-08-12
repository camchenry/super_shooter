Player = class('Player')

function Player:initialize()
    self.color = {255, 255, 255}
    self.radius = 15

    self.position = vector(-100, 100)
    self.velocity = vector(0, 0)
    self.dragFactor = 0.10
    self.acceleration = vector(0, 0)
    self.accelConstant = 1500
    self.heat = 0
    self.rateOfFire = (1/2) -- 1 / shots per second
    self.health = 100
    self.maxHealth = 100

    self.width = self.radius * 2
    self.height = self.radius * 2
    self.x, self.y = self.position:unpack()
    self.prev_x, self.prev_y = self.position:unpack()
end

function Player:update(dt)
    self.width, self.height = self.radius*2, self.radius*2
    self.x, self.y = self.position:unpack()

    if love.keyboard.isDown("w") then
        self.acceleration.y = -self.accelConstant
    elseif love.keyboard.isDown("s") then
        self.acceleration.y = self.accelConstant
    end

    if love.keyboard.isDown("a") then
        self.acceleration.x = -self.accelConstant
    elseif love.keyboard.isDown("d") then
        self.acceleration.x = self.accelConstant
    end

    if love.mouse.isDown('l') then
        if self.heat <= 0 then
            game:addBullet(Bullet:new(
                self.position,
                vector(love.mouse.getX(), love.mouse.getY()),
                self.velocity)
            ):setSource(self):setDamage(50)
            self.heat = self.rateOfFire
        end
    end

    if self.heat > 0 then
        self.heat = self.heat - dt
    end

    if self.health <= 0 then
        game:removeObject(self)
    elseif self.health > self.maxHealth then
        self.health = self.maxHealth
    end

    local collidableObjects = quadtree:getCollidableObjects(self, true)
    for i, obj in pairs(collidableObjects) do
        if self.position:dist(obj.position) < self.radius + obj.radius then
            if obj:isInstanceOf(Bullet) then
                if obj.source ~= self then
                    self.health = self.health - obj.damage
                    game:removeBullet(obj)
                end
            elseif obj:isInstanceOf(Enemy) then
                self.health = self.health - obj.touchDamage*dt
            end
        end
    end

    self.prev_x, self.prev_y = self.position:unpack()
    self.acceleration = self.acceleration - (self.acceleration * self.dragFactor)
    self.velocity = self.velocity - (self.velocity * self.dragFactor)
    self.velocity = self.velocity + self.acceleration * dt
    self.position = self.position + self.velocity * dt
    self.x, self.y = self.position:unpack()
end

function Player:keypressed(key, isrepeat)

end

function Player:draw()
    local rgba = {love.graphics.getColor()}
    love.graphics.setColor(self.color)
    love.graphics.circle("line", self.position.x, self.position.y, self.radius)
    love.graphics.setColor(rgba)
end