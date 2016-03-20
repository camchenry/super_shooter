Sweeper = class('Sweeper', Enemy)

function Sweeper:initialize(start, percent, num, radius)
    Enemy.initialize(self, start)
    self.originalColor = {241, 196, 0, 255}
    self.sides = 3

    self.hue = 65
    self.saturation = 95
    self.lightness = 50
    self:randomizeAppearance(1, 3, 5, 0.05)

    local radiusOrig = 18
    self.radius = radiusOrig

    self.speed = 800 * 1/(self.radius/radiusOrig)
    self.touchDamage = 80 * (self.radius/radiusOrig)

    self.angle = percent * 2 * math.pi
    self.orbitRadius = radius or math.random(100, math.min(game.worldSize.x/2, game.worldSize.y/2))

  	self.rotateSpeed = math.min(0.25, math.max(1.2, 1 - math.random() * math.random() + math.random())) -- revolutions per second
    self.rotateSpeed = 50*self.rotateSpeed/math.sqrt(self.orbitRadius)
    self.rotateDirection = (math.random() > 0.5) and -1 or 1
    self.start = start
    self.target = finish
    self.friction = 3
    self.knockbackResistance = 1

    self.health = 75
    self.maxHealth = 75
end

function Sweeper:update(dt)
    Enemy.update(self, dt)

    local position = vector(
        math.cos(self.angle) * self.orbitRadius,
        math.sin(self.angle) * self.orbitRadius
    )

    --self.moveTowardsPosition = (self.start - self.position + position):normalized()
    --local speed = math.atan2(self.position.y-self.moveTowardsPosition.y, self.position.x-self.moveTowardsPosition.x) + 5
    --self.acceleration = (self.moveTowardsPosition):normalized()*speed

    self.position = self.start + position

    self.angle = self.angle + dt * self.rotateSpeed * self.rotateDirection
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
