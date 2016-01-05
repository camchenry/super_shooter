restart = {}

function restart:enter()
	self.time = 0
end

function restart:update(dt)
	self.time = self.time + dt
end

function restart:mousepressed(x, y, mbutton)
	state.switch(game)
end

function restart:keypressed(key, isrepeat)
	if key == 'q' then
		state.push(highscoreList)
	end
end

function restart:draw()
	game:draw()
	love.graphics.setColor(255, 255, 255)
	local text = [[
		PROGRAM TERMINATED
	]]
	local score = "SCORE: " .. game.highScore.currentScore
	local text2 = [[
		< click anywhere to reboot >
	]]
	love.graphics.setFont(fontLight[48])
	love.graphics.printf(string.upper(text), 0, love.graphics.getHeight()/2-100, love.graphics.getWidth(), "center")
	love.graphics.setFont(font[36])
	love.graphics.printf(string.upper(score), 0, love.graphics.getHeight()/2-25, love.graphics.getWidth(), "center")
	love.graphics.setFont(font[24])
	love.graphics.setColor(255, 255, 255, math.abs(255*math.sin(self.time)))
	love.graphics.printf(text2, 400, love.graphics.getHeight()/2+50, love.graphics.getWidth()-800, "center")
	
	love.graphics.printf("You qualify for a highscore! Press 'Q'", 400, love.graphics.getHeight()/2+200, love.graphics.getWidth()-800, "center")
end