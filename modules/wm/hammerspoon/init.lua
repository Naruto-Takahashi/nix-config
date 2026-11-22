-- AeroSpace Trackpad Gesture Integration via Hammerspoon
-- 3本指スワイプ: ワークスペース切り替え (左: prev / 右: next)
-- 4本指スワイプ: フォーカスウィンドウを連れて移動 (左: prev / 右: next)
-- 4本指下スワイプ: ウィンドウ/タブを確実に閉じる (Cmd+W -> 閉じなければ AeroSpace close)
-- トラックパッドの角・上中央の物理クリック (1本指で押し込んだときだけ発火):
--   右上: コピー (Cmd+C, 結果が見えないので "Copied" を表示)
--   右下: ペースト (Cmd+V)
--   左下: 取り消し (Cmd+Z) / 左上: やり直し (Cmd+Shift+Z)
--   上中央: 範囲指定スクショ (Cmd+Shift+4)
--   ペースト・取り消し等は結果が画面に見えるため HUD は出さない
-- エッジスクロール (右端を指1本でなぞる):
--   右端を上下になぞる: 音量調整 (macOS標準HUD表示付き)

-- Hammerspoon CLI (hs) および AppleScript の外部制御を許可
pcall(require, "hs.ipc")
hs.allowAppleScript(true)
hs.dockicon.hide()
hs.autoLaunch(true)

-- HUD: 半透明の黒いカプセル + 白の細い縁線 + 柔らかい影 (macOS の音量 HUD に近い無彩色)
local hudCanvas, hudTimer
function showHUD(text)
    if hudTimer then hudTimer:stop(); hudTimer = nil end
    if hudCanvas then hudCanvas:delete(); hudCanvas = nil end

    local font = { name = ".AppleSystemUIFont", size = 15 }
    local styled = hs.styledtext.new(text, {
        font = font,
        color = { white = 1, alpha = 0.94 },
        paragraphStyle = { alignment = "center" },
    })
    local size = hs.drawing.getTextDrawingSize(styled)
    local pad, H, margin = 28, 44, 28          -- margin: 影のための余白
    local W = math.ceil(size.w) + pad * 2

    local f = hs.screen.mainScreen():frame()
    hudCanvas = hs.canvas.new({
        x = f.x + (f.w - W) / 2 - margin,
        y = f.y + f.h - H - 64 - margin,
        w = W + margin * 2, h = H + margin * 2,
    })
    hudCanvas:level(hs.canvas.windowLevels.overlay)
    hudCanvas:behavior({ "canJoinAllSpaces", "stationary" })
    hudCanvas:appendElements(
        { type = "rectangle", action = "strokeAndFill",
          frame = { x = margin, y = margin, w = W, h = H },
          roundedRectRadii = { xRadius = H / 2, yRadius = H / 2 },
          fillColor = { white = 0.12, alpha = 0.62 },
          strokeColor = { white = 1, alpha = 0.16 }, strokeWidth = 1,
          withShadow = true,
          shadow = { blurRadius = 18, color = { white = 0, alpha = 0.45 }, offset = { h = -6, w = 0 } } },
        { type = "text",
          frame = { x = margin, y = margin + (H - size.h) / 2, w = W, h = size.h + 2 },
          text = styled })
    hudCanvas:show(0.08)

    hudTimer = hs.timer.doAfter(0.7, function()
        local c = hudCanvas
        hudCanvas, hudTimer = nil, nil
        if c then c:hide(0.2); hs.timer.doAfter(0.3, function() c:delete() end) end
    end)
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
    maxFingers = 0,
    quietAtDown = false,  -- 指を置いた時点でカーソルが静止していたか
    resting = false,      -- 置きっぱなし(手のひら等)の接触が含まれたか
    volArmed = false,     -- 音量スライドが「意図した操作」と確定したか
    curCount = 0,         -- 現在の接触本数
    curX = 0, curY = 0,   -- 1本指のときの現在位置
    lastTouchEnd = 0,     -- 最後に全ての指が離れた時刻
    lastMultiTouch = 0    -- 最後に3本指以上が触れていた時刻
}

-- 角クリック(物理的な押し込み)の割り当て
local CORNER_ZONE = 0.20          -- 各角のエリアの大きさ (0〜1)
local CENTER_HALF_WIDTH = 0.15    -- 上中央エリアの半幅 (x が 0.5 ± この値)
local CURSOR_QUIET_SEC = 0.30   -- 指を置く直前にカーソルが動いていたら、音量スライドは開始しない
local TAP_CLICK_GRACE = 0.06      -- 指が離れた直後のクリックは「タップ」とみなして無視
-- 配置: 右列=クリップボード(上コピー/下ペースト)、左列=取り消し(下)/やり直し(上)、上中央=範囲スクショ
-- 下中央は通常クリックの領域なので未割り当て
local CORNER_ACTIONS = {
    topRight     = function() hs.eventtap.keyStroke({"cmd"}, "c"); showHUD("Copied") end,
    bottomRight  = function() hs.eventtap.keyStroke({"cmd"}, "v") end,
    bottomLeft   = function() hs.eventtap.keyStroke({"cmd"}, "z") end,
    topLeft      = function() hs.eventtap.keyStroke({"cmd", "shift"}, "z") end,
    topCenter    = function() hs.eventtap.keyStroke({"cmd", "shift"}, "4") end,
}

-- 音量スライドの誤爆対策パラメータ
local VOL_EDGE_X_MIN = 0.94     -- 右端エリア: x がこれ以上
local VOL_DEADZONE = 0.08       -- この縦移動量を超えるまで音量は変えない
local VOL_VERTICAL_RATIO = 2.0  -- 縦移動が横移動のこの倍以上のときだけ有効
local VOL_STEP = 0.04           -- 音量1段あたりの縦移動量

-- 3本指以上のあいだはスクロールをアプリに渡さない
-- (ブラウザ等の「横スクロール=戻る」が、3本指スワイプで誤爆するのを防ぐ)
-- 普段のスクロールが Hammerspoon を通らないよう、監視は3本指が触れている間だけ有効にする
local SCROLL_BLOCK_GRACE = 0.25   -- 指が離れた後の慣性スクロールも少し止める
local scrollStopTimer = nil

local function scrollBlockActive()
    local now = hs.timer.secondsSinceEpoch()
    return touchTracker.curCount >= 3 or (now - touchTracker.lastMultiTouch) < SCROLL_BLOCK_GRACE
end

scrollBlockTap = hs.eventtap.new({ hs.eventtap.event.types.scrollWheel }, function()
    return scrollBlockActive()
end)

local function scheduleScrollBlockStop()
    if scrollStopTimer then return end
    scrollStopTimer = hs.timer.doAfter(SCROLL_BLOCK_GRACE + 0.05, function()
        scrollStopTimer = nil
        if scrollBlockActive() then
            scheduleScrollBlockStop()   -- まだ3本指が触れている/直後なら延長
        else
            scrollBlockTap:stop()
        end
    end)
end

local cursorTracker = { pos = hs.mouse.absolutePosition(), lastMove = 0 }

local function handleEdgesAndTaps(touches)
    local now = hs.timer.secondsSinceEpoch()
    local n = #touches

    -- カーソルの最終移動時刻を更新 (ジェスチャーイベントごとに確認)
    local mp = hs.mouse.absolutePosition()
    if mp.x ~= cursorTracker.pos.x or mp.y ~= cursorTracker.pos.y then
        cursorTracker.pos = mp
        cursorTracker.lastMove = now
    end

    touchTracker.curCount = n
    if n >= 3 then
        touchTracker.lastMultiTouch = now
        if not scrollBlockTap:isEnabled() then scrollBlockTap:start() end
    elseif scrollBlockTap:isEnabled() then
        scheduleScrollBlockStop()
    end
    if n > 0 then
        touchTracker.curX = touches[1].normalizedPosition.x
        touchTracker.curY = touches[1].normalizedPosition.y
    else
        touchTracker.lastTouchEnd = now
    end

    if n > 0 then
        if not touchTracker.active then
            touchTracker.quietAtDown = (now - cursorTracker.lastMove) > CURSOR_QUIET_SEC
            touchTracker.resting = false
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
            touchTracker.volArmed = false

            -- 1本指で右端からスタートした場合のみ音量調整 (左端は誤爆防止のため無効化)
            -- カーソル操作中に触れただけの場合は対象外
            if n == 1 and x >= VOL_EDGE_X_MIN and touchTracker.quietAtDown then
                touchTracker.edge = "right"   -- 音量
            else
                touchTracker.edge = nil
            end
        else
            if n > touchTracker.maxFingers then
                touchTracker.maxFingers = n
            end

            -- 置きっぱなし判定の接触が含まれていれば、タップ扱いにしない
            for _, tt in ipairs(touches) do
                if tt.resting then touchTracker.resting = true end
            end

            -- 指の移動距離チェック (タップ判定用: 0.05まで許容)
            local t = touches[1]
            local dx = math.abs(t.normalizedPosition.x - touchTracker.startX)
            local dy = math.abs(t.normalizedPosition.y - touchTracker.startY)
            if dx > 0.05 or dy > 0.05 then
                touchTracker.moved = true
            end

            -- エッジスライド処理 (1本指: 右端の音量調整のみ)
            if n == 1 and touchTracker.edge == "right" and not touchTracker.resting then
                local y = t.normalizedPosition.y
                if not touchTracker.volArmed then
                    -- 不感帯: 十分な縦移動 かつ 縦方向が優勢 になるまで何もしない
                    local totalDy = math.abs(y - touchTracker.startY)
                    if totalDy >= VOL_DEADZONE and totalDy >= dx * VOL_VERTICAL_RATIO then
                        touchTracker.volArmed = true
                        touchTracker.lastY = y
                        touchTracker.accumulatedDelta = 0
                    end
                else
                    local deltaY = y - touchTracker.lastY
                    touchTracker.lastY = y
                    touchTracker.accumulatedDelta = touchTracker.accumulatedDelta + deltaY

                    if math.abs(touchTracker.accumulatedDelta) >= VOL_STEP then
                        touchTracker.didSlide = true
                        local key = touchTracker.accumulatedDelta > 0 and "SOUND_UP" or "SOUND_DOWN"
                        hs.eventtap.event.newSystemKeyEvent(key, true):post()
                        hs.eventtap.event.newSystemKeyEvent(key, false):post()
                        touchTracker.accumulatedDelta = 0
                    end
                end
            end
        end
    elseif n == 0 then
        touchTracker.active = false
    end
end

-- 角の物理クリック: 1本指で角を押し込んだときだけ割り当てを実行し、クリック自体は握りつぶす
local swallowMouseUp = false
local function cornerAt(x, y)
    local z = CORNER_ZONE
    if x >= 1 - z and y >= 1 - z then return "topRight" end
    if x >= 1 - z and y <= z then return "bottomRight" end
    if x <= z and y >= 1 - z then return "topLeft" end
    if x <= z and y <= z then return "bottomLeft" end
    if math.abs(x - 0.5) <= CENTER_HALF_WIDTH and y >= 1 - z then return "topCenter" end
    return nil
end

cornerClickTap = hs.eventtap.new({
    hs.eventtap.event.types.leftMouseDown,
    hs.eventtap.event.types.leftMouseUp,
}, function(event)
    local t = event:getType()
    if t == hs.eventtap.event.types.leftMouseUp then
        if swallowMouseUp then
            swallowMouseUp = false
            return true
        end
        return false
    end

    -- leftMouseDown: 指を置いたまま押し込んだ物理クリックか確認
    local now = hs.timer.secondsSinceEpoch()
    if touchTracker.curCount ~= 1 then return false end
    if now - touchTracker.lastTouchEnd < TAP_CLICK_GRACE then return false end
    local corner = cornerAt(touchTracker.curX, touchTracker.curY)
    local action = corner and CORNER_ACTIONS[corner]
    if not action then return false end

    swallowMouseUp = true
    hs.timer.doAfter(0, action)
    return true
end)
cornerClickTap:start()

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

-- 見張り: macOS が eventtap を無効化(タイムアウト等)しても自動で復帰させる
tapWatchdog = hs.timer.doEvery(2, function()
    for _, tap in ipairs({ trackpadWatcher, cornerClickTap }) do
        if not tap:isEnabled() then tap:start() end
    end
end)
