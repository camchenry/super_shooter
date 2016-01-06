menu = {}

menu.items = {
    {
        title = "NEW GAME",
        action = function()
            state.switch(game)
        end,
    },

    {
        title = "OPTIONS",
        action = function()
			state.push(options)
        end,
    },
	
	{
        title = "HIGH SCORES",
        action = function()
			state.push(highscoreList)
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
    for i, item in pairs(self.items) do
        table.insert(self.buttons, Button:new(item.title, 75, 50*(i-1) + 250, nil, nil, font[30], item.action))
    end
	
	-- reveal the menu on game launch
	self.headerTweenAmount = love.graphics.getHeight() - (120+55)
	self.headerTween = tween(2, self, {headerTweenAmount = 0}, "outBack", function() end)
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
    love.graphics.setColor(255, 255, 255)

    for i, button in pairs(self.buttons) do
		local x = button.x
		button.x = button.x
        button:draw()
		button.x = x
    end
	
	love.graphics.line(self.lineX, self.lineY1, self.lineX, self.lineY2)
	
	love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 120+55 + math.floor(self.headerTweenAmount))

    love.graphics.setFont(fontBold[72])
    love.graphics.setColor(0, 0, 0)
    love.graphics.print('SUPER SHOOTER', 75, 70 + math.floor(self.headerTweenAmount))
end