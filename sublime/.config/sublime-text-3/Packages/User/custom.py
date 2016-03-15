import sublime, sublime_plugin

class ExampleCommand(sublime_plugin.TextCommand):
	def run(self, edit, args):
		self.view.insert(edit, 0, "Hello, World!")
