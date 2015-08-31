Enemy = class('Enemy', Entity)

function Enemy:initialize(position)
    Entity.initialize(self, position)
    self.originalColor = {231, 76, 60, 255}
    self.radius = 15
    self.sides = 4

    self.position = position
    self.x, self.y = self.position:unpack()
    self.touchDamage = player.maxHealth/5

    self.health = 100
    self.maxHealth = 100
end

function Enemy:update(dt)
    self.moveAway = vector(0, 0)
    self.moveTowardsPlayer = (player.position - self.position):normalized()

    -- enemy fades away as it loses health
    self.color = self.originalColor
    self.color[4] = math.max(32, 255*(self.health/self.maxHealth))

    if self.health <= 0 then
        self.destroy = true
        signal.emit('enemyDeath', self)
    elseif self.health > self.maxHealth then
        self.health = self.maxHealth
    end

    self:physicsUpdate(dt)

    self:checkCollision(self._handleCollision)
end

-- this is a private collision function specifically for common enemy effects that aren't supposed
-- to be overridden
function Enemy:_handleCollision(obj)
    if obj:isInstanceOf(Enemy) then
        if self.position:dist(obj.position) < self.radius + obj.radius then
            v = vector(self.x - obj.x, self.y - obj.y)
            self.moveAway = self.moveAway + v:normalized()
        end
    end

    if obj:isInstanceOf(Bullet) then
        if self.position:dist(obj.position) < self.radius + obj.radius then
            self.health = self.health - obj.damage
            signal.emit('enemyHit', self)
            game:removeBullet(obj)
            self.color = {255, 255, 255, 255}
        end
    end
end

Blob = class('Blob', Enemy)

function Blob:initialize(position)
    Enemy.initialize(self, position)
    self.originalColor = {231, 76, 60, 255}
    self.radius = 15
    self.sides = 4

    self.position = position
    self.touchDamage = player.maxHealth/5

    self.health = 100
    self.maxHealth = 100
	
	local maxVariance = 45 -- max degrees of variance, effects the angle the entity travels towards the player
	local minSpeed = 1500
	local maxSpeed = 4000
	self.variance = math.rad(math.random(-maxVariance, maxVariance))
	local varPerc = math.abs(self.variance) / maxVariance
	self.speed = (maxSpeed-minSpeed) * varPerc + minSpeed 
	-- lowest for variance of 0, highest for max variance
	local scaleChance = math.random(1,2) -- some enemies will scale their variance angle based on distance, others will not
	self.scaleVariance = scaleChance == 1 and true or false
	
	self.speedBurstPercent = 0
	self.speedBurstGainRate = .01 -- percent gained per collision frame
	self.speedBurstLossRate = .05 -- percent lost when there is no collision frame
	self.speedBurstMax = 2000 -- extra speed that can be gained
	self.speedBurstKeepTime = 2 -- seconds that a speed burst will last after no collision with another enemy
	self.speedBurstTimer = 0
	self.collisionFrame = false
end

function Blob:update(dt)
	if self.collisionFrame then
		self:speedBurst(true)
		self.speedBurstTimer = self.speedBurstKeepTime * self.speedBurstPercent -- time to lose speed burst is based on percent | lower percent means less speed burst time
		self.collisionFrame = false
	elseif self.speedBurstPercent > 0 then
		self.speedBurstTimer = self.speedBurstTimer - dt
		if self.speedBurstTimer <= 0 then -- slowly lose speed burst
			self:speedBurst(false)
		end
	end

    Enemy.update(self, dt)
	local variance = self.variance
	if self.scaleVariance then
		variance = (player.position:dist2(self.position)/1600) / love.graphics.getWidth() * self.variance -- min variance of 0, max of self.variance based on distance -- scales accuracy based on distance
	end
	
    self.moveTowardsPlayer = (player.position - self.position):normalized():rotated(variance)

    self.acceleration = (self.moveTowardsPlayer + self.moveAway):normalized() * (self.speed + self.speedBurstMax*self.speedBurstPercent)
end

function Blob:handleCollision(obj)
	if obj:isInstanceOf(Enemy) then
		if self.position:dist(obj.position) < self.radius + obj.radius then
			self:speedBurst(true)
			self.collisionFrame = true
		end
	end
	
	if obj:isInstanceOf(Bullet) then
		local slowScale = 10
		self:speedBurst(false, slowScale)
	end
end

function Blob:speedBurst(gain, scale) -- input is a bool to gain or lose speed
	local scale = scale or 1
	local perc = self.speedBurstPercent
	local change = gain and self.speedBurstGainRate*scale or self.speedBurstLossRate*scale
	if gain then
		if perc < 1 then
			perc = perc + change
			if perc > 1 then perc = 1 end
		end
	else
		if perc >= 0 then
			perc = perc - change
			if perc < 0 then perc = 0 end
		end
	end
	
	self.speedBurstPercent = perc
end

LineEnemy = class('LineEnemy', Enemy)

function LineEnemy:initialize(start, finish)
    Enemy.initialize(self, start)
    self.originalColor = {241, 196, 0, 255}
    self.radius = 18
    self.sides = 3

    self.position = start
    self.start = start
    self.finish = finish
    self.target = finish
    self.speed = 3000

    self.touchDamage = player.maxHealth/2

    self.health = 50
    self.maxHealth = 50
end

function LineEnemy:update(dt)
    Enemy.update(self, dt)

    if self.position:dist(self.target) < 2 then
        if self.target == self.finish then
            self.target = self.start
        else
            self.target = self.finish
        end
    end

    self.acceleration = (self.target - self.position):normalized() * self.speed
end

function LineEnemy:handleCollision(obj)

end