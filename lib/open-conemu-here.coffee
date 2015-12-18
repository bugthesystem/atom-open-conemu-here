exec = require('child_process').exec
process = require('process')
path = require('path')
fs = require('fs')
{CompositeDisposable} = require 'atom'

module.exports =

  config:
    executablePath:
      type: 'string'
      default: 'ConEmu.exe'
      description: 'Path to ConEmu.exe or ConEmu64.exe.'
    extraArguments:
      type: 'string'
      default: ''
      description: 'Additional arguments to apply.'

  subscriptions: null

  activate: ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'open-conemu-here:open-default': => @open()
    @subscriptions.add atom.commands.add '.tree-view .selected',
      'open-conemu-here:open-target': (event) => @open(event.currentTarget)
    @subscriptions.add atom.commands.add 'atom-text-editor',
      'open-conemu-here:open-target': => @open()

   deactivate: ->
     @subscriptions.dispose()

  open: (target) ->
    if document.body.classList.contains("platform-win32")

      if target?
        filepath = target.getPath?() ? target.item?.getPath() ? target

      else
        filepath = atom.workspace.getActivePaneItem()?.buffer?.file?.getPath()
        filepath ?= atom.project.getPaths()?[0]

      if filepath? and fs.lstatSync(filepath).isFile()
        dirpath = path.dirname(filepath)
      else
        dirpath = filepath

      return if not dirpath

      app = atom.config.get('open-conemu-here.executablePath')
      args = atom.config.get('open-conemu-here.extraArguments')
      env = {}
      for key, val of process.env
        env[key] = val
      delete env['NODE_ENV'] # Workaround for https://github.com/atom/atom/issues/3099
      exec "start \"#{app}\" /Dir \"#{dirpath}\" #{args}",
        env: env
