FloatingMessages = class("FloatingMessages")

function FloatingMessages:initialize()
	self.messages = {}

	signal.register('enemyHit', function(enemy, damage)
		self:newMessage(enemy.position.x, enemy.position.y, damage, 1)
	end)
end

function FloatingMessages:newMessage(x, y, text, time)
	table.insert(self.messages, {
		x = x,
		y = y,
		text = text,
		time = time	
	})
end

function FloatingMessages:update(dt)
	for i, msg in pairs(self.messages) do
		msg.time = msg.time - dt
		msg.y = msg.y - 25*dt
	end

	for i=#self.messages, 1, -1 do
		if self.messages[i].time <= 0 then
			table.remove(self.messages, i)
		end
	end
end

function FloatingMessages:draw()
	love.graphics.setFont(font[14])

	for i, msg in pairs(self.messages) do
		love.graphics.setColor(255, 255, 255, 200 * msg.time)
		love.graphics.print(msg.text, msg.x + WINDOW_OFFSET.x, msg.y + WINDOW_OFFSET.y)
	end
end