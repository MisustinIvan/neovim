local Wiki = require('config.wiki')

---notes, in the order the homepage lists them
local wiki = Wiki.new({
	name = 'wiki',
	path = '~/Documents/Wiki',
	command_prefix = 'Wiki',
	prefix = '<leader>wi',
	key = 'w',
})

---the same thing, with an entry per day
local diary = Wiki.new({
	name = 'diary',
	path = '~/Documents/Diary',
	command_prefix = 'Diary',
	prefix = '<leader>di',
	key = 'd',
	journal = {
		file_format = '%Y-%m-%d',
		entry_pattern = '^%d%d%d%d%-%d%d%-%d%d%.md$',
		headings = { 'TODO', 'Song of the day', 'Thoughts' },
	},
})

return {
	wiki = wiki,
	diary = diary,
}
