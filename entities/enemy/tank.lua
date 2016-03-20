Tank = class('Tank', Enemy)

function Tank:initialize(position)
    Enemy.initialize(self, position)
    self.originalColor = {122, 214, 210, 255}
    self.sides = 6
    self.radius = 20

  	self.hue = 230
  	self.saturation = 80
  	self.lightness = 50
    self:randomizeAppearance(1, 3, 5, 0.2)

    local radiusOrig = 20

    self.speed = 350 * 1/(self.radius/radiusOrig)
    self.touchDamage = 65 * (self.radius/radiusOrig)

    self.knockbackResistance = 0.8
    self.damageResistance = 0.1

    self.position = position

    self.ricochetBulletDamage = 5

    self.maxHealth = 750
    self.health = self.maxHealth
end

function Tank:update(dt)
    Enemy.update(self, dt)
    self.moveTowardsPlayer = (player.position - self.position):normalized()

    self.acceleration = (self.moveTowardsPlayer + self.moveAway):normalized() * self.speed
end

function Tank:handleCollision(collision)
    local obj = collision.other

    if obj:isInstanceOf(Bullet) then
        if obj.source == self then return end
        if obj.source:isInstanceOf(Tank) then return end
        if obj.alreadyCollided then return end

		-- bullets have ~1/4 chance of not bouncing
        --if math.random() > .75 then return end

        local num = math.random(1, 3)
        for i=1, num do
            local d = -1 * obj.velocity -- incoming vector
            local n = obj.position - self.position -- vector to reflect off of
            local r = d:mirrorOn(n) -- result vector
            r:rotate_inplace(math.rad(math.random(-90, 90)))

            local offset = r

            local b = game:addBullet(Bullet:new(
                obj.position,
                player.position + offset,
                self.velocity)
            )

            b:setSource(self)
            b:setDamage(self.ricochetBulletDamage)
            b:setSpeed(obj.velocity:len()*1.4)
            b:setRadius(math.random(3, 4))
            obj.alreadyCollided = true
        end
    end
end
