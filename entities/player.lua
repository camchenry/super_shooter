Player = class('Player')

function Player:initialize()
    self.color = {255, 255, 255}
    self.radius = 15

    self.position = vector(-100, 100)
    self.oldVelocity = vector(0, 0)
    self.velocity = vector(0, 0)
    self.friction = 2
    self.acceleration = vector(0, 0)
    self.speed = 450
    self.heat = 0
    self.rateOfFire = (1/6) -- 1 / shots per second
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

    self.acceleration = vector(0, 0)

    if love.keyboard.isDown("w") then
        self.acceleration.y = -self.speed
    elseif love.keyboard.isDown("s") then
        self.acceleration.y = self.speed
    end

    if love.keyboard.isDown("a") then
        self.acceleration.x = -self.speed
    elseif love.keyboard.isDown("d") then
        self.acceleration.x = self.speed
    end

    if love.mouse.isDown('l') then
        if self.heat <= 0 then
            game:addBullet(Bullet:new(
                self.position,
                vector(love.mouse.getX(), love.mouse.getY()),
                self.velocity)
            ):setSource(self):setDamage(20)
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
    -- verlet integration, much more accurate than euler integration for constant acceleration and variable timesteps
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
end

function Player:getX()
    return self.position.x
end

function Player:getY()
    return self.position.y
end