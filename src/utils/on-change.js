// Produce an event name for the change of multiple properties
let onChange;
module.exports = (onChange = props =>
  props.map(p => `change:${ p }`)
       .join(' ')
);

