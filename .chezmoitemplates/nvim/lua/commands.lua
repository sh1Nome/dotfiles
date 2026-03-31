-- ユーザーコマンド設定

-- リモートプロバイダーのインターフェース
---@class RemoteProvider
---@field match fun(host: string): boolean ホストが対応しているか判定
---@field build_url fun(host: string, repo_path: string, branch: string, rel_path: string, start_line?: integer, end_line?: integer): string

--- GitHubプロバイダー
---@type RemoteProvider
local github = {
	match = function(host)
		return host:find("github") ~= nil
	end,
	build_url = function(host, repo_path, branch, rel_path, start_line, end_line)
		local base = ("https://%s/%s/blob/%s/%s"):format(host, repo_path, branch, rel_path)
		if not start_line then
			return base
		end
		if start_line == end_line then
			return base .. "#L" .. start_line
		end
		return base .. "#L" .. start_line .. "-L" .. end_line
	end,
}

--- GitLabプロバイダー
---@type RemoteProvider
local gitlab = {
	match = function(host)
		return host:find("gitlab") ~= nil
	end,
	build_url = function(host, repo_path, branch, rel_path, start_line, end_line)
		local base = ("https://%s/%s/-/blob/%s/%s"):format(host, repo_path, branch, rel_path)
		if not start_line then
			return base
		end
		if start_line == end_line then
			return base .. "#L" .. start_line
		end
		return base .. "#L" .. start_line .. "-" .. end_line
	end,
}

---@type RemoteProvider[]
local providers = { github, gitlab }

--- 現在のファイルをGitHub/GitLabのリモートURLでブラウザを開く
---@param range integer 範囲指定の有無（0: なし, 2: あり）
---@param start_line integer 開始行
---@param end_line integer 終了行
local function open_in_remote(range, start_line, end_line)
	-- リモートURLを取得
	local remote_url = vim.system({ "git", "remote", "get-url", "origin" }, { text = true })
		:wait().stdout
		:gsub("%s+$", "")
	if remote_url == "" then
		vim.notify("git remote not found", vim.log.levels.ERROR)
		return
	end

	-- SSH/HTTPSのURLからホストとリポジトリパスを抽出
	local host, repo_path
	local ssh_host, ssh_path = remote_url:match("^git@([^:]+):(.+)$")
	if ssh_host then
		host, repo_path = ssh_host, ssh_path
	else
		host, repo_path = remote_url:match("^https?://([^/]+)/(.+)$")
	end
	if not host or not repo_path then
		vim.notify("failed to parse remote URL: " .. remote_url, vim.log.levels.ERROR)
		return
	end
	repo_path = repo_path:gsub("%.git$", "")

	-- ホストに対応するプロバイダーを探す
	local provider
	for _, p in ipairs(providers) do
		if p.match(host) then
			provider = p
			break
		end
	end
	if not provider then
		vim.notify("no matching provider: " .. host, vim.log.levels.ERROR)
		return
	end

	-- リポジトリルートからの相対パスを算出
	local repo_root = vim.system({ "git", "rev-parse", "--show-toplevel" }, { text = true })
		:wait().stdout
		:gsub("%s+$", "")
	local buf_path = vim.api.nvim_buf_get_name(0)
	local rel_path = buf_path:sub(#repo_root + 2) -- +2 は末尾の / を飛ばすため

	-- ブランチ名を取得
	local branch = vim.system({ "git", "rev-parse", "--abbrev-ref", "HEAD" }, { text = true })
		:wait().stdout
		:gsub("%s+$", "")

	-- URL組み立て（範囲指定なしならファイルのみ）
	local url
	if range > 0 then
		url = provider.build_url(host, repo_path, branch, rel_path, start_line, end_line)
	else
		url = provider.build_url(host, repo_path, branch, rel_path)
	end

	-- ブラウザで開く
	local open_cmd = vim.fn.has("win32") == 1 and "start" or "xdg-open"
	vim.system({ open_cmd, url })
end

-- :OpenInRemote（範囲指定対応）
vim.api.nvim_create_user_command("OpenInRemote", function(opts)
	open_in_remote(opts.range, opts.line1, opts.line2)
end, { range = true, desc = "Open current file on GitHub/GitLab" })
