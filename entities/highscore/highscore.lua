HighScore = class('HighScore')

function HighScore:initialize()
	self.destroyScores = {
		blob = 2,
		tank = 10,
		healer = 5,
		ninja = 8,
		megabyte = 200,
		default = 1
	}
	
	self.accuracyScore = 50 -- get this many points with 100% accuracy in a wave
	
	self.enemyDeathObserver = signal.register('enemyDeath', function(enemy) self:onEnemyDeath(enemy) end)
	self.enemyHitObserver = signal.register('enemyHit', function(enemy) self:onEnemyHit(enemy) end)
    self.playerShootObserver = signal.register('playerShot', function() self:onPlayerShoot() end)
	self.waveEndObserver = signal.register('waveEnded', function() self:onWaveEnd() end)
	signal.register('newGame', function() self:reset() end)
	
	self:reset()
end

function HighScore:reset()
	-- no need to change these
	self.currentScore = 0
	self.bulletsShot = 0
	self.bulletsHit = 0

	-- The score displayed to the screen, may or may not be equal to the current score.
	-- It does approach the current score, though.
	self.displayScore = 0
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
	signal.emit('scoreChange', amount)
	self.currentScore = self.currentScore + amount
end

function HighScore:onEnemyDeath(enemy)
	-- add to score based on which enemy was defeated
	local scoreChange = self.destroyScores.default -- should only result if an enemy has not yet been given a score
	
	if enemy:isInstanceOf(Blob) then
		scoreChange = self.destroyScores.blob
	elseif enemy:isInstanceOf(Tank) then
		scoreChange = self.destroyScores.tank
	elseif enemy:isInstanceOf(Healer) then
		scoreChange = self.destroyScores.healer
	elseif enemy:isInstanceOf(Ninja) then
		scoreChange = self.destroyScores.ninja
	elseif enemy:isInstanceOf(Megabyte) then
		scoreChange = self.destroyScores.megabyte
	end
	
	self:changeScore(scoreChange)
end

function HighScore:onEnemyHit(enemy)
	if not enemy.isInstanceOf(Player) then
		self.bulletsHit = self.bulletsHit + 1
	end
end

function HighScore:onPlayerShoot()
	self.bulletsShot = self.bulletsShot + 1
end

function HighScore:onWaveEnd()
	-- calculate accuracy for the current wave, add to player score
	local accuracy = 0
	if self.bulletsShot ~= 0 then
		accuracy = self.bulletsHit / self.bulletsShot
	end
	
	local scoreChange = math.ceil(accuracy * self.accuracyScore)
	self:changeScore(scoreChange)
	
	if self.bulletsShot ~= 0 then
		--error(self.bulletsShot.." "..self.bulletsHit.." "..accuracy.." "..scoreChange.." "..self.currentScore)
	end
	
	-- reset the accuracy values
	self.bulletsShot = 0
	self.bulletsHit = 0
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

