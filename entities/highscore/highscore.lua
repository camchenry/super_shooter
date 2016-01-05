HighScore = class('HighScore')

function HighScore:initialize()
	self.destroyScores = {
		[Blob] = 2,
		[Tank] = 10,
		[Healer] = 5,
		[Ninja] = 8,
		[Megabyte] = 200,
		[LineEnemy] = 1, --sweeper
	}
	
	self.accuracyScore = 50 -- get this many points with 100% accuracy in a wave
	self.ricochetBonus = 200 -- get this bonus if 5 enemies are killed in one wave, as the result of tank ricochet shots
	self.ricochetMinimum = 5 -- kill this many enemies with tank ricochet shots in one wave, to score the bonus
	self.timeScore = 1000 -- you would get this many points by completing wave 1 in 1 second. formula: timeScore * wave / seconds
	
	self.scoreMultiplier = 1 -- this is multiplied to every score, good for bonuses
	
	self.enemyDeathObserver = signal.register('enemyDeath', function(enemy) self:onEnemyDeath(enemy) end)
	self.enemyHitObserver = signal.register('enemyHit', function(enemy, damage, critical, source, death) self:onEnemyHit(enemy, damage, critical, source, death) end)
    self.playerShootObserver = signal.register('playerShot', function() self:onPlayerShoot() end)
	self.waveEndObserver = signal.register('waveEnded', function(wave, waveTime) self:onWaveEnd(wave, waveTime) end)
	signal.register('newGame', function() self:reset() end)
	
	self:reset()
end

function HighScore:reset()
	-- no need to change these
	self.currentScore = 0
	self:resetCounters()

	-- The score displayed to the screen, may or may not be equal to the current score.
	-- It does approach the current score, though.
	self.displayScore = 0
end

function HighScore:resetCounters()
	self.bulletsShot = 0
	self.bulletsHit = 0
	self.ricochetKills = 0
end

function HighScore:update(dt)
	-- interpolates the display score towards the current score
	local diff = self.currentScore - self.displayScore
	local epsilon = 1

	if diff > epsilon then
		self.displayScore = self.displayScore + (diff) * 5 * dt
	else
		self.displayScore = self.currentScore
	end

end

function HighScore:changeScore(amount)
	amount = amount * self.scoreMultiplier
	signal.emit('scoreChange', amount)
	self.currentScore = self.currentScore + amount
end

function HighScore:onEnemyDeath(enemy)
	-- add to score based on which enemy was defeated
	local scoreChange = self.destroyScores[enemy.class] or 1
	self:changeScore(scoreChange)
end

function HighScore:onEnemyHit(enemy, damage, critical, source, death)
	if not enemy.isInstanceOf(Player) then
		if source:isInstanceOf(Player) then
			self.bulletsHit = self.bulletsHit + 1
		elseif source:isInstanceOf(Tank) then
			self.ricochetKills = self.ricochetKills + 1
		end
	end
end

function HighScore:onPlayerShoot()
	self.bulletsShot = self.bulletsShot + 1
end

function HighScore:onWaveEnd(wave, waveTime)
	if wave and wave > 0 then
		local scoreChange = 0

		-- calculate accuracy for the current wave, add to player score
		local accuracy = 0
		if self.bulletsShot ~= 0 then
			accuracy = self.bulletsHit / self.bulletsShot
		end

		local accuracyPoints = math.ceil(accuracy * self.accuracyScore)
		self:changeScore(accuracyPoints)
		
		-- add in the time bonus
		local timePoints = math.ceil(self.timeScore * wave / waveTime)
		scoreChange = scoreChange + timePoints
		self:changeScore(timePoints)
		
		-- check for wave ricochet bonus
		if self.ricochetKills >= self.ricochetMinimum then
			self:changeScore(self.ricochetBonus)
		end
		
		self:resetCounters()
	end
end

function HighScore:draw()
	-- do not show outside the game state, unless the game is paused
	if (state.current() ~= game) and (state.current() ~= pause) then
		return 
	end

	local font = font[64]
	local text = math.floor(self.displayScore)
	love.graphics.setFont(font)
	local w = font:getWidth(text)
	local h = font:getHeight(text)
	love.graphics.print(text, love.graphics.getWidth() - w - 15, love.graphics.getHeight() - h - 15)
end

