Ninja = class('Ninja', Enemy)

function Ninja:initialize(position)
    Enemy.initialize(self, position)
    self.originalColor = {255, 255, 255, 200}
    self.sides = 4

  	self.hue = 280
  	self.saturation = 20
  	self.lightness = 50

    local radiusOrig = 15
    self.radius = radiusOrig

    self.speed = 800 * 1/(self.radius/radiusOrig)
    self.touchDamage = 45 * (self.radius/radiusOrig)

    self.doTeleport = false
    self.drawTeleportLineTime = 0

    self.sprintCooldownMax = 5
    self.sprintCooldown = self.sprintCooldownMax + math.random(2, 7)
    -- what time to start telegraphing the attack
    -- stop the enemy, shake, change color, etc
    self.sprintTelegraphTime = 3
    -- for how long sprint is considered activated
    self.sprintActivatedTime = 1

    self.position = position

    self.health = 500
    self.maxHealth = 500
end

function Ninja:update(dt)
    Enemy.update(self, dt)

    if self.doTeleport and self.health > 0 and not self.sprinting then
        local teleport = vector(math.random(-200, 200),
                                math.random(-200, 200))
        self.position = self.position + teleport
        self.position = self.position + (self.position - player.position):normalized()*250
        self.doTeleport = false
    end

    self.drawTeleportLineTime = self.drawTeleportLineTime - dt
    self.sprintCooldown = self.sprintCooldown - dt

    local t = self.position:dist(player.position) / self.speed
    local predictedPosition = player.position + player.velocity * t
    self.moveTowards = (predictedPosition - self.position):normalized()
    self.acceleration = (self.moveTowards + self.moveAway):normalized() * self.speed

    -- start the attack
    if self.sprintCooldown < self.sprintActivatedTime then
        self.speed = 5000
        self.touchDamage = 375
    -- start telegraphing the attack
    elseif self.sprintCooldown < self.sprintTelegraphTime then
        self.sprinting = true
        self.acceleration = vector(0, 0)
        self.position = self.position + vector((math.random()-0.5)*2, (math.random()-0.5)*2)/2
        self.damageResistance = -0.5
    else
        self.speed = 800
        self.touchDamage = 40
        self.damageResistance = 0
    end

    if self.sprintCooldown < 0 then
        self.sprinting = false
        self.sprintCooldown = self.sprintCooldownMax
    end
end

function Ninja:handleCollision(collision)
    local obj = collision.other

    if obj:isInstanceOf(Bullet) then
        if obj.source ~= nil and obj.source:isInstanceOf(self.class) then return end
        if self.boss ~= nil then
            if obj.source == self.boss then return end
        end

        -- check for proximity and invincible
        if self.position:dist(obj.position) < self.radius + obj.radius then
            if not self.invincible then
                self.doTeleport = true
                self.drawTeleportLineTime = 35/1000
                self.oldPosition = self.position
            end
        end
    end
end

function Ninja:draw()
    Enemy.draw(self)

    if self.oldPosition and self.drawTeleportLineTime > 0 then
        love.graphics.setLineWidth(3)
        love.graphics.setColor(self.originalColor)
        love.graphics.line(self.oldPosition.x, self.oldPosition.y, self.position.x, self.position.y)
        self.drawTeleportLine = false
    end

    if self.sprintCooldown < self.sprintTelegraphTime then
        -- goes from 0 to 1 when sprint cooldown is 0
        local scale = (self.sprintTelegraphTime - self.sprintCooldown + self.sprintActivatedTime)/(self.sprintTelegraphTime + self.sprintActivatedTime)

        love.graphics.setColor(self.originalColor)
        love.graphics.circle("fill", self.position.x, self.position.y, scale*self.radius, self.sides)
    end
end
