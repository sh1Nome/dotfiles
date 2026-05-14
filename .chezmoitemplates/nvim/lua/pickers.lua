-- カスタムピッカー設定

---zk-nvimのコマンドをmini.pickのピッカーで表示・実行する
---ZkNew、ZkTags、ZkNotesの3つのコマンドを選択可能にし、
---各コマンドの説明をプレビューで表示します
local function zk_commands()
	local commands = {
		{ text = "ZkNew" },
		{ text = "ZkTags" },
		{ text = "ZkNotes" },
	}

	local descriptions = {
		ZkNew = "新規ノートを作成します。",
		ZkTags = "タグ一覧をピッカーで開きます。\n選択すると、タグでフィルタしたノート一覧をピッカーで開きます。",
		ZkNotes = "ノート一覧をピッカーで開きます。",
	}

	require("mini.pick").start({
		source = {
			items = commands,
			name = "Zk Commands",
			preview = function(buf_id, item)
				local description = descriptions[item.text]
				local lines = vim.split(description, "\n")
				vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
			end,
			choose = function(item)
				vim.cmd("ZkIndex")
				vim.cmd(item.text)
			end,
		},
	})
end

return {
	zk_commands = zk_commands,
}
