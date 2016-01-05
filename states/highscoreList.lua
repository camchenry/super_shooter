highscoreList = {}
-- this is out here because it needs to be accessible before highscoreList:init() is called
highscoreList.file = 'highscores.txt'

function highscoreList:init()
	self.leftAlign = 75
	self.scores = {}
	
	self.initialsInput = {' ', ' ', ' '}
	self.selectorPos = 1
	self.playerScore = 0
	self.fromGame = false
	self.scoreEntered = false
	self.initialChar = true
end

function highscoreList:enter(prev)
	self.scores = nil
	if not love.filesystem.exists(self.file) then
		self.scores = self:getDefaultScores()
	else
		self.scores = self:getScores()
	end
	
	if prev == menu then -- hides the score enter
		self.fromGame = false
	else -- the menu would have no player data stored
		self.fromGame = true
		self.scoreEntered = false
		self.initialChar = true
		self.playerScore = game.highScore.currentScore
	end
end

function highscoreList:leave()
	--self:load()
end

function highscoreList:mousepressed(x, y, button)

end

function highscoreList:keypressed(key)
	if key == "escape" then
		state.pop()
	end
	
	if self.fromGame then
		if key == "return" then
			if not self.scoreEntered then
				self.scoreEntered = true
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
	end
end

function highscoreList:textinput(t)
	if self.fromGame and not self.scoreEntered then
		if self.initialChar then
			self.initialChar = false
		else
			self.initialsInput [self.selectorPos] = t
			
			if self.selectorPos < 3 then
				self.selectorPos = self.selectorPos + 1
			end
		end
	end
end

function highscoreList:update(dt)

end

function highscoreList:draw()
	love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 120+55)

    love.graphics.setFont(fontBold[32])
    love.graphics.setColor(0, 0, 0)
    love.graphics.print('highscoreList', 75, 70)
	
	love.graphics.setColor(255, 255, 255)
	local sep = 40
	
	for i, scoreData in ipairs(self.scores) do
		love.graphics.print(scoreData.initials..' '..scoreData.score, 50, 200+(sep*(i-1)))
	end
	
	-- optimize! polish!
	-- initials input
	if self.fromGame then
		local x = 500
		local y = love.graphics.getHeight()/2
		
		if not self.scoreEntered then
			love.graphics.print('Press enter to save your score!', x, y + 200)
		end
		
		local font = fontBold[72]
		love.graphics.setFont(font)
		
		local spacing = 20
		local width = font:getWidth('W')
		local height = font:getHeight() + 10
		
		for i = 1, 3 do
			if i == self.selectorPos then
				love.graphics.setLineWidth(4)
			else
				love.graphics.setLineWidth(10)
			end
			
			local dx = (width+spacing)*(i-1)
			love.graphics.line(x + dx, y, x + dx + width, y)
			local char = self.initialsInput[i]
			local charWidth = font:getWidth(char)
			
			love.graphics.print(self.initialsInput[i], x + dx + width/2 - charWidth/2, y - height) --?
		end
	end
end

function highscoreList:checkScore()
	-- check if the score actually belongs in the scoreboard (top 10)
	local playerInitials = self.initialsInput[1]..self.initialsInput[2]..self.initialsInput[3]
	local playerScore = self.playerScore
	table.insert(self.scores, {initials = playerInitials, score = playerScore})
	
	self:save()
end

function highscoreList:getDefaultScores()
	-- default values on the scoreboard
	local o = {
		{
			initials = 'AAA',
			score = 1000
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