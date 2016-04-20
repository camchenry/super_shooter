Healer = class('Healer', Enemy)

function Healer:initialize(position)
    Enemy.initialize(self, position)
    self.sides = 5

    self.hue = 125
    self.saturation = 90
    self.lightness = 50
    self:randomizeAppearance(1, 3, 5, 0.1)

    local radiusOrig = 11
    self.radius = radiusOrig

    self.speed = 400 * 1/(self.radius/radiusOrig)
    self.touchDamage = 12 * (self.radius/radiusOrig)
    self.position = position

    self.maxHealth = 75
    self.health = self.maxHealth
    self.knockbackResistance = 0.5

  	self.healRate = 8
    self.healRadius = 150
end

function Healer:update(dt)
    Enemy.update(self, dt)
    
    if not self.isDead then -- stop it from healing during the death tween
        self.moveTowardsPlayer = (player.position - self.position):normalized()
        self.moveTowardsEnemy = vector(0, 0)

        for i, o in pairs(objects) do
            if o:isInstanceOf(Enemy) and o ~= self and not o.isDead then -- I'm not sure why the isDead check doesn't work
                if o.position:dist(self.position) <= self.healRadius then
                    if o.health > 0 and o.health < o.maxHealth then
                        o.health = o.health + self.healRate * dt
                        signal.emit('healing', o, self)
                    end
                end

                if not o:isInstanceOf(Healer) and not o:isInstanceOf(Sweeper) then -- healers will not move towards other healers or sweepers
                    if o.health < o.maxHealth then -- favor moving towards injured enemies
                        self.moveTowardsEnemy = self.moveTowardsEnemy + (o.position - self.position)*1.2
                    else
                        self.moveTowardsEnemy = self.moveTowardsEnemy + (o.position - self.position)
                    end
                end
            end
        end

        self.acceleration = (self.moveTowardsPlayer*0.5 + self.moveTowardsEnemy + self.moveAway):normalized() * self.speed
    end
end

function Healer:handleCollision(collision)

end

function Healer:draw()
    Enemy.draw(self)

    love.graphics.setColor(77, 214, 79, 70)

    for i, o in pairs(objects) do
        if o:isInstanceOf(Enemy) and o ~= self then
            if o.position:dist(self.position) <= self.healRadius then
                love.graphics.line(self.position.x, self.position.y, o.position.x, o.position.y)
            end
        end
    end

    love.graphics.setColor(255, 255, 255)
end
