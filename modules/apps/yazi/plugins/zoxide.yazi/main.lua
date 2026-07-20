-- zoxideの利用履歴からディレクトリを対話的に選んでジャンプする。
-- `zoxide query -i` (内部でfzfを使う) を端末を占有した状態で起動し、
-- 選択結果をyaziの `cd` に渡す。
local function fail(s, ...)
	ya.notify({ title = "zoxide", content = string.format(s, ...), timeout = 5, level = "error" })
end

return {
	entry = function()
		local child, err = Command("zoxide")
			:arg({ "query", "-i" })
			:stdin(Command.INHERIT)
			:stdout(Command.PIPED)
			:stderr(Command.INHERIT)
			:spawn()

		if not child then
			return fail("Failed to start `zoxide`, error: %s", err)
		end

		local output, err = child:wait_with_output()
		if not output then
			return fail("Cannot read `zoxide` output, error: %s", err)
		elseif not output.status.success then
			-- ユーザーがEsc等でキャンセルした場合は何もしない
			return
		end

		local target = output.stdout:gsub("\n$", "")
		if target ~= "" then
			ya.emit("cd", { target })
		end
	end,
}
