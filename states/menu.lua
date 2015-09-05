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
end

function menu:enter()

end

function menu:update(dt)

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
    love.graphics.rectangle("fill", 0, 55, love.graphics.getWidth(), 120)

    love.graphics.setFont(fontBold[72])
    love.graphics.setColor(0, 0, 0)
    love.graphics.print('SUPER SHOOTER', 75, 70)

    for i, button in pairs(self.buttons) do
        button:draw()
    end
end