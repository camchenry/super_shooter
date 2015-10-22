gameover = {}

function gameover:update(dt)

end

function gameover:draw()
	paused = true
	game:draw()
	love.graphics.setColor(255, 255, 255)
	local text = [[
		Thanks for playing!
	]]
	local text2 = [[
		That's all for now, if this were a paid game it wouldn't be so short. :)
	]]
	love.graphics.setFont(fontLight[48])
	love.graphics.printf(string.upper(text), 0, love.graphics.getHeight()/2-100, love.graphics.getWidth(), "center")
	love.graphics.setFont(font[24])
	love.graphics.printf(text2, 400, love.graphics.getHeight()/2, love.graphics.getWidth()-800, "center")
end