sidebarButton = class("sidebarButton")

function sidebarButton:initialize(text, x, y, w, h, fontSize, activated)
    self.text = text
    self.font = fontSize or font[32]
    self.x = x
    self.y = y
    self.width = w or self.font:getWidth(text)
    self.height = h or self.font:getHeight(text)

    self.active = {255, 255, 255}
	self.activebg = {66, 66, 66}
    self.bg = {0, 0, 0, 0}
    self.fg = {255, 255, 255, 255}
	
	self.outline = true
	self.outlineColor = {255, 255, 255}
	self.outlineWidth = 2

    self.translateX = 0
	
	self.index = 0
	self.hovered = function() end

    self.click = sidebarButton.click
    self.selected = false

    self.activated = activated or function() end
end

function sidebarButton:update()
	if self:hover() then
		self.hovered(self.index)
	end
end

-- Not used currently. Could be used to 'lock' a mission in the sidebar
function sidebarButton:mousepressed(x, y, mbutton)
    if self:hover() and mbutton == "l" then
        self.activated()
    end
end

function sidebarButton:draw(active)
    local r, g, b, a = love.graphics.getColor()
    local oldColor = {r, g, b, a}
	local oldLineWidth = love.graphics.getLineWidth()

    local hover = self:hover()
	if hover then
		love.graphics.setColor(self.activebg)
	elseif active then
		love.graphics.setColor(46, 167, 232)
	else
		love.graphics.setColor(self.bg)
	end
	
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	if self.outline then
		love.graphics.setColor(self.outlineColor)
		love.graphics.setLineWidth(self.outlineWidth)
		love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
	end

    if hover then
        love.graphics.setColor(self.active)
    else
        love.graphics.setColor(self.fg)
    end

    local x = self.x + self.width/2 - self.font:getWidth(self.text)/2 + self.translateX
    local y = self.y + self.height/2 - self.font:getHeight(self.text)/2
    love.graphics.setFont(self.font)
    love.graphics.print(self.text, x, y)

    love.graphics.setColor(oldColor)
	love.graphics.setLineWidth(oldLineWidth)
end

function sidebarButton:setFont(font, update)
    update = update or true
    self.font = font
    if update then
        self.width =  self.font:getWidth(self.text)
        self.height = self.font:getHeight(self.text)
    end
    return self
end

function sidebarButton:setActive(r, g, b, a)
    self.active = {r, g, b, a or 255}
    return self
end

function sidebarButton:setBG(r, g, b, a)
    self.bg = {r, g, b, a or 255}
    return self
end

function sidebarButton:setFG(r, g, b, a)
    self.fg = {r, g, b, a or 255}
    return self
end

function sidebarButton:align(mode, margin)
    margin = margin or 0

    -- this will center align the sidebarButton around the original coordinates
    if mode == 'both' then
        self.x = self.x - self.width/2
        self.y = self.y - self.height/2
    end

    -- this will only align the sidebarButton around the original x coordinate
    if mode == 'x' then
        self.x = self.x - self.width/2
    end

    -- this will only align the sidebarButton around the original y coordinate
    if mode == 'y' then
        self.y = self.y - self.height/2
    end

    -- shift text to left
    if mode == 'left' then
        self.translateX =  self.font:getWidth(self.text)/2 - self.width/2 + margin
    end

    -- shift text to center
    if mode == 'center' then
        self.translateX = 0
    end

    -- shift text to right
    if mode == 'right' then
        self.translateX = 0
    end
end

function sidebarButton:centerAround(x, y)
    self.x = x - self.width/2
    self.y = y - self.height/2
    return self
end

-- returns whether or not the mouse is currently over the sidebarButton
function sidebarButton:hover()
    local mx, my = love.mouse.getX(), love.mouse.getY()
    local inX = mx >= self.x and mx <= self.x + self.width
    local inY = my >= self.y and my <= self.y + self.height
    return inX and inY
end