info = {}

info.buttons = {}

function info:init()
	self.leftAlign = 75
	self.textY = 225

    self.title = "HOW TO PLAY"
    self.font = font[28]
	self.text = "Welcome to Super Shooter!\n\nUse WASD or Arrow Keys to move.\nUse your mouse to aim, and LMB to shoot.\nTrackpad Mode enables automatic aiming,\n\tit may be helpful when using a trackpad.\n\nAll feedback and criticism is welcome,\n\tor feel free to share your high score!\n\nYou can find our LOVE forum post\n\nIf you would like to contribute to the development\n\tof this project and future endeavors, donate at our"
end

function info:enter()
    signal.emit('infoEntered')
	local bottomMargin = 60

	self.back = Button:new("< BACK", 75, love.graphics.getHeight() - bottomMargin)
	self.back.activated = function()
		state.switch(menu)
	end

	local x, y = self.font:getWidth("You can find our LOVE forum post "), self.font:getHeight()*10
	x = x + self.leftAlign + 2
	y = y + self.textY - 2

	self.link = Button:new("here", x, y)
	self.link.activated = function()
		love.system.openURL("https://love2d.org/forums/viewtopic.php?f=5&t=81156")
	end
	self.link.fg = {116, 192, 242}
	self.link.active = {62, 131, 222}
	self.link.font = font[28]

	local x, y = self.font:getWidth("\tof this project and future endeavors, donate at our "), self.font:getHeight()*13
	x = x + self.leftAlign - 8
	y = y + self.textY - 2

	self.store = Button:new("itch.io page", x, y)
	self.store.activated = function()
		love.system.openURL("http://ikroth.itch.io/super-shooter")
	end
	self.store.fg = {116, 192, 242}
	self.store.active = {62, 131, 222}
	self.store.font = font[28]
end

function info:update(dt)
	self.back:update(dt)
	self.link:update(dt)
	self.store:update(dt)
end

function info:keyreleased(key, code)

end

function info:mousepressed(x, y, mbutton)
    self.back:mousepressed(x, y, mbutton)
    self.link:mousepressed(x, y, mbutton)
    self.store:mousepressed(x, y, mbutton)
end

function info:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 120+55)

    love.graphics.setFont(fontBold[72])
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.title, 75, 70)

    love.graphics.setColor(1, 1, 1)

    love.graphics.setFont(self.font)
    love.graphics.print(self.text, self.leftAlign, self.textY)

    self.back:draw()
	self.link:draw()
	self.store:draw()
end
