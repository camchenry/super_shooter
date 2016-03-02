function love.conf(t)
	if love._version_minor <= 9 then
        error("This game is designed for Love2D 0.10.0 and up, you are running:"..love._version_major.."."..love._version_minor.."."..love._version_revision)
    end

    t.identity = "super_shooter"                    -- The name of the save directory (string)
    t.version = "0.10.0"                -- The LÖVE version this game was made for (string)
    t.console = true                   -- Attach a console (boolean, Windows only)
    t.accelerometerjoystick = false     -- Enable the accelerometer on iOS and Android by exposing it as a Joystick (boolean)
    t.gammacorrect = false              -- Enable gamma-correct rendering, when supported by the system (boolean)
 
    t.window.title = "Super Shooter"         -- The window title (string)
    t.window.icon = nil                 -- Filepath to an image to use as the window's icon (string)
    t.window.width = 1024               -- The window width (number)
    t.window.height = 768               -- The window height (number)
    t.window.borderless = false         -- Remove all border visuals from the window (boolean)
    t.window.resizable = false          -- Let the window be user-resizable (boolean)
    t.window.minwidth = 1               -- Minimum window width if the window is resizable (number)
    t.window.minheight = 1              -- Minimum window height if the window is resizable (number)
    t.window.fullscreen = false         -- Enable fullscreen (boolean)
    t.window.fullscreentype = "exclusive" -- Choose between "desktop" fullscreen or "exclusive" fullscreen mode (string)
    t.window.vsync = true               -- Enable vertical sync (boolean)
    t.window.msaa = 0                   -- The number of samples to use with multi-sampled antialiasing (number)
    t.window.display = 1                -- Index of the monitor to show the window in (number)
    t.window.highdpi = false            -- Enable high-dpi mode for the window on a Retina display (boolean)
    t.window.x = nil                    -- The x-coordinate of the window's position in the specified display (number)
    t.window.y = nil                    -- The y-coordinate of the window's position in the specified display (number)
 
    t.modules.audio = true              -- Enable the audio module (boolean)
    t.modules.event = true              -- Enable the event module (boolean)
    t.modules.graphics = true           -- Enable the graphics module (boolean)
    t.modules.image = true              -- Enable the image module (boolean)
    t.modules.joystick = true           -- Enable the joystick module (boolean)
    t.modules.keyboard = true           -- Enable the keyboard module (boolean)
    t.modules.math = true               -- Enable the math module (boolean)
    t.modules.mouse = true              -- Enable the mouse module (boolean)
    t.modules.physics = true            -- Enable the physics module (boolean)
    t.modules.sound = true              -- Enable the sound module (boolean)
    t.modules.system = true             -- Enable the system module (boolean)
    t.modules.timer = true              -- Enable the timer module (boolean), Disabling it will result 0 delta time in love.update
    t.modules.touch = true              -- Enable the touch module (boolean)
    t.modules.video = true              -- Enable the video module (boolean)
    t.modules.window = true             -- Enable the window module (boolean)
    t.modules.thread = true             -- Enable the thread module (boolean)
end

config = {
    gameTitle = "super shooter",
    windowTitle = "super shooter",
    windowIcon = 'img/icon.png',

    -- see: http://love2d.org/wiki/love.graphics.setDefaultFilter
    filterModeMin = "nearest",
    filterModeMax = "nearest",
    anisotropy = 4,

    font = 'fonts/Lato-Regular.ttf',
    fontBold = 'fonts/Lato-Bold.ttf',
    fontLight = 'fonts/Lato-Light.ttf',
}

font = setmetatable({}, {
    __index = function(t,k)
        local f = love.graphics.newFont(config.font, k)
        rawset(t, k, f)
        return f
    end 
})

fontBold = setmetatable({}, {
    __index = function(t,k)
        local f = love.graphics.newFont(config.fontBold, k)
        rawset(t, k, f)
        return f
    end
})

fontLight = setmetatable({}, {
    __index = function(t,k)
        local f = love.graphics.newFont(config.fontLight, k)
        rawset(t, k, f)
        return f
    end 
})