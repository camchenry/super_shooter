-- libraries
class = require 'libs.class'
vector = require 'libs.vector'
state = require 'libs.state'
tween = require 'libs.tween'
cron = require 'libs.cron'
shine = require 'libs.shine'
signal = require 'libs.signal'
QuadTree = require 'libs.quadtree'
serialize = require 'libs.ser'
husl = require 'libs.husl'
require 'libs.util'

-- gamestates
require 'states.menu'
require 'states.game'
require 'states.options'
require 'states.pause'
require 'states.gameover'
require 'states.restart'
require 'states.charselect'

-- entities
require 'entities.entity'
require 'entities.bullet'
require 'entities.player'
require 'entities.enemy'
-- bosses
require 'entities.boss.megabyte'
require 'entities.boss.arena'
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

    soundControl = Sound:new()
	highScore = HighScore:new()

    if love.filesystem.exists("config.txt") then
        options:load()
    end

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