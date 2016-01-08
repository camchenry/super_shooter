Particles = class('Particles')

function Particles:initialize()
	self.particleLimit = 256
	self.particleImage = love.graphics.newImage("img/particle.png")
	self.particleSmallImage = love.graphics.newImage("img/particleSmall.png")

	self.particleSystem = love.graphics.newParticleSystem(self.particleImage, self.particleLimit)
    self.particleSystem:setRadialAcceleration(500, 600)
    self.particleSystem:setParticleLifetime(1)
    self.particleSystem:setSpread(2*math.pi)
    self.particleSystem:setSizeVariation(0.5)
    self.particleSystem:setRelativeRotation(true)
    self.particleSystem:setColors(255, 0, 0, 255, 0, 0, 0, 0)

    self.particleSmallSystem = self.particleSystem:clone()
    self.particleSmallSystem:setTexture(self.particleSmallImage)

    self.enemyDeathObserver = signal.register('enemyDeath', function(enemy) self:onEnemyDeath(enemy) end)
    self.enemyHitObserver = signal.register('enemyHit', function(enemy) self:onEnemyHit(enemy) end)


    signal.register('newGame', function()
		self.particleSystem:reset()
		self.particleSmallSystem:reset()
	end)
end

function Particles:update(dt)
	self.particleSystem:update(dt)
	self.particleSmallSystem:update(dt)

	self.particleSystem:setSpeed(250)
	self.particleSmallSystem:setSpeed(250)
end

function Particles:onEnemyDeath(enemy)
	for i, system in pairs({self.particleSystem, self.particleSmallSystem}) do
		system:setColors(enemy.color[1], enemy.color[2], enemy.color[3], 255, 0, 0, 0, 0)

		system:setSpeed(300, 550)
		system:setPosition(enemy.position.x, enemy.position.y)
		system:setSizes(2, 1)
		system:emit(15)
	end
end

function Particles:onEnemyHit(enemy)
	for i, system in pairs({self.particleSystem, self.particleSmallSystem}) do
		system:setColors(enemy.color[1], enemy.color[2], enemy.color[3], 255, 0, 0, 0, 0)

		system:setSpeed(50, 250)
		system:setPosition(enemy.position.x, enemy.position.y)
		system:emit(5)
	end
end

function Particles:draw()
	love.graphics.draw(self.particleSystem)
	love.graphics.draw(self.particleSmallSystem)
end