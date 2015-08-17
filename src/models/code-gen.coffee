# Configuration
Options = require '../options'
CoreModel = require '../core-model'

# The data model has three bits - the language, and a couple of presentation
# options.
module.exports = class CodeGenModel extends CoreModel

  defaults: ->
    lang: Options.get('CodeGen.Default') # The code-gen lang. See Options.CodeGen.Langs
    showBoilerPlate: false # Should we show language boilerplate.
    highlightSyntax: true  # Should we do syntax highlighting
