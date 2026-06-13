return {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    dependencies = { 'hrsh7th/nvim-cmp' },
    config = function()
        local autopairs = require("nvim-autopairs")
        
        -- 基本設定: Treesitterと連携して、コメント内などで自動括弧を無効化
        autopairs.setup({
            check_ts = true,
        })

        -- nvim-cmp (補完) との連携設定
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        local cmp = require("cmp")
        
        -- 補完確定時 (confirm_done) に括弧を自動挿入
        cmp.event:on(
            'confirm_done',
            cmp_autopairs.on_confirm_done()
        )
    end
}
