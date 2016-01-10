info = {}

info.buttons = {}

function info:init()
	self.leftAlign = 75
	self.textY = 225

    self.title = "HOW TO PLAY"
    self.font = font[32]
	self.text = "Welcome to Super Shooter!\n\nUse WASD or Arrow Keys to move\nUse your mouse to aim, LMB to shoot\n\nTrackpad Mode enables automatic shooting,\n\tit may be helpful when using a trackpad\n\nAll feedback and criticism is welcome!\n\tOr feel free to share your high score!\n\n\tYou can find the LOVE forum post"
end

function info:enter()
    signal.emit('infoEntered')
	local bottomMargin = 60
	
	self.back = Button:new("< BACK", 75, love.graphics.getHeight() - bottomMargin)
	self.back.activated = function()
		state.switch(menu)
	end
	
	self.link = Button:new("HERE", 588, 644)
	self.link.activated = function()
		love.system.openURL("https://love2d.org/forums/viewtopic.php?f=5&t=81156")
	end
	self.link.fg = {50, 50, 255}
	self.link.active = {20, 20, 235}
end

function info:update(dt)
	self.back:update(dt)
	self.link:update(dt)
end

function info:keyreleased(key, code)

end

function info:mousepressed(x, y, mbutton)
    self.back:mousepressed(x, y, mbutton)
    self.link:mousepressed(x, y, mbutton)
end

function info:draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 120+55)

    love.graphics.setFont(fontBold[72])
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.title, 75, 70)

    love.graphics.setColor(255, 255, 255)
	
    love.graphics.setFont(self.font)
    love.graphics.print(self.text, self.leftAlign, self.textY)
	
    self.back:draw()
	self.link:draw()
end