object:view, Event{object}
=============================

This event is published when the link for an object is clicked.
The default behaviour is to open the URL for the object in a new
window - this can be prevented with `event.preventDefault`. The event
object has the following relevant properties:

  * object: The InterMineObject model selected.
  * target: The `<a/>` element being clicked on.
