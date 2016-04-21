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

    self.healingParticleSystem = self.particleSmallSystem:clone()
    self.bulletParticleSystem = self.particleSystem:clone()

    signal.register('enemyDeath', function(enemy) self:onEnemyDeath(enemy) end)
    signal.register('enemyHit', function(enemy) self:onEnemyHit(enemy) end)
    signal.register('healing', function(enemy, healer) self:onHealing(enemy, healer) end)
	signal.register('playerShot', function(player, bullet) self:onPlayerShoot(player, bullet) end)
    signal.register('newGame', function()
		self.particleSystem:reset()
		self.particleSmallSystem:reset()
	end)
end

function Particles:update(dt)
	self.particleSystem:update(dt)
	self.particleSmallSystem:update(dt)
	self.healingParticleSystem:update(dt)
	self.bulletParticleSystem:update(dt)

	self.particleSystem:setSpeed(250)
	self.particleSmallSystem:setSpeed(250)
end

function Particles:onEnemyDeath(enemy)
	for i, system in pairs({self.particleSystem, self.particleSmallSystem}) do
		system:setColors(enemy.color[1], enemy.color[2], enemy.color[3], 128, 0, 0, 0, 0)

		system:setSpeed(300, 550)
		system:setPosition(enemy.position.x, enemy.position.y)
		system:setSizes(2, 1)
		system:emit(15)
	end
end

function Particles:onEnemyHit(enemy)
	for i, system in pairs({self.particleSystem, self.particleSmallSystem}) do
		system:setColors(enemy.color[1], enemy.color[2], enemy.color[3], 128, 0, 0, 0, 0)

		system:setSpeed(50, 250)
		system:setPosition(enemy.position.x, enemy.position.y)
		system:emit(5)
	end
end

function Particles:onHealing(enemy, healer)
	for i, system in pairs({self.healingParticleSystem}) do
		system:setColors(healer.color[1], healer.color[2], healer.color[3], 150, 0, 0, 0, 0)

		system:setSpeed(10, 50)
		system:setPosition(enemy.position.x, enemy.position.y)
		system:emit(1)
	end
end

function Particles:onPlayerShoot(player, bullet)
	for i, system in pairs({self.bulletParticleSystem}) do
		system:setColors(255, 255, 255, 150, 0, 0, 0, 0)

		system:setSpeed(bullet.speed/4)
		system:setPosition(player.position.x, player.position.y)
		system:setLinearAcceleration(bullet.velocity.x, bullet.velocity.y, bullet.velocity.x, bullet.velocity.y)
		system:setDirection(math.atan2(bullet.target.y - bullet.position.y, bullet.target.x - bullet.position.x))
		system:setSpread(math.pi/2)
		system:setParticleLifetime(.2)
		system:emit(30)
	end
end

function Particles:draw()
    love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.particleSystem)
	love.graphics.draw(self.particleSmallSystem)
	love.graphics.draw(self.healingParticleSystem)
	love.graphics.draw(self.bulletParticleSystem)
end
