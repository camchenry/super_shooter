credits = {}

function credits:enter()
	self.text = [[
		MUSIC:
			Game music by Mark Sparling
			Boss music by Mark Sparling
	]]

	self.back = Button:new("< BACK", 75, love.graphics.getHeight() - 80)
	self.back.activated = function()
		state.switch(menu)
	end
end

function credits:update(dt)
	self.back:update(dt)
end

function credits:mousepressed(x, y, mbutton)
	self.back:mousepressed(x, y, mbutton)
end

function credits:keypressed(key, isrepeat)
	
end

function credits:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.setFont(font[30])
	love.graphics.printf(self.text, 75, 100, love.graphics.getWidth()-200)
	love.graphics.setFont(font[36])

	self.back:draw()
end