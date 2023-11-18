local draw_data = {
    score = nil,
    accuracy = nil,
    crit = nil,
    grade = nil,
    grade_color = rgba(255, 255, 255, 255),
    in_level = false,
    open_menu = false,
}

set_callback(function(draw_ctx)
    if game_manager.pause_ui.visibility == 0 then
        if draw_data.in_level then
            local x18 = screen_position(18,0)
            local x19 = screen_position(19,0)
            draw_ctx:draw_line(x18, 1, x18, -1, 3, rgba(255, 255, 255, 255))
            draw_ctx:draw_line(x19, 1, x19, -1, 3, rgba(255, 255, 255, 255))
        end
        if draw_data.accuracy then
            draw_ctx:draw_text(-0.8, 0.85, 48.0, draw_data.accuracy.."%", rgba(255, 255, 255, 255))
        end
        if draw_data.score then
            draw_ctx:draw_text(0.65, 0.85, 48.0, draw_data.score, rgba(255, 255, 255, 255))
        end
        if draw_data.crit then
            local x, y = draw_text_size(64.0, draw_data.crit)
            draw_ctx:draw_text(0 - x/2, 0 - y/2, 64.0, draw_data.crit, rgba(255, 255, 255, 255))
        end
        if draw_data.grade then
            draw_ctx:draw_text(-0.9, 0.85, 60.0, draw_data.grade, draw_data.grade_color)
        end 
        if draw_data.open_menu then
            draw_ctx:draw_rect_filled(-0.8, 0.8, 0.8, -0.8, 0.0, rgba(0, 0, 0, 180))
        end
    end
end, ON.GUIFRAME)

local function initialize()
    draw_data.in_level = true
end

local function set_score(score)
    if type(score) ~= "string" then return end
    draw_data.score = score
    while string.len(draw_data.score) ~= 6 do
        draw_data.score = "0"..draw_data.score
    end
end

local function set_grade(accuracy)
    if type(accuracy) ~= "string" then return end
    local acc = tonumber(accuracy)
    local grade
    if (acc > 99) then
        grade = "X"
        draw_data.grade_color = rgba(227, 277, 216, 255)
    elseif (acc > 95) then
        grade = "S"
        draw_data.grade_color = rgba(245, 200, 20, 255)
    elseif (acc > 90) then
        grade = "A"
        draw_data.grade_color = rgba(65, 191, 15, 255)
    elseif (acc > 80) then
        grade = "B"
        draw_data.grade_color = rgba(15, 177, 191, 255)
    elseif (acc > 70) then
        grade = "C"
        draw_data.grade_color = rgba(201, 28, 175, 255)
    elseif (acc > 60) then
        grade = "D"
        draw_data.grade_color = rgba(201, 28, 46, 255)
    end
    draw_data.grade = grade
end

local function set_accuracy(accuracy)
    if type(accuracy) ~= "string" then return end
    set_grade(accuracy)
    draw_data.accuracy = accuracy
end

local function set_crit(crit)
    if type(crit) ~= "string" then return end
    draw_data.crit = crit
end

local function reset_draw_data()
    draw_data = {
        score = nil,
        accuracy = nil,
        crit = nil,
        grade = nil,
        grade_color = rgba(255, 255, 255, 255),
        in_level = false,
        open_menu = false,
    }
end

local function open_menu(on)
    if on then
        draw_data.open_menu = true
    else
        draw_data.open_menu = false
    end
end

return {
    set_score = set_score,
    set_accuracy = set_accuracy,
    set_crit = set_crit,
    set_grade = set_grade,
    reset_draw_data = reset_draw_data,
    initialize = initialize,
    open_menu = open_menu,
}