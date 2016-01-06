FloatingMessages = class("FloatingMessages")

function FloatingMessages:initialize()
	self.messages = {}
	self.messageQueue = {}
	self.queueDiff = .25
	self.queueTimer = 0

	signal.register('enemyHit', function(enemy, damage, crit)
		if damage == nil then return end
		damage = math.ceil(damage)

		local size = 14
		if crit then
			size = 20
		end

		self:newMessage(enemy.position.x, enemy.position.y, damage, 1, size)
	end)

	signal.register('scoreChange', function(score)
		local x = love.graphics.getWidth() - 40 - WINDOW_OFFSET.x
		local y = love.graphics.getHeight() - 100 - WINDOW_OFFSET.y
		
		local size = 24
		local w = font[size]:getWidth(score) - 14

		self:newMessage(x-w, y, score, 1, size, 75, true) -- add message to queue
	end)
end

function FloatingMessages:newMessage(x, y, text, time, size, speed, queue)
	size = size or 14
	speed = speed or 25
	table.insert(queue and self.messageQueue or self.messages, {
		x = x,
		y = y,
		text = text,
		time = time,
		size = size,
		speed = speed,
	})
end

function FloatingMessages:update(dt)
	self.queueTimer = self.queueTimer + dt
	if self.queueTimer >= self.queueDiff then -- remove from queue, add to messages
		self.queueTimer = 0
		
		if #self.messageQueue > 0 then
			-- release message from queue spot 1
			table.insert(self.messages, {
				x = self.messageQueue[1].x,
				y = self.messageQueue[1].y,
				text = self.messageQueue[1].text,
				time = self.messageQueue[1].time,
				size = self.messageQueue[1].size,
				speed = self.messageQueue[1].speed,
			})
			table.remove(self.messageQueue, 1)
		end
	end

	for i, msg in pairs(self.messages) do
		msg.time = msg.time - dt
		msg.y = msg.y - msg.speed*dt
	end

	for i=#self.messages, 1, -1 do
		if self.messages[i].time <= 0 then
			table.remove(self.messages, i)
		end
	end

	while #self.messages > 10 do
		table.remove(self.messages, 1)
	end
end

function FloatingMessages:draw()
	for i, msg in pairs(self.messages) do
		love.graphics.setFont(font[msg.size])
		love.graphics.setColor(255, 255, 255, 200 * msg.time)
		love.graphics.print(msg.text, msg.x + WINDOW_OFFSET.x, msg.y + WINDOW_OFFSET.y)
	end
end