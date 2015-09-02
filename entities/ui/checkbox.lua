Checkbox = class('Checkbox')

function Checkbox:initialize(text, x, y, w, h, fontSize, activated, deactivated)
	self.text = text
	self.font = fontSize or font[22]
	self.x = x
	self.y = y -- This centers it on the line
	self.width = w or 32
	self.height = h or 32
	
	self.textHeight = self.font:getHeight(self.text)
	
	self.color = {0, 0, 0}
	self.active = {255, 255, 255}
	
	self.textColor = {255, 255, 255}
	
	self.selected = false
	
	self.activated = activated or function() end
	self.deactivated = deactivated or function() end
end

function Checkbox:draw()
	local r, g, b, a = love.graphics.getColor()
    local oldColor = {r, g, b, a}
	
	local oldFont = love.graphics.getFont()
	love.graphics.setFont(self.font)
	
	if self.selected then
		love.graphics.setColor(self.active)
	else
		love.graphics.setColor(self.color)
	end
	
	local x = self.x
	local y = self.y - self.height/2

	love.graphics.setLineWidth(3)

	-- diagonal check line
	love.graphics.line(x, y, x+self.width, y+self.height)
	
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("line", x, y, self.width, self.height)
	
	local textWidth = self.font:getWidth(self.text)
	local textX = x + self.width + 10
	local textY = self.y - self.textHeight/2
	love.graphics.setFont(self.font)
	love.graphics.setColor(self.textColor)
	love.graphics.print(self.text, textX, textY)
	
	love.graphics.setColor(oldColor)
	love.graphics.setFont(oldFont)
end

function Checkbox:hovering(x, y)
	local xBoundMax = self.x + self.width + 10 + self.font:getWidth(self.text)
	local xBoundMin = self.x
	local yBoundMax = self.y + self.height/2
	local yBoundMin = self.y - self.height/2

	return x >= xBoundMin and x <= xBoundMax  and y >= yBoundMin and y <= yBoundMax
end

function Checkbox:mousepressed(x, y)
	if self:hovering(x, y) then
		-- toggle selected state
		self.selected = not self.selected

		if self.selected then
			self.activated()
		else
			self.deactivated()
		end
	end
end