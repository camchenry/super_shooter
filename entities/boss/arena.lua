Arena = class('Arena', Enemy)

function Arena:initialize(position)
    self.name = "Arena"
    self.color = {231, 76, 60, 255}
    self.radius = 0
    self.sides = 4

    self.position = vector(0, 0)
    self.velocity = vector(0, 0)
    self.dragFactor = 0.15
    self.heat = 0
    self.rateOfFire = (1/2) -- 4 shots per second
    self.fireAngle = 0
    self.fireAngleMultiplier = 1
	self.speed = 50

    self.touchDamage = 150
    self.health = 5000
    self.maxHealth = self.health
    self.invincible = false
    self.phase = 1
	self.time = 0

    self.lineWidth = 3

    self.spawnTween = tween(1, self, {radius = 20}, "inOutCubic", function() 
		self.spawnTimer = cron.after(2, function()
			self:spawnMinions(2, 1)
		end)
		
		for i = 1, 12 do
			game:addBullet(Bullet:new(
				self.position,
				vector(math.cos(i*math.pi/6 + math.pi/12)*250, math.sin(i*math.pi/6 + math.pi/12)*250) + WINDOW_OFFSET
			):setLife(5):setSource(self):setDamage(15))
		end
	end)

	for i = 1, 12 do
		game:addBullet(Bullet:new(
			self.position,
			vector(math.cos(i*math.pi/6)*250, math.sin(i*math.pi/6)*250) + WINDOW_OFFSET
		):setLife(5):setSource(self):setDamage(15))
	end

    self.width = self.radius * 2
    self.height = self.radius * 2
    self.x, self.y = self.position:unpack()
    self.prev_x, self.prev_y = self.position:unpack()

    self.minions = {}
end

function Arena:spawnMinions(entities, phase)
     local numMinions = entities or 2
    local d = 2*math.pi/numMinions

    for i=1, numMinions do
        local m = game:addObject(ArenaEnemy:new(0, d*i, math.rad(15), phase, self))
        table.insert(self.minions, m)
    end
end

function Arena:update(dt)
	self.time = self.time + dt
    self.width, self.height = self.radius*2, self.radius*2

    if self.spawnTimer  then
        self.spawnTimer:update(dt)
    end

    if self.health <= 0 then
        game:removeObject(self)
    elseif self.health > self.maxHealth then
        self.health = self.maxHealth
    end

    for i=#self.minions, 1, -1 do
        if self.minions[i].health <= 0 then
            table.remove(self.minions, i)
        end
    end

    self.prev_x, self.prev_y = self.position:unpack()
	
	if self.phase == 1 then
	
		-- the collision code is only relevant in phase 1
		local collidableObjects = quadtree:getCollidableObjects(self, true)
		for i, obj in pairs(collidableObjects) do
			if obj:isInstanceOf(Bullet) then
				if obj.source ~= self and not obj.source:isInstanceOf(Enemy) then
					if self.position:dist(obj.position) < self.radius + obj.radius then
						if not self.invincible then
							self.health = self.health - obj.damage
						end
						game:removeBullet(obj)
					end
				end
			end
		end
		
		if self.health <= self.maxHealth/2  then -- move into phase 2
			if not self.invincible then
				self.touchDamage = 0
				self.invincible = true
				self.color = {231, 76, 60, 0} -- center becomes invisible
				
				for i=#self.minions, 1, -1 do
					local minion = self.minions[i]
					minion.deathTween = tween(3, minion, {radius = 0, offset = 0}, "inOutCubic", function()
						self.deathTween = nil
						minion.health = 0
						minion.touchDamage = 0
						self:spawnMinions(3, 2) 
						self.phase = 2
					end)
				end
			end
		end
		
		self.velocity = vector(0, 0)
	
	-- in phase 2 the minions rotate around the player
	elseif self.phase == 2 then
		self.velocity = (player.position - self.position):normalized() * self.speed
		
		--set boss health to show average percent health of minions ( divided by two )
		local avgHealth = 0
		for k, minion in pairs(self.minions) do
			avgHealth = avgHealth + minion.health/minion.maxHealth
		end
		avgHealth = avgHealth / 3 -- assumes there are 3 minions in phase 2
		self.health = self.maxHealth * (avgHealth / 4)
	end

    self.position = self.position + self.velocity * dt
    self.x, self.y = self.position:unpack()
end


ArenaEnemy = class('ArenaEnemy', Enemy)

function ArenaEnemy:initialize(offset, angle, angleIncrease, phase, boss)
    Enemy.initialize(self, vector(0, 0))
    self.originalColor = {52, 152, 219}
    self.radius = 0
    self.sides = 6
	
	self.phase = phase

    self.health = 400
    self.maxHealth = self.health
    self.touchDamage = player.maxHealth/8
	
	if self.phase == 1 then
		self.invincible = true
		self.rateOfFire = 1/2 -- 4 shots per second
	else
		self.invincible = false
		self.rateOfFire = 2
	end

    self.offset = offset
    self.angle = angle
    self.angleIncrease = angleIncrease
    self.boss = boss
	self.offsetSpeed = 50
	self.fireAngle = angle
	
	self.heat = 0
	self.t = 0
	
	self.spawnTween = tween(3, self, {radius = 40, offset = 200}, "inOutCubic", function() self.spawnTween = nil boss.spawnTween = nil  end)
end

function ArenaEnemy:update(dt)
    Enemy.update(self, dt)
	
	if self.health <= 0 then
        self.destroy = true
        self.color = self.originalColor
        signal.emit('enemyDeath', self)
    elseif self.health > self.maxHealth then
        self.health = self.maxHealth
    end
	
	-- movement
	
	-- consider reversing self.t at some point
	self.t = self.t + dt
	self.angleIncrease = self.angleIncrease + math.sin(self.t*5)/10 --- this one creates a "slamming effect"
	--(math.sin(dt) % .5) / 30
	
    self.angle = self.angle + self.angleIncrease * dt
    self.position = vector(self.boss.x + math.cos(self.angle)*(self.boss.radius+self.offset),
                           self.boss.y + math.sin(self.angle)*(self.boss.radius+self.offset))
						   
	

	-- \left(\cos \left(2x\right)+1\right)^{\left(1.1+\sin \left(x\right)\right)}\cdot \cos \left(.3x\right)
	
	--(math.cos(self.t)/(math.sin(self.t)+1.1)) *math.sqrt(dt)/10 
	-- {\cos x}{\sin x+1.1}
	
	
	
	if self.phase == 1 then
		self.offset =  40 + 300 * (math.sin(self.t/3)^3)
		
		self.fireAngle = self.angle
	
		-- fire 3 bullets - based on current angle
		if self.heat <= 0 then
			game:addBullet(Bullet:new(
				self.position,
				vector(math.cos(self.fireAngle+math.pi/4)*250, math.sin(self.fireAngle+math.pi/4)*250) + WINDOW_OFFSET
			):setLife(5):setSource(self):setDamage(15))
			
			game:addBullet(Bullet:new(
				self.position,
				vector(math.cos(self.fireAngle-math.pi/4)*250, math.sin(self.fireAngle-math.pi/4)*250) + WINDOW_OFFSET
			):setLife(5):setSource(self):setDamage(15))
			
			game:addBullet(Bullet:new(
				self.position,
				vector(math.cos(self.fireAngle+math.pi/2)*250, math.sin(self.fireAngle+math.pi/2)*250) + WINDOW_OFFSET
			):setLife(5):setSource(self):setDamage(15))
			
			self.heat = self.rateOfFire
		end
		
	elseif self.phase == 2 then
		-- this puts the enemies at the same radius from the center as the player (near impossible to avoid)
		local playerDist = (player.position - self.boss.position):len() -- dist from boss center to player
		if self.offset > playerDist then
			self.offset = self.offset - self.offsetSpeed*dt
		elseif self.offset < playerDist then
			self.offset = self.offset + self.offsetSpeed*dt
		end
		
		--self.fireAngle = 
	
		-- fire 3 bullets - based on current angle
		if self.heat <= 0 then
			game:addBullet(Bullet:new(
				self.position,
				player.position + WINDOW_OFFSET
			):setLife(5):setSource(self):setDamage(5))
			
			self.heat = self.rateOfFire
		end
	end
	
	

	if self.heat > 0 then
		self.heat = self.heat - dt
	end
end

function ArenaEnemy:keypressed(key, isrepeat)

end

-- this does not work?
function ArenaEnemy:handleCollision(obj)
	if obj == obj:isInstanceOf(Bullet) then
		game:removeBullet(obj)
	end
end
