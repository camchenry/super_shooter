gameover = {}

function gameover:enter()
	self.time = 0
end

function gameover:update(dt)
	self.time = self.time + dt
end

function gameover:mousepressed(x, y, mbutton)
	state.switch(game)
end

function gameover:draw()
	game:draw()
	love.graphics.setColor(255, 255, 255)
	local text = [[
		Thanks for playing!
	]]
	local text2 = [[
		That's all for now. If you enjoyed it, leave a post on the forums!
	]]
	love.graphics.setFont(fontLight[48])
	love.graphics.printf(string.upper(text), 0, love.graphics.getHeight()/2-100, love.graphics.getWidth(), "center")
	love.graphics.setFont(font[24])
	love.graphics.printf(text2, 400, love.graphics.getHeight()/2, love.graphics.getWidth()-800, "center")
	love.graphics.setColor(255, 255, 255, math.abs(255*math.sin(self.time)))
	love.graphics.printf("< click to return to menu >", 400, love.graphics.getHeight()/2+100, love.graphics.getWidth()-800, "center")
end