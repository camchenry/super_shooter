-- libraries
class = require 'libs.class'
vector = require 'libs.vector'
state = require 'libs.state'
tween = require 'libs.tween'
cron = require 'libs.cron'
shine = require 'libs.shine'
signal = require 'libs.signal'
serialize = require 'libs.ser'
husl = require 'libs.husl'
Camera = require 'libs.camera'
bump = require 'libs.bump'
require 'libs.util'

-- gamestates
require 'states.menu'
require 'states.game'
require 'states.options'
require 'states.pause'
require 'states.gameover'
require 'states.restart'
require 'states.charselect'
require 'states.highscoreList'
require 'states.info'
require 'states.credits'
require 'states.modeselect'

-- entities
require 'entities.entity'
require 'entities.bullet'
require 'entities.player'
require 'entities.enemy.enemy'
require 'entities.enemy.blob'
require 'entities.enemy.healer'
require 'entities.enemy.tank'
require 'entities.enemy.sweeper'
require 'entities.enemy.ninja'

-- bosses
require 'entities.boss.megabyte'

-- visual effects
require 'entities.fx.particle'
require 'entities.fx.shake'
require 'entities.fx.hurt'
require 'entities.fx.background'
require 'entities.fx.floating'

-- sound effects
require 'entities.sound.sound'

-- high score
require 'entities.highscore.highscore'

-- ui elements
require 'entities.ui.button'
require 'entities.ui.checkbox'
require 'entities.ui.input'
require 'entities.ui.list'
require 'entities.ui.slider'

-- game modes
require 'entities.mode.gamemode'
require 'entities.mode.survival'

function love.load()
	love.window.setTitle(config.windowTitle)
    love.window.setIcon(love.image.newImageData(config.windowIcon))
	love.graphics.setDefaultFilter(config.filterModeMin, config.filterModeMax, config.anisotropy)
    love.graphics.setFont(font[16])

    math.randomseed(os.time()/10)

    crosshairImage = love.graphics.newImage("img/crosshair.png")
    cursorImage = love.graphics.newImage("img/cursor.png")
    crosshair = love.mouse.newCursor(crosshairImage:getData(), 16, 16)
    cursor = love.mouse.newCursor(cursorImage:getData(), 0, 0)
    love.mouse.setCursor(cursor)

    -- Sound is instantiated before the game because it observes things beyond the game scope
    soundControl = Sound:new()

    if love.filesystem.exists("config.txt") then
        options:load()
    end

    highscoreList:initializeScores()

    state.registerEvents()
    state.switch(menu)
end

function love.keypressed(key, code)

end

function love.mousepressed(x, y, mbutton)

end

function love.textinput(text)
end

function love.resize(w, h)

end

function love.update(dt)
    tween.update(dt)
    soundControl:update(dt)
end

function love.draw()

end
