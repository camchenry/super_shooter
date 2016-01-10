gameover = {}

function gameover:enter()
	self.time = 0
end

function gameover:update(dt)
	self.time = self.time + dt
end

function gameover:mousepressed(x, y, mbutton)
	if highscoreList:scoreIsValid(game.highScore.currentScore) then
		state.push(highscoreList)
	else
		state.switch(menu)
	end
end

function gameover:keypressed(key, isrepeat)
	if key == 'q' then
		state.push(highscoreList)
	end
end

function gameover:draw()
	game:draw()
	love.graphics.setColor(255, 255, 255)
	local text = "Thanks for playing!"
	local text2 = "That's all for now. If you enjoyed it, leave a post on the forums!"
	local text3 = "< click to return to menu >"
	local score = "FINAL SCORE: " .. game.highScore.currentScore
	
	love.graphics.setFont(fontLight[48])
	text = string.upper(text)
	local textX, textY = love.graphics.getWidth()/2 - fontLight[48]:getWidth(text)/2, love.graphics.getHeight()/2-100
	textX, textY = math.floor(textX), math.floor(textY)
	love.graphics.print(string.upper(text), textX, textY)
	
	love.graphics.setFont(font[24])
	local text2X, text2Y = love.graphics.getWidth()/2 - font[24]:getWidth(text2)/2, love.graphics.getHeight()/2
	text2X, text2Y = math.floor(text2X), math.floor(text2Y)
	love.graphics.print(text2, text2X, text2Y)
	
	local text3X, text3Y = love.graphics.getWidth()/2 - font[24]:getWidth(text3)/2, love.graphics.getHeight()/2 + 50
	text3X, text3Y = math.floor(text3X), math.floor(text3Y)
	love.graphics.print(text3, text3X, text3Y)
	
	love.graphics.setColor(255, 255, 255, math.abs(255*math.sin(self.time)))
	love.graphics.print(text3, text3X, text3Y)
	
	if highscoreList:scoreIsValid(game.highScore.currentScore) then
		love.graphics.setColor(255, 225, 0)
		local highscoreText = "You qualify for a highscore!"
		local highscoreX, highscoreY = love.graphics.getWidth()/2 - font[24]:getWidth(highscoreText)/2, love.graphics.getHeight()/2+100
		highscoreX, highscoreY = math.floor(highscoreX), math.floor(highscoreY)
		love.graphics.print(highscoreText, highscoreX, highscoreY)
	end
	
	love.graphics.setColor(255, 255, 255)
	
	love.graphics.setFont(font[36])
	local scoreX, scoreY = love.graphics.getWidth()/2 - font[36]:getWidth(score)/2, love.graphics.getHeight()/2 + 200
	scoreX, scoreY = math.floor(scoreX), math.floor(scoreY)
	love.graphics.print(score, scoreX, scoreY)
end