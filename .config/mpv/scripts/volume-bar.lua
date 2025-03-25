local mp = require 'mp'
local options = require 'mp.options'
local assdraw = require 'mp.assdraw'

-- Default options
local opts = {
    -- Position
    position = "top-right",
    margin_x = 20,
    margin_y = 20,
    
    -- Style
    bar_width = 200,
    bar_height = 4,
    bar_radius = 2,
    bar_color = "FFFFFF",
    bar_alpha = 0.8,
    bar_bg_color = "000000",
    bar_bg_alpha = 0.3,
    
    -- Animation
    animation_duration = 0.2,
    fadeout_duration = 0.5,
    show_on_change = true,
    
    -- Text
    show_text = true,
    text_size = 24,
    text_color = "FFFFFF",
    text_alpha = 0.9,
    text_margin = 10,
}

-- Load options from mpv.conf
options.read_options(opts, "volume-bar")

-- State
local state = {
    volume = 0,
    visible = false,
    last_show = 0,
    animation_start = 0,
    fadeout_start = 0,
}

-- Helper functions
local function get_volume()
    return mp.get_property_number("volume", 0)
end

local function get_position()
    local w, h = mp.get_osd_size()
    local x, y = 0, 0
    
    if opts.position == "top-right" then
        x = w - opts.bar_width - opts.margin_x
        y = opts.margin_y
    elseif opts.position == "top-left" then
        x = opts.margin_x
        y = opts.margin_y
    elseif opts.position == "bottom-right" then
        x = w - opts.bar_width - opts.margin_x
        y = h - opts.bar_height - opts.margin_y
    elseif opts.position == "bottom-left" then
        x = opts.margin_x
        y = h - opts.bar_height - opts.margin_y
    end
    
    return x, y
end

local function draw_volume_bar()
    local ass = assdraw:ass_new()
    local x, y = get_position()
    local volume = get_volume()
    local current_time = mp.get_time()
    
    -- Calculate animation progress
    local anim_progress = 1
    if current_time - state.animation_start < opts.animation_duration then
        anim_progress = (current_time - state.animation_start) / opts.animation_duration
    end
    
    -- Calculate fadeout progress
    local fade_progress = 1
    if current_time - state.fadeout_start < opts.fadeout_duration then
        fade_progress = (current_time - state.fadeout_start) / opts.fadeout_duration
    end
    
    -- Apply animations
    local alpha = opts.bar_alpha * fade_progress
    local text_alpha = opts.text_alpha * fade_progress
    
    -- Draw background
    ass:new_event()
    ass:append(string.format("{\\pos(%d,%d)\\bord0\\shad0\\c&H%s&\\alpha&H%02X&}", 
        x, y, opts.bar_bg_color, opts.bar_bg_alpha * 255))
    ass:append(string.format("{\\rDefault\\p1}m 0 0 l %d 0 l %d %d l 0 %d", 
        opts.bar_width, opts.bar_width, opts.bar_height, opts.bar_height))
    
    -- Draw volume bar with rounded corners
    local bar_width = opts.bar_width * (volume / 100) * anim_progress
    if bar_width > 0 then
        ass:new_event()
        ass:append(string.format("{\\pos(%d,%d)\\bord0\\shad0\\c&H%s&\\alpha&H%02X&}", 
            x, y, opts.bar_color, alpha * 255))
        ass:append(string.format("{\\rDefault\\p1}m %d %d q %d %d %d %d l %d %d q %d %d %d %d l %d %d", 
            opts.bar_radius, opts.bar_height/2,
            opts.bar_radius, 0, 0, 0,
            bar_width - opts.bar_radius, 0,
            bar_width, 0, bar_width, opts.bar_radius,
            bar_width, opts.bar_height))
    end
    
    -- Draw volume text
    if opts.show_text then
        ass:new_event()
        ass:append(string.format("{\\pos(%d,%d)\\fs%d\\c&H%s&\\alpha&H%02X&}", 
            x + opts.bar_width + opts.text_margin, y - opts.text_size/2,
            opts.text_size, opts.text_color, text_alpha * 255))
        ass:append(string.format("%d%%", volume))
    end
    
    mp.set_osd_ass(0, 0, ass.text)
end

-- Event handlers
local function volume_changed()
    state.volume = get_volume()
    state.visible = true
    state.last_show = mp.get_time()
    state.animation_start = mp.get_time()
    state.fadeout_start = mp.get_time() + 1.0
end

local function tick()
    local current_time = mp.get_time()
    
    if state.visible then
        if current_time > state.fadeout_start then
            state.visible = false
        end
        draw_volume_bar()
    end
end

-- Register events
mp.observe_property("volume", "number", volume_changed)
mp.add_periodic_timer(0.016, tick) -- ~60fps

-- Initial draw
volume_changed() 