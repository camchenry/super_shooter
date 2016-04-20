HighScore = class('HighScore')

function HighScore:initialize()
	self.destroyScores = {
		[Blob] = 5,
		[Tank] = 25,
		[Healer] = 10,
		[Ninja] = 40,
		[Megabyte] = 500,
		[Sweeper] = 15 --sweeper
	}
	
	self.accuracyScore = 100 -- get this many points with 100% accuracy in a wave
	self.ricochetBonus = 100 -- get this bonus if _ enemies are killed in one wave, as the result of tank ricochet shots
	self.ricochetMinimum = 7 -- kill this many enemies with tank ricochet shots in one wave, to score the bonus
	self.timeScore = 500 -- you would get this many points by completing wave 1 in 1 second. formula: timeScore * wave / seconds
	
	self.scoreMultiplier = 1 -- this is multiplied to every score, good for bonuses
	self.perfectAccuracyMultipler = 2 -- this is multiplied to the accuracy bonus if there is 100% accuracy in a wave
	
	self.enemyDeathObserver = signal.register('enemyDeath', function(enemy) self:onEnemyDeath(enemy) end)
	self.enemyHitObserver = signal.register('enemyHit', function(enemy, damage, critical, source, death) self:onEnemyHit(enemy, damage, critical, source, death) end)
    self.playerShootObserver = signal.register('playerShot', function() self:onPlayerShoot() end)
	self.waveEndObserver = signal.register('waveEnded', function(wave, waveTime) self:onWaveEnd(wave, waveTime) end)
	signal.register('newGame', function() self:reset() end)
	
	self:reset()

	self.defaultFontSize = 64
	self.fontSize = self.defaultFontSize
	self.fontSizeModifier = 3
	self.maxFontSize = 120
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

	if diff ~= 0 then
		self.fontSize = math.min(self.defaultFontSize + self.fontSizeModifier * diff, self.maxFontSize)
		--self.fontSizeTween = tween(.5, self, {fontSize = 80}, "inOutCubic", function()
        --    self.fontSizeTween2 = tween(.5, self, {fontSize = self.defaultFontSize}, "inOutCubic", function()
       	--	end)
       		--self.fontSize = self.defaultFontSize
        --end)
    else
    	self.fontSize = self.defaultFontSize
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
		-- calculate accuracy for the current wave, add to player score
		local accuracy = 0
		if self.bulletsShot ~= 0 then
			accuracy = self.bulletsHit / self.bulletsShot
		end

		local accuracyPoints = math.ceil(accuracy * self.accuracyScore)
		if accuracy == 1 then -- perfect accuracy!
			accuracyPoints = accuracyPoints * self.perfectAccuracyMultipler
		end
		self:changeScore(accuracyPoints)
		
		-- add in the time bonus
		if waveTime > 0 then -- avoid dividing by 0
			local timePoints = math.ceil(self.timeScore * wave / waveTime)
			timePoints = timePoints * game.wave -- higher wave gives a higher time score
			self:changeScore(timePoints)
		end
		
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

	local font = font[self.fontSize]
	local text = math.floor(self.displayScore)
	love.graphics.setFont(font)
	local w = font:getWidth(text)
	local h = font:getHeight(text)
	love.graphics.print(text, love.graphics.getWidth() - w - 15, love.graphics.getHeight() - h - 15)
end

