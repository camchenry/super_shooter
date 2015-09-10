pause = {}

pause.items = {
    {
        title = "BACK TO GAME",
        action = function()
            state.switch(game)
        end,
    },
    {
        title = "QUIT TO MENU",
        action = function()
            state.switch(menu)
        end,
    },

    {
        title = "QUIT TO DESKTOP",
        action = function()
            love.event.quit()
        end,
    },
}

pause.buttons = {}

function pause:init()
	for i, item in pairs(self.items) do
        table.insert(self.buttons, Button:new(item.title, 75, 50*(i-1) + 250, nil, nil, font[30], item.action))
    end
end

function pause:enter(prev)
	self.prevState = prev

	love.mouse.setCursor(cursor)
end

function pause:keypressed(key, isrepeat)
	if key == "p" then
		state.switch(game)
	end
end

function pause:mousepressed(x, y, mbutton)
    for i, button in pairs(self.buttons) do
        button:mousepressed(x, y, mbutton)
    end
end


function pause:draw()
	self.prevState:draw()

	love.graphics.setColor(0, 0, 0, 80)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 120+55)

    love.graphics.setFont(fontBold[72])
    love.graphics.setColor(0, 0, 0)
    love.graphics.print("PAUSED", 75, 70)

    for i, button in pairs(self.buttons) do
        button:draw()
    end
end