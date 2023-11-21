MapResults = {}

function MapResults.create(score, highest_crit)
    local self = setmetatable({}, MapResults)
    self.score = tostring(score)
    self.highest_crit = tostring(highest_crit)
    self.date_time = tostring(os.date("%A, %m %B %Y"))
    return self
end

return MapResults