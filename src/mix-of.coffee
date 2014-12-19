# Helper for Role-based composition.
module.exports = (Base, mixins...) ->

  class Mixed extends Base

  for mixin in mixins by -1 #earlier mixins override later ones
    for name, method of mixin::
      Mixed::[name] = method

  Mixed
