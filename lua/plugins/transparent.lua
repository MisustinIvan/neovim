return {
    'tribela/transparent.nvim',
    event = 'VimEnter',
    config = function ()
        require("transparent").setup( {
            auto = false,
        })
    end
}
