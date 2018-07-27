Hurt = class("Hurt")

function Hurt:initialize()
    self.playerHurtObserver = signal.register('playerHurt', function() self:onPlayerHurt() end)

    self.overlayColor = {172/255, 13/255, 8/255}
    self.overlayAlpha = 150
    self.overlayTimeMax = 1
    self.time = 0

    signal.register('newGame', function()
		self.time = 0
	end)
end

function Hurt:update(dt)
	if self.time < 0 then
		self.time = 0
	else
		self.time = self.time - dt
	end
end

function Hurt:onPlayerHurt()
	self.time = self.overlayTimeMax
end

function Hurt:draw()
	if state.current() ~= game then return end

	if self.time > 0 then
		local color = self.overlayColor
		color[4] = self.overlayAlpha*(self.overlayTimeMax - (self.overlayTimeMax - self.time)) / 255
		love.graphics.setLineWidth(18)
		love.graphics.setColor(color)
		local padding = 10
		love.graphics.rectangle("line", 0, 0, love.graphics.getWidth(), love.graphics.getHeight(), 20, 20, 5)
		love.graphics.setLineWidth(1)
	end
end
