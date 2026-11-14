-- eDP-1 fallback: abaikan "eDP-1 disabled" (dari nwg-displays) jika tidak ada monitor eksternal
local INTERNAL = "eDP-1"

local function has_external()
    for _, m in ipairs(hl.get_monitors({ all = true }) or {}) do
        if m.name ~= INTERNAL and m.name ~= "FALLBACK" and not m.name:match("^HEADLESS") then return true end
    end
    return false
end

local orig_monitor = hl.monitor
hl.monitor = function(spec)
    if spec and spec.output == INTERNAL and spec.disabled and not has_external() then
        return orig_monitor({ output = INTERNAL, mode = "preferred", position = "auto", scale = 1 })
    end
    return orig_monitor(spec)
end

local function on_change(m)
    if m and (m.name == INTERNAL or m.name == "FALLBACK" or m.name:match("^HEADLESS")) then return end
    hl.exec_cmd("sleep 0.5; hyprctl reload")
end
hl.on("monitor.added", on_change)
hl.on("monitor.removed", on_change)
