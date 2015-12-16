Hurt = class("Hurt")

function Hurt:initialize()
    self.playerHurtObserver = signal.register('playerHurt', function() self:onPlayerHurt() end)

    self.overlayColor = {172, 13, 8}
    self.overlayAlpha = 128
    self.overlayTimeMax = 0.75
    self.time = 0
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
		color[4] = self.overlayAlpha*(self.overlayTimeMax - (self.overlayTimeMax - self.time))
		love.graphics.setLineWidth(30)
		love.graphics.setColor(color)
		love.graphics.rectangle("line", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
		love.graphics.setLineWidth(1)
	end
end