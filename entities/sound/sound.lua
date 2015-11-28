Sound = class('Sound')

function Sound:initialize()
	local config = nil
	if love.filesystem.exists(options.file) then
		config = options:getConfig()
	else
		config = options:getDefaultConfig()
	end

	self.musicVolume = config.audio.musicVolume/100
	self.soundVolume = config.audio.soundVolume/100
	self.currentMusicVolume = self.musicVolume

	self.music = {
		menuMusic = "sound/music/menu_music.mp3",
		bossMusic = "sound/music/boss_music.mp3",
	}
	self.sounds = {
		uiClick = "sound/click4-2.wav",
		uiHover = "sound/rollover5-2.wav",
		shoot = "sound/shoot.wav",
		hit = "sound/hit.wav",
		hitTank = "sound/hit_tank.wav",
		bossIncoming = "sound/bossIncoming.wav",
		death = "sound/Randomize125.wav",
	}
	for i, sound in pairs(self.music) do
		self.music[i] = love.audio.newSource(sound)
		self.music[i]:setVolume(self.musicVolume)
		self.music[i]:setLooping(true)
	end
	for i, sound in pairs(self.sounds) do
		self.sounds[i] = love.audio.newSource(sound)
		self.sounds[i]:setVolume(self.soundVolume)
	end

    self.enemyDeathObserver = signal.register('enemyDeath', function(enemy) self:onEnemyDeath(enemy) end)
    self.enemyHitObserver = signal.register('enemyHit', function(enemy) self:onEnemyHit(enemy) end)
    self.playerShootObserver = signal.register('playerShot', function() self:onPlayerShoot() end)
    self.uiClick = signal.register('uiClick', function() self:onUiClick() end)
    self.uiHover = signal.register('uiHover', function() self:onUiHover() end)
    self.soundChangeObserver = signal.register('soundChanged', function(v) self:onSoundVolumeChanged(v) end)
    self.musicChangeObserver = signal.register('musicChanged', function(v) self:onMusicVolumeChanged(v) end)
    self.menuObserver = signal.register('menuEntered', function() self:onMenuEnter() end)
    self.bossIncoming = signal.register('bossIncoming', function() self:onBossIncoming() end)
    self.bossSpawn = signal.register('bossSpawned', function() self:onBossSpawn() end)
    self.newGame = signal.register('newGame', function() self:onNewGame() end)

end

function Sound:update(dt)
	if self.musicTween then
		self.currentMusic:setVolume(self.currentMusicVolume)
	else
		self.currentMusic:setVolume(self.musicVolume)
	end
end

function Sound:onSoundVolumeChanged(volume)
	for i, sound in pairs(self.sounds) do
		sound:setVolume(volume)
	end
end

function Sound:onMusicVolumeChanged(volume)
	for i, sound in pairs(self.music) do
		sound:setVolume(volume)
	end
end

function Sound:onPlayerShoot()
	self.sounds.shoot:play()
end

function Sound:onEnemyDeath(enemy)
	self.sounds.death:play()
end

function Sound:onEnemyHit(enemy)
	if enemy:isInstanceOf(Tank) then
		self.sounds.hitTank:play()
		self.sounds.hitTank:setPitch(1.0 + math.random(-25, 25)/100)
	else
		self.sounds.hit:play()
		self.sounds.hit:setPitch(1.0 + math.random(-25, 25)/100)
	end
end

function Sound:onUiClick(enemy)
	self.sounds.uiClick:play()
end

function Sound:onUiHover(enemy)
	self.sounds.uiHover:play()
end

function Sound:onNewGame()
	if self.currentMusic == self.music.menuMusic then return end

	self.musicTween = tween(1, self, {currentMusicVolume=0}, nil, function()
		self.currentMusic:stop()
		self.currentMusic = self.music.menuMusic
		self.currentMusic:play()
		self.musicTween = nil
	end)
end

function Sound:onMenuEnter()
	if self.currentMusic == nil then
		self.currentMusic = self.music.menuMusic
		self.currentMusic:play()
	end
end

function Sound:onBossSpawn()
	
end

function Sound:onBossIncoming()
	self.musicTween = tween(1, self, {currentMusicVolume=0}, nil, function()
		self.currentMusic:stop()
		self.currentMusic = self.music.bossMusic
		self.currentMusic:play()
		self.musicTween = nil
	end)
	self.sounds.bossIncoming:play()
end

function Sound:draw()

end