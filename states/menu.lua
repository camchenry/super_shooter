menu = {}

menu.items = {
    {
        title = "NEW GAME",
        action = function()
            --fx.fade(.75, {0, 0, 0}, "outQuad", function()
                state.switch(game)
            --end)
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
        table.insert(self.buttons, Button:new(item.title, 100, 50*(i-1) + 250, nil, nil, font[32], item.action))
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
    love.graphics.setFont(fontBold[72])
    love.graphics.print('VOYAGER', 100, 70)

    for i, button in pairs(self.buttons) do
        button:draw()
    end

    --fx.draw()
end