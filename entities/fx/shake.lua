ScreenShake = class('ScreenShake')

function ScreenShake:initialize()
    self.time = 0
    self.timeMax = 3
    self.strength = 0
    self.velocity = vector(0, 0)
    self.angle = 0

    self.enemyDeathObserver = signal.register('enemyDeath', function(enemy) self:onEnemyDeath(enemy) end)
    self.enemyHitObserver = signal.register('enemyHit', function(enemy) self:onEnemyHit(enemy) end)

    signal.register('newGame', function()
        self.time = 0
    end)
end

function ScreenShake:update(dt)
	if self.time > 0 then
        self.time = math.min(self.timeMax, self.time - dt)
    end
end

function ScreenShake:onEnemyDeath(enemy)
	self:shake(1, 90)
end

function ScreenShake:onEnemyHit(enemy)
	self:shake(1, 35)
end

function ScreenShake:shake(time, strength)
	self.time = time

    if strength > self.strength then
        self.strength = strength
    elseif time <= 0 then
        self.strength = strength
    end

    self.angle = math.random(0, math.pi)
    self.velocity = vector(math.cos(self.angle), math.sin(self.angle))
end

function ScreenShake:getOffset()
	local dx, dy = 0, 0
    if self.time > 0 then
        local dampen = math.sqrt(self.time / self.timeMax)

        dx = self.velocity.x * dampen * math.cos(self.time * self.strength * dampen)
        dy = self.velocity.y * dampen * math.sin(self.time * self.strength * dampen)
    end

    return dx, dy
end