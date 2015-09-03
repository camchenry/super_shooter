ScreenShake = class('ScreenShake')

function ScreenShake:initialize()
    self.time = 0
    self.timeMax = 3
    self.strength = 0
    self.velocity = vector(0, 0)
    self.angle = 0

    self.enemyDeathObserver = signal.register('enemyDeath', function(enemy) self:onEnemyDeath(enemy) end)
    self.enemyHitObserver = signal.register('enemyHit', function(enemy) self:onEnemyHit(enemy) end)

end

function ScreenShake:update(dt)
	if self.time > 0 then
        self.time = math.min(self.timeMax, self.time - dt)
    end
end

function ScreenShake:onEnemyDeath(enemy)
	self:shake(1, 100)
end

function ScreenShake:onEnemyHit(enemy)
	self:shake(1, 30)

    game.ptime = MOUSE_VALUE
end

function ScreenShake:shake(time, strength)
	self.time = time

    if self.time > 0 then
        self.strength = self.strength + self.strength * 0.4
    else
        self.strength = strength or 50
    end

    self.angle = math.random(0, math.pi)
    self.velocity = vector(math.cos(self.angle), math.sin(self.angle))
end

function ScreenShake:getOffset()
	local dx, dy = 0, 0
    if self.time > 0 then
        local dampen = math.sqrt(self.time / self.timeMax)

        dx = self.velocity.x * dampen * math.cos(self.time * 20 * dampen)
        dy = self.velocity.y * dampen * math.sin(self.time * 20 * dampen)
    end

    return dx, dy
end