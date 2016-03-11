Blob = class('Blob', Enemy)

function Blob:initialize(position)
    Enemy.initialize(self, position)
    self.originalColor = {231, 76, 60, 255}
    self.sides = 4
    self.radius = 15

    self.hue = 12
    self.saturation = 100
    self.lightness = 50
    self:randomizeAppearance(1, 3, 5, 0.1)

    local radiusOrig = 15

    self.speed = math.sqrt(750 * 1/(self.radius/radiusOrig)) * 20
    self.touchDamage = 25 * (self.radius/radiusOrig)

    self.position = position
    self.health = 100
    self.maxHealth = 100
    self.healthRadius = self.radius*self.health/self.maxHealth
end

function Blob:update(dt)
    Enemy.update(self, dt)
    self.moveTowardsPlayer = player.position - self.position

    self.acceleration = (self.moveTowardsPlayer + self.moveAway):normalized() * self.speed
end

function Blob:handleCollision(collision)

end
