/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
(function() {
  const SVG = "http://www.w3.org/TR/SVG11/feature#Shape";
  const supportsSVG = () => (typeof SVGAngle !== 'undefined' && SVGAngle !== null) || (window.SVGAngle != null) || __guardMethod__(document.implementation, 'hasFeature', o => o.hasFeature(SVG, "1.0"));

  /*
   * Add a 'destroyed' event on element removal.
   */
  jQuery.event.special.destroyed = { remove(o) { if (o.type !== 'destroyed') { return (typeof o.handler === 'function' ? o.handler() : undefined); } }

  /*
  *
  * A bridge between iPad and iPhone touch events and jquery draggable, 
  * sortable etc. mouse interactions.
  * @author Oleg Slobodskoi  
  * 
  * modified by John Hardy to use with any touch device
  * fixed breakage caused by jquery.ui so that mouseHandled internal flag is reset 
  * before each touchStart event
  * 
  */
};
  (function($) {

    $.support.touch = typeof Touch === 'object';
    if (!$.support.touch) { return false; }

    const proto =  $.ui.mouse.prototype;
    const { _mouseInit } = proto;

    return $.extend( proto, {
      _mouseInit() {
          this.element.bind( `touchstart.${this.widgetName}`, $.proxy( this, "_touchStart" ) );
          return _mouseInit.apply(this, arguments);
        },

      _touchStart( event ) {
          if ( event.originalEvent.targetTouches.length !== 1 ) {
              return false;
            }

          this.element
            .bind( `touchmove.${this.widgetName}`, $.proxy( this, "_touchMove" ) )
            .bind( `touchend.${this.widgetName}`, $.proxy( this, "_touchEnd" ) );

          this._modifyEvent( event );

          $( document ).trigger($.Event("mouseup")); // reset mouseHandled flag in ui.mouse
          this._mouseDown( event );

          return false;
        },

      _touchMove( event ) {
          this._modifyEvent( event );
          return this._mouseMove( event );
        },

      _touchEnd( event ) {
          this.element
            .unbind( `touchmove.${this.widgetName}` )
            .unbind( `touchend.${this.widgetName}` );
          return this._mouseUp( event );
        },

      _modifyEvent( event ) {
          event.which = 1;
          const target = event.originalEvent.targetTouches[0];
          event.pageX = target.clientX;
          return event.pageY = target.clientY;
        }
    });
  })(jQuery);

  return jQuery.fn.imWidget = function(arg0, arg1) {

      let view;
      if (typeof(arg0) === 'string') {
          view = this.data('widget');
          if (arg0 === 'option') {
              switch (arg1) {
                  case 'query': return view.query;
                  case 'service': return view.service;
                  case 'events': return view.queryEvents;
                  case 'type': return this.data('widget-type');
                  case 'properties': return this.data('widget-options');
                  default:
                      throw new Error(`Unknown option ${ arg1 }`);
              }
          } else if (arg0 === 'table') {
              return view;
          } else {
              throw new Error(`Unknown method ${arg0}`);
            }
      } else {
          let {type, service, url, token, query, events, properties, error, options} = arg0;
          if (supportsSVG() && (typeof d3 === 'undefined' || d3 === null)) {
            // Can be loaded late, as only needed for summaries, which the
            // user will have to click on.
            intermine.cdn.load('d3');
          }
          intermine.setOptions({Style: intermine.options.Style});
            
          if (service == null) { service = new intermine.Service({root: url, token}); }
          if (error != null) { service.errorHandler = error; }
          const cls = (() => {
            if (type === 'table') {
            return intermine.query.results.CompactView;
          } else if (type === 'dashboard') {
            return intermine.query.results.DashBoard;
          } else if (type === 'minimal') {
            return intermine.query.results.Toolless;
          }
          })();

          if (!cls) {
            console.error(`${ type } widgets are not supported`);
            return false;
          }

          if (this.width() < (jQuery('body').width() * 0.6)) {
            this.addClass('im-half');
          }

          if (options != null) {
            intermine.setOptions(options);
          }

          view = new cls(service, query, events, properties);
          this.empty().append(view.el);
          view.render();

          this.data('widget-options', properties);
          this.data('widget-type', type);
          this.data('widget', view);
          return this.data('widget');
        }
    };
})();




function __guardMethod__(obj, methodName, transform) {
  if (typeof obj !== 'undefined' && obj !== null && typeof obj[methodName] === 'function') {
    return transform(obj, methodName);
  } else {
    return undefined;
  }
}