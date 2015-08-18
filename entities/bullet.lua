Bullet = class('Bullet')

function Bullet:initialize(position, target, velocity)
    self.destroy = false

    self.color = {255, 255, 255}
    self.radius = 5

    self.position = position
    if velocity ~= nil then
        self.velocity = velocity
    else
        self.velocity = vector(0, 0)
    end
    self.target = target
    self.source = nil

    self.speed = 200
    self.life = 1.5 -- seconds
    self.damage = 0

    self.velocity = (self.target - self.position - WINDOW_OFFSET):normalized() * self.speed
    self.width = self.radius * 2
    self.height = self.radius * 2
    self.x, self.y = self.position:unpack()
    self.prev_x, self.prev_y = self.position:unpack()
end

function Bullet:update(dt)
    self.prev_x, self.prev_y = self.position:unpack()
    self.position = self.position + self.velocity * dt
    self.x, self.y = self.position:unpack()
    self.width, self.height = self.radius*2, self.radius*2

    self.life = self.life - dt

    if self.life <= 0 then
        self.destroy = true
    end

    if self.position.x > love.graphics.getWidth()-WINDOW_OFFSET.x or self.position.x < 0-WINDOW_OFFSET.x then
        self.destroy = true
    end

    if self.position.y > love.graphics.getHeight()-WINDOW_OFFSET.y or self.position.y < 0-WINDOW_OFFSET.y then
        self.destroy = true
    end
end

function Bullet:draw()
    love.graphics.circle("fill", self.position.x, self.position.y, self.radius)
end

function Bullet:setLife(life)
    self.life = life
    return self
end

function Bullet:setSpeed(speed)
    self.speed = speed
    return self
end

function Bullet:setSource(source)
    self.source = source
    return self
end

function Bullet:setColor(color)
    assert(type(color) == "table")
    self.color = color
    return self
end

function Bullet:setDamage(damage)
    self.damage = damage
    return self
end