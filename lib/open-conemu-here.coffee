exec = require("child_process").exec
path = require('path')
fs = require('fs')

module.exports =

  configDefaults: {
    win32App: 'ConEmu64.exe'
    win32Args: ''
  },

  activate: ->
    atom.commands.add '.tree-view .selected',
      'open-conemu-here:open': (event) => @open(event.currentTarget)

  open: (target) ->
    isWin32 = document.body.classList.contains("platform-win32")

    filepath = target.getPath?() ? target.item?.getPath()

    dirpath = filepath

    if fs.lstatSync(filepath).isFile()
      dirpath = path.dirname(filepath)

    return if not dirpath

    if isWin32
      @isWin32 dirpath


  isWin32: (dirpath) ->
    app = atom.config.get('open-conemu-here.win32App')
    args = atom.config.get('open-conemu-here.win32Args')
    exec "start #{app} /Dir \"#{dirpath}\" #{args}"
