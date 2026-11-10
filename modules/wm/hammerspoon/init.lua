-- AeroSpace Trackpad Gesture Integration via Hammerspoon
-- 3本指スワイプ: ワークスペース切り替え (左: prev / 右: next)
-- 4本指スワイプ: フォーカスウィンドウを連れて移動 (左: prev / 右: next)
-- 4本指下スワイプ: ウィンドウ/タブを確実に閉じる (Cmd+W -> 閉じなければ AeroSpace close)
-- 右手特化タップ (右利き用・左側の誤爆防止):
--   右上の角: コピー (Cmd + C -> Copied)
--   右下の角: ペースト (Cmd + V -> Pasted)
-- エッジスクロール (右端を指1本でなぞる):
--   右端を上下になぞる: 音量調整 (macOS標準HUD表示付き)

-- Hammerspoon CLI (hs) および AppleScript の外部制御を許可
pcall(require, "hs.ipc")
hs.allowAppleScript(true)
hs.dockicon.hide()
hs.autoLaunch(true)

-- スタイリッシュでミニマルな HUD スタイル (壁紙の抽出色に動的追従)
local alertStyle = {
    strokeWidth  = 0,
    strokeColor = { white = 0, alpha = 0 },
    fillColor   = { white = 0.08, alpha = 0.85 },
    textColor   = { white = 0.95, alpha = 1.0 },
    textFont    = ".AppleSystemUIFont",
    textSize    = 15,
    radius      = 10,
    atScreenEdge = 0,
    fadeInDuration  = 0.08,
    fadeOutDuration = 0.2
}

-- Matugen パレット (~/.cache/matugen/colors.lua) から triad (120度回転色) を読み込み反映
local function updateAlertStyle()
    local colorsPath = os.getenv("HOME") .. "/.cache/matugen/colors.lua"
    local f = loadfile(colorsPath)
    if not f then return end
    local ok, colors = pcall(f)
    if not ok or type(colors) ~= "table" then return end

    -- 壁紙から抽出した色相120度回転色 (triad: ウィンドウ枠線やmacOSハイライト色と同色)
    local bgHex = colors.triad or colors.complement or colors.accent
    if bgHex then
        alertStyle.fillColor = { hex = bgHex, alpha = 0.90 }

        -- 背景色の明度 (luminance) を計算し、常に高コントラストな文字色を選択
        local c = hs.drawing.color.asRGB({ hex = bgHex, alpha = 1.0 })
        if c and c.red and c.green and c.blue then
            local lum = 0.299 * c.red + 0.587 * c.green + 0.114 * c.blue
            if lum > 0.55 then
                alertStyle.textColor = { hex = colors.surface or "#18120c", alpha = 1.0 }
            else
                alertStyle.textColor = { hex = colors.text or "#ffffff", alpha = 1.0 }
            end
        end
    end
end

-- 初期ロード時にスタイルを適用
updateAlertStyle()

-- colors.lua の変更を自動監視してスタイルを動的更新
colorsWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.cache/matugen", function(files)
    for _, file in ipairs(files) do
        if file:match("colors%.lua$") then
            updateAlertStyle()
            break
        end
    end
end)
colorsWatcher:start()

function showHUD(text)
    updateAlertStyle()
    hs.alert.show(text, alertStyle, 0.35)
end

local AEROSPACE = "/opt/homebrew/bin/aerospace"
local gesture = hs.eventtap.event.types.gesture

local touchTracker = {
    active = false,
    startTime = 0,
    startX = 0,
    startY = 0,
    lastY = 0,
    edge = nil, -- "right" (音量), "left" (輝度)
    accumulatedDelta = 0,
    didSlide = false,
    moved = false,
    lastTriggered = 0,
    maxFingers = 0
}

local function handleEdgesAndTaps(touches)
    local now = hs.timer.secondsSinceEpoch()
    local n = #touches

    if n > 0 then
        if not touchTracker.active then
            touchTracker.active = true
            touchTracker.startTime = now
            touchTracker.maxFingers = n
            local t = touches[1]
            local x = t.normalizedPosition.x
            local y = t.normalizedPosition.y
            touchTracker.startX = x
            touchTracker.startY = y
            touchTracker.lastY = y
            touchTracker.accumulatedDelta = 0
            touchTracker.didSlide = false
            touchTracker.moved = false

            -- 1本指で右端からスタートした場合のみ音量調整 (左端は誤爆防止のため無効化)
            if n == 1 and x >= 0.93 then
                touchTracker.edge = "right"   -- 音量
            else
                touchTracker.edge = nil
            end
        else
            if n > touchTracker.maxFingers then
                touchTracker.maxFingers = n
            end

            -- 指の移動距離チェック (タップ判定用: 0.05まで許容)
            local t = touches[1]
            local dx = math.abs(t.normalizedPosition.x - touchTracker.startX)
            local dy = math.abs(t.normalizedPosition.y - touchTracker.startY)
            if dx > 0.05 or dy > 0.05 then
                touchTracker.moved = true
            end

            -- エッジスライド処理 (1本指: 右端の音量調整のみ)
            if n == 1 and touchTracker.edge == "right" then
                local y = t.normalizedPosition.y
                local deltaY = y - touchTracker.lastY
                touchTracker.lastY = y
                touchTracker.accumulatedDelta = touchTracker.accumulatedDelta + deltaY

                local step = 0.04
                if math.abs(touchTracker.accumulatedDelta) >= step then
                    touchTracker.didSlide = true
                    if touchTracker.accumulatedDelta > 0 then
                        hs.eventtap.event.newSystemKeyEvent("SOUND_UP", true):post()
                        hs.eventtap.event.newSystemKeyEvent("SOUND_UP", false):post()
                    else
                        hs.eventtap.event.newSystemKeyEvent("SOUND_DOWN", true):post()
                        hs.eventtap.event.newSystemKeyEvent("SOUND_DOWN", false):post()
                    end
                    touchTracker.accumulatedDelta = 0
                end
            end
        end
    elseif n == 0 then
        -- 指が離れた (タップ判定)
        if touchTracker.active then
            local duration = now - touchTracker.startTime
            local x = touchTracker.startX
            local y = touchTracker.startY
            local didSlide = touchTracker.didSlide
            local moved = touchTracker.moved
            local maxF = touchTracker.maxFingers
            touchTracker.active = false

            -- 0.38秒以内のクイックタップ かつ スライドしていない
            -- 右利き特化: 左半分や上端中央・下端中央の誤爆要因を全廃し、右手で自然に届く右側のみに限定
            if not didSlide and not moved and duration > 0.03 and duration < 0.38 and (now - touchTracker.lastTriggered) > 0.30 then
                if maxF == 1 then
                    -- 1本指タップ
                    if y >= 0.75 then
                        -- 上端エリア: 右上の角のみ Copy (左上や上端中央は無効化)
                        if x >= 0.75 then
                            touchTracker.lastTriggered = now
                            hs.eventtap.keyStroke({"cmd"}, "c")
                            showHUD("Copied")
                        end
                    elseif y <= 0.25 then
                        -- 下端エリア: 右下の角のみ Paste (左下角・中央は無効化)
                        if x >= 0.75 then
                            touchTracker.lastTriggered = now
                            hs.eventtap.keyStroke({"cmd"}, "v")
                            showHUD("Pasted")
                        end
                    end
                end
            end
        end
    end
end

-- スワイプ検出器生成関数
local function createSwipeDetector(fingers, onLeft, onRight, onUp, onDown)
    local Cache = { id = 1, direction = nil, distance = 0, size = 0, touches = {} }
    local current_id = 0
    local base_threshold = 0.06
    local threshold = base_threshold

    local function clearCache()
        Cache.touches = {}
        Cache.size = 0
        Cache.direction = nil
        Cache.distance = 0
    end

    local function noneTouches(touches)
        for _, touch in ipairs(touches) do
            if Cache.touches[touch.identity] ~= nil then return false end
        end
        return true
    end

    local function allTouches(touches)
        for _, touch in ipairs(touches) do
            if Cache.touches[touch.identity] == nil then return false end
        end
        return true
    end

    local function setTouches(touches)
        clearCache()
        for i, touch in ipairs(touches) do
            Cache.touches[touch.identity] = {
                x = touch.normalizedPosition.x,
                y = touch.normalizedPosition.y,
                dx = 0,
                dy = 0,
            }
            Cache.size = i
        end
        Cache.id = Cache.id + 1
        return Cache.id
    end

    local function detectTouches(touches)
        local left, right, up, down = true, true, true, true
        local distance = { dx = 0, dy = 0 }
        local size = 0
        for i, touch in ipairs(touches) do
            local id = touch.identity
            local orig = Cache.touches[id]
            if not orig then return nil, 0, Cache.id end
            local x, y = touch.normalizedPosition.x, touch.normalizedPosition.y
            local dx, dy = x - orig.x, y - orig.y
            local abs_dx, abs_dy = math.abs(dx), math.abs(dy)
            local moved = (touch.phase == "moved")

            left = left and moved and (dx < 0) and (abs_dx > abs_dy)
            right = right and moved and (dx > 0) and (abs_dx > abs_dy)
            up = up and moved and (dy > 0) and (abs_dy > abs_dx)
            down = down and moved and (dy < 0) and (abs_dy > abs_dx)

            distance = { dx = distance.dx + dx, dy = distance.dy + dy }
            Cache.touches[id] = { x = x, y = y, dx = dx, dy = dy }
            size = i
        end

        if Cache.size ~= size or size == 0 then return nil, 0, Cache.id end
        distance = { dx = distance.dx / size, dy = distance.dy / size }

        local direction = nil
        if left and not (right or up or down) then
            direction = "left"
            if Cache.direction == direction then Cache.distance = Cache.distance - distance.dx end
        elseif right and not (left or up or down) then
            direction = "right"
            if Cache.direction == direction then Cache.distance = Cache.distance + distance.dx end
        elseif up and not (left or right or down) then
            direction = "up"
            if Cache.direction == direction then Cache.distance = Cache.distance + distance.dy end
        elseif down and not (left or right or up) then
            direction = "down"
            if Cache.direction == direction then Cache.distance = Cache.distance - distance.dy end
        end

        if direction and (Cache.direction ~= direction) then
            Cache.direction = direction
            Cache.distance = 0
        end

        return direction, Cache.distance, Cache.id
    end

    return function(touches)
        if #touches ~= fingers then return end

        if noneTouches(touches) then
            setTouches(touches)
        elseif allTouches(touches) then
            local direction, dist, id = detectTouches(touches)
            if direction then
                if id ~= current_id then
                    current_id = id
                    threshold = base_threshold
                end
                if dist > threshold then
                    threshold = math.huge
                    if direction == "left" and onLeft then
                        hs.timer.doAfter(0, onLeft)
                    elseif direction == "right" and onRight then
                        hs.timer.doAfter(0, onRight)
                    elseif direction == "down" and onDown then
                        hs.timer.doAfter(0, onDown)
                    end
                end
            end
        end
    end
end

-- 3本指スワイプ: ワークスペース移動
local handleThreeFingers = createSwipeDetector(3,
    function() hs.execute(AEROSPACE .. " workspace --no-stdin prev") end,
    function() hs.execute(AEROSPACE .. " workspace --no-stdin next") end
)

-- 4本指スワイプ: ウィンドウ連れて移動 & 下でウィンドウ/タブを閉じる (上は完全無効化)
local handleFourFingers = createSwipeDetector(4,
    function() hs.execute(AEROSPACE .. " move-node-to-workspace --no-stdin --focus-follows-window prev") end,
    function() hs.execute(AEROSPACE .. " move-node-to-workspace --no-stdin --focus-follows-window next") end,
    nil, -- 上は完全無効 (誤爆防止)
    function()
        local initialWin = hs.window.focusedWindow()
        local initialId = initialWin and initialWin:id() or nil
        hs.eventtap.keyStroke({"cmd"}, "w")

        hs.timer.doAfter(0.12, function()
            local currentWin = hs.window.focusedWindow()
            if currentWin and initialId and currentWin:id() == initialId then
                hs.execute(AEROSPACE .. " close")
            end
        end)
    end
)

trackpadWatcher = hs.eventtap.new({ gesture }, function(event)
    if event:getType(true) ~= gesture then return end
    local touches = event:getTouches()
    if touches then
        handleThreeFingers(touches)
        handleFourFingers(touches)
        handleEdgesAndTaps(touches)
    end
end)

trackpadWatcher:start()
