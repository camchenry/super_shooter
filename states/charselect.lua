charSelect = {}
charSelect.elements = {}
function charSelect:add(e)
	table.insert(self.elements, e)
	return e
end

-- gambits have an upside and a downside
charSelect.characters = {
	[1] = {
		name = "Blaster",
		description = "Not great at anything, good at everything.",
		entity = function()
			Blaster = class('Blaster', Player)

			function Blaster:initialize()
				Player.initialize(self)
			end

			return Blaster
		end
	},

	[2] = {
		name = "Pathfinder",
		description = "Fragile, but able to kill enemies with ease.",
		entity = function()
			Pathfinder = class('Pathfinder', Player)

			function Pathfinder:initialize()
				Player.initialize(self)

				self.shotsPerSecond = 2
				self.speed = 1400
				self.maxHealth = 60
				self.health = 60
				self.bulletDamage = 110
				self.bulletVelocity = 425
				self.criticalChance = 0.00
                self.waveEndRegen = 10
				self.color = {127/255, 127/255, 127/255}
			end

			return Pathfinder
		end
	},

	[3] = {
		name = "Berserker",
		description = "Kills enemies, quickly, but only effective at close range.",
		entity = function()
			Berserker = class('Berserker', Player)

			function Berserker:initialize()
				Player.initialize(self)

				self.shotsPerSecond = 10
				self.bulletDamage = 30
                self.bulletVelocity = 275
				self.bulletDropoffDistance = 40
				self.bulletDropoffAmount = 27
				self.damageResistance = -0.25
				self.healthRegen = -1
				self.maxHealth = 175
				self.health = 175

				self.color = {1, 127/255, 127/255}

				signal.register('enemyDeath', function(enemy)
					self.health = self.health + 1

					if enemy:isInstanceOf(Tank) then
						self.health = self.health + 5
					end
				end)
			end

			return Berserker
		end
	},
}

function charSelect:init()

end

function charSelect:enter()
	self.list = {}
	self.elements = {}
	self.selectedCharacter = nil
	self.referencePlayer = self.characters[1].entity():new()
	love.mouse.setCursor(cursor)

	for i, character in pairs(self.characters) do
		local b = self:add(Button:new(
			string.upper(character.name),
			75,
			200+120*(i-1),
			350,
			100,
			font[36]
		))

		b:setBG(1, 1, 1, 32/255)
		b:setFG(0, 0, 0, 1)

		b.activated = function()
			for i, b in pairs(self.elements) do
				if b:isInstanceOf(Button) then b.selected = false end
			end
			b.selected = not b.selected
			self.selectedCharacter = character
			self.tempPlayer= character.entity():new()
			--state.pop()
		end

		b.update = function(dt)
			Button.update(b)

			if b.selected then
				b.bg = {255/255, 255/255, 255/255}
			else
				b.bg = {33/255, 33/255, 33/255, 255/255}
			end

			if b.selected then
				b.fg = {0, 0, 0}
				b.active = {0, 0, 0}
			else
				b.fg = {1, 1, 1, 1}
				b.active = {1, 1, 1, 1}
			end

			if b.selected then
				b.font = fontBold[36]
			else
				b.font = font[36]
			end

			if b.selected and b:hover() then
				b.bg = {1, 1, 1, 1}
			elseif not b.selected and b:hover() then
				b.bg = {55/255, 55/255, 55/255, 255/255}
			end
		end
	end

	self.continueButton = Button:new("CONTINUE")
	self.continueButton:setFont(fontBold[48])
	self.continueButton:centerAround(love.graphics.getWidth()/2, love.graphics.getHeight()-70)
	self.continueButton.activated = function()
		if self.selectedCharacter ~= nil then
			player = game:add(self.tempPlayer)
			state.pop()
		end
	end

	local bottomMargin = 60

	self.back = Button:new("< BACK", 75, love.graphics.getHeight() - bottomMargin)
	self.back.activated = function()
		state.switch(modeselect)
	end
end

function charSelect:leave()
	self.elements = {}
	love.mouse.setCursor(crosshair)
end

function charSelect:update(dt)
	for i, e in pairs(self.elements) do
		e:update(dt)
	end

	if self.selectedCharacter then
		self.continueButton:update(dt)
	end

	self.back:update(dt)
    game.background:update(dt)
end

function charSelect:keypressed(key)
	if key == "escape" then
		state.switch(modeselect)
	end

	for i, e in pairs(self.elements) do
		if e.keypressed then
			e:keypressed(key)
		end
	end
end

function charSelect:mousepressed(x, y, mbutton)
	for i, e in pairs(self.elements) do
		e:mousepressed(x, y, mbutton)
	end

	if self.selectedCharacter then
		self.continueButton:mousepressed(x, y, mbutton)
	end

	self.back:mousepressed(x, y, mbutton)
end

function charSelect:draw()
    game.background:draw()
	love.graphics.setColor(1, 1, 1)
	local text = "CHOOSE A CHARACTER"

	love.graphics.setFont(fontLight[48])
	love.graphics.printf(string.upper(text), 0, 75, love.graphics.getWidth(), "center")

	for i, e in pairs(self.elements) do
		e:draw()
	end

	love.graphics.setFont(font[28])
	if self.selectedCharacter then
		love.graphics.print(self.selectedCharacter.description, 475, 200)

		love.graphics.setFont(font[24])
		local i = 0
		for key, prop in pairs(self.tempPlayer) do
			local referenceValue = tonumber(self.referencePlayer[key])
			local playerValue = tonumber(self.tempPlayer[key])

			local excluded = (key == "bulletDropoffDistance") or (key == "bulletDropoffAmount")

			if referenceValue ~= playerValue and type(self.tempPlayer[key]) ~= 'table' and not excluded then
				local diff = referenceValue - playerValue
				local sign = ''
				if diff < 0 then
					sign = "+"
				else
					sign = '-'
				end
				diff = math.abs(diff)

				if referenceValue > playerValue then
					love.graphics.setColor(1, 200/255, 200/255)
				else
					love.graphics.setColor(200/255, 255/255, 200/255)
				end

				if key == "regenWaitAfterHurt" then
					love.graphics.setColor(255/255, 200/255, 200/255)
				end

				love.graphics.print(key .. " -> " .. playerValue .. ' (' .. sign .. diff .. ')', 475, 245+i*35)
				i = i + 1
			end
		end

		self.continueButton:draw()
	end

	self.back:draw()
end
