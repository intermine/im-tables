// Helper for Role-based composition.
module.exports = function(Base, ...mixins) {

  class Mixed extends Base {}

  for (let i = mixins.length - 1; i >= 0; i--) { //earlier mixins override later ones
    const mixin = mixins[i];
    for (let name in mixin.prototype) {
      const method = mixin.prototype[name];
      Mixed.prototype[name] = method;
    }
  }

  return Mixed;
};
