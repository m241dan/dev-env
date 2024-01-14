-- Function gets a width that is appropriate to not
-- hide anything below the signature box that pops up.
local function get_appropriate_width()
    local bufnr = vim.api.nvim_get_current_buf()
    local current_line = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.api.nvim_buf_get_lines(bufnr, current_line + 1, current_line + 12, false)

    local lengths = {}
    for _, v in ipairs(lines) do
        table.insert(lengths, #v)
    end

    -- have to pad by 10 for whatever reason
    if #lengths > 0 then
        return math.max(unpack(lengths)) + 10
    else
        return 10
    end
end


require("lsp_signature").setup({
    floating_window_above_cur_line = false,
    floating_window_off_x = get_appropriate_width,
    floating_window_off_y = -2,
})

