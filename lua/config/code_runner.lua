require('code_runner').setup({
  -- put here the commands by filetype
  filetype = {
    python = "python3 -u",
    go = "go run .",
    rust = {
      "cd $dir &&",
      "rustc $fileName &&",
      "$dir$fileNameWithoutExt"
    },
  },

  mode = "float",
  float = {
        close_key = 'q',
        border = 'rounded',
        border_hl = 'FloatBorder',
  },

  toggleterm = {
    size = 6,
    height = 0.5,
    width = 0.5,
  },
})
