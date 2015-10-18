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

	self.music = {
		menuMusic = "sound/music/menu_music.mp3"
	}
	self.sounds = {
		uiClick = "sound/click4-2.wav",
		uiHover = "sound/rollover5-2.wav",
		shoot = "sound/shoot.wav",
		hit = "sound/hit.wav",
		hitTank = "sound/hit_tank.wav",
		death = "sound/death2.wav",
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
end

function Sound:update(dt)
	
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
	else
		self.sounds.hit:play()
	end
end

function Sound:onUiClick(enemy)
	self.sounds.uiClick:play()
end

function Sound:onUiHover(enemy)
	self.sounds.uiHover:play()
end

function Sound:onMenuEnter()
	self.currentMusic = self.music.menuMusic
	self.currentMusic:play()
end

function Sound:draw()

end