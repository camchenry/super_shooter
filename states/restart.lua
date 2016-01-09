restart = {}

function restart:enter()
	self.time = 0
end

function restart:update(dt)
	self.time = self.time + dt
end

function restart:mousepressed(x, y, mbutton)
	if highscoreList:scoreIsValid(game.highScore.currentScore) then
		state.push(highscoreList)
	else
		state.switch(game)
	end
end

function restart:keypressed(key, isrepeat)
	
end

function restart:draw()
	game:draw()
	love.graphics.setColor(255, 255, 255)
	local text = [[
		PROGRAM TERMINATED
	]]
	local score = "SCORE: " .. game.highScore.currentScore
	local wave = "WAVE: " .. game.wave
	local text2 = [[
		< click anywhere to reboot >
	]]
	love.graphics.setFont(fontLight[48])
	love.graphics.printf(string.upper(text), 0, love.graphics.getHeight()/2-200, love.graphics.getWidth(), "center")
	love.graphics.setFont(font[36])
	love.graphics.printf(string.upper(score), 0, love.graphics.getHeight()/2-125, love.graphics.getWidth(), "center")
	love.graphics.setFont(font[36])
	love.graphics.printf(string.upper(wave), 0, love.graphics.getHeight()/2-70, love.graphics.getWidth(), "center")
	love.graphics.setFont(font[24])
	love.graphics.setColor(255, 255, 255, math.abs(255*math.sin(self.time)))
	love.graphics.print(text2, love.graphics.getWidth()/2 - font[24]:getWidth(text2)/2, love.graphics.getHeight()/2+25)
	
	if highscoreList:scoreIsValid(game.highScore.currentScore) then
		love.graphics.setColor(255, 225, 0)
		local highscoreText = "You qualify for a highscore!"
		love.graphics.print(highscoreText, love.graphics.getWidth()/2 - font[24]:getWidth(highscoreText)/2, love.graphics.getHeight()/2+100)
	end
end