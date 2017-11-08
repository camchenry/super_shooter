Tanker = class('Tanker', Enemy)

function Tanker:initialize(position)
    Enemy.initialize(self, vector(0, 0))
    self.name = "Tanker"
    self.radius = 0
    self.sides = 6

    self.heat = 0
    self.rateOfFire = 4
    self.fireAngle = 3*math.pi/4 + .33
    self.fireAngleMultiplier = 1
    self.speed = 1400

	self.hue = 200
	self.saturation = 100
	self.lightness = 60

    self.touchDamage = 150
    self.health = 2500
    self.maxHealth = 2500
    self.invincible = false
    self.knockbackResistance = 1
    self.phase = 1

    self.lineWidth = 1

    self.maxRadius = 40

    self.bulletFragments = 12

    self.spawnTween = tween(2.5, self, {radius = self.maxRadius}, "inOutCubic", function() self.spawnTween = nil end)

    self.state = 'move'
end

function Tanker:update(dt)
    Enemy.update(self, dt)

    self.invincible = (self.spawnTween ~= nil)


    local toPlayer = (player.position - self.position)
    if toPlayer:len() >= 600 then
        self.state = 'move'
    elseif toPlayer:len() <= 550 then
        self.state = 'shoot'
    end

    if self.state == 'move' then
        self.acceleration = toPlayer:normalized() * self.speed
    elseif self.state == 'shoot' then
        self.acceleration = vector(0, 0)

        if self.heat <= 0 and self.spawnTween == nil then
            game:addBullet(Bullet:new(
                self.position,
                player.position
            ):setLife(toPlayer:len()/600):setSource(self):setDamage(40):setSpeed(600):setRadius(40):setDeathAction(function(position, source)

                local deltaAngle = 360/source.bulletFragments
                for i = 1, source.bulletFragments do
                    local angle = math.rad(deltaAngle * i)
                    game:addBullet(Bullet:new(
                        position,
                        position + vector(math.cos(angle), math.sin(angle))
                    ):setLife(1):setSource(source):setDamage(10):setSpeed(300):setRadius(20):setDeathAction(function(position, source)

                        local deltaAngle = 360/source.bulletFragments
                        for i = 1, source.bulletFragments do
                            local angle = math.rad(deltaAngle * i)
                            game:addBullet(Bullet:new(
                                position,
                                position + vector(math.cos(angle), math.sin(angle))
                            ):setLife(.5):setSource(source):setDamage(5):setSpeed(150):setRadius(10))
                        end
                    end))
                end
            end)
            )


            self.heat = self.rateOfFire
        end
    end

    if self.heat > 0 then
        self.heat = self.heat - dt
    end
end

function Tanker:handleCollision(obj)

end

function Tanker:draw()
    Enemy.draw(self)
end
