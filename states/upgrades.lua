upgrades = {}
upgrades.elements = {}
function upgrades:add(e)
	table.insert(self.elements, e)
	return e
end

-- powers are just straight upgrades
upgrades.powers = {
	[1] = {
		description = "+30 health",
		effect = function(entity)
			entity.maxHealth = entity.maxHealth + 30
			entity.health = entity.health + 30
		end,
	},
}

-- gambits have an upside and a downside
upgrades.gambits = {
	[1] = {
		description = "+30% damage, -50% health",
		effect = function(entity)
			entity.damageMultiplier = entity.damageMultiplier + 0.30
			entity.maxHealth = entity.maxHealth * 0.5
			--entity.health = entity.health * 0.5
		end,
	},
	[2] = {
		description = "+100% rate of fire, -30% move speed",
		effect = function(entity)
			entity.rateOfFire = entity.rateOfFire * 0.5
			entity.speed = entity.speed * 0.7
		end,
	},
	[3] = {
		description = "+30% move speed, -20% damage",
		effect = function(entity)
			entity.damageMultiplier = entity.damageMultiplier - 0.2
			entity.speed = entity.speed * 1.3
		end,
	},
	[4] = {
		description = "+2 health regen, -30 health",
		effect = function(entity)
			entity.healthRegen = entity.healthRegen + 2
			entity.maxHealth = entity.maxHealth - 30
		end,
	},
}

function upgrades:enter()
	self.list = {}
	love.mouse.setCursor(cursor)

	shuffleTable(self.gambits)

	table.insert(self.list, self.gambits[1])
	table.insert(self.list, self.gambits[2])

	for i, upgrade in pairs(self.list) do
		local b = self:add(Button:new(
			upgrade.description,
			love.graphics.getWidth()/2 - 300,
			250+160*(i-1),
			600,
			150
		))
		b:setBG(127, 127, 127, 32)
		b.activated = function()
			upgrade.effect(player)
			state.pop()
		end
	end
end

function upgrades:leave()
	self.elements = {}
	love.mouse.setCursor(crosshair)
end

function upgrades:update(dt)
	for i, e in pairs(self.elements) do
		e:update(dt)
	end
end

function upgrades:keypressed(key)
	if key == "escape" then
		--state.pop()
	end

	for i, e in pairs(self.elements) do
		if e.keypressed then
			e:keypressed(key)
		end
	end
end

function upgrades:mousepressed(x, y, mbutton)
	for i, e in pairs(self.elements) do
		e:mousepressed(x, y, mbutton)
	end	
end

function upgrades:draw()
	game:draw()
	love.graphics.setColor(255, 255, 255)
	local text = "CHOOSE ONE UPGRADE"

	love.graphics.setFont(fontLight[48])
	love.graphics.printf(string.upper(text), 0, 150, love.graphics.getWidth(), "center")

	for i, e in pairs(self.elements) do
		e:draw()
	end
end