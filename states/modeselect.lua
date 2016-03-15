modeselect = {}

modeselect.items = {
    {
        title = "SURVIVAL",
        action = function()
            state.switch(game, Survival)
        end,
    },

    {
        title = "OTHER",
        action = function()
            state.push(game, Gamemode)
        end,
    },
}

modeselect.buttons = {}

function modeselect:init()
	local buttonHeight = 50
	self.lineLengthOffset = 9

    for i, item in pairs(self.items) do
        table.insert(self.buttons, Button:new(item.title, 75, buttonHeight*(i-1) + 250, nil, buttonHeight, font[30], item.action))
    end

    self.back = Button:new("< BACK", 75, love.graphics.getHeight() - 60)
    self.back.activated = function()
        state.switch(menu)
    end

    self.title = 'SUPER SHOOTER'
    self.titleFont = fontBold[72]
end

function modeselect:enter()
    love.mouse.setCursor(cursor)
	
	self.time = 0
	
	love.graphics.setLineWidth(1)
	-- default value for the line
	self.lineX = self.buttons[1].x - 10
	self.lineY1 = self.buttons[1].y
	self.lineY2 = self.buttons[#self.buttons].y + self.buttons[#self.buttons].height
end

function modeselect:update(dt)
	self.time = self.time+dt

    game.background:update(dt)

    for i, button in pairs(self.buttons) do
        button:update(dt)
    end

    self.back:update(dt)
	
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

function modeselect:keyreleased(key, code)
    
end

function modeselect:keypressed(key)
    if key == "escape" then
        state.switch(menu)
    end

    if key == 'f1' then
        state.push(game, Testmode)
    end
end

function modeselect:mousepressed(x, y, mbutton)
    for i, button in pairs(self.buttons) do
        button:mousepressed(x, y, mbutton)
    end
    self.back:mousepressed(x, y, mbutton)
end

function modeselect:draw()
    love.graphics.setColor(255, 255, 255)
    
    game.background:draw()

    for i, button in pairs(self.buttons) do
        button:draw()
    end

    self.back:draw()
	
	local lineOffset = self.lineLengthOffset
	love.graphics.line(self.lineX, self.lineY1+lineOffset, self.lineX, self.lineY2-lineOffset)
	
	love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 175)

    love.graphics.setFont(self.titleFont)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.title, 75, 70)
end
