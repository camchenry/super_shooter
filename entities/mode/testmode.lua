Testmode = class("Testmode")

function Testmode:initialize()

end

function Testmode:reset()
	self.standardTime = 1.0
	self.slowTime = 0.5
	self.isSlowed = false
	TIME_MULTIPLIER = 1.0
end

function Testmode:update(dt)
	player.maxHealth = 10000
	player.health = 10000
end

function Testmode:draw()
	
end

function Testmode:keypressed(key)
	-- key commands to toggle debug options
	if key == 'f1' then DEBUG = not DEBUG end
	if key == 'f2' then DRAW_COLLISION_BODIES = not DRAW_COLLISION_BODIES end
	if key == 'f3' then DRAW_PHYSICS_VECTORS = not DRAW_PHYSICS_VECTORS end
	if key == 'f4' then DRAW_WORLD_BORDER = not DRAW_WORLD_BORDER end
	if key == 'f5' then TRACK_ENTITIES = not TRACK_ENTITIES end
	if key == 'f6' then
		self.isSlowed = not self.isSlowed
		if self.isSlowed then 
			TIME_MULTIPLIER = self.slowTime
		else
			TIME_MULTIPLIER = self.standardTime
		end
	end

	-- key commands to spawn enemies
	if key == '1' then self:spawn('blob') end
	if key == '2' then self:spawn('sweeper') end
	if key == '3' then self:spawn('healer') end
	if key == '4' then self:spawn('tank') end
	if key == '5' then self:spawn('ninja') end
	if key == '6' then self:spawn('megabyte') end
	if key == '7' then self:spawn('tanker') end
end

function Testmode:spawn(name)
	if name == 'blob' then
		local p = vector(math.random(-game.worldSize.x/2, game.worldSize.x/2),
                         math.random(-game.worldSize.y/2, game.worldSize.y/2))
        p = p + (p - player.position):normalized()*150
        local b = Blob:new(p)
        game:add(b)
	end

	if name == 'sweeper' then
		-- number of line enemies to spawn
        local num = math.random(1, 7)
        -- margin from the sides of the screen
		local margin = 600

        local position = vector(math.random(-game.worldSize.x/2 + margin, game.worldSize.x/2 - margin),
                                math.random(-game.worldSize.y/2 + margin, game.worldSize.y/2 - margin))
	    local radius = math.random(200, 700)

	    for i = 1, num do
	        radius = radius*.9 -- makes the circles for each sweeper get a bit smaller
	        local percent = i / (num) -- used for circular movement

	        game:add(Sweeper:new(
	            position,
	            percent,
	            num,
	            radius
	        ))
	    end
	end

	if name == 'healer' then
		local p = vector(math.random(-game.worldSize.x/2, game.worldSize.x/2),
                         math.random(-game.worldSize.y/2, game.worldSize.y/2))
        p = p + (p - player.position):normalized()*250
        local b = Healer:new(p)
        game:add(b)
    end

    if name == 'tank' then
    	local p = vector(math.random(-game.worldSize.x/2, game.worldSize.x/2),
                         math.random(-game.worldSize.y/2, game.worldSize.y/2))
        p = p + (p - player.position):normalized()*150
        local b = Tank:new(p)
        game:add(b)
    end

    if name == 'ninja' then
    	local p = vector(math.random(-game.worldSize.x/2, game.worldSize.x/2),
                         math.random(-game.worldSize.y/2, game.worldSize.y/2))
        p = p + (p - player.position):normalized()*150
        local b = Ninja:new(p)
        game:add(b)
    end

    if name == 'megabyte' then
    	local b = Megabyte:new()
        game.boss = game:add(b)
    end

    if name == 'tanker' then
    	local b = Tanker:new()
        game.boss = game:add(b)
    end
end