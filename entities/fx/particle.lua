Particles = class('Particles')

function Particles:initialize()
	self.particleLimit = 256
	self.particleImage = love.graphics.newImage("img/particle.png")

	self.particleSystem = love.graphics.newParticleSystem(self.particleImage, self.particleLimit)
    self.particleSystem:setRadialAcceleration(500, 600)
    self.particleSystem:setParticleLifetime(1)
    self.particleSystem:setSpeed(150, 450)
    self.particleSystem:setSpread(2*math.pi)
    self.particleSystem:setSizeVariation(1)
    self.particleSystem:setColors(255, 0, 0, 255, 0, 0, 0, 0)

    self.enemyDeathObserver = signal.register('enemyDeath', function(enemy) self:onEnemyDeath(enemy) end)
    self.enemyHitObserver = signal.register('enemyHit', function(enemy) self:onEnemyHit(enemy) end)

end

function Particles:update(dt)
	self.particleSystem:update(dt)
end

function Particles:onEnemyDeath(enemy)
	if enemy:isInstanceOf(LineEnemy) then
		self.particleSystem:setPosition(enemy.position.x, enemy.position.y)
        self.particleSystem:setColors(255, 255, 0, 255, 0, 0, 0, 0)
        self.particleSystem:emit(50)
	elseif enemy:isInstanceOf(Blob) then
		self.particleSystem:setPosition(enemy.position.x, enemy.position.y)
        self.particleSystem:setColors(255, 0, 0, 255, 0, 0, 0, 0)
        self.particleSystem:emit(50)
	end
end

function Particles:onEnemyHit(enemy)
	if enemy:isInstanceOf(LineEnemy) then
		self.particleSystem:setColors(255, 255, 0, 255, 0, 0, 0, 0)
        self.particleSystem:setPosition(enemy.position.x, enemy.position.y)
        self.particleSystem:emit(10)
	elseif enemy:isInstanceOf(Blob) then
		self.particleSystem:setColors(255, 0, 0, 255, 0, 0, 0, 0)
	    self.particleSystem:setPosition(enemy.position.x, enemy.position.y)
	    self.particleSystem:emit(10)
	end
end

function Particles:draw()
	love.graphics.draw(self.particleSystem)
end