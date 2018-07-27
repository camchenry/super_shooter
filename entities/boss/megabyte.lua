Megabyte = class('Megabyte', Enemy)

function Megabyte:initialize(position)
    Enemy.initialize(self, vector(0, 0))
    self.name = "Megabyte"
    self.radius = 0
    self.sides = 6

    self.heat = 0
    self.rateOfFire = (1/4) -- 4 shots per second
    self.fireAngle = 3*math.pi/4 + .33
    self.fireAngleMultiplier = 1
    self.speed = 200

	self.hue = 200
	self.saturation = 100
	self.lightness = 60

    self.touchDamage = 150
    self.health = 2500
    self.maxHealth = 2500
    self.invincible = true
    self.knockbackResistance = 1
    self.phase = 1

    self.lineWidth = 1

    self.maxRadius = 70

    self.spawnTimer = cron.after(2.5, function()
        self:spawnMinions(4, 8)
    end)
    self.spawnTween = tween(2.5, self, {radius = self.maxRadius}, "inOutCubic", function() self.spawnTween = nil end)

    self.minions = {}
end

function Megabyte:spawnMinions(inner, outer)
    local numMinions = outer or 2
    local d = 2*math.pi/numMinions

    local numMinions2 = inner or 4
    local d2 = 2*math.pi/numMinions2

    for i=1, numMinions do
        local m = game:add(MegabyteEnemy:new(65, d*i, math.rad(15), self))
        table.insert(self.minions, m)
    end

    for i=1, numMinions2 do
        local m = game:add(MegabyteEnemy:new(15, d2*i, math.rad(25), self))
        table.insert(self.minions, m)
    end
end

function Megabyte:update(dt)
    Enemy.update(self, dt)

    self.invincible = (#self.minions > 0) or (self.spawnTween ~= nil)

    if self.spawnTimer then
        self.spawnTimer:update(dt)
    end

    for i=#self.minions, 1, -1 do
        if self.minions[i].health <= 0 then
            table.remove(self.minions, i)
        end
    end

    if self.health <= self.maxHealth/2 and self.phase == 1 then
        self:spawnMinions(12, 16)
        self.rateOfFire = 1/8
        self.phase = 2
        self.fireAngleMultiplier = 1.75
    end

    if self.phase == 2 then
        local p = vector(math.cos(self.fireAngle/2)*250, math.sin(self.fireAngle/2)*250)
        self.acceleration = (p - self.position):normalized() * self.speed
    end

    if self.heat <= 0 and not (self.spawnTimer.running < 2.5) then
        game:addBullet(Bullet:new(
            self.position,
            vector(self.x+math.cos(self.fireAngle)*250, self.y+math.sin(self.fireAngle)*250)
        ):setLife(5):setSource(self):setDamage(10):setSpeed(350))
        game:addBullet(Bullet:new(
            self.position,
            vector(self.x+math.cos(self.fireAngle-math.pi)*250, self.y+math.sin(self.fireAngle-math.pi)*250)
        ):setLife(5):setSource(self):setDamage(10):setSpeed(350))
        self.heat = self.rateOfFire

        -- bullet shot straight at the player
        if math.random() > .9 then
            game:addBullet(Bullet:new(
                self.position,
                player.position + (player.velocity*player.position:dist(self.position)/350)
            ):setLife(6):setSource(self):setDamage(15):setSpeed(350))
        end
    end

    if self.heat > 0 then
        self.heat = self.heat - dt
    end

    self.fireAngle = self.fireAngle + (math.pi/2*math.random()*1.3) * dt * self.fireAngleMultiplier
end

function Megabyte:handleCollision(obj)

end

function Megabyte:draw()
    Enemy.draw(self)

    love.graphics.setColor(1, 1, 1)
    if self.invincible then
        love.graphics.circle("line", self.x, self.y, self.radius+10, self.sides)
    end
end

MegabyteEnemy = class('MegabyteEnemy', Enemy)

function MegabyteEnemy:initialize(offset, angle, angleIncrease, boss)
    Enemy.initialize(self, vector(0, 0))
    self.radius = 15
    self.sides = 4

	self.hue = 200
	self.saturation = 100
	self.lightness = 50

    self.health = 100
    self.maxHealth = 100
    self.touchDamage = 40

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
