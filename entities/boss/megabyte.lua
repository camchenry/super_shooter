Megabyte = class('Megabyte', Enemy)

function Megabyte:initialize(position)
    self.name = "Megabyte"
    self.color = {52, 152, 219}
    self.radius = 0
    self.sides = 6

    self.position = vector(love.graphics.getWidth()/2-WINDOW_OFFSET.x+1, love.graphics.getHeight()/2-WINDOW_OFFSET.y+1)
    self.velocity = vector(0, 0)
    self.dragFactor = 0.15
    self.heat = 0
    self.rateOfFire = (1/2) -- 4 shots per second
    self.fireAngle = 3*math.pi/4 + .33
    self.fireAngleMultiplier = 1

    self.touchDamage = 150
    self.health = 500
    self.maxHealth = 500
    self.invincible = true
    self.phase = 1

    self.lineWidth = 3

    self.spawnTimer = cron.after(3, function()
        self:spawnMinions(4, 8)
    end)
    assert(tween ~= nil)
    self.spawnTween = tween(3, self, {radius = 80}, "inOutCubic", function() self.spawnTween = nil end)
    assert(self.spawnTween ~= nil)

    self.width = self.radius * 2
    self.height = self.radius * 2
    self.x, self.y = self.position:unpack()
    self.prev_x, self.prev_y = self.position:unpack()

    self.minions = {}
end

function Megabyte:spawnMinions(inner, outer)
    local numMinions = outer or 2
    local d = 2*math.pi/numMinions

    local numMinions2 = inner or 4
    local d2 = 2*math.pi/numMinions2

    for i=1, numMinions do
        local m = game:addObject(MegabyteEnemy:new(65, d*i, math.rad(15), self))
        table.insert(self.minions, m)
    end

    for i=1, numMinions2 do
        local m = game:addObject(MegabyteEnemy:new(15, d2*i, math.rad(25), self))
        table.insert(self.minions, m)
    end
end

function Megabyte:update(dt)
    self.width, self.height = self.radius*2, self.radius*2

    if self.spawnTimer then
        self.spawnTimer:update(dt)
    end

    if self.health <= 0 then
        game:removeObject(self)
    elseif self.health > self.maxHealth then
        self.health = self.maxHealth
    end

    for i=#self.minions, 1, -1 do
        if self.minions[i].health <= 0 then
            table.remove(self.minions, i)
        end
    end

    if self.health <= self.maxHealth/2 and self.phase == 1 then
        self:spawnMinions(12, 16)
        self.rateOfFire = 1/5
        self.phase = 2
    end

    if self.phase == 2 then
        if math.random() > 0.01 then
            self.fireAngleMultiplier = self.fireAngleMultiplier * -1
        end
    end

    self.invincible = (#self.minions > 0) or (self.spawnTween ~= nil)

    if self.heat <= 0 then
        game:addBullet(Bullet:new(
            self.position,
            vector(math.cos(self.fireAngle)*250, math.sin(self.fireAngle)*250) + WINDOW_OFFSET
        ):setLife(5):setSource(self):setDamage(15))
        game:addBullet(Bullet:new(
            self.position,
            vector(math.cos(self.fireAngle-math.pi)*250, math.sin(self.fireAngle-math.pi)*250) + WINDOW_OFFSET
        ):setLife(5):setSource(self):setDamage(15))
        self.heat = self.rateOfFire
    end

    if self.heat > 0 then
        self.heat = self.heat - dt
    end

    self.fireAngle = self.fireAngle + (math.pi/2*math.random()*1.3) * dt * self.fireAngleMultiplier

    local collidableObjects = quadtree:getCollidableObjects(self, true)
    for i, obj in pairs(collidableObjects) do
        if obj:isInstanceOf(Bullet) then
            if obj.source ~= self or not obj.source:isInstanceOf(Enemy) then
                if self.position:dist(obj.position) < self.radius + obj.radius then
                    if not self.invincible then
                        self.health = self.health - obj.damage
                    end
                    game:removeBullet(obj)
                end
            end
        end
    end

    self.prev_x, self.prev_y = self.position:unpack()
    --self.acceleration = (self.moveTowardsPoint + self.moveAway):normalized() * self.accelConstant
    --self.acceleration = self.acceleration - (self.acceleration * self.dragFactor)
    --self.velocity = self.velocity - (self.velocity * self.dragFactor)
    --self.velocity = self.velocity + self.acceleration * dt
    self.velocity = vector(0, 0)

    self.position = self.position + self.velocity * dt
    self.x, self.y = self.position:unpack()
end

MegabyteEnemy = class('MegabyteEnemy', Enemy)

function MegabyteEnemy:initialize(offset, angle, angleIncrease, boss)
    Enemy.initialize(self, vector(0, 0))
    self.color = {231, 76, 60}
    self.radius = 15
    self.sides = 4

    self.health = 100
    self.maxHealth = 100
    self.touchDamage = player.maxHealth/4

    self.offset = offset
    self.angle = angle
    self.angleIncrease = angleIncrease
    self.boss = boss
end

function MegabyteEnemy:update(dt)
    Enemy.update(self, dt)
    self.angle = self.angle + self.angleIncrease * dt
    self.position = vector(self.boss.x + math.cos(self.angle)*(self.boss.radius+self.radius+self.offset),
                           self.boss.y + math.sin(self.angle)*(self.boss.radius+self.radius+self.offset))
end

function MegabyteEnemy:keypressed(key, isrepeat)

end

function MegabyteEnemy:handleCollision(obj)

end
