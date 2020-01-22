# Produce an event name for the change of multiple properties
module.exports = onChange = (props) ->
  props.map (p) -> "change:#{ p }"
       .join ' '

