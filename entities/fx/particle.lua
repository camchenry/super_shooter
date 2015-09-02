Particles = class('Particles')

function Particles:initialize()
	self.particleLimit = 256
	self.particleImage = love.graphics.newImage("img/particle.png")

	self.particleSystem = love.graphics.newParticleSystem(self.particleImage, self.particleLimit)
    self.particleSystem:setRadialAcceleration(500, 600)
    self.particleSystem:setParticleLifetime(1)
    self.particleSystem:setSpread(2*math.pi)
    self.particleSystem:setSizeVariation(0.5)
    self.particleSystem:setColors(255, 0, 0, 255, 0, 0, 0, 0)

    self.enemyDeathObserver = signal.register('enemyDeath', function(enemy) self:onEnemyDeath(enemy) end)
    self.enemyHitObserver = signal.register('enemyHit', function(enemy) self:onEnemyHit(enemy) end)

end

function Particles:update(dt)
	self.particleSystem:update(dt)

	self.particleSystem:setSpeed(250)
end

function Particles:onEnemyDeath(enemy)
	if enemy:isInstanceOf(LineEnemy) then
        self.particleSystem:setColors(255, 255, 0, 255, 0, 0, 0, 0)
	elseif enemy:isInstanceOf(Blob) then
        self.particleSystem:setColors(255, 0, 0, 255, 0, 0, 0, 0)
	end

	self.particleSystem:setSpeed(300, 550)
	self.particleSystem:setSizes(2, 1)
	self.particleSystem:setPosition(enemy.position.x, enemy.position.y)
	self.particleSystem:emit(35)
end

function Particles:onEnemyHit(enemy)
	if enemy:isInstanceOf(LineEnemy) then
        self.particleSystem:setColors(255, 255, 0, 255, 0, 0, 0, 0)
	elseif enemy:isInstanceOf(Blob) then
        self.particleSystem:setColors(255, 0, 0, 255, 0, 0, 0, 0)
	end

	self.particleSystem:setSpeed(50, 250)
	self.particleSystem:setPosition(enemy.position.x, enemy.position.y)
	self.particleSystem:emit(5)
end

function Particles:draw()
	love.graphics.draw(self.particleSystem)
end