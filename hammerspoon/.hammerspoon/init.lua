hs.loadSpoon("SpoonInstall")

spoon.SpoonInstall.use_syncinstall = true

Install = spoon.SpoonInstall

-- function appID(app)
--     return hs.application.infoForBundlePath(app)['CFBundleIdentifier']
-- end
--
-- arcBrowser = appID("/Applications/Arc.app")
-- safariBrowser = appID("/Applications/Safari.app")
--
-- DefaultBrowser = safariBrowser
-- WorkBrowser = arcBrowser

-- Install:andUse("URLDispatcher", {
--     config = {
--         url_patterns = {
--             { "msteams:",                     "com.microsoft.teams" },
--             { "https?://.*%.cloudferro%.com", WorkBrowser },
--         },
--         url_redir_decoder = {
--             { "MS Teams URLs", "(https://teams.microsoft.com.*)", "msteams:%1", true },
--         },
--         default_handler = DefaultBrowser,
--     },
--     start = true,
-- })

local function reload_config(files)
    local should_reload = false
    for _, file in pairs(files) do
        if file:sub(-4) == ".lua" then
            should_reload = true
        end
    end

    if should_reload then
        hs.reload()
    end
end

local function current_artist()
    local artist = hs.itunes.getCurrentArtist()
    local track = hs.itunes.getCurrentTrack()
    hs.notify.show("Notification", artist .. " - " .. track)
end

-- hs.urlevent.httpCallback = function(scheme, host, params, fullURL)
--     if host == nil then
--         host = 'file'
--     end
--
--     local success, _, res = hs.osascript.applescript('choose from list {"Safari", "Arc"} with prompt "Open ' ..
--     host .. ' with...');
--     local app
--     if success and res:match("Safari") then
--         app = "com.apple.Safari"
--     elseif success and res:match("Arc") then
--         app = "com.arc.Browser"
--     else
--         return
--     end
--     hs.urlevent.openURLWithBundle(fullURL, app)
-- end

-- Must be global to not be removed by GC
ReloadWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "./hammerspoon/", reload_config)
ReloadWatcher:start()

hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "r", function()
    hs.reload()
end)

Apps = {
    { "1", "Helium" },
    { "2", "Ghostty" },
    { "4", "Microsoft Teams" },
    { "3", "Slack" },
}

for _, app in ipairs(Apps) do
    hs.hotkey.bind({ "cmd" }, app[1], function()
        hs.application.launchOrFocus(app[2]);
    end)
end

hs.alert.show("Config loaded")
