FloatingMessages = class("FloatingMessages")

function FloatingMessages:initialize()
	-- messages will be placed in static or dynamic
	-- dynamic will move with the game world
	-- static will have a fixed screen position
	self.staticMessages = {}
	self.dynamicMessages = {}
	self.messageQueue = {}
	self.queueDiff = .25
	self.queueTimer = 0

	signal.register('newGame', function()
		self.staticMessages = {}
		self.dynamicMessages = {}
		self.messagQueue = {}
	end)

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
		local width, height = love.graphics.getWidth(), love.graphics.getHeight()
		local x = love.graphics.getWidth() - 40 - width/2
		local y = love.graphics.getHeight() - 100 - height/2

		local size = 24
		local w = font[size]:getWidth(score) - 14

		self:newMessage(x-w, y, score, 1, size, 75, true, true) -- add message to queue, make it static
	end)
end

function FloatingMessages:newMessage(x, y, text, time, size, speed, queue, static)
	size = size or 14
	speed = speed or 25
	-- if queue, add to message queue. otherwise, if static, add to static messages. otherwise, add to dynamic messages.
	table.insert(queue and self.messageQueue or static and self.staticMessages or self.dynamicMessages, {
		x = x,
		y = y,
		text = text,
		time = time,
		size = size,
		speed = speed,
		static = static,
	})
end

function FloatingMessages:update(dt)
	self.queueTimer = self.queueTimer + dt
	if self.queueTimer >= self.queueDiff then -- remove from queue, add to messages
		self.queueTimer = 0

		if #self.messageQueue > 0 then
			-- release message from queue spot 1
			local static = self.messageQueue[1].static or false

			-- messages are sorted into either static or dynamic
			table.insert(static and self.staticMessages or self.dynamicMessages, {
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

	for i, msg in pairs(self.staticMessages) do
		msg.time = msg.time - dt
		msg.y = msg.y - msg.speed*dt
	end

	for i, msg in pairs(self.dynamicMessages) do
		msg.time = msg.time - dt
		msg.y = msg.y - msg.speed*dt
	end

	for i=#self.staticMessages, 1, -1 do
		if self.staticMessages[i].time <= 0 then
			table.remove(self.staticMessages, i)
		end
	end

	for i=#self.dynamicMessages, 1, -1 do
		if self.dynamicMessages[i].time <= 0 then
			table.remove(self.dynamicMessages, i)
		end
	end

	while #self.staticMessages > 10 do
		table.remove(self.staticMessages, 1)
	end

	while #self.dynamicMessages > 10 do
		table.remove(self.dynamicMessages, 1)
	end
end

function FloatingMessages:drawStatic()
	for i, msg in pairs(self.staticMessages) do
		love.graphics.setFont(font[msg.size])
		love.graphics.setColor(1, 1, 1, 200/255 * msg.time)
		local x, y = msg.x, msg.y
		local width, height = love.graphics.getWidth(), love.graphics.getHeight()
		x, y = x + width/2, y + height/2
		x, y = math.floor(x), math.floor(y)
		love.graphics.print(msg.text, x, y)
	end
end

function FloatingMessages:drawDynamic() -- contains many workarounds
	for i, msg in pairs(self.dynamicMessages) do
		local fontSize = msg.size*game.camera.scale
		love.graphics.setFont(font[fontSize])
		love.graphics.setColor(1, 1, 1, 200/255 * msg.time)
		local x, y = msg.x, msg.y
		x, y = math.floor(x), math.floor(y)
		love.graphics.print(msg.text, x, y, 0, 1/game.camera.scale, 1/game.camera.scale)
	end
end
