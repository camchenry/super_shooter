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
	love.graphics.setColor(1, 1, 1)
	local text = "PROGRAM TERMINATED"
	local score = "SCORE: " .. game.highScore.currentScore
	local wave = "WAVE: " .. game.wave
	local text2 = "< click anywhere to reboot >"

	love.graphics.setFont(fontLight[48])
	local textX, textY = love.graphics.getWidth()/2 - fontLight[48]:getWidth(text)/2, love.graphics.getHeight()/2-200
	textX, textY = math.floor(textX), math.floor(textY)
	love.graphics.print(text, textX, textY)

	love.graphics.setFont(font[36])
	local scoreX, scoreY = love.graphics.getWidth()/2 - font[36]:getWidth(score)/2, love.graphics.getHeight()/2-125
	scoreX, scoreY = math.floor(scoreX), math.floor(scoreY)
	love.graphics.print(score, scoreX, scoreY)

	love.graphics.setFont(font[36])
	local waveX, waveY =  love.graphics.getWidth()/2 - font[36]:getWidth(wave)/2, love.graphics.getHeight()/2-70
	waveX, waveY = math.floor(waveX), math.floor(waveY)
	love.graphics.print(wave, waveX, waveY)

	love.graphics.setFont(font[24])
	local text2X, text2Y = love.graphics.getWidth()/2 - font[24]:getWidth(text2)/2, love.graphics.getHeight()/2+25
	text2X, text2Y = math.floor(text2X), math.floor(text2Y)
	love.graphics.setColor(1, 1, 1, math.abs(1*math.sin(self.time)))
	love.graphics.print(text2, text2X, text2Y)

	if highscoreList:scoreIsValid(game.highScore.currentScore) then
		love.graphics.setColor(1, 1, 0)
		local highscoreText = "You qualify for a highscore!"
		local highscoreX, highscoreY = love.graphics.getWidth()/2 - font[24]:getWidth(highscoreText)/2, love.graphics.getHeight()/2+100
		highscoreX, highscoreY = math.floor(highscoreX), math.floor(highscoreY)
		love.graphics.print(highscoreText, highscoreX, highscoreY)
	end
end
