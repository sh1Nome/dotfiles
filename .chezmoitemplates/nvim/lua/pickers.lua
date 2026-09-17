-- mini.pickのcustom source設定

local pick = require("mini.pick")
local tgrep = {}
local source_name = "tgrep"
local last_picker_was_tgrep = false
local last_tgrep_resume_state = nil
local events_initialized = false
local state_id = 0

local function is_tgrep_source(opts)
	local name = opts and opts.source and opts.source.name
	return type(name) == "string" and (name == source_name or name:sub(1, #source_name + 2) == source_name .. " (")
end

local function kill_tgrep_process(process)
	if not process then
		return
	end

	local ok, is_closing = pcall(process.is_closing, process)
	if ok and is_closing then
		return
	end
	pcall(process.kill, process, "sigterm")
end

local function resolve_tgrep_executable(cwd)
	local ok, result = pcall(function()
		return vim.system({ "mise", "which", "tgrep" }, { cwd = cwd, text = true }):wait()
	end)
	if not ok then
		return nil, tostring(result)
	end
	if result.code ~= 0 then
		return nil, vim.trim(result.stderr or "")
	end

	local executable = vim.trim(result.stdout or "")
	if executable == "" then
		return nil, "mise returned an empty tgrep path"
	end
	return executable
end

local function parse_tgrep_items(stdout)
	local items = {}
	for line in vim.gsplit(stdout or "", "\n", { trimempty = true }) do
		line = line:gsub("\r$", "")
		local path, lnum, col = line:match("^(.-):(%d+):(%d+):(.*)$")
		if path then
			table.insert(items, {
				text = line,
				path = path,
				lnum = tonumber(lnum),
				col = tonumber(col),
			})
		end
	end
	return items
end

local function save_tgrep_resume_state(state)
	if not pick.is_picker_active() then
		return
	end

	local opts = pick.get_picker_opts()
	if not is_tgrep_source(opts) then
		return
	end

	local refined = state.refined or opts.source.match ~= state.match
	last_tgrep_resume_state = {
		cwd = state.cwd,
		query = pick.get_picker_query() or {},
		refined = refined,
		items = refined and pick.get_picker_items() or nil,
	}
end

local function schedule_tgrep_query(query)
	if #query == 0 then
		return
	end

	vim.api.nvim_create_autocmd("User", {
		pattern = "MiniPickStart",
		once = true,
		callback = function()
			if not pick.is_picker_active() or not is_tgrep_source(pick.get_picker_opts()) then
				return
			end
			pick.set_picker_query(query)
		end,
	})
end

local function stop_tgrep_search_if_refined(state)
	if state.stopping or state.refined or not pick.is_picker_active() then
		return
	end

	local opts = pick.get_picker_opts()
	if not is_tgrep_source(opts) then
		return
	end
	if opts.source.match ~= state.match then
		state.refined = true
		kill_tgrep_process(state.search_process)
		state.search_process = nil
	end
end

local function cleanup_tgrep(state)
	if state.stopping then
		return
	end
	save_tgrep_resume_state(state)
	state.stopping = true
	kill_tgrep_process(state.search_process)
	kill_tgrep_process(state.server)
	state.search_process = nil
	state.server = nil
	if state.group then
		pcall(vim.api.nvim_del_augroup_by_id, state.group)
	end
end

local function install_tgrep_lifecycle(state)
	state_id = state_id + 1
	state.group = vim.api.nvim_create_augroup("TgrepPicker" .. state_id, { clear = true })

	vim.api.nvim_create_autocmd("User", {
		group = state.group,
		pattern = "MiniPickMatch",
		callback = function()
			stop_tgrep_search_if_refined(state)
		end,
	})
	vim.api.nvim_create_autocmd("User", {
		group = state.group,
		pattern = "MiniPickStop",
		once = true,
		callback = function()
			cleanup_tgrep(state)
		end,
	})
end

local function search_tgrep(state, query)
	kill_tgrep_process(state.search_process)
	state.search_process = nil

	local raw_query = table.concat(pick.get_picker_query() or query)
	local querytick = pick.get_querytick()
	if raw_query == "" then
		pick.set_picker_items({}, { do_match = false, querytick = querytick })
		return
	end

	local command = {
		state.executable,
		"--vimgrep",
		"--smart-case",
		"--hidden",
		"--color=never",
		"--",
		raw_query,
		".",
	}
	local process
	local ok, error_message = pcall(function()
		process = vim.system(command, { cwd = state.cwd, text = true }, function(result)
			vim.schedule(function()
				if state.search_process == process then
					state.search_process = nil
				end
				if state.stopping or state.refined or not pick.is_picker_active() then
					return
				end
				local opts = pick.get_picker_opts()
				if not opts or not opts.source or opts.source.match ~= state.match then
					return
				end
				if pick.get_querytick() ~= querytick then
					return
				end

				local items = result.code == 0 and parse_tgrep_items(result.stdout) or {}
				pick.set_picker_items(items, { do_match = false, querytick = querytick })
			end)
		end)
	end)
	if not ok then
		vim.notify(("Failed to run tgrep: %s"):format(tostring(error_message)), vim.log.levels.ERROR)
		pick.stop()
		return
	end
	state.search_process = process
end

local function start_tgrep_server(state)
	local ok, server_or_error = pcall(function()
		return vim.system(
			{ state.executable, "serve", ".", "--exclude", ".git" },
			{ cwd = state.cwd, stdout = false, stderr = false },
			function(result)
				vim.schedule(function()
					if state.stopping or result.code == 0 then
						return
					end
					vim.notify(
						("Failed to start tgrep server (exit code %d)"):format(result.code),
						vim.log.levels.ERROR
					)
					if pick.is_picker_active() and is_tgrep_source(pick.get_picker_opts()) then
						pick.stop()
					end
				end)
			end
		)
	end)
	if not ok then
		return nil, tostring(server_or_error)
	end
	return server_or_error
end

local function start_tgrep_picker(resume_state)
	local cwd = resume_state and resume_state.cwd or vim.fn.getcwd()
	local is_refined = resume_state and resume_state.refined or false
	local executable, resolve_error = resolve_tgrep_executable(cwd)
	if not executable then
		vim.notify(
			("Failed to resolve tgrep executable with mise: %s"):format(resolve_error or "unknown error"),
			vim.log.levels.ERROR
		)
		return
	end

	local state = {
		cwd = cwd,
		executable = executable,
		search_process = nil,
		server = nil,
		refined = is_refined,
		stopping = false,
	}
	local match
	match = function(_, _, query)
		search_tgrep(state, query)
	end
	state.match = match

	local server, server_error = start_tgrep_server(state)
	if not server then
		vim.notify(("Failed to start tgrep server: %s"):format(server_error or "unknown error"), vim.log.levels.ERROR)
		return
	end
	state.server = server
	install_tgrep_lifecycle(state)
	last_picker_was_tgrep = true
	if resume_state then
		schedule_tgrep_query(resume_state.query)
	end

	local ok, result = pcall(function()
		return pick.start({
			source = {
				name = source_name,
				cwd = cwd,
				items = resume_state and resume_state.items or {},
				match = is_refined and pick.default_match or match,
				show = function(buf_id, items, query)
					pick.default_show(buf_id, items, query, { show_icons = false })
				end,
				preview = pick.default_preview,
				choose = pick.default_choose,
				choose_marked = pick.default_choose_marked,
			},
			window = {
				prompt_prefix = "tgrep> ",
			},
		})
	end)
	if not ok then
		cleanup_tgrep(state)
		vim.notify(("Failed to start tgrep picker: %s"):format(tostring(result)), vim.log.levels.ERROR)
	elseif not state.stopping and not pick.is_picker_active() then
		cleanup_tgrep(state)
	end
	return result
end

function tgrep.setup()
	if events_initialized then
		return
	end
	events_initialized = true

	local group = vim.api.nvim_create_augroup("TgrepPickerResume", { clear = true })
	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "MiniPickStart",
		callback = function()
			last_picker_was_tgrep = is_tgrep_source(pick.get_picker_opts())
		end,
	})
	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "MiniPickStop",
		callback = function()
			last_picker_was_tgrep = is_tgrep_source(pick.get_picker_opts())
		end,
	})
end

function tgrep.pick()
	if pick.is_picker_active() then
		vim.api.nvim_create_autocmd("User", {
			pattern = "MiniPickStop",
			once = true,
			callback = function()
				vim.schedule(start_tgrep_picker)
			end,
		})
		pick.stop()
		return
	end
	return start_tgrep_picker()
end

function tgrep.resume()
	if last_picker_was_tgrep then
		if not last_tgrep_resume_state then
			vim.notify("No tgrep picker to resume", vim.log.levels.WARN)
			return
		end
		return start_tgrep_picker(last_tgrep_resume_state)
	end
	return pick.builtin.resume()
end

tgrep.setup()

return {
	resume = tgrep.resume,
	tgrep = tgrep.pick,
}
