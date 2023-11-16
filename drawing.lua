local draw_data = {
    score = nil,
    accuracy = nil,
    crit = nil,
    grade = nil
}

set_callback(function(draw_ctx)
    if draw_data.accuracy then
		draw_ctx:draw_text(-0.8, 0.85, 48.0, draw_data.accuracy.."%", rgba(255, 255, 255, 255))
    end
    if draw_data.score then
		draw_ctx:draw_text(0.65, 0.85, 48.0, draw_data.score, rgba(255, 255, 255, 255))
    end
    if draw_data.crit then
        local x, y = draw_text_size(48.0, draw_data.crit)
		draw_ctx:draw_text(0 - x/2, 0 - y/2, 48.0, draw_data.crit, rgba(255, 255, 255, 255))
    end
    if draw_data.grade then
		draw_ctx:draw_text(-0.9, 0.85, 60.0, draw_data.grade, rgba(255, 255, 255, 255))
    end
end, ON.GUIFRAME)

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
    elseif (acc > 95) then
        grade = "S"
    elseif (acc > 90) then
        grade = "A"
    elseif (acc > 80) then
        grade = "B"
    elseif (acc > 70) then
        grade = "C"
    elseif (acc > 60) then
        grade = "D"
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
        grade = nil
    }
end

return {
    set_score = set_score,
    set_accuracy = set_accuracy,
    set_crit = set_crit,
    set_grade = set_grade,
    reset_draw_data = reset_draw_data
}