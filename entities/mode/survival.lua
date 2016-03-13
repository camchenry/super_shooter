Survival = class("Survival", Gamemode)

function Survival:initialize()
	signal.register('newGame', self.setupWaves)
end

function Survival:reset()
	game.firstWave = false
	game.startingWave = 0
	game.wave = game.startingWave
	game.timeToNextWave = 3
	game.waveTime = 0
    game.waveStartTime = 0
    game._postWaveCalled = false
    game._preWaveCalled = false
    game.boss = nil
    game.waveTimer = nil
end

function Survival:update(dt)
	if game.waveTimer then
		game.prevT = game.waveTimer.running

		if math.floor(game.prevT) ~= math.floor(game.prevT+dt) then
			signal.emit('waveCountdown')
		end

		game.waveTimer:update(dt)
	end

	if game.boss then
		if game.boss.health <= 0 then
			game.boss = nil
		end
	end

	if #objects == 1 and game.waves[game.wave+1] == nil and not (player.health <= 0) then
		state.switch(gameover)
        signal.emit('survivalVictory')
	end

	if #objects == 1 and not game.waveTimer and game.boss == nil then
		if not game._postWaveCalled then
			self:onWaveEnd()
		end
	end
end

function Survival:onWaveStart()
    if game._preWaveCalled then return end

    signal.emit('waveStart')

    game.firstWave = false

    self:startWave()
    game.waveTimer = nil

    if game.boss ~= nil then
        signal.emit('bossSpawn')
    end

    game._postWaveCalled = false
    game._preWaveCalled = true
end

function Survival:onWaveEnd()
    if game._postWaveCalled then return end

    signal.emit('waveEnded', game.wave, game.time - game.waveStartTime)

    player.health = player.health + player.health * 0.1 + 1

	if game.waves[game.wave+1] ~= nil then
		if game.waves[game.wave+1].boss ~= nil then
			signal.emit('bossIncoming')
		end
	end

    game.waveTimer = cron.after(game.timeToNextWave, function()
			if not game._preWaveCalled then
				self:onWaveStart()
			end
		end)

    game._postWaveCalled = true
    game._preWaveCalled = false
end

function Survival:setupWaves()
    game.waves = {}
    game.waves[1] = {
        blobs = 25,
        sweepers = 0,
		healers = 0,
		tanks = 0,
    }
    game.waves[2] = {
        blobs = 0, -- 25,
        sweepers = 10,
		tanks = 0, -- 1,
        ninjas = 0,
    }
    game.waves[3] = {
        blobs = 18,
        sweepers = 3,
    }
    game.waves[4] = {
        blobs = 25,
        sweepers = 0,
        healers = 2,
    }
    game.waves[5] = {
        blobs = 25,
        tanks = 3,
        healers = 2,
    }
    game.waves[6] = {
        blobs = 35,
		sweepers = 6,
    }
    game.waves[7] = {
        tanks = 5,
        healers = 3,
    }
    game.waves[8] = {
        blobs = 30,
        healers = 3,
        tanks = 4,
    }
    game.waves[9] = {
        blobs = 25,
        healers = 3,
        tanks = 3,
        sweepers = 8,
    }
    game.waves[10] = {
        boss = Megabyte,
    }
end

function Survival:startWave()
	game.waveTimer = nil
	game.waveStartTime = game.time -- set the wave start time to the game time

	if game.wave == nil then
		game.wave = game.startingWave
	elseif game.waves[game.wave+1] == nil then
		state.switch(gameover)
	else
		game.wave = game.wave + 1
	end

	self:setPrimaryText("WAVE "..game.wave)

	if game.waves[game.wave] ~= nil and game.wave ~= game.startingWave then
		self:spawnEnemies()
	end
end

function Survival:spawnEnemies()
	local wave = nil
    if w ~= nil then
        wave = w
    else
        wave = game.wave
    end
    local currentWave = game.waves[wave]

    if currentWave.blobs ~= nil then
        for i=1, currentWave.blobs do
            local p = vector(math.random(-game.worldSize.x/2, game.worldSize.x/2),
                             math.random(-game.worldSize.y/2, game.worldSize.y/2))
            p = p + (p - player.position):normalized()*150
            local b = Blob:new(p)
            game:add(b)
        end
    end

    if currentWave.sweepers ~= nil then
        -- number of line enemies to spawn
        local num = currentWave.sweepers
        -- margin from the sides of the screen
		local margin = 600

        self:spawnSweepers(num, margin)
    end

	if currentWave.healers ~= nil then
        for i=1, currentWave.healers do
            local p = vector(math.random(-game.worldSize.x/2, game.worldSize.x/2),
                             math.random(-game.worldSize.y/2, game.worldSize.y/2))
            p = p + (p - player.position):normalized()*250
            local b = Healer:new(p)
            game:add(b)
        end
    end

	if currentWave.tanks ~= nil then
        for i=1, currentWave.tanks do
            local p = vector(math.random(-game.worldSize.x/2, game.worldSize.x/2),
                             math.random(-game.worldSize.y/2, game.worldSize.y/2))
            p = p + (p - player.position):normalized()*150
            local b = Tank:new(p)
            game:add(b)
        end
    end

    if currentWave.ninjas ~= nil then
        for i=1, currentWave.ninjas do
            local p = vector(math.random(-game.worldSize.x/2, game.worldSize.x/2),
                             math.random(-game.worldSize.y/2, game.worldSize.y/2))
            p = p + (p - player.position):normalized()*150
            local b = Ninja:new(p)
            game:add(b)
        end
    end

    if currentWave.boss ~= nil then
        local b = currentWave.boss:new()
        game.boss = game:add(b)
    end
end

-- spawns sets of sweepers
function Survival:spawnSweepers(count, margin)
    local minimumCount = math.min(2, count) -- minimum count will be 2, unless count is only 1
    local circleCount = math.random(minimumCount, count/3) -- pick a random number of sweepers
    if count - circleCount == 1 then -- ensure that after this, there won't be only one more sweeper to allocate. if there is, then add one more to this set instead
        circleCount = circleCount + 1
    end

    local position = vector(math.random(-game.worldSize.x/2 + margin, game.worldSize.x/2 - margin),
                                    math.random(-game.worldSize.y/2 + margin, game.worldSize.y/2 - margin))
    local radius = math.random(200, 700)

    for i = 1, circleCount do
        radius = radius*.9 -- makes the circles for each sweeper get a bit smaller
        local percent = i / (circleCount) -- used for circular movement

        game:add(Sweeper:new(
            position,
            percent,
            num,
            radius
        ))
    end

    local newMargin = margin * 1.2 -- increase the margin with each iteration, so that it tends towards the center more
    local newCount = count - circleCount
    if newCount > 0 then
        self:spawnSweepers(count - circleCount, newMargin)
    end
end

function Survival:draw()
	if game.waveText ~= nil and game.wave > 0 then
		self:drawPrimaryText()
	end

	if game.boss ~= nil then
		self:drawBossHealthBar()
	end

	self:drawPlayerHealthBar()
	self:drawBossIncoming()
end

function Survival:drawBossIncoming()
    love.graphics.setFont(font[48])
    if game.waveTimer ~= nil and game.waveTimer.time - game.waveTimer.running <= 3 and #objects == 1 then
    	local t = game.waveTimer.time - game.waveTimer.running
        love.graphics.print(math.ceil(t), love.graphics.getWidth()/2 - love.graphics.getFont():getWidth(math.ceil(t))/2, 150)

        if game.waves[game.wave+1] ~= nil then
            if game.waves[game.wave+1].boss ~= nil then
            	love.graphics.print("BOSS INCOMING", love.graphics.getWidth()/2 - love.graphics.getFont():getWidth("BOSS INCOMING")/2, 100)
            end
        end

    end
end

function Survival:drawPlayerHealthBar()
    if state.current() ~= game then return end

    local height = 10
    local multiplier = player.health / player.maxHealth
    local width = love.graphics.getWidth() * multiplier

    love.graphics.setColor(204, 15, 10, 255)
    love.graphics.rectangle("fill", love.graphics.getWidth()/2 - width/2, love.graphics.getHeight()-height, width/2, height)
    love.graphics.rectangle("fill", love.graphics.getWidth()/2, love.graphics.getHeight()-height, width/2, height)
    love.graphics.setColor(255, 255, 255)
end

function Survival:drawBossHealthBar()
    love.graphics.setColor(255, 255, 255)
    local multiplier = game.boss.health/game.boss.maxHealth
    love.graphics.rectangle("fill", 50, 50, (love.graphics.getWidth()-100)*multiplier, 25)

    local text = string.upper(game.boss.name)
    love.graphics.setFont(fontLight[24])
    love.graphics.print(text, math.floor(love.graphics.getWidth()/2-love.graphics.getFont():getWidth(text)/2), 10)
end

function Survival:setPrimaryText(text)
    game.waveText = text
    game.waveTextTime = 3
end

function Survival:drawPrimaryText()
    if game.waveTextTime <= 0 or game.firstWave then return end
    game.waveTextTime = game.waveTextTime - love.timer.getDelta()

    love.graphics.setLineWidth(1)
    love.graphics.setFont(font[48])
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.print(game.waveText, love.graphics.getWidth()/2 - love.graphics.getFont():getWidth(game.waveText)/2, 100)
end
