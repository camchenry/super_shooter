highscoreList = {}
-- this is out here because it needs to be accessible before highscoreList:init() is called
highscoreList.file = 'highscores.txt'

function highscoreList:init()
	self.leftAlign = 75

	self.initialsInput = {' ', ' ', ' '}
	self.selectorPos = 1
	self.playerScore = 0
	self.fromGame = false
	self.scoreEntered = false
	self.initialChar = true
end

function highscoreList:initializeScores()
	self.scores = {}

	if not love.filesystem.exists(self.file) then
		self.scores = self:getDefaultScores()
	else
		self.scores = self:getScores()
	end

	self.maxScores = 10 -- how many high scores are stored
end

function highscoreList:enter(prev)
	if prev == menu then -- hides the score enter
		self.fromGame = false
	else -- the menu would have no player data stored
		self.fromGame = true
		self.scoreEntered = false
		self.initialChar = true
		self.playerScore = game.highScore.currentScore

		self.initialsInput = {' ', ' ', ' '}
		self.selectorPos = 1
	end

	local bottomMargin = 60

	self.back = Button:new("< BACK", self.leftAlign, love.graphics.getHeight() - bottomMargin)
	self.back.activated = function()
		if prev == restart then
			state.pop()
			state.switch(game)
		else
			state.switch(menu)
		end
	end
end

function highscoreList:leave()

end

function highscoreList:mousepressed(x, y, button)
	self.back:mousepressed(x, y, button)
end

function highscoreList:keypressed(key)
	if key == "escape" then
		self.back.activated()
	end

	if self.fromGame then
		if key == "return" then
			if not self.scoreEntered then
				self.scoreEntered = true
				self.fromGame = false
				self:checkScore()
			end
		end

		if key == "left" then
			if self.selectorPos > 1 then
				self.selectorPos = self.selectorPos - 1
			end
		elseif  key == "right" then
			if self.selectorPos < 3 then
				self.selectorPos = self.selectorPos + 1
			end
		end

		if key == "backspace" then
			if self.selectorPos > 1 then
				self.selectorPos = self.selectorPos - 1
			end
		end
	end
end

function highscoreList:deleteScores()
	self.scores = self:getDefaultScores()
	self:save()
end

function highscoreList:textinput(t)
	if self.fromGame and not self.scoreEntered then
		self.initialsInput [self.selectorPos] = t

		if self.selectorPos < 3 then
			self.selectorPos = self.selectorPos + 1
		end
	end
end

function highscoreList:update(dt)
	self.back:update(dt)
end

function highscoreList:draw()
    love.graphics.setFont(font[72])
    love.graphics.setColor(1, 1, 1)
	local x, y = love.graphics.getWidth()/2 - fontBold[72]:getWidth("HIGH SCORES")/2, 70
	x, y = math.floor(x), math.floor(y)
    love.graphics.print('HIGH SCORES', x, y)

    love.graphics.setFont(font[32])
	love.graphics.setColor(1, 1, 1)
	local sep = 45

	for i, scoreData in ipairs(self.scores) do
		if i == 1 then
			love.graphics.setFont(fontBold[36])
			love.graphics.setColor(1, 1, 0)
		elseif i == 2 then
			love.graphics.setFont(fontBold[32])
			love.graphics.setColor(192/255, 192/255, 192/255)
		elseif i == 3 then
			love.graphics.setFont(fontBold[32])
			love.graphics.setColor(205/255, 127/255, 50/255)
		else
			love.graphics.setFont(fontLight[30])
			love.graphics.setColor(255/255, 255/255, 255/255)
		end

		local line = scoreData.score
		local x = love.graphics.getWidth()/2 + 15
		local y = 200+(sep*(i-1))
		x, y = math.floor(x), math.floor(y)

		love.graphics.print(line, x, y)

		line = string.upper(scoreData.initials)
		x = love.graphics.getWidth()/2 - love.graphics.getFont():getWidth(line) - 15
		x = math.floor(x)

		love.graphics.print(line, x, y)
	end

	-- optimize! polish!
	-- initials input
	if self.fromGame then
		local y = love.graphics.getHeight()/2

		love.graphics.setColor(0, 0, 0, 96/255)
    	love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

		love.graphics.setColor(255/255, 255/255, 255/255)
    	love.graphics.rectangle("fill", 0, y-150, love.graphics.getWidth(), 300)
    	love.graphics.setColor(0, 0, 0)

    	local text = 'ENTER YOUR INITIALS'
    	love.graphics.setFont(font[24])
		local textX, textY = love.graphics.getWidth()/2-font[24]:getWidth(text)/2, y - 100
		textX, textY = math.floor(textX), math.floor(textY)
		love.graphics.print(text, textX, textY)


		local f = fontBold[72]
		love.graphics.setFont(f)

		local spacing = 20
		local width = f:getWidth('W')
		local height = f:getHeight() + 10
		local x = love.graphics.getWidth()/2 - (spacing*3)/2 - (width*3)/2

		for i = 1, 3 do
			love.graphics.setLineWidth(2)

			if i == self.selectorPos then
				love.graphics.setColor(255/255, 0, 0)
			else
				love.graphics.setColor(0, 0, 0)
			end

			local dx = (width+spacing)*(i-1)
			love.graphics.line(x + dx, y + height/2, x + dx + width, y + height/2)
			local char = self.initialsInput[i]
			char = string.upper(char)
			local charWidth = f:getWidth(char)

			love.graphics.setColor(0, 0, 0)

			local x, y = x + dx + width/2 - charWidth/2, y - height/2
			x, y = math.floor(x), math.floor(y)
			love.graphics.print(char, x, y)
		end

		if not self.scoreEntered then
			love.graphics.setFont(font[24])
			love.graphics.setColor(0, 0, 0)
			local text = 'Press enter to save your score!'
			local textX, textY = love.graphics.getWidth()/2-font[24]:getWidth(text)/2, y + 85
			textX, textY = math.floor(textX), math.floor(textY)
			love.graphics.print(text, textX, textY)
		end
	end

	self.back:draw()
end

function highscoreList:checkScore()
	-- check if the score actually belongs in the scoreboard (top 10)
	local playerInitials = self.initialsInput[1]..self.initialsInput[2]..self.initialsInput[3]
	local playerScore = self.playerScore

	if self:scoreIsValid(playerScore) then -- check if it belongs on the scoreboard
		-- find where the score belongs
		local pos = 1
		if #self.scores > 0 then -- if there are no scores in the list, it will place the score at pos 1
			for i = #self.scores, 1, -1 do
				if self.scores[i].score >= playerScore then -- found where new score belongs, right below the first score it is lower than
					pos = i+1
					break
				end
			end
		end
		table.insert(self.scores, pos, {initials = playerInitials, score = playerScore})

		if #self.scores > self.maxScores then -- if it's more than the max, it will only be one greater. so cut off the last score
			table.remove(self.scores)
		end
	end

	self:save()
end

function highscoreList:scoreIsValid(score)
	-- evaluates true if the high score list is not full, or the score is greater than the lowest score
	return ((#self.scores < self.maxScores) or (score > self.scores[self.maxScores].score)) and score > 0
end

function highscoreList:getDefaultScores()
	-- default values on the scoreboard
	local o = {
		{
			initials = 'IKR',
			score = 7960,
		},
		{
			initials = 'NTH',
			score = 6653,
		},
		{
			initials = 'ACE',
			score = 3531
		},
		{
			initials = 'AAA',
			score = 1200
		},
		{
			initials = 'KEK',
			score = 572
		},
		{
			initials = 'H8R',
			score = 22
		},
	}
	return o
end

function highscoreList:save()
	local string = ''
	for i, scoreData in ipairs(self.scores) do
		string = string..scoreData.initials..' '..scoreData.score..'\n'
	end

	love.filesystem.write(self.file, string)
end

function highscoreList:getScores()
	assert(love.filesystem.exists(self.file), 'Tried to load highscores file, but it does not exist.')
	local highscores = {}
	for line in love.filesystem.lines(highscoreList.file) do
		if string.len(line) > 0 then
			local name = string.sub(line, 1, 3)
			local number = tonumber(string.sub(line, 5))
			table.insert(highscores, {initials = name, score = number})
		end
	end

	return highscores
end
