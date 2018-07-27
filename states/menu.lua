menu = {}

menu.items = {
    {
        title = "NEW GAME",
        action = function()
            state.switch(modeselect)
        end,
    },

    {
        title = "HOW TO PLAY",
        action = function()
            state.push(info)
        end,
    },

	{
        title = "HIGH SCORES",
        action = function()
			state.push(highscoreList)
        end,
    },

    {
        title = "OPTIONS",
        action = function()
            state.push(options)
        end,
    },


    {
        title = "CREDITS",
        action = function()
			state.push(credits)
        end,
    },

    {
        title = "QUIT",
        action = function()
            love.event.quit()
        end,
    },
}

menu.buttons = {}

function menu:init()
	local buttonHeight = 50
	self.lineLengthOffset = 9

    for i, item in pairs(self.items) do
        table.insert(self.buttons, Button:new(item.title, 75, buttonHeight*(i-1) + 250, nil, buttonHeight, font[30], item.action))
    end

    self.title = 'SUPER SHOOTER'
    self.titleFont = fontBold[72]
    self.titleX = love.graphics.getWidth()/2 - self.titleFont:getWidth(self.title)/2
    self.titleTweenTime = 1.0
    self.titleTween = tween(self.titleTweenTime, self, {titleX = 75}, "inOutCubic")

	-- reveal the menu on game launch
    self.headerTweenTime = 1.4
	self.headerTweenAmount = love.graphics.getHeight() - (120+55)
	self.headerTween = tween(self.headerTweenTime, self, {headerTweenAmount = 0}, "inOutCubic", function() end)

    game.background = GridBackground:new()
end

function menu:enter()
    signal.emit('menuEntered')
    love.mouse.setCursor(cursor)

	self.time = 0

	love.graphics.setLineWidth(1)
	-- default value for the line
	self.lineX = self.buttons[1].x - 10
	self.lineY1 = self.buttons[1].y
	self.lineY2 = self.buttons[#self.buttons].y + self.buttons[#self.buttons].height
end

function menu:update(dt)
	self.time = self.time+dt

    game.background:update(dt)

    for i, button in pairs(self.buttons) do
        button:update(dt)
    end

	-- moving selector
	if not self.lineTween then
		local index1 = 1
		local index2 = #self.buttons
		for i, button in ipairs(self.buttons) do
			if button:hover() then
				index1 = i
				index2 = i
				break
			end
		end
		local y1 = self.buttons[index1].y
		local y2 = self.buttons[index2].y + self.buttons[index2].height

		self.lineTween = tween(.25, self, {lineY1 = y1, lineY2 = y2}, "inOutCirc", function() self.lineTween = false end)
	end
end

function menu:keyreleased(key, code)

end

function menu:mousepressed(x, y, mbutton)
    for i, button in pairs(self.buttons) do
        button:mousepressed(x, y, mbutton)
    end
end

function menu:draw()
    love.graphics.setColor(1, 1, 1)

    game.background:draw()

    for i, button in pairs(self.buttons) do
        button:draw()
    end

	local lineOffset = self.lineLengthOffset
	love.graphics.line(self.lineX, self.lineY1+lineOffset, self.lineX, self.lineY2-lineOffset)

	love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 120+55 + math.floor(self.headerTweenAmount))

    love.graphics.setFont(self.titleFont)
    love.graphics.setColor(0, 0, 0)
	local x = self.titleX
	x = math.floor(x)
    love.graphics.print(self.title, x, 70)
end
