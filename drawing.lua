local draw_data = {
    score = nil,
    accuracy = nil,
    crit = nil,
    grade = nil,
    grade_color = rgba(255, 255, 255, 255),
    hit_grade = nil,
    hit_grade_color = rgba(255, 255, 255, 255),
    in_level = false,
    is_beating_save = nil,
    -- save data specific
    save_score = nil,
    save_hc = nil,
    save_date = nil,
}

local function bn(bool)
    return bool and 1 or 0
end

set_callback(function(draw_ctx)
    if game_manager.pause_ui.visibility == 0 and state.screen == 12 then
        if draw_data.in_level then
            local x18 = screen_position(18.3,0)
            local x19 = screen_position(19.3,0)
            draw_ctx:draw_line(x18, 1, x18, -1, 3, rgba(255, 255, 255, 255))
            draw_ctx:draw_line(x19, 1, x19, -1, 3, rgba(255, 255, 255, 255))
        end
        if draw_data.accuracy then
            draw_ctx:draw_text(-0.8, 0.85, 48.0, draw_data.accuracy.."%", rgba(255, 255, 255, 255))
        end
        if draw_data.score then
            draw_ctx:draw_text(0.65, 0.85, 48.0, draw_data.score, rgba(255, 255, 255, 255))
        end
        if draw_data.crit and draw_data.hit_grade then
            local x1, y1 = draw_text_size(48.0, draw_data.hit_grade)
            local x2, y2 = draw_text_size(64.0, draw_data.crit)
            draw_ctx:draw_text(0 - x1/2, 0 - y1/2 + 0.05, 48.0, draw_data.hit_grade, draw_data.hit_grade_color)
            draw_ctx:draw_text(0 - x2/2, 0 - y2/2 - 0.05, 64.0, draw_data.crit, rgba(255, 255, 255, 255))
        end
        if draw_data.grade then
            draw_ctx:draw_text(-0.9, 0.85, 60.0, draw_data.grade, draw_data.grade_color)
        end
        if draw_data.is_beating_save ~= nil then
            draw_ctx:draw_text(-0.95, -0.73, 32.0, "Highscore", rgba(255 - (bn(draw_data.is_beating_save) * 255), 255, 255 - (bn(draw_data.is_beating_save) * 255), 100))
            if not draw_data.is_beating_save then
                draw_ctx:draw_text(-0.95, -0.80, 20.0, F"Score: {draw_data.save_score}\nMax Crit: {draw_data.save_hc}\n{draw_data.save_date}", rgba(255, 255, 255, 100))
            else
                local date = tostring(os.date("%A, %m %B %Y"))
                draw_ctx:draw_text(-0.95, -0.80, 20.0, F"Score: {draw_data.score}\nMax Crit: {draw_data.crit}\n{date}", rgba(0, 255, 0, 100))
            end
        end
    end
end, ON.GUIFRAME)

local function initialize()
    draw_data.in_level = true
end

local function set_score(score)

    if type(score) ~= "string" then return end
    draw_data.score = score

    if draw_data.save_score then
        if tonumber(score) > tonumber(draw_data.save_score) then
            draw_data.is_beating_save = true
        else
            draw_data.is_beating_save = false
        end
    end

    if string.len(draw_data.score) >= 6 then return end
    while string.len(draw_data.score) < 6 do
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

local function set_save_data(score, hc, date)
    if type(score) ~= "string" or type(hc) ~= "string" or type(date) ~= "string" then return end
    draw_data.save_score = score
    draw_data.save_hc = hc
    draw_data.save_date = date
end

local function set_is_beating_save(is_beating_save)
    if type(is_beating_save) ~= "boolean" then return end
    draw_data.is_beating_save = is_beating_save
end

local function get_is_beating_save()
    return draw_data.is_beating_save
end

local function set_hit_grade(hit_grade)
    if type(hit_grade) ~= "string" then return end
    draw_data.hit_grade = hit_grade
end

local function set_hit_grade_color(rgba)
    draw_data.hit_grade_color = rgba
end

local function reset_draw_data()
    draw_data = {
        score = nil,
        accuracy = nil,
        crit = nil,
        grade = nil,
        grade_color = rgba(255, 255, 255, 255),
        hit_grade = nil,
        hit_grade_color = rgba(255, 255, 255, 255),
        in_level = false,
        is_beating_save = nil,
        save_score = nil,
        save_hc = nil,
        save_date = nil
    }
end

return {
    set_score = set_score,
    set_accuracy = set_accuracy,
    set_crit = set_crit,
    set_grade = set_grade,
    reset_draw_data = reset_draw_data,
    initialize = initialize,
    set_save_data = set_save_data,
    set_hit_grade = set_hit_grade,
    set_hit_grade_color = set_hit_grade_color,
    set_is_beating_save = set_is_beating_save,
    get_is_beating_save = get_is_beating_save,
}