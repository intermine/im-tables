(function() {

  var root = this;
  var context = {};

  context.document = root.document;
  context.location = root.location;
  context.$ = context.jquery = context.jQuery = window.jQuery;
  context.Backbone = window.Backbone;
  context._ = window._;
  context.intermine = window.intermine;

  (function(jQuery) {
    var $ = jQuery;
    /*!
 * jQuery UI Core 1.10.2
 * http://jqueryui.com
 *
 * Copyright 2013 jQuery Foundation and other contributors
 * Released under the MIT license.
 * http://jquery.org/license
 *
 * http://api.jqueryui.com/category/ui-core/
 */
(function( $, undefined ) {

var uuid = 0,
	runiqueId = /^ui-id-\d+$/;

// $.ui might exist from components with no dependencies, e.g., $.ui.position
$.ui = $.ui || {};

$.extend( $.ui, {
	version: "1.10.2",

	keyCode: {
		BACKSPACE: 8,
		COMMA: 188,
		DELETE: 46,
		DOWN: 40,
		END: 35,
		ENTER: 13,
		ESCAPE: 27,
		HOME: 36,
		LEFT: 37,
		NUMPAD_ADD: 107,
		NUMPAD_DECIMAL: 110,
		NUMPAD_DIVIDE: 111,
		NUMPAD_ENTER: 108,
		NUMPAD_MULTIPLY: 106,
		NUMPAD_SUBTRACT: 109,
		PAGE_DOWN: 34,
		PAGE_UP: 33,
		PERIOD: 190,
		RIGHT: 39,
		SPACE: 32,
		TAB: 9,
		UP: 38
	}
});

// plugins
$.fn.extend({
	focus: (function( orig ) {
		return function( delay, fn ) {
			return typeof delay === "number" ?
				this.each(function() {
					var elem = this;
					setTimeout(function() {
						$( elem ).focus();
						if ( fn ) {
							fn.call( elem );
						}
					}, delay );
				}) :
				orig.apply( this, arguments );
		};
	})( $.fn.focus ),

	scrollParent: function() {
		var scrollParent;
		if (($.ui.ie && (/(static|relative)/).test(this.css("position"))) || (/absolute/).test(this.css("position"))) {
			scrollParent = this.parents().filter(function() {
				return (/(relative|absolute|fixed)/).test($.css(this,"position")) && (/(auto|scroll)/).test($.css(this,"overflow")+$.css(this,"overflow-y")+$.css(this,"overflow-x"));
			}).eq(0);
		} else {
			scrollParent = this.parents().filter(function() {
				return (/(auto|scroll)/).test($.css(this,"overflow")+$.css(this,"overflow-y")+$.css(this,"overflow-x"));
			}).eq(0);
		}

		return (/fixed/).test(this.css("position")) || !scrollParent.length ? $(document) : scrollParent;
	},

	zIndex: function( zIndex ) {
		if ( zIndex !== undefined ) {
			return this.css( "zIndex", zIndex );
		}

		if ( this.length ) {
			var elem = $( this[ 0 ] ), position, value;
			while ( elem.length && elem[ 0 ] !== document ) {
				// Ignore z-index if position is set to a value where z-index is ignored by the browser
				// This makes behavior of this function consistent across browsers
				// WebKit always returns auto if the element is positioned
				position = elem.css( "position" );
				if ( position === "absolute" || position === "relative" || position === "fixed" ) {
					// IE returns 0 when zIndex is not specified
					// other browsers return a string
					// we ignore the case of nested elements with an explicit value of 0
					// <div style="z-index: -10;"><div style="z-index: 0;"></div></div>
					value = parseInt( elem.css( "zIndex" ), 10 );
					if ( !isNaN( value ) && value !== 0 ) {
						return value;
					}
				}
				elem = elem.parent();
			}
		}

		return 0;
	},

	uniqueId: function() {
		return this.each(function() {
			if ( !this.id ) {
				this.id = "ui-id-" + (++uuid);
			}
		});
	},

	removeUniqueId: function() {
		return this.each(function() {
			if ( runiqueId.test( this.id ) ) {
				$( this ).removeAttr( "id" );
			}
		});
	}
});

// selectors
function focusable( element, isTabIndexNotNaN ) {
	var map, mapName, img,
		nodeName = element.nodeName.toLowerCase();
	if ( "area" === nodeName ) {
		map = element.parentNode;
		mapName = map.name;
		if ( !element.href || !mapName || map.nodeName.toLowerCase() !== "map" ) {
			return false;
		}
		img = $( "img[usemap=#" + mapName + "]" )[0];
		return !!img && visible( img );
	}
	return ( /input|select|textarea|button|object/.test( nodeName ) ?
		!element.disabled :
		"a" === nodeName ?
			element.href || isTabIndexNotNaN :
			isTabIndexNotNaN) &&
		// the element and all of its ancestors must be visible
		visible( element );
}

function visible( element ) {
	return $.expr.filters.visible( element ) &&
		!$( element ).parents().addBack().filter(function() {
			return $.css( this, "visibility" ) === "hidden";
		}).length;
}

$.extend( $.expr[ ":" ], {
	data: $.expr.createPseudo ?
		$.expr.createPseudo(function( dataName ) {
			return function( elem ) {
				return !!$.data( elem, dataName );
			};
		}) :
		// support: jQuery <1.8
		function( elem, i, match ) {
			return !!$.data( elem, match[ 3 ] );
		},

	focusable: function( element ) {
		return focusable( element, !isNaN( $.attr( element, "tabindex" ) ) );
	},

	tabbable: function( element ) {
		var tabIndex = $.attr( element, "tabindex" ),
			isTabIndexNaN = isNaN( tabIndex );
		return ( isTabIndexNaN || tabIndex >= 0 ) && focusable( element, !isTabIndexNaN );
	}
});

// support: jQuery <1.8
if ( !$( "<a>" ).outerWidth( 1 ).jquery ) {
	$.each( [ "Width", "Height" ], function( i, name ) {
		var side = name === "Width" ? [ "Left", "Right" ] : [ "Top", "Bottom" ],
			type = name.toLowerCase(),
			orig = {
				innerWidth: $.fn.innerWidth,
				innerHeight: $.fn.innerHeight,
				outerWidth: $.fn.outerWidth,
				outerHeight: $.fn.outerHeight
			};

		function reduce( elem, size, border, margin ) {
			$.each( side, function() {
				size -= parseFloat( $.css( elem, "padding" + this ) ) || 0;
				if ( border ) {
					size -= parseFloat( $.css( elem, "border" + this + "Width" ) ) || 0;
				}
				if ( margin ) {
					size -= parseFloat( $.css( elem, "margin" + this ) ) || 0;
				}
			});
			return size;
		}

		$.fn[ "inner" + name ] = function( size ) {
			if ( size === undefined ) {
				return orig[ "inner" + name ].call( this );
			}

			return this.each(function() {
				$( this ).css( type, reduce( this, size ) + "px" );
			});
		};

		$.fn[ "outer" + name] = function( size, margin ) {
			if ( typeof size !== "number" ) {
				return orig[ "outer" + name ].call( this, size );
			}

			return this.each(function() {
				$( this).css( type, reduce( this, size, true, margin ) + "px" );
			});
		};
	});
}

// support: jQuery <1.8
if ( !$.fn.addBack ) {
	$.fn.addBack = function( selector ) {
		return this.add( selector == null ?
			this.prevObject : this.prevObject.filter( selector )
		);
	};
}

// support: jQuery 1.6.1, 1.6.2 (http://bugs.jquery.com/ticket/9413)
if ( $( "<a>" ).data( "a-b", "a" ).removeData( "a-b" ).data( "a-b" ) ) {
	$.fn.removeData = (function( removeData ) {
		return function( key ) {
			if ( arguments.length ) {
				return removeData.call( this, $.camelCase( key ) );
			} else {
				return removeData.call( this );
			}
		};
	})( $.fn.removeData );
}





// deprecated
$.ui.ie = !!/msie [\w.]+/.exec( navigator.userAgent.toLowerCase() );

$.support.selectstart = "onselectstart" in document.createElement( "div" );
$.fn.extend({
	disableSelection: function() {
		return this.bind( ( $.support.selectstart ? "selectstart" : "mousedown" ) +
			".ui-disableSelection", function( event ) {
				event.preventDefault();
			});
	},

	enableSelection: function() {
		return this.unbind( ".ui-disableSelection" );
	}
});

$.extend( $.ui, {
	// $.ui.plugin is deprecated.  Use the proxy pattern instead.
	plugin: {
		add: function( module, option, set ) {
			var i,
				proto = $.ui[ module ].prototype;
			for ( i in set ) {
				proto.plugins[ i ] = proto.plugins[ i ] || [];
				proto.plugins[ i ].push( [ option, set[ i ] ] );
			}
		},
		call: function( instance, name, args ) {
			var i,
				set = instance.plugins[ name ];
			if ( !set || !instance.element[ 0 ].parentNode || instance.element[ 0 ].parentNode.nodeType === 11 ) {
				return;
			}

			for ( i = 0; i < set.length; i++ ) {
				if ( instance.options[ set[ i ][ 0 ] ] ) {
					set[ i ][ 1 ].apply( instance.element, args );
				}
			}
		}
	},

	// only used by resizable
	hasScroll: function( el, a ) {

		//If overflow is hidden, the element might have extra content, but the user wants to hide it
		if ( $( el ).css( "overflow" ) === "hidden") {
			return false;
		}

		var scroll = ( a && a === "left" ) ? "scrollLeft" : "scrollTop",
			has = false;

		if ( el[ scroll ] > 0 ) {
			return true;
		}

		// TODO: determine which cases actually cause this to happen
		// if the element doesn't have the scroll set, see if it's possible to
		// set the scroll
		el[ scroll ] = 1;
		has = ( el[ scroll ] > 0 );
		el[ scroll ] = 0;
		return has;
	}
});

})( jQuery );


/*!
 * jQuery UI Widget 1.10.2
 * http://jqueryui.com
 *
 * Copyright 2013 jQuery Foundation and other contributors
 * Released under the MIT license.
 * http://jquery.org/license
 *
 * http://api.jqueryui.com/jQuery.widget/
 */
(function( $, undefined ) {

var uuid = 0,
	slice = Array.prototype.slice,
	_cleanData = $.cleanData;
$.cleanData = function( elems ) {
	for ( var i = 0, elem; (elem = elems[i]) != null; i++ ) {
		try {
			$( elem ).triggerHandler( "remove" );
		// http://bugs.jquery.com/ticket/8235
		} catch( e ) {}
	}
	_cleanData( elems );
};

$.widget = function( name, base, prototype ) {
	var fullName, existingConstructor, constructor, basePrototype,
		// proxiedPrototype allows the provided prototype to remain unmodified
		// so that it can be used as a mixin for multiple widgets (#8876)
		proxiedPrototype = {},
		namespace = name.split( "." )[ 0 ];

	name = name.split( "." )[ 1 ];
	fullName = namespace + "-" + name;

	if ( !prototype ) {
		prototype = base;
		base = $.Widget;
	}

	// create selector for plugin
	$.expr[ ":" ][ fullName.toLowerCase() ] = function( elem ) {
		return !!$.data( elem, fullName );
	};

	$[ namespace ] = $[ namespace ] || {};
	existingConstructor = $[ namespace ][ name ];
	constructor = $[ namespace ][ name ] = function( options, element ) {
		// allow instantiation without "new" keyword
		if ( !this._createWidget ) {
			return new constructor( options, element );
		}

		// allow instantiation without initializing for simple inheritance
		// must use "new" keyword (the code above always passes args)
		if ( arguments.length ) {
			this._createWidget( options, element );
		}
	};
	// extend with the existing constructor to carry over any static properties
	$.extend( constructor, existingConstructor, {
		version: prototype.version,
		// copy the object used to create the prototype in case we need to
		// redefine the widget later
		_proto: $.extend( {}, prototype ),
		// track widgets that inherit from this widget in case this widget is
		// redefined after a widget inherits from it
		_childConstructors: []
	});

	basePrototype = new base();
	// we need to make the options hash a property directly on the new instance
	// otherwise we'll modify the options hash on the prototype that we're
	// inheriting from
	basePrototype.options = $.widget.extend( {}, basePrototype.options );
	$.each( prototype, function( prop, value ) {
		if ( !$.isFunction( value ) ) {
			proxiedPrototype[ prop ] = value;
			return;
		}
		proxiedPrototype[ prop ] = (function() {
			var _super = function() {
					return base.prototype[ prop ].apply( this, arguments );
				},
				_superApply = function( args ) {
					return base.prototype[ prop ].apply( this, args );
				};
			return function() {
				var __super = this._super,
					__superApply = this._superApply,
					returnValue;

				this._super = _super;
				this._superApply = _superApply;

				returnValue = value.apply( this, arguments );

				this._super = __super;
				this._superApply = __superApply;

				return returnValue;
			};
		})();
	});
	constructor.prototype = $.widget.extend( basePrototype, {
		// TODO: remove support for widgetEventPrefix
		// always use the name + a colon as the prefix, e.g., draggable:start
		// don't prefix for widgets that aren't DOM-based
		widgetEventPrefix: existingConstructor ? basePrototype.widgetEventPrefix : name
	}, proxiedPrototype, {
		constructor: constructor,
		namespace: namespace,
		widgetName: name,
		widgetFullName: fullName
	});

	// If this widget is being redefined then we need to find all widgets that
	// are inheriting from it and redefine all of them so that they inherit from
	// the new version of this widget. We're essentially trying to replace one
	// level in the prototype chain.
	if ( existingConstructor ) {
		$.each( existingConstructor._childConstructors, function( i, child ) {
			var childPrototype = child.prototype;

			// redefine the child widget using the same prototype that was
			// originally used, but inherit from the new version of the base
			$.widget( childPrototype.namespace + "." + childPrototype.widgetName, constructor, child._proto );
		});
		// remove the list of existing child constructors from the old constructor
		// so the old child constructors can be garbage collected
		delete existingConstructor._childConstructors;
	} else {
		base._childConstructors.push( constructor );
	}

	$.widget.bridge( name, constructor );
};

$.widget.extend = function( target ) {
	var input = slice.call( arguments, 1 ),
		inputIndex = 0,
		inputLength = input.length,
		key,
		value;
	for ( ; inputIndex < inputLength; inputIndex++ ) {
		for ( key in input[ inputIndex ] ) {
			value = input[ inputIndex ][ key ];
			if ( input[ inputIndex ].hasOwnProperty( key ) && value !== undefined ) {
				// Clone objects
				if ( $.isPlainObject( value ) ) {
					target[ key ] = $.isPlainObject( target[ key ] ) ?
						$.widget.extend( {}, target[ key ], value ) :
						// Don't extend strings, arrays, etc. with objects
						$.widget.extend( {}, value );
				// Copy everything else by reference
				} else {
					target[ key ] = value;
				}
			}
		}
	}
	return target;
};

$.widget.bridge = function( name, object ) {
	var fullName = object.prototype.widgetFullName || name;
	$.fn[ name ] = function( options ) {
		var isMethodCall = typeof options === "string",
			args = slice.call( arguments, 1 ),
			returnValue = this;

		// allow multiple hashes to be passed on init
		options = !isMethodCall && args.length ?
			$.widget.extend.apply( null, [ options ].concat(args) ) :
			options;

		if ( isMethodCall ) {
			this.each(function() {
				var methodValue,
					instance = $.data( this, fullName );
				if ( !instance ) {
					return $.error( "cannot call methods on " + name + " prior to initialization; " +
						"attempted to call method '" + options + "'" );
				}
				if ( !$.isFunction( instance[options] ) || options.charAt( 0 ) === "_" ) {
					return $.error( "no such method '" + options + "' for " + name + " widget instance" );
				}
				methodValue = instance[ options ].apply( instance, args );
				if ( methodValue !== instance && methodValue !== undefined ) {
					returnValue = methodValue && methodValue.jquery ?
						returnValue.pushStack( methodValue.get() ) :
						methodValue;
					return false;
				}
			});
		} else {
			this.each(function() {
				var instance = $.data( this, fullName );
				if ( instance ) {
					instance.option( options || {} )._init();
				} else {
					$.data( this, fullName, new object( options, this ) );
				}
			});
		}

		return returnValue;
	};
};

$.Widget = function( /* options, element */ ) {};
$.Widget._childConstructors = [];

$.Widget.prototype = {
	widgetName: "widget",
	widgetEventPrefix: "",
	defaultElement: "<div>",
	options: {
		disabled: false,

		// callbacks
		create: null
	},
	_createWidget: function( options, element ) {
		element = $( element || this.defaultElement || this )[ 0 ];
		this.element = $( element );
		this.uuid = uuid++;
		this.eventNamespace = "." + this.widgetName + this.uuid;
		this.options = $.widget.extend( {},
			this.options,
			this._getCreateOptions(),
			options );

		this.bindings = $();
		this.hoverable = $();
		this.focusable = $();

		if ( element !== this ) {
			$.data( element, this.widgetFullName, this );
			this._on( true, this.element, {
				remove: function( event ) {
					if ( event.target === element ) {
						this.destroy();
					}
				}
			});
			this.document = $( element.style ?
				// element within the document
				element.ownerDocument :
				// element is window or document
				element.document || element );
			this.window = $( this.document[0].defaultView || this.document[0].parentWindow );
		}

		this._create();
		this._trigger( "create", null, this._getCreateEventData() );
		this._init();
	},
	_getCreateOptions: $.noop,
	_getCreateEventData: $.noop,
	_create: $.noop,
	_init: $.noop,

	destroy: function() {
		this._destroy();
		// we can probably remove the unbind calls in 2.0
		// all event bindings should go through this._on()
		this.element
			.unbind( this.eventNamespace )
			// 1.9 BC for #7810
			// TODO remove dual storage
			.removeData( this.widgetName )
			.removeData( this.widgetFullName )
			// support: jquery <1.6.3
			// http://bugs.jquery.com/ticket/9413
			.removeData( $.camelCase( this.widgetFullName ) );
		this.widget()
			.unbind( this.eventNamespace )
			.removeAttr( "aria-disabled" )
			.removeClass(
				this.widgetFullName + "-disabled " +
				"ui-state-disabled" );

		// clean up events and states
		this.bindings.unbind( this.eventNamespace );
		this.hoverable.removeClass( "ui-state-hover" );
		this.focusable.removeClass( "ui-state-focus" );
	},
	_destroy: $.noop,

	widget: function() {
		return this.element;
	},

	option: function( key, value ) {
		var options = key,
			parts,
			curOption,
			i;

		if ( arguments.length === 0 ) {
			// don't return a reference to the internal hash
			return $.widget.extend( {}, this.options );
		}

		if ( typeof key === "string" ) {
			// handle nested keys, e.g., "foo.bar" => { foo: { bar: ___ } }
			options = {};
			parts = key.split( "." );
			key = parts.shift();
			if ( parts.length ) {
				curOption = options[ key ] = $.widget.extend( {}, this.options[ key ] );
				for ( i = 0; i < parts.length - 1; i++ ) {
					curOption[ parts[ i ] ] = curOption[ parts[ i ] ] || {};
					curOption = curOption[ parts[ i ] ];
				}
				key = parts.pop();
				if ( value === undefined ) {
					return curOption[ key ] === undefined ? null : curOption[ key ];
				}
				curOption[ key ] = value;
			} else {
				if ( value === undefined ) {
					return this.options[ key ] === undefined ? null : this.options[ key ];
				}
				options[ key ] = value;
			}
		}

		this._setOptions( options );

		return this;
	},
	_setOptions: function( options ) {
		var key;

		for ( key in options ) {
			this._setOption( key, options[ key ] );
		}

		return this;
	},
	_setOption: function( key, value ) {
		this.options[ key ] = value;

		if ( key === "disabled" ) {
			this.widget()
				.toggleClass( this.widgetFullName + "-disabled ui-state-disabled", !!value )
				.attr( "aria-disabled", value );
			this.hoverable.removeClass( "ui-state-hover" );
			this.focusable.removeClass( "ui-state-focus" );
		}

		return this;
	},

	enable: function() {
		return this._setOption( "disabled", false );
	},
	disable: function() {
		return this._setOption( "disabled", true );
	},

	_on: function( suppressDisabledCheck, element, handlers ) {
		var delegateElement,
			instance = this;

		// no suppressDisabledCheck flag, shuffle arguments
		if ( typeof suppressDisabledCheck !== "boolean" ) {
			handlers = element;
			element = suppressDisabledCheck;
			suppressDisabledCheck = false;
		}

		// no element argument, shuffle and use this.element
		if ( !handlers ) {
			handlers = element;
			element = this.element;
			delegateElement = this.widget();
		} else {
			// accept selectors, DOM elements
			element = delegateElement = $( element );
			this.bindings = this.bindings.add( element );
		}

		$.each( handlers, function( event, handler ) {
			function handlerProxy() {
				// allow widgets to customize the disabled handling
				// - disabled as an array instead of boolean
				// - disabled class as method for disabling individual parts
				if ( !suppressDisabledCheck &&
						( instance.options.disabled === true ||
							$( this ).hasClass( "ui-state-disabled" ) ) ) {
					return;
				}
				return ( typeof handler === "string" ? instance[ handler ] : handler )
					.apply( instance, arguments );
			}

			// copy the guid so direct unbinding works
			if ( typeof handler !== "string" ) {
				handlerProxy.guid = handler.guid =
					handler.guid || handlerProxy.guid || $.guid++;
			}

			var match = event.match( /^(\w+)\s*(.*)$/ ),
				eventName = match[1] + instance.eventNamespace,
				selector = match[2];
			if ( selector ) {
				delegateElement.delegate( selector, eventName, handlerProxy );
			} else {
				element.bind( eventName, handlerProxy );
			}
		});
	},

	_off: function( element, eventName ) {
		eventName = (eventName || "").split( " " ).join( this.eventNamespace + " " ) + this.eventNamespace;
		element.unbind( eventName ).undelegate( eventName );
	},

	_delay: function( handler, delay ) {
		function handlerProxy() {
			return ( typeof handler === "string" ? instance[ handler ] : handler )
				.apply( instance, arguments );
		}
		var instance = this;
		return setTimeout( handlerProxy, delay || 0 );
	},

	_hoverable: function( element ) {
		this.hoverable = this.hoverable.add( element );
		this._on( element, {
			mouseenter: function( event ) {
				$( event.currentTarget ).addClass( "ui-state-hover" );
			},
			mouseleave: function( event ) {
				$( event.currentTarget ).removeClass( "ui-state-hover" );
			}
		});
	},

	_focusable: function( element ) {
		this.focusable = this.focusable.add( element );
		this._on( element, {
			focusin: function( event ) {
				$( event.currentTarget ).addClass( "ui-state-focus" );
			},
			focusout: function( event ) {
				$( event.currentTarget ).removeClass( "ui-state-focus" );
			}
		});
	},

	_trigger: function( type, event, data ) {
		var prop, orig,
			callback = this.options[ type ];

		data = data || {};
		event = $.Event( event );
		event.type = ( type === this.widgetEventPrefix ?
			type :
			this.widgetEventPrefix + type ).toLowerCase();
		// the original event may come from any element
		// so we need to reset the target on the new event
		event.target = this.element[ 0 ];

		// copy original event properties over to the new event
		orig = event.originalEvent;
		if ( orig ) {
			for ( prop in orig ) {
				if ( !( prop in event ) ) {
					event[ prop ] = orig[ prop ];
				}
			}
		}

		this.element.trigger( event, data );
		return !( $.isFunction( callback ) &&
			callback.apply( this.element[0], [ event ].concat( data ) ) === false ||
			event.isDefaultPrevented() );
	}
};

$.each( { show: "fadeIn", hide: "fadeOut" }, function( method, defaultEffect ) {
	$.Widget.prototype[ "_" + method ] = function( element, options, callback ) {
		if ( typeof options === "string" ) {
			options = { effect: options };
		}
		var hasOptions,
			effectName = !options ?
				method :
				options === true || typeof options === "number" ?
					defaultEffect :
					options.effect || defaultEffect;
		options = options || {};
		if ( typeof options === "number" ) {
			options = { duration: options };
		}
		hasOptions = !$.isEmptyObject( options );
		options.complete = callback;
		if ( options.delay ) {
			element.delay( options.delay );
		}
		if ( hasOptions && $.effects && $.effects.effect[ effectName ] ) {
			element[ method ]( options );
		} else if ( effectName !== method && element[ effectName ] ) {
			element[ effectName ]( options.duration, options.easing, callback );
		} else {
			element.queue(function( next ) {
				$( this )[ method ]();
				if ( callback ) {
					callback.call( element[ 0 ] );
				}
				next();
			});
		}
	};
});

})( jQuery );


/*!
 * jQuery UI Mouse 1.10.2
 * http://jqueryui.com
 *
 * Copyright 2013 jQuery Foundation and other contributors
 * Released under the MIT license.
 * http://jquery.org/license
 *
 * http://api.jqueryui.com/mouse/
 *
 * Depends:
 *	jquery.ui.widget.js
 */
(function( $, undefined ) {

var mouseHandled = false;
$( document ).mouseup( function() {
	mouseHandled = false;
});

$.widget("ui.mouse", {
	version: "1.10.2",
	options: {
		cancel: "input,textarea,button,select,option",
		distance: 1,
		delay: 0
	},
	_mouseInit: function() {
		var that = this;

		this.element
			.bind("mousedown."+this.widgetName, function(event) {
				return that._mouseDown(event);
			})
			.bind("click."+this.widgetName, function(event) {
				if (true === $.data(event.target, that.widgetName + ".preventClickEvent")) {
					$.removeData(event.target, that.widgetName + ".preventClickEvent");
					event.stopImmediatePropagation();
					return false;
				}
			});

		this.started = false;
	},

	// TODO: make sure destroying one instance of mouse doesn't mess with
	// other instances of mouse
	_mouseDestroy: function() {
		this.element.unbind("."+this.widgetName);
		if ( this._mouseMoveDelegate ) {
			$(document)
				.unbind("mousemove."+this.widgetName, this._mouseMoveDelegate)
				.unbind("mouseup."+this.widgetName, this._mouseUpDelegate);
		}
	},

	_mouseDown: function(event) {
		// don't let more than one widget handle mouseStart
		if( mouseHandled ) { return; }

		// we may have missed mouseup (out of window)
		(this._mouseStarted && this._mouseUp(event));

		this._mouseDownEvent = event;

		var that = this,
			btnIsLeft = (event.which === 1),
			// event.target.nodeName works around a bug in IE 8 with
			// disabled inputs (#7620)
			elIsCancel = (typeof this.options.cancel === "string" && event.target.nodeName ? $(event.target).closest(this.options.cancel).length : false);
		if (!btnIsLeft || elIsCancel || !this._mouseCapture(event)) {
			return true;
		}

		this.mouseDelayMet = !this.options.delay;
		if (!this.mouseDelayMet) {
			this._mouseDelayTimer = setTimeout(function() {
				that.mouseDelayMet = true;
			}, this.options.delay);
		}

		if (this._mouseDistanceMet(event) && this._mouseDelayMet(event)) {
			this._mouseStarted = (this._mouseStart(event) !== false);
			if (!this._mouseStarted) {
				event.preventDefault();
				return true;
			}
		}

		// Click event may never have fired (Gecko & Opera)
		if (true === $.data(event.target, this.widgetName + ".preventClickEvent")) {
			$.removeData(event.target, this.widgetName + ".preventClickEvent");
		}

		// these delegates are required to keep context
		this._mouseMoveDelegate = function(event) {
			return that._mouseMove(event);
		};
		this._mouseUpDelegate = function(event) {
			return that._mouseUp(event);
		};
		$(document)
			.bind("mousemove."+this.widgetName, this._mouseMoveDelegate)
			.bind("mouseup."+this.widgetName, this._mouseUpDelegate);

		event.preventDefault();

		mouseHandled = true;
		return true;
	},

	_mouseMove: function(event) {
		// IE mouseup check - mouseup happened when mouse was out of window
		if ($.ui.ie && ( !document.documentMode || document.documentMode < 9 ) && !event.button) {
			return this._mouseUp(event);
		}

		if (this._mouseStarted) {
			this._mouseDrag(event);
			return event.preventDefault();
		}

		if (this._mouseDistanceMet(event) && this._mouseDelayMet(event)) {
			this._mouseStarted =
				(this._mouseStart(this._mouseDownEvent, event) !== false);
			(this._mouseStarted ? this._mouseDrag(event) : this._mouseUp(event));
		}

		return !this._mouseStarted;
	},

	_mouseUp: function(event) {
		$(document)
			.unbind("mousemove."+this.widgetName, this._mouseMoveDelegate)
			.unbind("mouseup."+this.widgetName, this._mouseUpDelegate);

		if (this._mouseStarted) {
			this._mouseStarted = false;

			if (event.target === this._mouseDownEvent.target) {
				$.data(event.target, this.widgetName + ".preventClickEvent", true);
			}

			this._mouseStop(event);
		}

		return false;
	},

	_mouseDistanceMet: function(event) {
		return (Math.max(
				Math.abs(this._mouseDownEvent.pageX - event.pageX),
				Math.abs(this._mouseDownEvent.pageY - event.pageY)
			) >= this.options.distance
		);
	},

	_mouseDelayMet: function(/* event */) {
		return this.mouseDelayMet;
	},

	// These are placeholder methods, to be overriden by extending plugin
	_mouseStart: function(/* event */) {},
	_mouseDrag: function(/* event */) {},
	_mouseStop: function(/* event */) {},
	_mouseCapture: function(/* event */) { return true; }
});

})(jQuery);


/*!
 * jQuery UI Draggable 1.10.2
 * http://jqueryui.com
 *
 * Copyright 2013 jQuery Foundation and other contributors
 * Released under the MIT license.
 * http://jquery.org/license
 *
 * http://api.jqueryui.com/draggable/
 *
 * Depends:
 *	jquery.ui.core.js
 *	jquery.ui.mouse.js
 *	jquery.ui.widget.js
 */
(function( $, undefined ) {

$.widget("ui.draggable", $.ui.mouse, {
	version: "1.10.2",
	widgetEventPrefix: "drag",
	options: {
		addClasses: true,
		appendTo: "parent",
		axis: false,
		connectToSortable: false,
		containment: false,
		cursor: "auto",
		cursorAt: false,
		grid: false,
		handle: false,
		helper: "original",
		iframeFix: false,
		opacity: false,
		refreshPositions: false,
		revert: false,
		revertDuration: 500,
		scope: "default",
		scroll: true,
		scrollSensitivity: 20,
		scrollSpeed: 20,
		snap: false,
		snapMode: "both",
		snapTolerance: 20,
		stack: false,
		zIndex: false,

		// callbacks
		drag: null,
		start: null,
		stop: null
	},
	_create: function() {

		if (this.options.helper === "original" && !(/^(?:r|a|f)/).test(this.element.css("position"))) {
			this.element[0].style.position = "relative";
		}
		if (this.options.addClasses){
			this.element.addClass("ui-draggable");
		}
		if (this.options.disabled){
			this.element.addClass("ui-draggable-disabled");
		}

		this._mouseInit();

	},

	_destroy: function() {
		this.element.removeClass( "ui-draggable ui-draggable-dragging ui-draggable-disabled" );
		this._mouseDestroy();
	},

	_mouseCapture: function(event) {

		var o = this.options;

		// among others, prevent a drag on a resizable-handle
		if (this.helper || o.disabled || $(event.target).closest(".ui-resizable-handle").length > 0) {
			return false;
		}

		//Quit if we're not on a valid handle
		this.handle = this._getHandle(event);
		if (!this.handle) {
			return false;
		}

		$(o.iframeFix === true ? "iframe" : o.iframeFix).each(function() {
			$("<div class='ui-draggable-iframeFix' style='background: #fff;'></div>")
			.css({
				width: this.offsetWidth+"px", height: this.offsetHeight+"px",
				position: "absolute", opacity: "0.001", zIndex: 1000
			})
			.css($(this).offset())
			.appendTo("body");
		});

		return true;

	},

	_mouseStart: function(event) {

		var o = this.options;

		//Create and append the visible helper
		this.helper = this._createHelper(event);

		this.helper.addClass("ui-draggable-dragging");

		//Cache the helper size
		this._cacheHelperProportions();

		//If ddmanager is used for droppables, set the global draggable
		if($.ui.ddmanager) {
			$.ui.ddmanager.current = this;
		}

		/*
		 * - Position generation -
		 * This block generates everything position related - it's the core of draggables.
		 */

		//Cache the margins of the original element
		this._cacheMargins();

		//Store the helper's css position
		this.cssPosition = this.helper.css("position");
		this.scrollParent = this.helper.scrollParent();

		//The element's absolute position on the page minus margins
		this.offset = this.positionAbs = this.element.offset();
		this.offset = {
			top: this.offset.top - this.margins.top,
			left: this.offset.left - this.margins.left
		};

		$.extend(this.offset, {
			click: { //Where the click happened, relative to the element
				left: event.pageX - this.offset.left,
				top: event.pageY - this.offset.top
			},
			parent: this._getParentOffset(),
			relative: this._getRelativeOffset() //This is a relative to absolute position minus the actual position calculation - only used for relative positioned helper
		});

		//Generate the original position
		this.originalPosition = this.position = this._generatePosition(event);
		this.originalPageX = event.pageX;
		this.originalPageY = event.pageY;

		//Adjust the mouse offset relative to the helper if "cursorAt" is supplied
		(o.cursorAt && this._adjustOffsetFromHelper(o.cursorAt));

		//Set a containment if given in the options
		if(o.containment) {
			this._setContainment();
		}

		//Trigger event + callbacks
		if(this._trigger("start", event) === false) {
			this._clear();
			return false;
		}

		//Recache the helper size
		this._cacheHelperProportions();

		//Prepare the droppable offsets
		if ($.ui.ddmanager && !o.dropBehaviour) {
			$.ui.ddmanager.prepareOffsets(this, event);
		}


		this._mouseDrag(event, true); //Execute the drag once - this causes the helper not to be visible before getting its correct position

		//If the ddmanager is used for droppables, inform the manager that dragging has started (see #5003)
		if ( $.ui.ddmanager ) {
			$.ui.ddmanager.dragStart(this, event);
		}

		return true;
	},

	_mouseDrag: function(event, noPropagation) {

		//Compute the helpers position
		this.position = this._generatePosition(event);
		this.positionAbs = this._convertPositionTo("absolute");

		//Call plugins and callbacks and use the resulting position if something is returned
		if (!noPropagation) {
			var ui = this._uiHash();
			if(this._trigger("drag", event, ui) === false) {
				this._mouseUp({});
				return false;
			}
			this.position = ui.position;
		}

		if(!this.options.axis || this.options.axis !== "y") {
			this.helper[0].style.left = this.position.left+"px";
		}
		if(!this.options.axis || this.options.axis !== "x") {
			this.helper[0].style.top = this.position.top+"px";
		}
		if($.ui.ddmanager) {
			$.ui.ddmanager.drag(this, event);
		}

		return false;
	},

	_mouseStop: function(event) {

		//If we are using droppables, inform the manager about the drop
		var element,
			that = this,
			elementInDom = false,
			dropped = false;
		if ($.ui.ddmanager && !this.options.dropBehaviour) {
			dropped = $.ui.ddmanager.drop(this, event);
		}

		//if a drop comes from outside (a sortable)
		if(this.dropped) {
			dropped = this.dropped;
			this.dropped = false;
		}

		//if the original element is no longer in the DOM don't bother to continue (see #8269)
		element = this.element[0];
		while ( element && (element = element.parentNode) ) {
			if (element === document ) {
				elementInDom = true;
			}
		}
		if ( !elementInDom && this.options.helper === "original" ) {
			return false;
		}

		if((this.options.revert === "invalid" && !dropped) || (this.options.revert === "valid" && dropped) || this.options.revert === true || ($.isFunction(this.options.revert) && this.options.revert.call(this.element, dropped))) {
			$(this.helper).animate(this.originalPosition, parseInt(this.options.revertDuration, 10), function() {
				if(that._trigger("stop", event) !== false) {
					that._clear();
				}
			});
		} else {
			if(this._trigger("stop", event) !== false) {
				this._clear();
			}
		}

		return false;
	},

	_mouseUp: function(event) {
		//Remove frame helpers
		$("div.ui-draggable-iframeFix").each(function() {
			this.parentNode.removeChild(this);
		});

		//If the ddmanager is used for droppables, inform the manager that dragging has stopped (see #5003)
		if( $.ui.ddmanager ) {
			$.ui.ddmanager.dragStop(this, event);
		}

		return $.ui.mouse.prototype._mouseUp.call(this, event);
	},

	cancel: function() {

		if(this.helper.is(".ui-draggable-dragging")) {
			this._mouseUp({});
		} else {
			this._clear();
		}

		return this;

	},

	_getHandle: function(event) {
		return this.options.handle ?
			!!$( event.target ).closest( this.element.find( this.options.handle ) ).length :
			true;
	},

	_createHelper: function(event) {

		var o = this.options,
			helper = $.isFunction(o.helper) ? $(o.helper.apply(this.element[0], [event])) : (o.helper === "clone" ? this.element.clone().removeAttr("id") : this.element);

		if(!helper.parents("body").length) {
			helper.appendTo((o.appendTo === "parent" ? this.element[0].parentNode : o.appendTo));
		}

		if(helper[0] !== this.element[0] && !(/(fixed|absolute)/).test(helper.css("position"))) {
			helper.css("position", "absolute");
		}

		return helper;

	},

	_adjustOffsetFromHelper: function(obj) {
		if (typeof obj === "string") {
			obj = obj.split(" ");
		}
		if ($.isArray(obj)) {
			obj = {left: +obj[0], top: +obj[1] || 0};
		}
		if ("left" in obj) {
			this.offset.click.left = obj.left + this.margins.left;
		}
		if ("right" in obj) {
			this.offset.click.left = this.helperProportions.width - obj.right + this.margins.left;
		}
		if ("top" in obj) {
			this.offset.click.top = obj.top + this.margins.top;
		}
		if ("bottom" in obj) {
			this.offset.click.top = this.helperProportions.height - obj.bottom + this.margins.top;
		}
	},

	_getParentOffset: function() {

		//Get the offsetParent and cache its position
		this.offsetParent = this.helper.offsetParent();
		var po = this.offsetParent.offset();

		// This is a special case where we need to modify a offset calculated on start, since the following happened:
		// 1. The position of the helper is absolute, so it's position is calculated based on the next positioned parent
		// 2. The actual offset parent is a child of the scroll parent, and the scroll parent isn't the document, which means that
		//    the scroll is included in the initial calculation of the offset of the parent, and never recalculated upon drag
		if(this.cssPosition === "absolute" && this.scrollParent[0] !== document && $.contains(this.scrollParent[0], this.offsetParent[0])) {
			po.left += this.scrollParent.scrollLeft();
			po.top += this.scrollParent.scrollTop();
		}

		//This needs to be actually done for all browsers, since pageX/pageY includes this information
		//Ugly IE fix
		if((this.offsetParent[0] === document.body) ||
			(this.offsetParent[0].tagName && this.offsetParent[0].tagName.toLowerCase() === "html" && $.ui.ie)) {
			po = { top: 0, left: 0 };
		}

		return {
			top: po.top + (parseInt(this.offsetParent.css("borderTopWidth"),10) || 0),
			left: po.left + (parseInt(this.offsetParent.css("borderLeftWidth"),10) || 0)
		};

	},

	_getRelativeOffset: function() {

		if(this.cssPosition === "relative") {
			var p = this.element.position();
			return {
				top: p.top - (parseInt(this.helper.css("top"),10) || 0) + this.scrollParent.scrollTop(),
				left: p.left - (parseInt(this.helper.css("left"),10) || 0) + this.scrollParent.scrollLeft()
			};
		} else {
			return { top: 0, left: 0 };
		}

	},

	_cacheMargins: function() {
		this.margins = {
			left: (parseInt(this.element.css("marginLeft"),10) || 0),
			top: (parseInt(this.element.css("marginTop"),10) || 0),
			right: (parseInt(this.element.css("marginRight"),10) || 0),
			bottom: (parseInt(this.element.css("marginBottom"),10) || 0)
		};
	},

	_cacheHelperProportions: function() {
		this.helperProportions = {
			width: this.helper.outerWidth(),
			height: this.helper.outerHeight()
		};
	},

	_setContainment: function() {

		var over, c, ce,
			o = this.options;

		if(o.containment === "parent") {
			o.containment = this.helper[0].parentNode;
		}
		if(o.containment === "document" || o.containment === "window") {
			this.containment = [
				o.containment === "document" ? 0 : $(window).scrollLeft() - this.offset.relative.left - this.offset.parent.left,
				o.containment === "document" ? 0 : $(window).scrollTop() - this.offset.relative.top - this.offset.parent.top,
				(o.containment === "document" ? 0 : $(window).scrollLeft()) + $(o.containment === "document" ? document : window).width() - this.helperProportions.width - this.margins.left,
				(o.containment === "document" ? 0 : $(window).scrollTop()) + ($(o.containment === "document" ? document : window).height() || document.body.parentNode.scrollHeight) - this.helperProportions.height - this.margins.top
			];
		}

		if(!(/^(document|window|parent)$/).test(o.containment) && o.containment.constructor !== Array) {
			c = $(o.containment);
			ce = c[0];

			if(!ce) {
				return;
			}

			over = ($(ce).css("overflow") !== "hidden");

			this.containment = [
				(parseInt($(ce).css("borderLeftWidth"),10) || 0) + (parseInt($(ce).css("paddingLeft"),10) || 0),
				(parseInt($(ce).css("borderTopWidth"),10) || 0) + (parseInt($(ce).css("paddingTop"),10) || 0),
				(over ? Math.max(ce.scrollWidth,ce.offsetWidth) : ce.offsetWidth) - (parseInt($(ce).css("borderRightWidth"),10) || 0) - (parseInt($(ce).css("paddingRight"),10) || 0) - this.helperProportions.width - this.margins.left - this.margins.right,
				(over ? Math.max(ce.scrollHeight,ce.offsetHeight) : ce.offsetHeight) - (parseInt($(ce).css("borderBottomWidth"),10) || 0) - (parseInt($(ce).css("paddingBottom"),10) || 0) - this.helperProportions.height - this.margins.top  - this.margins.bottom
			];
			this.relative_container = c;

		} else if(o.containment.constructor === Array) {
			this.containment = o.containment;
		}

	},

	_convertPositionTo: function(d, pos) {

		if(!pos) {
			pos = this.position;
		}

		var mod = d === "absolute" ? 1 : -1,
			scroll = this.cssPosition === "absolute" && !(this.scrollParent[0] !== document && $.contains(this.scrollParent[0], this.offsetParent[0])) ? this.offsetParent : this.scrollParent, scrollIsRootNode = (/(html|body)/i).test(scroll[0].tagName);

		return {
			top: (
				pos.top	+																// The absolute mouse position
				this.offset.relative.top * mod +										// Only for relative positioned nodes: Relative offset from element to offset parent
				this.offset.parent.top * mod -										// The offsetParent's offset without borders (offset + border)
				( ( this.cssPosition === "fixed" ? -this.scrollParent.scrollTop() : ( scrollIsRootNode ? 0 : scroll.scrollTop() ) ) * mod)
			),
			left: (
				pos.left +																// The absolute mouse position
				this.offset.relative.left * mod +										// Only for relative positioned nodes: Relative offset from element to offset parent
				this.offset.parent.left * mod	-										// The offsetParent's offset without borders (offset + border)
				( ( this.cssPosition === "fixed" ? -this.scrollParent.scrollLeft() : scrollIsRootNode ? 0 : scroll.scrollLeft() ) * mod)
			)
		};

	},

	_generatePosition: function(event) {

		var containment, co, top, left,
			o = this.options,
			scroll = this.cssPosition === "absolute" && !(this.scrollParent[0] !== document && $.contains(this.scrollParent[0], this.offsetParent[0])) ? this.offsetParent : this.scrollParent,
			scrollIsRootNode = (/(html|body)/i).test(scroll[0].tagName),
			pageX = event.pageX,
			pageY = event.pageY;

		/*
		 * - Position constraining -
		 * Constrain the position to a mix of grid, containment.
		 */

		if(this.originalPosition) { //If we are not dragging yet, we won't check for options
			if(this.containment) {
			if (this.relative_container){
				co = this.relative_container.offset();
				containment = [ this.containment[0] + co.left,
					this.containment[1] + co.top,
					this.containment[2] + co.left,
					this.containment[3] + co.top ];
			}
			else {
				containment = this.containment;
			}

				if(event.pageX - this.offset.click.left < containment[0]) {
					pageX = containment[0] + this.offset.click.left;
				}
				if(event.pageY - this.offset.click.top < containment[1]) {
					pageY = containment[1] + this.offset.click.top;
				}
				if(event.pageX - this.offset.click.left > containment[2]) {
					pageX = containment[2] + this.offset.click.left;
				}
				if(event.pageY - this.offset.click.top > containment[3]) {
					pageY = containment[3] + this.offset.click.top;
				}
			}

			if(o.grid) {
				//Check for grid elements set to 0 to prevent divide by 0 error causing invalid argument errors in IE (see ticket #6950)
				top = o.grid[1] ? this.originalPageY + Math.round((pageY - this.originalPageY) / o.grid[1]) * o.grid[1] : this.originalPageY;
				pageY = containment ? ((top - this.offset.click.top >= containment[1] || top - this.offset.click.top > containment[3]) ? top : ((top - this.offset.click.top >= containment[1]) ? top - o.grid[1] : top + o.grid[1])) : top;

				left = o.grid[0] ? this.originalPageX + Math.round((pageX - this.originalPageX) / o.grid[0]) * o.grid[0] : this.originalPageX;
				pageX = containment ? ((left - this.offset.click.left >= containment[0] || left - this.offset.click.left > containment[2]) ? left : ((left - this.offset.click.left >= containment[0]) ? left - o.grid[0] : left + o.grid[0])) : left;
			}

		}

		return {
			top: (
				pageY -																	// The absolute mouse position
				this.offset.click.top	-												// Click offset (relative to the element)
				this.offset.relative.top -												// Only for relative positioned nodes: Relative offset from element to offset parent
				this.offset.parent.top +												// The offsetParent's offset without borders (offset + border)
				( ( this.cssPosition === "fixed" ? -this.scrollParent.scrollTop() : ( scrollIsRootNode ? 0 : scroll.scrollTop() ) ))
			),
			left: (
				pageX -																	// The absolute mouse position
				this.offset.click.left -												// Click offset (relative to the element)
				this.offset.relative.left -												// Only for relative positioned nodes: Relative offset from element to offset parent
				this.offset.parent.left +												// The offsetParent's offset without borders (offset + border)
				( ( this.cssPosition === "fixed" ? -this.scrollParent.scrollLeft() : scrollIsRootNode ? 0 : scroll.scrollLeft() ))
			)
		};

	},

	_clear: function() {
		this.helper.removeClass("ui-draggable-dragging");
		if(this.helper[0] !== this.element[0] && !this.cancelHelperRemoval) {
			this.helper.remove();
		}
		this.helper = null;
		this.cancelHelperRemoval = false;
	},

	// From now on bulk stuff - mainly helpers

	_trigger: function(type, event, ui) {
		ui = ui || this._uiHash();
		$.ui.plugin.call(this, type, [event, ui]);
		//The absolute position has to be recalculated after plugins
		if(type === "drag") {
			this.positionAbs = this._convertPositionTo("absolute");
		}
		return $.Widget.prototype._trigger.call(this, type, event, ui);
	},

	plugins: {},

	_uiHash: function() {
		return {
			helper: this.helper,
			position: this.position,
			originalPosition: this.originalPosition,
			offset: this.positionAbs
		};
	}

});

$.ui.plugin.add("draggable", "connectToSortable", {
	start: function(event, ui) {

		var inst = $(this).data("ui-draggable"), o = inst.options,
			uiSortable = $.extend({}, ui, { item: inst.element });
		inst.sortables = [];
		$(o.connectToSortable).each(function() {
			var sortable = $.data(this, "ui-sortable");
			if (sortable && !sortable.options.disabled) {
				inst.sortables.push({
					instance: sortable,
					shouldRevert: sortable.options.revert
				});
				sortable.refreshPositions();	// Call the sortable's refreshPositions at drag start to refresh the containerCache since the sortable container cache is used in drag and needs to be up to date (this will ensure it's initialised as well as being kept in step with any changes that might have happened on the page).
				sortable._trigger("activate", event, uiSortable);
			}
		});

	},
	stop: function(event, ui) {

		//If we are still over the sortable, we fake the stop event of the sortable, but also remove helper
		var inst = $(this).data("ui-draggable"),
			uiSortable = $.extend({}, ui, { item: inst.element });

		$.each(inst.sortables, function() {
			if(this.instance.isOver) {

				this.instance.isOver = 0;

				inst.cancelHelperRemoval = true; //Don't remove the helper in the draggable instance
				this.instance.cancelHelperRemoval = false; //Remove it in the sortable instance (so sortable plugins like revert still work)

				//The sortable revert is supported, and we have to set a temporary dropped variable on the draggable to support revert: "valid/invalid"
				if(this.shouldRevert) {
					this.instance.options.revert = this.shouldRevert;
				}

				//Trigger the stop of the sortable
				this.instance._mouseStop(event);

				this.instance.options.helper = this.instance.options._helper;

				//If the helper has been the original item, restore properties in the sortable
				if(inst.options.helper === "original") {
					this.instance.currentItem.css({ top: "auto", left: "auto" });
				}

			} else {
				this.instance.cancelHelperRemoval = false; //Remove the helper in the sortable instance
				this.instance._trigger("deactivate", event, uiSortable);
			}

		});

	},
	drag: function(event, ui) {

		var inst = $(this).data("ui-draggable"), that = this;

		$.each(inst.sortables, function() {

			var innermostIntersecting = false,
				thisSortable = this;

			//Copy over some variables to allow calling the sortable's native _intersectsWith
			this.instance.positionAbs = inst.positionAbs;
			this.instance.helperProportions = inst.helperProportions;
			this.instance.offset.click = inst.offset.click;

			if(this.instance._intersectsWith(this.instance.containerCache)) {
				innermostIntersecting = true;
				$.each(inst.sortables, function () {
					this.instance.positionAbs = inst.positionAbs;
					this.instance.helperProportions = inst.helperProportions;
					this.instance.offset.click = inst.offset.click;
					if (this !== thisSortable &&
						this.instance._intersectsWith(this.instance.containerCache) &&
						$.contains(thisSortable.instance.element[0], this.instance.element[0])
					) {
						innermostIntersecting = false;
					}
					return innermostIntersecting;
				});
			}


			if(innermostIntersecting) {
				//If it intersects, we use a little isOver variable and set it once, so our move-in stuff gets fired only once
				if(!this.instance.isOver) {

					this.instance.isOver = 1;
					//Now we fake the start of dragging for the sortable instance,
					//by cloning the list group item, appending it to the sortable and using it as inst.currentItem
					//We can then fire the start event of the sortable with our passed browser event, and our own helper (so it doesn't create a new one)
					this.instance.currentItem = $(that).clone().removeAttr("id").appendTo(this.instance.element).data("ui-sortable-item", true);
					this.instance.options._helper = this.instance.options.helper; //Store helper option to later restore it
					this.instance.options.helper = function() { return ui.helper[0]; };

					event.target = this.instance.currentItem[0];
					this.instance._mouseCapture(event, true);
					this.instance._mouseStart(event, true, true);

					//Because the browser event is way off the new appended portlet, we modify a couple of variables to reflect the changes
					this.instance.offset.click.top = inst.offset.click.top;
					this.instance.offset.click.left = inst.offset.click.left;
					this.instance.offset.parent.left -= inst.offset.parent.left - this.instance.offset.parent.left;
					this.instance.offset.parent.top -= inst.offset.parent.top - this.instance.offset.parent.top;

					inst._trigger("toSortable", event);
					inst.dropped = this.instance.element; //draggable revert needs that
					//hack so receive/update callbacks work (mostly)
					inst.currentItem = inst.element;
					this.instance.fromOutside = inst;

				}

				//Provided we did all the previous steps, we can fire the drag event of the sortable on every draggable drag, when it intersects with the sortable
				if(this.instance.currentItem) {
					this.instance._mouseDrag(event);
				}

			} else {

				//If it doesn't intersect with the sortable, and it intersected before,
				//we fake the drag stop of the sortable, but make sure it doesn't remove the helper by using cancelHelperRemoval
				if(this.instance.isOver) {

					this.instance.isOver = 0;
					this.instance.cancelHelperRemoval = true;

					//Prevent reverting on this forced stop
					this.instance.options.revert = false;

					// The out event needs to be triggered independently
					this.instance._trigger("out", event, this.instance._uiHash(this.instance));

					this.instance._mouseStop(event, true);
					this.instance.options.helper = this.instance.options._helper;

					//Now we remove our currentItem, the list group clone again, and the placeholder, and animate the helper back to it's original size
					this.instance.currentItem.remove();
					if(this.instance.placeholder) {
						this.instance.placeholder.remove();
					}

					inst._trigger("fromSortable", event);
					inst.dropped = false; //draggable revert needs that
				}

			}

		});

	}
});

$.ui.plugin.add("draggable", "cursor", {
	start: function() {
		var t = $("body"), o = $(this).data("ui-draggable").options;
		if (t.css("cursor")) {
			o._cursor = t.css("cursor");
		}
		t.css("cursor", o.cursor);
	},
	stop: function() {
		var o = $(this).data("ui-draggable").options;
		if (o._cursor) {
			$("body").css("cursor", o._cursor);
		}
	}
});

$.ui.plugin.add("draggable", "opacity", {
	start: function(event, ui) {
		var t = $(ui.helper), o = $(this).data("ui-draggable").options;
		if(t.css("opacity")) {
			o._opacity = t.css("opacity");
		}
		t.css("opacity", o.opacity);
	},
	stop: function(event, ui) {
		var o = $(this).data("ui-draggable").options;
		if(o._opacity) {
			$(ui.helper).css("opacity", o._opacity);
		}
	}
});

$.ui.plugin.add("draggable", "scroll", {
	start: function() {
		var i = $(this).data("ui-draggable");
		if(i.scrollParent[0] !== document && i.scrollParent[0].tagName !== "HTML") {
			i.overflowOffset = i.scrollParent.offset();
		}
	},
	drag: function( event ) {

		var i = $(this).data("ui-draggable"), o = i.options, scrolled = false;

		if(i.scrollParent[0] !== document && i.scrollParent[0].tagName !== "HTML") {

			if(!o.axis || o.axis !== "x") {
				if((i.overflowOffset.top + i.scrollParent[0].offsetHeight) - event.pageY < o.scrollSensitivity) {
					i.scrollParent[0].scrollTop = scrolled = i.scrollParent[0].scrollTop + o.scrollSpeed;
				} else if(event.pageY - i.overflowOffset.top < o.scrollSensitivity) {
					i.scrollParent[0].scrollTop = scrolled = i.scrollParent[0].scrollTop - o.scrollSpeed;
				}
			}

			if(!o.axis || o.axis !== "y") {
				if((i.overflowOffset.left + i.scrollParent[0].offsetWidth) - event.pageX < o.scrollSensitivity) {
					i.scrollParent[0].scrollLeft = scrolled = i.scrollParent[0].scrollLeft + o.scrollSpeed;
				} else if(event.pageX - i.overflowOffset.left < o.scrollSensitivity) {
					i.scrollParent[0].scrollLeft = scrolled = i.scrollParent[0].scrollLeft - o.scrollSpeed;
				}
			}

		} else {

			if(!o.axis || o.axis !== "x") {
				if(event.pageY - $(document).scrollTop() < o.scrollSensitivity) {
					scrolled = $(document).scrollTop($(document).scrollTop() - o.scrollSpeed);
				} else if($(window).height() - (event.pageY - $(document).scrollTop()) < o.scrollSensitivity) {
					scrolled = $(document).scrollTop($(document).scrollTop() + o.scrollSpeed);
				}
			}

			if(!o.axis || o.axis !== "y") {
				if(event.pageX - $(document).scrollLeft() < o.scrollSensitivity) {
					scrolled = $(document).scrollLeft($(document).scrollLeft() - o.scrollSpeed);
				} else if($(window).width() - (event.pageX - $(document).scrollLeft()) < o.scrollSensitivity) {
					scrolled = $(document).scrollLeft($(document).scrollLeft() + o.scrollSpeed);
				}
			}

		}

		if(scrolled !== false && $.ui.ddmanager && !o.dropBehaviour) {
			$.ui.ddmanager.prepareOffsets(i, event);
		}

	}
});

$.ui.plugin.add("draggable", "snap", {
	start: function() {

		var i = $(this).data("ui-draggable"),
			o = i.options;

		i.snapElements = [];

		$(o.snap.constructor !== String ? ( o.snap.items || ":data(ui-draggable)" ) : o.snap).each(function() {
			var $t = $(this),
				$o = $t.offset();
			if(this !== i.element[0]) {
				i.snapElements.push({
					item: this,
					width: $t.outerWidth(), height: $t.outerHeight(),
					top: $o.top, left: $o.left
				});
			}
		});

	},
	drag: function(event, ui) {

		var ts, bs, ls, rs, l, r, t, b, i, first,
			inst = $(this).data("ui-draggable"),
			o = inst.options,
			d = o.snapTolerance,
			x1 = ui.offset.left, x2 = x1 + inst.helperProportions.width,
			y1 = ui.offset.top, y2 = y1 + inst.helperProportions.height;

		for (i = inst.snapElements.length - 1; i >= 0; i--){

			l = inst.snapElements[i].left;
			r = l + inst.snapElements[i].width;
			t = inst.snapElements[i].top;
			b = t + inst.snapElements[i].height;

			//Yes, I know, this is insane ;)
			if(!((l-d < x1 && x1 < r+d && t-d < y1 && y1 < b+d) || (l-d < x1 && x1 < r+d && t-d < y2 && y2 < b+d) || (l-d < x2 && x2 < r+d && t-d < y1 && y1 < b+d) || (l-d < x2 && x2 < r+d && t-d < y2 && y2 < b+d))) {
				if(inst.snapElements[i].snapping) {
					(inst.options.snap.release && inst.options.snap.release.call(inst.element, event, $.extend(inst._uiHash(), { snapItem: inst.snapElements[i].item })));
				}
				inst.snapElements[i].snapping = false;
				continue;
			}

			if(o.snapMode !== "inner") {
				ts = Math.abs(t - y2) <= d;
				bs = Math.abs(b - y1) <= d;
				ls = Math.abs(l - x2) <= d;
				rs = Math.abs(r - x1) <= d;
				if(ts) {
					ui.position.top = inst._convertPositionTo("relative", { top: t - inst.helperProportions.height, left: 0 }).top - inst.margins.top;
				}
				if(bs) {
					ui.position.top = inst._convertPositionTo("relative", { top: b, left: 0 }).top - inst.margins.top;
				}
				if(ls) {
					ui.position.left = inst._convertPositionTo("relative", { top: 0, left: l - inst.helperProportions.width }).left - inst.margins.left;
				}
				if(rs) {
					ui.position.left = inst._convertPositionTo("relative", { top: 0, left: r }).left - inst.margins.left;
				}
			}

			first = (ts || bs || ls || rs);

			if(o.snapMode !== "outer") {
				ts = Math.abs(t - y1) <= d;
				bs = Math.abs(b - y2) <= d;
				ls = Math.abs(l - x1) <= d;
				rs = Math.abs(r - x2) <= d;
				if(ts) {
					ui.position.top = inst._convertPositionTo("relative", { top: t, left: 0 }).top - inst.margins.top;
				}
				if(bs) {
					ui.position.top = inst._convertPositionTo("relative", { top: b - inst.helperProportions.height, left: 0 }).top - inst.margins.top;
				}
				if(ls) {
					ui.position.left = inst._convertPositionTo("relative", { top: 0, left: l }).left - inst.margins.left;
				}
				if(rs) {
					ui.position.left = inst._convertPositionTo("relative", { top: 0, left: r - inst.helperProportions.width }).left - inst.margins.left;
				}
			}

			if(!inst.snapElements[i].snapping && (ts || bs || ls || rs || first)) {
				(inst.options.snap.snap && inst.options.snap.snap.call(inst.element, event, $.extend(inst._uiHash(), { snapItem: inst.snapElements[i].item })));
			}
			inst.snapElements[i].snapping = (ts || bs || ls || rs || first);

		}

	}
});

$.ui.plugin.add("draggable", "stack", {
	start: function() {
		var min,
			o = this.data("ui-draggable").options,
			group = $.makeArray($(o.stack)).sort(function(a,b) {
				return (parseInt($(a).css("zIndex"),10) || 0) - (parseInt($(b).css("zIndex"),10) || 0);
			});

		if (!group.length) { return; }

		min = parseInt($(group[0]).css("zIndex"), 10) || 0;
		$(group).each(function(i) {
			$(this).css("zIndex", min + i);
		});
		this.css("zIndex", (min + group.length));
	}
});

$.ui.plugin.add("draggable", "zIndex", {
	start: function(event, ui) {
		var t = $(ui.helper), o = $(this).data("ui-draggable").options;
		if(t.css("zIndex")) {
			o._zIndex = t.css("zIndex");
		}
		t.css("zIndex", o.zIndex);
	},
	stop: function(event, ui) {
		var o = $(this).data("ui-draggable").options;
		if(o._zIndex) {
			$(ui.helper).css("zIndex", o._zIndex);
		}
	}
});

})(jQuery);


/*!
 * jQuery UI Droppable 1.10.2
 * http://jqueryui.com
 *
 * Copyright 2013 jQuery Foundation and other contributors
 * Released under the MIT license.
 * http://jquery.org/license
 *
 * http://api.jqueryui.com/droppable/
 *
 * Depends:
 *	jquery.ui.core.js
 *	jquery.ui.widget.js
 *	jquery.ui.mouse.js
 *	jquery.ui.draggable.js
 */
(function( $, undefined ) {

function isOverAxis( x, reference, size ) {
	return ( x > reference ) && ( x < ( reference + size ) );
}

$.widget("ui.droppable", {
	version: "1.10.2",
	widgetEventPrefix: "drop",
	options: {
		accept: "*",
		activeClass: false,
		addClasses: true,
		greedy: false,
		hoverClass: false,
		scope: "default",
		tolerance: "intersect",

		// callbacks
		activate: null,
		deactivate: null,
		drop: null,
		out: null,
		over: null
	},
	_create: function() {

		var o = this.options,
			accept = o.accept;

		this.isover = false;
		this.isout = true;

		this.accept = $.isFunction(accept) ? accept : function(d) {
			return d.is(accept);
		};

		//Store the droppable's proportions
		this.proportions = { width: this.element[0].offsetWidth, height: this.element[0].offsetHeight };

		// Add the reference and positions to the manager
		$.ui.ddmanager.droppables[o.scope] = $.ui.ddmanager.droppables[o.scope] || [];
		$.ui.ddmanager.droppables[o.scope].push(this);

		(o.addClasses && this.element.addClass("ui-droppable"));

	},

	_destroy: function() {
		var i = 0,
			drop = $.ui.ddmanager.droppables[this.options.scope];

		for ( ; i < drop.length; i++ ) {
			if ( drop[i] === this ) {
				drop.splice(i, 1);
			}
		}

		this.element.removeClass("ui-droppable ui-droppable-disabled");
	},

	_setOption: function(key, value) {

		if(key === "accept") {
			this.accept = $.isFunction(value) ? value : function(d) {
				return d.is(value);
			};
		}
		$.Widget.prototype._setOption.apply(this, arguments);
	},

	_activate: function(event) {
		var draggable = $.ui.ddmanager.current;
		if(this.options.activeClass) {
			this.element.addClass(this.options.activeClass);
		}
		if(draggable){
			this._trigger("activate", event, this.ui(draggable));
		}
	},

	_deactivate: function(event) {
		var draggable = $.ui.ddmanager.current;
		if(this.options.activeClass) {
			this.element.removeClass(this.options.activeClass);
		}
		if(draggable){
			this._trigger("deactivate", event, this.ui(draggable));
		}
	},

	_over: function(event) {

		var draggable = $.ui.ddmanager.current;

		// Bail if draggable and droppable are same element
		if (!draggable || (draggable.currentItem || draggable.element)[0] === this.element[0]) {
			return;
		}

		if (this.accept.call(this.element[0],(draggable.currentItem || draggable.element))) {
			if(this.options.hoverClass) {
				this.element.addClass(this.options.hoverClass);
			}
			this._trigger("over", event, this.ui(draggable));
		}

	},

	_out: function(event) {

		var draggable = $.ui.ddmanager.current;

		// Bail if draggable and droppable are same element
		if (!draggable || (draggable.currentItem || draggable.element)[0] === this.element[0]) {
			return;
		}

		if (this.accept.call(this.element[0],(draggable.currentItem || draggable.element))) {
			if(this.options.hoverClass) {
				this.element.removeClass(this.options.hoverClass);
			}
			this._trigger("out", event, this.ui(draggable));
		}

	},

	_drop: function(event,custom) {

		var draggable = custom || $.ui.ddmanager.current,
			childrenIntersection = false;

		// Bail if draggable and droppable are same element
		if (!draggable || (draggable.currentItem || draggable.element)[0] === this.element[0]) {
			return false;
		}

		this.element.find(":data(ui-droppable)").not(".ui-draggable-dragging").each(function() {
			var inst = $.data(this, "ui-droppable");
			if(
				inst.options.greedy &&
				!inst.options.disabled &&
				inst.options.scope === draggable.options.scope &&
				inst.accept.call(inst.element[0], (draggable.currentItem || draggable.element)) &&
				$.ui.intersect(draggable, $.extend(inst, { offset: inst.element.offset() }), inst.options.tolerance)
			) { childrenIntersection = true; return false; }
		});
		if(childrenIntersection) {
			return false;
		}

		if(this.accept.call(this.element[0],(draggable.currentItem || draggable.element))) {
			if(this.options.activeClass) {
				this.element.removeClass(this.options.activeClass);
			}
			if(this.options.hoverClass) {
				this.element.removeClass(this.options.hoverClass);
			}
			this._trigger("drop", event, this.ui(draggable));
			return this.element;
		}

		return false;

	},

	ui: function(c) {
		return {
			draggable: (c.currentItem || c.element),
			helper: c.helper,
			position: c.position,
			offset: c.positionAbs
		};
	}

});

$.ui.intersect = function(draggable, droppable, toleranceMode) {

	if (!droppable.offset) {
		return false;
	}

	var draggableLeft, draggableTop,
		x1 = (draggable.positionAbs || draggable.position.absolute).left, x2 = x1 + draggable.helperProportions.width,
		y1 = (draggable.positionAbs || draggable.position.absolute).top, y2 = y1 + draggable.helperProportions.height,
		l = droppable.offset.left, r = l + droppable.proportions.width,
		t = droppable.offset.top, b = t + droppable.proportions.height;

	switch (toleranceMode) {
		case "fit":
			return (l <= x1 && x2 <= r && t <= y1 && y2 <= b);
		case "intersect":
			return (l < x1 + (draggable.helperProportions.width / 2) && // Right Half
				x2 - (draggable.helperProportions.width / 2) < r && // Left Half
				t < y1 + (draggable.helperProportions.height / 2) && // Bottom Half
				y2 - (draggable.helperProportions.height / 2) < b ); // Top Half
		case "pointer":
			draggableLeft = ((draggable.positionAbs || draggable.position.absolute).left + (draggable.clickOffset || draggable.offset.click).left);
			draggableTop = ((draggable.positionAbs || draggable.position.absolute).top + (draggable.clickOffset || draggable.offset.click).top);
			return isOverAxis( draggableTop, t, droppable.proportions.height ) && isOverAxis( draggableLeft, l, droppable.proportions.width );
		case "touch":
			return (
				(y1 >= t && y1 <= b) ||	// Top edge touching
				(y2 >= t && y2 <= b) ||	// Bottom edge touching
				(y1 < t && y2 > b)		// Surrounded vertically
			) && (
				(x1 >= l && x1 <= r) ||	// Left edge touching
				(x2 >= l && x2 <= r) ||	// Right edge touching
				(x1 < l && x2 > r)		// Surrounded horizontally
			);
		default:
			return false;
		}

};

/*
	This manager tracks offsets of draggables and droppables
*/
$.ui.ddmanager = {
	current: null,
	droppables: { "default": [] },
	prepareOffsets: function(t, event) {

		var i, j,
			m = $.ui.ddmanager.droppables[t.options.scope] || [],
			type = event ? event.type : null, // workaround for #2317
			list = (t.currentItem || t.element).find(":data(ui-droppable)").addBack();

		droppablesLoop: for (i = 0; i < m.length; i++) {

			//No disabled and non-accepted
			if(m[i].options.disabled || (t && !m[i].accept.call(m[i].element[0],(t.currentItem || t.element)))) {
				continue;
			}

			// Filter out elements in the current dragged item
			for (j=0; j < list.length; j++) {
				if(list[j] === m[i].element[0]) {
					m[i].proportions.height = 0;
					continue droppablesLoop;
				}
			}

			m[i].visible = m[i].element.css("display") !== "none";
			if(!m[i].visible) {
				continue;
			}

			//Activate the droppable if used directly from draggables
			if(type === "mousedown") {
				m[i]._activate.call(m[i], event);
			}

			m[i].offset = m[i].element.offset();
			m[i].proportions = { width: m[i].element[0].offsetWidth, height: m[i].element[0].offsetHeight };

		}

	},
	drop: function(draggable, event) {

		var dropped = false;
		// Create a copy of the droppables in case the list changes during the drop (#9116)
		$.each(($.ui.ddmanager.droppables[draggable.options.scope] || []).slice(), function() {

			if(!this.options) {
				return;
			}
			if (!this.options.disabled && this.visible && $.ui.intersect(draggable, this, this.options.tolerance)) {
				dropped = this._drop.call(this, event) || dropped;
			}

			if (!this.options.disabled && this.visible && this.accept.call(this.element[0],(draggable.currentItem || draggable.element))) {
				this.isout = true;
				this.isover = false;
				this._deactivate.call(this, event);
			}

		});
		return dropped;

	},
	dragStart: function( draggable, event ) {
		//Listen for scrolling so that if the dragging causes scrolling the position of the droppables can be recalculated (see #5003)
		draggable.element.parentsUntil( "body" ).bind( "scroll.droppable", function() {
			if( !draggable.options.refreshPositions ) {
				$.ui.ddmanager.prepareOffsets( draggable, event );
			}
		});
	},
	drag: function(draggable, event) {

		//If you have a highly dynamic page, you might try this option. It renders positions every time you move the mouse.
		if(draggable.options.refreshPositions) {
			$.ui.ddmanager.prepareOffsets(draggable, event);
		}

		//Run through all droppables and check their positions based on specific tolerance options
		$.each($.ui.ddmanager.droppables[draggable.options.scope] || [], function() {

			if(this.options.disabled || this.greedyChild || !this.visible) {
				return;
			}

			var parentInstance, scope, parent,
				intersects = $.ui.intersect(draggable, this, this.options.tolerance),
				c = !intersects && this.isover ? "isout" : (intersects && !this.isover ? "isover" : null);
			if(!c) {
				return;
			}

			if (this.options.greedy) {
				// find droppable parents with same scope
				scope = this.options.scope;
				parent = this.element.parents(":data(ui-droppable)").filter(function () {
					return $.data(this, "ui-droppable").options.scope === scope;
				});

				if (parent.length) {
					parentInstance = $.data(parent[0], "ui-droppable");
					parentInstance.greedyChild = (c === "isover");
				}
			}

			// we just moved into a greedy child
			if (parentInstance && c === "isover") {
				parentInstance.isover = false;
				parentInstance.isout = true;
				parentInstance._out.call(parentInstance, event);
			}

			this[c] = true;
			this[c === "isout" ? "isover" : "isout"] = false;
			this[c === "isover" ? "_over" : "_out"].call(this, event);

			// we just moved out of a greedy child
			if (parentInstance && c === "isout") {
				parentInstance.isout = false;
				parentInstance.isover = true;
				parentInstance._over.call(parentInstance, event);
			}
		});

	},
	dragStop: function( draggable, event ) {
		draggable.element.parentsUntil( "body" ).unbind( "scroll.droppable" );
		//Call prepareOffsets one final time since IE does not fire return scroll events when overflow was caused by drag (see #5003)
		if( !draggable.options.refreshPositions ) {
			$.ui.ddmanager.prepareOffsets( draggable, event );
		}
	}
};

})(jQuery);


/*!
 * jQuery UI Position 1.10.2
 * http://jqueryui.com
 *
 * Copyright 2013 jQuery Foundation and other contributors
 * Released under the MIT license.
 * http://jquery.org/license
 *
 * http://api.jqueryui.com/position/
 */
(function( $, undefined ) {

$.ui = $.ui || {};

var cachedScrollbarWidth,
	max = Math.max,
	abs = Math.abs,
	round = Math.round,
	rhorizontal = /left|center|right/,
	rvertical = /top|center|bottom/,
	roffset = /[\+\-]\d+(\.[\d]+)?%?/,
	rposition = /^\w+/,
	rpercent = /%$/,
	_position = $.fn.position;

function getOffsets( offsets, width, height ) {
	return [
		parseFloat( offsets[ 0 ] ) * ( rpercent.test( offsets[ 0 ] ) ? width / 100 : 1 ),
		parseFloat( offsets[ 1 ] ) * ( rpercent.test( offsets[ 1 ] ) ? height / 100 : 1 )
	];
}

function parseCss( element, property ) {
	return parseInt( $.css( element, property ), 10 ) || 0;
}

function getDimensions( elem ) {
	var raw = elem[0];
	if ( raw.nodeType === 9 ) {
		return {
			width: elem.width(),
			height: elem.height(),
			offset: { top: 0, left: 0 }
		};
	}
	if ( $.isWindow( raw ) ) {
		return {
			width: elem.width(),
			height: elem.height(),
			offset: { top: elem.scrollTop(), left: elem.scrollLeft() }
		};
	}
	if ( raw.preventDefault ) {
		return {
			width: 0,
			height: 0,
			offset: { top: raw.pageY, left: raw.pageX }
		};
	}
	return {
		width: elem.outerWidth(),
		height: elem.outerHeight(),
		offset: elem.offset()
	};
}

$.position = {
	scrollbarWidth: function() {
		if ( cachedScrollbarWidth !== undefined ) {
			return cachedScrollbarWidth;
		}
		var w1, w2,
			div = $( "<div style='display:block;width:50px;height:50px;overflow:hidden;'><div style='height:100px;width:auto;'></div></div>" ),
			innerDiv = div.children()[0];

		$( "body" ).append( div );
		w1 = innerDiv.offsetWidth;
		div.css( "overflow", "scroll" );

		w2 = innerDiv.offsetWidth;

		if ( w1 === w2 ) {
			w2 = div[0].clientWidth;
		}

		div.remove();

		return (cachedScrollbarWidth = w1 - w2);
	},
	getScrollInfo: function( within ) {
		var overflowX = within.isWindow ? "" : within.element.css( "overflow-x" ),
			overflowY = within.isWindow ? "" : within.element.css( "overflow-y" ),
			hasOverflowX = overflowX === "scroll" ||
				( overflowX === "auto" && within.width < within.element[0].scrollWidth ),
			hasOverflowY = overflowY === "scroll" ||
				( overflowY === "auto" && within.height < within.element[0].scrollHeight );
		return {
			width: hasOverflowY ? $.position.scrollbarWidth() : 0,
			height: hasOverflowX ? $.position.scrollbarWidth() : 0
		};
	},
	getWithinInfo: function( element ) {
		var withinElement = $( element || window ),
			isWindow = $.isWindow( withinElement[0] );
		return {
			element: withinElement,
			isWindow: isWindow,
			offset: withinElement.offset() || { left: 0, top: 0 },
			scrollLeft: withinElement.scrollLeft(),
			scrollTop: withinElement.scrollTop(),
			width: isWindow ? withinElement.width() : withinElement.outerWidth(),
			height: isWindow ? withinElement.height() : withinElement.outerHeight()
		};
	}
};

$.fn.position = function( options ) {
	if ( !options || !options.of ) {
		return _position.apply( this, arguments );
	}

	// make a copy, we don't want to modify arguments
	options = $.extend( {}, options );

	var atOffset, targetWidth, targetHeight, targetOffset, basePosition, dimensions,
		target = $( options.of ),
		within = $.position.getWithinInfo( options.within ),
		scrollInfo = $.position.getScrollInfo( within ),
		collision = ( options.collision || "flip" ).split( " " ),
		offsets = {};

	dimensions = getDimensions( target );
	if ( target[0].preventDefault ) {
		// force left top to allow flipping
		options.at = "left top";
	}
	targetWidth = dimensions.width;
	targetHeight = dimensions.height;
	targetOffset = dimensions.offset;
	// clone to reuse original targetOffset later
	basePosition = $.extend( {}, targetOffset );

	// force my and at to have valid horizontal and vertical positions
	// if a value is missing or invalid, it will be converted to center
	$.each( [ "my", "at" ], function() {
		var pos = ( options[ this ] || "" ).split( " " ),
			horizontalOffset,
			verticalOffset;

		if ( pos.length === 1) {
			pos = rhorizontal.test( pos[ 0 ] ) ?
				pos.concat( [ "center" ] ) :
				rvertical.test( pos[ 0 ] ) ?
					[ "center" ].concat( pos ) :
					[ "center", "center" ];
		}
		pos[ 0 ] = rhorizontal.test( pos[ 0 ] ) ? pos[ 0 ] : "center";
		pos[ 1 ] = rvertical.test( pos[ 1 ] ) ? pos[ 1 ] : "center";

		// calculate offsets
		horizontalOffset = roffset.exec( pos[ 0 ] );
		verticalOffset = roffset.exec( pos[ 1 ] );
		offsets[ this ] = [
			horizontalOffset ? horizontalOffset[ 0 ] : 0,
			verticalOffset ? verticalOffset[ 0 ] : 0
		];

		// reduce to just the positions without the offsets
		options[ this ] = [
			rposition.exec( pos[ 0 ] )[ 0 ],
			rposition.exec( pos[ 1 ] )[ 0 ]
		];
	});

	// normalize collision option
	if ( collision.length === 1 ) {
		collision[ 1 ] = collision[ 0 ];
	}

	if ( options.at[ 0 ] === "right" ) {
		basePosition.left += targetWidth;
	} else if ( options.at[ 0 ] === "center" ) {
		basePosition.left += targetWidth / 2;
	}

	if ( options.at[ 1 ] === "bottom" ) {
		basePosition.top += targetHeight;
	} else if ( options.at[ 1 ] === "center" ) {
		basePosition.top += targetHeight / 2;
	}

	atOffset = getOffsets( offsets.at, targetWidth, targetHeight );
	basePosition.left += atOffset[ 0 ];
	basePosition.top += atOffset[ 1 ];

	return this.each(function() {
		var collisionPosition, using,
			elem = $( this ),
			elemWidth = elem.outerWidth(),
			elemHeight = elem.outerHeight(),
			marginLeft = parseCss( this, "marginLeft" ),
			marginTop = parseCss( this, "marginTop" ),
			collisionWidth = elemWidth + marginLeft + parseCss( this, "marginRight" ) + scrollInfo.width,
			collisionHeight = elemHeight + marginTop + parseCss( this, "marginBottom" ) + scrollInfo.height,
			position = $.extend( {}, basePosition ),
			myOffset = getOffsets( offsets.my, elem.outerWidth(), elem.outerHeight() );

		if ( options.my[ 0 ] === "right" ) {
			position.left -= elemWidth;
		} else if ( options.my[ 0 ] === "center" ) {
			position.left -= elemWidth / 2;
		}

		if ( options.my[ 1 ] === "bottom" ) {
			position.top -= elemHeight;
		} else if ( options.my[ 1 ] === "center" ) {
			position.top -= elemHeight / 2;
		}

		position.left += myOffset[ 0 ];
		position.top += myOffset[ 1 ];

		// if the browser doesn't support fractions, then round for consistent results
		if ( !$.support.offsetFractions ) {
			position.left = round( position.left );
			position.top = round( position.top );
		}

		collisionPosition = {
			marginLeft: marginLeft,
			marginTop: marginTop
		};

		$.each( [ "left", "top" ], function( i, dir ) {
			if ( $.ui.position[ collision[ i ] ] ) {
				$.ui.position[ collision[ i ] ][ dir ]( position, {
					targetWidth: targetWidth,
					targetHeight: targetHeight,
					elemWidth: elemWidth,
					elemHeight: elemHeight,
					collisionPosition: collisionPosition,
					collisionWidth: collisionWidth,
					collisionHeight: collisionHeight,
					offset: [ atOffset[ 0 ] + myOffset[ 0 ], atOffset [ 1 ] + myOffset[ 1 ] ],
					my: options.my,
					at: options.at,
					within: within,
					elem : elem
				});
			}
		});

		if ( options.using ) {
			// adds feedback as second argument to using callback, if present
			using = function( props ) {
				var left = targetOffset.left - position.left,
					right = left + targetWidth - elemWidth,
					top = targetOffset.top - position.top,
					bottom = top + targetHeight - elemHeight,
					feedback = {
						target: {
							element: target,
							left: targetOffset.left,
							top: targetOffset.top,
							width: targetWidth,
							height: targetHeight
						},
						element: {
							element: elem,
							left: position.left,
							top: position.top,
							width: elemWidth,
							height: elemHeight
						},
						horizontal: right < 0 ? "left" : left > 0 ? "right" : "center",
						vertical: bottom < 0 ? "top" : top > 0 ? "bottom" : "middle"
					};
				if ( targetWidth < elemWidth && abs( left + right ) < targetWidth ) {
					feedback.horizontal = "center";
				}
				if ( targetHeight < elemHeight && abs( top + bottom ) < targetHeight ) {
					feedback.vertical = "middle";
				}
				if ( max( abs( left ), abs( right ) ) > max( abs( top ), abs( bottom ) ) ) {
					feedback.important = "horizontal";
				} else {
					feedback.important = "vertical";
				}
				options.using.call( this, props, feedback );
			};
		}

		elem.offset( $.extend( position, { using: using } ) );
	});
};

$.ui.position = {
	fit: {
		left: function( position, data ) {
			var within = data.within,
				withinOffset = within.isWindow ? within.scrollLeft : within.offset.left,
				outerWidth = within.width,
				collisionPosLeft = position.left - data.collisionPosition.marginLeft,
				overLeft = withinOffset - collisionPosLeft,
				overRight = collisionPosLeft + data.collisionWidth - outerWidth - withinOffset,
				newOverRight;

			// element is wider than within
			if ( data.collisionWidth > outerWidth ) {
				// element is initially over the left side of within
				if ( overLeft > 0 && overRight <= 0 ) {
					newOverRight = position.left + overLeft + data.collisionWidth - outerWidth - withinOffset;
					position.left += overLeft - newOverRight;
				// element is initially over right side of within
				} else if ( overRight > 0 && overLeft <= 0 ) {
					position.left = withinOffset;
				// element is initially over both left and right sides of within
				} else {
					if ( overLeft > overRight ) {
						position.left = withinOffset + outerWidth - data.collisionWidth;
					} else {
						position.left = withinOffset;
					}
				}
			// too far left -> align with left edge
			} else if ( overLeft > 0 ) {
				position.left += overLeft;
			// too far right -> align with right edge
			} else if ( overRight > 0 ) {
				position.left -= overRight;
			// adjust based on position and margin
			} else {
				position.left = max( position.left - collisionPosLeft, position.left );
			}
		},
		top: function( position, data ) {
			var within = data.within,
				withinOffset = within.isWindow ? within.scrollTop : within.offset.top,
				outerHeight = data.within.height,
				collisionPosTop = position.top - data.collisionPosition.marginTop,
				overTop = withinOffset - collisionPosTop,
				overBottom = collisionPosTop + data.collisionHeight - outerHeight - withinOffset,
				newOverBottom;

			// element is taller than within
			if ( data.collisionHeight > outerHeight ) {
				// element is initially over the top of within
				if ( overTop > 0 && overBottom <= 0 ) {
					newOverBottom = position.top + overTop + data.collisionHeight - outerHeight - withinOffset;
					position.top += overTop - newOverBottom;
				// element is initially over bottom of within
				} else if ( overBottom > 0 && overTop <= 0 ) {
					position.top = withinOffset;
				// element is initially over both top and bottom of within
				} else {
					if ( overTop > overBottom ) {
						position.top = withinOffset + outerHeight - data.collisionHeight;
					} else {
						position.top = withinOffset;
					}
				}
			// too far up -> align with top
			} else if ( overTop > 0 ) {
				position.top += overTop;
			// too far down -> align with bottom edge
			} else if ( overBottom > 0 ) {
				position.top -= overBottom;
			// adjust based on position and margin
			} else {
				position.top = max( position.top - collisionPosTop, position.top );
			}
		}
	},
	flip: {
		left: function( position, data ) {
			var within = data.within,
				withinOffset = within.offset.left + within.scrollLeft,
				outerWidth = within.width,
				offsetLeft = within.isWindow ? within.scrollLeft : within.offset.left,
				collisionPosLeft = position.left - data.collisionPosition.marginLeft,
				overLeft = collisionPosLeft - offsetLeft,
				overRight = collisionPosLeft + data.collisionWidth - outerWidth - offsetLeft,
				myOffset = data.my[ 0 ] === "left" ?
					-data.elemWidth :
					data.my[ 0 ] === "right" ?
						data.elemWidth :
						0,
				atOffset = data.at[ 0 ] === "left" ?
					data.targetWidth :
					data.at[ 0 ] === "right" ?
						-data.targetWidth :
						0,
				offset = -2 * data.offset[ 0 ],
				newOverRight,
				newOverLeft;

			if ( overLeft < 0 ) {
				newOverRight = position.left + myOffset + atOffset + offset + data.collisionWidth - outerWidth - withinOffset;
				if ( newOverRight < 0 || newOverRight < abs( overLeft ) ) {
					position.left += myOffset + atOffset + offset;
				}
			}
			else if ( overRight > 0 ) {
				newOverLeft = position.left - data.collisionPosition.marginLeft + myOffset + atOffset + offset - offsetLeft;
				if ( newOverLeft > 0 || abs( newOverLeft ) < overRight ) {
					position.left += myOffset + atOffset + offset;
				}
			}
		},
		top: function( position, data ) {
			var within = data.within,
				withinOffset = within.offset.top + within.scrollTop,
				outerHeight = within.height,
				offsetTop = within.isWindow ? within.scrollTop : within.offset.top,
				collisionPosTop = position.top - data.collisionPosition.marginTop,
				overTop = collisionPosTop - offsetTop,
				overBottom = collisionPosTop + data.collisionHeight - outerHeight - offsetTop,
				top = data.my[ 1 ] === "top",
				myOffset = top ?
					-data.elemHeight :
					data.my[ 1 ] === "bottom" ?
						data.elemHeight :
						0,
				atOffset = data.at[ 1 ] === "top" ?
					data.targetHeight :
					data.at[ 1 ] === "bottom" ?
						-data.targetHeight :
						0,
				offset = -2 * data.offset[ 1 ],
				newOverTop,
				newOverBottom;
			if ( overTop < 0 ) {
				newOverBottom = position.top + myOffset + atOffset + offset + data.collisionHeight - outerHeight - withinOffset;
				if ( ( position.top + myOffset + atOffset + offset) > overTop && ( newOverBottom < 0 || newOverBottom < abs( overTop ) ) ) {
					position.top += myOffset + atOffset + offset;
				}
			}
			else if ( overBottom > 0 ) {
				newOverTop = position.top -  data.collisionPosition.marginTop + myOffset + atOffset + offset - offsetTop;
				if ( ( position.top + myOffset + atOffset + offset) > overBottom && ( newOverTop > 0 || abs( newOverTop ) < overBottom ) ) {
					position.top += myOffset + atOffset + offset;
				}
			}
		}
	},
	flipfit: {
		left: function() {
			$.ui.position.flip.left.apply( this, arguments );
			$.ui.position.fit.left.apply( this, arguments );
		},
		top: function() {
			$.ui.position.flip.top.apply( this, arguments );
			$.ui.position.fit.top.apply( this, arguments );
		}
	}
};

// fraction support test
(function () {
	var testElement, testElementParent, testElementStyle, offsetLeft, i,
		body = document.getElementsByTagName( "body" )[ 0 ],
		div = document.createElement( "div" );

	//Create a "fake body" for testing based on method used in jQuery.support
	testElement = document.createElement( body ? "div" : "body" );
	testElementStyle = {
		visibility: "hidden",
		width: 0,
		height: 0,
		border: 0,
		margin: 0,
		background: "none"
	};
	if ( body ) {
		$.extend( testElementStyle, {
			position: "absolute",
			left: "-1000px",
			top: "-1000px"
		});
	}
	for ( i in testElementStyle ) {
		testElement.style[ i ] = testElementStyle[ i ];
	}
	testElement.appendChild( div );
	testElementParent = body || document.documentElement;
	testElementParent.insertBefore( testElement, testElementParent.firstChild );

	div.style.cssText = "position: absolute; left: 10.7432222px;";

	offsetLeft = $( div ).offset().left;
	$.support.offsetFractions = offsetLeft > 10 && offsetLeft < 11;

	testElement.innerHTML = "";
	testElementParent.removeChild( testElement );
})();

}( jQuery ) );


/*!
 * jQuery UI Selectable 1.10.2
 * http://jqueryui.com
 *
 * Copyright 2013 jQuery Foundation and other contributors
 * Released under the MIT license.
 * http://jquery.org/license
 *
 * http://api.jqueryui.com/selectable/
 *
 * Depends:
 *	jquery.ui.core.js
 *	jquery.ui.mouse.js
 *	jquery.ui.widget.js
 */
(function( $, undefined ) {

$.widget("ui.selectable", $.ui.mouse, {
	version: "1.10.2",
	options: {
		appendTo: "body",
		autoRefresh: true,
		distance: 0,
		filter: "*",
		tolerance: "touch",

		// callbacks
		selected: null,
		selecting: null,
		start: null,
		stop: null,
		unselected: null,
		unselecting: null
	},
	_create: function() {
		var selectees,
			that = this;

		this.element.addClass("ui-selectable");

		this.dragged = false;

		// cache selectee children based on filter
		this.refresh = function() {
			selectees = $(that.options.filter, that.element[0]);
			selectees.addClass("ui-selectee");
			selectees.each(function() {
				var $this = $(this),
					pos = $this.offset();
				$.data(this, "selectable-item", {
					element: this,
					$element: $this,
					left: pos.left,
					top: pos.top,
					right: pos.left + $this.outerWidth(),
					bottom: pos.top + $this.outerHeight(),
					startselected: false,
					selected: $this.hasClass("ui-selected"),
					selecting: $this.hasClass("ui-selecting"),
					unselecting: $this.hasClass("ui-unselecting")
				});
			});
		};
		this.refresh();

		this.selectees = selectees.addClass("ui-selectee");

		this._mouseInit();

		this.helper = $("<div class='ui-selectable-helper'></div>");
	},

	_destroy: function() {
		this.selectees
			.removeClass("ui-selectee")
			.removeData("selectable-item");
		this.element
			.removeClass("ui-selectable ui-selectable-disabled");
		this._mouseDestroy();
	},

	_mouseStart: function(event) {
		var that = this,
			options = this.options;

		this.opos = [event.pageX, event.pageY];

		if (this.options.disabled) {
			return;
		}

		this.selectees = $(options.filter, this.element[0]);

		this._trigger("start", event);

		$(options.appendTo).append(this.helper);
		// position helper (lasso)
		this.helper.css({
			"left": event.pageX,
			"top": event.pageY,
			"width": 0,
			"height": 0
		});

		if (options.autoRefresh) {
			this.refresh();
		}

		this.selectees.filter(".ui-selected").each(function() {
			var selectee = $.data(this, "selectable-item");
			selectee.startselected = true;
			if (!event.metaKey && !event.ctrlKey) {
				selectee.$element.removeClass("ui-selected");
				selectee.selected = false;
				selectee.$element.addClass("ui-unselecting");
				selectee.unselecting = true;
				// selectable UNSELECTING callback
				that._trigger("unselecting", event, {
					unselecting: selectee.element
				});
			}
		});

		$(event.target).parents().addBack().each(function() {
			var doSelect,
				selectee = $.data(this, "selectable-item");
			if (selectee) {
				doSelect = (!event.metaKey && !event.ctrlKey) || !selectee.$element.hasClass("ui-selected");
				selectee.$element
					.removeClass(doSelect ? "ui-unselecting" : "ui-selected")
					.addClass(doSelect ? "ui-selecting" : "ui-unselecting");
				selectee.unselecting = !doSelect;
				selectee.selecting = doSelect;
				selectee.selected = doSelect;
				// selectable (UN)SELECTING callback
				if (doSelect) {
					that._trigger("selecting", event, {
						selecting: selectee.element
					});
				} else {
					that._trigger("unselecting", event, {
						unselecting: selectee.element
					});
				}
				return false;
			}
		});

	},

	_mouseDrag: function(event) {

		this.dragged = true;

		if (this.options.disabled) {
			return;
		}

		var tmp,
			that = this,
			options = this.options,
			x1 = this.opos[0],
			y1 = this.opos[1],
			x2 = event.pageX,
			y2 = event.pageY;

		if (x1 > x2) { tmp = x2; x2 = x1; x1 = tmp; }
		if (y1 > y2) { tmp = y2; y2 = y1; y1 = tmp; }
		this.helper.css({left: x1, top: y1, width: x2-x1, height: y2-y1});

		this.selectees.each(function() {
			var selectee = $.data(this, "selectable-item"),
				hit = false;

			//prevent helper from being selected if appendTo: selectable
			if (!selectee || selectee.element === that.element[0]) {
				return;
			}

			if (options.tolerance === "touch") {
				hit = ( !(selectee.left > x2 || selectee.right < x1 || selectee.top > y2 || selectee.bottom < y1) );
			} else if (options.tolerance === "fit") {
				hit = (selectee.left > x1 && selectee.right < x2 && selectee.top > y1 && selectee.bottom < y2);
			}

			if (hit) {
				// SELECT
				if (selectee.selected) {
					selectee.$element.removeClass("ui-selected");
					selectee.selected = false;
				}
				if (selectee.unselecting) {
					selectee.$element.removeClass("ui-unselecting");
					selectee.unselecting = false;
				}
				if (!selectee.selecting) {
					selectee.$element.addClass("ui-selecting");
					selectee.selecting = true;
					// selectable SELECTING callback
					that._trigger("selecting", event, {
						selecting: selectee.element
					});
				}
			} else {
				// UNSELECT
				if (selectee.selecting) {
					if ((event.metaKey || event.ctrlKey) && selectee.startselected) {
						selectee.$element.removeClass("ui-selecting");
						selectee.selecting = false;
						selectee.$element.addClass("ui-selected");
						selectee.selected = true;
					} else {
						selectee.$element.removeClass("ui-selecting");
						selectee.selecting = false;
						if (selectee.startselected) {
							selectee.$element.addClass("ui-unselecting");
							selectee.unselecting = true;
						}
						// selectable UNSELECTING callback
						that._trigger("unselecting", event, {
							unselecting: selectee.element
						});
					}
				}
				if (selectee.selected) {
					if (!event.metaKey && !event.ctrlKey && !selectee.startselected) {
						selectee.$element.removeClass("ui-selected");
						selectee.selected = false;

						selectee.$element.addClass("ui-unselecting");
						selectee.unselecting = true;
						// selectable UNSELECTING callback
						that._trigger("unselecting", event, {
							unselecting: selectee.element
						});
					}
				}
			}
		});

		return false;
	},

	_mouseStop: function(event) {
		var that = this;

		this.dragged = false;

		$(".ui-unselecting", this.element[0]).each(function() {
			var selectee = $.data(this, "selectable-item");
			selectee.$element.removeClass("ui-unselecting");
			selectee.unselecting = false;
			selectee.startselected = false;
			that._trigger("unselected", event, {
				unselected: selectee.element
			});
		});
		$(".ui-selecting", this.element[0]).each(function() {
			var selectee = $.data(this, "selectable-item");
			selectee.$element.removeClass("ui-selecting").addClass("ui-selected");
			selectee.selecting = false;
			selectee.selected = true;
			selectee.startselected = true;
			that._trigger("selected", event, {
				selected: selectee.element
			});
		});
		this._trigger("stop", event);

		this.helper.remove();

		return false;
	}

});

})(jQuery);


/*!
 * jQuery UI Slider 1.10.2
 * http://jqueryui.com
 *
 * Copyright 2013 jQuery Foundation and other contributors
 * Released under the MIT license.
 * http://jquery.org/license
 *
 * http://api.jqueryui.com/slider/
 *
 * Depends:
 *	jquery.ui.core.js
 *	jquery.ui.mouse.js
 *	jquery.ui.widget.js
 */
(function( $, undefined ) {

// number of pages in a slider
// (how many times can you page up/down to go through the whole range)
var numPages = 5;

$.widget( "ui.slider", $.ui.mouse, {
	version: "1.10.2",
	widgetEventPrefix: "slide",

	options: {
		animate: false,
		distance: 0,
		max: 100,
		min: 0,
		orientation: "horizontal",
		range: false,
		step: 1,
		value: 0,
		values: null,

		// callbacks
		change: null,
		slide: null,
		start: null,
		stop: null
	},

	_create: function() {
		this._keySliding = false;
		this._mouseSliding = false;
		this._animateOff = true;
		this._handleIndex = null;
		this._detectOrientation();
		this._mouseInit();

		this.element
			.addClass( "ui-slider" +
				" ui-slider-" + this.orientation +
				" ui-widget" +
				" ui-widget-content" +
				" ui-corner-all");

		this._refresh();
		this._setOption( "disabled", this.options.disabled );

		this._animateOff = false;
	},

	_refresh: function() {
		this._createRange();
		this._createHandles();
		this._setupEvents();
		this._refreshValue();
	},

	_createHandles: function() {
		var i, handleCount,
			options = this.options,
			existingHandles = this.element.find( ".ui-slider-handle" ).addClass( "ui-state-default ui-corner-all" ),
			handle = "<a class='ui-slider-handle ui-state-default ui-corner-all' href='#'></a>",
			handles = [];

		handleCount = ( options.values && options.values.length ) || 1;

		if ( existingHandles.length > handleCount ) {
			existingHandles.slice( handleCount ).remove();
			existingHandles = existingHandles.slice( 0, handleCount );
		}

		for ( i = existingHandles.length; i < handleCount; i++ ) {
			handles.push( handle );
		}

		this.handles = existingHandles.add( $( handles.join( "" ) ).appendTo( this.element ) );

		this.handle = this.handles.eq( 0 );

		this.handles.each(function( i ) {
			$( this ).data( "ui-slider-handle-index", i );
		});
	},

	_createRange: function() {
		var options = this.options,
			classes = "";

		if ( options.range ) {
			if ( options.range === true ) {
				if ( !options.values ) {
					options.values = [ this._valueMin(), this._valueMin() ];
				} else if ( options.values.length && options.values.length !== 2 ) {
					options.values = [ options.values[0], options.values[0] ];
				} else if ( $.isArray( options.values ) ) {
					options.values = options.values.slice(0);
				}
			}

			if ( !this.range || !this.range.length ) {
				this.range = $( "<div></div>" )
					.appendTo( this.element );

				classes = "ui-slider-range" +
				// note: this isn't the most fittingly semantic framework class for this element,
				// but worked best visually with a variety of themes
				" ui-widget-header ui-corner-all";
			} else {
				this.range.removeClass( "ui-slider-range-min ui-slider-range-max" )
					// Handle range switching from true to min/max
					.css({
						"left": "",
						"bottom": ""
					});
			}

			this.range.addClass( classes +
				( ( options.range === "min" || options.range === "max" ) ? " ui-slider-range-" + options.range : "" ) );
		} else {
			this.range = $([]);
		}
	},

	_setupEvents: function() {
		var elements = this.handles.add( this.range ).filter( "a" );
		this._off( elements );
		this._on( elements, this._handleEvents );
		this._hoverable( elements );
		this._focusable( elements );
	},

	_destroy: function() {
		this.handles.remove();
		this.range.remove();

		this.element
			.removeClass( "ui-slider" +
				" ui-slider-horizontal" +
				" ui-slider-vertical" +
				" ui-widget" +
				" ui-widget-content" +
				" ui-corner-all" );

		this._mouseDestroy();
	},

	_mouseCapture: function( event ) {
		var position, normValue, distance, closestHandle, index, allowed, offset, mouseOverHandle,
			that = this,
			o = this.options;

		if ( o.disabled ) {
			return false;
		}

		this.elementSize = {
			width: this.element.outerWidth(),
			height: this.element.outerHeight()
		};
		this.elementOffset = this.element.offset();

		position = { x: event.pageX, y: event.pageY };
		normValue = this._normValueFromMouse( position );
		distance = this._valueMax() - this._valueMin() + 1;
		this.handles.each(function( i ) {
			var thisDistance = Math.abs( normValue - that.values(i) );
			if (( distance > thisDistance ) ||
				( distance === thisDistance &&
					(i === that._lastChangedValue || that.values(i) === o.min ))) {
				distance = thisDistance;
				closestHandle = $( this );
				index = i;
			}
		});

		allowed = this._start( event, index );
		if ( allowed === false ) {
			return false;
		}
		this._mouseSliding = true;

		this._handleIndex = index;

		closestHandle
			.addClass( "ui-state-active" )
			.focus();

		offset = closestHandle.offset();
		mouseOverHandle = !$( event.target ).parents().addBack().is( ".ui-slider-handle" );
		this._clickOffset = mouseOverHandle ? { left: 0, top: 0 } : {
			left: event.pageX - offset.left - ( closestHandle.width() / 2 ),
			top: event.pageY - offset.top -
				( closestHandle.height() / 2 ) -
				( parseInt( closestHandle.css("borderTopWidth"), 10 ) || 0 ) -
				( parseInt( closestHandle.css("borderBottomWidth"), 10 ) || 0) +
				( parseInt( closestHandle.css("marginTop"), 10 ) || 0)
		};

		if ( !this.handles.hasClass( "ui-state-hover" ) ) {
			this._slide( event, index, normValue );
		}
		this._animateOff = true;
		return true;
	},

	_mouseStart: function() {
		return true;
	},

	_mouseDrag: function( event ) {
		var position = { x: event.pageX, y: event.pageY },
			normValue = this._normValueFromMouse( position );

		this._slide( event, this._handleIndex, normValue );

		return false;
	},

	_mouseStop: function( event ) {
		this.handles.removeClass( "ui-state-active" );
		this._mouseSliding = false;

		this._stop( event, this._handleIndex );
		this._change( event, this._handleIndex );

		this._handleIndex = null;
		this._clickOffset = null;
		this._animateOff = false;

		return false;
	},

	_detectOrientation: function() {
		this.orientation = ( this.options.orientation === "vertical" ) ? "vertical" : "horizontal";
	},

	_normValueFromMouse: function( position ) {
		var pixelTotal,
			pixelMouse,
			percentMouse,
			valueTotal,
			valueMouse;

		if ( this.orientation === "horizontal" ) {
			pixelTotal = this.elementSize.width;
			pixelMouse = position.x - this.elementOffset.left - ( this._clickOffset ? this._clickOffset.left : 0 );
		} else {
			pixelTotal = this.elementSize.height;
			pixelMouse = position.y - this.elementOffset.top - ( this._clickOffset ? this._clickOffset.top : 0 );
		}

		percentMouse = ( pixelMouse / pixelTotal );
		if ( percentMouse > 1 ) {
			percentMouse = 1;
		}
		if ( percentMouse < 0 ) {
			percentMouse = 0;
		}
		if ( this.orientation === "vertical" ) {
			percentMouse = 1 - percentMouse;
		}

		valueTotal = this._valueMax() - this._valueMin();
		valueMouse = this._valueMin() + percentMouse * valueTotal;

		return this._trimAlignValue( valueMouse );
	},

	_start: function( event, index ) {
		var uiHash = {
			handle: this.handles[ index ],
			value: this.value()
		};
		if ( this.options.values && this.options.values.length ) {
			uiHash.value = this.values( index );
			uiHash.values = this.values();
		}
		return this._trigger( "start", event, uiHash );
	},

	_slide: function( event, index, newVal ) {
		var otherVal,
			newValues,
			allowed;

		if ( this.options.values && this.options.values.length ) {
			otherVal = this.values( index ? 0 : 1 );

			if ( ( this.options.values.length === 2 && this.options.range === true ) &&
					( ( index === 0 && newVal > otherVal) || ( index === 1 && newVal < otherVal ) )
				) {
				newVal = otherVal;
			}

			if ( newVal !== this.values( index ) ) {
				newValues = this.values();
				newValues[ index ] = newVal;
				// A slide can be canceled by returning false from the slide callback
				allowed = this._trigger( "slide", event, {
					handle: this.handles[ index ],
					value: newVal,
					values: newValues
				} );
				otherVal = this.values( index ? 0 : 1 );
				if ( allowed !== false ) {
					this.values( index, newVal, true );
				}
			}
		} else {
			if ( newVal !== this.value() ) {
				// A slide can be canceled by returning false from the slide callback
				allowed = this._trigger( "slide", event, {
					handle: this.handles[ index ],
					value: newVal
				} );
				if ( allowed !== false ) {
					this.value( newVal );
				}
			}
		}
	},

	_stop: function( event, index ) {
		var uiHash = {
			handle: this.handles[ index ],
			value: this.value()
		};
		if ( this.options.values && this.options.values.length ) {
			uiHash.value = this.values( index );
			uiHash.values = this.values();
		}

		this._trigger( "stop", event, uiHash );
	},

	_change: function( event, index ) {
		if ( !this._keySliding && !this._mouseSliding ) {
			var uiHash = {
				handle: this.handles[ index ],
				value: this.value()
			};
			if ( this.options.values && this.options.values.length ) {
				uiHash.value = this.values( index );
				uiHash.values = this.values();
			}

			//store the last changed value index for reference when handles overlap
			this._lastChangedValue = index;

			this._trigger( "change", event, uiHash );
		}
	},

	value: function( newValue ) {
		if ( arguments.length ) {
			this.options.value = this._trimAlignValue( newValue );
			this._refreshValue();
			this._change( null, 0 );
			return;
		}

		return this._value();
	},

	values: function( index, newValue ) {
		var vals,
			newValues,
			i;

		if ( arguments.length > 1 ) {
			this.options.values[ index ] = this._trimAlignValue( newValue );
			this._refreshValue();
			this._change( null, index );
			return;
		}

		if ( arguments.length ) {
			if ( $.isArray( arguments[ 0 ] ) ) {
				vals = this.options.values;
				newValues = arguments[ 0 ];
				for ( i = 0; i < vals.length; i += 1 ) {
					vals[ i ] = this._trimAlignValue( newValues[ i ] );
					this._change( null, i );
				}
				this._refreshValue();
			} else {
				if ( this.options.values && this.options.values.length ) {
					return this._values( index );
				} else {
					return this.value();
				}
			}
		} else {
			return this._values();
		}
	},

	_setOption: function( key, value ) {
		var i,
			valsLength = 0;

		if ( key === "range" && this.options.range === true ) {
			if ( value === "min" ) {
				this.options.value = this._values( 0 );
				this.options.values = null;
			} else if ( value === "max" ) {
				this.options.value = this._values( this.options.values.length-1 );
				this.options.values = null;
			}
		}

		if ( $.isArray( this.options.values ) ) {
			valsLength = this.options.values.length;
		}

		$.Widget.prototype._setOption.apply( this, arguments );

		switch ( key ) {
			case "orientation":
				this._detectOrientation();
				this.element
					.removeClass( "ui-slider-horizontal ui-slider-vertical" )
					.addClass( "ui-slider-" + this.orientation );
				this._refreshValue();
				break;
			case "value":
				this._animateOff = true;
				this._refreshValue();
				this._change( null, 0 );
				this._animateOff = false;
				break;
			case "values":
				this._animateOff = true;
				this._refreshValue();
				for ( i = 0; i < valsLength; i += 1 ) {
					this._change( null, i );
				}
				this._animateOff = false;
				break;
			case "min":
			case "max":
				this._animateOff = true;
				this._refreshValue();
				this._animateOff = false;
				break;
			case "range":
				this._animateOff = true;
				this._refresh();
				this._animateOff = false;
				break;
		}
	},

	//internal value getter
	// _value() returns value trimmed by min and max, aligned by step
	_value: function() {
		var val = this.options.value;
		val = this._trimAlignValue( val );

		return val;
	},

	//internal values getter
	// _values() returns array of values trimmed by min and max, aligned by step
	// _values( index ) returns single value trimmed by min and max, aligned by step
	_values: function( index ) {
		var val,
			vals,
			i;

		if ( arguments.length ) {
			val = this.options.values[ index ];
			val = this._trimAlignValue( val );

			return val;
		} else if ( this.options.values && this.options.values.length ) {
			// .slice() creates a copy of the array
			// this copy gets trimmed by min and max and then returned
			vals = this.options.values.slice();
			for ( i = 0; i < vals.length; i+= 1) {
				vals[ i ] = this._trimAlignValue( vals[ i ] );
			}

			return vals;
		} else {
			return [];
		}
	},

	// returns the step-aligned value that val is closest to, between (inclusive) min and max
	_trimAlignValue: function( val ) {
		if ( val <= this._valueMin() ) {
			return this._valueMin();
		}
		if ( val >= this._valueMax() ) {
			return this._valueMax();
		}
		var step = ( this.options.step > 0 ) ? this.options.step : 1,
			valModStep = (val - this._valueMin()) % step,
			alignValue = val - valModStep;

		if ( Math.abs(valModStep) * 2 >= step ) {
			alignValue += ( valModStep > 0 ) ? step : ( -step );
		}

		// Since JavaScript has problems with large floats, round
		// the final value to 5 digits after the decimal point (see #4124)
		return parseFloat( alignValue.toFixed(5) );
	},

	_valueMin: function() {
		return this.options.min;
	},

	_valueMax: function() {
		return this.options.max;
	},

	_refreshValue: function() {
		var lastValPercent, valPercent, value, valueMin, valueMax,
			oRange = this.options.range,
			o = this.options,
			that = this,
			animate = ( !this._animateOff ) ? o.animate : false,
			_set = {};

		if ( this.options.values && this.options.values.length ) {
			this.handles.each(function( i ) {
				valPercent = ( that.values(i) - that._valueMin() ) / ( that._valueMax() - that._valueMin() ) * 100;
				_set[ that.orientation === "horizontal" ? "left" : "bottom" ] = valPercent + "%";
				$( this ).stop( 1, 1 )[ animate ? "animate" : "css" ]( _set, o.animate );
				if ( that.options.range === true ) {
					if ( that.orientation === "horizontal" ) {
						if ( i === 0 ) {
							that.range.stop( 1, 1 )[ animate ? "animate" : "css" ]( { left: valPercent + "%" }, o.animate );
						}
						if ( i === 1 ) {
							that.range[ animate ? "animate" : "css" ]( { width: ( valPercent - lastValPercent ) + "%" }, { queue: false, duration: o.animate } );
						}
					} else {
						if ( i === 0 ) {
							that.range.stop( 1, 1 )[ animate ? "animate" : "css" ]( { bottom: ( valPercent ) + "%" }, o.animate );
						}
						if ( i === 1 ) {
							that.range[ animate ? "animate" : "css" ]( { height: ( valPercent - lastValPercent ) + "%" }, { queue: false, duration: o.animate } );
						}
					}
				}
				lastValPercent = valPercent;
			});
		} else {
			value = this.value();
			valueMin = this._valueMin();
			valueMax = this._valueMax();
			valPercent = ( valueMax !== valueMin ) ?
					( value - valueMin ) / ( valueMax - valueMin ) * 100 :
					0;
			_set[ this.orientation === "horizontal" ? "left" : "bottom" ] = valPercent + "%";
			this.handle.stop( 1, 1 )[ animate ? "animate" : "css" ]( _set, o.animate );

			if ( oRange === "min" && this.orientation === "horizontal" ) {
				this.range.stop( 1, 1 )[ animate ? "animate" : "css" ]( { width: valPercent + "%" }, o.animate );
			}
			if ( oRange === "max" && this.orientation === "horizontal" ) {
				this.range[ animate ? "animate" : "css" ]( { width: ( 100 - valPercent ) + "%" }, { queue: false, duration: o.animate } );
			}
			if ( oRange === "min" && this.orientation === "vertical" ) {
				this.range.stop( 1, 1 )[ animate ? "animate" : "css" ]( { height: valPercent + "%" }, o.animate );
			}
			if ( oRange === "max" && this.orientation === "vertical" ) {
				this.range[ animate ? "animate" : "css" ]( { height: ( 100 - valPercent ) + "%" }, { queue: false, duration: o.animate } );
			}
		}
	},

	_handleEvents: {
		keydown: function( event ) {
			/*jshint maxcomplexity:25*/
			var allowed, curVal, newVal, step,
				index = $( event.target ).data( "ui-slider-handle-index" );

			switch ( event.keyCode ) {
				case $.ui.keyCode.HOME:
				case $.ui.keyCode.END:
				case $.ui.keyCode.PAGE_UP:
				case $.ui.keyCode.PAGE_DOWN:
				case $.ui.keyCode.UP:
				case $.ui.keyCode.RIGHT:
				case $.ui.keyCode.DOWN:
				case $.ui.keyCode.LEFT:
					event.preventDefault();
					if ( !this._keySliding ) {
						this._keySliding = true;
						$( event.target ).addClass( "ui-state-active" );
						allowed = this._start( event, index );
						if ( allowed === false ) {
							return;
						}
					}
					break;
			}

			step = this.options.step;
			if ( this.options.values && this.options.values.length ) {
				curVal = newVal = this.values( index );
			} else {
				curVal = newVal = this.value();
			}

			switch ( event.keyCode ) {
				case $.ui.keyCode.HOME:
					newVal = this._valueMin();
					break;
				case $.ui.keyCode.END:
					newVal = this._valueMax();
					break;
				case $.ui.keyCode.PAGE_UP:
					newVal = this._trimAlignValue( curVal + ( (this._valueMax() - this._valueMin()) / numPages ) );
					break;
				case $.ui.keyCode.PAGE_DOWN:
					newVal = this._trimAlignValue( curVal - ( (this._valueMax() - this._valueMin()) / numPages ) );
					break;
				case $.ui.keyCode.UP:
				case $.ui.keyCode.RIGHT:
					if ( curVal === this._valueMax() ) {
						return;
					}
					newVal = this._trimAlignValue( curVal + step );
					break;
				case $.ui.keyCode.DOWN:
				case $.ui.keyCode.LEFT:
					if ( curVal === this._valueMin() ) {
						return;
					}
					newVal = this._trimAlignValue( curVal - step );
					break;
			}

			this._slide( event, index, newVal );
		},
		click: function( event ) {
			event.preventDefault();
		},
		keyup: function( event ) {
			var index = $( event.target ).data( "ui-slider-handle-index" );

			if ( this._keySliding ) {
				this._keySliding = false;
				this._stop( event, index );
				this._change( event, index );
				$( event.target ).removeClass( "ui-state-active" );
			}
		}
	}

});

}(jQuery));


/*!
 * jQuery UI Sortable 1.10.2
 * http://jqueryui.com
 *
 * Copyright 2013 jQuery Foundation and other contributors
 * Released under the MIT license.
 * http://jquery.org/license
 *
 * http://api.jqueryui.com/sortable/
 *
 * Depends:
 *	jquery.ui.core.js
 *	jquery.ui.mouse.js
 *	jquery.ui.widget.js
 */
(function( $, undefined ) {

/*jshint loopfunc: true */

function isOverAxis( x, reference, size ) {
	return ( x > reference ) && ( x < ( reference + size ) );
}

function isFloating(item) {
	return (/left|right/).test(item.css("float")) || (/inline|table-cell/).test(item.css("display"));
}

$.widget("ui.sortable", $.ui.mouse, {
	version: "1.10.2",
	widgetEventPrefix: "sort",
	ready: false,
	options: {
		appendTo: "parent",
		axis: false,
		connectWith: false,
		containment: false,
		cursor: "auto",
		cursorAt: false,
		dropOnEmpty: true,
		forcePlaceholderSize: false,
		forceHelperSize: false,
		grid: false,
		handle: false,
		helper: "original",
		items: "> *",
		opacity: false,
		placeholder: false,
		revert: false,
		scroll: true,
		scrollSensitivity: 20,
		scrollSpeed: 20,
		scope: "default",
		tolerance: "intersect",
		zIndex: 1000,

		// callbacks
		activate: null,
		beforeStop: null,
		change: null,
		deactivate: null,
		out: null,
		over: null,
		receive: null,
		remove: null,
		sort: null,
		start: null,
		stop: null,
		update: null
	},
	_create: function() {

		var o = this.options;
		this.containerCache = {};
		this.element.addClass("ui-sortable");

		//Get the items
		this.refresh();

		//Let's determine if the items are being displayed horizontally
		this.floating = this.items.length ? o.axis === "x" || isFloating(this.items[0].item) : false;

		//Let's determine the parent's offset
		this.offset = this.element.offset();

		//Initialize mouse events for interaction
		this._mouseInit();

		//We're ready to go
		this.ready = true;

	},

	_destroy: function() {
		this.element
			.removeClass("ui-sortable ui-sortable-disabled");
		this._mouseDestroy();

		for ( var i = this.items.length - 1; i >= 0; i-- ) {
			this.items[i].item.removeData(this.widgetName + "-item");
		}

		return this;
	},

	_setOption: function(key, value){
		if ( key === "disabled" ) {
			this.options[ key ] = value;

			this.widget().toggleClass( "ui-sortable-disabled", !!value );
		} else {
			// Don't call widget base _setOption for disable as it adds ui-state-disabled class
			$.Widget.prototype._setOption.apply(this, arguments);
		}
	},

	_mouseCapture: function(event, overrideHandle) {
		var currentItem = null,
			validHandle = false,
			that = this;

		if (this.reverting) {
			return false;
		}

		if(this.options.disabled || this.options.type === "static") {
			return false;
		}

		//We have to refresh the items data once first
		this._refreshItems(event);

		//Find out if the clicked node (or one of its parents) is a actual item in this.items
		$(event.target).parents().each(function() {
			if($.data(this, that.widgetName + "-item") === that) {
				currentItem = $(this);
				return false;
			}
		});
		if($.data(event.target, that.widgetName + "-item") === that) {
			currentItem = $(event.target);
		}

		if(!currentItem) {
			return false;
		}
		if(this.options.handle && !overrideHandle) {
			$(this.options.handle, currentItem).find("*").addBack().each(function() {
				if(this === event.target) {
					validHandle = true;
				}
			});
			if(!validHandle) {
				return false;
			}
		}

		this.currentItem = currentItem;
		this._removeCurrentsFromItems();
		return true;

	},

	_mouseStart: function(event, overrideHandle, noActivation) {

		var i, body,
			o = this.options;

		this.currentContainer = this;

		//We only need to call refreshPositions, because the refreshItems call has been moved to mouseCapture
		this.refreshPositions();

		//Create and append the visible helper
		this.helper = this._createHelper(event);

		//Cache the helper size
		this._cacheHelperProportions();

		/*
		 * - Position generation -
		 * This block generates everything position related - it's the core of draggables.
		 */

		//Cache the margins of the original element
		this._cacheMargins();

		//Get the next scrolling parent
		this.scrollParent = this.helper.scrollParent();

		//The element's absolute position on the page minus margins
		this.offset = this.currentItem.offset();
		this.offset = {
			top: this.offset.top - this.margins.top,
			left: this.offset.left - this.margins.left
		};

		$.extend(this.offset, {
			click: { //Where the click happened, relative to the element
				left: event.pageX - this.offset.left,
				top: event.pageY - this.offset.top
			},
			parent: this._getParentOffset(),
			relative: this._getRelativeOffset() //This is a relative to absolute position minus the actual position calculation - only used for relative positioned helper
		});

		// Only after we got the offset, we can change the helper's position to absolute
		// TODO: Still need to figure out a way to make relative sorting possible
		this.helper.css("position", "absolute");
		this.cssPosition = this.helper.css("position");

		//Generate the original position
		this.originalPosition = this._generatePosition(event);
		this.originalPageX = event.pageX;
		this.originalPageY = event.pageY;

		//Adjust the mouse offset relative to the helper if "cursorAt" is supplied
		(o.cursorAt && this._adjustOffsetFromHelper(o.cursorAt));

		//Cache the former DOM position
		this.domPosition = { prev: this.currentItem.prev()[0], parent: this.currentItem.parent()[0] };

		//If the helper is not the original, hide the original so it's not playing any role during the drag, won't cause anything bad this way
		if(this.helper[0] !== this.currentItem[0]) {
			this.currentItem.hide();
		}

		//Create the placeholder
		this._createPlaceholder();

		//Set a containment if given in the options
		if(o.containment) {
			this._setContainment();
		}

		if( o.cursor && o.cursor !== "auto" ) { // cursor option
			body = this.document.find( "body" );

			// support: IE
			this.storedCursor = body.css( "cursor" );
			body.css( "cursor", o.cursor );

			this.storedStylesheet = $( "<style>*{ cursor: "+o.cursor+" !important; }</style>" ).appendTo( body );
		}

		if(o.opacity) { // opacity option
			if (this.helper.css("opacity")) {
				this._storedOpacity = this.helper.css("opacity");
			}
			this.helper.css("opacity", o.opacity);
		}

		if(o.zIndex) { // zIndex option
			if (this.helper.css("zIndex")) {
				this._storedZIndex = this.helper.css("zIndex");
			}
			this.helper.css("zIndex", o.zIndex);
		}

		//Prepare scrolling
		if(this.scrollParent[0] !== document && this.scrollParent[0].tagName !== "HTML") {
			this.overflowOffset = this.scrollParent.offset();
		}

		//Call callbacks
		this._trigger("start", event, this._uiHash());

		//Recache the helper size
		if(!this._preserveHelperProportions) {
			this._cacheHelperProportions();
		}


		//Post "activate" events to possible containers
		if( !noActivation ) {
			for ( i = this.containers.length - 1; i >= 0; i-- ) {
				this.containers[ i ]._trigger( "activate", event, this._uiHash( this ) );
			}
		}

		//Prepare possible droppables
		if($.ui.ddmanager) {
			$.ui.ddmanager.current = this;
		}

		if ($.ui.ddmanager && !o.dropBehaviour) {
			$.ui.ddmanager.prepareOffsets(this, event);
		}

		this.dragging = true;

		this.helper.addClass("ui-sortable-helper");
		this._mouseDrag(event); //Execute the drag once - this causes the helper not to be visible before getting its correct position
		return true;

	},

	_mouseDrag: function(event) {
		var i, item, itemElement, intersection,
			o = this.options,
			scrolled = false;

		//Compute the helpers position
		this.position = this._generatePosition(event);
		this.positionAbs = this._convertPositionTo("absolute");

		if (!this.lastPositionAbs) {
			this.lastPositionAbs = this.positionAbs;
		}

		//Do scrolling
		if(this.options.scroll) {
			if(this.scrollParent[0] !== document && this.scrollParent[0].tagName !== "HTML") {

				if((this.overflowOffset.top + this.scrollParent[0].offsetHeight) - event.pageY < o.scrollSensitivity) {
					this.scrollParent[0].scrollTop = scrolled = this.scrollParent[0].scrollTop + o.scrollSpeed;
				} else if(event.pageY - this.overflowOffset.top < o.scrollSensitivity) {
					this.scrollParent[0].scrollTop = scrolled = this.scrollParent[0].scrollTop - o.scrollSpeed;
				}

				if((this.overflowOffset.left + this.scrollParent[0].offsetWidth) - event.pageX < o.scrollSensitivity) {
					this.scrollParent[0].scrollLeft = scrolled = this.scrollParent[0].scrollLeft + o.scrollSpeed;
				} else if(event.pageX - this.overflowOffset.left < o.scrollSensitivity) {
					this.scrollParent[0].scrollLeft = scrolled = this.scrollParent[0].scrollLeft - o.scrollSpeed;
				}

			} else {

				if(event.pageY - $(document).scrollTop() < o.scrollSensitivity) {
					scrolled = $(document).scrollTop($(document).scrollTop() - o.scrollSpeed);
				} else if($(window).height() - (event.pageY - $(document).scrollTop()) < o.scrollSensitivity) {
					scrolled = $(document).scrollTop($(document).scrollTop() + o.scrollSpeed);
				}

				if(event.pageX - $(document).scrollLeft() < o.scrollSensitivity) {
					scrolled = $(document).scrollLeft($(document).scrollLeft() - o.scrollSpeed);
				} else if($(window).width() - (event.pageX - $(document).scrollLeft()) < o.scrollSensitivity) {
					scrolled = $(document).scrollLeft($(document).scrollLeft() + o.scrollSpeed);
				}

			}

			if(scrolled !== false && $.ui.ddmanager && !o.dropBehaviour) {
				$.ui.ddmanager.prepareOffsets(this, event);
			}
		}

		//Regenerate the absolute position used for position checks
		this.positionAbs = this._convertPositionTo("absolute");

		//Set the helper position
		if(!this.options.axis || this.options.axis !== "y") {
			this.helper[0].style.left = this.position.left+"px";
		}
		if(!this.options.axis || this.options.axis !== "x") {
			this.helper[0].style.top = this.position.top+"px";
		}

		//Rearrange
		for (i = this.items.length - 1; i >= 0; i--) {

			//Cache variables and intersection, continue if no intersection
			item = this.items[i];
			itemElement = item.item[0];
			intersection = this._intersectsWithPointer(item);
			if (!intersection) {
				continue;
			}

			// Only put the placeholder inside the current Container, skip all
			// items form other containers. This works because when moving
			// an item from one container to another the
			// currentContainer is switched before the placeholder is moved.
			//
			// Without this moving items in "sub-sortables" can cause the placeholder to jitter
			// beetween the outer and inner container.
			if (item.instance !== this.currentContainer) {
				continue;
			}

			// cannot intersect with itself
			// no useless actions that have been done before
			// no action if the item moved is the parent of the item checked
			if (itemElement !== this.currentItem[0] &&
				this.placeholder[intersection === 1 ? "next" : "prev"]()[0] !== itemElement &&
				!$.contains(this.placeholder[0], itemElement) &&
				(this.options.type === "semi-dynamic" ? !$.contains(this.element[0], itemElement) : true)
			) {

				this.direction = intersection === 1 ? "down" : "up";

				if (this.options.tolerance === "pointer" || this._intersectsWithSides(item)) {
					this._rearrange(event, item);
				} else {
					break;
				}

				this._trigger("change", event, this._uiHash());
				break;
			}
		}

		//Post events to containers
		this._contactContainers(event);

		//Interconnect with droppables
		if($.ui.ddmanager) {
			$.ui.ddmanager.drag(this, event);
		}

		//Call callbacks
		this._trigger("sort", event, this._uiHash());

		this.lastPositionAbs = this.positionAbs;
		return false;

	},

	_mouseStop: function(event, noPropagation) {

		if(!event) {
			return;
		}

		//If we are using droppables, inform the manager about the drop
		if ($.ui.ddmanager && !this.options.dropBehaviour) {
			$.ui.ddmanager.drop(this, event);
		}

		if(this.options.revert) {
			var that = this,
				cur = this.placeholder.offset(),
				axis = this.options.axis,
				animation = {};

			if ( !axis || axis === "x" ) {
				animation.left = cur.left - this.offset.parent.left - this.margins.left + (this.offsetParent[0] === document.body ? 0 : this.offsetParent[0].scrollLeft);
			}
			if ( !axis || axis === "y" ) {
				animation.top = cur.top - this.offset.parent.top - this.margins.top + (this.offsetParent[0] === document.body ? 0 : this.offsetParent[0].scrollTop);
			}
			this.reverting = true;
			$(this.helper).animate( animation, parseInt(this.options.revert, 10) || 500, function() {
				that._clear(event);
			});
		} else {
			this._clear(event, noPropagation);
		}

		return false;

	},

	cancel: function() {

		if(this.dragging) {

			this._mouseUp({ target: null });

			if(this.options.helper === "original") {
				this.currentItem.css(this._storedCSS).removeClass("ui-sortable-helper");
			} else {
				this.currentItem.show();
			}

			//Post deactivating events to containers
			for (var i = this.containers.length - 1; i >= 0; i--){
				this.containers[i]._trigger("deactivate", null, this._uiHash(this));
				if(this.containers[i].containerCache.over) {
					this.containers[i]._trigger("out", null, this._uiHash(this));
					this.containers[i].containerCache.over = 0;
				}
			}

		}

		if (this.placeholder) {
			//$(this.placeholder[0]).remove(); would have been the jQuery way - unfortunately, it unbinds ALL events from the original node!
			if(this.placeholder[0].parentNode) {
				this.placeholder[0].parentNode.removeChild(this.placeholder[0]);
			}
			if(this.options.helper !== "original" && this.helper && this.helper[0].parentNode) {
				this.helper.remove();
			}

			$.extend(this, {
				helper: null,
				dragging: false,
				reverting: false,
				_noFinalSort: null
			});

			if(this.domPosition.prev) {
				$(this.domPosition.prev).after(this.currentItem);
			} else {
				$(this.domPosition.parent).prepend(this.currentItem);
			}
		}

		return this;

	},

	serialize: function(o) {

		var items = this._getItemsAsjQuery(o && o.connected),
			str = [];
		o = o || {};

		$(items).each(function() {
			var res = ($(o.item || this).attr(o.attribute || "id") || "").match(o.expression || (/(.+)[\-=_](.+)/));
			if (res) {
				str.push((o.key || res[1]+"[]")+"="+(o.key && o.expression ? res[1] : res[2]));
			}
		});

		if(!str.length && o.key) {
			str.push(o.key + "=");
		}

		return str.join("&");

	},

	toArray: function(o) {

		var items = this._getItemsAsjQuery(o && o.connected),
			ret = [];

		o = o || {};

		items.each(function() { ret.push($(o.item || this).attr(o.attribute || "id") || ""); });
		return ret;

	},

	/* Be careful with the following core functions */
	_intersectsWith: function(item) {

		var x1 = this.positionAbs.left,
			x2 = x1 + this.helperProportions.width,
			y1 = this.positionAbs.top,
			y2 = y1 + this.helperProportions.height,
			l = item.left,
			r = l + item.width,
			t = item.top,
			b = t + item.height,
			dyClick = this.offset.click.top,
			dxClick = this.offset.click.left,
			isOverElement = (y1 + dyClick) > t && (y1 + dyClick) < b && (x1 + dxClick) > l && (x1 + dxClick) < r;

		if ( this.options.tolerance === "pointer" ||
			this.options.forcePointerForContainers ||
			(this.options.tolerance !== "pointer" && this.helperProportions[this.floating ? "width" : "height"] > item[this.floating ? "width" : "height"])
		) {
			return isOverElement;
		} else {

			return (l < x1 + (this.helperProportions.width / 2) && // Right Half
				x2 - (this.helperProportions.width / 2) < r && // Left Half
				t < y1 + (this.helperProportions.height / 2) && // Bottom Half
				y2 - (this.helperProportions.height / 2) < b ); // Top Half

		}
	},

	_intersectsWithPointer: function(item) {

		var isOverElementHeight = (this.options.axis === "x") || isOverAxis(this.positionAbs.top + this.offset.click.top, item.top, item.height),
			isOverElementWidth = (this.options.axis === "y") || isOverAxis(this.positionAbs.left + this.offset.click.left, item.left, item.width),
			isOverElement = isOverElementHeight && isOverElementWidth,
			verticalDirection = this._getDragVerticalDirection(),
			horizontalDirection = this._getDragHorizontalDirection();

		if (!isOverElement) {
			return false;
		}

		return this.floating ?
			( ((horizontalDirection && horizontalDirection === "right") || verticalDirection === "down") ? 2 : 1 )
			: ( verticalDirection && (verticalDirection === "down" ? 2 : 1) );

	},

	_intersectsWithSides: function(item) {

		var isOverBottomHalf = isOverAxis(this.positionAbs.top + this.offset.click.top, item.top + (item.height/2), item.height),
			isOverRightHalf = isOverAxis(this.positionAbs.left + this.offset.click.left, item.left + (item.width/2), item.width),
			verticalDirection = this._getDragVerticalDirection(),
			horizontalDirection = this._getDragHorizontalDirection();

		if (this.floating && horizontalDirection) {
			return ((horizontalDirection === "right" && isOverRightHalf) || (horizontalDirection === "left" && !isOverRightHalf));
		} else {
			return verticalDirection && ((verticalDirection === "down" && isOverBottomHalf) || (verticalDirection === "up" && !isOverBottomHalf));
		}

	},

	_getDragVerticalDirection: function() {
		var delta = this.positionAbs.top - this.lastPositionAbs.top;
		return delta !== 0 && (delta > 0 ? "down" : "up");
	},

	_getDragHorizontalDirection: function() {
		var delta = this.positionAbs.left - this.lastPositionAbs.left;
		return delta !== 0 && (delta > 0 ? "right" : "left");
	},

	refresh: function(event) {
		this._refreshItems(event);
		this.refreshPositions();
		return this;
	},

	_connectWith: function() {
		var options = this.options;
		return options.connectWith.constructor === String ? [options.connectWith] : options.connectWith;
	},

	_getItemsAsjQuery: function(connected) {

		var i, j, cur, inst,
			items = [],
			queries = [],
			connectWith = this._connectWith();

		if(connectWith && connected) {
			for (i = connectWith.length - 1; i >= 0; i--){
				cur = $(connectWith[i]);
				for ( j = cur.length - 1; j >= 0; j--){
					inst = $.data(cur[j], this.widgetFullName);
					if(inst && inst !== this && !inst.options.disabled) {
						queries.push([$.isFunction(inst.options.items) ? inst.options.items.call(inst.element) : $(inst.options.items, inst.element).not(".ui-sortable-helper").not(".ui-sortable-placeholder"), inst]);
					}
				}
			}
		}

		queries.push([$.isFunction(this.options.items) ? this.options.items.call(this.element, null, { options: this.options, item: this.currentItem }) : $(this.options.items, this.element).not(".ui-sortable-helper").not(".ui-sortable-placeholder"), this]);

		for (i = queries.length - 1; i >= 0; i--){
			queries[i][0].each(function() {
				items.push(this);
			});
		}

		return $(items);

	},

	_removeCurrentsFromItems: function() {

		var list = this.currentItem.find(":data(" + this.widgetName + "-item)");

		this.items = $.grep(this.items, function (item) {
			for (var j=0; j < list.length; j++) {
				if(list[j] === item.item[0]) {
					return false;
				}
			}
			return true;
		});

	},

	_refreshItems: function(event) {

		this.items = [];
		this.containers = [this];

		var i, j, cur, inst, targetData, _queries, item, queriesLength,
			items = this.items,
			queries = [[$.isFunction(this.options.items) ? this.options.items.call(this.element[0], event, { item: this.currentItem }) : $(this.options.items, this.element), this]],
			connectWith = this._connectWith();

		if(connectWith && this.ready) { //Shouldn't be run the first time through due to massive slow-down
			for (i = connectWith.length - 1; i >= 0; i--){
				cur = $(connectWith[i]);
				for (j = cur.length - 1; j >= 0; j--){
					inst = $.data(cur[j], this.widgetFullName);
					if(inst && inst !== this && !inst.options.disabled) {
						queries.push([$.isFunction(inst.options.items) ? inst.options.items.call(inst.element[0], event, { item: this.currentItem }) : $(inst.options.items, inst.element), inst]);
						this.containers.push(inst);
					}
				}
			}
		}

		for (i = queries.length - 1; i >= 0; i--) {
			targetData = queries[i][1];
			_queries = queries[i][0];

			for (j=0, queriesLength = _queries.length; j < queriesLength; j++) {
				item = $(_queries[j]);

				item.data(this.widgetName + "-item", targetData); // Data for target checking (mouse manager)

				items.push({
					item: item,
					instance: targetData,
					width: 0, height: 0,
					left: 0, top: 0
				});
			}
		}

	},

	refreshPositions: function(fast) {

		//This has to be redone because due to the item being moved out/into the offsetParent, the offsetParent's position will change
		if(this.offsetParent && this.helper) {
			this.offset.parent = this._getParentOffset();
		}

		var i, item, t, p;

		for (i = this.items.length - 1; i >= 0; i--){
			item = this.items[i];

			//We ignore calculating positions of all connected containers when we're not over them
			if(item.instance !== this.currentContainer && this.currentContainer && item.item[0] !== this.currentItem[0]) {
				continue;
			}

			t = this.options.toleranceElement ? $(this.options.toleranceElement, item.item) : item.item;

			if (!fast) {
				item.width = t.outerWidth();
				item.height = t.outerHeight();
			}

			p = t.offset();
			item.left = p.left;
			item.top = p.top;
		}

		if(this.options.custom && this.options.custom.refreshContainers) {
			this.options.custom.refreshContainers.call(this);
		} else {
			for (i = this.containers.length - 1; i >= 0; i--){
				p = this.containers[i].element.offset();
				this.containers[i].containerCache.left = p.left;
				this.containers[i].containerCache.top = p.top;
				this.containers[i].containerCache.width	= this.containers[i].element.outerWidth();
				this.containers[i].containerCache.height = this.containers[i].element.outerHeight();
			}
		}

		return this;
	},

	_createPlaceholder: function(that) {
		that = that || this;
		var className,
			o = that.options;

		if(!o.placeholder || o.placeholder.constructor === String) {
			className = o.placeholder;
			o.placeholder = {
				element: function() {

					var nodeName = that.currentItem[0].nodeName.toLowerCase(),
						element = $( that.document[0].createElement( nodeName ) )
							.addClass(className || that.currentItem[0].className+" ui-sortable-placeholder")
							.removeClass("ui-sortable-helper");

					if ( nodeName === "tr" ) {
						// Use a high colspan to force the td to expand the full
						// width of the table (browsers are smart enough to
						// handle this properly)
						element.append( "<td colspan='99'>&#160;</td>" );
					} else if ( nodeName === "img" ) {
						element.attr( "src", that.currentItem.attr( "src" ) );
					}

					if ( !className ) {
						element.css( "visibility", "hidden" );
					}

					return element;
				},
				update: function(container, p) {

					// 1. If a className is set as 'placeholder option, we don't force sizes - the class is responsible for that
					// 2. The option 'forcePlaceholderSize can be enabled to force it even if a class name is specified
					if(className && !o.forcePlaceholderSize) {
						return;
					}

					//If the element doesn't have a actual height by itself (without styles coming from a stylesheet), it receives the inline height from the dragged item
					if(!p.height()) { p.height(that.currentItem.innerHeight() - parseInt(that.currentItem.css("paddingTop")||0, 10) - parseInt(that.currentItem.css("paddingBottom")||0, 10)); }
					if(!p.width()) { p.width(that.currentItem.innerWidth() - parseInt(that.currentItem.css("paddingLeft")||0, 10) - parseInt(that.currentItem.css("paddingRight")||0, 10)); }
				}
			};
		}

		//Create the placeholder
		that.placeholder = $(o.placeholder.element.call(that.element, that.currentItem));

		//Append it after the actual current item
		that.currentItem.after(that.placeholder);

		//Update the size of the placeholder (TODO: Logic to fuzzy, see line 316/317)
		o.placeholder.update(that, that.placeholder);

	},

	_contactContainers: function(event) {
		var i, j, dist, itemWithLeastDistance, posProperty, sizeProperty, base, cur, nearBottom, floating,
			innermostContainer = null,
			innermostIndex = null;

		// get innermost container that intersects with item
		for (i = this.containers.length - 1; i >= 0; i--) {

			// never consider a container that's located within the item itself
			if($.contains(this.currentItem[0], this.containers[i].element[0])) {
				continue;
			}

			if(this._intersectsWith(this.containers[i].containerCache)) {

				// if we've already found a container and it's more "inner" than this, then continue
				if(innermostContainer && $.contains(this.containers[i].element[0], innermostContainer.element[0])) {
					continue;
				}

				innermostContainer = this.containers[i];
				innermostIndex = i;

			} else {
				// container doesn't intersect. trigger "out" event if necessary
				if(this.containers[i].containerCache.over) {
					this.containers[i]._trigger("out", event, this._uiHash(this));
					this.containers[i].containerCache.over = 0;
				}
			}

		}

		// if no intersecting containers found, return
		if(!innermostContainer) {
			return;
		}

		// move the item into the container if it's not there already
		if(this.containers.length === 1) {
			if (!this.containers[innermostIndex].containerCache.over) {
				this.containers[innermostIndex]._trigger("over", event, this._uiHash(this));
				this.containers[innermostIndex].containerCache.over = 1;
			}
		} else {

			//When entering a new container, we will find the item with the least distance and append our item near it
			dist = 10000;
			itemWithLeastDistance = null;
			floating = innermostContainer.floating || isFloating(this.currentItem);
			posProperty = floating ? "left" : "top";
			sizeProperty = floating ? "width" : "height";
			base = this.positionAbs[posProperty] + this.offset.click[posProperty];
			for (j = this.items.length - 1; j >= 0; j--) {
				if(!$.contains(this.containers[innermostIndex].element[0], this.items[j].item[0])) {
					continue;
				}
				if(this.items[j].item[0] === this.currentItem[0]) {
					continue;
				}
				if (floating && !isOverAxis(this.positionAbs.top + this.offset.click.top, this.items[j].top, this.items[j].height)) {
					continue;
				}
				cur = this.items[j].item.offset()[posProperty];
				nearBottom = false;
				if(Math.abs(cur - base) > Math.abs(cur + this.items[j][sizeProperty] - base)){
					nearBottom = true;
					cur += this.items[j][sizeProperty];
				}

				if(Math.abs(cur - base) < dist) {
					dist = Math.abs(cur - base); itemWithLeastDistance = this.items[j];
					this.direction = nearBottom ? "up": "down";
				}
			}

			//Check if dropOnEmpty is enabled
			if(!itemWithLeastDistance && !this.options.dropOnEmpty) {
				return;
			}

			if(this.currentContainer === this.containers[innermostIndex]) {
				return;
			}

			itemWithLeastDistance ? this._rearrange(event, itemWithLeastDistance, null, true) : this._rearrange(event, null, this.containers[innermostIndex].element, true);
			this._trigger("change", event, this._uiHash());
			this.containers[innermostIndex]._trigger("change", event, this._uiHash(this));
			this.currentContainer = this.containers[innermostIndex];

			//Update the placeholder
			this.options.placeholder.update(this.currentContainer, this.placeholder);

			this.containers[innermostIndex]._trigger("over", event, this._uiHash(this));
			this.containers[innermostIndex].containerCache.over = 1;
		}


	},

	_createHelper: function(event) {

		var o = this.options,
			helper = $.isFunction(o.helper) ? $(o.helper.apply(this.element[0], [event, this.currentItem])) : (o.helper === "clone" ? this.currentItem.clone() : this.currentItem);

		//Add the helper to the DOM if that didn't happen already
		if(!helper.parents("body").length) {
			$(o.appendTo !== "parent" ? o.appendTo : this.currentItem[0].parentNode)[0].appendChild(helper[0]);
		}

		if(helper[0] === this.currentItem[0]) {
			this._storedCSS = { width: this.currentItem[0].style.width, height: this.currentItem[0].style.height, position: this.currentItem.css("position"), top: this.currentItem.css("top"), left: this.currentItem.css("left") };
		}

		if(!helper[0].style.width || o.forceHelperSize) {
			helper.width(this.currentItem.width());
		}
		if(!helper[0].style.height || o.forceHelperSize) {
			helper.height(this.currentItem.height());
		}

		return helper;

	},

	_adjustOffsetFromHelper: function(obj) {
		if (typeof obj === "string") {
			obj = obj.split(" ");
		}
		if ($.isArray(obj)) {
			obj = {left: +obj[0], top: +obj[1] || 0};
		}
		if ("left" in obj) {
			this.offset.click.left = obj.left + this.margins.left;
		}
		if ("right" in obj) {
			this.offset.click.left = this.helperProportions.width - obj.right + this.margins.left;
		}
		if ("top" in obj) {
			this.offset.click.top = obj.top + this.margins.top;
		}
		if ("bottom" in obj) {
			this.offset.click.top = this.helperProportions.height - obj.bottom + this.margins.top;
		}
	},

	_getParentOffset: function() {


		//Get the offsetParent and cache its position
		this.offsetParent = this.helper.offsetParent();
		var po = this.offsetParent.offset();

		// This is a special case where we need to modify a offset calculated on start, since the following happened:
		// 1. The position of the helper is absolute, so it's position is calculated based on the next positioned parent
		// 2. The actual offset parent is a child of the scroll parent, and the scroll parent isn't the document, which means that
		//    the scroll is included in the initial calculation of the offset of the parent, and never recalculated upon drag
		if(this.cssPosition === "absolute" && this.scrollParent[0] !== document && $.contains(this.scrollParent[0], this.offsetParent[0])) {
			po.left += this.scrollParent.scrollLeft();
			po.top += this.scrollParent.scrollTop();
		}

		// This needs to be actually done for all browsers, since pageX/pageY includes this information
		// with an ugly IE fix
		if( this.offsetParent[0] === document.body || (this.offsetParent[0].tagName && this.offsetParent[0].tagName.toLowerCase() === "html" && $.ui.ie)) {
			po = { top: 0, left: 0 };
		}

		return {
			top: po.top + (parseInt(this.offsetParent.css("borderTopWidth"),10) || 0),
			left: po.left + (parseInt(this.offsetParent.css("borderLeftWidth"),10) || 0)
		};

	},

	_getRelativeOffset: function() {

		if(this.cssPosition === "relative") {
			var p = this.currentItem.position();
			return {
				top: p.top - (parseInt(this.helper.css("top"),10) || 0) + this.scrollParent.scrollTop(),
				left: p.left - (parseInt(this.helper.css("left"),10) || 0) + this.scrollParent.scrollLeft()
			};
		} else {
			return { top: 0, left: 0 };
		}

	},

	_cacheMargins: function() {
		this.margins = {
			left: (parseInt(this.currentItem.css("marginLeft"),10) || 0),
			top: (parseInt(this.currentItem.css("marginTop"),10) || 0)
		};
	},

	_cacheHelperProportions: function() {
		this.helperProportions = {
			width: this.helper.outerWidth(),
			height: this.helper.outerHeight()
		};
	},

	_setContainment: function() {

		var ce, co, over,
			o = this.options;
		if(o.containment === "parent") {
			o.containment = this.helper[0].parentNode;
		}
		if(o.containment === "document" || o.containment === "window") {
			this.containment = [
				0 - this.offset.relative.left - this.offset.parent.left,
				0 - this.offset.relative.top - this.offset.parent.top,
				$(o.containment === "document" ? document : window).width() - this.helperProportions.width - this.margins.left,
				($(o.containment === "document" ? document : window).height() || document.body.parentNode.scrollHeight) - this.helperProportions.height - this.margins.top
			];
		}

		if(!(/^(document|window|parent)$/).test(o.containment)) {
			ce = $(o.containment)[0];
			co = $(o.containment).offset();
			over = ($(ce).css("overflow") !== "hidden");

			this.containment = [
				co.left + (parseInt($(ce).css("borderLeftWidth"),10) || 0) + (parseInt($(ce).css("paddingLeft"),10) || 0) - this.margins.left,
				co.top + (parseInt($(ce).css("borderTopWidth"),10) || 0) + (parseInt($(ce).css("paddingTop"),10) || 0) - this.margins.top,
				co.left+(over ? Math.max(ce.scrollWidth,ce.offsetWidth) : ce.offsetWidth) - (parseInt($(ce).css("borderLeftWidth"),10) || 0) - (parseInt($(ce).css("paddingRight"),10) || 0) - this.helperProportions.width - this.margins.left,
				co.top+(over ? Math.max(ce.scrollHeight,ce.offsetHeight) : ce.offsetHeight) - (parseInt($(ce).css("borderTopWidth"),10) || 0) - (parseInt($(ce).css("paddingBottom"),10) || 0) - this.helperProportions.height - this.margins.top
			];
		}

	},

	_convertPositionTo: function(d, pos) {

		if(!pos) {
			pos = this.position;
		}
		var mod = d === "absolute" ? 1 : -1,
			scroll = this.cssPosition === "absolute" && !(this.scrollParent[0] !== document && $.contains(this.scrollParent[0], this.offsetParent[0])) ? this.offsetParent : this.scrollParent,
			scrollIsRootNode = (/(html|body)/i).test(scroll[0].tagName);

		return {
			top: (
				pos.top	+																// The absolute mouse position
				this.offset.relative.top * mod +										// Only for relative positioned nodes: Relative offset from element to offset parent
				this.offset.parent.top * mod -											// The offsetParent's offset without borders (offset + border)
				( ( this.cssPosition === "fixed" ? -this.scrollParent.scrollTop() : ( scrollIsRootNode ? 0 : scroll.scrollTop() ) ) * mod)
			),
			left: (
				pos.left +																// The absolute mouse position
				this.offset.relative.left * mod +										// Only for relative positioned nodes: Relative offset from element to offset parent
				this.offset.parent.left * mod	-										// The offsetParent's offset without borders (offset + border)
				( ( this.cssPosition === "fixed" ? -this.scrollParent.scrollLeft() : scrollIsRootNode ? 0 : scroll.scrollLeft() ) * mod)
			)
		};

	},

	_generatePosition: function(event) {

		var top, left,
			o = this.options,
			pageX = event.pageX,
			pageY = event.pageY,
			scroll = this.cssPosition === "absolute" && !(this.scrollParent[0] !== document && $.contains(this.scrollParent[0], this.offsetParent[0])) ? this.offsetParent : this.scrollParent, scrollIsRootNode = (/(html|body)/i).test(scroll[0].tagName);

		// This is another very weird special case that only happens for relative elements:
		// 1. If the css position is relative
		// 2. and the scroll parent is the document or similar to the offset parent
		// we have to refresh the relative offset during the scroll so there are no jumps
		if(this.cssPosition === "relative" && !(this.scrollParent[0] !== document && this.scrollParent[0] !== this.offsetParent[0])) {
			this.offset.relative = this._getRelativeOffset();
		}

		/*
		 * - Position constraining -
		 * Constrain the position to a mix of grid, containment.
		 */

		if(this.originalPosition) { //If we are not dragging yet, we won't check for options

			if(this.containment) {
				if(event.pageX - this.offset.click.left < this.containment[0]) {
					pageX = this.containment[0] + this.offset.click.left;
				}
				if(event.pageY - this.offset.click.top < this.containment[1]) {
					pageY = this.containment[1] + this.offset.click.top;
				}
				if(event.pageX - this.offset.click.left > this.containment[2]) {
					pageX = this.containment[2] + this.offset.click.left;
				}
				if(event.pageY - this.offset.click.top > this.containment[3]) {
					pageY = this.containment[3] + this.offset.click.top;
				}
			}

			if(o.grid) {
				top = this.originalPageY + Math.round((pageY - this.originalPageY) / o.grid[1]) * o.grid[1];
				pageY = this.containment ? ( (top - this.offset.click.top >= this.containment[1] && top - this.offset.click.top <= this.containment[3]) ? top : ((top - this.offset.click.top >= this.containment[1]) ? top - o.grid[1] : top + o.grid[1])) : top;

				left = this.originalPageX + Math.round((pageX - this.originalPageX) / o.grid[0]) * o.grid[0];
				pageX = this.containment ? ( (left - this.offset.click.left >= this.containment[0] && left - this.offset.click.left <= this.containment[2]) ? left : ((left - this.offset.click.left >= this.containment[0]) ? left - o.grid[0] : left + o.grid[0])) : left;
			}

		}

		return {
			top: (
				pageY -																// The absolute mouse position
				this.offset.click.top -													// Click offset (relative to the element)
				this.offset.relative.top	-											// Only for relative positioned nodes: Relative offset from element to offset parent
				this.offset.parent.top +												// The offsetParent's offset without borders (offset + border)
				( ( this.cssPosition === "fixed" ? -this.scrollParent.scrollTop() : ( scrollIsRootNode ? 0 : scroll.scrollTop() ) ))
			),
			left: (
				pageX -																// The absolute mouse position
				this.offset.click.left -												// Click offset (relative to the element)
				this.offset.relative.left	-											// Only for relative positioned nodes: Relative offset from element to offset parent
				this.offset.parent.left +												// The offsetParent's offset without borders (offset + border)
				( ( this.cssPosition === "fixed" ? -this.scrollParent.scrollLeft() : scrollIsRootNode ? 0 : scroll.scrollLeft() ))
			)
		};

	},

	_rearrange: function(event, i, a, hardRefresh) {

		a ? a[0].appendChild(this.placeholder[0]) : i.item[0].parentNode.insertBefore(this.placeholder[0], (this.direction === "down" ? i.item[0] : i.item[0].nextSibling));

		//Various things done here to improve the performance:
		// 1. we create a setTimeout, that calls refreshPositions
		// 2. on the instance, we have a counter variable, that get's higher after every append
		// 3. on the local scope, we copy the counter variable, and check in the timeout, if it's still the same
		// 4. this lets only the last addition to the timeout stack through
		this.counter = this.counter ? ++this.counter : 1;
		var counter = this.counter;

		this._delay(function() {
			if(counter === this.counter) {
				this.refreshPositions(!hardRefresh); //Precompute after each DOM insertion, NOT on mousemove
			}
		});

	},

	_clear: function(event, noPropagation) {

		this.reverting = false;
		// We delay all events that have to be triggered to after the point where the placeholder has been removed and
		// everything else normalized again
		var i,
			delayedTriggers = [];

		// We first have to update the dom position of the actual currentItem
		// Note: don't do it if the current item is already removed (by a user), or it gets reappended (see #4088)
		if(!this._noFinalSort && this.currentItem.parent().length) {
			this.placeholder.before(this.currentItem);
		}
		this._noFinalSort = null;

		if(this.helper[0] === this.currentItem[0]) {
			for(i in this._storedCSS) {
				if(this._storedCSS[i] === "auto" || this._storedCSS[i] === "static") {
					this._storedCSS[i] = "";
				}
			}
			this.currentItem.css(this._storedCSS).removeClass("ui-sortable-helper");
		} else {
			this.currentItem.show();
		}

		if(this.fromOutside && !noPropagation) {
			delayedTriggers.push(function(event) { this._trigger("receive", event, this._uiHash(this.fromOutside)); });
		}
		if((this.fromOutside || this.domPosition.prev !== this.currentItem.prev().not(".ui-sortable-helper")[0] || this.domPosition.parent !== this.currentItem.parent()[0]) && !noPropagation) {
			delayedTriggers.push(function(event) { this._trigger("update", event, this._uiHash()); }); //Trigger update callback if the DOM position has changed
		}

		// Check if the items Container has Changed and trigger appropriate
		// events.
		if (this !== this.currentContainer) {
			if(!noPropagation) {
				delayedTriggers.push(function(event) { this._trigger("remove", event, this._uiHash()); });
				delayedTriggers.push((function(c) { return function(event) { c._trigger("receive", event, this._uiHash(this)); };  }).call(this, this.currentContainer));
				delayedTriggers.push((function(c) { return function(event) { c._trigger("update", event, this._uiHash(this));  }; }).call(this, this.currentContainer));
			}
		}


		//Post events to containers
		for (i = this.containers.length - 1; i >= 0; i--){
			if(!noPropagation) {
				delayedTriggers.push((function(c) { return function(event) { c._trigger("deactivate", event, this._uiHash(this)); };  }).call(this, this.containers[i]));
			}
			if(this.containers[i].containerCache.over) {
				delayedTriggers.push((function(c) { return function(event) { c._trigger("out", event, this._uiHash(this)); };  }).call(this, this.containers[i]));
				this.containers[i].containerCache.over = 0;
			}
		}

		//Do what was originally in plugins
		if ( this.storedCursor ) {
			this.document.find( "body" ).css( "cursor", this.storedCursor );
			this.storedStylesheet.remove();
		}
		if(this._storedOpacity) {
			this.helper.css("opacity", this._storedOpacity);
		}
		if(this._storedZIndex) {
			this.helper.css("zIndex", this._storedZIndex === "auto" ? "" : this._storedZIndex);
		}

		this.dragging = false;
		if(this.cancelHelperRemoval) {
			if(!noPropagation) {
				this._trigger("beforeStop", event, this._uiHash());
				for (i=0; i < delayedTriggers.length; i++) {
					delayedTriggers[i].call(this, event);
				} //Trigger all delayed events
				this._trigger("stop", event, this._uiHash());
			}

			this.fromOutside = false;
			return false;
		}

		if(!noPropagation) {
			this._trigger("beforeStop", event, this._uiHash());
		}

		//$(this.placeholder[0]).remove(); would have been the jQuery way - unfortunately, it unbinds ALL events from the original node!
		this.placeholder[0].parentNode.removeChild(this.placeholder[0]);

		if(this.helper[0] !== this.currentItem[0]) {
			this.helper.remove();
		}
		this.helper = null;

		if(!noPropagation) {
			for (i=0; i < delayedTriggers.length; i++) {
				delayedTriggers[i].call(this, event);
			} //Trigger all delayed events
			this._trigger("stop", event, this._uiHash());
		}

		this.fromOutside = false;
		return true;

	},

	_trigger: function() {
		if ($.Widget.prototype._trigger.apply(this, arguments) === false) {
			this.cancel();
		}
	},

	_uiHash: function(_inst) {
		var inst = _inst || this;
		return {
			helper: inst.helper,
			placeholder: inst.placeholder || $([]),
			position: inst.position,
			originalPosition: inst.originalPosition,
			offset: inst.positionAbs,
			item: inst.currentItem,
			sender: _inst ? _inst.element : null
		};
	}

});

})(jQuery);

  }).call(context, context.jquery);

  (function(window) {
    /* ===================================================
 * bootstrap-transition.js v2.3.1
 * http://twitter.github.com/bootstrap/javascript.html#transitions
 * ===================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ========================================================== */


!function ($) {

  "use strict"; // jshint ;_;


  /* CSS TRANSITION SUPPORT (http://www.modernizr.com/)
   * ======================================================= */

  $(function () {

    $.support.transition = (function () {

      var transitionEnd = (function () {

        var el = document.createElement('bootstrap')
          , transEndEventNames = {
               'WebkitTransition' : 'webkitTransitionEnd'
            ,  'MozTransition'    : 'transitionend'
            ,  'OTransition'      : 'oTransitionEnd otransitionend'
            ,  'transition'       : 'transitionend'
            }
          , name

        for (name in transEndEventNames){
          if (el.style[name] !== undefined) {
            return transEndEventNames[name]
          }
        }

      }())

      return transitionEnd && {
        end: transitionEnd
      }

    })()

  })

}(window.jQuery);/* ==========================================================
 * bootstrap-alert.js v2.3.1
 * http://twitter.github.com/bootstrap/javascript.html#alerts
 * ==========================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ========================================================== */


!function ($) {

  "use strict"; // jshint ;_;


 /* ALERT CLASS DEFINITION
  * ====================== */

  var dismiss = '[data-dismiss="alert"]'
    , Alert = function (el) {
        $(el).on('click', dismiss, this.close)
      }

  Alert.prototype.close = function (e) {
    var $this = $(this)
      , selector = $this.data('target')
      , $parent

    if (!selector) {
      selector = $this.attr('href')
      selector = selector && selector.replace(/.*(?=#[^\s]*$)/, '') //strip for ie7
    }

    $parent = $(selector)

    e && e.preventDefault()

    $parent.length || ($parent = $this.hasClass('alert') ? $this : $this.parent())

    $parent.trigger(e = $.Event('close'))

    if (e.isDefaultPrevented()) return

    $parent.removeClass('in')

    function removeElement() {
      $parent
        .trigger('closed')
        .remove()
    }

    $.support.transition && $parent.hasClass('fade') ?
      $parent.on($.support.transition.end, removeElement) :
      removeElement()
  }


 /* ALERT PLUGIN DEFINITION
  * ======================= */

  var old = $.fn.alert

  $.fn.alert = function (option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('alert')
      if (!data) $this.data('alert', (data = new Alert(this)))
      if (typeof option == 'string') data[option].call($this)
    })
  }

  $.fn.alert.Constructor = Alert


 /* ALERT NO CONFLICT
  * ================= */

  $.fn.alert.noConflict = function () {
    $.fn.alert = old
    return this
  }


 /* ALERT DATA-API
  * ============== */

  $(document).on('click.alert.data-api', dismiss, Alert.prototype.close)

}(window.jQuery);/* ============================================================
 * bootstrap-button.js v2.3.1
 * http://twitter.github.com/bootstrap/javascript.html#buttons
 * ============================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ============================================================ */


!function ($) {

  "use strict"; // jshint ;_;


 /* BUTTON PUBLIC CLASS DEFINITION
  * ============================== */

  var Button = function (element, options) {
    this.$element = $(element)
    this.options = $.extend({}, $.fn.button.defaults, options)
  }

  Button.prototype.setState = function (state) {
    var d = 'disabled'
      , $el = this.$element
      , data = $el.data()
      , val = $el.is('input') ? 'val' : 'html'

    state = state + 'Text'
    data.resetText || $el.data('resetText', $el[val]())

    $el[val](data[state] || this.options[state])

    // push to event loop to allow forms to submit
    setTimeout(function () {
      state == 'loadingText' ?
        $el.addClass(d).attr(d, d) :
        $el.removeClass(d).removeAttr(d)
    }, 0)
  }

  Button.prototype.toggle = function () {
    var $parent = this.$element.closest('[data-toggle="buttons-radio"]')

    $parent && $parent
      .find('.active')
      .removeClass('active')

    this.$element.toggleClass('active')
  }


 /* BUTTON PLUGIN DEFINITION
  * ======================== */

  var old = $.fn.button

  $.fn.button = function (option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('button')
        , options = typeof option == 'object' && option
      if (!data) $this.data('button', (data = new Button(this, options)))
      if (option == 'toggle') data.toggle()
      else if (option) data.setState(option)
    })
  }

  $.fn.button.defaults = {
    loadingText: 'loading...'
  }

  $.fn.button.Constructor = Button


 /* BUTTON NO CONFLICT
  * ================== */

  $.fn.button.noConflict = function () {
    $.fn.button = old
    return this
  }


 /* BUTTON DATA-API
  * =============== */

  $(document).on('click.button.data-api', '[data-toggle^=button]', function (e) {
    var $btn = $(e.target)
    if (!$btn.hasClass('btn')) $btn = $btn.closest('.btn')
    $btn.button('toggle')
  })

}(window.jQuery);/* ==========================================================
 * bootstrap-carousel.js v2.3.1
 * http://twitter.github.com/bootstrap/javascript.html#carousel
 * ==========================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ========================================================== */


!function ($) {

  "use strict"; // jshint ;_;


 /* CAROUSEL CLASS DEFINITION
  * ========================= */

  var Carousel = function (element, options) {
    this.$element = $(element)
    this.$indicators = this.$element.find('.carousel-indicators')
    this.options = options
    this.options.pause == 'hover' && this.$element
      .on('mouseenter', $.proxy(this.pause, this))
      .on('mouseleave', $.proxy(this.cycle, this))
  }

  Carousel.prototype = {

    cycle: function (e) {
      if (!e) this.paused = false
      if (this.interval) clearInterval(this.interval);
      this.options.interval
        && !this.paused
        && (this.interval = setInterval($.proxy(this.next, this), this.options.interval))
      return this
    }

  , getActiveIndex: function () {
      this.$active = this.$element.find('.item.active')
      this.$items = this.$active.parent().children()
      return this.$items.index(this.$active)
    }

  , to: function (pos) {
      var activeIndex = this.getActiveIndex()
        , that = this

      if (pos > (this.$items.length - 1) || pos < 0) return

      if (this.sliding) {
        return this.$element.one('slid', function () {
          that.to(pos)
        })
      }

      if (activeIndex == pos) {
        return this.pause().cycle()
      }

      return this.slide(pos > activeIndex ? 'next' : 'prev', $(this.$items[pos]))
    }

  , pause: function (e) {
      if (!e) this.paused = true
      if (this.$element.find('.next, .prev').length && $.support.transition.end) {
        this.$element.trigger($.support.transition.end)
        this.cycle(true)
      }
      clearInterval(this.interval)
      this.interval = null
      return this
    }

  , next: function () {
      if (this.sliding) return
      return this.slide('next')
    }

  , prev: function () {
      if (this.sliding) return
      return this.slide('prev')
    }

  , slide: function (type, next) {
      var $active = this.$element.find('.item.active')
        , $next = next || $active[type]()
        , isCycling = this.interval
        , direction = type == 'next' ? 'left' : 'right'
        , fallback  = type == 'next' ? 'first' : 'last'
        , that = this
        , e

      this.sliding = true

      isCycling && this.pause()

      $next = $next.length ? $next : this.$element.find('.item')[fallback]()

      e = $.Event('slide', {
        relatedTarget: $next[0]
      , direction: direction
      })

      if ($next.hasClass('active')) return

      if (this.$indicators.length) {
        this.$indicators.find('.active').removeClass('active')
        this.$element.one('slid', function () {
          var $nextIndicator = $(that.$indicators.children()[that.getActiveIndex()])
          $nextIndicator && $nextIndicator.addClass('active')
        })
      }

      if ($.support.transition && this.$element.hasClass('slide')) {
        this.$element.trigger(e)
        if (e.isDefaultPrevented()) return
        $next.addClass(type)
        $next[0].offsetWidth // force reflow
        $active.addClass(direction)
        $next.addClass(direction)
        this.$element.one($.support.transition.end, function () {
          $next.removeClass([type, direction].join(' ')).addClass('active')
          $active.removeClass(['active', direction].join(' '))
          that.sliding = false
          setTimeout(function () { that.$element.trigger('slid') }, 0)
        })
      } else {
        this.$element.trigger(e)
        if (e.isDefaultPrevented()) return
        $active.removeClass('active')
        $next.addClass('active')
        this.sliding = false
        this.$element.trigger('slid')
      }

      isCycling && this.cycle()

      return this
    }

  }


 /* CAROUSEL PLUGIN DEFINITION
  * ========================== */

  var old = $.fn.carousel

  $.fn.carousel = function (option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('carousel')
        , options = $.extend({}, $.fn.carousel.defaults, typeof option == 'object' && option)
        , action = typeof option == 'string' ? option : options.slide
      if (!data) $this.data('carousel', (data = new Carousel(this, options)))
      if (typeof option == 'number') data.to(option)
      else if (action) data[action]()
      else if (options.interval) data.pause().cycle()
    })
  }

  $.fn.carousel.defaults = {
    interval: 5000
  , pause: 'hover'
  }

  $.fn.carousel.Constructor = Carousel


 /* CAROUSEL NO CONFLICT
  * ==================== */

  $.fn.carousel.noConflict = function () {
    $.fn.carousel = old
    return this
  }

 /* CAROUSEL DATA-API
  * ================= */

  $(document).on('click.carousel.data-api', '[data-slide], [data-slide-to]', function (e) {
    var $this = $(this), href
      , $target = $($this.data('target') || (href = $this.attr('href')) && href.replace(/.*(?=#[^\s]+$)/, '')) //strip for ie7
      , options = $.extend({}, $target.data(), $this.data())
      , slideIndex

    $target.carousel(options)

    if (slideIndex = $this.attr('data-slide-to')) {
      $target.data('carousel').pause().to(slideIndex).cycle()
    }

    e.preventDefault()
  })

}(window.jQuery);/* =============================================================
 * bootstrap-collapse.js v2.3.1
 * http://twitter.github.com/bootstrap/javascript.html#collapse
 * =============================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ============================================================ */


!function ($) {

  "use strict"; // jshint ;_;


 /* COLLAPSE PUBLIC CLASS DEFINITION
  * ================================ */

  var Collapse = function (element, options) {
    this.$element = $(element)
    this.options = $.extend({}, $.fn.collapse.defaults, options)

    if (this.options.parent) {
      this.$parent = $(this.options.parent)
    }

    this.options.toggle && this.toggle()
  }

  Collapse.prototype = {

    constructor: Collapse

  , dimension: function () {
      var hasWidth = this.$element.hasClass('width')
      return hasWidth ? 'width' : 'height'
    }

  , show: function () {
      var dimension
        , scroll
        , actives
        , hasData

      if (this.transitioning || this.$element.hasClass('in')) return

      dimension = this.dimension()
      scroll = $.camelCase(['scroll', dimension].join('-'))
      actives = this.$parent && this.$parent.find('> .accordion-group > .in')

      if (actives && actives.length) {
        hasData = actives.data('collapse')
        if (hasData && hasData.transitioning) return
        actives.collapse('hide')
        hasData || actives.data('collapse', null)
      }

      this.$element[dimension](0)
      this.transition('addClass', $.Event('show'), 'shown')
      $.support.transition && this.$element[dimension](this.$element[0][scroll])
    }

  , hide: function () {
      var dimension
      if (this.transitioning || !this.$element.hasClass('in')) return
      dimension = this.dimension()
      this.reset(this.$element[dimension]())
      this.transition('removeClass', $.Event('hide'), 'hidden')
      this.$element[dimension](0)
    }

  , reset: function (size) {
      var dimension = this.dimension()

      this.$element
        .removeClass('collapse')
        [dimension](size || 'auto')
        [0].offsetWidth

      this.$element[size !== null ? 'addClass' : 'removeClass']('collapse')

      return this
    }

  , transition: function (method, startEvent, completeEvent) {
      var that = this
        , complete = function () {
            if (startEvent.type == 'show') that.reset()
            that.transitioning = 0
            that.$element.trigger(completeEvent)
          }

      this.$element.trigger(startEvent)

      if (startEvent.isDefaultPrevented()) return

      this.transitioning = 1

      this.$element[method]('in')

      $.support.transition && this.$element.hasClass('collapse') ?
        this.$element.one($.support.transition.end, complete) :
        complete()
    }

  , toggle: function () {
      this[this.$element.hasClass('in') ? 'hide' : 'show']()
    }

  }


 /* COLLAPSE PLUGIN DEFINITION
  * ========================== */

  var old = $.fn.collapse

  $.fn.collapse = function (option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('collapse')
        , options = $.extend({}, $.fn.collapse.defaults, $this.data(), typeof option == 'object' && option)
      if (!data) $this.data('collapse', (data = new Collapse(this, options)))
      if (typeof option == 'string') data[option]()
    })
  }

  $.fn.collapse.defaults = {
    toggle: true
  }

  $.fn.collapse.Constructor = Collapse


 /* COLLAPSE NO CONFLICT
  * ==================== */

  $.fn.collapse.noConflict = function () {
    $.fn.collapse = old
    return this
  }


 /* COLLAPSE DATA-API
  * ================= */

  $(document).on('click.collapse.data-api', '[data-toggle=collapse]', function (e) {
    var $this = $(this), href
      , target = $this.data('target')
        || e.preventDefault()
        || (href = $this.attr('href')) && href.replace(/.*(?=#[^\s]+$)/, '') //strip for ie7
      , option = $(target).data('collapse') ? 'toggle' : $this.data()
    $this[$(target).hasClass('in') ? 'addClass' : 'removeClass']('collapsed')
    $(target).collapse(option)
  })

}(window.jQuery);/* ============================================================
 * bootstrap-dropdown.js v2.3.1
 * http://twitter.github.com/bootstrap/javascript.html#dropdowns
 * ============================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ============================================================ */


!function ($) {

  "use strict"; // jshint ;_;


 /* DROPDOWN CLASS DEFINITION
  * ========================= */

  var toggle = '[data-toggle=dropdown]'
    , Dropdown = function (element) {
        var $el = $(element).on('click.dropdown.data-api', this.toggle)
        $('html').on('click.dropdown.data-api', function () {
          $el.parent().removeClass('open')
        })
      }

  Dropdown.prototype = {

    constructor: Dropdown

  , toggle: function (e) {
      var $this = $(this)
        , $parent
        , isActive

      if ($this.is('.disabled, :disabled')) return

      $parent = getParent($this)

      isActive = $parent.hasClass('open')

      clearMenus()

      if (!isActive) {
        $parent.toggleClass('open')
      }

      $this.focus()

      return false
    }

  , keydown: function (e) {
      var $this
        , $items
        , $active
        , $parent
        , isActive
        , index

      if (!/(38|40|27)/.test(e.keyCode)) return

      $this = $(this)

      e.preventDefault()
      e.stopPropagation()

      if ($this.is('.disabled, :disabled')) return

      $parent = getParent($this)

      isActive = $parent.hasClass('open')

      if (!isActive || (isActive && e.keyCode == 27)) {
        if (e.which == 27) $parent.find(toggle).focus()
        return $this.click()
      }

      $items = $('[role=menu] li:not(.divider):visible a', $parent)

      if (!$items.length) return

      index = $items.index($items.filter(':focus'))

      if (e.keyCode == 38 && index > 0) index--                                        // up
      if (e.keyCode == 40 && index < $items.length - 1) index++                        // down
      if (!~index) index = 0

      $items
        .eq(index)
        .focus()
    }

  }

  function clearMenus() {
    $(toggle).each(function () {
      getParent($(this)).removeClass('open')
    })
  }

  function getParent($this) {
    var selector = $this.data('target')
      , $parent

    if (!selector) {
      selector = $this.attr('href')
      selector = selector && /#/.test(selector) && selector.replace(/.*(?=#[^\s]*$)/, '') //strip for ie7
    }

    $parent = selector && $(selector)

    if (!$parent || !$parent.length) $parent = $this.parent()

    return $parent
  }


  /* DROPDOWN PLUGIN DEFINITION
   * ========================== */

  var old = $.fn.dropdown

  $.fn.dropdown = function (option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('dropdown')
      if (!data) $this.data('dropdown', (data = new Dropdown(this)))
      if (typeof option == 'string') data[option].call($this)
    })
  }

  $.fn.dropdown.Constructor = Dropdown


 /* DROPDOWN NO CONFLICT
  * ==================== */

  $.fn.dropdown.noConflict = function () {
    $.fn.dropdown = old
    return this
  }


  /* APPLY TO STANDARD DROPDOWN ELEMENTS
   * =================================== */

  $(document)
    .on('click.dropdown.data-api', clearMenus)
    .on('click.dropdown.data-api', '.dropdown form', function (e) { e.stopPropagation() })
    .on('click.dropdown-menu', function (e) { e.stopPropagation() })
    .on('click.dropdown.data-api'  , toggle, Dropdown.prototype.toggle)
    .on('keydown.dropdown.data-api', toggle + ', [role=menu]' , Dropdown.prototype.keydown)

}(window.jQuery);
/* =========================================================
 * bootstrap-modal.js v2.3.1
 * http://twitter.github.com/bootstrap/javascript.html#modals
 * =========================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ========================================================= */


!function ($) {

  "use strict"; // jshint ;_;


 /* MODAL CLASS DEFINITION
  * ====================== */

  var Modal = function (element, options) {
    this.options = options
    this.$element = $(element)
      .delegate('[data-dismiss="modal"]', 'click.dismiss.modal', $.proxy(this.hide, this))
    this.options.remote && this.$element.find('.modal-body').load(this.options.remote)
  }

  Modal.prototype = {

      constructor: Modal

    , toggle: function () {
        return this[!this.isShown ? 'show' : 'hide']()
      }

    , show: function () {
        var that = this
          , e = $.Event('show')

        this.$element.trigger(e)

        if (this.isShown || e.isDefaultPrevented()) return

        this.isShown = true

        this.escape()

        this.backdrop(function () {
          var transition = $.support.transition && that.$element.hasClass('fade')

          if (!that.$element.parent().length) {
            that.$element.appendTo(document.body) //don't move modals dom position
          }

          that.$element.show()

          if (transition) {
            that.$element[0].offsetWidth // force reflow
          }

          that.$element
            .addClass('in')
            .attr('aria-hidden', false)

          that.enforceFocus()

          transition ?
            that.$element.one($.support.transition.end, function () { that.$element.focus().trigger('shown') }) :
            that.$element.focus().trigger('shown')

        })
      }

    , hide: function (e) {
        e && e.preventDefault()

        var that = this

        e = $.Event('hide')

        this.$element.trigger(e)

        if (!this.isShown || e.isDefaultPrevented()) return

        this.isShown = false

        this.escape()

        $(document).off('focusin.modal')

        this.$element
          .removeClass('in')
          .attr('aria-hidden', true)

        $.support.transition && this.$element.hasClass('fade') ?
          this.hideWithTransition() :
          this.hideModal()
      }

    , enforceFocus: function () {
        var that = this
        $(document).on('focusin.modal', function (e) {
          if (that.$element[0] !== e.target && !that.$element.has(e.target).length) {
            that.$element.focus()
          }
        })
      }

    , escape: function () {
        var that = this
        if (this.isShown && this.options.keyboard) {
          this.$element.on('keyup.dismiss.modal', function ( e ) {
            e.which == 27 && that.hide()
          })
        } else if (!this.isShown) {
          this.$element.off('keyup.dismiss.modal')
        }
      }

    , hideWithTransition: function () {
        var that = this
          , timeout = setTimeout(function () {
              that.$element.off($.support.transition.end)
              that.hideModal()
            }, 500)

        this.$element.one($.support.transition.end, function () {
          clearTimeout(timeout)
          that.hideModal()
        })
      }

    , hideModal: function () {
        var that = this
        this.$element.hide()
        this.backdrop(function () {
          that.removeBackdrop()
          that.$element.trigger('hidden')
        })
      }

    , removeBackdrop: function () {
        this.$backdrop && this.$backdrop.remove()
        this.$backdrop = null
      }

    , backdrop: function (callback) {
        var that = this
          , animate = this.$element.hasClass('fade') ? 'fade' : ''

        if (this.isShown && this.options.backdrop) {
          var doAnimate = $.support.transition && animate

          this.$backdrop = $('<div class="modal-backdrop ' + animate + '" />')
            .appendTo(document.body)

          this.$backdrop.click(
            this.options.backdrop == 'static' ?
              $.proxy(this.$element[0].focus, this.$element[0])
            : $.proxy(this.hide, this)
          )

          if (doAnimate) this.$backdrop[0].offsetWidth // force reflow

          this.$backdrop.addClass('in')

          if (!callback) return

          doAnimate ?
            this.$backdrop.one($.support.transition.end, callback) :
            callback()

        } else if (!this.isShown && this.$backdrop) {
          this.$backdrop.removeClass('in')

          $.support.transition && this.$element.hasClass('fade')?
            this.$backdrop.one($.support.transition.end, callback) :
            callback()

        } else if (callback) {
          callback()
        }
      }
  }


 /* MODAL PLUGIN DEFINITION
  * ======================= */

  var old = $.fn.modal

  $.fn.modal = function (option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('modal')
        , options = $.extend({}, $.fn.modal.defaults, $this.data(), typeof option == 'object' && option)
      if (!data) $this.data('modal', (data = new Modal(this, options)))
      if (typeof option == 'string') data[option]()
      else if (options.show) data.show()
    })
  }

  $.fn.modal.defaults = {
      backdrop: true
    , keyboard: true
    , show: true
  }

  $.fn.modal.Constructor = Modal


 /* MODAL NO CONFLICT
  * ================= */

  $.fn.modal.noConflict = function () {
    $.fn.modal = old
    return this
  }


 /* MODAL DATA-API
  * ============== */

  $(document).on('click.modal.data-api', '[data-toggle="modal"]', function (e) {
    var $this = $(this)
      , href = $this.attr('href')
      , $target = $($this.data('target') || (href && href.replace(/.*(?=#[^\s]+$)/, ''))) //strip for ie7
      , option = $target.data('modal') ? 'toggle' : $.extend({ remote:!/#/.test(href) && href }, $target.data(), $this.data())

    e.preventDefault()

    $target
      .modal(option)
      .one('hide', function () {
        $this.focus()
      })
  })

}(window.jQuery);
/* ===========================================================
 * bootstrap-tooltip.js v2.3.1
 * http://twitter.github.com/bootstrap/javascript.html#tooltips
 * Inspired by the original jQuery.tipsy by Jason Frame
 * ===========================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ========================================================== */


!function ($) {

  "use strict"; // jshint ;_;


 /* TOOLTIP PUBLIC CLASS DEFINITION
  * =============================== */

  var Tooltip = function (element, options) {
    this.init('tooltip', element, options)
  }

  Tooltip.prototype = {

    constructor: Tooltip

  , init: function (type, element, options) {
      var eventIn
        , eventOut
        , triggers
        , trigger
        , i

      this.type = type
      this.$element = $(element)
      this.options = this.getOptions(options)
      this.enabled = true

      triggers = this.options.trigger.split(' ')

      for (i = triggers.length; i--;) {
        trigger = triggers[i]
        if (trigger == 'click') {
          this.$element.on('click.' + this.type, this.options.selector, $.proxy(this.toggle, this))
        } else if (trigger != 'manual') {
          eventIn = trigger == 'hover' ? 'mouseenter' : 'focus'
          eventOut = trigger == 'hover' ? 'mouseleave' : 'blur'
          this.$element.on(eventIn + '.' + this.type, this.options.selector, $.proxy(this.enter, this))
          this.$element.on(eventOut + '.' + this.type, this.options.selector, $.proxy(this.leave, this))
        }
      }

      this.options.selector ?
        (this._options = $.extend({}, this.options, { trigger: 'manual', selector: '' })) :
        this.fixTitle()
    }

  , getOptions: function (options) {
      options = $.extend({}, $.fn[this.type].defaults, this.$element.data(), options)

      if (options.delay && typeof options.delay == 'number') {
        options.delay = {
          show: options.delay
        , hide: options.delay
        }
      }

      return options
    }

  , enter: function (e) {
      var defaults = $.fn[this.type].defaults
        , options = {}
        , self

      this._options && $.each(this._options, function (key, value) {
        if (defaults[key] != value) options[key] = value
      }, this)

      self = $(e.currentTarget)[this.type](options).data(this.type)

      if (!self.options.delay || !self.options.delay.show) return self.show()

      clearTimeout(this.timeout)
      self.hoverState = 'in'
      this.timeout = setTimeout(function() {
        if (self.hoverState == 'in') self.show()
      }, self.options.delay.show)
    }

  , leave: function (e) {
      var self = $(e.currentTarget)[this.type](this._options).data(this.type)

      if (this.timeout) clearTimeout(this.timeout)
      if (!self.options.delay || !self.options.delay.hide) return self.hide()

      self.hoverState = 'out'
      this.timeout = setTimeout(function() {
        if (self.hoverState == 'out') self.hide()
      }, self.options.delay.hide)
    }

  , show: function () {
      var $tip
        , pos
        , actualWidth
        , actualHeight
        , placement
        , tp
        , e = $.Event('show')

      if (this.hasContent() && this.enabled) {
        this.$element.trigger(e)
        if (e.isDefaultPrevented()) return
        $tip = this.tip()
        this.setContent()

        if (this.options.animation) {
          $tip.addClass('fade')
        }

        placement = typeof this.options.placement == 'function' ?
          this.options.placement.call(this, $tip[0], this.$element[0]) :
          this.options.placement

        $tip
          .detach()
          .css({ top: 0, left: 0, display: 'block' })

        this.options.container ? $tip.appendTo(this.options.container) : $tip.insertAfter(this.$element)

        pos = this.getPosition()

        actualWidth = $tip[0].offsetWidth
        actualHeight = $tip[0].offsetHeight

        switch (placement) {
          case 'bottom':
            tp = {top: pos.top + pos.height, left: pos.left + pos.width / 2 - actualWidth / 2}
            break
          case 'top':
            tp = {top: pos.top - actualHeight, left: pos.left + pos.width / 2 - actualWidth / 2}
            break
          case 'left':
            tp = {top: pos.top + pos.height / 2 - actualHeight / 2, left: pos.left - actualWidth}
            break
          case 'right':
            tp = {top: pos.top + pos.height / 2 - actualHeight / 2, left: pos.left + pos.width}
            break
        }

        this.applyPlacement(tp, placement)
        this.$element.trigger('shown')
      }
    }

  , applyPlacement: function(offset, placement){
      var $tip = this.tip()
        , width = $tip[0].offsetWidth
        , height = $tip[0].offsetHeight
        , actualWidth
        , actualHeight
        , delta
        , replace

      $tip
        .offset(offset)
        .addClass(placement)
        .addClass('in')

      actualWidth = $tip[0].offsetWidth
      actualHeight = $tip[0].offsetHeight

      if (placement == 'top' && actualHeight != height) {
        offset.top = offset.top + height - actualHeight
        replace = true
      }

      if (placement == 'bottom' || placement == 'top') {
        delta = 0

        if (offset.left < 0){
          delta = offset.left * -2
          offset.left = 0
          $tip.offset(offset)
          actualWidth = $tip[0].offsetWidth
          actualHeight = $tip[0].offsetHeight
        }

        this.replaceArrow(delta - width + actualWidth, actualWidth, 'left')
      } else {
        this.replaceArrow(actualHeight - height, actualHeight, 'top')
      }

      if (replace) $tip.offset(offset)
    }

  , replaceArrow: function(delta, dimension, position){
      this
        .arrow()
        .css(position, delta ? (50 * (1 - delta / dimension) + "%") : '')
    }

  , setContent: function () {
      var $tip = this.tip()
        , title = this.getTitle()

      $tip.find('.tooltip-inner')[this.options.html ? 'html' : 'text'](title)
      $tip.removeClass('fade in top bottom left right')
    }

  , hide: function () {
      var that = this
        , $tip = this.tip()
        , e = $.Event('hide')

      this.$element.trigger(e)
      if (e.isDefaultPrevented()) return

      $tip.removeClass('in')

      function removeWithAnimation() {
        var timeout = setTimeout(function () {
          $tip.off($.support.transition.end).detach()
        }, 500)

        $tip.one($.support.transition.end, function () {
          clearTimeout(timeout)
          $tip.detach()
        })
      }

      $.support.transition && this.$tip.hasClass('fade') ?
        removeWithAnimation() :
        $tip.detach()

      this.$element.trigger('hidden')

      return this
    }

  , fixTitle: function () {
      var $e = this.$element
      if ($e.attr('title') || typeof($e.attr('data-original-title')) != 'string') {
        $e.attr('data-original-title', $e.attr('title') || '').attr('title', '')
      }
    }

  , hasContent: function () {
      return this.getTitle()
    }

  , getPosition: function () {
      var el = this.$element[0]
      return $.extend({}, (typeof el.getBoundingClientRect == 'function') ? el.getBoundingClientRect() : {
        width: el.offsetWidth
      , height: el.offsetHeight
      }, this.$element.offset())
    }

  , getTitle: function () {
      var title
        , $e = this.$element
        , o = this.options

      title = $e.attr('data-original-title')
        || (typeof o.title == 'function' ? o.title.call($e[0]) :  o.title)

      return title
    }

  , tip: function () {
      return this.$tip = this.$tip || $(this.options.template)
    }

  , arrow: function(){
      return this.$arrow = this.$arrow || this.tip().find(".tooltip-arrow")
    }

  , validate: function () {
      if (!this.$element[0].parentNode) {
        this.hide()
        this.$element = null
        this.options = null
      }
    }

  , enable: function () {
      this.enabled = true
    }

  , disable: function () {
      this.enabled = false
    }

  , toggleEnabled: function () {
      this.enabled = !this.enabled
    }

  , toggle: function (e) {
      var self = e ? $(e.currentTarget)[this.type](this._options).data(this.type) : this
      self.tip().hasClass('in') ? self.hide() : self.show()
    }

  , destroy: function () {
      this.hide().$element.off('.' + this.type).removeData(this.type)
    }

  }


 /* TOOLTIP PLUGIN DEFINITION
  * ========================= */

  var old = $.fn.tooltip

  $.fn.tooltip = function ( option ) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('tooltip')
        , options = typeof option == 'object' && option
      if (!data) $this.data('tooltip', (data = new Tooltip(this, options)))
      if (typeof option == 'string') data[option]()
    })
  }

  $.fn.tooltip.Constructor = Tooltip

  $.fn.tooltip.defaults = {
    animation: true
  , placement: 'top'
  , selector: false
  , template: '<div class="tooltip"><div class="tooltip-arrow"></div><div class="tooltip-inner"></div></div>'
  , trigger: 'hover focus'
  , title: ''
  , delay: 0
  , html: false
  , container: false
  }


 /* TOOLTIP NO CONFLICT
  * =================== */

  $.fn.tooltip.noConflict = function () {
    $.fn.tooltip = old
    return this
  }

}(window.jQuery);
/* ===========================================================
 * bootstrap-popover.js v2.3.1
 * http://twitter.github.com/bootstrap/javascript.html#popovers
 * ===========================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * =========================================================== */


!function ($) {

  "use strict"; // jshint ;_;


 /* POPOVER PUBLIC CLASS DEFINITION
  * =============================== */

  var Popover = function (element, options) {
    this.init('popover', element, options)
  }


  /* NOTE: POPOVER EXTENDS BOOTSTRAP-TOOLTIP.js
     ========================================== */

  Popover.prototype = $.extend({}, $.fn.tooltip.Constructor.prototype, {

    constructor: Popover

  , setContent: function () {
      var $tip = this.tip()
        , title = this.getTitle()
        , content = this.getContent()

      $tip.find('.popover-title')[this.options.html ? 'html' : 'text'](title)
      $tip.find('.popover-content')[this.options.html ? 'html' : 'text'](content)

      $tip.removeClass('fade top bottom left right in')
    }

  , hasContent: function () {
      return this.getTitle() || this.getContent()
    }

  , getContent: function () {
      var content
        , $e = this.$element
        , o = this.options

      content = (typeof o.content == 'function' ? o.content.call($e[0]) :  o.content)
        || $e.attr('data-content')

      return content
    }

  , tip: function () {
      if (!this.$tip) {
        this.$tip = $(this.options.template)
      }
      return this.$tip
    }

  , destroy: function () {
      this.hide().$element.off('.' + this.type).removeData(this.type)
    }

  })


 /* POPOVER PLUGIN DEFINITION
  * ======================= */

  var old = $.fn.popover

  $.fn.popover = function (option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('popover')
        , options = typeof option == 'object' && option
      if (!data) $this.data('popover', (data = new Popover(this, options)))
      if (typeof option == 'string') data[option]()
    })
  }

  $.fn.popover.Constructor = Popover

  $.fn.popover.defaults = $.extend({} , $.fn.tooltip.defaults, {
    placement: 'right'
  , trigger: 'click'
  , content: ''
  , template: '<div class="popover"><div class="arrow"></div><h3 class="popover-title"></h3><div class="popover-content"></div></div>'
  })


 /* POPOVER NO CONFLICT
  * =================== */

  $.fn.popover.noConflict = function () {
    $.fn.popover = old
    return this
  }

}(window.jQuery);
/* =============================================================
 * bootstrap-scrollspy.js v2.3.1
 * http://twitter.github.com/bootstrap/javascript.html#scrollspy
 * =============================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ============================================================== */


!function ($) {

  "use strict"; // jshint ;_;


 /* SCROLLSPY CLASS DEFINITION
  * ========================== */

  function ScrollSpy(element, options) {
    var process = $.proxy(this.process, this)
      , $element = $(element).is('body') ? $(window) : $(element)
      , href
    this.options = $.extend({}, $.fn.scrollspy.defaults, options)
    this.$scrollElement = $element.on('scroll.scroll-spy.data-api', process)
    this.selector = (this.options.target
      || ((href = $(element).attr('href')) && href.replace(/.*(?=#[^\s]+$)/, '')) //strip for ie7
      || '') + ' .nav li > a'
    this.$body = $('body')
    this.refresh()
    this.process()
  }

  ScrollSpy.prototype = {

      constructor: ScrollSpy

    , refresh: function () {
        var self = this
          , $targets

        this.offsets = $([])
        this.targets = $([])

        $targets = this.$body
          .find(this.selector)
          .map(function () {
            var $el = $(this)
              , href = $el.data('target') || $el.attr('href')
              , $href = /^#\w/.test(href) && $(href)
            return ( $href
              && $href.length
              && [[ $href.position().top + (!$.isWindow(self.$scrollElement.get(0)) && self.$scrollElement.scrollTop()), href ]] ) || null
          })
          .sort(function (a, b) { return a[0] - b[0] })
          .each(function () {
            self.offsets.push(this[0])
            self.targets.push(this[1])
          })
      }

    , process: function () {
        var scrollTop = this.$scrollElement.scrollTop() + this.options.offset
          , scrollHeight = this.$scrollElement[0].scrollHeight || this.$body[0].scrollHeight
          , maxScroll = scrollHeight - this.$scrollElement.height()
          , offsets = this.offsets
          , targets = this.targets
          , activeTarget = this.activeTarget
          , i

        if (scrollTop >= maxScroll) {
          return activeTarget != (i = targets.last()[0])
            && this.activate ( i )
        }

        for (i = offsets.length; i--;) {
          activeTarget != targets[i]
            && scrollTop >= offsets[i]
            && (!offsets[i + 1] || scrollTop <= offsets[i + 1])
            && this.activate( targets[i] )
        }
      }

    , activate: function (target) {
        var active
          , selector

        this.activeTarget = target

        $(this.selector)
          .parent('.active')
          .removeClass('active')

        selector = this.selector
          + '[data-target="' + target + '"],'
          + this.selector + '[href="' + target + '"]'

        active = $(selector)
          .parent('li')
          .addClass('active')

        if (active.parent('.dropdown-menu').length)  {
          active = active.closest('li.dropdown').addClass('active')
        }

        active.trigger('activate')
      }

  }


 /* SCROLLSPY PLUGIN DEFINITION
  * =========================== */

  var old = $.fn.scrollspy

  $.fn.scrollspy = function (option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('scrollspy')
        , options = typeof option == 'object' && option
      if (!data) $this.data('scrollspy', (data = new ScrollSpy(this, options)))
      if (typeof option == 'string') data[option]()
    })
  }

  $.fn.scrollspy.Constructor = ScrollSpy

  $.fn.scrollspy.defaults = {
    offset: 10
  }


 /* SCROLLSPY NO CONFLICT
  * ===================== */

  $.fn.scrollspy.noConflict = function () {
    $.fn.scrollspy = old
    return this
  }


 /* SCROLLSPY DATA-API
  * ================== */

  $(window).on('load', function () {
    $('[data-spy="scroll"]').each(function () {
      var $spy = $(this)
      $spy.scrollspy($spy.data())
    })
  })

}(window.jQuery);/* ========================================================
 * bootstrap-tab.js v2.3.1
 * http://twitter.github.com/bootstrap/javascript.html#tabs
 * ========================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ======================================================== */


!function ($) {

  "use strict"; // jshint ;_;


 /* TAB CLASS DEFINITION
  * ==================== */

  var Tab = function (element) {
    this.element = $(element)
  }

  Tab.prototype = {

    constructor: Tab

  , show: function () {
      var $this = this.element
        , $ul = $this.closest('ul:not(.dropdown-menu)')
        , selector = $this.data('target')
        , previous
        , $target
        , e

      if (!selector) {
        selector = $this.attr('href')
        selector = selector && selector.replace(/.*(?=#[^\s]*$)/, '') //strip for ie7
      }

      if ( $this.parent('li').hasClass('active') ) return

      previous = $ul.find('.active:last a')[0]

      e = $.Event('show', {
        relatedTarget: previous
      })

      $this.trigger(e)

      if (e.isDefaultPrevented()) return

      $target = $(selector)

      this.activate($this.parent('li'), $ul)
      this.activate($target, $target.parent(), function () {
        $this.trigger({
          type: 'shown'
        , relatedTarget: previous
        })
      })
    }

  , activate: function ( element, container, callback) {
      var $active = container.find('> .active')
        , transition = callback
            && $.support.transition
            && $active.hasClass('fade')

      function next() {
        $active
          .removeClass('active')
          .find('> .dropdown-menu > .active')
          .removeClass('active')

        element.addClass('active')

        if (transition) {
          element[0].offsetWidth // reflow for transition
          element.addClass('in')
        } else {
          element.removeClass('fade')
        }

        if ( element.parent('.dropdown-menu') ) {
          element.closest('li.dropdown').addClass('active')
        }

        callback && callback()
      }

      transition ?
        $active.one($.support.transition.end, next) :
        next()

      $active.removeClass('in')
    }
  }


 /* TAB PLUGIN DEFINITION
  * ===================== */

  var old = $.fn.tab

  $.fn.tab = function ( option ) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('tab')
      if (!data) $this.data('tab', (data = new Tab(this)))
      if (typeof option == 'string') data[option]()
    })
  }

  $.fn.tab.Constructor = Tab


 /* TAB NO CONFLICT
  * =============== */

  $.fn.tab.noConflict = function () {
    $.fn.tab = old
    return this
  }


 /* TAB DATA-API
  * ============ */

  $(document).on('click.tab.data-api', '[data-toggle="tab"], [data-toggle="pill"]', function (e) {
    e.preventDefault()
    $(this).tab('show')
  })

}(window.jQuery);/* =============================================================
 * bootstrap-typeahead.js v2.3.1
 * http://twitter.github.com/bootstrap/javascript.html#typeahead
 * =============================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ============================================================ */


!function($){

  "use strict"; // jshint ;_;


 /* TYPEAHEAD PUBLIC CLASS DEFINITION
  * ================================= */

  var Typeahead = function (element, options) {
    this.$element = $(element)
    this.options = $.extend({}, $.fn.typeahead.defaults, options)
    this.matcher = this.options.matcher || this.matcher
    this.sorter = this.options.sorter || this.sorter
    this.highlighter = this.options.highlighter || this.highlighter
    this.updater = this.options.updater || this.updater
    this.source = this.options.source
    this.$menu = $(this.options.menu)
    this.shown = false
    this.listen()
  }

  Typeahead.prototype = {

    constructor: Typeahead

  , select: function () {
      var val = this.$menu.find('.active').attr('data-value')
      this.$element
        .val(this.updater(val))
        .change()
      return this.hide()
    }

  , updater: function (item) {
      return item
    }

  , show: function () {
      var pos = $.extend({}, this.$element.position(), {
        height: this.$element[0].offsetHeight
      })

      this.$menu
        .insertAfter(this.$element)
        .css({
          top: pos.top + pos.height
        , left: pos.left
        })
        .show()

      this.shown = true
      return this
    }

  , hide: function () {
      this.$menu.hide()
      this.shown = false
      return this
    }

  , lookup: function (event) {
      var items

      this.query = this.$element.val()

      if (!this.query || this.query.length < this.options.minLength) {
        return this.shown ? this.hide() : this
      }

      items = $.isFunction(this.source) ? this.source(this.query, $.proxy(this.process, this)) : this.source

      return items ? this.process(items) : this
    }

  , process: function (items) {
      var that = this

      items = $.grep(items, function (item) {
        return that.matcher(item)
      })

      items = this.sorter(items)

      if (!items.length) {
        return this.shown ? this.hide() : this
      }

      return this.render(items.slice(0, this.options.items)).show()
    }

  , matcher: function (item) {
      return ~item.toLowerCase().indexOf(this.query.toLowerCase())
    }

  , sorter: function (items) {
      var beginswith = []
        , caseSensitive = []
        , caseInsensitive = []
        , item

      while (item = items.shift()) {
        if (!item.toLowerCase().indexOf(this.query.toLowerCase())) beginswith.push(item)
        else if (~item.indexOf(this.query)) caseSensitive.push(item)
        else caseInsensitive.push(item)
      }

      return beginswith.concat(caseSensitive, caseInsensitive)
    }

  , highlighter: function (item) {
      var query = this.query.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, '\\$&')
      return item.replace(new RegExp('(' + query + ')', 'ig'), function ($1, match) {
        return '<strong>' + match + '</strong>'
      })
    }

  , render: function (items) {
      var that = this

      items = $(items).map(function (i, item) {
        i = $(that.options.item).attr('data-value', item)
        i.find('a').html(that.highlighter(item))
        return i[0]
      })

      items.first().addClass('active')
      this.$menu.html(items)
      return this
    }

  , next: function (event) {
      var active = this.$menu.find('.active').removeClass('active')
        , next = active.next()

      if (!next.length) {
        next = $(this.$menu.find('li')[0])
      }

      next.addClass('active')
    }

  , prev: function (event) {
      var active = this.$menu.find('.active').removeClass('active')
        , prev = active.prev()

      if (!prev.length) {
        prev = this.$menu.find('li').last()
      }

      prev.addClass('active')
    }

  , listen: function () {
      this.$element
        .on('focus',    $.proxy(this.focus, this))
        .on('blur',     $.proxy(this.blur, this))
        .on('keypress', $.proxy(this.keypress, this))
        .on('keyup',    $.proxy(this.keyup, this))

      if (this.eventSupported('keydown')) {
        this.$element.on('keydown', $.proxy(this.keydown, this))
      }

      this.$menu
        .on('click', $.proxy(this.click, this))
        .on('mouseenter', 'li', $.proxy(this.mouseenter, this))
        .on('mouseleave', 'li', $.proxy(this.mouseleave, this))
    }

  , eventSupported: function(eventName) {
      var isSupported = eventName in this.$element
      if (!isSupported) {
        this.$element.setAttribute(eventName, 'return;')
        isSupported = typeof this.$element[eventName] === 'function'
      }
      return isSupported
    }

  , move: function (e) {
      if (!this.shown) return

      switch(e.keyCode) {
        case 9: // tab
        case 13: // enter
        case 27: // escape
          e.preventDefault()
          break

        case 38: // up arrow
          e.preventDefault()
          this.prev()
          break

        case 40: // down arrow
          e.preventDefault()
          this.next()
          break
      }

      e.stopPropagation()
    }

  , keydown: function (e) {
      this.suppressKeyPressRepeat = ~$.inArray(e.keyCode, [40,38,9,13,27])
      this.move(e)
    }

  , keypress: function (e) {
      if (this.suppressKeyPressRepeat) return
      this.move(e)
    }

  , keyup: function (e) {
      switch(e.keyCode) {
        case 40: // down arrow
        case 38: // up arrow
        case 16: // shift
        case 17: // ctrl
        case 18: // alt
          break

        case 9: // tab
        case 13: // enter
          if (!this.shown) return
          this.select()
          break

        case 27: // escape
          if (!this.shown) return
          this.hide()
          break

        default:
          this.lookup()
      }

      e.stopPropagation()
      e.preventDefault()
  }

  , focus: function (e) {
      this.focused = true
    }

  , blur: function (e) {
      this.focused = false
      if (!this.mousedover && this.shown) this.hide()
    }

  , click: function (e) {
      e.stopPropagation()
      e.preventDefault()
      this.select()
      this.$element.focus()
    }

  , mouseenter: function (e) {
      this.mousedover = true
      this.$menu.find('.active').removeClass('active')
      $(e.currentTarget).addClass('active')
    }

  , mouseleave: function (e) {
      this.mousedover = false
      if (!this.focused && this.shown) this.hide()
    }

  }


  /* TYPEAHEAD PLUGIN DEFINITION
   * =========================== */

  var old = $.fn.typeahead

  $.fn.typeahead = function (option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('typeahead')
        , options = typeof option == 'object' && option
      if (!data) $this.data('typeahead', (data = new Typeahead(this, options)))
      if (typeof option == 'string') data[option]()
    })
  }

  $.fn.typeahead.defaults = {
    source: []
  , items: 8
  , menu: '<ul class="typeahead dropdown-menu"></ul>'
  , item: '<li><a href="#"></a></li>'
  , minLength: 1
  }

  $.fn.typeahead.Constructor = Typeahead


 /* TYPEAHEAD NO CONFLICT
  * =================== */

  $.fn.typeahead.noConflict = function () {
    $.fn.typeahead = old
    return this
  }


 /* TYPEAHEAD DATA-API
  * ================== */

  $(document).on('focus.typeahead.data-api', '[data-provide="typeahead"]', function (e) {
    var $this = $(this)
    if ($this.data('typeahead')) return
    $this.typeahead($this.data())
  })

}(window.jQuery);
/* ==========================================================
 * bootstrap-affix.js v2.3.1
 * http://twitter.github.com/bootstrap/javascript.html#affix
 * ==========================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ========================================================== */


!function ($) {

  "use strict"; // jshint ;_;


 /* AFFIX CLASS DEFINITION
  * ====================== */

  var Affix = function (element, options) {
    this.options = $.extend({}, $.fn.affix.defaults, options)
    this.$window = $(window)
      .on('scroll.affix.data-api', $.proxy(this.checkPosition, this))
      .on('click.affix.data-api',  $.proxy(function () { setTimeout($.proxy(this.checkPosition, this), 1) }, this))
    this.$element = $(element)
    this.checkPosition()
  }

  Affix.prototype.checkPosition = function () {
    if (!this.$element.is(':visible')) return

    var scrollHeight = $(document).height()
      , scrollTop = this.$window.scrollTop()
      , position = this.$element.offset()
      , offset = this.options.offset
      , offsetBottom = offset.bottom
      , offsetTop = offset.top
      , reset = 'affix affix-top affix-bottom'
      , affix

    if (typeof offset != 'object') offsetBottom = offsetTop = offset
    if (typeof offsetTop == 'function') offsetTop = offset.top()
    if (typeof offsetBottom == 'function') offsetBottom = offset.bottom()

    affix = this.unpin != null && (scrollTop + this.unpin <= position.top) ?
      false    : offsetBottom != null && (position.top + this.$element.height() >= scrollHeight - offsetBottom) ?
      'bottom' : offsetTop != null && scrollTop <= offsetTop ?
      'top'    : false

    if (this.affixed === affix) return

    this.affixed = affix
    this.unpin = affix == 'bottom' ? position.top - scrollTop : null

    this.$element.removeClass(reset).addClass('affix' + (affix ? '-' + affix : ''))
  }


 /* AFFIX PLUGIN DEFINITION
  * ======================= */

  var old = $.fn.affix

  $.fn.affix = function (option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('affix')
        , options = typeof option == 'object' && option
      if (!data) $this.data('affix', (data = new Affix(this, options)))
      if (typeof option == 'string') data[option]()
    })
  }

  $.fn.affix.Constructor = Affix

  $.fn.affix.defaults = {
    offset: 0
  }


 /* AFFIX NO CONFLICT
  * ================= */

  $.fn.affix.noConflict = function () {
    $.fn.affix = old
    return this
  }


 /* AFFIX DATA-API
  * ============== */

  $(window).on('load', function () {
    $('[data-spy="affix"]').each(function () {
      var $spy = $(this)
        , data = $spy.data()

      data.offset = data.offset || {}

      data.offsetBottom && (data.offset.bottom = data.offsetBottom)
      data.offsetTop && (data.offset.top = data.offsetTop)

      $spy.affix(data)
    })
  })


}(window.jQuery);
  }).call(context, context);

  (function() {
    var jQuery = context.jQuery;
    var Backbone = context.Backbone;
    var $ = jQuery;
    var _ = context._;
    var intermine = context.intermine;

    // Generated by CoffeeScript 1.6.2
/*
 * InterMine Results Tables Library v1.7.1
 * web: http://www.intermine.org
 * repo: git://github.com/alexkalderimis/im-tables.git
 *
 * Copyright 2012, 2013, Alex Kalderimis and InterMine
 * Released under the LGPL license.
 * 
 * Built at Tue Jul 29 2014 10:17:36 GMT+0100 (BST)
*/


(function() {
  var $, bio_formatters, define, end_of_definitions, reqs, require, root, scope, stope, using, x,
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  if (Array.prototype.filter == null) {
    Array.prototype.filter = function(test) {
      var x, _i, _len, _results;

      _results = [];
      for (_i = 0, _len = this.length; _i < _len; _i++) {
        x = this[_i];
        if (test(x)) {
          _results.push(x);
        }
      }
      return _results;
    };
  }

  if (Array.prototype.map == null) {
    Array.prototype.map = function(transform) {
      var x, _i, _len, _results;

      _results = [];
      for (_i = 0, _len = this.length; _i < _len; _i++) {
        x = this[_i];
        _results.push(transform(x));
      }
      return _results;
    };
  }

  if (Array.prototype.indexOf == null) {
    Array.prototype.indexOf = function(elem) {
      var i, x, _i, _len;

      for (i = _i = 0, _len = this.length; _i < _len; i = ++_i) {
        x = this[i];
        if (x === elem) {
          return i;
        }
      }
    };
  }

  $ = jQuery;

  if (Backbone.View.prototype.make == null) {
    Backbone.View.prototype.make = function(elemName, attrs, content) {
      var $el, el, name, value, x, _i, _len;

      el = document.createElement(elemName);
      $el = $(el);
      if (attrs != null) {
        for (name in attrs) {
          value = attrs[name];
          if (name === 'class') {
            $el.addClass(value);
          } else {
            $el.attr(name, value);
          }
        }
      }
      if (content != null) {
        if (_.isArray(content)) {
          for (_i = 0, _len = content.length; _i < _len; _i++) {
            x = content[_i];
            $el.append(x);
          }
        } else {
          $el.append(content);
        }
      }
      return el;
    };
  }

  (function($) {
    var oldToggle;

    oldToggle = $.fn.dropdown.Constructor.prototype.toggle;
    return $.fn.dropdown.Constructor.prototype.toggle = function(e) {
      oldToggle.call(this, e);
      $(this).trigger('toggle', $(this).closest('.dropdown').hasClass('open'));
      return false;
    };
  })(jQuery);

  (function($) {
    var oldPos;

    oldPos = $.fn.tooltip.Constructor.prototype.getPosition;
    return $.fn.tooltip.Constructor.prototype.getPosition = function() {
      var el, height, ret, width, _ref, _ref1;

      ret = oldPos.apply(this, arguments);
      el = this.$element[0];
      if (!ret.width && !ret.height && 'http://www.w3.org/2000/svg' === el.namespaceURI) {
        _ref1 = (_ref = typeof el.getBoundingClientRect === "function" ? el.getBoundingClientRect() : void 0) != null ? _ref : el.getBBox(), width = _ref1.width, height = _ref1.height;
        return $.extend(ret, {
          width: width,
          height: height
        });
      } else {
        return ret;
      }
    };
  })(jQuery);

  root = this;

  if (!root.console) {
    root.console = {
      log: function() {},
      debug: function() {},
      error: function() {}
    };
  }

  stope = function(f) {
    return function(e) {
      e.stopPropagation();
      e.preventDefault();
      return f(e);
    };
  };

  scope = function(path, code, overwrite) {
    var name, ns, part, parts, value, _i, _len;

    if (code == null) {
      code = {};
    }
    if (overwrite == null) {
      overwrite = false;
    }
    parts = path.split(".");
    ns = root;
    for (_i = 0, _len = parts.length; _i < _len; _i++) {
      part = parts[_i];
      ns = ns[part] != null ? ns[part] : (ns[part] = {});
    }
    for (name in code) {
      value = code[name];
      if (overwrite || (ns[name] == null)) {
        ns[name] = value;
      }
    }
    return ns;
  };

  define = function() {};

  using = function() {};

  end_of_definitions = function() {};

  require = function() {};

  (function() {
    var define_pending_modules, defined_modules, pending_modules, sweep_pending;

    pending_modules = {};
    defined_modules = {};
    require = function(name) {
      return defined_modules[name];
    };
    sweep_pending = function() {
      var name, newDefs, obj, pending;

      newDefs = 0;
      for (name in pending_modules) {
        pending = pending_modules[name];
        obj = pending();
        if (obj != null) {
          defined_modules[name] = obj;
          delete pending_modules[name];
          newDefs++;
        }
      }
      return newDefs;
    };
    define_pending_modules = function() {
      var _results;

      _results = [];
      while (sweep_pending()) {
        _results.push(1);
      }
      return _results;
    };
    define = function(name, f) {
      if (name in pending_modules || name in defined_modules) {
        throw new Error("Duplicate definition for " + name);
      }
      pending_modules[name] = f;
      define_pending_modules();
      return null;
    };
    using = function() {
      var f, names, _i;

      names = 2 <= arguments.length ? __slice.call(arguments, 0, _i = arguments.length - 1) : (_i = 0, []), f = arguments[_i++];
      return function(eof) {
        var name, objs, _j, _len, _results;

        if (eof == null) {
          eof = false;
        }
        objs = (function() {
          var _j, _len, _results;

          _results = [];
          for (_j = 0, _len = names.length; _j < _len; _j++) {
            name = names[_j];
            if (name in defined_modules) {
              _results.push(defined_modules[name]);
            }
          }
          return _results;
        })();
        if (objs.length === names.length) {
          return f.apply(null, objs) || true;
        } else if (eof) {
          _results = [];
          for (_j = 0, _len = names.length; _j < _len; _j++) {
            name = names[_j];
            if (!(name in defined_modules)) {
              _results.push(name);
            }
          }
          return _results;
        } else {
          return null;
        }
      };
    };
    return end_of_definitions = function() {
      var err, name, pending, problems;

      pending = (function() {
        var _results;

        _results = [];
        for (name in pending_modules) {
          _results.push(name);
        }
        return _results;
      })();
      if (pending.length) {
        err = "The following modules have unmet dependencies";
        problems = (function() {
          var _i, _len, _results;

          _results = [];
          for (_i = 0, _len = pending.length; _i < _len; _i++) {
            name = pending[_i];
            _results.push("" + name + " needs [" + (pending_modules[name](true)) + "]");
          }
          return _results;
        })();
        throw new Error("" + err + ": " + (problems.join(', ')));
      }
    };
  })();

  scope("intermine", {
    scope: scope
  }, true);

  (function($) {
    var ClosableCollection, ERROR, ItemView, Tab, addStylePrefix, copy, getContainer, getOrganisms, getParameter, getReplacedTest, longestCommonPrefix, modelIsBio, numToString, openWindowWithPost, organisable, pluralise, renderError, requiresAuthentication, uniquelyFlat, walk, _ref, _ref1;

    walk = function(obj, f) {
      var k, v, _results;

      _results = [];
      for (k in obj) {
        if (!__hasProp.call(obj, k)) continue;
        v = obj[k];
        if (_.isObject(v)) {
          _results.push(walk(v, f));
        } else {
          _results.push(f(obj, k, v));
        }
      }
      return _results;
    };
    copy = function(obj) {
      var dup, duped, k, v, x, _i, _len;

      if (!_.isObject(obj)) {
        return obj;
      }
      dup = _.isArray(obj) ? [] : {};
      for (k in obj) {
        if (!__hasProp.call(obj, k)) continue;
        v = obj[k];
        if (_.isArray(v)) {
          duped = [];
          for (_i = 0, _len = v.length; _i < _len; _i++) {
            x = v[_i];
            duped.push(copy(x));
          }
          dup[k] = duped;
        } else if (!_.isObject(v)) {
          dup[k] = v;
        } else {
          dup[k] = copy(v);
        }
      }
      return dup;
    };
    getContainer = function(el) {
      return el.closest('.' + intermine.options.StylePrefix);
    };
    addStylePrefix = function(x) {
      return function(elem) {
        $(elem).addClass(intermine.options.StylePrefix);
        return x;
      };
    };
    pluralise = function(word, count) {
      if (count === 1) {
        return word;
      } else if (word.match(/(s|x|ch)$/)) {
        return word + "es";
      } else if (word.match(/[^aeiou]y$/)) {
        return word.replace(/y$/, "ies");
      } else {
        return word + "s";
      }
    };
    numToString = function(num, sep, every) {
      var chars, groups, i, len, rets;

      rets = [];
      i = 0;
      chars = (num + "").split("");
      len = chars.length;
      groups = _(chars).groupBy(function(c, i) {
        return Math.floor((len - (i + 1)) / every).toFixed();
      });
      while (groups[i]) {
        rets.unshift(groups[i].join(""));
        i++;
      }
      return rets.join(sep);
    };
    getParameter = function(params, name) {
      return _(params).chain().select(function(p) {
        return p.name === name;
      }).pluck('value').first().value();
    };
    modelIsBio = function(model) {
      return !!(model != null ? model.classes['Gene'] : void 0);
    };
    requiresAuthentication = function(q) {
      return _.any(q.constraints, function(c) {
        var _ref;

        return (_ref = c.op) === 'NOT IN' || _ref === 'IN';
      });
    };
    organisable = function(path) {
      return path.getEndClass().name === 'Organism' || (path.getType().fields['organism'] != null);
    };
    uniquelyFlat = _.compose(_.uniq, _.flatten);
    longestCommonPrefix = function(paths) {
      var nextPrefix, part, parts, prefix, prefixesAll, _i, _len;

      parts = paths[0].split(/\./);
      prefix = parts.shift();
      prefixesAll = function(pf) {
        return _.all(paths, function(path) {
          return 0 === path.indexOf(pf);
        });
      };
      for (_i = 0, _len = parts.length; _i < _len; _i++) {
        part = parts[_i];
        if (prefixesAll(nextPrefix = "" + prefix + "." + part)) {
          prefix = nextPrefix;
        }
      }
      return prefix;
    };
    getReplacedTest = function(replacedBy, explicitReplacements) {
      return function(col) {
        var p, replacer;

        p = col.path;
        if (!(intermine.results.shouldFormat(p) || explicitReplacements[p])) {
          return false;
        }
        replacer = replacedBy[p];
        if (p.isAttribute() && p.end.name === 'id') {
          if (replacer == null) {
            replacer = replacedBy[p.getParent()];
          }
        }
        return replacer && (replacer.formatter != null) && col !== replacer;
      };
    };
    getOrganisms = function(q, cb) {
      return $.when(q).then(function(query) {
        var c, def, done, mustBe, n, newView, opath, toRun;

        def = $.Deferred();
        if (cb != null) {
          def.done(cb);
        }
        done = _.compose(def.resolve, uniquelyFlat);
        mustBe = (function() {
          var _i, _len, _ref, _ref1, _results;

          _ref = query.constraints;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            c = _ref[_i];
            if (((_ref1 = c.op) === '=' || _ref1 === 'ONE OF' || _ref1 === 'LOOKUP') && c.path.match(/(o|O)rganism(\.\w+)?$/)) {
              _results.push(c.value || c.values);
            }
          }
          return _results;
        })();
        if (mustBe.length) {
          done(mustBe);
        } else {
          toRun = query.clone();
          newView = (function() {
            var _i, _len, _ref, _results;

            _ref = toRun.getViewNodes();
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              n = _ref[_i];
              if (!(organisable(n))) {
                continue;
              }
              opath = n.getEndClass().name === 'Organism' ? n : n.append('organism');
              _results.push(opath.append('shortName'));
            }
            return _results;
          })();
          if (newView.length) {
            toRun.select(_.uniq(newView, String)).orderBy([]).rows().then(done, function() {
              return done([]);
            });
          } else {
            done([]);
          }
        }
        return def.promise();
      });
    };
    openWindowWithPost = function(uri, name, params) {
      var addInput, form, k, v, w, _fn;

      form = $("<form style=\"display;none\" method=\"POST\" action=\"" + uri + "\" \n     target=\"" + name + (new Date().getTime()) + "\">");
      addInput = function(k, v) {
        var input;

        input = $("<input name=\"" + k + "\" type=\"hidden\">");
        form.append(input);
        return input.val(v);
      };
      _fn = function(k, v) {
        var v_, _i, _len, _results;

        if (_.isArray(v)) {
          _results = [];
          for (_i = 0, _len = v.length; _i < _len; _i++) {
            v_ = v[_i];
            _results.push(addInput(k, v_));
          }
          return _results;
        } else {
          return addInput(k, v);
        }
      };
      for (k in params) {
        v = params[k];
        _fn(k, v);
      }
      form.appendTo('body');
      w = window.open("someNonExistantPathToSomeWhere", name);
      form.submit();
      form.remove();
      return w.close();
    };
    ERROR = _.template("<div class=\"alert alert-error\">\n  <p class=\"apology\">Could not fetch summary</p>\n  <pre><%- message %></pre>\n</div>");
    renderError = function(dest) {
      return function(response, err) {
        var $el, e, message;

        $el = $(dest).empty();
        message = (function() {
          var _ref;

          try {
            return JSON.parse(response.responseText).error;
          } catch (_error) {
            e = _error;
            return (_ref = response != null ? response.responseText : void 0) != null ? _ref : err;
          }
        })();
        return $el.append(ERROR({
          message: message
        }));
      };
    };
    ItemView = (function(_super) {
      __extends(ItemView, _super);

      function ItemView() {
        _ref = ItemView.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      ItemView.prototype.initialize = function() {
        if (this.model.toJSON == null) {
          return this.model = new Backbone.Model(this.model);
        }
      };

      ItemView.prototype.renderError = function(resp) {
        return renderError(this.el)(resp);
      };

      ItemView.prototype.render = function() {
        if (this.template != null) {
          this.$el.html(this.template(this.model.toJSON()));
        }
        this.trigger('rendered');
        return this;
      };

      return ItemView;

    })(Backbone.View);
    ClosableCollection = (function(_super) {
      __extends(ClosableCollection, _super);

      function ClosableCollection() {
        _ref1 = ClosableCollection.__super__.constructor.apply(this, arguments);
        return _ref1;
      }

      ClosableCollection.prototype.close = function() {
        this.each(function(m) {
          m.destroy();
          return m.off();
        });
        this.reset();
        return this;
      };

      return ClosableCollection;

    })(Backbone.Collection);
    Tab = jQuery.fn.tab.noConflict();
    scope('intermine.bootstrap', {
      Tab: Tab
    });
    scope('intermine.views', {
      ItemView: ItemView
    });
    scope('intermine.models', {
      ClosableCollection: ClosableCollection
    });
    return scope("intermine.utils", {
      copy: copy,
      walk: walk,
      getOrganisms: getOrganisms,
      requiresAuthentication: requiresAuthentication,
      modelIsBio: modelIsBio,
      renderError: renderError,
      getParameter: getParameter,
      numToString: numToString,
      pluralise: pluralise,
      addStylePrefix: addStylePrefix,
      getContainer: getContainer,
      openWindowWithPost: openWindowWithPost,
      longestCommonPrefix: longestCommonPrefix,
      getReplacedTest: getReplacedTest
    });
  })(jQuery);

  scope("intermine.options", {
    INITIAL_SUMMARY_ROWS: 1000,
    NUM_SEPARATOR: ',',
    NUM_CHUNK_SIZE: 3,
    MAX_PIE_SLICES: 15,
    DefaultCodeLang: 'py',
    ListFreshness: 250,
    MaxSuggestions: 1000,
    ListCategorisers: ['organism.name', 'department.company.name'],
    PieColors: 'category20',
    CellPreviewTrigger: 'hover',
    IndicateOffHostLinks: true,
    ExternalLinkIcons: {
      "http://some.host.somewhere": "http://some.host.somewhere/logo.png"
    },
    StylePrefix: 'intermine',
    GalaxyMain: "http://main.g2.bx.psu.edu",
    GalaxyCurrent: null,
    GalaxyTool: 'flymine',
    GenomeSpaceUpload: "https://gsui.genomespace.org/jsui/upload/loadUrlToGenomespace.html",
    ExternalExportDestinations: {
      Galaxy: true,
      Genomespace: true
    },
    ShowId: false,
    TableWidgets: ['Pagination', 'PageSizer', 'TableSummary', 'ManagementTools', 'ScrollBar'],
    CellCutoff: 100,
    Style: {
      icons: 'glyphicons'
    },
    CDN: {
      server: 'http://cdn.intermine.org',
      tests: {
        fontawesome: /font-awesome/,
        glyphicons: /bootstrap-icons/
      },
      resources: {
        prettify: ['/js/google-code-prettify/latest/prettify.js', '/js/google-code-prettify/latest/prettify.css'],
        d3: '/js/d3/3.0.6/d3.v3.min.js',
        glyphicons: "/css/bootstrap/2.3.2/css/bootstrap-icons.css",
        fontawesome: "/css/font-awesome/3.0.2/css/font-awesome.css",
        filesaver: '/js/filesaver.js/FileSaver.min.js'
      }
    },
    D3: {
      Transition: {
        Easing: 'elastic',
        Duration: 750
      }
    },
    brand: {
      "http://www.flymine.org": "FlyMine",
      "http://preview.flymine.org": "FlyMine-Preview",
      "http://www.mousemine.org": "MouseMine (MGI)"
    },
    preview: {
      count: {
        'http://localhost/intermine-test/service/': {
          Department: ['employees'],
          Company: [
            'departments', {
              label: 'employees',
              query: {
                select: '*',
                from: 'Employee',
                where: {
                  'department.company.id': '{{ID}}'
                }
              }
            }
          ]
        },
        'http://preview.flymine.org/preview/service/': {
          Organism: [
            {
              label: 'Genes',
              query: {
                select: '*',
                from: 'Gene',
                where: {
                  'organism.id': '{{ID}}'
                }
              }
            }
          ],
          Gene: ['pathways', 'proteins', 'publications', 'transcripts', 'homologues']
        }
      }
    }
  });

  (function() {
    return scope('intermine', {
      setOptions: function(opts, ns) {
        if (ns == null) {
          ns = '';
        }
        ns = ns === '' || /^\./.test(ns) ? 'intermine.options' + ns : ns;
        return scope(ns, opts, true);
      }
    });
  })();

  (function() {
    var asArray, hasStyle, loader, parallel;

    asArray = function(things) {
      return [].slice.call(things);
    };
    hasStyle = function(pattern) {
      var links;

      if (pattern == null) {
        return false;
      }
      links = asArray(document.querySelectorAll('link[rel="stylesheet"]'));
      return _.any(links, function(link) {
        return pattern.test(link.href);
      });
    };
    parallel = function(promises) {
      return jQuery.when.apply(jQuery, promises);
    };
    loader = function(server) {
      return function(resource, resourceRegex) {
        var fetch, link, resolution;

        resolution = jQuery.Deferred(function() {
          return _.delay(this.resolve, 50, true);
        });
        if (/\.css$/.test(resource)) {
          if (hasStyle(resourceRegex)) {
            return resolution;
          }
          link = jQuery('<link type="text/css" rel="stylesheet">');
          link.appendTo('head').attr({
            href: server + resource
          });
          return resolution;
        } else {
          fetch = jQuery.ajax({
            url: server + resource,
            cache: true,
            dataType: 'script'
          });
          return fetch.then(function() {
            return resolution;
          });
        }
      };
    };
    return scope('intermine.cdn', {
      load: function(ident) {
        var conf, load, resources, server, test, tests, _ref;

        _ref = intermine.options.CDN, server = _ref.server, tests = _ref.tests, resources = _ref.resources;
        conf = resources[ident];
        test = tests[ident];
        load = loader(server);
        if (!conf) {
          return jQuery.Deferred(function() {
            return this.reject("No resource is configured for " + ident);
          });
        } else if (_.isArray(conf)) {
          return parallel(conf.map(function(c) {
            return load(c);
          }));
        } else {
          return load(conf, test);
        }
      }
    });
  })();

  scope('intermine.css', {
    unsorted: "icon-resize-vertical",
    sortedASC: "icon-arrow-up",
    sortedDESC: "icon-arrow-down",
    headerIcon: "icon",
    headerIconRemove: "icon-remove",
    headerIconHide: "icon-minus",
    headerIconReveal: 'icon-fullscreen'
  });

  scope("intermine.icons", {
    Yes: "icon-star",
    No: "icon-star-empty",
    Table: 'icon-list',
    Script: "icon-cog",
    Export: "icon-download-alt",
    Remove: "icon-minus-sign",
    Check: "icon-ok",
    UnCheck: "icon-none",
    CheckUnCheck: "icon-ok icon-none",
    Add: "icon-plus-sign",
    Move: "icon-move",
    More: "icon-plus-sign",
    Filter: "icon-filter",
    Summary: "icon-eye-open",
    Undo: "icon-refresh",
    Columns: "icon-wrench",
    Collapsed: "icon-chevron-right",
    Expanded: "icon-chevron-down",
    MoveDown: "icon-chevron-down",
    MoveUp: "icon-chevron-up",
    Toggle: "icon-retweet",
    ExpandCollapse: "icon-angle-right icon-angle-down",
    Help: "icon-question-sign",
    ReverseRef: 'icon-retweet',
    Edit: 'icon-edit',
    Download: 'icon-file',
    ClipBoard: 'icon-paper-clip',
    Composed: 'icon-tags',
    tsv: 'icon-list',
    csv: 'icon-list',
    xml: 'icon-xml',
    json: 'icon-json'
  });

  scope("intermine.messages.actions", {
    ListNameDuplicate: 'List names must be unique. This name is already taken',
    ListNameEmpty: 'Lists must have names. Please enter one',
    ListNameIllegal: _.template("Some characters are not allowed in list names. This name contains the following\nillegal characters: <%- illegals.join(', ') %>. Please remove them."),
    ExportTitle: "Download Results",
    ConfigureExport: "Configure Export",
    GetData: "Download Data",
    ExportHelp: "Download file containing results to your computer",
    ExportButton: "Download",
    ExportFormat: "Format",
    Cancel: "Cancel",
    Clear: "Clear",
    Export: "Download",
    'download-file': 'Download File',
    Galaxy: 'Send to Galaxy',
    Genomespace: 'Upload to Genomespace',
    'Destdownload-file': 'File',
    DestGalaxy: 'Galaxy',
    DestGenomespace: 'Genomespace',
    ExportAlt: "Send Data Somewhere Else",
    ExportLong: "<span class=\"hidden-tablet\">Download</span>\nFile\n<span class=\"im-only-widescreen\">to your Computer</span>",
    SendToGalaxy: "<span class=\"hidden-tablet\">Send to</span>\nGalaxy\n<span class=\"im-only-widescreen\">for analysis</span>",
    SendToGenomespace: "<span class=\"hidden-tablet\">Upload to</span>\n<span class=\"im-only-widescreen\">your</span>\nGenomespace\n<span class=\"im-only-widescreen\">account</span>",
    MyGalaxy: "Send to your Galaxy",
    ForgetGalaxy: "Clear this galaxy URL",
    GalaxyHelp: "Start a file upload job within Galaxy",
    GalaxyURILabel: "Galaxy Location:",
    GalaxyAlt: "Send to a specific Galaxy",
    SaveGalaxyURL: "Make this my default Galaxy",
    WhatIsGalaxy: "What is Galaxy?",
    WhatIsGalaxyURL: "http://wiki.g2.bx.psu.edu/",
    GalaxyAuthExplanation: "If you have already logged into Galaxy with this browser, then the data\nwill be sent into your active account. Otherwise it will appear in a \ntemporary anonymous account.",
    CopyToClipBoard: 'Copy to clipboard: <CTL>+C, <ENTER>',
    IsPrivateData: "This link provides access to data stored in your private lists. In order to do so\nit uses the API access token provided on initialisation. If this is your permanent\nAPI token you should be as careful of this link as you would of the data is provides\naccess to. If this is just a 24 hour access token, then you will need to replace it\nonce it becomes invalid.",
    LongURI: "The normal URI for this query (which includes the full query XML in the \nparameters) is too long for a GET request. The URI you can see here uses a\nquery-id, which has a limited validity. You should not store this URI for long\nterm use.",
    SendToOtherGalaxy: "Send",
    AllRows: "Whole Result Set",
    SomeRows: "Specific Range",
    WhichRows: "Rows to Export",
    RowsHelp: "Export all rows, or define a range of rows to export.",
    AllColumns: "All Current Columns",
    SomeColumns: "Choose Columns",
    CompressResults: "Compress results",
    NoCompression: "No compression",
    GZIPCompression: "GZIP",
    ZIPCompression: "ZIP",
    Copy: 'copy to clip-board',
    ResultsPermaLink: "Perma-link to results",
    ResultsPermaLinkText: "Results URI",
    QueryXML: 'Query XML',
    ResultsPermaLinkTitle: "Get a permanent URL for these results, suitable for your own use",
    ResultsPermaLinkShareTitle: "Get a permanent URL for these results, suitable for sharing with others",
    ColumnsHelp: "Export all columns, or choose specific columns to export.",
    WhichColumns: "Columns to Export",
    ResetColumns: "Reset Columns.",
    FirstRow: "From",
    LastRow: "To",
    SpreadsheetOptions: "Spreadsheet Options",
    ColumnHeaders: "Include Column Headers",
    PossibleColumns: "You can add any attribute from these nodes without changing your results:",
    ExportedColumns: "Exported Columns (drag to reorder)",
    ChangeColumns: "You may add any of the columns in the right hand box by clicking on the\nplus sign. You may remove unwanted columns by clicking on the minus signs\nin the left hand box. Note that while adding these columns will not alter your query,\nif you remove all the attributes from an item, then you <b>may change</b> the results\nyou receive.",
    OuterJoinWarning: "This query has outer-joined collections. This means that the number of rows in \nthe table is likely to be different from the number of rows in the exported results.\n<b>You are strongly discouraged from specifying specific ranges for export</b>. If\nyou do specify a certain range, please check that you did in fact get all the \nresults you wanted.",
    IncludedFeatures: "Exportable parts of this Query - <strong>choose at least one</strong>:",
    FastaFeatures: "Features with Sequences in this Query - <strong>select one</strong>:",
    FastaOptions: 'FASTA Specific Options',
    FastaExtension: "Extension (eg: 100/100bp/5kbp/0.5mbp):",
    ExtraAttributes: "Columns to include as extra attributes on each exported record:",
    NoSuitableColumns: "There are no columns of a suitable type for this format.",
    BEDOptions: "BED Specific Options",
    Gff3Options: 'GFF3 Specific Options',
    ChrPrefix: "Prefix \"chr\" to the chromosome identifier as per UCSC convention (eg: chr2)",
    ConfigureExportHelp: 'Configure the export options in these categories'
  });

  scope('intermine.messages.cell', {
    RelatedItems: "Related item counts:"
  });

  scope('intermine.messages.columns', {
    FindColumnToAdd: 'Add a new Column',
    OrderVerb: 'Add / Remove / Re-Arrange',
    OrderTitle: 'Columns',
    SortVerb: 'Configure',
    SortTitle: 'Sort-Order',
    OnlyColsInView: 'Only show columns in the table:',
    SortingHelpTitle: 'What Columns Can I Sort by?',
    SortingHelpContent: "A table can be sorted by any of the attributes of the objects\nwhich are in the output columns or constrained by a filter, so\nlong as they haven't been declared to be optional parts of the\nquery. So if you are displaying <span class=\"label path\">Gene > Name</span>\nand <span class=\"label path\">Gene > Exons > Symbol</span>, and also\n<span class=\"label path\">Gene > Proteins > Name</span> if the gene\nhas any proteins (ie. the proteins part of the query is optional), then\nyou can sort by any of the attributes attached to\n<span class=\"label path available\">Gene</span>\nor <span class=\"label path available\">Gene > Exons</span>,\nwhether or not you have selected them for output, but you could not sort by\nany of the attributes of <span class=\"label path available\">Gene > Proteins</span>,\nsince these items may not be present in the results."
  });

  scope('intermine.messages.facets', {
    DownloadData: 'Save',
    DownloadFormat: 'As',
    More: 'Load more items',
    Include: 'Restrict table to matching rows',
    Exclude: 'Exclude matching rows from table',
    Reset: 'Reset selection',
    ToggleSelection: 'Toggle selection'
  });

  scope('intermine.messages.constraints', {
    BrowseForColumn: 'Browse for Column',
    AddANewFilter: 'Add a new filter',
    Filter: 'Filter'
  });

  (function() {
    var Attribute, CONSTRAINT_ADDER_HTML, ConstraintAdder, PATH_HIGHLIGHTER, PATH_LEN_SORTER, PATH_MATCHER, PathChooser, Reference, ReverseReference, RootClass, pathLen, pos, _ref, _ref1, _ref2, _ref3, _ref4, _ref5;

    pos = function(substr) {
      return _.memoize(function(str) {
        return str.toLowerCase().indexOf(substr);
      });
    };
    pathLen = _.memoize(function(str) {
      return str.split(".").length;
    });
    CONSTRAINT_ADDER_HTML = "<input type=\"text\" placeholder=\"" + intermine.messages.constraints.AddANewFilter + "\"\n        class=\"im-constraint-adder span9\">\n<button disabled class=\"btn btn-primary span2\" type=\"submit\">\n  " + intermine.messages.constraints.Filter + "\n</button>";
    PATH_LEN_SORTER = function(items) {
      var getPos;

      getPos = pos(this.query.toLowerCase());
      items.sort(function(a, b) {
        if (a === b) {
          return 0;
        } else {
          return getPos(a) - getPos(b) || pathLen(a) - pathLen(b) || (a < b ? -1 : 1);
        }
      });
      return items;
    };
    PATH_MATCHER = function(item) {
      var lci, term, terms;

      lci = item.toLowerCase();
      terms = (function() {
        var _i, _len, _ref, _results;

        _ref = this.query.toLowerCase().split(/\s+/);
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          term = _ref[_i];
          if (term) {
            _results.push(term);
          }
        }
        return _results;
      }).call(this);
      return item && _.all(terms, function(t) {
        return lci.match(t);
      });
    };
    PATH_HIGHLIGHTER = function(item) {
      var term, terms, _i, _len;

      terms = this.query.toLowerCase().split(/\s+/);
      for (_i = 0, _len = terms.length; _i < _len; _i++) {
        term = terms[_i];
        if (term) {
          item = item.replace(new RegExp(term, "gi"), function(match) {
            return "<>" + match + "</>";
          });
        }
      }
      return item.replace(/>/g, "strong>");
    };
    Attribute = (function(_super) {
      __extends(Attribute, _super);

      function Attribute() {
        _ref = Attribute.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      Attribute.prototype.tagName = 'li';

      Attribute.prototype.events = {
        'click a': 'handleClick'
      };

      Attribute.prototype.handleClick = function(e) {
        var isNewChoice;

        e.stopPropagation();
        e.preventDefault();
        if (!this.getDisabled(this.path)) {
          isNewChoice = !this.$el.is('.active');
          return this.evts.trigger('chosen', this.path, isNewChoice);
        }
      };

      Attribute.prototype.initialize = function(query, path, depth, evts, getDisabled, multiSelect) {
        var _this = this;

        this.query = query;
        this.path = path;
        this.depth = depth;
        this.evts = evts;
        this.getDisabled = getDisabled;
        this.multiSelect = multiSelect;
        this.listenTo(this.evts, 'remove', function() {
          return _this.remove();
        });
        this.listenTo(this.evts, 'chosen', function(p, isNewChoice) {
          if (p.toString() === _this.path.toString()) {
            return _this.$el.toggleClass('active', isNewChoice);
          } else {
            if (!_this.multiSelect) {
              return _this.$el.removeClass('active');
            }
          }
        });
        return this.listenTo(this.evts, 'filter:paths', function(terms) {
          var lastMatch, matches, t, _i, _len;

          terms = (function() {
            var _i, _len, _results;

            _results = [];
            for (_i = 0, _len = terms.length; _i < _len; _i++) {
              t = terms[_i];
              if (t) {
                _results.push(new RegExp(t, 'i'));
              }
            }
            return _results;
          })();
          if (terms.length) {
            matches = 0;
            lastMatch = null;
            for (_i = 0, _len = terms.length; _i < _len; _i++) {
              t = terms[_i];
              if (t.test(_this.path.toString()) || t.test(_this.displayName)) {
                matches += 1;
                lastMatch = t;
              }
            }
            return _this.matches(matches, terms, lastMatch);
          } else {
            return _this.$el.show();
          }
        });
      };

      Attribute.prototype.remove = function() {
        var prop, _i, _len, _ref1;

        _ref1 = ['query', 'path', 'depth', 'evts', 'getDisabled', 'multiSelect'];
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          prop = _ref1[_i];
          delete this[prop];
        }
        return Attribute.__super__.remove.apply(this, arguments);
      };

      Attribute.prototype.template = _.template("<a href=\"#\" title=\"<%- path %> (<%- type %>)\"><span><%- name %></span></a>");

      Attribute.prototype.matches = function(matches, terms) {
        var _this = this;

        if (matches === terms.length) {
          this.evts.trigger('matched', this.path.toString());
          this.path.getDisplayName(function(name) {
            var hl, matchesOnPath, term, _i, _len;

            hl = _this.depth > 0 ? name.replace(/^.*>\s*/, '') : name;
            for (_i = 0, _len = terms.length; _i < _len; _i++) {
              term = terms[_i];
              hl = hl.replace(term, function(match) {
                return "<strong>" + match + "</strong>";
              });
            }
            matchesOnPath = _.any(terms, function(t) {
              return !!_this.path.end.name.match(t);
            });
            return _this.$('a span').html(hl.match(/strong/) || !matchesOnPath ? hl : "<strong>" + hl + "</strong>");
          });
        }
        return this.$el.toggle(!!(matches === terms.length));
      };

      Attribute.prototype.rendered = false;

      Attribute.prototype.render = function() {
        var disabled,
          _this = this;

        disabled = this.getDisabled(this.path);
        if (disabled) {
          this.$el.addClass('disabled');
        }
        this.rendered = true;
        this.path.getDisplayName().then(function(name) {
          var a;

          _this.displayName = name;
          name = name.replace(/^.*\s*>/, '');
          a = $(_this.template(_.extend({}, _this, {
            name: name,
            path: _this.path,
            type: _this.path.getType()
          })));
          a.appendTo(_this.el);
          return _this.addedLiContent(a);
        });
        return this;
      };

      Attribute.prototype.addedLiContent = function(a) {
        if (intermine.options.ShowId) {
          return a.tooltip({
            placement: 'bottom'
          }).appendTo(this.el);
        } else {
          return a.attr({
            title: ""
          });
        }
      };

      return Attribute;

    })(Backbone.View);
    RootClass = (function(_super) {
      __extends(RootClass, _super);

      function RootClass() {
        _ref1 = RootClass.__super__.constructor.apply(this, arguments);
        return _ref1;
      }

      RootClass.prototype.className = 'im-rootclass';

      RootClass.prototype.initialize = function(query, cd, evts, multiSelect) {
        this.query = query;
        this.cd = cd;
        this.evts = evts;
        this.multiSelect = multiSelect;
        return RootClass.__super__.initialize.call(this, this.query, this.query.getPathInfo(this.cd.name), 0, this.evts, (function() {
          return false;
        }), this.multiSelect);
      };

      RootClass.prototype.template = _.template("<a href=\"#\">\n  <i class=\"icon-stop\"></i>\n  <span><%- name %></span>\n</a>");

      return RootClass;

    })(Attribute);
    Reference = (function(_super) {
      __extends(Reference, _super);

      function Reference() {
        this.collapse = __bind(this.collapse, this);        _ref2 = Reference.__super__.constructor.apply(this, arguments);
        return _ref2;
      }

      Reference.prototype.initialize = function(query, path, depth, evts, getDisabled, multiSelect, isSelectable) {
        var _this = this;

        this.query = query;
        this.path = path;
        this.depth = depth;
        this.evts = evts;
        this.getDisabled = getDisabled;
        this.multiSelect = multiSelect;
        this.isSelectable = isSelectable;
        Reference.__super__.initialize.call(this, this.query, this.path, this.depth, this.evts, this.getDisabled, this.multiSelect);
        this.evts.on('filter:paths', function(terms) {
          return _this.$el.hide();
        });
        this.evts.on('matched', function(path) {
          if (path.match(_this.path.toString())) {
            _this.$el.show();
            if (!_this.$el.is('.open')) {
              return _this.openSubFinder();
            }
          }
        });
        return this.evts.on('collapse:tree-branches', this.collapse);
      };

      Reference.prototype.collapse = function() {
        var _ref3;

        if ((_ref3 = this.subfinder) != null) {
          _ref3.remove();
        }
        this.$el.removeClass('open');
        return this.$('i.im-has-fields').removeClass(intermine.icons.Expanded).addClass(intermine.icons.Collapsed);
      };

      Reference.prototype.remove = function() {
        this.collapse();
        return Reference.__super__.remove.call(this);
      };

      Reference.prototype.openSubFinder = function() {
        this.$el.addClass('open');
        this.$('i.im-has-fields').addClass(intermine.icons.Expanded).removeClass(intermine.icons.Collapsed);
        this.subfinder = new PathChooser(this.query, this.path, this.depth + 1, this.evts, this.getDisabled, this.isSelectable, this.multiSelect);
        this.subfinder.allowRevRefs(this.allowRevRefs);
        return this.$el.append(this.subfinder.render().el);
      };

      Reference.prototype.template = _.template("<a href=\"#\">\n  <i class=\"" + intermine.icons.Collapsed + " im-has-fields\"></i>\n  <% if (isLoop) { %>\n    <i class=\"" + intermine.icons.ReverseRef + "\"></i>\n  <% } %>\n  <span><%- name %></span>\n</a>");

      Reference.prototype.iconClasses = intermine.icons.ExpandCollapse;

      Reference.prototype.toggleFields = function() {
        if (this.$el.is('.open')) {
          return this.collapse();
        } else {
          return this.openSubFinder();
        }
      };

      Reference.prototype.handleClick = function(e) {
        e.preventDefault();
        e.stopPropagation();
        if ($(e.target).is('.im-has-fields') || (!this.isSelectable)) {
          return this.toggleFields();
        } else {
          return Reference.__super__.handleClick.call(this, e);
        }
      };

      Reference.prototype.addedLiContent = function(a) {
        var prefix;

        prefix = new RegExp("^" + this.path + "\\.");
        if (_.any(this.query.views, function(v) {
          return v.match(prefix);
        })) {
          this.toggleFields();
          return this.$el.addClass('im-in-view');
        }
      };

      return Reference;

    })(Attribute);
    ReverseReference = (function(_super) {
      __extends(ReverseReference, _super);

      function ReverseReference() {
        _ref3 = ReverseReference.__super__.constructor.apply(this, arguments);
        return _ref3;
      }

      ReverseReference.prototype.template = _.template("<a href=\"#\">\n  <i class=\"" + intermine.icons.ReverseRef + " im-has-fields\"></i>\n  <span><%- name %></span>\n</a>");

      ReverseReference.prototype.toggleFields = function() {};

      ReverseReference.prototype.handleClick = function(e) {
        e.preventDefault();
        e.stopPropagation();
        return this.$el.tooltip('hide');
      };

      ReverseReference.prototype.render = function() {
        ReverseReference.__super__.render.call(this);
        this.$el.attr({
          title: "Refers back to " + (this.path.getParent().getParent())
        }).tooltip();
        return this;
      };

      return ReverseReference;

    })(Reference);
    PathChooser = (function(_super) {
      __extends(PathChooser, _super);

      function PathChooser() {
        this.allowRevRefs = __bind(this.allowRevRefs, this);
        this.searchFor = __bind(this.searchFor, this);        _ref4 = PathChooser.__super__.constructor.apply(this, arguments);
        return _ref4;
      }

      PathChooser.prototype.tagName = 'ul';

      PathChooser.prototype.dropDownClasses = '';

      PathChooser.prototype.searchFor = function(terms) {
        var m, matches, p, _i, _len, _results;

        this.evts.trigger('filter:paths', terms);
        matches = (function() {
          var _i, _len, _ref5, _results,
            _this = this;

          _ref5 = this.query.getPossiblePaths(3);
          _results = [];
          for (_i = 0, _len = _ref5.length; _i < _len; _i++) {
            p = _ref5[_i];
            if (_.all(terms, function(t) {
              return p.match(new RegExp(t, 'i'));
            })) {
              _results.push(p);
            }
          }
          return _results;
        }).call(this);
        _results = [];
        for (_i = 0, _len = matches.length; _i < _len; _i++) {
          m = matches[_i];
          _results.push(this.evts.trigger('matched', m, terms));
        }
        return _results;
      };

      PathChooser.prototype.initialize = function(query, path, depth, events, getDisabled, canSelectRefs, multiSelect) {
        var attr, cd, coll, name, ref, toPath,
          _this = this;

        this.query = query;
        this.path = path;
        this.depth = depth;
        this.getDisabled = getDisabled;
        this.canSelectRefs = canSelectRefs;
        this.multiSelect = multiSelect;
        this.state = new Backbone.Model({
          allowRevRefs: false
        });
        this.leaves = [];
        this.evts = this.depth === 0 ? _.extend({}, Backbone.Events) : events;
        cd = this.path.getEndClass();
        toPath = function(f) {
          return _this.path.append(f);
        };
        this.attributes = (function() {
          var _ref5, _results;

          _ref5 = cd.attributes;
          _results = [];
          for (name in _ref5) {
            attr = _ref5[name];
            _results.push(toPath(attr));
          }
          return _results;
        })();
        this.references = (function() {
          var _ref5, _results;

          _ref5 = cd.references;
          _results = [];
          for (name in _ref5) {
            ref = _ref5[name];
            _results.push(toPath(ref));
          }
          return _results;
        })();
        this.collections = (function() {
          var _ref5, _results;

          _ref5 = cd.collections;
          _results = [];
          for (name in _ref5) {
            coll = _ref5[name];
            _results.push(toPath(coll));
          }
          return _results;
        })();
        if (this.depth === 0) {
          this.evts.on('chosen', events);
        }
        this.on('collapse:tree-branches', function() {
          return _this.evts.trigger('collapse:tree-branches');
        });
        return this.state.on('change:allowRevRefs', function() {
          if (_this.rendered) {
            return _this.render();
          }
        });
      };

      PathChooser.prototype.allowRevRefs = function(allowed) {
        return this.state.set({
          allowRevRefs: allowed
        });
      };

      PathChooser.prototype.remove = function() {
        if (this.depth === 0) {
          this.evts.off();
        }
        this.state.off();
        return PathChooser.__super__.remove.call(this);
      };

      PathChooser.prototype.reset = function() {
        var leaf, _ref5, _results;

        if ((_ref5 = this.$root) != null) {
          _ref5.remove();
        }
        _results = [];
        while (leaf = this.leaves.pop()) {
          _results.push(leaf.remove());
        }
        return _results;
      };

      PathChooser.prototype.render = function() {
        var allowingRevRefs, apath, attr, cd, isLoop, leaf, ref, rpath, _i, _j, _k, _len, _len1, _len2, _ref5, _ref6, _ref7;

        this.reset();
        this.rendered = true;
        cd = this.path.getEndClass();
        if (this.depth === 0 && this.canSelectRefs) {
          this.$root = new RootClass(this.query, cd, this.evts, this.multiSelect);
          this.$el.append(this.$root.render().el);
        }
        _ref5 = this.attributes;
        for (_i = 0, _len = _ref5.length; _i < _len; _i++) {
          apath = _ref5[_i];
          if (intermine.options.ShowId || apath.end.name !== 'id') {
            attr = new Attribute(this.query, apath, this.depth, this.evts, this.getDisabled, this.multiSelect);
            this.leaves.push(attr);
          }
        }
        _ref6 = this.references.concat(this.collections);
        for (_j = 0, _len1 = _ref6.length; _j < _len1; _j++) {
          rpath = _ref6[_j];
          isLoop = false;
          if ((rpath.end.reverseReference != null) && this.path.isReference()) {
            if (this.path.getParent().isa(rpath.end.referencedType)) {
              if (this.path.end.name === rpath.end.reverseReference) {
                isLoop = true;
              }
            }
          }
          allowingRevRefs = this.state.get('allowRevRefs');
          ref = isLoop && !allowingRevRefs ? new ReverseReference(this.query, rpath, this.depth, this.evts, (function() {
            return true;
          }), this.multiSelect, this.canSelectRefs) : new Reference(this.query, rpath, this.depth, this.evts, this.getDisabled, this.multiSelect, this.canSelectRefs);
          ref.allowRevRefs = allowingRevRefs;
          ref.isLoop = isLoop;
          this.leaves.push(ref);
        }
        _ref7 = this.leaves;
        for (_k = 0, _len2 = _ref7.length; _k < _len2; _k++) {
          leaf = _ref7[_k];
          this.$el.append(leaf.render().el);
        }
        if (this.depth === 0) {
          this.$el.addClass(this.dropDownClasses);
        }
        this.$el.show();
        return this;
      };

      return PathChooser;

    })(Backbone.View);
    ConstraintAdder = (function(_super) {
      var VALUE_OPS;

      __extends(ConstraintAdder, _super);

      function ConstraintAdder() {
        this.showTree = __bind(this.showTree, this);
        this.handleChoice = __bind(this.handleChoice, this);
        this.handleSubmission = __bind(this.handleSubmission, this);        _ref5 = ConstraintAdder.__super__.constructor.apply(this, arguments);
        return _ref5;
      }

      ConstraintAdder.prototype.tagName = "form";

      ConstraintAdder.prototype.className = "form im-constraint-adder row-fluid im-constraint";

      ConstraintAdder.prototype.initialize = function(query) {
        this.query = query;
      };

      ConstraintAdder.prototype.events = function() {
        return {
          'submit': 'handleSubmission',
          'click .im-collapser': 'collapseBranches',
          'change .im-allow-rev-ref': 'allowReverseRefs'
        };
      };

      ConstraintAdder.prototype.collapseBranches = function() {
        var _ref6;

        return (_ref6 = this.$pathfinder) != null ? _ref6.trigger('collapse:tree-branches') : void 0;
      };

      ConstraintAdder.prototype.allowReverseRefs = function() {
        var _ref6;

        return (_ref6 = this.$pathfinder) != null ? _ref6.allowRevRefs(this.$('.im-allow-rev-ref').is(':checked')) : void 0;
      };

      ConstraintAdder.prototype.handleClick = function(e) {
        e.preventDefault();
        if (!$(e.target).is('button')) {
          e.stopPropagation();
        }
        if ($(e.target).is('button.btn-primary')) {
          return this.handleSubmission(e);
        }
      };

      ConstraintAdder.prototype.handleSubmission = function(e) {
        var con, _ref6;

        e.preventDefault();
        e.stopPropagation();
        if (this.chosen != null) {
          con = {
            path: this.chosen.toString()
          };
          this.newCon = new intermine.query.NewConstraint(this.query, con);
          this.newCon.render().$el.insertAfter(this.el);
          this.$('.btn-primary').fadeOut('fast');
          if ((_ref6 = this.$pathfinder) != null) {
            _ref6.remove();
          }
          this.$pathfinder = null;
          return this.query.trigger('editing-constraint');
        } else {
          return console.log("Nothing chosen");
        }
      };

      ConstraintAdder.prototype.handleChoice = function(path, isNewChoice) {
        if (isNewChoice) {
          this.chosen = path;
          return this.$('.btn-primary').fadeIn('slow');
        } else {
          this.chosen = null;
          return this.$('.btn-primary').fadeOut('slow');
        }
      };

      ConstraintAdder.prototype.isDisabled = function(path) {
        return false;
      };

      ConstraintAdder.prototype.getTreeRoot = function() {
        return this.query.getPathInfo(this.query.root);
      };

      ConstraintAdder.prototype.refsOK = true;

      ConstraintAdder.prototype.multiSelect = false;

      ConstraintAdder.prototype.reset = function() {
        var _ref6;

        this.trigger('resetting:tree');
        if ((_ref6 = this.$pathfinder) != null) {
          _ref6.remove();
        }
        this.$pathfinder = null;
        return this.$('.im-tree-option').addClass('hidden');
      };

      ConstraintAdder.prototype.showTree = function(e) {
        var pathFinder, treeRoot;

        this.$('.im-tree-option').removeClass('hidden');
        this.trigger('showing:tree');
        if (this.$pathfinder != null) {
          return this.reset();
        } else {
          treeRoot = this.getTreeRoot();
          pathFinder = new PathChooser(this.query, treeRoot, 0, this.handleChoice, this.isDisabled, this.refsOK, this.multiSelect);
          pathFinder.render();
          this.$el.append(pathFinder.el);
          pathFinder.$el.show().css({
            top: this.$el.height()
          });
          return this.$pathfinder = pathFinder;
        }
      };

      VALUE_OPS = intermine.Query.ATTRIBUTE_VALUE_OPS.concat(intermine.Query.REFERENCE_OPS);

      ConstraintAdder.prototype.isValid = function() {
        var _ref6, _ref7;

        if (this.newCon != null) {
          if (!this.newCon.con.has('op')) {
            return false;
          }
          if (_ref6 = this.newCon.con.get('op'), __indexOf.call(VALUE_OPS, _ref6) >= 0) {
            return this.newCon.con.has('value');
          }
          if (_ref7 = this.newCon.con.get('op'), __indexOf.call(intermine.Query.MULTIVALUE_OPS, _ref7) >= 0) {
            return this.newCon.con.has('values');
          }
          return true;
        } else {
          return false;
        }
      };

      ConstraintAdder.prototype.render = function() {
        var approver, browser;

        browser = $("<button type=\"button\" class=\"btn btn-chooser\" data-toggle=\"button\">\n  <i class=\"icon-sitemap\"></i>\n  <span>" + intermine.messages.constraints.BrowseForColumn + "</span>\n</button>");
        approver = $(this.make('button', {
          type: "button",
          "class": "btn btn-primary"
        }, "Choose"));
        this.$el.append(browser);
        this.$el.append(approver);
        approver.click(this.handleSubmission);
        browser.click(this.showTree);
        this.$('.btn-chooser').after("<label class=\"im-tree-option hidden\">\n  " + intermine.messages.columns.AllowRevRef + "\n  <input type=\"checkbox\" class=\"im-allow-rev-ref\">\n</label>\n<button class=\"btn im-collapser im-tree-option hidden\" type=\"button\" >\n  " + intermine.messages.columns.CollapseAll + "\n</button>");
        return this;
      };

      return ConstraintAdder;

    })(Backbone.View);
    return scope("intermine.query", {
      PATH_LEN_SORTER: PATH_LEN_SORTER,
      PATH_MATCHER: PATH_MATCHER,
      PATH_HIGHLIGHTER: PATH_HIGHLIGHTER,
      ConstraintAdder: ConstraintAdder
    });
  })();

  reqs = ['actions', 'actions/list-manager', 'actions/code-gen', 'actions/export-manager'];

  define('actions/actionbar', using.apply(null, __slice.call(reqs).concat([function(Actions, Lists, CodeGen, Exports) {
    var ActionBar, _ref;

    ActionBar = (function(_super) {
      __extends(ActionBar, _super);

      function ActionBar() {
        _ref = ActionBar.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      ActionBar.prototype.extraClass = "im-action";

      ActionBar.prototype.actionClasses = function() {
        return [Lists, CodeGen, Exports];
      };

      return ActionBar;

    })(Actions);
    scope("intermine.query.actions", {
      ActionBar: ActionBar
    });
    return ActionBar;
  }])));

  define('actions/code-gen', using('perma-query', 'html/code-gen', function(getPermaQuery, HTML) {
    var CODE_GEN_LANGS, CodeGenerator, alreadyDone, alreadyRejected, defer, get, indent, invoke, _ref, _ref1;

    CODE_GEN_LANGS = [
      {
        name: "Perl",
        extension: "pl"
      }, {
        name: "Python",
        extension: "py"
      }, {
        name: "Ruby",
        extension: "rb"
      }, {
        name: "Java",
        extension: "java"
      }, {
        name: "JavaScript",
        extension: "js"
      }, {
        name: "XML",
        extension: "xml"
      }
    ];
    indent = function(xml) {
      var buffer, indentLevel, isClosing, isOneLiner, isOpening, line, lines, _i, _len;

      lines = xml.split(/></);
      indentLevel = 1;
      buffer = [];
      for (_i = 0, _len = lines.length; _i < _len; _i++) {
        line = lines[_i];
        if (!/>$/.test(line)) {
          line = line + '>';
        }
        if (!/^</.test(line)) {
          line = '<' + line;
        }
        isClosing = /^<\/\w+\s*>/.test(line);
        isOneLiner = /\/>$/.test(line) || (!isClosing && /<\/\w+>$/.test(line));
        isOpening = !(isOneLiner || isClosing);
        if (isClosing) {
          indentLevel--;
        }
        buffer.push(new Array(indentLevel).join('  ') + line);
        if (isOpening) {
          indentLevel++;
        }
      }
      return buffer.join("\n");
    };
    _ref = intermine.funcutils, get = _ref.get, invoke = _ref.invoke;
    defer = function(x) {
      return jQuery.Deferred(function() {
        return this.resolve(x);
      });
    };
    alreadyDone = defer(true);
    alreadyRejected = jQuery.Deferred(function() {
      return this.reject('not available');
    });
    return CodeGenerator = (function(_super) {
      var canSaveFromMemory;

      __extends(CodeGenerator, _super);

      function CodeGenerator() {
        this.expand = __bind(this.expand, this);
        this.compact = __bind(this.compact, this);
        this.doMainAction = __bind(this.doMainAction, this);
        this.displayLang = __bind(this.displayLang, this);
        this.showComments = __bind(this.showComments, this);
        this.render = __bind(this.render, this);        _ref1 = CodeGenerator.__super__.constructor.apply(this, arguments);
        return _ref1;
      }

      CodeGenerator.prototype.tagName = "li";

      CodeGenerator.prototype.className = "im-code-gen";

      CodeGenerator.prototype.html = HTML({
        langs: CODE_GEN_LANGS
      });

      CodeGenerator.prototype.initialize = function(states) {
        var l, lang, _i, _len;

        this.states = states;
        this.model = new Backbone.Model;
        for (_i = 0, _len = CODE_GEN_LANGS.length; _i < _len; _i++) {
          l = CODE_GEN_LANGS[_i];
          if (l.extension === intermine.options.DefaultCodeLang) {
            lang = l;
          }
        }
        if (lang == null) {
          lang = CODE_GEN_LANGS[0];
        }
        this.model.set({
          lang: lang
        });
        return this.model.on('set:lang', this.displayLang);
      };

      CodeGenerator.prototype.render = function() {
        this.$el.append(this.html);
        this.$('.modal').hide();
        return this;
      };

      CodeGenerator.prototype.events = {
        'click .im-show-comments': 'showComments',
        'click .dropdown-menu a': 'setLang',
        'click .btn-action': 'doMainAction'
      };

      CodeGenerator.prototype.showComments = function(e) {
        if ($(e.target).is('.active')) {
          return this.compact();
        } else {
          return this.expand();
        }
      };

      CodeGenerator.prototype.setLang = function(e) {
        var $t, desired, l, lang, _i, _len;

        $t = $(e.target);
        desired = $t.data('lang');
        for (_i = 0, _len = CODE_GEN_LANGS.length; _i < _len; _i++) {
          l = CODE_GEN_LANGS[_i];
          if (l.extension === desired) {
            lang = l;
          }
        }
        if (lang != null) {
          this.model.set({
            lang: lang
          }, {
            silent: true
          });
          return this.model.trigger('set:lang');
        }
      };

      canSaveFromMemory = function() {
        if (typeof Blob === "undefined" || Blob === null) {
          alreadyRejected;
        }
        if (typeof saveAs !== "undefined" && saveAs !== null) {
          return alreadyDone;
        } else {
          return intermine.cdn.load('filesaver');
        }
      };

      CodeGenerator.prototype.displayLang = function() {
        var $modal, code, ext, href, isJS, isXML, lang, pq, query, ready, saveBtn,
          _this = this;

        lang = this.model.get('lang') || CODE_GEN_LANGS[0];
        query = this.states.currentQuery;
        pq = getPermaQuery(query);
        isJS = lang.extension === 'js';
        isXML = lang.extension === 'xml';
        ext = isJS ? 'html' : lang.extension;
        href = isXML ? '' : query.getCodeURI(lang.extension);
        ready = typeof prettyPrintOne !== "undefined" && prettyPrintOne !== null ? alreadyDone : intermine.cdn.load('prettify');
        $modal = this.$('.modal');
        saveBtn = this.$('.modal .btn-save').removeClass('disabled').unbind('click').attr({
          href: null
        });
        code = isXML ? pq.then(invoke('toXML')).then(indent) : pq.then(invoke('fetchCode', lang.extension));
        this.$('.im-code-lang').text(lang.name);
        if (isXML) {
          saveBtn.addClass('disabled');
          jQuery.when(code, canSaveFromMemory()).done(function(xml) {
            return saveBtn.removeClass('disabled').click(function() {
              var blob;

              blob = new Blob([xml], {
                type: 'application/xml;charset=utf8'
              });
              return saveAs(blob, 'query.xml');
            });
          });
        } else {
          pq.then(invoke('getCodeURI', lang.extension)).then(function(href) {
            return saveBtn.attr({
              href: href
            });
          });
        }
        return jQuery.when(code, ready).fail(function(e) {
          return _this.states.trigger('error', e);
        }).then(function(code) {
          var formatted;

          formatted = prettyPrintOne(_.escape(code), ext);
          $modal.find('pre').html(formatted);
          return $modal.modal('show');
        });
      };

      CodeGenerator.prototype.doMainAction = function(e) {
        if (this.model.has('lang')) {
          return this.displayLang();
        } else {
          return $(e.target).next().dropdown('toggle');
        }
      };

      CodeGenerator.prototype.compact = function() {
        var $m;

        $m = this.$('.modal');
        $m.find('span.com').closest('li').slideUp();
        return $m.find('.linenums li').filter(function() {
          return $(this).text().replace(/\s+/g, "") === "";
        }).slideUp();
      };

      CodeGenerator.prototype.expand = function() {
        var $m;

        $m = this.$('.modal');
        return $m.find('linenums li').slideDown();
      };

      return CodeGenerator;

    })(Backbone.View);
  }));

  define('actions/export-manager', function() {
    var ExportManager, _ref;

    return ExportManager = (function(_super) {
      __extends(ExportManager, _super);

      function ExportManager() {
        _ref = ExportManager.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      ExportManager.prototype.tagName = 'li';

      ExportManager.prototype.className = 'im-data-export';

      ExportManager.prototype.initialize = function(states) {
        this.states = states;
        return ExportManager.__super__.initialize.call(this);
      };

      ExportManager.prototype.template = _.template("<a class=\"btn im-open-dialogue\">\n  <i class=\"" + intermine.icons.Export + "\"></i>\n  <span class=\"visible-desktop\">" + intermine.messages.actions.ExportButton + "</span>\n</a>");

      ExportManager.prototype.events = function() {
        return {
          'click .im-open-dialogue': 'openDialogue'
        };
      };

      ExportManager.prototype.openDialogue = function() {
        var _ref1;

        if ((_ref1 = this.dialogue) != null) {
          _ref1.remove();
        }
        this.dialogue = new intermine.query["export"].ExportDialogue(this.states.currentQuery);
        this.$el.append(this.dialogue.render().el);
        return this.dialogue.show();
      };

      return ExportManager;

    })(intermine.views.ItemView);
  });

  define('actions/list-append-dialogue', using('actions/list-dialogue', 'html/append-list', function(ListDialogue, HTML) {
    var ListAppender, OPTION_TEMPLATE, makeOption, _ref;

    OPTION_TEMPLATE = _.template("<option value=\"<%- name %>\">\n  <%- name %> (<%= size %> <%- things %>)\n</option>");
    makeOption = function(list) {
      return OPTION_TEMPLATE(_.extend({}, list, {
        things: intermine.utils.pluralise(list.type, list.size)
      }));
    };
    ListAppender = (function(_super) {
      __extends(ListAppender, _super);

      function ListAppender() {
        _ref = ListAppender.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      ListAppender.prototype.html = HTML;

      ListAppender.prototype.events = function() {
        return _.extend(ListAppender.__super__.events.call(this), {
          'change select': 'setTarget'
        });
      };

      ListAppender.prototype.setTarget = function() {
        var l, name;

        name = this.$('select').val();
        return this.listOptions.set({
          list: ((function() {
            var _i, _len, _ref1, _results;

            _ref1 = this.__ls;
            _results = [];
            for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
              l = _ref1[_i];
              if (name === l.name) {
                _results.push(l);
              }
            }
            return _results;
          }).call(this))[0]
        });
      };

      ListAppender.prototype.displayType = function() {
        var estSize, type, _ref1;

        _ref1 = this.listOptions.toJSON(), estSize = _ref1.estSize, type = _ref1.type;
        return this.$('.im-item-type').text(intermine.utils.pluralise(type, estSize));
      };

      ListAppender.prototype.initialize = function() {
        var _this = this;

        ListAppender.__super__.initialize.apply(this, arguments);
        this.listOptions.on('change:estSize', function(opts, n) {
          return _this.$('.im-item-count').text(n);
        });
        this.listOptions.on('change:type', this.displayType, this);
        return this.listOptions.on('change:type', this.onlyShowCompatibleOptions, this);
      };

      ListAppender.prototype.nothingSelected = function() {
        var _this = this;

        ListAppender.__super__.nothingSelected.call(this);
        return this.$('form select option').each(function(i, elem) {
          return $(elem).attr({
            disabled: false
          });
        });
      };

      ListAppender.prototype.getSuitabilityFilter = function() {
        var model, pi, type;

        model = this.query.model;
        type = this.listOptions.toJSON().type;
        pi = model.getPathInfo(type);
        return function(list) {
          return list.authorized && pi.isa(list.type);
        };
      };

      ListAppender.prototype.onlyShowCompatibleOptions = function() {
        var list, select, service, type, _ref1,
          _this = this;

        _ref1 = this.listOptions.toJSON(), list = _ref1.list, type = _ref1.type;
        service = this.query.service;
        select = this.$('form select');
        select.empty();
        return service.fetchLists().done(function(ls) {
          var l, opt, suitable, _i, _len;

          _this.__ls = ls;
          suitable = ls.filter(_this.getSuitabilityFilter());
          for (_i = 0, _len = suitable.length; _i < _len; _i++) {
            l = suitable[_i];
            opt = $(makeOption(l));
            select.append(opt);
          }
          if (list) {
            select.val(list.name);
          } else {
            _this.listOptions.set({
              list: suitable[0]
            });
          }
          _this.$('.btn-primary').attr({
            disabled: suitable.length < 1
          });
          return _this.$('.im-none-compatible-error').toggle(suitable.length < 1);
        });
      };

      ListAppender.prototype.doAppend = function() {
        var ids, list, listQ, query, service, _ref1;

        ids = _.keys(this.types);
        _ref1 = this.listOptions.toJSON(), query = _ref1.query, list = _ref1.list;
        service = this.query.service;
        listQ = query || {
          select: ["id"],
          from: list.type,
          where: {
            id: ids
          }
        };
        return service.query(listQ).then(function(q) {
          return q.appendToList(list.name);
        });
      };

      ListAppender.prototype.create = function() {
        var backToNormal, cg, ilh, promise,
          _this = this;

        if (!this.listOptions.has('list')) {
          cg = this.$('.im-receiving-list').closest('.control-group').addClass('error');
          ilh = this.$('.help-inline').text("No receiving list selected").show();
          backToNormal = function() {
            return ilh.fadeOut(1000, function() {
              ilh.text("");
              return cg.removeClass("error");
            });
          };
          _.delay(backToNormal, 5000);
          return false;
        }
        promise = this.doAppend();
        promise.done(function(updated) {
          var added;

          added = updated.size - _this.listOptions.get('list').size;
          _this.query.trigger("list-update:success", updated, added);
          return _this.stop();
        });
        return promise.fail(function(xhr, level, message) {
          var e, err;

          err = (function() {
            try {
              return JSON.parse(xhr.responseText).error;
            } catch (_error) {
              e = _error;
              return message;
            }
          })();
          return _this.query.trigger("list-update:failure", err);
        });
      };

      ListAppender.prototype.render = function() {
        ListAppender.__super__.render.call(this);
        return this;
      };

      ListAppender.prototype.startPicking = function() {
        ListAppender.__super__.startPicking.call(this);
        return this.$('.im-none-compatible-error').hide();
      };

      return ListAppender;

    })(ListDialogue);
    scope('intermine.actions.lists', {
      ListAppender: ListAppender
    });
    return ListAppender;
  }));

  define('actions/list-dialogue', function() {
    var ListDialogue, _ref;

    return ListDialogue = (function(_super) {
      __extends(ListDialogue, _super);

      function ListDialogue() {
        _ref = ListDialogue.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      ListDialogue.prototype.tagName = "li";

      ListDialogue.prototype.className = "im-list-dialogue dropdown";

      ListDialogue.prototype.usingDefaultName = true;

      ListDialogue.prototype.initialize = function(query) {
        var opts,
          _this = this;

        this.query = query;
        this.listOptions = opts = new Backbone.Model;
        this.types = {};
        this.query.on("imo:selected", function(type, id, selected) {
          var commonType, m, types;

          if (_this.listOptions == null) {
            return;
          }
          if (selected) {
            _this.types[id] = type;
          } else {
            delete _this.types[id];
          }
          types = _.values(_this.types);
          opts.set({
            estSize: types.length
          });
          if (types.length > 0) {
            m = _this.query.model;
            commonType = m.findCommonTypeOfMultipleClasses(types);
            return opts.set({
              type: commonType
            });
          }
        });
        opts.on('change:query', function(_, q) {
          return q.count(function(n) {
            return opts.set({
              estSize: n
            });
          });
        });
        opts.on('change:query', function() {
          return _this.$('.modal').modal('show').find('form').show();
        });
        opts.on('change:name', this.updateNameDisplay, this);
        opts.on('change:name', this.checkName, this);
        opts.on('change:type', this.newCommonType, this);
        return opts.on('change:estSize', this.bindEstSize, this);
      };

      ListDialogue.prototype.updateNameDisplay = function() {
        console.log("Updating name to " + (this.listOptions.get('name')));
        return this.$('.im-list-name').val(this.listOptions.get('name'));
      };

      ListDialogue.prototype.remove = function() {
        var thing, _i, _len, _ref1;

        _ref1 = ['listOptions'];
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          thing = _ref1[_i];
          this[thing].off();
          delete this[thing];
        }
        return ListDialogue.__super__.remove.call(this);
      };

      ListDialogue.prototype.bindEstSize = function() {
        var estSize, hasSelectedItems;

        estSize = this.listOptions.get('estSize');
        hasSelectedItems = estSize > 0;
        this.$('.btn-primary').attr({
          disabled: !hasSelectedItems
        });
        this.$('.im-selection-instruction').hide();
        this.$('form').show();
        this.$el.addClass('im-picked');
        if (!hasSelectedItems) {
          return this.nothingSelected();
        }
      };

      ListDialogue.prototype.newCommonType = function() {
        return this.query.trigger("common:type:selected", this.listOptions.get('type'));
      };

      ListDialogue.prototype.nothingSelected = function() {
        this.$('.im-selection-instruction').slideDown();
        this.$('form').hide();
        this.$el.removeClass('im-picked');
        return this.query.trigger("selection:cleared");
      };

      ListDialogue.prototype.events = function() {
        return {
          'hidden': 'onHidden',
          'change .im-list-name': 'listNameChanged',
          'submit form': 'ignore',
          'click form': 'ignore',
          'click .btn-cancel': 'stop',
          'click .btn-primary': 'create',
          'click .im-minimise': 'minimise'
        };
      };

      ListDialogue.prototype.minimise = function() {
        this.$('.control-group').slice(1).slideToggle();
        return this.$('.im-minimise').toggleClass('im-collapsed');
      };

      ListDialogue.prototype.onHidden = function(e) {
        if (e && $(e.target).is('.modal')) {
          return this.remove();
        }
      };

      ListDialogue.prototype.startPicking = function() {
        var headAndFoot, m;

        this.$('.modal').addClass('im-picking-list-items');
        headAndFoot = this.$('.modal-header').add('.modal-footer', this.el).addClass('im-handle');
        this.query.trigger("start:list-creation");
        this.nothingSelected();
        m = this.$('.modal').show(function() {
          return $(this).addClass("in").draggable({
            handle: ".im-handle"
          });
        });
        return headAndFoot.css({
          cursor: "move"
        }).tooltip({
          title: "Drag me around!",
          placement: 'bottom'
        });
      };

      ListDialogue.prototype.stop = function(e) {
        var modal;

        this.query.trigger("stop:list-creation");
        modal = this.$('.modal');
        if (modal.is('.ui-draggable')) {
          return this.remove();
        } else {
          return modal.modal('hide');
        }
      };

      ListDialogue.prototype.ignore = function(e) {
        e.preventDefault();
        return e.stopPropagation();
      };

      ListDialogue.prototype.listNameChanged = function(e) {
        return this.listOptions.set({
          customName: true,
          name: $(e.target).val()
        });
      };

      ListDialogue.prototype.getLists = function() {
        var now;

        now = new Date().getTime();
        if (!this.listPromise || this.listPromise.made_at < now - intermine.options.ListFreshness) {
          this.listPromise = this.query.service.fetchLists();
          this.listPromise.made_at = now;
        }
        return this.listPromise;
      };

      ListDialogue.prototype.checkName = function() {
        var message, selector,
          _this = this;

        selector = '.im-list-name';
        message = intermine.messages.actions.ListNameDuplicate;
        this.clearError(selector);
        return this.getLists().done(function(ls) {
          var chosen, isDup;

          chosen = _this.listOptions.get('name');
          isDup = _.any(ls, function(l) {
            return l.authorized && l.name === chosen;
          });
          if (isDup) {
            return _this.setError(selector, message);
          }
        });
      };

      ListDialogue.prototype.setError = function(selector, message) {
        var $input;

        $input = this.$(selector);
        $input.next().text(message);
        return $input.parent().addClass('error');
      };

      ListDialogue.prototype.clearError = function(selector) {
        var $input;

        $input = this.$(selector);
        $input.next().text('');
        return $input.parent().removeClass('error');
      };

      ListDialogue.prototype.create = function() {
        throw new Error("Override me!");
      };

      ListDialogue.prototype.openDialogue = function(type, q) {
        if (type == null) {
          type = this.query.root;
        }
        if (q == null) {
          q = this.query.clone();
        }
        return this.listOptions.set({
          query: q,
          type: type
        });
      };

      ListDialogue.prototype.render = function() {
        this.$el.append(this.html);
        this.$('.modal').modal({
          show: false
        });
        return this;
      };

      return ListDialogue;

    })(Backbone.View);
  });

  define('actions/list-manager', using('actions/list-append-dialogue', 'actions/new-list-dialogue', function(ListAppender, ListCreator) {
    var ListManager, _ref;

    return ListManager = (function(_super) {
      var descendedFrom, pathOf;

      __extends(ListManager, _super);

      function ListManager() {
        this.updateTypeOptions = __bind(this.updateTypeOptions, this);
        this.changeAction = __bind(this.changeAction, this);        _ref = ListManager.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      ListManager.prototype.tagName = "li";

      ListManager.prototype.className = "im-list-management dropdown";

      ListManager.prototype.initialize = function(states) {
        this.states = states;
        this.states.on('add reverted', this.updateTypeOptions);
        this.action = ListManager.actions.create;
        return this.disabled = this.states.currentQuery.service.token == null;
      };

      ListManager.prototype.html = "<a class=\"btn\" data-toggle=\"dropdown\">\n    <i class=\"icon-list-alt\"></i>\n    <span class=\"im-only-widescreen\">Create / Add to</span>\n    List\n    <b class=\"caret\"></b>\n</a>\n<ul class=\"dropdown-menu im-type-options pull-right\">\n    <div class=\"btn-group\" data-toggle=\"buttons-radio\">\n        <button class=\"btn active im-list-action-chooser\" data-action=\"create\">\n            Create New List\n        </button>\n        <button class=\"btn im-list-action-chooser\" data-action=\"append\">\n            Add to Existing List\n        </button>\n    </div>\n</ul>";

      ListManager.prototype.events = {
        'click .btn-group > .im-list-action-chooser': 'changeAction',
        'click .im-pick-and-choose': 'startPicking'
      };

      ListManager.actions = {
        create: ListCreator,
        append: ListAppender
      };

      ListManager.prototype.changeAction = function(e) {
        var $t;

        e.stopPropagation();
        e.preventDefault();
        $t = $(e.target).button("toggle");
        return this.action = ListManager.actions[$t.data('action')];
      };

      ListManager.prototype.openDialogue = function(type, q) {
        var dialog;

        dialog = new this.action(this.states.currentQuery);
        dialog.render().$el.appendTo(this.el);
        return dialog.openDialogue(type, q);
      };

      ListManager.prototype.startPicking = function() {
        var dialog;

        dialog = new this.action(this.states.currentQuery);
        dialog.render().$el.appendTo(this.el);
        return dialog.startPicking();
      };

      descendedFrom = function(putativeParent) {
        var prefix;

        if (putativeParent.isAttribute()) {
          return function() {
            return false;
          };
        } else {
          prefix = putativeParent + '.';
          return function(suspectedChild) {
            return suspectedChild.substring(0, prefix.length) === prefix;
          };
        }
      };

      pathOf = intermine.funcutils.get('path');

      ListManager.prototype.updateTypeOptions = function() {
        var node, query, ul, viewNodes, _fn, _i, _len,
          _this = this;

        ul = this.$('.im-type-options');
        ul.find("li").remove();
        query = this.states.currentQuery;
        viewNodes = query.getViewNodes();
        _fn = function(node) {
          var countQuery, err, inCons, li, missingNode, needsAsserting, unselected, _j, _len1;

          li = $("<li></li>");
          ul.append(li);
          countQuery = query.clone();
          try {
            countQuery.select([node.append("id").toPathString()]);
          } catch (_error) {
            err = _error;
            console.error(err);
            return;
          }
          if (query.isOuterJoined(countQuery.views[0])) {
            (function(path) {
              var style, _results;

              style = 'INNER';
              _results = [];
              while (!path.isRoot()) {
                countQuery.addJoin({
                  path: path,
                  style: style
                });
                _results.push(path = path.getParent());
              }
              return _results;
            })(node);
          }
          unselected = viewNodes.filter(function(n) {
            return n !== node;
          });
          for (_j = 0, _len1 = unselected.length; _j < _len1; _j++) {
            missingNode = unselected[_j];
            inCons = _.any(countQuery.constraints, _.compose(descendedFrom(missingNode), pathOf));
            needsAsserting = (!inCons) || (query.isOuterJoined(missingNode));
            if (needsAsserting) {
              countQuery.addConstraint([missingNode.append("id"), "IS NOT NULL"]);
            }
          }
          countQuery.orderBy([]);
          li.click(function() {
            return _this.openDialogue(node.getType().name, countQuery);
          });
          li.mouseover(function() {
            return query.trigger("start:highlight:node", node);
          });
          li.mouseout(function() {
            return query.trigger("stop:highlight");
          });
          return countQuery.count().then(function(n) {
            var quantifier, typeName;

            if (n < 1) {
              return li.remove();
            }
            quantifier = (function() {
              switch (n) {
                case 1:
                  return "The";
                case 2:
                  return "Both";
                default:
                  return "All " + n;
              }
            })();
            typeName = intermine.utils.pluralise(node.getType().name, n);
            return li.append("<a>" + quantifier + " " + typeName + "</a>");
          });
        };
        for (_i = 0, _len = viewNodes.length; _i < _len; _i++) {
          node = viewNodes[_i];
          _fn(node);
        }
        return ul.append("<li class=\"im-pick-and-choose\">\n    <a>Choose individual items from the table</a>\n</li>");
      };

      ListManager.prototype.render = function() {
        this.$el.append(this.html);
        this.updateTypeOptions();
        return this;
      };

      return ListManager;

    })(Backbone.View);
  }));

  define('actions/new-list-dialogue', using('actions/list-dialogue', 'models/uniq-items', 'html/new-list', function(ListDialogue, UniqItems, HTML) {
    var CATEGORY_FROM_ROWS, CATEGORY_FROM_SUMMARY, ILLEGAL_LIST_NAME_CHARS, ListCreator, _ref;

    ILLEGAL_LIST_NAME_CHARS = /[^\w\s\(\):+\.-]/g;
    CATEGORY_FROM_SUMMARY = function(items, _arg) {
      var uniqueValues;

      uniqueValues = _arg.uniqueValues;
      return [uniqueValues, items, 'item'];
    };
    CATEGORY_FROM_ROWS = function(rows) {
      return [rows.length, rows, 0];
    };
    ListCreator = (function(_super) {
      var TAG_ILLEGALS;

      __extends(ListCreator, _super);

      function ListCreator() {
        this.updateTagBox = __bind(this.updateTagBox, this);
        this.handleFailure = __bind(this.handleFailure, this);
        this.handleSuccess = __bind(this.handleSuccess, this);        _ref = ListCreator.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      ListCreator.prototype.html = HTML;

      ListCreator.prototype.initialize = function(query) {
        var _this = this;

        this.query = query;
        ListCreator.__super__.initialize.call(this, this.query);
        this.query.service.whoami(function(me) {
          _this.canTag = me.username != null;
          if (_this.rendered && !_this.canTag) {
            return _this.hideTagOptions();
          }
        });
        this.tags = new UniqItems();
        this.suggestedTags = new UniqItems();
        this.tags.on("add", this.updateTagBox);
        this.suggestedTags.on("add", this.updateTagBox);
        this.tags.on("remove", this.updateTagBox);
        return this.initTags();
      };

      ListCreator.prototype.hideTagOptions = function() {
        return this.$('.im-tag-options').hide();
      };

      ListCreator.prototype.newCommonType = function() {
        var categoriser, cd, dateStr, first, ids, model, now, oq, querying, rest, service, summPath, text, type, viewNode, _i, _len, _ref1, _ref2, _ref3,
          _this = this;

        ListCreator.__super__.newCommonType.call(this);
        if (this.listOptions.get('customName')) {
          return;
        }
        type = this.listOptions.get('type');
        _ref1 = this.query, service = _ref1.service, model = _ref1.model;
        now = new Date();
        dateStr = ("" + now).replace(/\s\d\d:\d\d:\d\d\s.*$/, '');
        text = "" + type + " list - " + dateStr;
        cd = model.classes[type];
        ids = _.keys(this.types);
        this.listOptions.set({
          name: text,
          customName: false
        });
        _ref2 = intermine.options.ListCategorisers;
        for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
          categoriser = _ref2[_i];
          _ref3 = categoriser.split(/\./), first = _ref3[0], rest = 2 <= _ref3.length ? __slice.call(_ref3, 1) : [];
          if (first in cd.fields) {
            if (ids != null ? ids.length : void 0) {
              oq = {
                select: categoriser,
                from: type,
                where: {
                  id: ids
                }
              };
              querying = service.rows(oq).then(CATEGORY_FROM_ROWS);
            } else {
              oq = (this.listOptions.get('query') || this.query).clone();
              viewNode = oq.getViewNodes()[0];
              summPath = "" + viewNode + "." + categoriser;
              if (first in viewNode.getType().fields) {
                querying = oq.summarise(summPath, 1).then(CATEGORY_FROM_SUMMARY);
              }
            }
            querying.done(function(_arg) {
              var category, key, n, name, xs;

              n = _arg[0], xs = _arg[1], key = _arg[2];
              if (n === 1) {
                category = xs[0][key];
                name = "" + type + " list for " + category + " - " + dateStr;
                return _this.listOptions.set({
                  name: name,
                  customName: false
                });
              }
            });
            querying.always(function() {
              return _this.avoidNameDuplication();
            });
            return;
          }
        }
        return this.avoidNameDuplication();
      };

      ListCreator.prototype.avoidNameDuplication = function() {
        var copyNo, model, service, text, textBase, _ref1,
          _this = this;

        text = textBase = this.listOptions.get('name');
        copyNo = 1;
        _ref1 = this.query, service = _ref1.service, model = _ref1.model;
        return this.getLists().done(function(ls) {
          var l, _i, _len, _ref2, _results;

          _ref2 = _.sortBy(ls, function(l) {
            return l.name;
          });
          _results = [];
          for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
            l = _ref2[_i];
            if (l.name === text) {
              text = "" + textBase + " (" + (copyNo++) + ")";
              _results.push(_this.listOptions.set({
                name: text,
                customName: false
              }));
            } else {
              _results.push(void 0);
            }
          }
          return _results;
        });
      };

      ListCreator.prototype.openDialogue = function(type, q) {
        ListCreator.__super__.openDialogue.call(this, type, q);
        return this.initTags();
      };

      TAG_ILLEGALS = /[^\w\d\s.,:-]/g;

      ListCreator.prototype.initTags = function() {
        var add, c, now, _fn, _i, _len, _ref1,
          _this = this;

        this.tags.reset();
        this.suggestedTags.reset();
        add = function(tag) {
          return _this.suggestedTags.add(tag.replace(TAG_ILLEGALS, ' '), {
            silent: true
          });
        };
        _ref1 = this.query.constraints;
        _fn = function(c) {
          var title;

          title = c.title || c.path.replace(/^[^\.]+\./, "");
          if (c.op === "IN") {
            return add("source: " + c.value);
          } else if (c.op === "=") {
            return add("" + title + ": " + c.value);
          } else if (c.op === "<") {
            return add("" + title + " below " + c.value);
          } else if (c.op === ">") {
            return add("" + title + " above " + c.value);
          } else if (c.type) {
            return add("" + title + " is a " + c.type);
          } else {
            return add("" + title + " " + c.op + " " + (c.value || c.values));
          }
        };
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          c = _ref1[_i];
          _fn(c);
        }
        now = new Date();
        add("month: " + (now.getFullYear()) + "-" + (now.getMonth() + 1));
        add("year: " + (now.getFullYear()));
        add("day: " + (now.getFullYear()) + "-" + (now.getMonth() + 1) + "-" + (now.getDate()));
        return this.updateTagBox();
      };

      ListCreator.prototype.events = function() {
        return _.extend(ListCreator.__super__.events.call(this), {
          'click .remove-tag': 'removeTag',
          'click .accept-tag': 'acceptTag',
          'click .im-confirm-tag': 'addTag',
          'click .btn-reset': 'reset',
          'click .control-group h5': 'rollUpNext',
          'change .im-list-desc': 'updateDesc'
        });
      };

      ListCreator.prototype.updateDesc = function(e) {
        return this.listOptions.set({
          description: $(e.target).val()
        });
      };

      ListCreator.prototype.rollUpNext = function(e) {
        $(e.target).next().slideToggle();
        return $(e.target).find("i").toggleClass("icon-chevron-right icon-chevron-down");
      };

      ListCreator.prototype.reset = function() {
        var field, _i, _len, _ref1;

        _ref1 = ["name", "desc", "type"];
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          field = _ref1[_i];
          this.$(".im-list-" + field).val("");
        }
        return this.initTags();
      };

      ListCreator.prototype.create = function() {
        var description, illegals, listQ, name, opts, query, tags, type, _ref1;

        _ref1 = this.listOptions.toJSON(), query = _ref1.query, name = _ref1.name, type = _ref1.type, description = _ref1.description;
        tags = this.tags.map(function(t) {
          return t.get("item");
        });
        if (!(name && /\w/.test(name))) {
          return this.setError('.im-list-name', intermine.messages.actions.ListNameEmpty);
        }
        if (illegals = name.match(ILLEGAL_LIST_NAME_CHARS)) {
          return this.setError('.im-list-name', intermine.messages.actions.ListNameIllegal({
            illegals: illegals
          }));
        }
        listQ = query || {
          select: ["id"],
          from: type,
          where: {
            id: _(this.types).keys()
          }
        };
        opts = {
          name: name,
          description: description,
          tags: tags
        };
        return this.makeNewList(listQ, opts);
      };

      ListCreator.prototype.makeNewList = function(query, opts) {
        var saving,
          _this = this;

        if (query.saveAsList != null) {
          saving = query.saveAsList(opts);
          saving.done(this.handleSuccess);
          saving.fail(this.handleFailure);
          return this.stop();
        } else {
          return this.query.service.query(query, function(q) {
            return _this.makeNewList(q, opts);
          });
        }
      };

      ListCreator.prototype.handleSuccess = function(list) {
        console.log("Created a list", list);
        return this.query.trigger("list-creation:success", list);
      };

      ListCreator.prototype.handleFailure = function(xhr, level, message) {
        if (xhr.responseText) {
          message = (JSON.parse(xhr.responseText)).error;
        }
        return this.query.trigger("list-creation:failure", message);
      };

      ListCreator.prototype.removeTag = function(e) {
        var tag;

        tag = $(e.target).closest('.label').find('.tag-text').text();
        this.tags.remove(tag);
        this.suggestedTags.add(tag);
        return $('.tooltip').remove();
      };

      ListCreator.prototype.acceptTag = function(e) {
        var tag;

        console.log("Accepting", e);
        tag = $(e.target).closest('.label').find('.tag-text').text();
        $('.tooltip').remove();
        this.suggestedTags.remove(tag);
        return this.tags.add(tag);
      };

      ListCreator.prototype.updateTagBox = function() {
        var box;

        box = this.$('.im-list-tags.choices');
        box.empty();
        this.tags.each(function(t) {
          var $li;

          $li = $("<li title=\"" + (t.escape("item")) + "\">\n    <span class=\"label label-warning\">\n        <i class=\"icon-tag icon-white\"></i>\n        <span class=\"tag-text\">" + (t.escape("item")) + "</span>\n        <a href=\"#\">\n            <i class=\"icon-remove-circle icon-white remove-tag\"></i>\n        </a>\n    </span>\n</li>");
          return $li.tooltip({
            placement: "top"
          }).appendTo(box);
        });
        box.append("<div style=\"clear:both\"></div>");
        box = this.$('.im-list-tags.suggestions');
        box.empty();
        this.suggestedTags.each(function(t) {
          var $li;

          $li = $("<li title=\"This tag is a suggestion. Click the 'ok' sign to add it\">\n    <span class=\"label\">\n        <i class=\"icon-tag icon-white\"></i>\n        <span class=\"tag-text\">" + (t.escape("item")) + "</span>\n        <a href=\"#\" class=\"accept-tag\">\n            <i class=\"icon-ok-circle icon-white\"></i>\n        </a>\n    </span>\n</li>");
          return $li.tooltip({
            placement: "top"
          }).appendTo(box);
        });
        return box.append("<div style=\"clear:both\"></div>");
      };

      ListCreator.prototype.addTag = function(e) {
        var tagAdder;

        e.preventDefault();
        tagAdder = this.$('.im-available-tags');
        this.tags.add(tagAdder.val());
        tagAdder.val("");
        return tagAdder.next().attr({
          disabled: true
        });
      };

      ListCreator.prototype.rendered = false;

      ListCreator.prototype.render = function() {
        var tagAdder,
          _this = this;

        ListCreator.__super__.render.call(this);
        this.updateTagBox();
        tagAdder = this.$('.im-available-tags');
        this.$('a').button();
        this.getLists().done(function(ls) {
          return tagAdder.typeahead({
            source: _.reduce(ls, (function(a, l) {
              return _.union(a, l.tags);
            }), []),
            items: 10,
            matcher: function(item) {
              if (!this.query) {
                return true;
              }
              return this.constructor.prototype.matcher.call(this, item);
            }
          });
        });
        tagAdder.keyup(function(e) {
          _this.$('.im-confirm-tag').attr("disabled", false);
          if (e.which === 13) {
            return _this.addTag(e);
          }
        });
        if ((this.canTag != null) && !this.canTag) {
          this.hideTagOptions();
        }
        this.rendered = true;
        return this;
      };

      return ListCreator;

    })(ListDialogue);
    scope('intermine.query.actions', {
      ListCreator: ListCreator
    });
    scope('intermine.actions.lists', {
      ListCreator: ListCreator
    });
    return ListCreator;
  }));

  define('actions', using('actions/list-manager', 'actions/code-gen', function(ListManager, CodeGenerator) {
    var Actions, _ref;

    Actions = (function(_super) {
      __extends(Actions, _super);

      function Actions() {
        _ref = Actions.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      Actions.prototype.className = "im-query-actions row-fluid";

      Actions.prototype.tagName = "ul";

      Actions.prototype.initialize = function(states) {
        this.states = states;
      };

      Actions.prototype.actionClasses = function() {
        return [ListManager, CodeGenerator];
      };

      Actions.prototype.extraClass = "im-action";

      Actions.prototype.render = function() {
        var action, cls, _i, _len, _ref1;

        _ref1 = this.actionClasses();
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          cls = _ref1[_i];
          action = new cls(this.states);
          if (!action.disabled) {
            action.render().$el.addClass(this.extraClass).appendTo(this.el);
          }
        }
        return this;
      };

      return Actions;

    })(Backbone.View);
    scope("intermine.query.actions", {
      Actions: Actions
    });
    return Actions;
  }));

  (function() {
    var PossibleColumns, _ref;

    PossibleColumns = (function(_super) {
      __extends(PossibleColumns, _super);

      function PossibleColumns() {
        _ref = PossibleColumns.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      PossibleColumns.prototype.initialize = function(_, _arg) {
        var _this = this;

        this.exported = _arg.exported;
        return this.on('close', function() {
          return _this.each(function(m) {
            return m.destroy();
          });
        });
      };

      return PossibleColumns;

    })(Backbone.Collection);
    return scope('intermine.columns.models', {
      PossibleColumns: PossibleColumns
    });
  })();

  scope('intermine.messages.results', {
    ReorderHelp: 'Drag the columns to reorder them'
  });

  scope('intermine.messages.columns', {
    AllowRevRef: 'Allow reverse references',
    CollapseAll: 'Collapse all branches'
  });

  (function() {
    var ColumnAdder, ColumnsDialogue, NewViewNodes, Tab, ViewNode, byEl, _ref, _ref1, _ref2, _ref3;

    byEl = function(el) {
      return function(nv) {
        return nv.el === el;
      };
    };
    Tab = intermine.bootstrap.Tab;
    ColumnAdder = (function(_super) {
      __extends(ColumnAdder, _super);

      function ColumnAdder() {
        this.isDisabled = __bind(this.isDisabled, this);
        this.handleSubmission = __bind(this.handleSubmission, this);
        this.handleChoice = __bind(this.handleChoice, this);        _ref = ColumnAdder.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      ColumnAdder.prototype.className = "form node-adder form-horizontal";

      ColumnAdder.prototype.initialize = function(query, newView) {
        this.newView = newView;
        ColumnAdder.__super__.initialize.call(this, query);
        return this.chosen = [];
      };

      ColumnAdder.prototype.handleChoice = function(path) {
        var $b;

        if (__indexOf.call(this.chosen, path) >= 0) {
          this.chosen = _.without(this.chosen, path);
        } else {
          this.chosen.push(path);
        }
        this.applyChanges();
        $b = this.$('.btn-chooser');
        if ($b.is('.active')) {
          return $b.button('toggle');
        }
      };

      ColumnAdder.prototype.handleSubmission = function(e) {
        e.preventDefault();
        e.stopPropagation();
        return this.applyChanges();
      };

      ColumnAdder.prototype.applyChanges = function() {
        this.newView.addPaths(this.chosen);
        return this.reset();
      };

      ColumnAdder.prototype.reset = function() {
        ColumnAdder.__super__.reset.call(this);
        return this.chosen = [];
      };

      ColumnAdder.prototype.refsOK = false;

      ColumnAdder.prototype.multiSelect = true;

      ColumnAdder.prototype.isDisabled = function(path) {
        var _ref1;

        return _ref1 = path.toString(), __indexOf.call(this.query.views, _ref1) >= 0;
      };

      ColumnAdder.prototype.render = function() {
        ColumnAdder.__super__.render.call(this);
        this.$('input').remove();
        this.$('.btn-chooser > span').text(intermine.messages.columns.FindColumnToAdd);
        return this;
      };

      ColumnAdder.prototype.showTree = function(e) {
        var _ref1;

        ColumnAdder.__super__.showTree.call(this, e);
        return (_ref1 = this.$pathfinder) != null ? _ref1.$el.removeClass(this.$pathfinder.dropDownClasses) : void 0;
      };

      return ColumnAdder;

    })(intermine.query.ConstraintAdder);
    ViewNode = (function(_super) {
      __extends(ViewNode, _super);

      function ViewNode() {
        _ref1 = ViewNode.__super__.constructor.apply(this, arguments);
        return _ref1;
      }

      ViewNode.prototype.initialize = function() {
        if (!this.has('isNew')) {
          this.set({
            isNew: false
          });
        }
        if (!this.has('replaces')) {
          this.set({
            replaces: []
          });
        }
        if (!this.has('isFormatted')) {
          return this.set({
            isFormatted: intermine.results.shouldFormat(this.get('path'))
          });
        }
      };

      ViewNode.prototype.addPath = function(path) {
        return this.set({
          replaces: this.get('replaces').concat([path])
        });
      };

      ViewNode.prototype.getViews = function() {
        if (this.get('replaces').length) {
          return this.get('replaces');
        } else {
          return [this.get('path')];
        }
      };

      ViewNode.prototype.isAbove = function(path, query) {
        var base, myformatter, theirformatter;

        base = this.get('path');
        if (base.isAttribute()) {
          false;
        }
        if (path.toString().indexOf(base.toString()) !== 0) {
          return false;
        } else if (this.get('isFormatted') && intermine.results.shouldFormat(path)) {
          myformatter = intermine.results.getFormatter(base.append('id'));
          theirformatter = intermine.results.getFormatter(path);
          return myformatter === theirformatter;
        } else if (path.containsCollection() && query.isOuterJoined(path)) {
          return true;
        } else {
          return false;
        }
      };

      return ViewNode;

    })(Backbone.Model);
    NewViewNodes = (function(_super) {
      var lengthOfPath;

      __extends(NewViewNodes, _super);

      function NewViewNodes() {
        _ref2 = NewViewNodes.__super__.constructor.apply(this, arguments);
        return _ref2;
      }

      NewViewNodes.prototype.model = ViewNode;

      NewViewNodes.prototype.close = function() {
        this.off();
        return this.each(function(vn) {
          if (vn != null) {
            vn.off();
          }
          return vn != null ? vn.destroy() : void 0;
        });
      };

      lengthOfPath = function(vn) {
        return vn.get('path').allDescriptors().length;
      };

      NewViewNodes.prototype.initialize = function(_, options) {
        this.options = options;
      };

      NewViewNodes.prototype.addPaths = function(paths) {
        var group, path, _i, _len, _results;

        _results = [];
        for (_i = 0, _len = paths.length; _i < _len; _i++) {
          path = paths[_i];
          group = this.getGroup(path);
          if (group != null) {
            _results.push(group.addPath(path));
          } else {
            _results.push(this.add({
              path: path,
              isNew: true
            }));
          }
        }
        return _results;
      };

      NewViewNodes.prototype.getGroup = function(path) {
        var bestMatch, matches, q;

        q = this.options.query;
        matches = this.filter(function(vn) {
          return vn.isAbove(path, q);
        });
        bestMatch = _.last(_.sortBy(matches, lengthOfPath));
        return bestMatch;
      };

      return NewViewNodes;

    })(Backbone.Collection);
    ColumnsDialogue = (function(_super) {
      __extends(ColumnsDialogue, _super);

      function ColumnsDialogue() {
        this.addPossibleSortElement = __bind(this.addPossibleSortElement, this);
        this.addSortElement = __bind(this.addSortElement, this);        _ref3 = ColumnsDialogue.__super__.constructor.apply(this, arguments);
        return _ref3;
      }

      ColumnsDialogue.prototype.tagName = "div";

      ColumnsDialogue.prototype.className = "im-column-dialogue modal";

      ColumnsDialogue.prototype.initialize = function(query, columnHeaders) {
        var _ref4,
          _this = this;

        this.query = query;
        this.columnHeaders = columnHeaders;
        if ((_ref4 = this.columnHeaders) == null) {
          this.columnHeaders = new Backbone.Collection;
        }
        this.sortOpts = new Backbone.Model;
        this.sortOrder = new intermine.columns.collections.SortOrder;
        this.sortPossibles = new intermine.columns.collections.PossibleOrderElements;
        this.newView = new NewViewNodes([], {
          query: this.query
        });
        this.sortOrder.on('add', this.addSortElement);
        this.sortPossibles.on('add', this.addPossibleSortElement);
        this.sortOpts.on('change:onlyInView', function(m, only) {
          return _this.sortPossibles.each(function(m) {
            return m.trigger('only-in-view', only);
          });
        });
        this.sortOpts.on('change:filterTerm', function(m, re) {
          return _this.sortPossibles.each(function(m) {
            return m.trigger('filter', re);
          });
        });
        this.sortOrder.on('destroy', function(m) {
          return _this.sortPossibles.add({
            path: m.get('path'),
            query: _this.query
          });
        });
        this.newView.on('add remove change', this.drawOrder, this);
        return this.newView.on('destroy', function(nv) {
          return _this.newView.remove(nv);
        });
      };

      ColumnsDialogue.prototype.html = function() {
        return intermine.columns.snippets.ColumnsDialogue;
      };

      ColumnsDialogue.prototype.render = function() {
        var _this = this;

        this.$el.append(this.html());
        this.initOrdering();
        this.initSorting();
        this.sortOpts.set({
          onlyInView: true
        });
        this.$('i.im-sorting-help').popover({
          placement: function(popover) {
            $(popover).addClass('bootstrap');
            return 'left';
          },
          trigger: 'hover',
          html: true,
          title: intermine.messages.columns.SortingHelpTitle,
          content: intermine.messages.columns.SortingHelpContent
        });
        this.$('.nav-tabs li a').each(function(i, e) {
          var $elem;

          $elem = $(e);
          return $elem.data({
            target: _this.$($elem.data("target"))
          });
        });
        return this;
      };

      ColumnsDialogue.prototype.events = {
        'hidden': 'onHidden',
        'click .btn-cancel': 'hideModal',
        'click .btn-primary': 'applyChanges',
        'click .nav-tabs li a': 'changeTab',
        'change input.im-only-in-view': 'onlyShowOptionsInView',
        'change .im-sortables-filter': 'filterSortables',
        'keyup .im-sortables-filter': 'filterSortables',
        'sortstop .im-sorting-container': 'onSortStop',
        'sortupdate .im-reordering-container': 'updateOrder',
        'sortupdate .im-sorting-container': 'updateSorting'
      };

      ColumnsDialogue.prototype.onSortStop = function(e, ui) {
        var left, oe, removed, top, well, wtop, _ref4;

        _ref4 = ui.offset, top = _ref4.top, left = _ref4.left;
        well = ui.item.closest('.well');
        wtop = well.offset().top;
        removed = (top + ui.item.height() < wtop) || (top > wtop + well.height());
        oe = this.sortOrder.find(byEl(ui.item[0]));
        if (removed) {
          return _.defer(function() {
            return oe.destroy();
          });
        }
      };

      ColumnsDialogue.prototype.onHidden = function(e) {
        if (this.el !== (e != null ? e.target : void 0)) {
          return false;
        }
        return this.remove();
      };

      ColumnsDialogue.prototype.remove = function() {
        this.sortOpts.off();
        this.sortOrder.off();
        this.sortPossibles.off();
        this.newView.close();
        delete this.newView;
        delete this.columnHeaders;
        delete this.sortOpts;
        delete this.sortOrder;
        delete this.sortPossibles;
        this.$el.empty();
        this.undelegateEvents();
        this.off();
        return ColumnsDialogue.__super__.remove.call(this);
      };

      ColumnsDialogue.prototype.getFilterTerm = function(e) {
        var $input, pattern, term;

        $input = $(e.currentTarget);
        term = $input.val();
        if (!term) {
          return;
        }
        pattern = term.split(/\s+/).join('.*');
        return new RegExp(pattern, 'i');
      };

      ColumnsDialogue.prototype.filterSortables = function(e) {
        return this.sortOpts.set({
          filterTerm: this.getFilterTerm(e)
        });
      };

      ColumnsDialogue.prototype.onlyShowOptionsInView = function(e) {
        return this.sortOpts.set({
          onlyInView: $(e.currentTarget).is(':checked')
        });
      };

      ColumnsDialogue.prototype.changeTab = function(e) {
        return Tab.call($(e.currentTarget), "show");
      };

      ColumnsDialogue.prototype.initOrdering = function() {
        var model;

        this.newView.reset((function() {
          var _i, _len, _ref4, _results;

          _ref4 = this.columnHeaders.models;
          _results = [];
          for (_i = 0, _len = _ref4.length; _i < _len; _i++) {
            model = _ref4[_i];
            _results.push(model.toJSON());
          }
          return _results;
        }).call(this));
        this.drawOrder();
        return this.drawSelector();
      };

      ColumnsDialogue.prototype.drawOrder = function() {
        var colContainer,
          _this = this;

        colContainer = this.$('.im-reordering-container');
        colContainer.empty();
        colContainer.tooltip({
          title: intermine.messages.results.ReorderHelp,
          placement: intermine.utils.addStylePrefix('top')
        });
        this.newView.each(function(model) {
          var view;

          view = new intermine.columns.views.ViewElement({
            model: model
          });
          return colContainer.append(view.render().el);
        });
        return colContainer.sortable({
          items: 'li.im-reorderable',
          axis: 'y',
          forcePlaceholderSize: true,
          placeholder: 'im-resorting-placeholder'
        });
      };

      ColumnsDialogue.prototype.drawSelector = function() {
        var ca, nodeAdder, selector, _ref4,
          _this = this;

        selector = '.im-reordering .well';
        nodeAdder = this.$('.node-adder');
        if ((_ref4 = this.ca) != null) {
          _ref4.remove();
        }
        ca = new ColumnAdder(this.query, this.newView);
        nodeAdder.empty().append(ca.render().el);
        ca.on('showing:tree', function() {
          return _this.$(selector).slideUp();
        });
        ca.on('resetting:tree', function() {
          return _this.$(selector).slideDown();
        });
        return this.ca = ca;
      };

      ColumnsDialogue.prototype.updateOrder = function(e, ui) {
        var el, lis, reorderedState;

        lis = this.$('.im-view-element');
        byEl = function(el) {
          return function(nv) {
            return nv.el === el;
          };
        };
        reorderedState = (function() {
          var _i, _len, _ref4, _results;

          _ref4 = lis.get();
          _results = [];
          for (_i = 0, _len = _ref4.length; _i < _len; _i++) {
            el = _ref4[_i];
            _results.push(this.newView.find(byEl(el)));
          }
          return _results;
        }).call(this);
        return this.newView.reset(reorderedState);
      };

      ColumnsDialogue.prototype.updateSorting = function(e, ui) {
        var el, lis, reorderedState;

        lis = this.$('.im-in-order');
        byEl = function(el) {
          return function(oe) {
            return oe.el === el;
          };
        };
        reorderedState = (function() {
          var _i, _len, _ref4, _results;

          _ref4 = lis.get();
          _results = [];
          for (_i = 0, _len = _ref4.length; _i < _len; _i++) {
            el = _ref4[_i];
            _results.push(this.sortOrder.find(byEl(el)));
          }
          return _results;
        }).call(this);
        return this.sortOrder.reset(reorderedState);
      };

      ColumnsDialogue.prototype.sortingPlaceholder = "<div class=\"placeholder\">\n    Drop columns here.\n</div>";

      ColumnsDialogue.prototype.makeSortOrderElem = function(model) {
        var possibles, soe;

        possibles = this.sortPossibles;
        soe = new intermine.columns.views.OrderElement({
          model: model,
          possibles: possibles
        });
        return soe.render().el;
      };

      ColumnsDialogue.prototype.makeSortOption = function(model) {
        var option;

        option = new intermine.columns.views.PossibleOrderElement({
          model: model,
          sortOrder: this.sortOrder
        });
        return option.render().el;
      };

      ColumnsDialogue.prototype.initSorting = function() {
        var container;

        container = this.$('.im-sorting-container').empty().append(this.sortingPlaceholder);
        this.$('.im-sorting-container-possibilities').empty();
        container.sortable();
        container.parent().droppable({
          drop: function(event, ui) {
            return $(ui.draggable).trigger('dropped');
          }
        });
        this.buildSortOrder();
        return this.buildPossibleSortOrder();
      };

      ColumnsDialogue.prototype.buildSortOrder = function() {
        var direction, i, path, so, _i, _len, _ref4, _results;

        this.sortOrder.reset([]);
        _ref4 = this.query.sortOrder || [];
        _results = [];
        for (i = _i = 0, _len = _ref4.length; _i < _len; i = ++_i) {
          so = _ref4[i];
          path = so.path, direction = so.direction;
          _results.push(this.sortOrder.add({
            path: this.query.getPathInfo(path),
            direction: direction
          }));
        }
        return _results;
      };

      ColumnsDialogue.prototype.buildPossibleSortOrder = function() {
        var inView, isOuter, isSorted, n, path, test0, test1, _i, _j, _len, _len1, _ref4, _ref5, _results,
          _this = this;

        this.sortPossibles.reset([]);
        isSorted = function(v) {
          return _this.query.getSortDirection(v);
        };
        isOuter = function(v) {
          return _this.query.isOuterJoined(v);
        };
        inView = function(v) {
          var _ref4;

          return _ref4 = "" + v, __indexOf.call(_this.query.views, _ref4) >= 0;
        };
        test0 = function(path) {
          return !isSorted(path) && !isOuter(path);
        };
        test1 = function(p) {
          return p.isAttribute() && !inView(p) && !isSorted(p);
        };
        _ref4 = this.query.views;
        for (_i = 0, _len = _ref4.length; _i < _len; _i++) {
          path = _ref4[_i];
          if (test0(path)) {
            this.sortPossibles.add({
              path: path,
              query: this.query
            });
          }
        }
        _ref5 = this.query.getViewNodes();
        _results = [];
        for (_j = 0, _len1 = _ref5.length; _j < _len1; _j++) {
          n = _ref5[_j];
          if (!isOuter(n)) {
            _results.push((function() {
              var _k, _len2, _ref6, _results1;

              _ref6 = n.getChildNodes();
              _results1 = [];
              for (_k = 0, _len2 = _ref6.length; _k < _len2; _k++) {
                path = _ref6[_k];
                if (test1(path)) {
                  _results1.push(this.sortPossibles.add({
                    path: path,
                    query: this.query
                  }));
                }
              }
              return _results1;
            }).call(this));
          }
        }
        return _results;
      };

      ColumnsDialogue.prototype.addSortElement = function(m) {
        var container, elem;

        container = this.$('.im-sorting-container');
        elem = this.makeSortOrderElem(m);
        return container.append(elem);
      };

      ColumnsDialogue.prototype.addPossibleSortElement = function(m) {
        var elem, possibilities;

        possibilities = this.$('.im-sorting-container-possibilities');
        elem = this.makeSortOption(m);
        return possibilities.append(elem);
      };

      ColumnsDialogue.prototype.hideModal = function() {
        return this.$el.modal('hide');
      };

      ColumnsDialogue.prototype.showModal = function() {
        return this.$el.modal({
          show: true
        });
      };

      ColumnsDialogue.prototype.applyChanges = function(e) {
        if (this.$('.im-reordering').is('.active')) {
          return this.changeOrder(e);
        } else {
          return this.changeSorting(e);
        }
      };

      ColumnsDialogue.prototype.changeOrder = function(e) {
        var newViews;

        newViews = _.flatten(this.newView.map(function(v) {
          return v.getViews();
        }));
        this.hideModal();
        return this.query.select(newViews);
      };

      ColumnsDialogue.prototype.changeSorting = function(e) {
        var newSO, so;

        newSO = (function() {
          var _i, _len, _ref4, _results;

          _ref4 = this.sortOrder.models;
          _results = [];
          for (_i = 0, _len = _ref4.length; _i < _len; _i++) {
            so = _ref4[_i];
            _results.push(so.toJSON());
          }
          return _results;
        }).call(this);
        this.hideModal();
        return this.query.orderBy(newSO);
      };

      return ColumnsDialogue;

    })(Backbone.View);
    return scope("intermine.query.results.table", {
      ColumnsDialogue: ColumnsDialogue
    });
  })();

  (function() {
    var ATTR_HTML, Columns, CurrentColumns, JOIN_TOGGLE_HTML, Selectable, _ref, _ref1, _ref2;

    JOIN_TOGGLE_HTML = _.template("<form class=\"form-inline pull-right im-join\">\n<div class=\"btn-group\" data-toggle=\"buttons-radio\">\n    <button data-style=\"INNER\" class=\"btn btn-small <% print(outer ? \"\" : \"active\") %>\">\n    Required\n    </button>\n    <button data-style=\"OUTER\" class=\"btn btn-small <% print(outer ? \"active\" : \"\") %>\">\n    Optional\n    </button>\n</div></form>");
    ATTR_HTML = _.template("<input type=\"checkbox\" \n    data-path=\"<%= path %>\"\n    <% inQuery ? print(\"checked\") : \"\" %> >\n<span class=\"im-view-option\">\n    <%= name %> (<% print(type.replace(\"java.lang.\", \"\")) %>)\n</span>");
    CurrentColumns = (function(_super) {
      __extends(CurrentColumns, _super);

      function CurrentColumns() {
        _ref = CurrentColumns.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      CurrentColumns.prototype.className = "node-remover";

      CurrentColumns.prototype.tagName = "dl";

      CurrentColumns.prototype.initialize = function(query) {
        this.query = query;
      };

      CurrentColumns.prototype.render = function() {
        var cd, rootSel, subnodes,
          _this = this;

        cd = this.query.service.model.classes[this.query.root];
        rootSel = new Selectable(this.query, cd);
        rootSel.render().$el.appendTo(this.el);
        subnodes = _({}).extend(cd.references, cd.collections);
        _(subnodes).chain().values().sortBy(function(f) {
          return f.name;
        }).each(function(f) {
          var sel, type;

          type = _this.query.getPathInfo(f).getEndClass();
          sel = new Selectable(_this.query, type, f);
          return sel.render().$el.appendTo(_this.el);
        });
        return this;
      };

      return CurrentColumns;

    })(Backbone.View);
    Selectable = (function(_super) {
      __extends(Selectable, _super);

      function Selectable() {
        this.render = __bind(this.render, this);
        this.setCheckBoxState = __bind(this.setCheckBoxState, this);        _ref1 = Selectable.__super__.constructor.apply(this, arguments);
        return _ref1;
      }

      Selectable.prototype.tagName = "dl";

      Selectable.prototype.className = "im-selectable-node";

      Selectable.prototype.initialize = function(query, table, field) {
        this.query = query;
        this.table = table;
        this.field = field;
        this.path = this.query.root + (this.field ? "." + this.field.name : "");
        return this.query.on("change:views", this.setCheckBoxState);
      };

      Selectable.prototype.events = {
        'click dt': 'toggleFields',
        'change input[type="checkbox"]': 'changeView'
      };

      Selectable.prototype.toggleFields = function(e) {
        return this.$('dd').slideToggle();
      };

      Selectable.prototype.changeView = function(e) {
        var $t, path;

        $t = $(e.target);
        path = $t.data("path");
        if ($t.attr("checked")) {
          return this.query.addToSelect(path);
        } else {
          return this.query.removeFromSelect(path);
        }
      };

      Selectable.prototype.setCheckBoxState = function(e) {
        var _this = this;

        return this.$('dd input').each(function(i, cbx) {
          var $cbx, path;

          $cbx = $(cbx);
          path = $cbx.data("path");
          return $cbx.attr({
            checked: _this.query.hasView(path)
          });
        });
      };

      Selectable.prototype.render = function() {
        var attr, dt, icon, isInView, name, title, _fn, _ref2, _ref3,
          _this = this;

        this.$el.empty();
        title = this.make("h4", {}, ((_ref2 = this.field) != null ? _ref2.name : void 0) || this.table.name);
        dt = this.make("dt", {
          "class": "im-column-group"
        }, title);
        this.$el.append(dt);
        isInView = _(this.query.views).any(function(v) {
          return this.path === v.substring(0, v.lastIndexOf("."));
        });
        icon = isInView ? "minus" : "plus";
        $("<i class=\"icon-" + icon + "-sign\"></i>").css({
          cursor: "pointer"
        }).appendTo(title);
        if (isInView && this.path !== this.query.root) {
          $(JOIN_TOGGLE_HTML({
            outer: this.query.isOuterJoin(this.path)
          })).submit(function(e) {
            var _this = this;

            return e.preventDefault().css("display", "inline-block".appendTo(title.find(".btn".click(function(e) {
              var style;

              e.stopPropagation();
              style = $(e.target).data("style");
              return _this.query.setJoinStyle(_this.path, style.button());
            }))));
          });
        }
        _ref3 = this.table.attributes;
        _fn = function(attr) {
          return _this.addAttribute(attr);
        };
        for (name in _ref3) {
          attr = _ref3[name];
          _fn(attr);
        }
        return this;
      };

      Selectable.prototype.addAttribute = function(a) {
        var ctx, dd, p;

        if (a.name !== "id") {
          dd = this.make("dd");
          p = "" + this.path + "." + a.name;
          ctx = {
            path: p,
            inQuery: __indexOf.call(this.query.views, p) >= 0
          };
          _(ctx).extend(a);
          return $(dd).append(ATTR_HTML(ctx)).appendTo(this.el);
        }
      };

      return Selectable;

    })(Backbone.View);
    Columns = (function(_super) {
      __extends(Columns, _super);

      function Columns() {
        _ref2 = Columns.__super__.constructor.apply(this, arguments);
        return _ref2;
      }

      Columns.prototype.className = "im-query-columns";

      Columns.prototype.initialize = function(query) {
        this.query = query;
      };

      Columns.prototype.render = function() {
        var cls, _fn, _i, _len, _ref3,
          _this = this;

        _ref3 = [ColumnAdder, CurrentColumns];
        _fn = function(cls) {
          var inst;

          inst = new cls(_this.query);
          return _this.$el.append(inst.render().el);
        };
        for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
          cls = _ref3[_i];
          _fn(cls);
        }
        return this;
      };

      return Columns;

    })(Backbone.View);
    return scope("intermine.query.columns", {
      Columns: Columns
    });
  })();

  scope('intermine.columns.snippets', {
    ColumnsDialogue: "<div class=\"modal-header\">\n  <a class=\"close\" data-dismiss=\"modal\">close</a>\n  <h3>Manage Columns</h3>\n</div>\n<div class=\"modal-body\">\n  <ul class=\"nav nav-tabs\">\n    <li class=\"active\">\n      <a data-target=\".im-reordering\">\n        <span class=\"hidden-tablet\">\n          " + intermine.messages.columns.OrderVerb + "\n        </span>\n        " + intermine.messages.columns.OrderTitle + "\n      </a>\n    </li>\n    <li>\n      <a data-target=\".im-sorting\" >\n        <span class=\"hidden-tablet\">\n          " + intermine.messages.columns.SortVerb + "\n        </span>\n        " + intermine.messages.columns.SortTitle + "\n      </a>\n    </li>\n  </ul>\n  <div class=\"tab-content\">\n    <div class=\"tab-pane fade im-reordering active in\">\n      <div class=\"node-adder\"></div>\n      <div class=\"well\">\n      <ul class=\"im-reordering-container nav nav-tabs nav-stacked\"></ul>\n      </div>\n    </div>\n    <div class=\"tab-pane fade im-sorting\">\n      <div class=\"well\">\n      <ul class=\"im-sorting-container nav nav-tabs nav-stacked\"></ul>\n      </div>\n      <form class=\"form-search\">\n      <i class=\"" + intermine.icons.Help + " pull-right im-sorting-help\"></i>\n      <div class=\"input-prepend\">\n        <span class=\"add-on\">filter</span>\n        <input type=\"text\" class=\"search-query im-sortables-filter\">\n      </div>\n      <label class=\"im-only-in-view\">\n        " + intermine.messages.columns.OnlyColsInView + "\n        <input class=\"im-only-in-view\" type=\"checkbox\" checked>\n      </label>\n      </form>\n      <div class=\"well\">\n      <ul class=\"im-sorting-container-possibilities nav nav-tabs nav-stacked\"></ul>\n      </div>\n    </div>\n  </div>\n</div>\n<div class=\"modal-footer\">\n  <a class=\"btn btn-cancel\">\n    Cancel\n  </a>\n  <a class=\"btn pull-right btn-primary\">\n    Apply\n  </a>\n</div>"
  });

  (function() {
    var NODE_TEMPLATE, PopOver, PossibleColumn, PossibleColumns, QueryNode, _ref, _ref1, _ref2, _ref3;

    NODE_TEMPLATE = _.template("<h4><%- node %></h4>\n<ul class=\"im-possible-attributes\"></ul>");
    PossibleColumn = (function(_super) {
      __extends(PossibleColumn, _super);

      function PossibleColumn() {
        _ref = PossibleColumn.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      PossibleColumn.prototype.tagName = 'li';

      PossibleColumn.prototype.className = 'im-possible-column';

      PossibleColumn.prototype.initialize = function(options) {
        this.options = options;
        this.on('rendered', this.showDisplayName, this);
        this.on('rendered', this.setClassName, this);
        return this.model.on('destroy', this.remove, this);
      };

      PossibleColumn.prototype.events = {
        'click': 'addToExportedList'
      };

      PossibleColumn.prototype.addToExportedList = function() {
        if (!this.model.get('alreadySelected')) {
          return this.model.trigger('selected', this.model);
        }
      };

      PossibleColumn.prototype.setClassName = function() {
        return this.$el.toggleClass('disabled', this.model.get('alreadySelected'));
      };

      PossibleColumn.prototype.showDisplayName = function() {
        var basicPath, canonical, path,
          _this = this;

        path = this.model.get('path');
        basicPath = "" + (path.getParent().getType().name) + "." + path.end.name;
        canonical = path.model.getPathInfo(basicPath);
        return canonical.getDisplayName().done(function(name) {
          _this.$('.im-field-name').text(name.split(' > ').pop());
          return _this.model.trigger('displayed-name');
        });
      };

      PossibleColumn.prototype.template = _.template("<a>\n  <i class=\"<% if (alreadySelected) { %>" + intermine.icons.Check + "<% } else { %>" + intermine.icons.UnCheck + "<% } %>\"></i>\n  <span class=\"im-field-name\"><%- path %></span>\n</a>");

      return PossibleColumn;

    })(intermine.views.ItemView);
    PopOver = (function(_super) {
      __extends(PopOver, _super);

      function PopOver() {
        _ref1 = PopOver.__super__.constructor.apply(this, arguments);
        return _ref1;
      }

      PopOver.prototype.tagName = 'ul';

      PopOver.prototype.className = 'im-possible-attributes';

      PopOver.prototype.initialize = function(options) {
        this.options = options;
        this.collection = new Backbone.Collection;
        this.collection.on('selected', this.selectPathForExport, this);
        this.collection.on('displayed-name', this.sortUL, this);
        return this.initFields();
      };

      PopOver.prototype.initFields = function() {
        var alreadySelected, path, _i, _len, _ref2, _results;

        this.collection.reset();
        _ref2 = this.options.node.getChildNodes();
        _results = [];
        for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
          path = _ref2[_i];
          if (!(this.isSuitable(path))) {
            continue;
          }
          alreadySelected = this.options.exported.any(function(x) {
            return path.equals(x.get('path'));
          });
          _results.push(this.collection.add({
            path: path,
            alreadySelected: alreadySelected
          }));
        }
        return _results;
      };

      PopOver.prototype.isSuitable = function(p) {
        var ok;

        return ok = p.isAttribute() && (intermine.options.ShowId || (p.end.name !== 'id'));
      };

      PopOver.prototype.remove = function() {
        this.collection.each(function(m) {
          if (m != null) {
            m.destroy();
          }
          return m != null ? m.off() : void 0;
        });
        this.collection.off();
        return PopOver.__super__.remove.apply(this, arguments);
      };

      PopOver.prototype.sortUL = function() {
        var $lis, lis, sorted;

        $lis = this.$('li');
        $lis.detach();
        lis = $lis.get();
        sorted = _.sortBy(lis, function(li) {
          return $(li).find('.im-field-name').text();
        });
        this.$el.append(sorted);
        return this.trigger('needs-repositioning');
      };

      PopOver.prototype.selectPathForExport = function(model) {
        console.log("We want " + (model.get('path')));
        this.collection.remove(model);
        this.options.exported.add({
          path: model.get('path')
        });
        model.destroy();
        return model.off();
      };

      PopOver.prototype.render = function() {
        var _this = this;

        this.collection.each(function(model) {
          var item;

          item = new PossibleColumn({
            model: model
          });
          item.render();
          return _this.$el.append(item.el);
        });
        return this;
      };

      return PopOver;

    })(Backbone.View);
    QueryNode = (function(_super) {
      __extends(QueryNode, _super);

      function QueryNode() {
        _ref2 = QueryNode.__super__.constructor.apply(this, arguments);
        return _ref2;
      }

      QueryNode.prototype.tagName = 'div';

      QueryNode.prototype.className = 'im-query-node btn';

      QueryNode.prototype.initialize = function(options) {
        var exported, node,
          _this = this;

        this.options = options;
        exported = this.model.collection.exported;
        node = this.model.get('node');
        this.content = new PopOver({
          node: node,
          exported: exported
        });
        this.listenTo(exported, 'add remove', this.render, this);
        this.listenTo(this.content, 'needs-repositioning', function() {
          var _ref3;

          return (_ref3 = _this.popover) != null ? _ref3.reposition() : void 0;
        });
        this.listenTo(this.model, 'destroy', this.remove, this);
        this.listenTo(this.model.collection, 'popover-toggled', function(originator) {
          var _ref3;

          if (_this.model !== originator) {
            return (_ref3 = _this.popover) != null ? _ref3.hide() : void 0;
          }
        });
        return this.model.once('popover-toggled', function() {
          return _this.content.render();
        });
      };

      QueryNode.prototype.remove = function() {
        var _ref3, _ref4, _ref5;

        if ((_ref3 = this.popover) != null) {
          _ref3.hide();
        }
        if ((_ref4 = this.popover) != null) {
          _ref4.destroy();
        }
        if ((_ref5 = this.content) != null) {
          _ref5.remove();
        }
        delete this.content;
        delete this.popover;
        return QueryNode.__super__.remove.apply(this, arguments);
      };

      QueryNode.prototype.events = function() {
        var _this = this;

        return {
          shown: function() {
            var _ref3;

            if ((_ref3 = _this.popover) != null) {
              _ref3.reposition();
            }
            return _this.model.trigger('popover-toggled', _this.model);
          },
          hide: function() {
            return _this.content.$el.detach();
          }
        };
      };

      QueryNode.prototype.render = function() {
        var data, options, ul,
          _this = this;

        data = this.model.toJSON();
        this.$el.empty();
        this.$el.html(NODE_TEMPLATE(data));
        ul = this.$('ul');
        data.node.getDisplayName().done(function(name) {
          var end, parents, _i, _ref3;

          _ref3 = name.split(' > '), parents = 2 <= _ref3.length ? __slice.call(_ref3, 0, _i = _ref3.length - 1) : (_i = 0, []), end = _ref3[_i++];
          return _this.$('h4').text(end);
        });
        options = {
          containment: '.tab-pane',
          html: true,
          trigger: 'click',
          placement: 'top',
          content: function() {
            return _this.content.$el;
          },
          title: function() {
            return _this.$('h4').text();
          }
        };
        this.popover = new intermine.bootstrap.DynamicPopover(this.el, options);
        return this;
      };

      return QueryNode;

    })(Backbone.View);
    PossibleColumns = (function(_super) {
      __extends(PossibleColumns, _super);

      function PossibleColumns() {
        _ref3 = PossibleColumns.__super__.constructor.apply(this, arguments);
        return _ref3;
      }

      PossibleColumns.prototype.tagName = 'div';

      PossibleColumns.prototype.className = 'im-possible-columns btn-group';

      PossibleColumns.prototype.initialize = function(options) {
        this.options = options;
        return this.nodes = [];
      };

      PossibleColumns.prototype.remove = function() {
        var node;

        while (node = this.nodes.pop()) {
          node.remove();
        }
        return PossibleColumns.__super__.remove.apply(this, arguments);
      };

      PossibleColumns.prototype.render = function() {
        var _this = this;

        this.collection.each(function(model) {
          var el, item;

          item = new QueryNode({
            model: model
          });
          _this.nodes.push(item);
          el = item.render().$el;
          return _this.$el.append(el);
        });
        return this;
      };

      return PossibleColumns;

    })(Backbone.View);
    return scope('intermine.columns.views', {
      PossibleColumns: PossibleColumns
    });
  })();

  scope("intermine.conbuilder.messages", {
    ValuePlaceholder: 'David*',
    ExtraPlaceholder: 'Wernham-Hogg',
    ExtraLabel: 'within',
    IsA: 'is a',
    NoValue: 'No value selected. Please enter a value.',
    Duplicate: 'This constraint is already on the query',
    TooManySuggestions: 'We cannot show you all the possible values'
  });

  (function() {
    var ActiveConstraint, HIGHLIGHTER, MATCHER, NewConstraint, PATH_SEGMENT_DIVIDER, TOO_MANY_SUGGESTIONS, UPDATER, aeql, basicEql, _ref, _ref1;

    PATH_SEGMENT_DIVIDER = "&rarr;";
    MATCHER = function(tooMany) {
      return function(item) {
        var parts, _ref;

        if ((item === tooMany) || (!this.query) || /^\s+$/.test(this.query)) {
          return true;
        } else {
          parts = (_ref = this.query.toLowerCase().split(' ')) != null ? _ref : [];
          return _.all(parts, function(p) {
            return item.toLowerCase().indexOf(p) >= 0;
          });
        }
      };
    };
    HIGHLIGHTER = function(tooMany) {
      return function(item) {
        if (item === tooMany) {
          return tooMany;
        } else {
          return this.constructor.prototype.highlighter.call(this, item);
        }
      };
    };
    UPDATER = function(tooMany) {
      return function(item) {
        if (item === tooMany) {
          return null;
        } else {
          return item;
        }
      };
    };
    TOO_MANY_SUGGESTIONS = _.template("<span class=\"alert alert-info\">\n  <i class=\"icon-info-sign\"></i>\n  " + intermine.conbuilder.messages.TooManySuggestions + "\n  There are <%= extra %> values we could not include.\n</span>");
    aeql = function(xs, ys) {
      var longer, shorter, _ref;

      if (!xs && !ys) {
        return true;
      }
      if (!xs || !ys) {
        return false;
      }
      _ref = _.sortBy([xs, ys], function(a) {
        return a.length;
      }), shorter = _ref[0], longer = _ref[1];
      return _.all(longer, function(x) {
        return __indexOf.call(shorter, x) >= 0;
      });
    };
    basicEql = function(a, b) {
      var k, keys, same, va, vb, x, _i, _len, _ref;

      if (!(a && b)) {
        return a === b;
      }
      keys = _.union.apply(_, [a, b].map(_.keys));
      same = true;
      for (_i = 0, _len = keys.length; _i < _len; _i++) {
        k = keys[_i];
        _ref = (function() {
          var _j, _len1, _ref, _results;

          _ref = [a, b];
          _results = [];
          for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
            x = _ref[_j];
            _results.push(x[k]);
          }
          return _results;
        })(), va = _ref[0], vb = _ref[1];
        same && (same = (_.isArray(va) ? aeql(va, vb) : va === vb));
      }
      return same;
    };
    ActiveConstraint = (function(_super) {
      var BASIC_OPS, CON_OPTS, IS_BLANK, toLabel;

      __extends(ActiveConstraint, _super);

      function ActiveConstraint() {
        this.changeMultiValues = __bind(this.changeMultiValues, this);        _ref = ActiveConstraint.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      ActiveConstraint.prototype.tagName = "form";

      ActiveConstraint.prototype.className = "form-inline im-constraint row-fluid";

      BASIC_OPS = intermine.Query.ATTRIBUTE_VALUE_OPS.concat(intermine.Query.NULL_OPS);

      ActiveConstraint.prototype.initialize = function(query, orig) {
        var _ref1, _ref2;

        this.query = query;
        this.orig = orig;
        this.typeaheads = [];
        this.path = this.query.getPathInfo(this.orig.path);
        this.type = this.path.getType();
        this.cast = (_ref1 = this.type, __indexOf.call(intermine.Model.NUMERIC_TYPES, _ref1) >= 0) ? (function(x) {
          return 1 * x;
        }) : (function(x) {
          return '' + x;
        });
        this.con = new Backbone.Model(_.extend({}, this.orig));
        if (this.path.isReference() || this.path.isRoot()) {
          this.ops = intermine.Query.REFERENCE_OPS;
        } else if (_ref2 = this.path.getType(), __indexOf.call(intermine.Model.BOOLEAN_TYPES, _ref2) >= 0) {
          this.ops = ["=", "!="].concat(intermine.Query.NULL_OPS);
        } else if (this.con.has('values')) {
          this.ops = intermine.Query.ATTRIBUTE_OPS;
        } else {
          this.ops = BASIC_OPS;
        }
        return this.con.on('change', this.fillConSummaryLabel, this);
      };

      ActiveConstraint.prototype.events = {
        'change .im-ops': 'drawValueOptions',
        'click .im-edit': 'toggleEditForm',
        'click .btn-cancel': 'hideEditForm',
        'click .btn-primary': 'editConstraint',
        'click .icon-remove-sign': 'removeConstraint',
        'click td.im-multi-value': 'toggleRowCheckbox',
        'submit': function(e) {
          e.preventDefault();
          return e.stopPropagation();
        }
      };

      ActiveConstraint.prototype.toggleRowCheckbox = function(e) {
        var $td, input;

        $td = $(e.target);
        input = $td.prev().find('input')[0];
        input.checked = !input.checked;
        return $(input).trigger('change');
      };

      ActiveConstraint.prototype.toggleEditForm = function() {
        this.$('.im-constraint-options').show();
        this.$('.im-con-buttons').show();
        this.$('.im-value-options').show();
        this.$el.siblings('.im-constraint').slideUp();
        return this.$el.closest('.well').addClass('im-editing');
      };

      ActiveConstraint.prototype.hideEditForm = function(e) {
        var ta, _results;

        if (e != null) {
          e.preventDefault();
        }
        if (e != null) {
          e.stopPropagation();
        }
        this.$el.removeClass('error');
        this.$el.siblings('.im-constraint').slideDown();
        this.$el.closest('.well').removeClass('im-editing');
        this.$('.im-con-overview').siblings('[class*="im-con"]').slideUp(200);
        this.$('.im-multi-value-table input').prop('checked', true);
        this.con.set(_.extend({}, this.orig));
        _results = [];
        while ((ta = this.typeaheads.shift())) {
          _results.push(ta.remove());
        }
        return _results;
      };

      IS_BLANK = /^\s*$/;

      ActiveConstraint.prototype.valid = function() {
        var e, ok, op, val;

        if (this.con.has('type')) {
          return true;
        }
        if (!this.con.get('op') || IS_BLANK.test(this.con.get('op'))) {
          return false;
        }
        op = this.con.get('op');
        if (this.path.isReference() && (op === '=' || op === '!=')) {
          ok = (function() {
            try {
              this.query.getPathInfo(this.con.get('value'));
              return true;
            } catch (_error) {
              e = _error;
              return false;
            }
          }).call(this);
          return ok;
        }
        if (__indexOf.call(intermine.Query.ATTRIBUTE_VALUE_OPS.concat(intermine.Query.REFERENCE_OPS), op) >= 0) {
          val = this.con.get('value');
          return (val != null) && (!IS_BLANK.test(val)) && (!_.isNaN(val));
        }
        if (__indexOf.call(intermine.Query.MULTIVALUE_OPS, op) >= 0) {
          return this.con.has('values') && this.con.get('values').length > 0;
        }
        return true;
      };

      ActiveConstraint.prototype.isDuplicate = function() {
        return _.any(this.query.constraints, _.partial(basicEql, this.con.toJSON()));
      };

      ActiveConstraint.prototype.setError = function(key) {
        this.$el.addClass('error');
        this.$('.im-conbuilder-error').text(intermine.conbuilder.messages[key]);
        return false;
      };

      ActiveConstraint.prototype.editConstraint = function(e) {
        var silently, ta, _ref1, _ref2, _ref3;

        if (e != null) {
          e.stopPropagation();
        }
        if (e != null) {
          e.preventDefault();
        }
        if (!this.valid()) {
          return this.setError('NoValue');
        }
        if (this.isDuplicate()) {
          return this.setError('Duplicate');
        }
        this.removeConstraint(e, silently = true);
        if (_ref1 = this.con.get('op'), __indexOf.call(intermine.Query.MULTIVALUE_OPS.concat(intermine.Query.NULL_OPS), _ref1) >= 0) {
          this.con.unset('value');
        }
        if (_ref2 = this.con.get('op'), __indexOf.call(intermine.Query.ATTRIBUTE_VALUE_OPS.concat(intermine.Query.NULL_OPS), _ref2) >= 0) {
          this.con.unset('values');
        }
        if ((_ref3 = this.con.get('op'), __indexOf.call(intermine.Query.MULTIVALUE_OPS, _ref3) >= 0) && this.con.get('values').length === 0) {
          this.query.trigger("change:constraints");
        } else {
          this.query.addConstraint(this.con.toJSON());
        }
        while ((ta = this.typeaheads.shift())) {
          ta.remove();
        }
        return true;
      };

      ActiveConstraint.prototype.removeConstraint = function(e, silently) {
        if (silently == null) {
          silently = false;
        }
        return this.query.removeConstraint(this.orig, silently);
      };

      ActiveConstraint.prototype.addIcons = function($label) {
        $label.append("<a><i class=\"icon-remove-sign\"></i></a>");
        if (this.con.locked) {
          return $label.append("<a><i class=\"icon-lock\" title=\"this constraint is not editable\"></i></a>");
        } else {
          return $label.append("<a><i class=\"im-edit " + intermine.icons.Edit + "\"></i></a>");
        }
      };

      ActiveConstraint.prototype.buttons = [
        {
          text: "Update",
          "class": "btn btn-primary"
        }, {
          text: "Cancel",
          "class": "btn btn-cancel"
        }
      ];

      ActiveConstraint.prototype.addButtons = function() {
        var btns, c, t, _fn, _i, _len, _ref1, _ref2;

        btns = $("<div class=\"btn-group im-con-buttons\">\n</div>");
        _ref1 = this.buttons;
        _fn = function() {
          return btns.append("<button class=\"" + c + "\">" + t + "</button>");
        };
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          _ref2 = _ref1[_i], t = _ref2.text, c = _ref2["class"];
          _fn();
        }
        return this.$el.append(btns);
      };

      ActiveConstraint.prototype.getTitleOp = function() {
        return this.con.get('op') || intermine.conbuilder.messages.IsA;
      };

      ActiveConstraint.prototype.getTitleVal = function() {
        if (this.con.get('values')) {
          return this.con.get('values').length + " values";
        } else if (this.con.has('value')) {
          return this.con.get('value');
        } else {
          return this.con.get('type');
        }
      };

      toLabel = function(content, type) {
        return $("<span class=\"label label-" + type + "\">" + content + "</span>");
      };

      ActiveConstraint.prototype.fillConSummaryLabel = function() {
        var op, sp, ul, val, _ref1,
          _this = this;

        if (this.label == null) {
          return;
        }
        this.label.empty();
        this.addIcons(this.label);
        ul = $('<ul class="breadcrumb">').appendTo(this.label);
        if (this.con.has('title')) {
          ul.append(toLabel(this.con.get('title'), 'path'));
        } else {
          sp = toLabel(this.path, 'path');
          (function(sp) {
            return _this.path.getDisplayName(function(name) {
              return sp.text(name);
            });
          })(sp);
          ul.append(sp);
        }
        if ((op = this.getTitleOp())) {
          ul.append(toLabel(op, 'op'));
        }
        if (_ref1 = this.con.get('op'), __indexOf.call(intermine.Query.NULL_OPS, _ref1) < 0) {
          val = this.getTitleVal();
          if (val != null) {
            ul.append(toLabel(val, 'value'));
          }
          if (this.con.has('extraValue')) {
            ul.append(intermine.conbuilder.messages.ExtraLabel);
            return ul.append(toLabel(this.con.get('extraValue'), 'extra'));
          }
        }
      };

      CON_OPTS = "<fieldset class=\"im-constraint-options\"></fieldset>";

      ActiveConstraint.prototype.render = function() {
        var fs;

        this.label = $("<label class=\"im-con-overview\">\n</label>");
        this.fillConSummaryLabel();
        this.$el.append(this.label);
        fs = $(CON_OPTS).appendTo(this.el);
        if (this.con.has('op')) {
          this.drawOperatorSelector(fs);
        }
        this.drawValueOptions();
        this.$el.append("<div class=\"alert alert-error im-hidden\">\n  <i class=\"icon-warning-sign\"></i>\n  <span class=\"im-conbuilder-error\">\n  </span>\n</div>");
        this.addButtons();
        return this;
      };

      ActiveConstraint.prototype.drawOperatorSelector = function(fs) {
        var $select, current,
          _this = this;

        current = this.con.get('op');
        $select = $("<select class=\"span4 im-ops\"><option>" + current + "</option></select>");
        $select.appendTo(fs);
        _(this.ops).chain().without(current).each(function(op) {
          return $select.append("<option>" + op + "</select>");
        });
        return $select.change(function(e) {
          return _this.con.set({
            op: $select.val()
          });
        });
      };

      ActiveConstraint.prototype.btnGroup = "<div class=\"im-value-options btn-group\" data-toggle=\"buttons-radio\"></div>";

      ActiveConstraint.prototype.drawTypeOpts = function(fs) {
        var baseType, label, schema, select, subclasses, t, type, types, _fn, _i, _len,
          _this = this;

        label = "<label class=\"span4\">IS A</label>";
        select = $("<select class=\"span7\">\n</select>");
        fs.append(label);
        fs.append(select);
        type = this.con.get('type');
        subclasses = this.query.getSubclasses();
        schema = this.query.model;
        delete subclasses[this.path];
        baseType = schema.getPathInfo(this.path, subclasses).getType();
        types = [type].concat(schema.getSubclassesOf(baseType));
        _fn = function(t) {
          var option;

          option = $('<option>');
          option.attr({
            value: t
          });
          select.append(option);
          return schema.getPathInfo(t).getDisplayName().done(function(name) {
            return option.text(name);
          });
        };
        for (_i = 0, _len = types.length; _i < _len; _i++) {
          t = types[_i];
          _fn(t);
        }
        return select.change(function() {
          return _this.con.set({
            type: select.val()
          });
        });
      };

      ActiveConstraint.prototype.drawBooleanOpts = function(fs) {
        var con, current, grp, val, _i, _len, _ref1, _results,
          _this = this;

        current = this.con.get('value');
        con = this.con;
        grp = $(this.btnGroup).appendTo(fs);
        _ref1 = ['true', 'false'];
        _results = [];
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          val = _ref1[_i];
          _results.push((function(val) {
            var button;

            button = $("<button class=\"btn " + (current === val ? 'active' : '') + "\">\n    " + val + "\n</button>");
            button.appendTo(grp);
            return button.click(function(e) {
              var wasActive;

              wasActive = button.is('.active');
              grp.find('button').removeClass('active');
              if (!wasActive) {
                button.addClass('active');
                return _this.con.set({
                  value: val
                });
              } else {
                return _this.con.unset('value');
              }
            });
          })(val));
        }
        return _results;
      };

      ActiveConstraint.prototype.valueSelect = "<select class=\"span7 im-value-options im-con-value\"></select>";

      ActiveConstraint.prototype.listOptionTempl = _.template("<option value=\"<%- name %>\">\n    <%- name %> (<%- size %> <%- type %>s)\n</option>");

      ActiveConstraint.prototype.multiValueTable = "<div class=\"im-value-options im-multi-value-table\">\n  <table class=\"table table-condensed\"></table>\n</div>";

      ActiveConstraint.prototype.multiValueOptTempl = _.template("<tr>\n    <td><input type=checkbox checked data-value=\"<%- value %>\"></td>\n    <td class=\"im-multi-value\"><%- value %></td>\n</tr>");

      ActiveConstraint.prototype.clearer = '<div class="im-value-options" style="clear:both;">';

      ActiveConstraint.prototype.drawMultiValueOps = function(fs) {
        var $multiValues, con, table, values,
          _this = this;

        con = this.con;
        if (!con.has('values')) {
          con.set({
            values: []
          });
        }
        values = con.get('values');
        $multiValues = $(this.multiValueTable).appendTo(fs);
        table = $multiValues.find('table');
        _(values).each(function(v) {
          return table.append(_this.multiValueOptTempl({
            value: v
          }));
        });
        return $multiValues.find('input').change(this.changeMultiValues);
      };

      ActiveConstraint.prototype.changeMultiValues = function(e) {
        var changed, value, values;

        changed = $(e.target);
        values = this.con.get('values');
        value = changed.data('value');
        if (changed.prop('checked')) {
          values = _.union(values, [value]);
        } else {
          values = _.without(values, value);
        }
        return this.con.set({
          values: values
        });
      };

      ActiveConstraint.prototype.drawListOptions = function(fs) {
        var $lists,
          _this = this;

        $lists = $(this.valueSelect).appendTo(fs);
        this.query.service.fetchLists(function(ls) {
          var selectables, sl, _i, _len;

          selectables = _(ls).filter(function(l) {
            return l.size && _this.path.isa(l.type);
          });
          for (_i = 0, _len = selectables.length; _i < _len; _i++) {
            sl = selectables[_i];
            $lists.append(_this.listOptionTempl(sl));
          }
          if (_this.con.has('value')) {
            $lists.val(_this.con.get('value'));
          }
          if (selectables.length === 0) {
            $lists.attr({
              disabled: true
            });
            return $lists.append('No lists of this type available');
          } else {
            return _this.con.set({
              value: $lists.val()
            });
          }
        });
        return $lists.change(function(e) {
          return _this.con.set({
            value: $lists.val()
          });
        });
      };

      ActiveConstraint.prototype.drawLoopOpts = function(fs) {
        var $loops, lc, loopCandidates, opt, _i, _len, _results,
          _this = this;

        $loops = $(this.valueSelect).appendTo(fs);
        loopCandidates = this.query.getQueryNodes().filter(function(lc) {
          return lc.isa(_this.type) || _this.path.isa(lc.getType());
        });
        _results = [];
        for (_i = 0, _len = loopCandidates.length; _i < _len; _i++) {
          lc = loopCandidates[_i];
          opt = $("<option value=\"" + (lc.toString()) + "\">");
          opt.appendTo($loops);
          _results.push((function(opt, lc) {
            return lc.getDisplayName(function(name) {
              return opt.text(name);
            });
          })(opt, lc));
        }
        return _results;
      };

      ActiveConstraint.prototype.handleSummary = function(input, items, total) {
        var MaxSuggestions, item, suggestions, tooMany;

        suggestions = (function() {
          var _i, _len, _ref1, _results;

          _ref1 = _.pluck(items, 'item');
          _results = [];
          for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
            item = _ref1[_i];
            _results.push('' + item);
          }
          return _results;
        })();
        MaxSuggestions = intermine.options.MaxSuggestions;
        if (total > MaxSuggestions) {
          tooMany = TOO_MANY_SUGGESTIONS({
            extra: total - MaxSuggestions
          });
          suggestions.push(tooMany);
        }
        input.typeahead({
          source: suggestions,
          items: 20,
          minLength: 0,
          updater: UPDATER(tooMany),
          highlighter: HIGHLIGHTER(tooMany),
          matcher: MATCHER(tooMany)
        });
        this.typeaheads.push(input.data('typeahead').$menu);
        this.query.on('cancel:add-constraint', function() {
          var _ref1;

          return (_ref1 = input.data('typeahead')) != null ? _ref1.$menu.remove() : void 0;
        });
        return input.attr({
          placeholder: items[0].item
        });
      };

      ActiveConstraint.prototype.handleNumericSummary = function(input, _arg) {
        var $slider, average, caster, fs, isInt, max, min, step, _ref1;

        min = _arg.min, max = _arg.max, average = _arg.average;
        isInt = (_ref1 = this.path.getType(), __indexOf.call(intermine.Model.INTEGRAL_TYPES, _ref1) >= 0);
        step = isInt ? 1 : max - min / 100;
        caster = isInt ? parseInt : parseFloat;
        fs = input.closest('fieldset');
        fs.append(this.clearer);
        $slider = $('<div class="im-value-options">');
        $slider.appendTo(fs).slider({
          min: min,
          max: max,
          value: (this.con.has('value') ? this.con.get('value') : caster(average)),
          step: step,
          slide: function(e, ui) {
            return input.val(ui.value).change();
          }
        });
        input.attr({
          placeholder: caster(average)
        });
        fs.append(this.clearer);
        return input.change(function(e) {
          return $slider.slider('value', caster(input.val()));
        });
      };

      ActiveConstraint.prototype.drawAttributeOpts = function(fs) {
        var input, setValue,
          _this = this;

        input = $("<input class=\"span7 im-constraint-value im-value-options im-con-value\" type=\"text\"\n    placeholder=\"" + intermine.conbuilder.messages.ValuePlaceholder + "\"\n    value=\"" + (this.con.get('value') || '') + "\"\n>");
        fs.append(input);
        setValue = function() {
          var _ref1;

          return _this.con.set({
            value: _this.cast((_ref1 = input.val()) != null ? _ref1.trim() : void 0)
          });
        };
        input.keyup(setValue);
        input.change(setValue);
        this.con.on('change:value', function() {
          var current;

          current = _this.con.get('value');
          if (current !== _this.cast(input.val())) {
            return input.val(current).change();
          }
        });
        if (this.path.isAttribute()) {
          return this.provideSuggestions(input);
        }
      };

      ActiveConstraint.prototype.provideSuggestions = function(input) {
        var c, clone, filtering, pstr, value,
          _this = this;

        clone = this.query.clone();
        pstr = this.path.toString();
        value = this.con.get('value');
        clone.constraints = (function() {
          var _i, _len, _ref1, _results;

          _ref1 = clone.constraints;
          _results = [];
          for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
            c = _ref1[_i];
            if (!(c.path === pstr && c.value === value)) {
              _results.push(c);
            }
          }
          return _results;
        })();
        filtering = clone.filterSummary(pstr, "", intermine.options.MaxSuggestions);
        return filtering.done(function(items, stats) {
          if ((items != null ? items.length : void 0) > 0) {
            if (items[0].item != null) {
              return _this.handleSummary(input, items, stats.uniqueValues);
            } else if (items[0].max != null) {
              return _this.handleNumericSummary(input, items[0]);
            }
          }
        });
      };

      ActiveConstraint.prototype.drawExtraOpts = function(fs) {
        var input,
          _this = this;

        fs.append("<label class=\"im-value-options\">\n    " + intermine.conbuilder.messages.ExtraLabel + "\n    <input type=\"text\" class=\"im-extra-value\"\n        placeholder=\"" + intermine.conbuilder.messages.ExtraPlaceholder + "\"\n        value=\"" + (this.con.get('extraValue') || '') + "\"\n    >\n</label>");
        return input = fs.find('input.im-extra-value').change(function(e) {
          return _this.con.set({
            extraValue: input.val()
          });
        });
      };

      ActiveConstraint.prototype.drawValueOptions = function() {
        var currentOp, fs, _ref1;

        this.$('.im-value-options').remove();
        fs = this.$('.im-constraint-options');
        currentOp = this.con.get('op');
        if (!currentOp && this.con.has('type')) {
          this.drawTypeOpts(fs);
        } else if ((_ref1 = this.path.getType(), __indexOf.call(intermine.Model.BOOLEAN_TYPES, _ref1) >= 0) && !(__indexOf.call(intermine.Query.NULL_OPS, currentOp) >= 0)) {
          this.drawBooleanOpts(fs);
        } else if (__indexOf.call(intermine.Query.MULTIVALUE_OPS, currentOp) >= 0) {
          this.drawMultiValueOps(fs);
        } else if (__indexOf.call(intermine.Query.LIST_OPS, currentOp) >= 0) {
          this.drawListOptions(fs);
        } else if (this.path.isReference() && (currentOp === '=' || currentOp === '!=')) {
          this.drawLoopOpts(fs);
        } else if (!(__indexOf.call(intermine.Query.NULL_OPS, currentOp) >= 0)) {
          this.drawAttributeOpts(fs);
        }
        if (__indexOf.call(intermine.Query.TERNARY_OPS, currentOp) >= 0) {
          return this.drawExtraOpts(fs);
        }
      };

      return ActiveConstraint;

    })(Backbone.View);
    NewConstraint = (function(_super) {
      __extends(NewConstraint, _super);

      function NewConstraint() {
        _ref1 = NewConstraint.__super__.constructor.apply(this, arguments);
        return _ref1;
      }

      NewConstraint.prototype.initialize = function(q, c) {
        NewConstraint.__super__.initialize.call(this, q, c);
        this.$el.addClass("new");
        this.buttons[0].text = "Apply";
        return this.con.set({
          op: (this.path.isReference() ? 'LOOKUP' : '=')
        });
      };

      NewConstraint.prototype.addIcons = function() {};

      NewConstraint.prototype.valueChanged = function(value) {
        return this.fillConSummaryLabel(_.extend({}, this.con, {
          value: "" + value
        }));
      };

      NewConstraint.prototype.opChanged = function(op) {
        return this.$('.label-op').text(op);
      };

      NewConstraint.prototype.removeConstraint = function() {};

      NewConstraint.prototype.hideEditForm = function(e) {
        NewConstraint.__super__.hideEditForm.call(this, e);
        this.query.trigger("cancel:add-constraint");
        return this.remove();
      };

      return NewConstraint;

    })(ActiveConstraint);
    return scope("intermine.query", {
      ActiveConstraint: ActiveConstraint,
      NewConstraint: NewConstraint
    });
  })();

  (function() {
    var DownloadDialogue;

    DownloadDialogue = function() {
      return "<div class=\"modal-header\">\n  <a  class=\"close im-closer\" data-dismiss=\"modal\">close</a>\n  <h2>\n    " + intermine.messages.actions.ExportTitle + "\n  </h2>\n</div>\n\n<div class=\"modal-body tab-content\">\n <div class=\"carousel slide\">\n  <div class=\"carousel-inner\">\n  <div class=\"active item\">\n\n   <div class=\"tabbable tabs-left\">\n     <ul class=\"nav nav-tabs\">\n       <li class=\"active\">\n         <a  class=\"im-export-format\">format</a>\n       </li>\n       <li>\n         <a  class=\"im-export-columns\">columns</a>\n       </li>\n       <li>\n         <a  class=\"im-export-rows\">Rows</a>\n       </li>\n       <li>\n         <a  class=\"im-export-output\">Output</a>\n       </li>\n       <li>\n         <a  class=\"im-export-destination\">\n          Destination: <span class=\"im-current\"></span>\n         </a>\n       </li>\n       <div class=\"alert alert-info\">\n         <p>\n          <i class=\"icon-info-sign\"></i>\n          " + intermine.messages.actions.ConfigureExportHelp + "\n         </p>\n       </div>\n     </ul>\n     <div class=\"tab-content\">\n       <div class=\"tab-pane active im-export-format\">\n          <h2>\n            " + intermine.messages.actions.ExportFormat + "\n          </h2>\n         <div class=\"im-export-formats\" data-toggle=\"buttons-radio\">\n         </div>\n       </div>\n       <div class=\"tab-pane im-export-columns\">\n           <button class=\"im-reset-cols btn disabled pull-right\">\n             <i class=\"" + intermine.icons.Undo + "\"></i>\n             " + intermine.messages.actions.ResetColumns + "\n           </button>\n          <h2>\n            " + intermine.messages.actions.WhichColumns + "\n          </h2>\n          <div class=\"im-col-options\">\n            <div class=\"well\">\n              <ul class=\"im-cols im-exported-cols nav nav-tabs nav-stacked\"></ul>\n            </div>\n            <h4>" + intermine.messages.actions.PossibleColumns + "</h4>\n            <div class=\"im-can-be-exported-cols\">\n            </div>\n            <div style=\"clear:both;\"></div>\n          </div>\n          <div class=\"im-col-options-bio\">\n          </div>\n       </div>\n       <div class=\"tab-pane im-export-rows\">\n         <h2>\n          " + intermine.messages.actions.WhichRows + "\n         </h2>\n          <div class=\"form-horizontal\">\n            <fieldset class=\"im-row-selection control-group\">\n              <label class=\"control-label\">\n                " + intermine.messages.actions.FirstRow + "\n                <input type=\"text\" value=\"1\"\n                        class=\"disabled input-mini im-first-row im-range-limit\">\n              </label>\n              <label class=\"control-label\">\n                " + intermine.messages.actions.LastRow + "\n                <input type=\"text\"\n                        class=\"disabled input-mini im-last-row im-range-limit\">\n              </label>\n              <div style=\"clear:both\"></div>\n              <div class=\"slider im-row-range-slider\"></div>\n            </fieldset>\n          </div>\n       </div>\n       <div class=\"tab-pane im-export-output\">\n          <label>\n            " + intermine.messages.actions.CompressResults + "\n          </label>\n          <div class=\"span11 im-compression-opts radio btn-group pull-right\"\n                data-toggle=\"buttons-radio\">\n            <button class=\"btn active im-no-compression span7\">\n              " + intermine.messages.actions.NoCompression + "\n            </button>\n            <button class=\"btn im-gzip-compression span2\">\n              " + intermine.messages.actions.GZIPCompression + "\n            </button>\n            <button class=\"btn im-zip-compression span2\">\n              " + intermine.messages.actions.ZIPCompression + "\n            </button>\n          </div>\n          <div style=\"clear:both\"></div>\n          <div class=\"im-output-options\">\n          </div>\n       </div>\n       <div class=\"tab-pane im-export-destination\">\n      <ul class=\"im-export-destinations nav nav-pills\">\n        <li class=\"active\">\n          <a  data-destination=\"download-file\">\n            <i class=\"" + intermine.icons.Download + "\"></i>\n            " + intermine.messages.actions.ExportLong + "\n          </a>\n        </li>\n      </ul>\n        <div class=\"row-fluid im-export-destination-options\">\n\n          <div class=\"im-download-file active\">\n            <div class=\"btn-group im-what-to-show\">\n              <button class=\"im-results-uri btn active\">\n                " + intermine.messages.actions.ResultsPermaLinkText + ":\n              </button>\n              <button class=\"im-query-xml btn\">\n                " + intermine.messages.actions.QueryXML + "\n              </button>\n            </div>\n            <span class=\"im-copy\">\n              <i class=\"icon " + intermine.icons.ClipBoard + "\"></i>\n              " + intermine.messages.actions.Copy + "\n            </span>\n\n            <div class=\"well im-perma-link-content active\"></div>\n            <div class=\"well im-query-xml\"></div>\n\n            <div class=\"alert alert-block im-private-query\">\n              <button type=\"button\" class=\"close im-closer\" data-dismiss=\"alert\">×</button>\n              <h4>nb:</h4>\n              " + intermine.messages.actions.IsPrivateData + "\n            </div>\n\n            <div class=\"alert alert-block alert-info im-long-uri\">\n              <button type=\"button\" class=\"close im-closer\" data-dismiss=\"alert\">×</button>\n              <h4>nb:</h4>\n              " + intermine.messages.actions.LongURI + "\n            </div>\n\n\n          </div>\n\n        </div>\n       </div>\n     </div>\n   </div>\n  \n  </div> <!-- End item -->\n  \n  <div class=\"item\">\n    <iframe class=\"gs-frame\" width=\"0\" height=\"0\" frameborder=\"0\"\n      id=\"im-to-gs-" + (new Date().getTime()) + "\">\n    </iframe>\n  </div>\n\n  </div> <!-- end inner -->\n  </div> <!-- end carousel -->\n\n</div>\n\n<!--\n-->\n\n<div class=\"modal-footer\">\n  <a  class=\"btn btn-primary im-download pull-right\">\n    <i class=\"icon " + intermine.icons.Export + "\"></i>\n    " + intermine.messages.actions.Export + "\n  </a>\n  <button class=\"btn btn-cancel pull-left im-cancel\">\n    " + intermine.messages.actions.Cancel + "\n  </button>\n</div>";
    };
    return scope('intermine.snippets.actions', {
      DownloadDialogue: DownloadDialogue
    });
  })();

  (function() {
    var DropDownColumnSummary, OuterJoinDropDown, SummaryHeading, _ref, _ref1, _ref2;

    OuterJoinDropDown = (function(_super) {
      __extends(OuterJoinDropDown, _super);

      function OuterJoinDropDown() {
        _ref = OuterJoinDropDown.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      OuterJoinDropDown.prototype.className = "im-summary-selector no-margins";

      OuterJoinDropDown.prototype.tagName = 'ul';

      OuterJoinDropDown.prototype.initialize = function(query, path, model) {
        var _ref1;

        this.query = query;
        this.path = path;
        return _ref1 = model.toJSON(), this.replaces = _ref1.replaces, this.isFormatted = _ref1.isFormatted, _ref1;
      };

      OuterJoinDropDown.prototype.getSubpaths = function() {
        return this.replaces.slice();
      };

      OuterJoinDropDown.prototype.render = function() {
        var node, v, vs, _fn, _i, _len,
          _this = this;

        vs = [];
        node = this.path;
        vs = this.getSubpaths();
        if (vs.length === 1) {
          this.showPathSummary(vs[0]);
        } else {
          _fn = function(v) {
            var li;

            li = $("<li class=\"im-subpath im-outer-joined-path\"><a href=\"#\"></a></li>");
            _this.$el.append(li);
            $.when(node.getDisplayName(), _this.query.getPathInfo(v).getDisplayName()).done(function(parent, name) {
              return li.find('a').text(name.replace(parent, '').replace(/^\s*>\s*/, ''));
            });
            return li.click(function(e) {
              e.stopPropagation();
              e.preventDefault();
              return _this.showPathSummary(v);
            });
          };
          for (_i = 0, _len = vs.length; _i < _len; _i++) {
            v = vs[_i];
            _fn(v);
          }
        }
        return this;
      };

      OuterJoinDropDown.prototype.showPathSummary = function(v) {
        var summ;

        summ = new intermine.query.results.DropDownColumnSummary(this.query, v);
        this.$el.parent().html(summ.render().el);
        this.summ = summ;
        return this.$el.remove();
      };

      OuterJoinDropDown.prototype.remove = function() {
        var _ref1;

        if ((_ref1 = this.summ) != null) {
          _ref1.remove();
        }
        return OuterJoinDropDown.__super__.remove.call(this);
      };

      return OuterJoinDropDown;

    })(Backbone.View);
    DropDownColumnSummary = (function(_super) {
      __extends(DropDownColumnSummary, _super);

      function DropDownColumnSummary() {
        _ref1 = DropDownColumnSummary.__super__.constructor.apply(this, arguments);
        return _ref1;
      }

      DropDownColumnSummary.prototype.className = "im-dropdown-summary";

      DropDownColumnSummary.prototype.initialize = function(query, view) {
        this.query = query;
        this.view = view;
      };

      DropDownColumnSummary.prototype.remove = function() {
        var _ref2, _ref3;

        if ((_ref2 = this.heading) != null) {
          _ref2.remove();
        }
        if ((_ref3 = this.summ) != null) {
          _ref3.remove();
        }
        return DropDownColumnSummary.__super__.remove.call(this);
      };

      DropDownColumnSummary.prototype.render = function() {
        var heading;

        heading = new SummaryHeading(this.query, this.view);
        heading.render().$el.appendTo(this.el);
        this.heading = heading;
        this.summ = new intermine.results.ColumnSummary(this.query, this.view);
        this.summ.noTitle = true;
        this.summ.render().$el.appendTo(this.el);
        return this;
      };

      return DropDownColumnSummary;

    })(Backbone.View);
    SummaryHeading = (function(_super) {
      var nts;

      __extends(SummaryHeading, _super);

      function SummaryHeading() {
        _ref2 = SummaryHeading.__super__.constructor.apply(this, arguments);
        return _ref2;
      }

      nts = function(num) {
        return intermine.utils.numToString(num, ',', 3);
      };

      SummaryHeading.prototype.initialize = function(query, view) {
        var _this = this;

        this.query = query;
        this.view = view;
        return this.query.on("got:summary:total", function(path, total, got, filteredTotal) {
          var available;

          if (path === _this.view) {
            available = filteredTotal != null ? filteredTotal : total;
            _this.$('.im-item-available').text(nts(available));
            _this.$('.im-item-total').text(filteredTotal != null ? "(filtered from " + (nts(total)) + ")" : "");
            if (available > got) {
              return _this.$('.im-item-got').text("Showing " + (nts(got)) + " of ");
            } else {
              return _this.$('.im-item-got').text('');
            }
          }
        });
      };

      SummaryHeading.prototype.template = _.template("<h3>\n    <span class=\"im-item-got\"></span>\n    <span class=\"im-item-available\"></span>\n    <span class=\"im-type-name\"></span>\n    <span class=\"im-attr-name\"></span>\n    <span class=\"im-item-total\"></span>\n</h3>");

      SummaryHeading.prototype.render = function() {
        var attr, s, type,
          _this = this;

        this.$el.append(this.template());
        s = this.query.service;
        type = this.query.getPathInfo(this.view).getParent().getType().name;
        attr = this.query.getPathInfo(this.view).end.name;
        s.get("model/" + type).then(function(info) {
          return _this.$('.im-type-name').text(info.name);
        });
        s.get("model/" + type + "/" + attr).then(function(info) {
          return _this.$('.im-attr-name').text(intermine.utils.pluralise(info.name));
        });
        return this;
      };

      return SummaryHeading;

    })(Backbone.View);
    return scope("intermine.query.results", {
      OuterJoinDropDown: OuterJoinDropDown,
      DropDownColumnSummary: DropDownColumnSummary
    });
  })();

  (function() {
    var DynamicPopover;

    DynamicPopover = (function(_super) {
      __extends(DynamicPopover, _super);

      function DynamicPopover(elem, opts) {
        this.init('popover', elem, opts);
        $(elem).data('popover', this);
        if (opts != null ? opts.classes : void 0) {
          this.tip().addClass(opts.classes);
        }
      }

      DynamicPopover.prototype.hasContent = function() {
        return true;
      };

      DynamicPopover.prototype.getPlacement = function() {
        if (typeof this.options.placement === 'function') {
          return this.options.placement.call(this, this.tip()[0], this.$element[0]);
        } else {
          return this.options.placement;
        }
      };

      DynamicPopover.prototype.respectContainment = function(offset, pos, placement) {
        var $containment, $tip, actualHeight, actualWidth, arrowHeight, arrowOffset, arrowWidth, bottom, diff, height, left, top, _ref;

        $tip = this.tip();
        arrowOffset = {};
        actualWidth = $tip[0].offsetWidth;
        actualHeight = $tip[0].offsetHeight;
        $containment = this.$element.closest(this.options.containment);
        _ref = $containment.offset(), top = _ref.top, left = _ref.left;
        height = $containment[0].offsetHeight;
        bottom = top + height;
        arrowHeight = $tip.find('.arrow')[0].offsetHeight;
        arrowWidth = $tip.find('.arrow')[0].offsetWidth;
        if (actualHeight >= height) {
          $tip.find('.arrow').css({
            top: '',
            left: ''
          });
          return;
        }
        if (placement === 'right' || placement === 'left') {
          if (offset.top < top) {
            diff = top - offset.top;
            offset.top += diff;
            arrowOffset.top = offset.top + (pos.top - offset.top) + (pos.height / 2) - (arrowHeight / 2);
          } else if (offset.top + actualHeight > bottom) {
            diff = offset.top + actualHeight - bottom;
            offset.top -= diff;
            arrowOffset.top = offset.top + (pos.top - offset.top) + (pos.height / 2) - (arrowHeight / 2);
          }
        } else {
          if (offset.left < left) {
            diff = left - offset.left;
            offset.left += diff;
            arrowOffset.left = pos.left + (pos.width / 2) - (arrowWidth / 2);
          }
        }
        if (placement === 'right') {
          offset.left += arrowWidth;
        } else if (placement === 'top') {
          offset.top -= arrowHeight;
        } else if (placement === 'left') {
          offset.left -= arrowWidth;
        }
        $tip.offset(offset);
        return $tip.find('.arrow').offset(arrowOffset);
      };

      DynamicPopover.prototype.applyPlacement = function(offset, placement) {
        var $tip;

        $tip = this.tip();
        $tip.removeClass('left right top bottom');
        return DynamicPopover.__super__.applyPlacement.call(this, offset, placement);
      };

      DynamicPopover.prototype.reposition = function() {
        var $tip, actualHeight, actualWidth, placement, pos, tp;

        pos = this.getPosition();
        $tip = this.tip();
        actualWidth = $tip[0].offsetWidth;
        actualHeight = $tip[0].offsetHeight;
        placement = this.getPlacement();
        tp = (function() {
          switch (placement) {
            case 'bottom':
              return {
                top: pos.top + pos.height,
                left: pos.left + pos.width / 2 - actualWidth / 2
              };
            case 'top':
              return {
                top: pos.top - actualHeight,
                left: pos.left + pos.width / 2 - actualWidth / 2
              };
            case 'left':
              return {
                top: pos.top + pos.height / 2 - actualHeight / 2,
                left: pos.left - actualWidth
              };
            case 'right':
              return {
                top: pos.top + pos.height / 2 - actualHeight / 2,
                left: pos.left + pos.width
              };
          }
        })();
        this.applyPlacement(tp, placement);
        if (this.options.containment != null) {
          this.respectContainment(tp, pos, placement);
        }
        return this.$element.trigger('repositioned');
      };

      return DynamicPopover;

    })(jQuery.fn.popover.Constructor);
    return scope('intermine.bootstrap', {
      DynamicPopover: DynamicPopover
    });
  })();

  (function() {
    var ExportColumnHeader, NAME_TEMPLATE, TEMPLATE, moveRight, shift, _ref;

    TEMPLATE = "<div>\n  <div class=\"pull-right im-promoters\">\n    <i class=\"" + intermine.icons.MoveUp + " im-promote\"></i>\n    <i class=\"" + intermine.icons.MoveDown + " im-demote\"></i>\n  </div>\n  <i class=\"" + intermine.icons.Check + " im-exclude\"></i>\n  <span class=\"im-path\"></span>\n</div>";
    NAME_TEMPLATE = _.template("<span class=\"im-name-part\"><%- part %></span>");
    moveRight = function(xs, i) {
      return xs.splice(i, 2, xs[i + 1], xs[i]);
    };
    shift = function(model, toLeft) {
      var idx, models;

      models = model.collection.models;
      idx = models.indexOf(model);
      moveRight(models, toLeft ? idx - 1 : idx);
      return model.collection.trigger('reset');
    };
    ExportColumnHeader = (function(_super) {
      __extends(ExportColumnHeader, _super);

      function ExportColumnHeader() {
        _ref = ExportColumnHeader.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      ExportColumnHeader.prototype.tagName = 'li';

      ExportColumnHeader.prototype.className = 'im-exported-col im-view-element';

      ExportColumnHeader.prototype.template = function() {
        return TEMPLATE;
      };

      ExportColumnHeader.prototype.events = {
        "click .im-promote": "promote",
        "click .im-demote": "demote",
        "click .im-exclude": "toggle",
        "click .im-path": "toggle"
      };

      ExportColumnHeader.prototype.promote = function(e) {
        var toLeft;

        if (!$(e.target).is('.disabled')) {
          return shift(this.model, toLeft = true);
        }
      };

      ExportColumnHeader.prototype.demote = function(e) {
        var toLeft;

        if (!$(e.target).is('.disabled')) {
          return shift(this.model, toLeft = false);
        }
      };

      ExportColumnHeader.prototype.toggle = function() {
        return this.model.set({
          excluded: !this.model.get('excluded')
        });
      };

      ExportColumnHeader.prototype.initialize = function() {
        if (!this.model.has('excluded')) {
          this.model.set({
            excluded: false
          });
        }
        this.$el.data({
          model: this.model
        });
        this.on('rendered', this.displayName, this);
        this.on('rendered', this.onChangeExclusion, this);
        this.on('rendered', this.checkShifters, this);
        return this.model.on('change:excluded', this.onChangeExclusion, this);
      };

      ExportColumnHeader.prototype.checkShifters = function() {
        var idx;

        idx = this.model.collection.models.indexOf(this.model);
        this.$('.im-promote').toggleClass('disabled', idx === 0);
        return this.$('.im-demote').toggleClass('disabled', idx + 1 === this.model.collection.length);
      };

      ExportColumnHeader.prototype.onChangeExclusion = function() {
        var excl;

        excl = this.model.get('excluded');
        this.$('.im-exclude').toggleClass(intermine.icons.Check, !excl).toggleClass(intermine.icons.UnCheck, excl);
        return this.$el.toggleClass('im-excluded', excl);
      };

      ExportColumnHeader.prototype.displayName = function() {
        var _this = this;

        return this.model.get('path').getDisplayName().done(function(dname) {
          var $path, part, parts, _i, _len, _results;

          parts = dname.split(' > ');
          $path = _this.$('.im-path');
          _results = [];
          for (_i = 0, _len = parts.length; _i < _len; _i++) {
            part = parts[_i];
            _results.push($path.append(NAME_TEMPLATE({
              part: part
            })));
          }
          return _results;
        });
      };

      return ExportColumnHeader;

    })(intermine.views.ItemView);
    return scope('intermine.columns.views', {
      ExportColumnHeader: ExportColumnHeader
    });
  })();

  (function() {
    var ExportColumnOptions, NODE_HTML, SelectableNode, namePart, _ref, _ref1;

    NODE_HTML = _.template("<div>\n  <i class=\"<%= icon %>\"></i>\n  <span class=\"im-display-name\"></span>\n</div>");
    namePart = _.template("<span class=\"im-name-part\"><%- part %></span>");
    SelectableNode = (function(_super) {
      __extends(SelectableNode, _super);

      function SelectableNode() {
        this.render = __bind(this.render, this);        _ref = SelectableNode.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      SelectableNode.prototype.tagName = 'li';

      SelectableNode.prototype.className = 'im-selectable-node im-view-element';

      SelectableNode.prototype.initialize = function() {
        this.model.on('change:included', this.render);
        return this.model.on('destroy', this.remove, this);
      };

      SelectableNode.prototype.events = {
        'click': 'toggleIncluded'
      };

      SelectableNode.prototype.toggleIncluded = function() {
        return this.model.set({
          included: !this.model.get('included')
        });
      };

      SelectableNode.prototype.render = function() {
        var Check, UnCheck, icon, included, path, _ref1, _ref2,
          _this = this;

        _ref1 = this.model.toJSON(), path = _ref1.path, included = _ref1.included;
        _ref2 = intermine.icons, Check = _ref2.Check, UnCheck = _ref2.UnCheck;
        icon = included ? Check : UnCheck;
        this.$el.html(NODE_HTML({
          icon: icon
        }));
        this.$el.toggleClass('included', included);
        path.getDisplayName(function(name) {
          var $name, part, parts, _i, _len, _results;

          parts = name.split(' > ');
          $name = _this.$('.im-display-name').empty();
          _results = [];
          for (_i = 0, _len = parts.length; _i < _len; _i++) {
            part = parts[_i];
            _results.push($name.append(namePart({
              part: part
            })));
          }
          return _results;
        });
        return this;
      };

      return SelectableNode;

    })(Backbone.View);
    ExportColumnOptions = (function(_super) {
      var COUNT_INCLUDED, TEMPLATE;

      __extends(ExportColumnOptions, _super);

      function ExportColumnOptions() {
        this.update = __bind(this.update, this);
        this.insert = __bind(this.insert, this);        _ref1 = ExportColumnOptions.__super__.constructor.apply(this, arguments);
        return _ref1;
      }

      ExportColumnOptions.prototype.tagName = 'label';

      ExportColumnOptions.prototype.className = 'export-column-options';

      TEMPLATE = function(ctx) {
        return _.template("<div class=\"control-label\">\n  <%= message %>\n  <span class=\"im-selected-count\">0</span> selected.\n  <div class=\"btn im-clear disabled\">\n    " + intermine.messages.actions.Clear + "\n  </div>\n</div>\n<div class=\"well\">\n  <ul class=\"im-export-paths nav nav-tabs nav-stacked\"></ul>\n</div>", ctx);
      };

      COUNT_INCLUDED = function(sum, m) {
        if (m.get('included')) {
          return ++sum;
        } else {
          return sum;
        }
      };

      ExportColumnOptions.prototype.initialize = function(options) {
        var col, _ref2;

        this.options = options;
        this.paths = col = (function() {
          if ((_ref2 = this.collection) != null) {
            return _ref2;
          } else {
            throw new Error('collection required');
          }
        }).call(this);
        this.listenTo(col, 'change:included', this.update);
        this.listenTo(col, 'add', this.insert);
        this.listenTo(col, 'add', this.update);
        return this.listenTo(col, 'close', this.remove, this);
      };

      ExportColumnOptions.prototype.insert = function(m) {
        return this.$('.im-export-paths').append(new SelectableNode({
          model: m
        }).render().el);
      };

      ExportColumnOptions.prototype.events = {
        'click .im-clear': 'clear',
        'click .im-collapser': 'toggle'
      };

      ExportColumnOptions.prototype.clear = function() {
        return this.paths.each(function(m) {
          return m.set({
            included: false
          });
        });
      };

      ExportColumnOptions.prototype.toggle = function() {
        this.$('.im-export-paths').slideToggle();
        this.$('.im-left-col').toggleClass('span4 span10');
        return this.$('.im-collapser').toggleClass(intermine.icons.ExpandCollapse);
      };

      ExportColumnOptions.prototype.update = function() {
        var c;

        c = this.paths.reduce(COUNT_INCLUDED, 0);
        this.$('.im-selected-count').text(c);
        this.$('.im-clear').toggleClass('disabled', c < 1);
        return this.$el.toggleClass('error', !this.isValidCount(c));
      };

      ExportColumnOptions.prototype.isValidCount = function() {
        return true;
      };

      ExportColumnOptions.prototype.render = function() {
        var m, _i, _len, _ref2;

        this.$el.append(TEMPLATE({
          message: this.options.message
        }));
        if (this.paths.isEmpty()) {
          this.$('.im-export-paths').append("<li>\n  <span class=\"label label-important\">\n  " + intermine.messages.actions.NoSuitableColumns + "\n  </span>\n</li>");
        } else {
          _ref2 = this.paths.models;
          for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
            m = _ref2[_i];
            this.insert(m);
          }
        }
        this.paths.trigger('change:included');
        return this;
      };

      return ExportColumnOptions;

    })(Backbone.View);
    return scope('intermine.actions', {
      ExportColumnOptions: ExportColumnOptions
    });
  })();

  define('export/dialogue', using('perma-query', function(getPermaQuery) {
    var BIO_FORMATS, DELENDA, ENTER, EXPORT_FORMATS, ExportDialogue, SPACE, Tab, anyAny, anyNodeIsSuitable, defer, featuresToPaths, formatByExtension, idAttr, isImplicitlyConstrained, isIncluded, isntExcluded, toPath, _ref;

    defer = function(x) {
      return new jQuery.Deferred(function() {
        return this.resolve(x);
      });
    };
    EXPORT_FORMATS = [
      {
        name: "Spreadsheet (tab separated values)",
        extension: "tsv",
        param: "tab"
      }, {
        name: "Spreadsheet (comma separated values)",
        extension: "csv"
      }, {
        name: "XML",
        extension: "xml"
      }, {
        name: "JSON",
        extension: "json"
      }
    ];
    BIO_FORMATS = [
      {
        name: "GFF3 (General Feature Format)",
        extension: "gff3",
        types: ["SequenceFeature"]
      }, {
        name: "UCSC-BED (Browser Extensible Display Format)",
        extension: "bed",
        types: ["SequenceFeature"]
      }, {
        name: "FASTA sequence",
        extension: "fasta",
        types: ["SequenceFeature", "Protein"]
      }
    ];
    DELENDA = ['requestInfo', 'state', 'exportedCols', 'possibleColumns', 'seqFeatures', 'fastaFeatures', 'extraAttributes'];
    ENTER = 13;
    SPACE = 32;
    formatByExtension = function(ext) {
      return _.find(EXPORT_FORMATS.concat(BIO_FORMATS), function(f) {
        return f.extension === ext;
      });
    };
    toPath = function(col) {
      return col.get('path');
    };
    idAttr = function(path) {
      return path.append('id');
    };
    isIncluded = function(col) {
      return col.get('included');
    };
    isntExcluded = function(col) {
      return !col.get('excluded');
    };
    featuresToPaths = function(features) {
      return features.filter(isIncluded).map(_.compose(idAttr, toPath));
    };
    isImplicitlyConstrained = function(q, node) {
      var c, n, v, _i, _j, _len, _len1, _ref, _ref1;

      if (q.isInView(node)) {
        return true;
      }
      n = node.toString();
      _ref = q.views;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        v = _ref[_i];
        if (0 === v.indexOf(n)) {
          return true;
        }
      }
      _ref1 = q.constraints;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        c = _ref1[_j];
        if (c.op && 0 === c.path.indexOf(n)) {
          return true;
        }
      }
      return false;
    };
    anyAny = function(xs, ys, f) {
      return _.any(xs, function(x) {
        return _.any(ys, function(y) {
          return f(x, y);
        });
      });
    };
    anyNodeIsSuitable = function(model, nodes) {
      return function(types) {
        return anyAny(types, nodes, function(t, n) {
          var _ref;

          return _ref = n.name, __indexOf.call(model.getSubclassesOf(t), _ref) >= 0;
        });
      };
    };
    Tab = intermine.bootstrap.Tab;
    ExportDialogue = (function(_super) {
      var formatToEl, ignore, switchActive;

      __extends(ExportDialogue, _super);

      function ExportDialogue() {
        this.initCols = __bind(this.initCols, this);
        this.onChangeDest = __bind(this.onChangeDest, this);
        this.onChangePermalink = __bind(this.onChangePermalink, this);
        this.onChangePermaquery = __bind(this.onChangePermaquery, this);
        this.onChangeURL = __bind(this.onChangeURL, this);
        this.onChangePrivacy = __bind(this.onChangePrivacy, this);
        this.buildPermaLink = __bind(this.buildPermaLink, this);        _ref = ExportDialogue.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      ExportDialogue.prototype.tagName = 'div';

      ExportDialogue.prototype.className = "modal im-export-dialogue";

      ExportDialogue.prototype.initialize = function(query) {
        var col, enabled, name, _fn, _i, _len, _ref1, _ref2, _ref3,
          _this = this;

        this.query = query.clone();
        this.service = query.service;
        this.dummyParams = ['allRows', 'allCols', 'end', 'columnHeaders'];
        this.qids = {};
        this.requestInfo = new Backbone.Model({
          format: EXPORT_FORMATS[0],
          allRows: true,
          allCols: true,
          start: 0,
          compress: "no",
          columnHeaders: true
        });
        _ref1 = intermine.options.ExternalExportDestinations;
        for (name in _ref1) {
          enabled = _ref1[name];
          if (enabled) {
            if ((_ref2 = intermine["export"].external[name].init) != null) {
              _ref2.call(this);
            }
          }
        }
        this.state = new Backbone.Model({
          destination: 'download-file'
        });
        this.state.on('change:isPrivate', this.onChangePrivacy);
        this.state.on('change:url', this.onChangeURL);
        this.state.on('change:destination', this.onChangeDest);
        this.state.on('change:permalink', this.onChangePermalink);
        this.state.on('change:permaquery', this.onChangePermaquery);
        this.service.fetchVersion(function(v) {
          if (v < 12) {
            return _this.$('.im-ws-v12').remove();
          }
        });
        this.exportedCols = new Backbone.Collection;
        this.resetExportedColumns();
        this.seqFeatures = new intermine.models.ClosableCollection;
        this.fastaFeatures = new intermine.models.ClosableCollection;
        this.extraAttributes = new intermine.models.ClosableCollection;
        _ref3 = [this.seqFeatures, this.fastaFeatures];
        _fn = function(col) {
          return col.on('change:included', function() {
            return _this.onChangeIncludedNodes(col);
          });
        };
        for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
          col = _ref3[_i];
          _fn(col);
        }
        this.fastaFeatures.on('change:included', function(originator, incl) {
          var f;

          f = function(m) {
            if (m !== originator) {
              return m.set({
                included: false
              });
            }
          };
          if (incl) {
            return _this.fastaFeatures.each(f);
          }
        });
        this.fastaFeatures.on('change:included', function(col, incl) {
          var canHaveExt, inp;

          canHaveExt = incl && col.get('path').isa('SequenceFeature');
          inp = _this.$('input.im-fasta-extension').attr({
            disabled: !canHaveExt
          });
          if (canHaveExt) {
            return _this.requestInfo.set({
              extension: inp.val()
            });
          } else {
            return _this.requestInfo.unset('extension');
          }
        });
        this.extraAttributes.on('change:included', function() {
          var extras;

          extras = _this.extraAttributes.where({
            included: true
          });
          return _this.requestInfo.set({
            view: extras.map(toPath).map(String)
          });
        });
        this.requestInfo.on('change', this.buildPermaLink);
        this.requestInfo.on('change:format', this.onChangeFormat, this);
        this.requestInfo.on('change:format', this.updateColTabText, this);
        this.requestInfo.on('change:format', this.updateFormatOptions, this);
        this.requestInfo.on('change:start', function(m, start) {
          var $elem, newVal, _ref4;

          $elem = _this.$('.im-first-row');
          newVal = "" + (start + 1);
          if (newVal !== $elem.val()) {
            $elem.val(newVal);
          }
          return (_ref4 = _this.$slider) != null ? _ref4.slider('option', 'values', [start, m.get('end') - 1]) : void 0;
        });
        this.requestInfo.on('change:end', function(m, end) {
          var $elem, newVal, _ref4;

          $elem = _this.$('.im-last-row');
          newVal = "" + end;
          if (newVal !== $elem.val()) {
            $elem.val(newVal);
          }
          return (_ref4 = _this.$slider) != null ? _ref4.slider('option', 'values', [m.get('start'), end - 1]) : void 0;
        });
        this.requestInfo.on("change:format", function(m, format) {
          return _this.$('.im-export-format').val(format);
        });
        this.exportedCols.on('add remove reset', this.initCols);
        this.exportedCols.on('add remove change:excluded', this.updateColTabText, this);
        this.exportedCols.on('add remove reset change:excluded', this.buildPermaLink);
        return this.requestInfo.on('change:start change:end', function() {
          var end, start, text, _ref4;

          _ref4 = _this.requestInfo.toJSON(), start = _ref4.start, end = _ref4.end;
          text = start === 0 && ((!end) || (_this.count && end === _this.count)) ? "All rows" : "" + (end - start) + " rows";
          return _this.$('.nav-tabs .im-export-rows').text(text);
        });
      };

      ExportDialogue.prototype.updateColTabText = function() {
        var n;

        n = this.exportedCols.filter(function(c) {
          return !c.get('excluded');
        }).length;
        return this.$('.nav-tabs .im-export-columns').text("" + n + " columns");
      };

      ExportDialogue.prototype.onChangeIncludedNodes = function(coll) {
        var n;

        n = coll.reduce((function(n, m) {
          return n + (m.get('included') ? 1 : 0);
        }), 0);
        this.$('.nav-tabs .im-export-columns').text("" + n + " nodes");
        return this.buildPermaLink();
      };

      ExportDialogue.prototype.onChangeFormat = function() {
        var format, tab;

        format = this.requestInfo.get('format');
        tab = this.$('.nav-tabs .im-export-format');
        tab.text("Format: " + format.extension);
        this.$('.im-export-formats input').val([format.extension]);
        return this.$('.im-format-choice').each(function() {
          var inp;

          inp = $('input', this);
          return $(this).toggleClass('active', inp.attr('value') === format.extension);
        });
      };

      ExportDialogue.prototype.resetExportedColumns = function(e) {
        var q;

        if (e != null) {
          e.stopPropagation();
        }
        if (e != null) {
          e.preventDefault();
        }
        this.$('.im-reset-cols').addClass('disabled');
        q = this.query;
        return this.exportedCols.reset(q.views.map(function(v) {
          return {
            path: q.getPathInfo(v)
          };
        }));
      };

      ExportDialogue.prototype.readColumnHeaders = function(e) {
        return this.requestInfo.set({
          columnHeaders: $(e.target).is(':checked')
        });
      };

      ExportDialogue.prototype.readBedChrPrefix = function(e) {
        return this.requestInfo.set({
          useChrPrefix: $(e.target).is(':checked')
        });
      };

      ExportDialogue.prototype.events = function() {
        var enabled, events, format, moreEvents, name, val, x, _fn, _fn1, _fn2, _i, _j, _k, _len, _len1, _len2, _ref1, _ref2, _ref3, _ref4, _ref5,
          _this = this;

        events = {
          'click .im-reset-cols': 'resetExportedColumns',
          'click .im-col-btns': 'toggleColSelection',
          'click .im-row-btns': 'toggleRowSelection',
          'click .close': 'stop',
          'click .im-cancel': 'stop',
          'click a.im-download': 'export',
          'change .im-first-row': 'changeStart',
          'change .im-last-row': 'changeEnd',
          'keyup .im-range-limit': 'keyPressOnLimit',
          'submit form': 'dontReallySubmitForm',
          'click .im-perma-link': 'buildPermaLink',
          'click .im-perma-link-share': 'buildSharableLink',
          'click .im-download-file .im-collapser': 'toggleLinkViewer',
          'click .im-download-file .im-copy': 'copyUriToClipboard',
          'click .im-export-destinations > li > a': 'moveToSection',
          'hidden': 'modalHidden',
          'change .im-column-headers': 'readColumnHeaders',
          'change .im-bed-chr-prefix': 'readBedChrPrefix',
          'change .im-fasta-extension': 'readFastaExt',
          'click .im-download-file .im-what-to-show button': 'switchWhatToShow',
          'keyup .im-format-choice': function(e) {
            var input, key;

            input = $(e.target).find('input');
            key = e != null ? e.which : void 0;
            if (key === ENTER || key === SPACE) {
              input.attr({
                checked: true
              });
              return _this.requestInfo.set({
                format: formatByExtension(input.val())
              });
            }
          }
        };
        _ref1 = EXPORT_FORMATS.concat(BIO_FORMATS);
        _fn = function(format) {
          var cb, key;

          key = "click .im-format-" + format.extension;
          cb = function() {
            return _this.requestInfo.set({
              format: format
            });
          };
          return events[key] = cb;
        };
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          format = _ref1[_i];
          _fn(format);
        }
        _ref2 = ['format', 'columns', 'rows', 'output', 'destination'];
        _fn1 = function(x) {
          var cb, key;

          key = "click .nav-tabs .im-export-" + x;
          cb = function(e) {
            var $a;

            $a = $(e.target);
            if ($a.parent().is('.disabled')) {
              e.preventDefault();
              return false;
            }
            $a.data({
              target: _this.$(".tab-pane.im-export-" + x)
            });
            return Tab.call($a, 'show');
          };
          return events[key] = cb;
        };
        for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
          x = _ref2[_j];
          _fn1(x);
        }
        _ref3 = ["no", "gzip", "zip"];
        _fn2 = function(val) {
          return events["click .im-" + val + "-compression"] = function(e) {
            return _this.requestInfo.set({
              compress: val
            });
          };
        };
        for (_k = 0, _len2 = _ref3.length; _k < _len2; _k++) {
          val = _ref3[_k];
          _fn2(val);
        }
        _ref4 = intermine.options.ExternalExportDestinations;
        for (name in _ref4) {
          enabled = _ref4[name];
          if (!(enabled)) {
            continue;
          }
          moreEvents = (_ref5 = intermine["export"].external[name].events) != null ? _ref5.call(this) : void 0;
          if (moreEvents != null) {
            _.extend(events, moreEvents);
          }
        }
        return events;
      };

      ExportDialogue.prototype.readFastaExt = function(e) {
        var ext;

        ext = this.$('input.im-fasta-extension').val();
        if (ext && /\S/.test(ext)) {
          return this.requestInfo.set({
            extension: ext
          });
        } else {
          return this.requestInfo.unset('extension');
        }
      };

      ExportDialogue.prototype.modalHidden = function(e) {
        if ((e != null) && e.target === this.el) {
          return this.remove();
        }
      };

      ExportDialogue.prototype.copyUriToClipboard = function() {
        var text;

        text = this.$('button.im-results-uri').is('.active') ? this.$('.im-download').attr('href') : this.$('.well.im-query-xml').text();
        return window.prompt(intermine.messages.actions.CopyToClipBoard, text);
      };

      ExportDialogue.prototype.toggleLinkViewer = function() {
        this.$('.im-download-file .im-perma-link-content').toggleClass('hide show');
        return this.$('.im-download-file .im-collapser').toggleClass('icon-angle-right icon-angle-down');
      };

      ExportDialogue.prototype.moveToSection = function(e) {
        var $this, destination;

        $this = $(e.currentTarget);
        Tab.call($this, 'show');
        destination = $this.data('destination');
        return this.state.set({
          destination: destination
        });
      };

      ExportDialogue.prototype.buildSharableLink = function(e) {
        return this.$('.im-perma-link-share-content').text("TODO");
      };

      switchActive = function() {
        var $this;

        $this = $(this);
        return $this.toggleClass('active', !$this.hasClass('active'));
      };

      ExportDialogue.prototype.switchWhatToShow = function(e) {
        var btns, wells;

        if ($(e.target).hasClass('active')) {
          return false;
        }
        btns = this.$('.im-what-to-show button');
        btns.each(switchActive);
        wells = this.$('.im-export-destination-options .im-download-file .well');
        return wells.each(switchActive);
      };

      ExportDialogue.prototype.buildPermaLink = function(e) {
        var currentQuery, endpoint, isPrivate, noIds, prop, _i, _len, _ref1, _ref2, _results,
          _this = this;

        endpoint = this.getExportEndPoint();
        currentQuery = this.query;
        isPrivate = intermine.utils.requiresAuthentication(currentQuery);
        this.state.set({
          isPrivate: isPrivate
        });
        _ref1 = [[true, 'permalink'], [false, 'url']];
        _results = [];
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          _ref2 = _ref1[_i], noIds = _ref2[0], prop = _ref2[1];
          _results.push((function(noIds, prop) {
            return _this.getExportParams(noIds).then(function(params) {
              var uriIsTooLong, url;

              if (!isPrivate) {
                delete params.token;
              }
              url = endpoint + "?" + $.param(params, true);
              if (noIds) {
                _this.state.set({
                  permaquery: params.query
                });
              }
              _this.state.set(prop, url);
              uriIsTooLong = url.length > 4000;
              if (uriIsTooLong) {
                return _this.getExportQuery(noIds).then(function(eq) {
                  var fetching, xml, _base, _ref3;

                  xml = eq.toXML();
                  fetching = ((_ref3 = (_base = _this.qids)[xml]) != null ? _ref3 : _base[xml] = eq.fetchQID());
                  return fetching.done(function(qid) {
                    _this.$('.im-long-uri').show();
                    delete params.query;
                    params.qid = qid;
                    url = endpoint + "?" + $.param(params, true);
                    return _this.state.set(prop, url);
                  });
                });
              } else {
                return _this.$('.im-long-uri').hide();
              }
            });
          })(noIds, prop));
        }
        return _results;
      };

      ExportDialogue.prototype.onChangePrivacy = function(state, isPrivate) {
        return this.$('.im-private-query').toggle(isPrivate);
      };

      ExportDialogue.prototype.onChangeURL = function(state, url) {
        return this.$('a.im-download').attr({
          href: url
        });
      };

      ExportDialogue.prototype.onChangePermaquery = function(state, permaquery) {
        return this.$('.well.im-query-xml').text(permaquery);
      };

      ExportDialogue.prototype.onChangePermalink = function(state, permalink) {
        var $a;

        $a = $('<a>').text(permalink).attr({
          href: permalink
        });
        return this.$('.im-perma-link-content').empty().append($a);
      };

      ExportDialogue.prototype.onChangeDest = function() {
        var action, dest, destination, x, _ref1;

        destination = this.state.get('destination');
        _ref1 = (function() {
          var _i, _len, _ref1, _results;

          _ref1 = ['Dest', ''];
          _results = [];
          for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
            x = _ref1[_i];
            _results.push(intermine.messages.actions[x + destination]);
          }
          return _results;
        })(), dest = _ref1[0], action = _ref1[1];
        this.$('.nav-tabs .im-export-destination .im-current').text(dest);
        this.$('.btn-primary.im-download').text(action);
        this.$('.im-export-destination-options > div').removeClass('active');
        return this.$(".im-" + (destination.toLowerCase())).addClass('active');
      };

      ExportDialogue.prototype.dontReallySubmitForm = function(e) {
        e.preventDefault();
        e.stopPropagation();
        return false;
      };

      ExportDialogue.prototype.keyPressOnLimit = function(e) {
        var input;

        input = $(e.target);
        switch (e.keyCode) {
          case 38:
            input.val(1 + parseInt(input.val(), 10));
            break;
          case 40:
            input.val(parseInt(input.val(), 10) - 1);
        }
        return input.change();
      };

      ExportDialogue.prototype.changeStart = function(e) {
        if (this.checkStartAndEnd()) {
          return this.requestInfo.set({
            start: parseInt(this.$('.im-first-row').val(), 10) - 1
          });
        }
      };

      ExportDialogue.prototype.changeEnd = function(e) {
        if (this.checkStartAndEnd()) {
          return this.requestInfo.set({
            end: parseInt(this.$('.im-last-row').val(), 10)
          });
        }
      };

      ExportDialogue.prototype.DIGITS = /^\s*\d+\s*$/;

      ExportDialogue.prototype.checkStartAndEnd = function() {
        var end, ok, start, valA, valB;

        start = this.$('.im-first-row');
        end = this.$('.im-last-row');
        valA = start.val();
        valB = end.val();
        ok = (this.DIGITS.test(valA) && parseInt(valA, 10) >= 1) && (this.DIGITS.test(valB) && parseInt(valB, 10) <= this.count);
        if (this.DIGITS.test(valA) && this.DIGITS.test(valB)) {
          ok = ok && (parseInt(valA, 10) <= parseInt(valB, 10));
        }
        $('.im-row-selection').toggleClass('error', !ok);
        return ok;
      };

      ignore = function(e) {
        e.stopPropagation();
        return e.preventDefault();
      };

      ExportDialogue.prototype.getExportEndPoint = function() {
        var format, suffix;

        format = this.requestInfo.get('format');
        suffix = __indexOf.call(BIO_FORMATS, format) >= 0 ? "/" + format.extension : "";
        return "" + this.service.root + "query/results" + suffix;
      };

      ExportDialogue.prototype["export"] = function(e) {
        var dest;

        dest = this.state.get('destination');
        if (dest in intermine["export"].external) {
          ignore(e);
          return intermine["export"].external[dest]["export"].call(this);
        } else {
          return true;
        }
      };

      ExportDialogue.prototype.getExportQuery = function(noIdCons) {
        var columns, f, newOrder, node, path, q, viewNodes, _i, _len, _ref1;

        if (noIdCons == null) {
          noIdCons = false;
        }
        q = this.query.clone();
        f = this.requestInfo.get('format');
        columns = (function() {
          switch (f.extension) {
            case 'bed':
            case 'gff3':
              return featuresToPaths(this.seqFeatures);
            case 'fasta':
              return featuresToPaths(this.fastaFeatures);
            default:
              return this.exportedCols.filter(isntExcluded).map(toPath);
          }
        }).call(this);
        if (columns != null) {
          q.select(columns);
        }
        _ref1 = this.query.views;
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          path = _ref1[_i];
          if (!(!q.isOuterJoined(path))) {
            continue;
          }
          node = q.getPathInfo(path).getParent();
          if (!isImplicitlyConstrained(q, node)) {
            q.addConstraint({
              path: node.append('id'),
              op: 'IS NOT NULL'
            });
          }
        }
        newOrder = __indexOf.call(BIO_FORMATS, f) >= 0 ? [] : (viewNodes = q.getViewNodes(), _.filter(q.sortOrder, function(_arg) {
          var parent, path;

          path = _arg.path;
          parent = q.getPathInfo(path).getParent();
          return _.any(viewNodes, function(node) {
            return parent.equals(node);
          });
        }));
        q.orderBy(newOrder);
        if (noIdCons) {
          return getPermaQuery(q);
        } else {
          return defer(q);
        }
      };

      ExportDialogue.prototype.getExportParams = function(noIdCons) {
        var dummy, end, params, start, _i, _len, _ref1, _ref2, _ref3;

        if (noIdCons == null) {
          noIdCons = false;
        }
        params = this.requestInfo.toJSON();
        params.token = this.service.token;
        params.format = this.getFormatParam();
        _ref1 = this.dummyParams;
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          dummy = _ref1[_i];
          delete params[dummy];
        }
        if (params.compress === 'no') {
          delete params.compress;
        }
        if ((_ref2 = params.format) !== 'gff3' && _ref2 !== 'fasta') {
          delete params.view;
        }
        if (this.requestInfo.get('columnHeaders') && ((_ref3 = params.format) === 'tab' || _ref3 === 'csv')) {
          params.columnheaders = "1";
        }
        start = params.start = this.requestInfo.get('start');
        end = this.requestInfo.get('end');
        if (end !== this.count) {
          params.size = end - start;
        }
        return this.getExportQuery(noIdCons).then(function(q) {
          params.query = q.toXML();
          return params;
        });
      };

      ExportDialogue.prototype.getExportURI = function(noIdCons) {
        var _this = this;

        if (noIdCons == null) {
          noIdCons = false;
        }
        return this.getExportQuery(noIdCons).then(function(q) {
          var uri;

          uri = q.getExportURI(_this.getFormatParam());
          uri += _this.getExtraOptions();
          return uri;
        });
      };

      ExportDialogue.prototype.getFormatParam = function() {
        var format;

        format = this.requestInfo.get('format');
        return format.param || format.extension;
      };

      ExportDialogue.prototype.getExtraOptions = function() {
        var end, ret, start;

        ret = "";
        if (this.requestInfo.get('columnHeaders')) {
          ret += "&columnheaders=1";
        }
        if (!this.requestInfo.get('allRows')) {
          start = this.requestInfo.get('start');
          end = this.requestInfo.get('end');
          ret += "&start=" + start;
          if (end !== this.count) {
            ret += "&size=" + (end - start);
          }
        }
        return ret;
      };

      ExportDialogue.prototype.toggleColSelection = function(e) {
        this.requestInfo.set({
          allCols: !this.requestInfo.get('allCols')
        });
        return false;
      };

      ExportDialogue.prototype.toggleRowSelection = function(e) {
        this.requestInfo.set({
          allRows: !this.requestInfo.get('allRows')
        });
        return false;
      };

      ExportDialogue.prototype.show = function() {
        return this.$el.modal('show');
      };

      ExportDialogue.prototype.stop = function() {
        return this.$el.modal('hide');
      };

      ExportDialogue.prototype.remove = function() {
        var obj, x, _i, _len, _ref1;

        for (_i = 0, _len = DELENDA.length; _i < _len; _i++) {
          x = DELENDA[_i];
          obj = this[x];
          if (obj != null) {
            if (typeof obj.close === "function") {
              obj.close();
            }
          }
          if (obj != null) {
            if (typeof obj.destroy === "function") {
              obj.destroy();
            }
          }
          if (obj != null) {
            obj.off();
          }
          delete this[x];
        }
        delete this.query;
        if ((_ref1 = this.$slider) != null) {
          _ref1.slider('destroy');
        }
        delete this.$slider;
        return ExportDialogue.__super__.remove.call(this);
      };

      ExportDialogue.prototype.isSpreadsheet = function() {
        var ColumnHeaders, SpreadsheetOptions, _ref1;

        _ref1 = intermine.messages.actions, ColumnHeaders = _ref1.ColumnHeaders, SpreadsheetOptions = _ref1.SpreadsheetOptions;
        this.$('.im-output-options').append("<h2>" + SpreadsheetOptions + "</h2>\n<div>\n  <label>\n    <span class=\"span4\">" + ColumnHeaders + "</span>\n    <input type=\"checkbox\" class=\"span8 im-column-headers\">\n  </label>\n</div>");
        return this.$('.im-column-headers').attr({
          checked: !!this.requestInfo.get('columnHeaders')
        });
      };

      ExportDialogue.prototype.isBED = function() {
        var BEDOptions, ChrPrefix, chrPref, _ref1;

        _ref1 = intermine.messages.actions, BEDOptions = _ref1.BEDOptions, ChrPrefix = _ref1.ChrPrefix;
        chrPref = $("<h3>" + BEDOptions + "</h3>\n<div>\n  <label>\n    <span class=\"span4\">" + ChrPrefix + "</span>\n    <input type=\"checkbox\" class=\"im-bed-chr-prefix span8\">\n  </label>\n</div>");
        chrPref.appendTo(this.$('.im-output-options'));
        chrPref.find('input').attr({
          checked: !!this.requestInfo.get('useChrPrefix')
        });
        return this.addSeqFeatureSelector();
      };

      ExportDialogue.prototype.isGFF3 = function() {
        this.addSeqFeatureSelector();
        this.$('.im-output-options').append("<h3>" + intermine.messages.actions.Gff3Options + "</h3>");
        return this.addExtraColumnsSelector();
      };

      ExportDialogue.prototype.isFASTA = function() {
        this.addFastaFeatureSelector();
        this.addFastaExtensionInput();
        return this.addExtraColumnsSelector();
      };

      ExportDialogue.prototype.updateFormatOptions = function() {
        var format, opts, requestInfo, _name, _ref1;

        opts = this.$('.im-output-options').empty();
        requestInfo = this.requestInfo;
        format = requestInfo.get('format');
        if (__indexOf.call(BIO_FORMATS, format) >= 0) {
          this.$('.im-col-options').hide();
          this.$('.im-col-options-bio').show();
          this.$('.tab-pane.im-export-rows').removeClass('active');
          this.$('.nav-tabs .im-export-rows').text('All rows').parent().removeClass('active').addClass('disabled');
          this.requestInfo.set({
            start: 0,
            end: this.count
          });
        } else {
          this.$('.im-col-options').show();
          this.$('.im-col-options-bio').hide();
          this.$('.nav-tabs .im-export-rows').parent().removeClass('disabled');
        }
        if ((_ref1 = format.extension) === 'tsv' || _ref1 === 'csv') {
          return this.isSpreadsheet();
        } else {
          return typeof this[_name = 'is' + format.extension.toUpperCase()] === "function" ? this[_name]() : void 0;
        }
      };

      ExportDialogue.prototype.addFastaExtensionInput = function() {
        var FastaExtension, FastaOptions, extOpt, _ref1;

        _ref1 = intermine.messages.actions, FastaOptions = _ref1.FastaOptions, FastaExtension = _ref1.FastaExtension;
        extOpt = $("<h3>" + FastaOptions + "</h3>\n<div>\n  <label>\n    <span class=\"span4\">" + FastaExtension + "</span>\n    <input type=\"text\"\n           placeholder=\"5kbp\"\n           class=\"span8 im-fasta-extension\">\n  </label>\n</div>");
        extOpt.appendTo(this.$('.im-output-options'));
        return extOpt.find('input').val(this.requestInfo.get('extension'));
      };

      ExportDialogue.prototype.initExtraAttributes = function() {
        var coll, path, _i, _len, _ref1, _results;

        coll = this.extraAttributes.close();
        _ref1 = this.query.views;
        _results = [];
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          path = _ref1[_i];
          if (!this.query.canHaveMultipleValues(path)) {
            _results.push(coll.add({
              path: this.query.getPathInfo(path),
              included: false
            }));
          }
        }
        return _results;
      };

      ExportDialogue.prototype.addExtraColumnsSelector = function() {
        var row;

        this.initExtraAttributes();
        row = new intermine.actions.ExportColumnOptions({
          collection: this.extraAttributes,
          message: intermine.messages.actions.ExtraAttributes
        });
        return this.$('.im-output-options').append(row.render().$el);
      };

      ExportDialogue.prototype.initFastaFeatures = function() {
        var included, node, _i, _len, _ref1, _results;

        this.fastaFeatures.close();
        included = true;
        _ref1 = this.query.getViewNodes();
        _results = [];
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          node = _ref1[_i];
          if ((node.isa('SequenceFeature')) || (node.isa('Protein'))) {
            this.fastaFeatures.add({
              path: node,
              included: included
            });
            _results.push(included = false);
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      };

      ExportDialogue.prototype.addFastaFeatureSelector = function() {
        var row;

        this.initFastaFeatures();
        row = new intermine.actions.ExportColumnOptions({
          collection: this.fastaFeatures,
          message: intermine.messages.actions.FastaFeatures
        });
        row.isValidCount = function(c) {
          return c === 1;
        };
        return this.$('.im-col-options-bio').html(row.render().$el);
      };

      ExportDialogue.prototype.initSeqFeatures = function() {
        var node, _i, _len, _ref1, _results;

        this.seqFeatures.close();
        _ref1 = this.query.getViewNodes();
        _results = [];
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          node = _ref1[_i];
          if (node.isa('SequenceFeature')) {
            _results.push(this.seqFeatures.add({
              path: node,
              included: true
            }));
          }
        }
        return _results;
      };

      ExportDialogue.prototype.addSeqFeatureSelector = function() {
        var row;

        this.initSeqFeatures();
        row = new intermine.actions.ExportColumnOptions({
          collection: this.seqFeatures,
          message: intermine.messages.actions.IncludedFeatures
        });
        row.isValidCount = function(c) {
          return c > 0;
        };
        return this.$('.im-col-options-bio').html(row.render().$el);
      };

      ExportDialogue.prototype.initColumnOptions = function() {
        var node, nodes;

        nodes = (function() {
          var _i, _len, _ref1, _results;

          _ref1 = this.query.getQueryNodes();
          _results = [];
          for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
            node = _ref1[_i];
            _results.push({
              node: node
            });
          }
          return _results;
        }).call(this);
        return this.possibleColumns = new intermine.columns.models.PossibleColumns(nodes, {
          exported: this.exportedCols
        });
      };

      ExportDialogue.prototype.initCols = function() {
        var cols, maybes, _ref1,
          _this = this;

        this.$('ul.im-cols li').remove();
        cols = this.$('.im-exported-cols');
        this.exportedCols.each(function(col) {
          var exported;

          exported = new intermine.columns.views.ExportColumnHeader({
            model: col
          });
          return exported.render().$el.appendTo(cols);
        });
        cols.sortable({
          items: 'li',
          axis: 'y',
          placeholder: 'im-resorting-placeholder im-exported-col',
          forcePlaceholderSize: true,
          update: function(e, ui) {
            _this.$('.im-reset-cols').removeClass('disabled');
            return _this.exportedCols.reset(cols.find('li').map(function() {
              return $(this).data('model');
            }).get());
          }
        });
        this.initColumnOptions();
        maybes = this.$('.im-can-be-exported-cols');
        if ((_ref1 = this.maybeView) != null) {
          _ref1.remove();
        }
        this.maybeView = new intermine.columns.views.PossibleColumns({
          collection: this.possibleColumns
        });
        return maybes.append(this.maybeView.render().el);
      };

      ExportDialogue.prototype.warnOfOuterJoinedCollections = function() {
        var q,
          _this = this;

        q = this.query;
        if (_.any(q.joins, function(s, p) {
          return (s === 'OUTER') && q.canHaveMultipleValues(p);
        })) {
          return this.$('.im-row-selection').append("<div class=\"alert alert-warning\">\n    <button class=\"close\" data-dismiss=\"alert\">×</button>\n    <strong>NB</strong>\n    " + intermine.messages.actions.OuterJoinWarning + "\n</div>");
        }
      };

      formatToEl = function(format) {
        return "<div class=\"im-format-choice\">\n  <label class=\"radio\">\n    <input type=\"radio\" class=\"im-format-" + format.extension + "\"\n          name=\"im-export-format\" value=\"" + format.extension + "\">\n    <i class=\"" + intermine.icons[format.extension] + "\"></i>\n    " + format.name + "\n  </label>\n</div>";
      };

      ExportDialogue.prototype.initFormats = function() {
        var $btn, $formats, current, ext, format, i, _i, _len,
          _this = this;

        $formats = this.$('.tab-pane.im-export-format .im-export-formats');
        current = this.requestInfo.get('format');
        for (i = _i = 0, _len = EXPORT_FORMATS.length; _i < _len; i = ++_i) {
          format = EXPORT_FORMATS[i];
          $btn = $(formatToEl(format));
          $btn[0].tabIndex = i;
          $formats.append($btn);
        }
        this.service.fetchModel().done(function(model) {
          var isSuitableForThisQuery, viewNodeTypes, _j, _len1, _results;

          if (intermine.utils.modelIsBio(model)) {
            viewNodeTypes = _this.query.getViewNodes().map(function(n) {
              return n.getType();
            });
            isSuitableForThisQuery = anyNodeIsSuitable(model, viewNodeTypes);
            _results = [];
            for (i = _j = 0, _len1 = BIO_FORMATS.length; _j < _len1; i = ++_j) {
              format = BIO_FORMATS[i];
              if (!(isSuitableForThisQuery(format.types))) {
                continue;
              }
              $btn = $(formatToEl(format));
              $btn[0].tabIndex = i + EXPORT_FORMATS.length;
              _results.push($formats.append($btn));
            }
            return _results;
          }
        });
        ext = this.requestInfo.get('format').extension;
        return $formats.find('input').val([ext]);
      };

      ExportDialogue.prototype.render = function() {
        this.$el.append(intermine.snippets.actions.DownloadDialogue());
        this.initFormats();
        this.initCols();
        this.makeSlider();
        this.updateFormatOptions();
        this.warnOfOuterJoinedCollections();
        this.addExternalExports();
        this.state.trigger('change:destination');
        this.requestInfo.trigger('change');
        this.requestInfo.trigger('change:format');
        return this;
      };

      ExportDialogue.prototype.addExternalExports = function() {
        var $navs, $options, action, enabled, name, _base, _ref1, _results;

        $options = this.$('.im-export-destination-options');
        $navs = this.$('.im-export-destinations.nav');
        _ref1 = intermine.options.ExternalExportDestinations;
        _results = [];
        for (name in _ref1) {
          enabled = _ref1[name];
          if (!(enabled)) {
            continue;
          }
          action = "SendTo" + name;
          $navs.append("<li>\n  <a data-destination=\"" + name + "\">\n    " + intermine.messages.actions[action] + "\n  </a>\n</li>");
          _results.push($options.append(typeof (_base = intermine["export"].snippets)[name] === "function" ? _base[name](this.requestInfo.toJSON()) : void 0));
        }
        return _results;
      };

      ExportDialogue.prototype.makeSlider = function() {
        var _ref1,
          _this = this;

        if ((_ref1 = this.$slider) != null) {
          _ref1.slider('destroy');
        }
        this.$slider = null;
        return this.query.count(function(c) {
          _this.count = c;
          _this.requestInfo.set({
            end: c
          });
          return _this.$slider = _this.$('.im-row-range-slider').slider({
            range: true,
            min: 0,
            max: c - 1,
            values: [0, c - 1],
            step: 1,
            slide: function(e, ui) {
              return _this.requestInfo.set({
                start: ui.values[0],
                end: ui.values[1] + 1
              });
            }
          });
        });
      };

      return ExportDialogue;

    })(Backbone.View);
    return scope("intermine.query.export", {
      ExportDialogue: ExportDialogue
    });
  }));

  (function() {
    var changeGalaxyURI, defaultGalaxy, doGalaxy, forgetGalaxy, getResultClass, saveGalaxyPreference, sendToGalaxy, yielding;

    yielding = function(x) {
      return $.Deferred(function() {
        return this.resolve(x);
      }).promise();
    };
    getResultClass = function(q) {
      return $.when(q).then(function(query) {
        var commonType, model, node, viewNodes;

        viewNodes = query.getViewNodes();
        model = query.model;
        if (viewNodes.length === 1) {
          return model.getPathInfo(viewNodes[0].getType().name).getDisplayName();
        } else if (commonType = model.findCommonType((function() {
          var _i, _len, _results;

          _results = [];
          for (_i = 0, _len = viewNodes.length; _i < _len; _i++) {
            node = viewNodes[_i];
            _results.push(node.getType());
          }
          return _results;
        })())) {
          return model.getPathInfo(commonType).getDisplayName();
        } else if (model.name) {
          return yielding(model.name);
        } else {
          return yielding('');
        }
      });
    };
    saveGalaxyPreference = function(uri) {
      return this.query.service.whoami(function(user) {
        if (user.hasPreferences && user.preferences['galaxy-url'] !== uri) {
          return user.setPreference('galaxy-url', uri);
        }
      });
    };
    doGalaxy = function(galaxy) {
      var c, endpoint, format, qLists, query,
        _this = this;

      query = this.getExportQuery();
      endpoint = this.getExportEndPoint();
      format = this.requestInfo.get('format');
      qLists = (function() {
        var _i, _len, _ref, _results;

        _ref = this.query;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          c = _ref[_i];
          if (c.op === 'IN') {
            _results.push(c.value);
          }
        }
        return _results;
      }).call(this);
      return $.when(intermine.utils.getOrganisms(query), getResultClass(query)).then(function(orgs, type) {
        var brand, k, name, params, prefix, suffix, v, _ref;

        prefix = orgs.length === 1 ? orgs[0] + ' ' : '';
        brand = intermine.options.brand[_this.service.root.replace(/\/[^\.]+$/, '')];
        suffix = brand != null ? " from " + brand : '';
        name = prefix + ("" + type + " data") + suffix;
        params = {
          tool_id: intermine.options.GalaxyTool,
          organism: orgs.join(', '),
          URL: endpoint,
          URL_method: "post",
          name: name,
          data_type: format.extension === 'tsv' ? 'tabular' : format.extension,
          info: "" + query.root + " data from " + _this.service.root + ".\nUploaded from " + (window.location.toString().replace(/\?.*/, '')) + ".\n" + (qLists.length ? ' source: ' + lists.join(', ') : '') + "\n" + (orgs.length ? ' organisms: ' + orgs.join(', ') : '')
        };
        _ref = _this.getExportParams();
        for (k in _ref) {
          v = _ref[k];
          params[k] = v;
        }
        return intermine.utils.openWindowWithPost("" + galaxy + "/tool_runner", "Upload", params);
      });
    };
    changeGalaxyURI = function(e) {
      return this.requestInfo.set({
        galaxy: this.$('.im-galaxy-uri').val()
      });
    };
    defaultGalaxy = function() {
      var _ref;

      return (_ref = intermine.options.GalaxyCurrent) != null ? _ref : intermine.options.GalaxyMain;
    };
    forgetGalaxy = function(e) {
      var _this = this;

      this.service.whoami().then(function(user) {
        return user.clearPreference('galaxy-url');
      }).done(function() {
        return _this.requestInfo.set({
          galaxy: defaultGalaxy()
        });
      });
      return false;
    };
    sendToGalaxy = function() {
      var uri;

      uri = this.requestInfo.get('galaxy');
      doGalaxy.call(this, uri);
      if (this.$('.im-galaxy-save-url').is(':checked') && uri !== intermine.options.GalaxyMain) {
        return saveGalaxyPreference.call(this, uri);
      }
    };
    return scope('intermine.export.external.Galaxy', {
      "export": sendToGalaxy,
      init: function() {
        var _this = this;

        this.requestInfo.set({
          galaxy: defaultGalaxy()
        });
        this.dummyParams.push('galaxy');
        this.service.whoami(function(user) {
          var myGalaxy;

          if (user.hasPreferences && (myGalaxy = user.preferences['galaxy-url'])) {
            return _this.requestInfo.set({
              galaxy: myGalaxy
            });
          }
        });
        return this.requestInfo.on("change:galaxy", function(m, uri) {
          var currentVal, input;

          input = _this.$('input.im-galaxy-uri');
          currentVal = input.val();
          if (currentVal !== uri) {
            input.val(uri);
          }
          return _this.$('.im-galaxy-save-url').attr({
            disabled: uri === intermine.options.GalaxyMain
          });
        });
      },
      events: function() {
        var _this = this;

        return {
          'click .im-forget-galaxy': function(e) {
            return forgetGalaxy.call(_this, e);
          },
          'change .im-galaxy-uri': function(e) {
            return changeGalaxyURI.call(_this, e);
          },
          'click .im-send-to-galaxy': function(e) {
            return sendToGalaxy.call(_this, e);
          }
        };
      }
    });
  })();

  (function() {
    var sendToGenomeSpace;

    sendToGenomeSpace = function() {
      var fileName, format, genomeSpaceURL, gsFileName, qs, uploadUrl, url, win, _ref,
        _this = this;

      genomeSpaceURL = intermine.options.GenomeSpaceUpload;
      uploadUrl = this.state.get('url');
      _ref = this.requestInfo.toJSON(), format = _ref.format, gsFileName = _ref.gsFileName;
      fileName = "" + gsFileName + "." + format.extension;
      qs = $.param({
        uploadUrl: uploadUrl,
        fileName: fileName
      });
      url = "" + genomeSpaceURL + "?" + qs;
      win = window.open(url);
      win.setCallbackOnGSUploadComplete = function(savePath) {
        return _this.stop();
      };
      win.setCallbackOnGSUploadError = function(savePath) {
        _this.trigger('export:error', 'genomespace');
        return _this.stop();
      };
      return win.focus();
    };
    return scope('intermine.export.external.Genomespace', {
      init: function() {
        var gsFileName, onChange, s, view;

        view = this;
        onChange = function() {
          var format, gsFileName, _ref;

          _ref = view.requestInfo.toJSON(), format = _ref.format, gsFileName = _ref.gsFileName;
          view.$('.im-genomespace .im-format').text('.' + format.extension);
          return view.$('.im-genomespace-filename').val(gsFileName);
        };
        this.dummyParams.push('gsFileName');
        this.requestInfo.on('change', onChange);
        s = this.service.name || this.service.root.replace(/^https?:\/\//, '').replace(/\/.*/, '');
        gsFileName = "" + this.query.root + " results from " + s + " " + (new Date());
        return this.requestInfo.set({
          gsFileName: gsFileName
        });
      },
      "export": sendToGenomeSpace,
      events: function() {
        var _this = this;

        return {
          'click .im-send-to-genomespace': function(e) {
            return sendToGenomeSpace.call(_this, e);
          },
          'change .im-genomespace-filename': function(e) {
            return _this.requestInfo.set({
              gsFileName: $(e.target).val()
            });
          }
        };
      }
    });
  })();

  scope('intermine.export.snippets', {
    Galaxy: _.template("<div class=\"im-galaxy\">\n  <form class=\"im-galaxy form form-compact well\">\n    <label>\n      " + intermine.messages.actions.GalaxyURILabel + "\n      <input class=\"im-galaxy-uri\" \n            type=\"text\"\n            value=\"<%- galaxy %>\"\n    </label>\n    <label>\n      " + intermine.messages.actions.SaveGalaxyURL + "\n      <input type=\"checkbox\" disabled checked class=\"im-galaxy-save-url\">\n    </label>\n  </form>\n</div>"),
    Genomespace: function() {
      return "<div class=\"im-genomespace\">\n  <div class=\"well\">\n    <label>File Name</label>\n    <div class=\"input-append\">\n      <input class=\"im-genomespace-filename input\" style=\"width: 40em\" type=\"text\">\n      <span class=\"add-on im-format\"></span>\n    </div>\n  </div>\n</div>";
    }
  });

  scope('intermine.snippets.facets', {
    OnlyOne: _.template("<div class=\"alert alert-info im-all-same\">\n    All <%= count %> values are the same: <strong><%= item %></strong>\n</div>")
  });

  (function() {
    var BooleanFacet, ColumnSummary, FACET_TEMPLATE, FACET_TITLE, FacetRow, FacetView, FrequencyFacet, HistoFacet, Int, MORE_FACETS_HTML, NormalCurve, NumericFacet, NumericRange, PieFacet, SUMMARY_FORMATS, numeric, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8;

    NormalCurve = function(mean, stdev) {
      return function(x) {
        var a;

        a = x - mean;
        return Math.exp(-(a * a) / (2 * stdev * stdev)) / (Math.sqrt(2 * Math.PI) * stdev);
      };
    };
    Int = function(x) {
      return parseInt(x, 10);
    };
    numeric = function(x) {
      return +x;
    };
    MORE_FACETS_HTML = "<i class=\"icon-plus-sign pull-right\" title=\"Showing top ten. Click to see all values\"></i>";
    FACET_TITLE = "<dt>\n  <i class=\"icon-chevron-right\"></i>\n  <span class=\"im-facet-title\"></span>\n  &nbsp;<span class=\"im-facet-count\"></span>\n</dt>";
    FACET_TEMPLATE = _.template("<dd>\n    <a href=#>\n        <b class=\"im-facet-count pull-right\">\n            (<%= count %>)\n        </b>\n        <%= item %>\n    </a>\n</dd>");
    SUMMARY_FORMATS = {
      tab: 'tsv',
      csv: 'csv',
      xml: 'xml',
      json: 'json'
    };
    ColumnSummary = (function(_super) {
      __extends(ColumnSummary, _super);

      function ColumnSummary() {
        this.render = __bind(this.render, this);        _ref = ColumnSummary.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      ColumnSummary.prototype.tagName = 'div';

      ColumnSummary.prototype.className = "im-column-summary";

      ColumnSummary.prototype.initialize = function(query, facet) {
        var fp,
          _this = this;

        this.query = query;
        this.state = new Backbone.Model({
          open: false
        });
        if (facet.path) {
          return this.facet = facet;
        } else {
          fp = this.query.getPathInfo(facet);
          return this.facet = {
            path: fp,
            title: fp.getDisplayName().then(function(name) {
              return name.replace(/^[^>]+>\s*/, '');
            }),
            ignoreTitle: true
          };
        }
      };

      ColumnSummary.prototype.render = function() {
        var attrType, clazz, initialLimit,
          _this = this;

        attrType = this.facet.path.getType();
        clazz = __indexOf.call(intermine.Model.NUMERIC_TYPES, attrType) >= 0 ? NumericFacet : FrequencyFacet;
        initialLimit = intermine.options.INITIAL_SUMMARY_ROWS;
        this.fac = new clazz(this.query, this.facet, initialLimit, this.noTitle);
        this.$el.append(this.fac.el);
        this.fac.render();
        this.fac.on('ready', function() {
          return _this.trigger('ready', _this);
        });
        this.fac.on('toggled', function() {
          return _this.state.set({
            open: !_this.state.get('open')
          });
        });
        this.fac.on('closed', function() {
          return _this.state.set({
            open: false
          });
        });
        this.trigger('rendered', this);
        return this;
      };

      ColumnSummary.prototype.toggle = function() {
        var _ref1;

        return (_ref1 = this.fac) != null ? _ref1.toggle() : void 0;
      };

      ColumnSummary.prototype.close = function() {
        var _ref1;

        return (_ref1 = this.fac) != null ? _ref1.close() : void 0;
      };

      ColumnSummary.prototype.remove = function() {
        var _ref1;

        if ((_ref1 = this.fac) != null) {
          _ref1.remove();
        }
        return ColumnSummary.__super__.remove.call(this);
      };

      return ColumnSummary;

    })(Backbone.View);
    FacetView = (function(_super) {
      __extends(FacetView, _super);

      function FacetView() {
        this.render = __bind(this.render, this);        _ref1 = FacetView.__super__.constructor.apply(this, arguments);
        return _ref1;
      }

      FacetView.prototype.tagName = "dl";

      FacetView.prototype.initialize = function(query, facet, limit, noTitle) {
        this.query = query;
        this.facet = facet;
        this.limit = limit;
        this.noTitle = noTitle;
        this.query.on("change:constraints", this.render);
        return this.query.on("filter:summary", this.render);
      };

      FacetView.prototype.events = function() {
        return {
          "click dt": "toggle"
        };
      };

      FacetView.prototype.toggle = function() {
        this.$('.im-facet').slideToggle();
        this.$('dt i').first().toggleClass('icon-chevron-right icon-chevron-down');
        return this.trigger('toggled', this);
      };

      FacetView.prototype.close = function() {
        this.$('.im-facet').slideUp();
        this.$('dt i').removeClass('icon-chevron-down').addClass('icon-chevron-right');
        return this.trigger('close', this);
      };

      FacetView.prototype.render = function() {
        var _this = this;

        if (!this.noTitle) {
          this.$el.prepend(FACET_TITLE);
          $.when(this.facet.title).then(function(title) {
            return _this.$('.im-facet-title').text(title);
          });
        }
        return this;
      };

      return FacetView;

    })(Backbone.View);
    FrequencyFacet = (function(_super) {
      __extends(FrequencyFacet, _super);

      function FrequencyFacet() {
        this.addItem = __bind(this.addItem, this);
        this.showMore = __bind(this.showMore, this);        _ref2 = FrequencyFacet.__super__.constructor.apply(this, arguments);
        return _ref2;
      }

      FrequencyFacet.prototype.showMore = function(e) {
        var areVisible, got, more,
          _this = this;

        more = $(e.target);
        got = this.$('dd').length();
        areVisible = this.$('dd').first().is(':visible');
        e.stopPropagation();
        e.preventDefault();
        return this.query.summarise(this.facet.path, function(items) {
          var item, _i, _len, _ref3;

          _ref3 = items.slice(got);
          for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
            item = _ref3[_i];
            _this.addItem(item).toggle(areVisible);
          }
          return more.tooltip('hide').remove();
        });
      };

      FrequencyFacet.prototype.render = function(filterTerm) {
        var $progress, getSummary, limit, placement,
          _this = this;

        if (filterTerm == null) {
          filterTerm = "";
        }
        if (this.rendering) {
          return;
        }
        this.filterTerm = filterTerm;
        this.rendering = true;
        this.$el.empty();
        FrequencyFacet.__super__.render.call(this);
        $progress = $("<div class=\"progress progress-info progress-striped active\">\n    <div class=\"bar\" style=\"width:100%\"></div>\n</div>");
        $progress.appendTo(this.el);
        getSummary = this.query.filterSummary(this.facet.path, filterTerm, this.limit);
        getSummary.fail(this.remove);
        limit = this.limit;
        placement = 'left';
        return getSummary.done(function(results, stats, count) {
          var Vizualization, hasMore, summaryView;

          _this.query.trigger('got:summary:total', _this.facet.path, stats.uniqueValues, results.length, count);
          $progress.remove();
          _this.$('.im-facet-count').text("(" + stats.uniqueValues + ")");
          hasMore = results.length < limit ? false : stats.uniqueValues > limit;
          if (hasMore) {
            $(MORE_FACETS_HTML).appendTo(_this.$dt).tooltip({
              placement: placement
            }).click(_this.showMore);
          }
          summaryView = stats.uniqueValues <= 1 ? (_this.$el.empty(), stats.uniqueValues ? intermine.snippets.facets.OnlyOne(results[0]) : "No results") : (Vizualization = _this.getVizualization(stats), new Vizualization(_this.query, _this.facet, results, hasMore, filterTerm));
          _this.$el.append(summaryView.el ? summaryView.el : summaryView);
          if (typeof summaryView.render === "function") {
            summaryView.render();
          }
          _this.rendering = false;
          return _this.trigger('ready', _this);
        });
      };

      FrequencyFacet.prototype.getVizualization = function(stats) {
        var _ref3;

        if (!this.query.canHaveMultipleValues(this.facet.path)) {
          if (_ref3 = this.query.getType(this.facet.path), __indexOf.call(intermine.Model.BOOLEAN_TYPES, _ref3) >= 0) {
            return BooleanFacet;
          } else if (stats.uniqueValues <= intermine.options.MAX_PIE_SLICES) {
            return PieFacet;
          }
        }
        return HistoFacet;
      };

      FrequencyFacet.prototype.addItem = function(item) {
        var $dd,
          _this = this;

        $dd = $(FACET_TEMPLATE(item)).appendTo(this.el);
        $dd.click(function() {
          return _this.query.addConstraint({
            title: _this.facet.title,
            path: _this.facet.path,
            op: "=",
            value: item.item
          });
        });
        return $dd;
      };

      return FrequencyFacet;

    })(FacetView);
    NumericRange = (function(_super) {
      __extends(NumericRange, _super);

      function NumericRange() {
        _ref3 = NumericRange.__super__.constructor.apply(this, arguments);
        return _ref3;
      }

      NumericRange.prototype._defaults = {};

      NumericRange.prototype.setLimits = function(limits) {
        return this._defaults = limits;
      };

      NumericRange.prototype.get = function(prop) {
        var ret;

        ret = NumericRange.__super__.get.call(this, prop);
        if (ret != null) {
          return ret;
        } else if (prop in this._defaults) {
          return this._defaults[prop];
        } else {
          return null;
        }
      };

      NumericRange.prototype.toJSON = function() {
        return _.extend({}, this._defaults, this.attributes);
      };

      NumericRange.prototype.nullify = function() {
        var evt, _i, _len, _ref4, _results;

        this.set({
          min: null,
          max: null
        });
        this.nulled = true;
        _ref4 = ['change:min', 'change:max', 'change'];
        _results = [];
        for (_i = 0, _len = _ref4.length; _i < _len; _i++) {
          evt = _ref4[_i];
          _results.push(this.trigger(evt, this));
        }
        return _results;
      };

      NumericRange.prototype.set = function(name, value) {
        var meth;

        this.nulled = false;
        if (_.isString(name) && (name in this._defaults)) {
          meth = name === 'min' ? 'max' : 'min';
          return NumericRange.__super__.set.call(this, name, Math[meth](this._defaults[name], value));
        } else {
          return NumericRange.__super__.set.apply(this, arguments);
        }
      };

      NumericRange.prototype.isNotAll = function() {
        var max, min, _ref4;

        if (this.nulled) {
          return true;
        }
        _ref4 = this.toJSON(), min = _ref4.min, max = _ref4.max;
        return ((min != null) && min !== this._defaults.min) || ((max != null) && max !== this._defaults.max);
      };

      return NumericRange;

    })(Backbone.Model);
    NumericFacet = (function(_super) {
      var fracWithinRange, getPartialCount, inty, sumCounts;

      __extends(NumericFacet, _super);

      function NumericFacet() {
        this.drawSelection = __bind(this.drawSelection, this);
        this.drawChart = __bind(this.drawChart, this);
        this.drawSlider = __bind(this.drawSlider, this);
        this.drawStats = __bind(this.drawStats, this);
        this.handleSummary = __bind(this.handleSummary, this);
        this.valForX = __bind(this.valForX, this);
        this.xForVal = __bind(this.xForVal, this);        _ref4 = NumericFacet.__super__.constructor.apply(this, arguments);
        return _ref4;
      }

      NumericFacet.prototype.initialize = function() {
        var idx, prop, _fn, _ref5,
          _this = this;

        NumericFacet.__super__.initialize.apply(this, arguments);
        this.range = new NumericRange();
        this.range.on('change', function() {
          var width, x, _ref5;

          if (_this.shouldDrawBox()) {
            if (_this.range.nulled) {
              return _this.drawSelection(0, 25);
            } else {
              x = _this.xForVal(_this.range.get('min'));
              width = _this.xForVal(_this.range.get('max')) - x;
              return _this.drawSelection(x, width);
            }
          } else {
            if ((_ref5 = _this.selection) != null) {
              _ref5.remove();
            }
            return _this.selection = null;
          }
        });
        this.range.on('change', function() {
          var _ref5;

          if (_this.range.isNotAll()) {
            return _this.drawEstCount();
          } else {
            if ((_ref5 = _this.estCount) != null) {
              _ref5.remove();
            }
            return _this.estCount = null;
          }
        });
        this.range.on('reset', function() {
          var max, min, prop, val, _ref5, _ref6, _ref7, _results;

          _ref5 = _this.range.toJSON(), min = _ref5.min, max = _ref5.max;
          if ((_ref6 = _this.$slider) != null) {
            _ref6.slider('option', 'values', [min, max]);
          }
          _ref7 = {
            min: min,
            max: max
          };
          _results = [];
          for (prop in _ref7) {
            val = _ref7[prop];
            _results.push(_this.$("input.im-range-" + prop).val("" + val));
          }
          return _results;
        });
        _ref5 = {
          min: 0,
          max: 1
        };
        _fn = function(prop, idx) {
          return _this.range.on("change:" + prop, function(m, val) {
            var _ref6, _ref7;

            if (m.nulled) {
              _this.$("input.im-range-" + prop).val("null");
            }
            if (val == null) {
              return;
            }
            val = _this.round(val);
            _this.$("input.im-range-" + prop).val("" + val);
            if (((_ref6 = _this.$slider) != null ? _ref6.slider('values', idx) : void 0) !== val) {
              return (_ref7 = _this.$slider) != null ? _ref7.slider('values', idx, val) : void 0;
            }
          });
        };
        for (prop in _ref5) {
          idx = _ref5[prop];
          _fn(prop, idx);
        }
        return this.range.on('change', function() {
          var changed;

          changed = _this.range.isNotAll();
          return _this.$('.btn').toggleClass("disabled", !changed);
        });
      };

      NumericFacet.prototype.events = function() {
        return _.extend(NumericFacet.__super__.events.apply(this, arguments), {
          'click': function(e) {
            return e.stopPropagation();
          },
          'keyup input.im-range-val': 'incRangeVal',
          'change input.im-range-val': 'setRangeVal',
          'click .btn-primary': 'changeConstraints',
          'click .btn-cancel': 'clearRange'
        });
      };

      NumericFacet.prototype.clearRange = function() {
        var _ref5, _ref6;

        if ((_ref5 = this.range) != null) {
          _ref5.clear();
        }
        return (_ref6 = this.range) != null ? _ref6.trigger('reset') : void 0;
      };

      NumericFacet.prototype.changeConstraints = function(e) {
        var fpath, newConstraints;

        e.preventDefault();
        e.stopPropagation();
        fpath = this.facet.path.toString();
        this.query.constraints = _(this.query.constraints).filter(function(c) {
          return c.path !== fpath;
        });
        if (this.range.nulled) {
          newConstraints = [
            {
              path: this.facet.path,
              op: 'IS NULL'
            }
          ];
        } else {
          newConstraints = [
            {
              path: this.facet.path,
              op: ">=",
              value: this.range.get('min')
            }, {
              path: this.facet.path,
              op: "<=",
              value: this.range.get('max')
            }
          ];
        }
        return this.query.addConstraints(newConstraints);
      };

      NumericFacet.prototype.className = "im-numeric-facet";

      NumericFacet.prototype.chartHeight = 70;

      NumericFacet.prototype.leftMargin = 25;

      NumericFacet.prototype.xForVal = function(val) {
        var conversionRate;

        if (val === this.min) {
          return this.leftMargin;
        }
        if (val === this.max) {
          return this.w;
        }
        conversionRate = (this.w - this.leftMargin) / (this.max - this.min);
        return this.leftMargin + (conversionRate * (val - this.min));
      };

      NumericFacet.prototype.valForX = function(x) {
        var conversionRate;

        if (x <= this.leftMargin) {
          return this.min;
        }
        if (x >= this.w) {
          return this.max;
        }
        conversionRate = (this.max - this.min) / (this.w - this.leftMargin);
        return this.min + (conversionRate * (x - this.leftMargin));
      };

      NumericFacet.prototype.shouldDrawBox = function() {
        return this.range.isNotAll();
      };

      NumericFacet.prototype.render = function() {
        var promise,
          _this = this;

        NumericFacet.__super__.render.call(this);
        this.container = this.make("div", {
          "class": "facet-content im-facet"
        });
        this.$el.append(this.container);
        this.canvas = this.make("div");
        $(this.canvas).mouseout(function() {
          return _this._selecting_paths_ = false;
        });
        $(this.container).append(this.canvas);
        this.throbber = $("<div class=\"progress progress-info progress-striped active\">\n    <div class=\"bar\" style=\"width:100%\"></div>\n</div>");
        this.throbber.appendTo(this.el);
        promise = this.query.summarise(this.facet.path, this.handleSummary);
        promise.fail(this.remove);
        promise.done(function() {
          return _this.trigger('ready', _this);
        });
        return this;
      };

      NumericFacet.prototype.remove = function() {
        var _ref5, _ref6;

        if ((_ref5 = this.$slider) != null) {
          _ref5.slider('destroy');
        }
        delete this.$slider;
        if ((_ref6 = this.range) != null) {
          _ref6.off();
        }
        delete this.range;
        return NumericFacet.__super__.remove.call(this);
      };

      inty = function(type) {
        return type === "int" || type === "Integer" || type === "long" || type === "Long";
      };

      NumericFacet.prototype.handleSummary = function(items, stats) {
        var hasMore, hf, step, summary;

        this.throbber.remove();
        summary = items[0];
        this.w = this.$el.closest(':visible').width() * 0.95;
        if (summary.item != null) {
          if (items.length > 1) {
            hasMore = items.length < this.limit ? false : stats.uniqueValues > this.limit;
            hf = new HistoFacet(this.query, this.facet, items, hasMore, "");
            this.$el.append(hf.el);
            return hf.render();
          } else {
            return this.$el.empty().append(intermine.snippets.facets.OnlyOne(summary));
          }
        }
        this.mean = parseFloat(summary.average);
        this.dev = parseFloat(summary.stdev);
        this.range.setLimits(summary);
        this.max = summary.max;
        this.min = summary.min;
        this.step = step = inty(this.query.getType(this.facet.path)) ? 1 : Math.abs((this.max - this.min) / 100);
        this.round = function(x) {
          if (step === 1) {
            return Math.round(x);
          } else {
            return x;
          }
        };
        if (summary.count != null) {
          this.stepWidth = (this.w - (this.leftMargin + 1)) / items[0].buckets;
          this.drawChart(items);
        } else {
          this.drawCurve();
        }
        this.drawStats();
        return this.drawSlider();
      };

      NumericFacet.prototype.drawStats = function() {
        return $(this.container).append("<table class=\"table table-condensed\">\n    <thead>\n        <tr>\n            <th>Min</th>\n            <th>Max</th>\n            <th>Mean</th>\n            <th>Standard Deviation</th>\n        </tr>\n    </thead>\n    <tbody>\n        <tr>\n            <td>" + this.min + "</td>\n            <td>" + this.max + "</td>\n            <td>" + (this.mean.toFixed(5)) + "</td>\n            <td>" + (this.dev.toFixed(5)) + "</td>\n        </tr>\n    </tbody>\n</table>");
      };

      NumericFacet.prototype.setRangeVal = function(e) {
        var $input, current, next, prop, _ref5;

        $input = $(e.target);
        prop = $input.data('var');
        current = (_ref5 = this.range.get(prop)) != null ? _ref5 : this[prop];
        next = numeric($input.val());
        if (current !== next) {
          return this.range.set(prop, next);
        }
      };

      NumericFacet.prototype.incRangeVal = function(e) {
        var $input, current, next, prop, _ref5;

        $input = $(e.target);
        prop = $input.data('var');
        current = next = (_ref5 = this.range.get(prop)) != null ? _ref5 : this[prop];
        switch (e.keyCode) {
          case 40:
            next -= this.step;
            break;
          case 38:
            next += this.step;
        }
        if (next !== current) {
          return this.range.set(prop, next);
        }
      };

      NumericFacet.prototype.drawSlider = function() {
        var opts,
          _this = this;

        $(this.container).append("<div class=\"btn-group pull-right\">\n  <button class=\"btn btn-primary disabled\">Apply</button>\n  <button class=\"btn btn-cancel disabled\">Reset</button>\n</div>\n<input type=\"text\" data-var=\"min\" class=\"im-range-min input im-range-val\" value=\"" + this.min + "\">\n<span>...</span>\n<input type=\"text\" data-var=\"max\" class=\"im-range-max input im-range-val\" value=\"" + this.max + "\">\n<div class=\"slider\"></div>");
        opts = {
          range: true,
          min: this.min,
          max: this.max,
          values: [this.min, this.max],
          step: this.step,
          slide: function(e, ui) {
            var _ref5;

            return (_ref5 = _this.range) != null ? _ref5.set({
              min: ui.values[0],
              max: ui.values[1]
            }) : void 0;
          }
        };
        return this.$slider = this.$('.slider').slider(opts);
      };

      NumericFacet.prototype.drawChart = function(items) {
        var _this = this;

        if (typeof d3 !== "undefined" && d3 !== null) {
          return setTimeout((function() {
            return _this._drawD3Chart(items);
          }), 0);
        }
      };

      NumericFacet.prototype._drawD3Chart = function(items) {
        var axis, barClickHandler, bottomMargin, bucketRange, bucketVal, chart, container, getTitle, h, item, most, n, rects, rightMargin, val, x, xToVal, y, _i, _len,
          _this = this;

        this.items = items;
        bottomMargin = 18;
        rightMargin = 14;
        n = items[0].buckets + 1;
        h = this.chartHeight;
        most = d3.max(items, function(d) {
          return d.count;
        });
        x = d3.scale.linear().domain([1, n]).range([this.leftMargin, this.w - rightMargin]);
        y = d3.scale.linear().domain([0, most]).rangeRound([0, h - bottomMargin]);
        this.xForVal = d3.scale.linear().domain([this.min, this.max]).range([this.leftMargin, this.w - rightMargin]);
        xToVal = d3.scale.linear().domain([1, n]).range([this.min, this.max]);
        val = function(x) {
          return _this.round(xToVal(x));
        };
        bucketVal = function(x) {
          var raw;

          raw = val(x);
          if (raw < _this.min) {
            return _this.min;
          } else if (raw > _this.max) {
            return _this.max;
          } else {
            return raw;
          }
        };
        bucketRange = function(bucket) {
          var delta, max, min, _ref5, _ref6;

          if (bucket != null) {
            _ref5 = (function() {
              var _i, _len, _ref5, _results;

              _ref5 = [0, 1];
              _results = [];
              for (_i = 0, _len = _ref5.length; _i < _len; _i++) {
                delta = _ref5[_i];
                _results.push(bucketVal(bucket + delta));
              }
              return _results;
            })(), min = _ref5[0], max = _ref5[1];
          } else {
            _ref6 = [0 - bucketVal(2), bucketVal(1)], min = _ref6[0], max = _ref6[1];
          }
          return {
            min: min,
            max: max
          };
        };
        getTitle = function(item) {
          var brange, title;

          return title = item.bucket != null ? (brange = bucketRange(item.bucket), "" + brange.min + " >= x < " + brange.max + ": " + item.count + " items") : "x is null: " + item.count + " items";
        };
        this.paper = chart = d3.select(this.canvas).append('svg').attr('class', 'chart').attr('width', this.w).attr('height', h);
        container = this.canvas;
        barClickHandler = function(d, i) {
          var _ref5, _ref6;

          if (d.bucket != null) {
            return (_ref5 = _this.range) != null ? _ref5.set(bucketRange(d.bucket)) : void 0;
          } else {
            return (_ref6 = _this.range) != null ? _ref6.nullify() : void 0;
          }
        };
        for (_i = 0, _len = items.length; _i < _len; _i++) {
          item = items[_i];
          if (item.bucket != null) {
            item.brange = bucketRange(item.bucket);
          }
        }
        chart.selectAll('rect').data(items).enter().append('rect').attr('x', function(d, i) {
          return x(d.bucket) - 0.5;
        }).attr('y', h - bottomMargin).attr('width', function(d) {
          return Math.abs(x(d.bucket + 1) - x(d.bucket));
        }).attr('height', 0).classed('im-null-bucket', function(d) {
          return d.bucket === null;
        }).on('click', barClickHandler).each(function(d, i) {
          var title;

          title = getTitle(d);
          return $(this).tooltip({
            title: title,
            container: container
          });
        });
        rects = chart.selectAll('rect').data(items).transition().duration(intermine.options.D3.Transition.Duration).ease(intermine.options.D3.Transition.Easing).attr('y', function(d) {
          return h - bottomMargin - y(d.count) - 0.5;
        }).attr('height', function(d) {
          return y(d.count);
        });
        chart.append('line').attr('x1', 0).attr('x2', this.w).attr('y1', h - bottomMargin - .5).attr('y2', h - bottomMargin - .5).style('stroke', '#000');
        axis = chart.append('svg:g');
        axis.selectAll('line').data(x.ticks(n)).enter().append('svg:line').attr('x1', x).attr('x2', x).attr('y1', h - (bottomMargin * 0.75)).attr('y2', h - bottomMargin).attr('stroke', 'gray').attr('text-anchor', 'start');
        return this;
      };

      NumericFacet.prototype.drawEstCount = function() {
        var _ref5;

        if ((_ref5 = this.estCount) != null) {
          _ref5.remove();
        }
        if (typeof d3 === "undefined" || d3 === null) {
          return false;
        }
        return this.estCount = this.paper.append('text').classed('im-est-count', true).attr('x', this.w * 0.75).attr('y', 22).text("~" + (this.estimateCount()));
      };

      sumCounts = function(xs) {
        return _.reduce(xs, (function(total, x) {
          return total + x.count;
        }), 0);
      };

      fracWithinRange = function(range, min, max) {
        var overlap, rangeSize;

        if (!range) {
          return 0;
        }
        rangeSize = range.max - range.min;
        overlap = range.min < min ? Math.min(range.max, max) - min : max - Math.max(range.min, min);
        return overlap / rangeSize;
      };

      getPartialCount = function(min, max) {
        return function(item) {
          if (item != null) {
            return item.count * fracWithinRange(item.brange, min, max);
          } else {
            return 0;
          }
        };
      };

      NumericFacet.prototype.estimateCount = function() {
        var fullBuckets, left, max, min, partialLeft, partialRight, right, _ref5, _ref6;

        if (this.range.nulled) {
          return sumCounts(this.items.filter(function(i) {
            return i.bucket === null;
          }));
        } else {
          _ref5 = this.range.toJSON(), min = _ref5.min, max = _ref5.max;
          fullBuckets = sumCounts(this.items.filter(function(i) {
            return (i.brange != null) && i.brange.min >= min && i.brange.max <= max;
          }));
          partialLeft = this.items.filter(function(i) {
            return (i.brange != null) && i.brange.min < min && i.brange.max > min;
          })[0];
          partialRight = this.items.filter(function(i) {
            return (i.brange != null) && i.brange.max > max && i.brange.min < max;
          })[0];
          _ref6 = [partialLeft, partialRight].map(getPartialCount(min, max)), left = _ref6[0], right = _ref6[1];
          return this.round(fullBuckets + left + right);
        }
      };

      NumericFacet.prototype.drawSelection = function(x, width) {
        var _ref5;

        if ((_ref5 = this.selection) != null) {
          _ref5.remove();
        }
        if ((x <= 0) && (width >= this.w)) {
          return;
        }
        if (typeof d3 !== "undefined" && d3 !== null) {
          return this.selection = this.paper.append('svg:rect').attr('x', x).attr('y', 0).attr('width', width).attr('height', this.chartHeight * 0.9).classed('rubberband-selection', true);
        } else {
          return console.error("Cannot draw selection without SVG lib");
        }
      };

      NumericFacet.prototype._selecting_paths_ = false;

      return NumericFacet;

    })(FacetView);
    PieFacet = (function(_super) {
      var IGNORE_E, basicOps, getChartPalette, negateOps;

      __extends(PieFacet, _super);

      function PieFacet() {
        this.filterItems = __bind(this.filterItems, this);        _ref5 = PieFacet.__super__.constructor.apply(this, arguments);
        return _ref5;
      }

      PieFacet.prototype.className = 'im-grouped-facet im-pie-facet im-facet';

      PieFacet.prototype.chartHeight = 100;

      PieFacet.prototype.initialize = function(query, facet, items, hasMore, filterTerm) {
        var _ref6,
          _this = this;

        this.query = query;
        this.facet = facet;
        this.hasMore = hasMore;
        this.filterTerm = filterTerm;
        this.items = new Backbone.Collection(items);
        this.items.each(function(item) {
          return item.set({
            visibility: true,
            selected: false
          });
        });
        this.items.maxCount = (_ref6 = this.items.first()) != null ? _ref6.get("count") : void 0;
        this.items.on("change:selected", function() {
          var allAreSelected, someAreSelected;

          someAreSelected = _this.items.any(function(item) {
            return !!item.get("selected");
          });
          allAreSelected = !_this.items.any(function(item) {
            return !item.get("selected");
          });
          _this.$('.im-filter .btn-group .btn').attr("disabled", !someAreSelected);
          return _this.$('.im-filter .btn-toggle-selection').attr("disabled", allAreSelected).toggleClass("im-invert", someAreSelected);
        });
        return this.items.on('add', this.addItemRow, this);
      };

      basicOps = {
        single: '=',
        multi: 'ONE OF',
        absent: 'IS NULL'
      };

      negateOps = function(ops) {
        var ret;

        ret = {};
        ret.multi = ops.multi === 'ONE OF' ? 'NONE OF' : 'ONE OF';
        ret.single = ops.single === '=' ? '!=' : '=';
        ret.absent = ops.absent === 'IS NULL' ? 'IS NOT NULL' : 'IS NULL';
        return ret;
      };

      IGNORE_E = function(e) {
        e.preventDefault();
        return e.stopPropagation();
      };

      PieFacet.prototype.events = function() {
        var _this = this;

        return {
          'submit .im-facet form': IGNORE_E,
          'click .im-filter .btn-cancel': 'resetOptions',
          'click .im-filter .btn-toggle-selection': 'toggleSelection',
          'click .im-export-summary': 'exportSummary',
          'click .im-load-more': 'loadMoreItems',
          'click .im-filter .im-filter-in': function(e) {
            return _this.addConstraint(e, basicOps);
          },
          'click .im-filter .im-filter-out': function(e) {
            return _this.addConstraint(e, negateOps(basicOps));
          },
          'keyup .im-filter-values': _.throttle(this.filterItems, 750, {
            leading: false
          }),
          'click .im-clear-value-filter': 'clearValueFilter',
          'click': IGNORE_E
        };
      };

      PieFacet.prototype.filterItems = function(e) {
        var $input, current, parts, test,
          _this = this;

        $input = this.$('.im-filter-values');
        current = $input.val();
        if (this.hasMore || (this.filterTerm && current.length < this.filterTerm.length)) {
          if (this._filter_queued) {
            return;
          }
          this._filter_queued = true;
          return _.delay((function() {
            return _this.query.trigger('filter:summary', $input.val());
          }), 750);
        } else {
          parts = (current != null ? current : '').toLowerCase().split(/\s+/);
          test = function(str) {
            return _.all(parts, function(part) {
              return !!(str && ~str.toLowerCase().indexOf(part));
            });
          };
          return this.items.each(function(x) {
            return x.set({
              visibility: test(x.get('item'))
            });
          });
        }
      };

      PieFacet.prototype.clearValueFilter = function() {
        var $input;

        $input = this.$('.im-filter-values');
        $input.val(this.filterTerm);
        return this.items.each(function(x) {
          return x.set({
            visibility: true
          });
        });
      };

      PieFacet.prototype.loadMoreItems = function() {
        var loader, text,
          _this = this;

        if (this.summarising) {
          return;
        }
        loader = this.$('.im-load-more');
        text = loader.text();
        loader.html("<i class=\"icon-refresh icon-spin\"></i>");
        this.limit *= 2;
        this.summarising = this.query.filterSummary(this.facet.path, this.filterTerm, this.limit);
        this.summarising.done(function(items, stats, fcount) {
          var newItem, newItems, _i, _len;

          _this.hasMore = stats.uniqueValues > _this.limit;
          newItems = items.slice(_this.items.length);
          for (_i = 0, _len = newItems.length; _i < _len; _i++) {
            newItem = newItems[_i];
            _this.items.add(_.extend(newItem, {
              visibility: true,
              selected: false
            }));
          }
          return _this.query.trigger('got:summary:total', _this.facet.path, stats.uniqueValues, items.length, fcount);
        });
        this.summarising.done(function() {
          loader.empty().text(text);
          return loader.toggle(_this.hasMore);
        });
        return this.summarising.always(function() {
          return delete _this.summarising;
        });
      };

      PieFacet.prototype.exportSummary = function(e) {
        e.stopImmediatePropagation();
        return true;
      };

      PieFacet.prototype.changeSelection = function(f) {
        var tbody,
          _this = this;

        tbody = this.$('.im-item-table tbody')[0];
        return this.items.each(function(item) {
          return _.defer(function() {
            return f.call(_this, item);
          });
        });
      };

      PieFacet.prototype.resetOptions = function(e) {
        return this.changeSelection(function(item) {
          return item.set({
            selected: false
          });
        });
      };

      PieFacet.prototype.toggleSelection = function(e) {
        return this.changeSelection(function(item) {
          if (item.get('visibility')) {
            return item.set({
              selected: !item.get('selected')
            });
          }
        });
      };

      PieFacet.prototype.addConstraint = function(e, ops, vals) {
        var item, newCon, unselected;

        e.preventDefault();
        e.stopPropagation();
        newCon = {
          path: this.facet.path
        };
        if (vals == null) {
          vals = (function() {
            var _i, _len, _ref6, _results;

            _ref6 = this.items.where({
              selected: true
            });
            _results = [];
            for (_i = 0, _len = _ref6.length; _i < _len; _i++) {
              item = _ref6[_i];
              _results.push(item.get("item"));
            }
            return _results;
          }).call(this);
          unselected = this.items.where({
            selected: false
          });
          if ((!this.hasMore) && vals.length > unselected.length) {
            return this.addConstraint(e, negateOps(ops), (function() {
              var _i, _len, _results;

              _results = [];
              for (_i = 0, _len = unselected.length; _i < _len; _i++) {
                item = unselected[_i];
                _results.push(item.get('item'));
              }
              return _results;
            })());
          }
        }
        if (vals.length === 1) {
          if (vals[0] === null) {
            newCon.op = ops.absent;
          } else {
            newCon.op = ops.single;
            newCon.value = "" + vals[0];
          }
        } else {
          newCon.op = ops.multi;
          newCon.values = vals;
        }
        if (!this.facet.ignoreTitle) {
          newCon.title = this.facet.title;
        }
        return this.query.addConstraint(newCon);
      };

      PieFacet.prototype.render = function() {
        this.addChart();
        this.addControls();
        return this;
      };

      PieFacet.prototype.addChart = function() {
        var _this = this;

        this.chartElem = this.make("div");
        this.$el.append(this.chartElem);
        if (typeof d3 !== "undefined" && d3 !== null) {
          setTimeout((function() {
            return _this._drawD3Chart();
          }), 0);
        }
        return this;
      };

      getChartPalette = function() {
        var PieColors, paint;

        PieColors = intermine.options.PieColors;
        if (_.isFunction(PieColors)) {
          paint = PieColors;
        } else {
          paint = d3.scale[PieColors]();
        }
        return function(d, i) {
          return paint(i);
        };
      };

      PieFacet.prototype._drawD3Chart = function() {
        var arc, arc_group, centre_group, chart, colour, donut, getTween, h, ir, label_group, paths, percent, r, total, w, whiteCircle,
          _this = this;

        h = this.chartHeight;
        w = this.$el.closest(':visible').width();
        r = h * 0.4;
        ir = h * 0.1;
        donut = d3.layout.pie().value(function(d) {
          return d.get('count');
        });
        colour = getChartPalette();
        chart = d3.select(this.chartElem).append('svg').attr('class', 'chart').attr('height', h).attr('width', w);
        arc = d3.svg.arc().startAngle(function(d) {
          return d.startAngle;
        }).endAngle(function(d) {
          return d.endAngle;
        }).innerRadius(function(d) {
          if (d.data.get('selected')) {
            return ir + 5;
          } else {
            return ir;
          }
        }).outerRadius(function(d) {
          if (d.data.get('selected')) {
            return r + 5;
          } else {
            return r;
          }
        });
        arc_group = chart.append('svg:g').attr('class', 'arc').attr('transform', "translate(" + (w / 2) + "," + (h / 2) + ")");
        centre_group = chart.append('svg:g').attr('class', 'center_group').attr('transform', "translate(" + (w / 2) + "," + (h / 2) + ")");
        label_group = chart.append("svg:g").attr("class", "label_group").attr("transform", "translate(" + (w / 2) + "," + (h / 2) + ")");
        whiteCircle = centre_group.append("svg:circle").attr("fill", "white").attr("r", ir);
        getTween = function(d, i) {
          var j;

          j = d3.interpolate({
            startAngle: 0,
            endAngle: 0
          }, d);
          return function(t) {
            return arc(j(t));
          };
        };
        paths = arc_group.selectAll('path').data(donut(this.items.models));
        paths.enter().append('svg:path').attr('class', 'donut-arc').attr('stroke', 'white').attr('stroke-width', 0.5).attr('fill', colour).on('click', function(d, i) {
          return d.data.set({
            selected: !d.data.get('selected')
          });
        }).on('mouseover', function(d, i) {
          return d.data.trigger('hover');
        }).on('mouseout', function(d, i) {
          return d.data.trigger('unhover');
        }).transition().duration(intermine.options.D3.Transition.Duration).attrTween('d', getTween);
        total = this.items.reduce((function(sum, m) {
          return sum + m.get('count');
        }), 0);
        percent = function(d) {
          return (d.data.get('count') / total * 100).toFixed(1);
        };
        paths.each(function(d, i) {
          var placement, title;

          title = "" + (d.data.get('item')) + ": " + (percent(d)) + "%";
          placement = (d.endAngle + d.startAngle) / 2 > Math.PI ? 'left' : 'right';
          return $(this).tooltip({
            title: title,
            placement: placement,
            container: this.chartElem
          });
        });
        paths.transition().duration(intermine.options.D3.Transition.Duration).ease(intermine.options.D3.Transition.Easing).attrTween("d", getTween);
        this.items.on('change:selected', function() {
          paths.data(donut(_this.items.models)).attr('d', arc);
          return paths.transition().duration(intermine.options.D3.Transition.Duration).ease(intermine.options.D3.Transition.Easing);
        });
        return this;
      };

      PieFacet.prototype.filterControls = "<div class=\"input-prepend\">\n    <span class=\"add-on im-clear-value-filter\">\n      <i class=\"icon-refresh\"></i>\n    </span>\n    <input type=\"text\" class=\"input-medium  im-filter-values\" placeholder=\"Filter values\">\n</div>";

      PieFacet.prototype.getDownloadPopover = function() {
        var href, i, icons, lis, name, param;

        icons = intermine.icons;
        lis = (function() {
          var _results;

          _results = [];
          for (param in SUMMARY_FORMATS) {
            name = SUMMARY_FORMATS[param];
            href = "" + (this.query.getExportURI(param)) + "&summaryPath=" + this.facet.path;
            i = "<i class=\"" + icons[name] + "\"></i>";
            _results.push("<li><a href=\"" + href + "\"> " + i + " " + name + "</a></li>");
          }
          return _results;
        }).call(this);
        return "<ul class=\"im-export-summary\">" + (lis.join('')) + "</ul>";
      };

      PieFacet.prototype.addControls = function() {
        var $btns, $grp, DownloadData, DownloadFormat, More, imd, tbody, _ref6,
          _this = this;

        _ref6 = intermine.messages.facets, More = _ref6.More, DownloadData = _ref6.DownloadData, DownloadFormat = _ref6.DownloadFormat;
        $grp = $("<form class=\"form form-horizontal\">\n  " + this.filterControls + "\n  <div class=\"im-item-table\">\n    <table class=\"table table-condensed table-striped\">\n      <colgroup>\n        " + (this.colClasses.map(function(cl) {
          return "<col class=" + cl + ">";
        }).join('')) + "\n      </colgroup>\n      <thead>\n        <tr>" + (this.columnHeaders.map(function(h) {
          return "<th>" + h + "</th>";
        }).join('')) + "</tr>\n      </thead>\n      <tbody class=\"scrollable\"></tbody>\n    </table>\n    " + (this.hasMore ? '<div class="im-load-more">' + More + '</div>' : '') + "\n  </div>\n</form>");
        $grp.button();
        tbody = $grp.find('tbody')[0];
        this.items.each(function(item) {
          return _this.addItemRow(item, _this.items, {}, tbody);
        });
        $grp.append("<div class=\"im-filter\">\n  <button class=\"btn pull-right im-download\" >\n    <i class=\"" + intermine.icons.Download + "\"></i>\n    " + DownloadData + "\n  </button>\n  " + (this.buttons()) + "\n</div>");
        $btns = $grp.find('.im-filter .btn').tooltip({
          placement: 'top',
          container: this.el
        });
        $btns.on('click', function(e) {
          return $btns.tooltip('hide');
        });
        $grp.find('.dropdown-toggle').click(function(e) {
          var $parent, $this;

          $this = $(this);
          $parent = $this.parent();
          return $parent.toggleClass('open');
        });
        imd = $grp.find('.im-download').popover({
          placement: 'top',
          html: true,
          container: this.el,
          title: DownloadFormat,
          content: this.getDownloadPopover(),
          trigger: 'manual'
        });
        imd.click(function(e) {
          return imd.popover('toggle');
        });
        this.initFilter($grp);
        $grp.appendTo(this.el);
        return this;
      };

      PieFacet.prototype.addItemRow = function(item, items, opts, tbody) {
        if (tbody == null) {
          tbody = this.$('.im-item-table tbody').get()[0];
        }
        return tbody.appendChild(this.makeRow(item));
      };

      PieFacet.prototype.buttons = function() {
        return "<div class=\"btn-group\">\n  <button type=\"submit\" class=\"btn btn-primary im-filter-in\" disabled\n          title=\"" + intermine.messages.facets.Include + "\">\n    Filter\n  </button>\n  <button class=\"btn btn-primary dropdown-toggle\" \n          title=\"Select filter type\"  disabled>\n    <span class=\"caret\"></span>\n  </button>\n  <ul class=\"dropdown-menu\">\n    <li>\n      <a href=\"#\" class=\"im-filter-in\">\n        " + intermine.messages.facets.Include + "\n      </a>\n    </li>\n    <li>\n      <a href=\"#\" class=\"im-filter-out\">\n        " + intermine.messages.facets.Exclude + "\n      </a>\n    </li>\n  </ul>\n</div>\n\n<div class=\"btn-group\">\n  <button class=\"btn btn-cancel\" disabled\n            title=\"" + intermine.messages.facets.Reset + "\">\n    <i class=\"" + intermine.icons.Undo + "\"></i>\n  </button>\n  <button class=\"btn btn-toggle-selection\"\n          title=\"" + intermine.messages.facets.ToggleSelection + "\">\n    <i class=\"" + intermine.icons.Toggle + "\"></i>\n  </button>\n</div>";
      };

      PieFacet.prototype.initFilter = function($grp) {
        var $valFilter, sel;

        if (this.filterTerm == null) {
          return;
        }
        sel = '.im-filter-values';
        $valFilter = $grp != null ? $grp.find(sel) : this.$(sel);
        return $valFilter.val(this.filterTerm);
      };

      PieFacet.prototype.colClasses = ["im-item-selector", "im-item-value", "im-item-count"];

      PieFacet.prototype.columnHeaders = [' ', 'Item', 'Count'];

      PieFacet.prototype.makeRow = function(item) {
        var row;

        row = new FacetRow(item, this.items);
        return row.render().el;
      };

      return PieFacet;

    })(Backbone.View);
    FacetRow = (function(_super) {
      __extends(FacetRow, _super);

      function FacetRow() {
        _ref6 = FacetRow.__super__.constructor.apply(this, arguments);
        return _ref6;
      }

      FacetRow.prototype.tagName = "tr";

      FacetRow.prototype.className = "im-facet-row";

      FacetRow.prototype.isBelow = function() {
        var parent;

        parent = this.$el.closest('.im-item-table');
        return this.$el.offset().top + this.$el.outerHeight() > parent.offset().top + parent.outerHeight();
      };

      FacetRow.prototype.isAbove = function() {
        var parent;

        parent = this.$el.closest('.im-item-table');
        return this.$el.offset().top < parent.offset().top;
      };

      FacetRow.prototype.isVisible = function() {
        return !(this.isAbove() || this.isBelow());
      };

      FacetRow.prototype.initialize = function(item, items) {
        var _this = this;

        this.item = item;
        this.items = items;
        this.item.facetRow = this;
        this.listenTo(this.item, "change:selected", function() {
          return _this.onChangeSelected();
        });
        this.listenTo(this.item, "change:visibility", function() {
          return _this.onChangeVisibility();
        });
        this.listenTo(this.item, 'hover', function() {
          var above, itemTable, newTop, surrogate;

          _this.$el.addClass('hover');
          if (!_this.isVisible()) {
            above = _this.isAbove();
            surrogate = $("<div class=\"im-facet-surrogate " + (above ? 'above' : 'below') + "\">\n    <i class=\"icon-caret-" + (above ? 'up' : 'down') + "\"></i>\n    " + (_this.item.get('item')) + ": " + (_this.item.get('count')) + "\n</div>");
            itemTable = _this.$el.closest('.im-item-table').append(surrogate);
            newTop = above ? itemTable.offset().top + itemTable.scrollTop() : itemTable.scrollTop() + itemTable.offset().top + itemTable.outerHeight() - surrogate.outerHeight();
            return surrogate.offset({
              top: newTop
            });
          }
        });
        return this.listenTo(this.item, 'unhover', function() {
          var s;

          _this.$el.removeClass('hover');
          return s = _this.$el.closest('.im-item-table').find('.im-facet-surrogate').fadeOut('fast', function() {
            return s.remove();
          });
        });
      };

      FacetRow.prototype.initState = function() {
        this.onChangeVisibility();
        return this.onChangeSelected();
      };

      FacetRow.prototype.onChangeVisibility = function() {
        return this.$el.toggle(this.item.get("visibility"));
      };

      FacetRow.prototype.onChangeSelected = function() {
        var f, isSelected,
          _this = this;

        isSelected = !!this.item.get("selected");
        if (this.item.has("path")) {
          item.get("path").node.setAttribute("class", isSelected ? "selected" : "");
        }
        f = function() {
          _this.$el.toggleClass("active", isSelected);
          if (isSelected !== _this.$('input').prop("checked")) {
            return _this.$('input').prop("checked", isSelected);
          }
        };
        return setTimeout(f, 0);
      };

      FacetRow.prototype.events = {
        'click': 'handleClick',
        'change input': 'handleChange'
      };

      FacetRow.prototype.render = function() {
        var opacity, percent, ratio, _ref7;

        ratio = parseInt(this.item.get("count"), 10) / this.items.maxCount;
        opacity = ratio.toFixed(2) / 2 + 0.5;
        percent = (ratio * 100).toFixed(1);
        this.$el.append("<td class=\"im-selector-col\">\n    <span>" + ((this.item.get("symbol")) || "") + "</span>\n    <input type=\"checkbox\">\n</td>\n<td class=\"im-item-col\">\n  " + ((_ref7 = this.item.get("item")) != null ? _ref7 : '<span class=null-value>&nbsp;</span>') + "\n</td>\n<td class=\"im-count-col\">\n    <div class=\"im-facet-bar\"\n         style=\"width:" + percent + "%;background:rgba(206, 210, 222, " + opacity + ")\">\n      <span class=\"im-count\">\n        " + (this.item.get("count")) + "\n      </span>\n    </div>\n</td>");
        if (this.item.get("percent")) {
          this.$el.append("<td class=\"im-prop-col\"><i>" + (this.item.get("percent").toFixed()) + "%</i></td>");
        }
        this.initState();
        return this;
      };

      FacetRow.prototype.handleClick = function(e) {
        e.stopPropagation();
        if (e.target.type !== 'checkbox') {
          return this.$('input').trigger("click");
        }
      };

      FacetRow.prototype.handleChange = function(e) {
        var _this = this;

        e.stopPropagation();
        return setTimeout((function() {
          return _this.item.set("selected", _this.$('input').is(':checked'));
        }), 0);
      };

      return FacetRow;

    })(Backbone.View);
    HistoFacet = (function(_super) {
      __extends(HistoFacet, _super);

      function HistoFacet() {
        _ref7 = HistoFacet.__super__.constructor.apply(this, arguments);
        return _ref7;
      }

      HistoFacet.prototype.className = 'im-grouped-facet im-facet';

      HistoFacet.prototype.chartHeight = 50;

      HistoFacet.prototype.leftMargin = 25;

      HistoFacet.prototype.colClasses = ["im-item-selector", "im-item-value", "im-item-count"];

      HistoFacet.prototype.columnHeaders = [' ', 'Item', 'Count'];

      HistoFacet.prototype._drawD3Chart = function() {
        var chart, data, f, h, itemW, max, n, onSelection, rectClass, rects, w, x, y,
          _this = this;

        if (this.items.all(function(i) {
          return 1 === i.get('count');
        })) {
          return this;
        }
        data = this.items.models;
        w = this.$el.closest(':visible').width() * 0.95;
        n = data.length;
        itemW = (w - this.leftMargin) / data.length;
        h = this.chartHeight;
        f = this.items.first();
        max = f.get("count");
        x = d3.scale.linear().domain([0, n]).range([this.leftMargin, w]);
        y = d3.scale.linear().domain([0, max]).rangeRound([0, h]);
        chart = d3.select(this.chartElem).append('svg').attr('class', 'chart').attr('width', w).attr('height', h);
        rectClass = n > w / 4 ? 'squashed' : 'bar';
        rects = chart.selectAll('rect');
        rects.data(data).enter().append('rect').attr('class', rectClass).attr('width', itemW).attr('y', h).attr('height', 0).attr('x', function(d, i) {
          return x(i) - 0.5;
        }).on('click', function(d, i) {
          return d.set({
            selected: !d.get('selected')
          });
        }).on('mouseover', function(d, i) {
          return d.trigger('hover');
        }).on('mouseout', function(d, i) {
          return d.trigger('unhover');
        });
        chart.selectAll('rect').data(this.items.models).transition().duration(intermine.options.D3.Transition.Duration).ease(intermine.options.D3.Transition.Easing).attr('y', function(d) {
          return h - y(d.get('count')) - 0.5;
        }).attr('height', function(d) {
          return y(d.get('count'));
        });
        chart.append('line').attr('x1', 0).attr('x2', w).attr('y1', h - .5).attr('y2', h - .5).style('stroke', '#000');
        onSelection = function() {
          return _.defer(function() {
            return chart.selectAll('rect').data(_this.items.models).transition().duration(intermine.options.D3.Transition.Duration).ease(intermine.options.D3.Transition.Easing).attr('class', function(d) {
              return rectClass + (d.get('selected') ? '-selected' : '');
            });
          });
        };
        this.items.on('change:selected', _.throttle(onSelection, 150));
        return this;
      };

      return HistoFacet;

    })(PieFacet);
    BooleanFacet = (function(_super) {
      __extends(BooleanFacet, _super);

      function BooleanFacet() {
        _ref8 = BooleanFacet.__super__.constructor.apply(this, arguments);
        return _ref8;
      }

      BooleanFacet.prototype.initialize = function() {
        var _this = this;

        BooleanFacet.__super__.initialize.apply(this, arguments);
        if (this.items.length === 2) {
          return this.items.on('change:selected', function(x, selected) {
            var someAreSelected;

            _this.items.each(function(y) {
              if (selected && x !== y) {
                return y.set({
                  selected: false
                });
              }
            });
            someAreSelected = _this.items.any(function(item) {
              return !!item.get("selected");
            });
            return _this.$('.im-filtering.btn').attr("disabled", !someAreSelected);
          });
        }
      };

      BooleanFacet.prototype.filterControls = '';

      BooleanFacet.prototype.initFilter = function() {};

      BooleanFacet.prototype.buttons = function() {
        return "<button type=\"submit\" class=\"btn btn-primary im-filtering im-filter-in\" disabled>Filter</button>\n<button class=\"btn btn-cancel im-filtering\" disabled>Reset</button>";
      };

      return BooleanFacet;

    })(PieFacet);
    return scope("intermine.results", {
      ColumnSummary: ColumnSummary,
      FacetView: FacetView,
      FrequencyFacet: FrequencyFacet,
      NumericFacet: NumericFacet,
      PieFacet: PieFacet,
      FacetRow: FacetRow,
      HistoFacet: HistoFacet,
      BooleanFacet: BooleanFacet
    });
  })();

  scope("intermine.messages.filters", {
    AddNew: "Add Filter",
    DefineNew: 'Define a new filter',
    EditOrRemove: 'edit or remove the currently active filters',
    None: 'No active filters',
    Heading: "Active Filters"
  });

  scope("intermine.css", {
    FilterBoxClass: 'well'
  });

  (function() {
    var Constraints, FACETS, Facets, FilterManager, Filters, SingleColumnConstraints, SingleColumnConstraintsSummary, SingleConstraintAdder, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6;

    Filters = (function(_super) {
      __extends(Filters, _super);

      function Filters() {
        _ref = Filters.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      Filters.prototype.className = "im-query-filters";

      Filters.prototype.initialize = function(query) {
        this.query = query;
      };

      Filters.prototype.render = function() {
        var constraints, facets;

        constraints = new Constraints(this.query);
        constraints.render().$el.appendTo(this.el);
        facets = new Facets(this.query);
        facets.render().$el.appendTo(this.el);
        return this;
      };

      return Filters;

    })(Backbone.View);
    FACETS = {
      Gene: [
        {
          title: "Pathways",
          path: "pathways.name"
        }, {
          title: "Expression Term",
          path: "mRNAExpressionResults.mRNAExpressionTerms.name"
        }, {
          title: "Ontology Term",
          path: "ontologyAnnotations.ontologyTerm.name"
        }, {
          title: "Protein Domains",
          path: "proteins.proteinDomains.name"
        }
      ]
    };
    Facets = (function(_super) {
      __extends(Facets, _super);

      function Facets() {
        this.render = __bind(this.render, this);        _ref1 = Facets.__super__.constructor.apply(this, arguments);
        return _ref1;
      }

      Facets.prototype.className = "im-query-facets";

      Facets.prototype.tagName = "dl";

      Facets.prototype.initialize = function(query) {
        this.query = query;
        this.query.on("change:constraints", this.render);
        return this.query.on("change:joins", this.render);
      };

      Facets.prototype.render = function() {
        var cs, f, facets, searcher, simplify, v, _i, _len,
          _this = this;

        this.$el.empty();
        simplify = function(x) {
          return x.replace(/^[^\.]+\./, "").replace(/\./g, " > ");
        };
        facets = (FACETS[this.query.root] || []).concat((function() {
          var _i, _len, _ref2, _results;

          _ref2 = this.query.views;
          _results = [];
          for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
            v = _ref2[_i];
            _results.push({
              title: simplify(v),
              path: v
            });
          }
          return _results;
        }).call(this));
        if (facets) {
          searcher = this.make("input", {
            "class": "input-long",
            placeholder: "Filter facets..."
          });
          $(searcher).appendTo(this.el).keyup(function(e) {
            var pattern;

            pattern = new RegExp($(e.target).val(), "i");
            return _this.query.trigger("filter:facets", pattern);
          });
          for (_i = 0, _len = facets.length; _i < _len; _i++) {
            f = facets[_i];
            cs = new intermine.results.ColumnSummary(f, this.query);
            this.$el.append(cs.el);
            cs.render();
          }
        }
        return this;
      };

      return Facets;

    })(Backbone.View);
    Constraints = (function(_super) {
      __extends(Constraints, _super);

      function Constraints() {
        this.render = __bind(this.render, this);        _ref2 = Constraints.__super__.constructor.apply(this, arguments);
        return _ref2;
      }

      Constraints.prototype.className = "im-constraints";

      Constraints.prototype.initialize = function(query) {
        this.query = query;
        return this.query.on("change:constraints", this.render);
      };

      Constraints.prototype.getConstraints = function() {
        return this.query.constraints;
      };

      Constraints.prototype.getConAdder = function() {
        return new intermine.query.ConstraintAdder(this.query);
      };

      Constraints.prototype.render = function() {
        var c, conBox, cons, msgs, ul, _fn, _i, _len, _ref3,
          _this = this;

        cons = this.getConstraints();
        msgs = intermine.messages.filters;
        this.$el.empty();
        this.$el.append(this.make("h3", {}, msgs.Heading));
        conBox = $("<div class=\"" + intermine.css.FilterBoxClass + "\">");
        conBox.appendTo(this.el).append(this.make("p", {
          "class": 'well-help'
        }, cons.length ? msgs.EditOrRemove : msgs.None)).append(ul = this.make("ul", {}));
        _fn = function(c) {
          var con;

          con = new intermine.query.ActiveConstraint(_this.query, c);
          return con.render().$el.appendTo($(ul));
        };
        for (_i = 0, _len = cons.length; _i < _len; _i++) {
          c = cons[_i];
          _fn(c);
        }
        if ((_ref3 = this.getConAdder()) != null) {
          _ref3.render().$el.appendTo(this.el);
        }
        return this;
      };

      Constraints.prototype.events = {
        click: function(e) {
          return e.stopPropagation();
        }
      };

      return Constraints;

    })(Backbone.View);
    FilterManager = (function(_super) {
      __extends(FilterManager, _super);

      function FilterManager() {
        _ref3 = FilterManager.__super__.constructor.apply(this, arguments);
        return _ref3;
      }

      FilterManager.prototype.className = "im-filter-manager modal";

      FilterManager.prototype.tagName = "div";

      FilterManager.prototype.initialize = function(query) {
        var _this = this;

        this.query = query;
        return this.query.on('change:constraints', function() {
          return _this.hideModal();
        });
      };

      FilterManager.prototype.html = "<div class=\"modal-header\">\n    <a class=\"close im-closer\">close</a>\n    <h3>" + intermine.messages.filters.Heading + "</h3>\n</div>\n<div class=\"modal-body\">\n    <div class=\"" + intermine.css.FilterBoxClass + "\">\n        <p class=\"well-help\"></p>\n        <ul></ul>\n    </div>\n    <button class=\"btn im-closer im-define-new-filter\">\n        " + intermine.messages.filters.DefineNew + "\n    </button>\n</div>";

      FilterManager.prototype.events = {
        'hidden': 'remove',
        'click .icon-remove-sign': 'hideModal',
        'click .im-closer': 'hideModal',
        'click .im-define-new-filter': 'addNewFilter'
      };

      FilterManager.prototype.addNewFilter = function(e) {
        return this.query.trigger('add-filter-dialogue:please');
      };

      FilterManager.prototype.hideModal = function(e) {
        this.$el.modal('hide');
        return $('.modal-backdrop').trigger('click');
      };

      FilterManager.prototype.showModal = function() {
        return this.$el.modal().modal('show');
      };

      FilterManager.prototype.render = function() {
        var c, cons, msgs, ul, _fn, _i, _len,
          _this = this;

        this.$el.append(this.html);
        cons = this.getConstraints();
        msgs = intermine.messages.filters;
        this.$('.well-help').append(cons.length ? msgs.EditOrRemove : msgs.None);
        ul = this.$('ul');
        _fn = function(c) {
          var con;

          con = new intermine.query.ActiveConstraint(_this.query, c);
          return con.render().$el.appendTo(ul);
        };
        for (_i = 0, _len = cons.length; _i < _len; _i++) {
          c = cons[_i];
          _fn(c);
        }
        return this;
      };

      return FilterManager;

    })(Constraints);
    SingleConstraintAdder = (function(_super) {
      __extends(SingleConstraintAdder, _super);

      function SingleConstraintAdder() {
        _ref4 = SingleConstraintAdder.__super__.constructor.apply(this, arguments);
        return _ref4;
      }

      SingleConstraintAdder.prototype.initialize = function(query, view) {
        var _this = this;

        this.view = view;
        SingleConstraintAdder.__super__.initialize.call(this, query);
        return this.query.on('cancel:add-constraint', function() {
          return _this.$('.btn-primary').toggle(_this.getTreeRoot().isAttribute());
        });
      };

      SingleConstraintAdder.prototype.initPaths = function() {
        return [this.view];
      };

      SingleConstraintAdder.prototype.getTreeRoot = function() {
        return this.query.getPathInfo(this.view);
      };

      SingleConstraintAdder.prototype.render = function() {
        SingleConstraintAdder.__super__.render.call(this);
        this.$('input').remove();
        root = this.getTreeRoot();
        console.log(this.view);
        if (root.isAttribute()) {
          this.chosen = root;
          this.$('button.btn-primary').text(intermine.messages.filters.DefineNew).attr({
            disabled: false
          });
          this.$('button.btn-chooser').remove();
        }
        return this;
      };

      return SingleConstraintAdder;

    })(intermine.query.ConstraintAdder);
    SingleColumnConstraints = (function(_super) {
      __extends(SingleColumnConstraints, _super);

      function SingleColumnConstraints() {
        _ref5 = SingleColumnConstraints.__super__.constructor.apply(this, arguments);
        return _ref5;
      }

      SingleColumnConstraints.prototype.initialize = function(query, view) {
        this.view = view;
        return SingleColumnConstraints.__super__.initialize.call(this, query);
      };

      SingleColumnConstraints.prototype.getConAdder = function() {
        return null;
      };

      SingleColumnConstraints.prototype.getConstraints = function() {
        var c, _i, _len, _ref6, _results;

        _ref6 = this.query.constraints;
        _results = [];
        for (_i = 0, _len = _ref6.length; _i < _len; _i++) {
          c = _ref6[_i];
          if (c.path.match(this.view)) {
            _results.push(c);
          }
        }
        return _results;
      };

      return SingleColumnConstraints;

    })(Constraints);
    SingleColumnConstraintsSummary = (function(_super) {
      __extends(SingleColumnConstraintsSummary, _super);

      function SingleColumnConstraintsSummary() {
        _ref6 = SingleColumnConstraintsSummary.__super__.constructor.apply(this, arguments);
        return _ref6;
      }

      SingleColumnConstraintsSummary.prototype.getConAdder = function() {};

      SingleColumnConstraintsSummary.prototype.render = function() {
        var cons;

        SingleColumnConstraintsSummary.__super__.render.call(this);
        cons = this.getConstraints();
        if (cons.length < 1) {
          this.undelegateEvents();
          this.$el.hide();
        }
        return this;
      };

      return SingleColumnConstraintsSummary;

    })(SingleColumnConstraints);
    return scope("intermine.query.filters", {
      SingleColumnConstraintsSummary: SingleColumnConstraintsSummary,
      SingleColumnConstraints: SingleColumnConstraints,
      Filters: Filters,
      FilterManager: FilterManager
    });
  })();

  define('formatters/bio/core/chromosome-location', function() {
    var ChrLocFormatter, fetch;

    fetch = function(service, id) {
      return service.rows({
        from: 'Location',
        select: ChrLocFormatter.replaces,
        where: {
          id: id
        }
      });
    };
    return ChrLocFormatter = (function() {
      ChrLocFormatter.replaces = ['locatedOn.primaryIdentifier', 'start', 'end'];

      ChrLocFormatter.merge = function(location, chromosome) {
        if (chromosome.has('primaryIdentifier')) {
          return location.set({
            chr: chromosome.get('primaryIdentifier')
          });
        }
      };

      function ChrLocFormatter(model) {
        var chr, end, id, needs, start, _ref;

        id = model.get('id');
        this.$el.addClass('chromosome-location');
        needs = ['start', 'end', 'chr'];
        if (!((model._fetching != null) || _.all(needs, function(n) {
          return model.has(n);
        }))) {
          model._fetching = fetch(this.options.query.service, id);
          model._fetching.done(function(_arg) {
            var chr, end, start, _ref;

            _ref = _arg[0], chr = _ref[0], start = _ref[1], end = _ref[2];
            return model.set({
              chr: chr,
              start: start,
              end: end
            });
          });
        }
        _ref = model.toJSON(), start = _ref.start, end = _ref.end, chr = _ref.chr;
        return "" + chr + ":" + start + "-" + end;
      }

      return ChrLocFormatter;

    })();
  });

  define('formatters/bio/core/organism', function() {
    var Organism, ensureData, getData, templ;

    getData = function(model, prop, backupProp) {
      var ret, val;

      ret = {};
      val = ret[prop] = model.get(prop);
      if (val == null) {
        ret[prop] = model.get(backupProp);
      }
      return ret;
    };
    ensureData = function(model, service) {
      var p;

      if ((model._fetching != null) || model.has('shortName')) {
        return;
      }
      model._fetching = p = service.findById('Organism', model.get('id'));
      return p.done(function(org) {
        return model.set({
          shortName: org.shortName
        });
      });
    };
    templ = _.template("<span class=\"name\"><%- shortName %></span>");
    return Organism = function(model) {
      var data;

      this.$el.addClass('organism');
      ensureData(model, this.options.query.service);
      if (model.get('id')) {
        data = getData(model, 'shortName', 'name');
        return templ(data);
      } else {
        return "<span class=\"null-value\">&nbsp;</span>";
      }
    };
  });

  define('formatters/bio/core/publication', function() {
    var PublicationFormatter;

    PublicationFormatter = function(model) {
      var firstAuthor, id, title, year, _ref, _ref1;

      id = model.get('id');
      this.$el.addClass('publication');
      if (!(model.has('title') && model.has('firstAuthor') && model.has('year'))) {
        if ((_ref = model._formatter_promise) == null) {
          model._formatter_promise = this.options.query.service.findById('Publication', id);
        }
        model._formatter_promise.done(function(pub) {
          return model.set(pub);
        });
      }
      _ref1 = model.toJSON(), title = _ref1.title, firstAuthor = _ref1.firstAuthor, year = _ref1.year;
      return "" + title + " (" + firstAuthor + ", " + year + ")";
    };
    PublicationFormatter.replaces = ['title', 'firstAuthor', 'year'];
    return PublicationFormatter;
  });

  define('formatters/bio/core/sequence', function() {
    var SequenceFormatter, lineLength;

    lineLength = 40;
    return SequenceFormatter = function(model) {
      var id, line, lines, rest, sequence, _ref;

      id = model.get('id');
      this.$el.addClass('dna-sequence');
      if (!model.has('residues')) {
        if ((_ref = model._formatter_promise) == null) {
          model._formatter_promise = this.options.query.service.findById('Sequence', id);
        }
        model._formatter_promise.done(function(seq) {
          return model.set(seq);
        });
      }
      sequence = model.get('residues') || '';
      lines = [];
      while (sequence.length > 0) {
        line = sequence.slice(0, lineLength);
        rest = sequence.slice(lineLength);
        lines.push(line);
        sequence = rest;
      }
      return ((function() {
        var _i, _len, _results;

        _results = [];
        for (_i = 0, _len = lines.length; _i < _len; _i++) {
          line = lines[_i];
          _results.push("<code>" + line + "</code>");
        }
        return _results;
      })()).join("<br/>");
    };
  });

  bio_formatters = (function() {
    var _i, _len, _ref, _results;

    _ref = ['chromosome-location', 'sequence', 'organism', 'publication'];
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      x = _ref[_i];
      _results.push("formatters/bio/core/" + x);
    }
    return _results;
  })();

  define('formatters/bio/core', using.apply(null, __slice.call(bio_formatters).concat([function(Chr, Seq, Org, Pub) {
    scope('intermine.results.formatters', {
      Location: Chr,
      Sequence: Seq,
      Publication: Pub,
      Organism: Org
    });
    return scope('intermine.results.formatsets.genomic', {
      'Location.start': false,
      'Location.end': false,
      'Organism.name': false,
      'Publication.title': false,
      'Sequence.residues': false
    });
  }])));

  scope("intermine.results", {
    getFormatter: function(path) {
      var a, ancestors, cd, fieldName, formats, formatter, _i, _len, _ref;

      if (path == null) {
        return null;
      }
      cd = path.isAttribute() ? path.getParent().getType() : path.getType();
      ancestors = [cd.name].concat(path.model.getAncestorsOf(cd.name));
      formats = (_ref = intermine.results.formatsets[path.model.name]) != null ? _ref : {};
      fieldName = path.end.name;
      for (_i = 0, _len = ancestors.length; _i < _len; _i++) {
        a = ancestors[_i];
        formatter = formats["" + a + ".*"] || formats["" + a + "." + fieldName];
        if (formatter === true) {
          formatter = intermine.results.formatters[a];
        }
        if (formatter != null) {
          return formatter;
        }
      }
      return null;
    },
    shouldFormat: function(path, formatSet) {
      var a, ancestors, cd, fieldName, formats, formatterAvailable, model, _i, _len, _ref;

      if (!path.isAttribute()) {
        return false;
      }
      model = path.model;
      if (formatSet == null) {
        formatSet = model.name;
      }
      cd = path.isAttribute() ? path.getParent().getType() : path.getType();
      fieldName = path.end.name;
      formatterAvailable = intermine.results.getFormatter(path) != null;
      if (!formatterAvailable) {
        return false;
      }
      if (fieldName === 'id') {
        return true;
      }
      ancestors = [cd.name].concat(path.model.getAncestorsOf(cd.name));
      formats = (_ref = intermine.results.formatsets[formatSet]) != null ? _ref : {};
      for (_i = 0, _len = ancestors.length; _i < _len; _i++) {
        a = ancestors[_i];
        if (formats["" + a + ".*"] || formats["" + a + "." + fieldName]) {
          return true;
        }
      }
      return false;
    }
  });

  define('html/append-list', function() {
    return "<div class=\"modal\">\n  <div class=\"modal-header\">\n    <a class=\"close btn-cancel\">close</a>\n    <h2>Add Items To Existing List</h2>\n  </div>\n  <div class=\"modal-body\">\n    <form class=\"form-horizontal form\">\n      <fieldset class=\"control-group\">\n        <label>\n          Add\n          <span class=\"im-item-count\"></span>\n          <span class=\"im-item-type\"></span>\n          to:\n          <select class=\"im-receiving-list input-xlarge\">\n              <option value=\"\"><i>Select a list</i></option>\n          </select>\n        </label>\n        <span class=\"help-inline\"></span>\n      </fieldset>\n    </form>\n    <div class=\"alert alert-error im-none-compatible-error\">\n      <b>Sorry!</b> You don't have access to any compatible lists.\n    </div>\n    <div class=\"alert alert-info im-selection-instruction\">\n      <b>Get started!</b> Choose items from the table below.\n      You can move this dialogue around by dragging it, if you \n      need access to a column it is covering up.\n    </div>\n  </div>\n  <div class=\"modal-footer\">\n    <div class=\"btn-group\">\n      <button disabled class=\"btn btn-primary\">Add to list</button>\n      <button class=\"btn btn-cancel\">Cancel</button>\n    </div>\n  </div>\n</div>";
  });

  define('html/code-gen', function() {
    return _.template("<div class=\"btn-group\">\n    <a class=\"btn btn-action\">\n        <i class=\"" + intermine.icons.Script + "\"></i>\n        <span class=\"im-only-widescreen\">Get</span>\n        <span class=\"im-code-lang hidden-tablet\"></span>\n        <span class=\"hidden-tablet\">Code</span>\n    </a>\n    <a class=\"btn dropdown-toggle\" data-toggle=\"dropdown\">\n        <span class=\"caret\"></span>\n    </a>\n    <ul class=\"dropdown-menu\">\n        <% _(langs).each(function(lang) { %>\n          <li>\n            <a data-lang=\"<%= lang.extension %>\">\n                <i class=\"icon-<%= lang.extension %>\"></i>\n                <%= lang.name %>\n            </a>\n          </li>\n        <% }); %>\n    </ul>\n</div>\n<div class=\"modal\">\n    <div class=\"modal-header\">\n        <a class=\"close im-closer\" data-dismiss=\"modal\">close</a>\n        <h3>Generated <span class=\"im-code-lang\"></span> Code</h3>\n    </div>\n    <div class=\"modal-body\">\n        <pre class=\"im-generated-code prettyprint linenums\">\n        </pre>\n    </div>\n    <div class=\"modal-footer\">\n        <a class=\"btn btn-save\"><i class=\"icon-file\"></i>Save</a>\n        <a data-dismiss=\"modal\" class=\"btn im-closer\">Close</a>\n    </div>\n</div>");
  });

  define('html/new-list', function() {
    return "<div class=\"modal im-list-creation-dialogue\">\n    <div class=\"modal-header\">\n        <a class=\"close btn-cancel\">close</a>\n        <a class=\"im-minimise\">&nbsp;</a>\n        <h2>List Details</h2>\n    </div>\n    <div class=\"modal-body\">\n        <form class=\"form form-horizontal\">\n            <p class=\"im-list-summary\"></p>\n            <fieldset class=\"control-group\">\n                <label>Name</label>\n                <input class=\"im-list-name span10\" type=\"text\" placeholder=\"required identifier\">\n                <span class=\"help-inline\"></span>\n            </fieldset>\n            <fieldset class=\"control-group\">\n                <label>Description</label>\n                <input class=\"im-list-desc span10\" type=\"text\" placeholder=\"an optional description\" >\n            </fieldset>\n            <fieldset class=\"control-group im-tag-options\">\n                <label>Add Tags</label>\n                <input type=\"text\" class=\"im-available-tags input-medium\" placeholder=\"categorize your list\">\n                <button class=\"btn im-confirm-tag\" disabled>Add</button>\n                <ul class=\"im-list-tags choices well\">\n                    <div style=\"clear:both\"></div>\n                </ul>\n                <h5><i class=\"icon-chevron-down\"></i>Suggested Tags</h5>\n                <ul class=\"im-list-tags suggestions well\">\n                    <div style=\"clear:both\"></div>\n                </ul>\n            </fieldset>\n            <input type=\"hidden\" class=\"im-list-type\">\n        </form>\n        <div class=\"alert alert-info im-selection-instruction\">\n            <b>Get started!</b> Choose items from the table below.\n            You can move this dialogue around by dragging it, if you \n            need access to a column it is covering up.\n        </div>\n    </div>\n    <div class=\"modal-footer\">\n        <div class=\"btn-group\">\n            <button class=\"btn btn-primary\">Create</button>\n            <button class=\"btn btn-cancel\">Cancel</button>\n            <button class=\"btn btn-reset\">Reset</button>\n        </div>\n    </div>\n</div>";
  });

  (function() {
    var FPObject, IMObject, NullObject, _ref, _ref1, _ref2;

    IMObject = (function(_super) {
      __extends(IMObject, _super);

      function IMObject() {
        _ref = IMObject.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      IMObject.prototype.initialize = function(obj, query, field, base, history) {
        var model,
          _this = this;

        obj[field] = obj.value;
        obj['obj:type'] = obj["class"];
        obj['service:base'] = base;
        obj['service:url'] = obj.url;
        obj['is:selected'] = false;
        obj['is:selectable'] = true;
        obj['is:selecting'] = false;
        this.set(obj);
        model = query.model;
        query.on("selection:cleared", function() {
          return _this.set({
            'is:selectable': true
          });
        });
        query.on("common:type:selected", function(type) {
          var ok;

          ok = !type || model.findSharedAncestor(type, _this.get('obj:type'));
          return _this.set({
            'is:selectable': !!ok
          });
        });
        this.on("change:is:selected", function(self, selected) {
          return query.trigger("imo:selected", _this.get("obj:type"), _this.get("id"), selected);
        });
        return this.on('click', function() {
          return query.trigger('imo:click', _this.get('obj:type'), _this.get('id'), _this.toJSON());
        });
      };

      IMObject.prototype.selectionState = function() {
        return {
          selected: this.get('is:selected'),
          selecting: this.get('is:selecting'),
          selectable: this.get('is:selectable')
        };
      };

      IMObject.prototype.merge = function(obj, field) {
        return this.set(field, obj.value);
      };

      return IMObject;

    })(Backbone.Model);
    NullObject = (function(_super) {
      __extends(NullObject, _super);

      function NullObject() {
        _ref1 = NullObject.__super__.constructor.apply(this, arguments);
        return _ref1;
      }

      NullObject.prototype.initialize = function(_, _arg) {
        var field, query, type;

        query = _arg.query, field = _arg.field, type = _arg.type;
        this.set({
          'id': null,
          'obj:type': type,
          'is:selected': false,
          'is:selectable': false,
          'is:selecting': false,
          'service:base': '',
          'service:url': ''
        });
        if (field) {
          return this.set(field, null);
        }
      };

      NullObject.prototype.merge = function() {};

      return NullObject;

    })(IMObject);
    FPObject = (function(_super) {
      __extends(FPObject, _super);

      function FPObject() {
        _ref2 = FPObject.__super__.constructor.apply(this, arguments);
        return _ref2;
      }

      FPObject.prototype.initialize = function(_arg, _arg1) {
        var field, obj, query;

        _arg;
        query = _arg1.query, obj = _arg1.obj, field = _arg1.field;
        this.set({
          'id': null,
          'obj:type': obj["class"],
          'is:selected': false,
          'is:selectable': false,
          'is:selecting': false,
          'service:base': '',
          'service:url': ''
        });
        return this.set(field, obj.value);
      };

      return FPObject;

    })(NullObject);
    return scope("intermine.model", {
      IMObject: IMObject,
      NullObject: NullObject,
      FPObject: FPObject
    });
  })();

  (function() {
    var SVG, supportsSVG;

    SVG = "http://www.w3.org/TR/SVG11/feature#Shape";
    supportsSVG = function() {
      var _ref;

      return (typeof SVGAngle !== "undefined" && SVGAngle !== null) || (window.SVGAngle != null) || ((_ref = document.implementation) != null ? typeof _ref.hasFeature === "function" ? _ref.hasFeature(SVG, "1.0") : void 0 : void 0);
    };
    /*
    # Add a 'destroyed' event on element removal.
    */

    jQuery.event.special.destroyed = {
      remove: function(o) {
        if (o.type !== 'destroyed') {
          return typeof o.handler === "function" ? o.handler() : void 0;
        }
      }
    };
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

    (function($) {
      var proto, _mouseInit;

      $.support.touch = typeof Touch === 'object';
      if (!$.support.touch) {
        return false;
      }
      proto = $.ui.mouse.prototype;
      _mouseInit = proto._mouseInit;
      return $.extend(proto, {
        _mouseInit: function() {
          this.element.bind("touchstart." + this.widgetName, $.proxy(this, "_touchStart"));
          return _mouseInit.apply(this, arguments);
        },
        _touchStart: function(event) {
          if (event.originalEvent.targetTouches.length !== 1) {
            return false;
          }
          this.element.bind("touchmove." + this.widgetName, $.proxy(this, "_touchMove")).bind("touchend." + this.widgetName, $.proxy(this, "_touchEnd"));
          this._modifyEvent(event);
          $(document).trigger($.Event("mouseup"));
          this._mouseDown(event);
          return false;
        },
        _touchMove: function(event) {
          this._modifyEvent(event);
          return this._mouseMove(event);
        },
        _touchEnd: function(event) {
          this.element.unbind("touchmove." + this.widgetName).unbind("touchend." + this.widgetName);
          return this._mouseUp(event);
        },
        _modifyEvent: function(event) {
          var target;

          event.which = 1;
          target = event.originalEvent.targetTouches[0];
          event.pageX = target.clientX;
          return event.pageY = target.clientY;
        }
      });
    })(jQuery);
    return jQuery.fn.imWidget = function(arg0, arg1) {
      var cls, error, events, icons, options, properties, query, service, token, type, url, view;

      if (typeof arg0 === 'string') {
        view = this.data('widget');
        if (arg0 === 'option') {
          switch (arg1) {
            case 'query':
              return view.query;
            case 'service':
              return view.service;
            case 'events':
              return view.queryEvents;
            case 'type':
              return this.data('widget-type');
            case 'properties':
              return this.data('widget-options');
            default:
              throw new Error("Unknown option " + arg1);
          }
        } else if (arg0 === 'table') {
          return view;
        } else {
          throw new Error("Unknown method " + arg0);
        }
      } else {
        type = arg0.type, service = arg0.service, url = arg0.url, token = arg0.token, query = arg0.query, events = arg0.events, properties = arg0.properties, error = arg0.error, options = arg0.options;
        if (supportsSVG() && (typeof d3 === "undefined" || d3 === null)) {
          intermine.cdn.load('d3');
        }
        icons = intermine.options.Style.icons;
        intermine.cdn.load(icons);
        if (service == null) {
          service = new intermine.Service({
            root: url,
            token: token
          });
        }
        if (error != null) {
          service.errorHandler = error;
        }
        cls = type === 'table' ? intermine.query.results.CompactView : type === 'dashboard' ? intermine.query.results.DashBoard : type === 'minimal' ? intermine.query.results.Toolless : void 0;
        if (!cls) {
          console.error("" + type + " widgets are not supported");
          return false;
        }
        if (this.width() < jQuery('body').width() * 0.6) {
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

  scope('intermine.snippets.table', {
    LargeTableDisuader: "<div class=\"modal im-page-size-sanity-check\">\n  <div class=\"modal-header\">\n    <h3>\n      Are you sure?\n    </h3>\n  </div>\n  <div class=\"modal-body\">\n    <p>\n      You have requested a very large table size. Your\n      browser may struggle to render such a large table,\n      and the page will probably become unresponsive. It\n      will be very difficult for you to read the whole table\n      in the page. We suggest the following alternatives:\n    </p>\n    <ul>\n      <li>\n         <p>\n            If you are looking for something specific, you can use the\n            <span class=\"label label-info\">filtering tools</span>\n            to narrow down the result set. Then you \n            might be able to fit the items you are interested in in a\n            single page.\n         </p>\n          <button class=\"btn im-alternative-action\" data-event=\"add-filter-dialogue:please\">\n          <i class=\"" + intermine.icons.Filter + "\"></i>\n          Add a new filter.\n          </button>\n        </li>\n        <li>\n          <p>\n            If you want to see all the data, you can page \n            <span class=\"label label-info\">\n             <i class=\"icon-chevron-left\"></i>\n              backwards\n            </span>\n            and \n            <span class=\"label label-info\">\n              forwards\n              <i class=\"icon-chevron-right\"></i>\n            </span>\n            through the results.\n          </p>\n          <div class=\"btn-group\">\n            <a class=\"btn im-alternative-action\" data-event=\"page:backwards\" href=\"#\">\n             <i class=\"icon-chevron-left\"></i>\n             go one page back\n           </a>\n           <a class=\"btn im-alternative-action\" data-event=\"page:forwards\" href=\"#\">\n             go one page forward\n             <i class=\"icon-chevron-right\"></i>\n           </a>\n          </div>\n        </li>\n        <li>\n            <p>\n                If you want to get and save the results, we suggest\n                <span class=\"label label-info\">downloading</span>\n                the results in a format that suits you. \n            <p>\n            <button class=\"btn im-alternative-action\" data-event=\"download-menu:open\">\n                <i class=\"" + intermine.icons.Export + "\"></i>\n                Open the download menu.\n            </buttn>\n        </li>\n    </ul>\n  </div>\n  <div class=\"modal-footer\">\n      <button class=\"btn btn-primary pull-right\">\n          I know what I'm doing.\n      </button>\n      <button class=\"btn pull-left im-alternative-action\">\n          OK, no worries then.\n      </button>\n  </div>\n</div>"
  });

  (function() {
    var ManagementTools, _ref;

    ManagementTools = (function(_super) {
      __extends(ManagementTools, _super);

      function ManagementTools() {
        _ref = ManagementTools.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      ManagementTools.prototype.initialize = function(states, columnHeaders) {
        this.states = states;
        this.columnHeaders = columnHeaders;
        return this.states.on('add reverted', this.checkHasFilters, this);
      };

      ManagementTools.prototype.checkHasFilters = function() {
        var count, q;

        if (q = this.states.currentQuery) {
          count = q.constraints.length;
          this.$('.im-filters').toggleClass("im-has-constraint", count > 0);
          return this.$('.im-filters .im-action').text(count > 0 ? count : 'Add ');
        }
      };

      ManagementTools.prototype.tagName = "div";

      ManagementTools.prototype.className = "im-management-tools";

      ManagementTools.prototype.html = "<div class=\"btn-group\"> \n  <button class=\"btn im-columns\">\n      <i class=\"" + intermine.icons.Columns + "\"></i>\n      <span class=\"im-only-widescreen\">Manage </span>\n      <span class=\"hidden-tablet\">Columns</span>\n  </button>\n  <button class=\"btn im-filters\">\n      <i class=\"" + intermine.icons.Filter + "\"></i>\n      <span class=\"hidden-phone im-action\">Manage </span>\n      <span class=\"hidden-phone\">Filters</span>\n  </button>\n</div>";

      ManagementTools.prototype.events = {
        'click .im-columns': 'showColumnDialogue',
        'click .im-filters': 'showFilterDialogue'
      };

      ManagementTools.prototype.showColumnDialogue = function(e) {
        var dialogue, q;

        q = this.states.currentQuery;
        dialogue = new intermine.query.results.table.ColumnsDialogue(q, this.columnHeaders);
        this.$el.append(dialogue.el);
        return dialogue.render().showModal();
      };

      ManagementTools.prototype.showFilterDialogue = function(e) {
        var dialogue, q;

        q = this.states.currentQuery;
        dialogue = new intermine.query.filters.FilterManager(q);
        this.$el.append(dialogue.el);
        return dialogue.render().showModal();
      };

      ManagementTools.prototype.render = function() {
        this.$el.append(this.html);
        this.checkHasFilters();
        return this;
      };

      return ManagementTools;

    })(Backbone.View);
    return scope('intermine.query.tools', {
      ManagementTools: ManagementTools
    });
  })();

  (function() {
    var History, _ref;

    History = (function(_super) {
      __extends(History, _super);

      function History() {
        _ref = History.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      History.prototype.initialize = function() {
        this.currentStep = 0;
        this.currentQuery = null;
        return this.on('revert', this.revert, this);
      };

      History.prototype.unwatch = function() {
        var _ref1;

        if (((_ref1 = this.currentQuery) != null ? _ref1.off : void 0) != null) {
          return this.stopListening(this.currentQuery);
        }
      };

      History.prototype.watch = function() {
        var q,
          _this = this;

        if (q = this.currentQuery) {
          this.listenTo(q, "change:constraints", function() {
            return _this.onChange(q, 'constraints', 'filter');
          });
          this.listenTo(q, "change:views", function() {
            return _this.onChange(q, 'views', 'column');
          });
          this.listenTo(q, "change:joins", function() {
            return _this.addStep("Changed joins", q);
          });
          this.listenTo(q, "set:sortorder", function() {
            return _this.addStep("Changed sort order", q);
          });
          this.listenTo(q, "count:is", function(n) {
            return _this.last().set({
              count: n
            });
          });
          return this.listenTo(q, "undo", function() {
            return _this.popState();
          });
        }
      };

      History.prototype.onChange = function(query, prop, label) {
        var n, now, pl, quantity, title, verb, was, xs, ys;

        xs = this.last().get('query')[prop];
        ys = query[prop];
        was = xs.length;
        now = ys.length;
        n = Math.abs(was - now);
        quantity = n === 1 ? 'a ' : n ? "" + n + " " : '';
        pl = n !== 1 ? 's' : '';
        verb = was < now ? 'Added' : was > now ? 'Removed' : now === _.union(xs, ys).length ? 'Rearranged' : 'Changed';
        title = "" + verb + " " + quantity + label + pl;
        return this.addStep(title, query);
      };

      History.prototype.addStep = function(title, query) {
        var was;

        was = this.currentQuery;
        this.unwatch();
        this.currentQuery = query.clone();
        this.currentQuery.revision = this.currentStep;
        this.watch();
        this.each(function(state) {
          return state.set({
            current: false
          });
        });
        this.add({
          query: query.clone(),
          current: true,
          title: title,
          stepNo: this.currentStep++
        });
        return was != null ? was.trigger('replaced:by', this.currentQuery) : void 0;
      };

      History.prototype.popState = function() {
        return this.revert(this.at(this.length - 2));
      };

      History.prototype.revert = function(target) {
        var current, was, _ref1;

        this.unwatch();
        was = this.currentQuery;
        while (this.last().get('stepNo') > target.get('stepNo')) {
          this.pop();
        }
        current = this.last();
        if (current != null) {
          current.set({
            current: true
          });
        }
        this.currentQuery = current != null ? (_ref1 = current.get('query')) != null ? _ref1.clone() : void 0 : void 0;
        this.currentQuery.revision = current.get('stepNo');
        this.watch();
        this.trigger('reverted', this.currentQuery);
        return was != null ? was.trigger('replaced:by', this.currentQuery) : void 0;
      };

      return History;

    })(Backbone.Collection);
    return scope('intermine.models.table', {
      History: History
    });
  })();

  define('models/uniq-items', function() {
    var Item, UniqItems, _ref, _ref1;

    Item = (function(_super) {
      __extends(Item, _super);

      function Item() {
        _ref = Item.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      Item.prototype.initialize = function(item) {
        return this.set("item", item);
      };

      return Item;

    })(Backbone.Model);
    UniqItems = (function(_super) {
      __extends(UniqItems, _super);

      function UniqItems() {
        _ref1 = UniqItems.__super__.constructor.apply(this, arguments);
        return _ref1;
      }

      UniqItems.prototype.model = Item;

      UniqItems.prototype.add = function(items, opts) {
        var item, _i, _len, _results;

        items = _(items).isArray() ? items : [items];
        _results = [];
        for (_i = 0, _len = items.length; _i < _len; _i++) {
          item = items[_i];
          if ((item != null) && "" !== item) {
            if (!(this.any(function(i) {
              return i.get("item") === item;
            }))) {
              _results.push(UniqItems.__super__.add.call(this, new Item(item, opts)));
            } else {
              _results.push(void 0);
            }
          }
        }
        return _results;
      };

      UniqItems.prototype.remove = function(item, opts) {
        var delenda;

        delenda = this.filter(function(i) {
          return i.get("item") === item;
        });
        return UniqItems.__super__.remove.call(this, delenda, opts);
      };

      return UniqItems;

    })(Backbone.Collection);
    return UniqItems;
  });

  (function() {
    var NewFilterDialogue, _ref;

    NewFilterDialogue = (function(_super) {
      __extends(NewFilterDialogue, _super);

      function NewFilterDialogue() {
        _ref = NewFilterDialogue.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      NewFilterDialogue.prototype.tagName = "div";

      NewFilterDialogue.prototype.className = "im-constraint-dialogue modal";

      NewFilterDialogue.prototype.html = "<div class=\"modal-header\">\n    <a href=\"#\" class=\"close pull-right im-close\">close</a>\n    <h3>Add New Filter</h3>\n</div>\n<div class=\"modal-body\">\n</div>\n<div class=\"modal-footer\">\n    <button class=\"disabled btn btn-primary pull-right im-add-constraint\">\n        Add Filter\n    </button>\n    <button class=\"btn im-close pull-left\">\n        Cancel\n    </button>\n</div>";

      NewFilterDialogue.prototype.initialize = function(query) {
        var _this = this;

        this.query = query;
        this.query.on('change:constraints', this.closeDialogue, this);
        return this.query.on('editing-constraint', function() {
          return _this.$('.im-add-constraint').removeClass('disabled');
        });
      };

      NewFilterDialogue.prototype.events = {
        'click .im-close': 'closeDialogue',
        'hidden': 'onHidden',
        'click .im-add-constraint': 'addConstraint'
      };

      NewFilterDialogue.prototype.onHidden = function(e) {
        if (!(e && e.target === this.el)) {
          return false;
        }
        return this.remove();
      };

      NewFilterDialogue.prototype.closeDialogue = function(e) {
        return this.$el.modal('hide');
      };

      NewFilterDialogue.prototype.openDialogue = function() {
        return this.$el.modal().modal('show');
      };

      NewFilterDialogue.prototype.addConstraint = function(e) {
        var edited;

        edited = this.conAdder.newCon.editConstraint(e);
        if (edited) {
          return this.$el.modal('hide');
        }
      };

      NewFilterDialogue.prototype.render = function() {
        this.$el.append(this.html);
        this.conAdder = new intermine.query.ConstraintAdder(this.query);
        this.$el.find('.modal-body').append(this.conAdder.render().el);
        this.conAdder.showTree();
        return this;
      };

      return NewFilterDialogue;

    })(Backbone.View);
    return scope('intermine.filters', {
      NewFilterDialogue: NewFilterDialogue
    });
  })();

  define('perma-query', function() {
    var Deferred, any, defer, get, getPermaQuery, replaceIdConstraint, whenAll, zip;

    get = intermine.funcutils.get;
    any = _.any, zip = _.zip;
    Deferred = jQuery.Deferred;
    defer = function(x) {
      return Deferred(function() {
        return this.resolve(x);
      });
    };
    whenAll = function(promises) {
      return $.when.apply($, promises).then(function() {
        var results;

        results = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
        return results.slice();
      });
    };
    replaceIdConstraint = function(classkeys, query) {
      return function(c) {
        var def, finding, keys, path, type, _ref;

        path = query.makePath(c.path);
        def = new Deferred;
        if (!(((_ref = c.op) === '=' || _ref === '==') && path.end.name === 'id')) {
          def.resolve(c);
        } else {
          type = path.getParent().getType().name;
          keys = classkeys[type];
          if (keys == null) {
            def.reject("No class keys configured for " + type);
          } else {
            finding = query.service.rows({
              select: keys,
              where: {
                id: c.value
              }
            }).then(get(0));
            finding.fail(def.reject);
            finding.then(function(values) {
              var value, _i, _len, _ref1, _ref2;

              if (!values) {
                return def.reject("" + type + "@" + c.value + " not found");
              }
              _ref1 = zip(keys, values);
              for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
                _ref2 = _ref1[_i], path = _ref2[0], value = _ref2[1];
                if (value != null) {
                  return def.resolve({
                    path: path,
                    value: value,
                    op: '=='
                  });
                }
              }
              return def.reject("" + type + "@" + c.value + " has no identifying fields");
            });
          }
        }
        return def.promise();
      };
    };
    return getPermaQuery = function(query) {
      var applyNewCons, c, containsIdConstraint, copy, def, nodes;

      nodes = (function() {
        var _i, _len, _ref, _results;

        _ref = query.constraints;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          c = _ref[_i];
          if (c.type == null) {
            _results.push(query.makePath(c.path));
          }
        }
        return _results;
      })();
      containsIdConstraint = nodes.length && any(nodes, function(n) {
        var _ref;

        return 'id' === ((_ref = n.end) != null ? _ref.name : void 0);
      });
      copy = query.clone();
      if (!containsIdConstraint) {
        return defer(copy);
      }
      def = new Deferred;
      applyNewCons = function(newCons) {
        copy.constraints = newCons;
        return def.resolve(copy);
      };
      query.service.get('classkeys').then(function(_arg) {
        var classes, replaceIdCon;

        classes = _arg.classes;
        replaceIdCon = replaceIdConstraint(classes, copy);
        return whenAll((function() {
          var _i, _len, _ref, _results;

          _ref = copy.constraints;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            c = _ref[_i];
            _results.push(replaceIdCon(c));
          }
          return _results;
        })()).then(applyNewCons).fail(def.reject);
      });
      return def.promise();
    };
  });

  (function() {
    var CompactView, DashBoard, Toolless, _ref, _ref1, _ref2;

    DashBoard = (function(_super) {
      __extends(DashBoard, _super);

      function DashBoard() {
        _ref = DashBoard.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      DashBoard.prototype.tagName = "div";

      DashBoard.prototype.className = "query-display row-fluid";

      DashBoard.prototype.initialize = function(service, query, queryEvents, tableProperties) {
        var _ref1,
          _this = this;

        this.query = query;
        this.queryEvents = queryEvents;
        this.tableProperties = tableProperties;
        this.columnHeaders = new Backbone.Collection;
        this.states = new intermine.models.table.History;
        if ((_ref1 = this.events) == null) {
          this.events = {};
        }
        if (_(service).isString()) {
          this.service = new intermine.Service({
            root: service
          });
        } else if (service.fetchModel != null) {
          this.service = service;
        } else {
          this.service = new intermine.Service(service);
        }
        return this.states.on('reverted add', function() {
          return _this.loadQuery(_this.states.currentQuery);
        });
      };

      DashBoard.prototype.TABLE_CLASSES = "span9 im-query-results";

      DashBoard.prototype.loadQuery = function(q) {
        var cb, currentPageSize, evt, k, v, _ref1, _ref2, _ref3, _ref4, _results;

        currentPageSize = (_ref1 = this.table) != null ? _ref1.getCurrentPageSize() : void 0;
        if ((_ref2 = this.table) != null) {
          _ref2.remove();
        }
        this.main.empty();
        this.table = new intermine.query.results.Table(q, this.main, this.columnHeaders);
        _ref3 = this.tableProperties;
        for (k in _ref3) {
          v = _ref3[k];
          this.table[k] = v;
        }
        if (currentPageSize != null) {
          this.table.pageSize = currentPageSize;
        }
        this.table.render();
        _ref4 = this.queryEvents;
        _results = [];
        for (evt in _ref4) {
          cb = _ref4[evt];
          _results.push(q.on(evt, cb));
        }
        return _results;
      };

      DashBoard.prototype.render = function() {
        var queryPromise,
          _this = this;

        this.$el.addClass(intermine.options.StylePrefix);
        this.tools = $("<div class=\"clearfix\">");
        this.$el.append(this.tools);
        this.main = $("<div class=\"" + this.TABLE_CLASSES + "\">");
        this.$el.append(this.main);
        queryPromise = this.service.query(this.query);
        queryPromise.done(function(q) {
          return _this.states.addStep('Original state', q);
        });
        queryPromise.done(function(q) {
          _this.renderQueryManagement(q);
          return _this.renderTools(q);
        });
        queryPromise.fail(function(xhr, err, msg) {
          return _this.$el.append("<div class=\"alert alert-error\">\n  <h1>" + (err || xhr) + "</h1>\n  <p>Unable to construct query: " + (msg || xhr) + "</p>\n</div>");
        });
        return this;
      };

      DashBoard.prototype.renderTools = function(q) {
        var tools;

        tools = this.make("div", {
          "class": "span3 im-query-toolbox"
        });
        this.$el.append(tools);
        this.toolbar = new intermine.query.tools.Tools(this.states);
        return this.toolbar.render().$el.appendTo(tools);
      };

      DashBoard.prototype.renderQueryManagement = function(q) {
        var ManagementTools, Trail, managementGroup, trail, _ref1;

        _ref1 = intermine.query.tools, ManagementTools = _ref1.ManagementTools, Trail = _ref1.Trail;
        managementGroup = new ManagementTools(this.states, this.columnHeaders);
        managementGroup.render().$el.appendTo(this.tools);
        trail = new Trail(this.states);
        return trail.render().$el.appendTo(managementGroup.el);
      };

      return DashBoard;

    })(Backbone.View);
    CompactView = (function(_super) {
      __extends(CompactView, _super);

      function CompactView() {
        _ref1 = CompactView.__super__.constructor.apply(this, arguments);
        return _ref1;
      }

      CompactView.prototype.className = "im-query-display compact";

      CompactView.prototype.TABLE_CLASSES = "im-query-results";

      CompactView.prototype.renderTools = function(q) {
        this.toolbar = new intermine.query.tools.ToolBar(this.states);
        return this.tools.append(this.toolbar.render().el);
      };

      return CompactView;

    })(DashBoard);
    Toolless = (function(_super) {
      __extends(Toolless, _super);

      function Toolless() {
        _ref2 = Toolless.__super__.constructor.apply(this, arguments);
        return _ref2;
      }

      Toolless.prototype.className = 'im-query-display im-toolless';

      Toolless.prototype.TABLE_CLASSES = 'im-query-results';

      Toolless.prototype.renderTools = function(q) {};

      Toolless.prototype.renderQueryManagement = function(q) {
        var Trail, trail;

        Trail = intermine.query.tools.Trail;
        trail = new Trail(this.states);
        return this.$el.prepend(trail.render().el);
      };

      return Toolless;

    })(DashBoard);
    return scope("intermine.query.results", {
      DashBoard: DashBoard,
      CompactView: CompactView,
      Toolless: Toolless
    });
  })();

  scope('intermine.messages.columns', {
    AddThisColumn: 'Add this column to the Sort Order'
  });

  (function() {
    var OrderElement, PossibleOrderElements, PossibleSortOrder, SortOrder, _ref, _ref1, _ref2, _ref3;

    OrderElement = (function(_super) {
      __extends(OrderElement, _super);

      function OrderElement() {
        _ref = OrderElement.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      OrderElement.prototype.isNumeric = false;

      OrderElement.prototype.initialize = function() {
        var _ref1;

        OrderElement.__super__.initialize.apply(this, arguments);
        if (!this.has('direction')) {
          this.set({
            direction: 'ASC'
          });
        }
        return this.isNumeric = (_ref1 = this.get('path').getType(), __indexOf.call(intermine.Model.NUMERIC_TYPES, _ref1) >= 0);
      };

      OrderElement.prototype.toJSON = function() {
        return {
          path: this.get('path').toString(),
          direction: this.get('direction')
        };
      };

      return OrderElement;

    })(Backbone.Model);
    SortOrder = (function(_super) {
      __extends(SortOrder, _super);

      function SortOrder() {
        _ref1 = SortOrder.__super__.constructor.apply(this, arguments);
        return _ref1;
      }

      SortOrder.prototype.model = OrderElement;

      SortOrder.prototype.initialize = function() {
        return this.on('destroy', this.remove, this);
      };

      return SortOrder;

    })(Backbone.Collection);
    PossibleSortOrder = (function(_super) {
      __extends(PossibleSortOrder, _super);

      function PossibleSortOrder() {
        _ref2 = PossibleSortOrder.__super__.constructor.apply(this, arguments);
        return _ref2;
      }

      PossibleSortOrder.prototype.toSortOrder = function() {
        return {
          path: this.get('path')
        };
      };

      PossibleSortOrder.prototype.isInView = function() {
        var _ref3;

        return _ref3 = this.get('path').toString(), __indexOf.call(this.get('query').views, _ref3) >= 0;
      };

      PossibleSortOrder.prototype.initialize = function() {
        this.set({
          visibleInView: true,
          matchesTerm: true
        });
        return this.set({
          path: this.get('query').getPathInfo(this.get('path'))
        });
      };

      PossibleSortOrder.prototype.toJSON = function() {
        return {
          isInView: this.isInView(),
          path: this.get('path').toString()
        };
      };

      return PossibleSortOrder;

    })(Backbone.Model);
    PossibleOrderElements = (function(_super) {
      __extends(PossibleOrderElements, _super);

      function PossibleOrderElements() {
        _ref3 = PossibleOrderElements.__super__.constructor.apply(this, arguments);
        return _ref3;
      }

      PossibleOrderElements.prototype.model = PossibleSortOrder;

      PossibleOrderElements.prototype.initialize = function() {
        return this.on('destroy', this.remove, this);
      };

      return PossibleOrderElements;

    })(Backbone.Collection);
    return scope('intermine.columns.collections', {
      SortOrder: SortOrder,
      PossibleOrderElements: PossibleOrderElements
    });
  })();

  (function() {
    var OrderElement, PossibleOrderElement, placement, _ref, _ref1;

    placement = intermine.utils.addStylePrefix('top');
    OrderElement = (function(_super) {
      var TEMPLATE;

      __extends(OrderElement, _super);

      function OrderElement() {
        _ref = OrderElement.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      OrderElement.prototype.tagName = 'li';

      OrderElement.prototype.className = 'im-reorderable im-soe im-in-order';

      TEMPLATE = _.template("<div>\n  <span class=\"im-sort-direction <%= direction.toLowerCase() %>\"></span>\n  <i class=\"icon-minus im-remove-soe\" title=\"Remove this column from the sort order\"></i>\n  <span class=\"im-path\" title=\"<%- path %>\"><%- path %></span>\n  <i class=\"icon-reorder pull-right\"></i>\n</div>");

      OrderElement.prototype.initialize = function(options) {
        var _this = this;

        this.options = options != null ? options : {};
        this.model.on('change:direction', function() {
          return _this.$('.im-sort-direction').toggleClass('asc desc');
        });
        this.model.on('destroy', this.remove, this);
        return this.model.el = this.el;
      };

      OrderElement.prototype.events = {
        'click .im-sort-direction': 'changeDirection',
        'click .im-remove-soe': 'deorder'
      };

      OrderElement.prototype.deorder = function() {
        return this.model.destroy();
      };

      OrderElement.prototype.changeDirection = function() {
        var direction;

        direction = this.model.get('direction') === 'ASC' ? 'DESC' : 'ASC';
        return this.model.set({
          direction: direction
        });
      };

      OrderElement.prototype.remove = function() {
        this.model.off();
        this.$('.im-remove-soe').tooltip('hide');
        return OrderElement.__super__.remove.call(this);
      };

      OrderElement.prototype.render = function() {
        var _this = this;

        if (this.model.isNumeric) {
          this.$el.addClass('numeric');
        }
        this.$el.append(TEMPLATE(this.model.toJSON()));
        this.$('.im-remove-soe').tooltip({
          placement: placement
        });
        this.model.get('path').getDisplayName().done(function(name) {
          return _this.$('.im-path').text(name);
        });
        return this;
      };

      return OrderElement;

    })(Backbone.View);
    PossibleOrderElement = (function(_super) {
      var TEMPLATE;

      __extends(PossibleOrderElement, _super);

      function PossibleOrderElement() {
        _ref1 = PossibleOrderElement.__super__.constructor.apply(this, arguments);
        return _ref1;
      }

      PossibleOrderElement.prototype.tagName = 'li';

      PossibleOrderElement.prototype.className = 'im-soe';

      TEMPLATE = _.template("<div>\n  <a class=\"im-add-soe\"\n     title=\"" + intermine.messages.columns.AddThisColumn + "\" >\n    <i class=\"icon-plus\"></i>\n    <span title=\"<%- path %>\"><%- path %></span>\n  </a>\n  <i class=\"icon-reorder pull-right\"></i>\n</div>");

      PossibleOrderElement.prototype.events = {
        'click .im-add-soe': 'addToOrderBy',
        'dropped': 'addToOrderBy'
      };

      PossibleOrderElement.prototype.addToOrderBy = function() {
        this.options.sortOrder.add(this.model.toSortOrder());
        this.model.destroy();
        return this.remove();
      };

      PossibleOrderElement.prototype.remove = function() {
        this.model.off();
        this.$('.im-add-soe').tooltip('hide');
        return PossibleOrderElement.__super__.remove.call(this);
      };

      PossibleOrderElement.prototype.initialize = function(options) {
        var _this = this;

        this.options = options != null ? options : {};
        this.model.on('only-in-view', function(only) {
          return _this.model.set({
            visibleInView: !only || _this.model.isInView()
          });
        });
        this.model.on('filter', function(pattern) {
          return _this.model.set({
            matchesTerm: !pattern || pattern.test(_this.model.get('path'))
          });
        });
        return this.model.on('change', function() {
          var visible;

          visible = _this.model.get('visibleInView') && _this.model.get('matchesTerm');
          return _this.$el.toggle(visible);
        });
      };

      PossibleOrderElement.prototype.render = function() {
        var so,
          _this = this;

        so = this.model.toJSON();
        this.$el.append(TEMPLATE(so));
        if (!so.isInView) {
          this.$el.addClass('im-not-in-view');
        }
        this.model.get('path').getDisplayName().done(function(name) {
          return _this.$('span').text(name);
        });
        this.$el.draggable({
          revert: 'invalid',
          revertDuration: 100
        });
        this.$(".im-add-soe").tooltip({
          placement: placement
        });
        return this;
      };

      return PossibleOrderElement;

    })(Backbone.View);
    return scope('intermine.columns.views', {
      PossibleOrderElement: PossibleOrderElement,
      OrderElement: OrderElement
    });
  })();

  (function() {
    var FormattedSorting, ICONS, INIT_CARETS, NEXT_DIRECTION_OF, ROW, _ref;

    ROW = "<li class=\"im-formatted-part im-subpath\"><a><i class=\"sort-icon\"></i></a></li>";
    INIT_CARETS = /^\s*>\s*/;
    ICONS = function() {
      return {
        ASC: intermine.css.sortedASC,
        DESC: intermine.css.sortedDESC,
        NONE: intermine.css.unsorted
      };
    };
    NEXT_DIRECTION_OF = {
      ASC: 'DESC',
      DESC: 'ASC',
      NONE: 'ASC'
    };
    FormattedSorting = (function(_super) {
      __extends(FormattedSorting, _super);

      function FormattedSorting() {
        this.appendSortOption = __bind(this.appendSortOption, this);        _ref = FormattedSorting.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      FormattedSorting.prototype.className = 'im-col-sort-menu no-margins';

      FormattedSorting.prototype.tagName = 'ul';

      FormattedSorting.prototype.initialize = function(query, path, model) {
        this.query = query;
        this.path = path;
        this.model = model;
      };

      FormattedSorting.prototype.toggleSort = function(paths) {
        var currentDir, direction, path;

        console.log("Ordering by " + paths);
        currentDir = this.currentDir(paths);
        direction = NEXT_DIRECTION_OF[currentDir];
        this.query.orderBy((function() {
          var _i, _len, _results;

          _results = [];
          for (_i = 0, _len = paths.length; _i < _len; _i++) {
            path = paths[_i];
            _results.push({
              path: path,
              direction: direction
            });
          }
          return _results;
        })());
        this.model.set({
          direction: direction
        });
        return this.remove();
      };

      FormattedSorting.prototype.currentDir = function(paths) {
        var current, dirs, p;

        dirs = (function() {
          var _i, _len, _results;

          _results = [];
          for (_i = 0, _len = paths.length; _i < _len; _i++) {
            p = paths[_i];
            _results.push(this.query.getSortDirection(p));
          }
          return _results;
        }).call(this);
        if (_.unique(dirs).length === 1) {
          current = dirs[0];
        }
        return current != null ? current : 'NONE';
      };

      FormattedSorting.prototype.render = function() {
        var paths, replaces;

        console.log("Rendering FormattedSorting for " + this.path);
        paths = [];
        replaces = this.model.get('replaces');
        if (replaces.length > 1) {
          paths = [replaces].concat(replaces.map(function(x) {
            return [x];
          }));
        } else {
          paths = [this.path];
        }
        if (paths.length === 1) {
          this.toggleSort(paths[0]);
        } else {
          paths.forEach(this.appendSortOption);
        }
        return this;
      };

      FormattedSorting.prototype.appendSortOption = function(paths) {
        var $a, currentDir, icons, li, p, _fn, _i, _len,
          _this = this;

        li = $(ROW);
        $a = li.find('a');
        icons = ICONS();
        _fn = function(p) {
          var $span, path;

          console.log("Adding span for " + p);
          $span = $("<span class=\"im-sort-path\">");
          $a.append($span);
          path = _this.query.getPathInfo(p);
          return $.when(_this.path.getDisplayName(), path.getDisplayName()).done(function(pn, cn) {
            return $span.text(cn.replace(pn, '').replace(INIT_CARETS, ''));
          });
        };
        for (_i = 0, _len = paths.length; _i < _len; _i++) {
          p = paths[_i];
          _fn(p);
        }
        $a.click(function(e) {
          e.stopPropagation();
          e.preventDefault();
          return _this.toggleSort(paths);
        });
        currentDir = paths === this.model.get('replaces') ? this.currentDir(paths) : this.currentDir(this.model.get('replaces')) !== 'NONE' ? 'NONE' : this.currentDir(paths);
        li.find('i').addClass(icons[currentDir]);
        this.$el.append(li);
        return null;
      };

      return FormattedSorting;

    })(Backbone.View);
    return scope("intermine.query", {
      FormattedSorting: FormattedSorting
    });
  })();

  (function() {
    var CellCutoff, HIDDEN_FIELDS, NUM_CHUNK_SIZE, NUM_SEPARATOR, Preview, getLeaves, numToStr, sortTableByFieldName, toField, _ref, _ref1;

    HIDDEN_FIELDS = ["class", "objectId"];
    getLeaves = function(o) {
      var leaf, leaves, name, values, _i, _len;

      leaves = [];
      values = (function() {
        var _results;

        _results = [];
        for (name in o) {
          leaf = o[name];
          if (__indexOf.call(HIDDEN_FIELDS, name) < 0) {
            _results.push(leaf);
          }
        }
        return _results;
      })();
      for (_i = 0, _len = values.length; _i < _len; _i++) {
        x = values[_i];
        if (x['objectId']) {
          leaves = leaves.concat(getLeaves(x));
        } else {
          leaves.push(x);
        }
      }
      return leaves;
    };
    toField = function(row) {
      return $(row).find('.im-field-name').text();
    };
    sortTableByFieldName = function(tbody) {
      return tbody.html(_.sortBy(tbody.children('tr').get(), toField));
    };
    _ref = intermine.options, NUM_SEPARATOR = _ref.NUM_SEPARATOR, NUM_CHUNK_SIZE = _ref.NUM_CHUNK_SIZE, CellCutoff = _ref.CellCutoff;
    numToStr = function(n) {
      return intermine.utils.numToString(n, NUM_SEPARATOR, NUM_CHUNK_SIZE);
    };
    Preview = (function(_super) {
      var ITEMS, ITEM_ROW, REFERENCE, RELATION, RELATIONS, THROBBER;

      __extends(Preview, _super);

      function Preview() {
        this.handleItem = __bind(this.handleItem, this);        _ref1 = Preview.__super__.constructor.apply(this, arguments);
        return _ref1;
      }

      Preview.prototype.className = 'im-cell-preview-inner';

      ITEM_ROW = _.template("<tr>\n  <td class=\"im-field-name\"><%= field %></td>\n  <td class=\"im-field-value <%= field.toLowerCase() %>\">\n    <%- value %>\n    <span class=\"im-overspill\"><%- valueOverspill %></span>\n    <% if (tooLong) { %>\n      <a href=\"#\" class=\"im-too-long\">\n        <span class=\"im-ellipsis\">...</span>\n        <i class=\"" + intermine.icons.More + "\"></i>\n      </a>\n    <% } %>\n  </td>\n</tr>");

      THROBBER = "<div class=\"progress progress-info progress-striped active\">\n  <div class=\"bar\" style=\"width: 100%\"></div>\n</div>";

      ITEMS = "<table class=\"im-item-details table table-condensed table-bordered\">\n<colgroup>\n    <col class=\"im-item-field\"/>\n    <col class=\"im-item-value\"/>\n</colgroup>\n</table>";

      RELATIONS = "<ul class=\"im-related-counts\"></ul>";

      RELATION = _.template("<li class=\"im-relation\">\n  <span class=\"pull-left\"><%- label %></span>\n  <span class=\"pull-right im-count\"><%= count %></span>\n</li>");

      REFERENCE = _.template("<tr>\n  <td class=\"im-field-name\"><%= field %></td>\n  <td class=\"im-field-value <%= field.toLowerCase() %>\">\n     <%- values.join(', ') %>\n  </td>\n</tr>");

      Preview.prototype.events = {
        'click .im-too-long': 'revealLongField'
      };

      Preview.prototype.revealLongField = function(e) {
        var $overSpill, $tooLong;

        if (e != null) {
          e.preventDefault();
        }
        if (e != null) {
          e.stopPropagation();
        }
        $tooLong = $(e.currentTarget);
        $overSpill = $tooLong.siblings('.im-overspill');
        $tooLong.remove();
        return $overSpill.show();
      };

      Preview.prototype.template = _.template(THROBBER);

      Preview.prototype.initialize = function(options) {
        this.options = options != null ? options : {};
        Preview.__super__.initialize.apply(this, arguments);
        return this.on('rendered', this.insertRows, this);
      };

      Preview.prototype.formatName = function(field, row) {
        var fv, p, type,
          _this = this;

        type = this.model.get('type');
        p = this.options.schema.getPathInfo("" + type + "." + field);
        fv = row.find('.im-field-value');
        fv.addClass(p.getType().toString().toLowerCase());
        return p.getDisplayName().done(function(name) {
          row.find('.im-field-name').text(name.split(' > ').pop());
          sortTableByFieldName(row.parent());
          return _this.trigger('ready');
        });
      };

      Preview.prototype.handleItem = function(item) {
        var field, row, snipPoint, table, tooLong, v, value, valueOverspill, values, _results;

        table = this.itemDetails;
        for (field in item) {
          v = item[field];
          if (!(v && (__indexOf.call(HIDDEN_FIELDS, field) < 0) && !v['objectId'])) {
            continue;
          }
          value = v + '';
          tooLong = value.length > CellCutoff;
          snipPoint = value.indexOf(' ', CellCutoff * 0.9);
          if (snipPoint === -1) {
            snipPoint = CellCutoff;
          }
          value = tooLong ? value.substring(0, snipPoint) : value;
          valueOverspill = (v + '').substring(snipPoint);
          row = $(ITEM_ROW({
            field: field,
            value: value,
            tooLong: tooLong,
            valueOverspill: valueOverspill
          }));
          this.formatName(field, row);
          table.append(row);
        }
        _results = [];
        for (field in item) {
          value = item[field];
          if (!(value && value['objectId'])) {
            continue;
          }
          values = getLeaves(value);
          row = $(REFERENCE({
            field: field,
            values: values
          }));
          this.formatName(field, row);
          _results.push(table.append(row));
        }
        return _results;
      };

      Preview.prototype.fillRelationsTable = function(table) {
        var settings, type, _i, _len, _ref2, _ref3, _ref4, _results;

        type = this.model.get('type');
        root = this.options.service.root;
        _ref4 = (_ref2 = (_ref3 = intermine.options.preview.count[root]) != null ? _ref3[type] : void 0) != null ? _ref2 : [];
        _results = [];
        for (_i = 0, _len = _ref4.length; _i < _len; _i++) {
          settings = _ref4[_i];
          _results.push(this.handleRelationCount(settings));
        }
        return _results;
      };

      Preview.prototype.handleRelationCount = function(settings) {
        var counter, id, label, query, table, type, _ref2;

        table = this.relatedCounts;
        _ref2 = this.model.toJSON(), type = _ref2.type, id = _ref2.id;
        if (_.isObject(settings)) {
          query = settings.query, label = settings.label;
          counter = intermine.utils.copy(query);
          intermine.utils.walk(counter, function(o, k, v) {
            if (v === '{{ID}}') {
              return o[k] = id;
            }
          });
        } else {
          label = settings;
          counter = {
            select: settings + '.id',
            from: type,
            where: {
              id: id
            }
          };
        }
        return this.options.service.count(counter).done(function(c) {
          return table.append(RELATION({
            label: label,
            count: numToStr(c)
          }));
        });
      };

      Preview.prototype.fillItemTable = function() {
        var id, schema, service, t, table, type, types, _ref2, _ref3;

        _ref2 = this.model.toJSON(), type = _ref2.type, id = _ref2.id;
        _ref3 = this.options, schema = _ref3.schema, service = _ref3.service;
        table = this.itemDetails;
        types = [type].concat(schema.getAncestorsOf(type));
        table.addClass(((function() {
          var _i, _len, _results;

          _results = [];
          for (_i = 0, _len = types.length; _i < _len; _i++) {
            t = types[_i];
            _results.push(t.toLowerCase());
          }
          return _results;
        })()).join(' '));
        return service.findById(type, id, this.handleItem);
      };

      Preview.prototype.insertRows = function() {
        var promise, ready, relations, _i, _len,
          _this = this;

        this.itemDetails = $(ITEMS);
        this.relatedCounts = $(RELATIONS);
        ready = this.fillItemTable();
        relations = this.fillRelationsTable();
        for (_i = 0, _len = relations.length; _i < _len; _i++) {
          promise = relations[_i];
          ready = ready.then(function() {
            return promise;
          });
        }
        ready.done(function() {
          _this.$el.empty().append(_this.itemDetails);
          if (relations.length) {
            _this.$el.append("<h4>" + intermine.messages.cell.RelatedItems + "</h4>");
            _this.$el.append(_this.relatedCounts);
          }
          return _this.trigger('ready');
        });
        return ready.fail(function(err) {
          _this.renderError(err);
          return _this.trigger('ready');
        });
      };

      return Preview;

    })(intermine.views.ItemView);
    return scope('intermine.table.cell', {
      Preview: Preview
    });
  })();

  (function() {
    var CELL_HTML, Cell, NullCell, SubTable, _CELL_HTML, _ref, _ref1, _ref2;

    _CELL_HTML = _.template("<input class=\"list-chooser\" type=\"checkbox\"\n  <% if (checked) { %> checked <% } %>\n  <% if (disabled) { %> disabled <% } %>\n  style=\"display: <%= display %>\"\n>\n<a class=\"im-cell-link\" target=\"<%= target %>\" href=\"<%= url %>\">\n  <% if (isForeign) { %>\n    <% if (icon) { %>\n      <img src=\"<%= icon %>\" class=\"im-external-link\"></img>\n    <% } else { %>\n      <i class=\"icon-globe\"></i>\n    <% } %>\n  <% } %>\n  <% if (value == null) { %>\n    <span class=\"null-value\">&nbsp;</span>\n  <% } else { %>\n    <span class=\"im-displayed-value\">\n      <%= value %>\n    </span>\n  <% } %>\n</a>\n<% if (rawValue != null && field == 'url' && rawValue != url) { %>\n    <a class=\"im-cell-link external\" href=\"<%= rawValue %>\">\n      <i class=\"icon-globe\"></i>\n      link\n    </a>\n<% } %>");
    CELL_HTML = function(data) {
      var host, url;

      url = data.url, host = data.host;
      data.isForeign = url && !url.match(host);
      data.target = data.isForeign ? '_blank' : '';
      return _CELL_HTML(data);
    };
    SubTable = (function(_super) {
      __extends(SubTable, _super);

      function SubTable() {
        this.appendRow = __bind(this.appendRow, this);        _ref = SubTable.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      SubTable.prototype.tagName = "td";

      SubTable.prototype.className = "im-result-subtable";

      SubTable.prototype.initialize = function(options) {
        var subtable,
          _this = this;

        this.options = options != null ? options : {};
        this.query = this.options.query;
        this.cellify = this.options.cellify;
        this.path = this.options.node;
        subtable = this.options.subtable;
        this.rows = subtable.rows;
        this.view = subtable.view;
        this.column = this.query.getPathInfo(subtable.column);
        this.query.on('expand:subtables', function(path) {
          if (path.getParent().toString() === _this.column.toString()) {
            return _this.renderTable().slideDown();
          }
        });
        return this.query.on('collapse:subtables', function(path) {
          if (path.getParent().toString() === _this.column.toString()) {
            return _this.$('.im-subtable').slideUp();
          }
        });
      };

      SubTable.prototype.getSummaryText = function() {
        var def, level;

        def = jQuery.Deferred();
        if (this.column.isCollection()) {
          def.resolve("" + this.rows.length + " " + (this.column.getType().name) + "s");
        } else {
          if (this.rows.length === 0) {
            level = this.query.isOuterJoined(this.view[0]) ? this.query.getPathInfo(this.query.getOuterJoin(this.view[0])) : this.column;
            def.resolve("<span class=\"im-no-value\">No " + (level.getType().name) + "</span>");
          } else {
            def.resolve("" + this.rows[0][0].value + " (" + (this.rows[0].slice(1).map(function(c) {
              return c.value;
            }).join(', ')) + ")");
          }
        }
        return def.promise();
      };

      SubTable.prototype.getEffectiveView = function() {
        var c, cell, col, columns, commonPrefix, explicitReplacements, fieldExpr, formatter, getFormatter, getReplacedTest, isReplaced, longestCommonPrefix, parent, path, r, replacedBy, replaces, row, shouldFormat, subPath, sv, view, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7;

        _ref1 = intermine.utils, getReplacedTest = _ref1.getReplacedTest, longestCommonPrefix = _ref1.longestCommonPrefix;
        _ref2 = intermine.results, shouldFormat = _ref2.shouldFormat, getFormatter = _ref2.getFormatter;
        row = this.rows[0];
        replacedBy = {};
        explicitReplacements = {};
        columns = (function() {
          var _i, _len, _ref3, _results;

          _results = [];
          for (_i = 0, _len = row.length; _i < _len; _i++) {
            cell = row[_i];
            _ref3 = cell.view != null ? (commonPrefix = longestCommonPrefix(cell.view), path = this.query.getPathInfo(commonPrefix), [
              path, (function() {
                var _j, _len1, _ref3, _results1;

                _ref3 = cell.view;
                _results1 = [];
                for (_j = 0, _len1 = _ref3.length; _j < _len1; _j++) {
                  sv = _ref3[_j];
                  _results1.push(this.query.getPathInfo(sv));
                }
                return _results1;
              }).call(this)
            ]) : (path = this.query.getPathInfo(cell.column), [path, [path]]), path = _ref3[0], replaces = _ref3[1];
            _results.push({
              path: path,
              replaces: replaces
            });
          }
          return _results;
        }).call(this);
        for (_i = 0, _len = columns.length; _i < _len; _i++) {
          c = columns[_i];
          if (!(c.path.isAttribute() && shouldFormat(c.path))) {
            continue;
          }
          parent = c.path.getParent();
          if ((_ref3 = replacedBy[parent]) == null) {
            replacedBy[parent] = c;
          }
          formatter = getFormatter(c.path);
          if (__indexOf.call(this.options.blacklistedFormatters, formatter) < 0) {
            c.isFormatted = true;
            c.formatter = formatter;
            _ref5 = (_ref4 = formatter.replaces) != null ? _ref4 : [];
            for (_j = 0, _len1 = _ref5.length; _j < _len1; _j++) {
              fieldExpr = _ref5[_j];
              subPath = this.query.getPathInfo("" + parent + "." + fieldExpr);
              if ((_ref6 = replacedBy[subPath]) == null) {
                replacedBy[subPath] = c;
              }
              c.replaces.push(subPath);
            }
          }
          _ref7 = c.replaces;
          for (_k = 0, _len2 = _ref7.length; _k < _len2; _k++) {
            r = _ref7[_k];
            explicitReplacements[r] = c;
          }
        }
        isReplaced = getReplacedTest(replacedBy, explicitReplacements);
        view = [];
        for (_l = 0, _len3 = columns.length; _l < _len3; _l++) {
          col = columns[_l];
          if (!(!isReplaced(col))) {
            continue;
          }
          if (col.isFormatted) {
            col.path = col.path.getParent();
          }
          view.push(col);
        }
        return view;
      };

      SubTable.prototype.renderHead = function(headers, columns) {
        var c, tableNamePromise, _i, _len, _results,
          _this = this;

        tableNamePromise = this.column.getDisplayName();
        _results = [];
        for (_i = 0, _len = columns.length; _i < _len; _i++) {
          c = columns[_i];
          _results.push((function(c) {
            var th;

            th = $("<th>\n    <i class=\"" + intermine.css.headerIconRemove + "\"></i>\n    <span></span>\n</th>");
            th.find('i').click(function(e) {
              return _this.query.removeFromSelect(c.replaces);
            });
            $.when(tableNamePromise, c.path.getDisplayName()).then(function(tableName, colName) {
              var span, text;

              text = colName.match(tableName) ? colName.replace(tableName, '').replace(/^\s*>?\s*/, '') : colName.replace(/^[^>]*\s*>\s*/, '');
              return span = th.find('span').text(text);
            });
            return headers.append(th);
          })(c));
        }
        return _results;
      };

      SubTable.prototype.appendRow = function(columns, row, tbody) {
        var c, cell, cells, processed, r, replacedBy, tr, w, _fn, _i, _j, _k, _len, _len1, _len2, _ref1,
          _this = this;

        if (tbody == null) {
          tbody = this.$('.im-subtable tbody');
        }
        tr = $('<tr>');
        w = this.$el.width() / this.view.length;
        processed = {};
        replacedBy = {};
        for (_i = 0, _len = columns.length; _i < _len; _i++) {
          c = columns[_i];
          _ref1 = c.replaces;
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            r = _ref1[_j];
            replacedBy[r] = c;
          }
        }
        cells = row.map(this.cellify);
        _fn = function(tr, cell) {
          var formatter, otherC, path, replaces, _l, _len3, _len4, _m, _ref2, _ref3;

          if (processed[cell.path]) {
            return;
          }
          processed[cell.path] = true;
          _ref3 = (_ref2 = replacedBy[cell.path]) != null ? _ref2 : {}, replaces = _ref3.replaces, formatter = _ref3.formatter, path = _ref3.path;
          if (replaces.length > 1) {
            if (!path.equals(cell.path.getParent())) {
              return;
            }
            if ((formatter != null ? formatter.merge : void 0) != null) {
              for (_l = 0, _len3 = row.length; _l < _len3; _l++) {
                otherC = row[_l];
                if (_.any(replaces, function(repl) {
                  return repl.equals(otherC.path);
                })) {
                  formatter.merge(cell.model, otherC.model);
                }
              }
            }
          }
          for (_m = 0, _len4 = replaces.length; _m < _len4; _m++) {
            r = replaces[_m];
            processed[r] = true;
          }
          if (formatter != null) {
            cell.formatter = formatter;
          }
          tr.append(cell.el);
          return cell.render().setWidth(w);
        };
        for (_k = 0, _len2 = cells.length; _k < _len2; _k++) {
          cell = cells[_k];
          _fn(tr, cell);
        }
        tr.appendTo(tbody);
        return null;
      };

      SubTable.prototype.renderTable = function($table) {
        var colRoot, colStr, columns, docfrag, row, tbody, _i, _len, _ref1;

        if ($table == null) {
          $table = this.$('.im-subtable');
        }
        if (this.tableRendered) {
          return $table;
        }
        colRoot = this.column.getType().name;
        colStr = this.column.toString();
        if (this.rows.length > 0) {
          columns = this.getEffectiveView();
          this.renderHead($table.find('thead tr'), columns);
          tbody = $table.find('tbody');
          docfrag = document.createDocumentFragment();
          if (this.column.isCollection()) {
            _ref1 = this.rows;
            for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
              row = _ref1[_i];
              this.appendRow(columns, row, docfrag);
            }
          } else {
            this.appendRow(columns, this.rows[0], docfrag);
          }
          tbody.html(docfrag);
        }
        this.tableRendered = true;
        return $table;
      };

      SubTable.prototype.events = {
        'click .im-subtable-summary': 'toggleTable'
      };

      SubTable.prototype.toggleTable = function(e) {
        var $table, evt;

        if (e != null) {
          e.stopPropagation();
        }
        $table = this.$('.im-subtable');
        evt = $table.is(':visible') ? 'subtable:collapsed' : (this.renderTable($table), 'subtable:expanded');
        $table.slideToggle();
        return this.query.trigger(evt, this.column);
      };

      SubTable.prototype.render = function() {
        var icon, summary;

        icon = this.rows.length > 0 ? "<i class=\"" + intermine.icons.Table + "\"></i>" : '<i class=icon-non-existent></i>';
        summary = $("<span class=\"im-subtable-summary\">\n  " + icon + "&nbsp;\n</span>");
        summary.appendTo(this.$el);
        this.getSummaryText().done(function(content) {
          return summary.append(content);
        });
        this.$el.append("<table class=\"im-subtable table table-condensed table-striped\">\n  <thead><tr></tr></thead>\n  <tbody></tbody>\n</table>");
        if (intermine.options.SubtableInitialState === 'open' || this.options.mainTable.SubtableInitialState === 'open') {
          this.toggleTable();
        }
        return this;
      };

      SubTable.prototype.getUnits = function() {
        if (this.rows.length = 0) {
          return this.view.length;
        } else {
          return _.reduce(this.rows[0], (function(a, item) {
            return a + (item.view != null ? item.view.length : 1);
          }), 0);
        }
      };

      SubTable.prototype.setWidth = function(w) {
        return this;
      };

      return SubTable;

    })(Backbone.View);
    Cell = (function(_super) {
      __extends(Cell, _super);

      function Cell() {
        this.getPopoverPlacement = __bind(this.getPopoverPlacement, this);
        this.getPopoverContent = __bind(this.getPopoverContent, this);        _ref1 = Cell.__super__.constructor.apply(this, arguments);
        return _ref1;
      }

      Cell.prototype.tagName = "td";

      Cell.prototype.className = "im-result-field";

      Cell.prototype.getUnits = function() {
        return 1;
      };

      Cell.prototype.formatter = function(model) {
        if (model.get(this.options.field) != null) {
          return model.escape(this.options.field);
        } else {
          return "<span class=\"null-value\">&nbsp;</span>";
        }
      };

      Cell.prototype.initialize = function(options) {
        var field, path;

        this.options = options != null ? options : {};
        this.model.on('change', this.selectingStateChange, this);
        this.model.on('change', this.updateValue, this);
        this.listenToQuery(this.options.query);
        field = this.options.field;
        path = this.path = this.options.node.append(field);
        return this.$el.addClass('im-type-' + path.getType().toLowerCase());
      };

      Cell.prototype.events = function() {
        var _this = this;

        return {
          'shown': function() {
            var _ref2;

            return (_ref2 = _this.cellPreview) != null ? _ref2.reposition() : void 0;
          },
          'show': function(e) {
            _this.options.query.trigger('showing:preview', _this.el);
            if (_this.model.get('is:selecting')) {
              return e != null ? e.preventDefault() : void 0;
            }
          },
          'hide': function(e) {
            var _ref2;

            return (_ref2 = _this.model.cachedPopover) != null ? _ref2.detach() : void 0;
          },
          'click': 'activateChooser',
          'click a.im-cell-link': function(e) {
            return e != null ? e.stopPropagation() : void 0;
          }
        };
      };

      Cell.prototype.reportClick = function() {
        return this.model.trigger('click', this.model);
      };

      Cell.prototype.listenToQuery = function(q) {
        var _this = this;

        q.on("start:list-creation", function() {
          return _this.model.set({
            'is:selecting': true
          });
        });
        q.on("stop:list-creation", function() {
          return _this.model.set({
            'is:selecting': false,
            'is:selected': false
          });
        });
        q.on('showing:preview', function(el) {
          var _ref2;

          if (el !== _this.el) {
            return (_ref2 = _this.cellPreview) != null ? _ref2.hide() : void 0;
          }
        });
        q.on("start:highlight:node", function(node) {
          var _ref2;

          if (((_ref2 = _this.options.node) != null ? _ref2.toPathString() : void 0) === node.toPathString()) {
            return _this.$el.addClass("im-highlight");
          }
        });
        q.on("stop:highlight", function() {
          return _this.$el.removeClass("im-highlight");
        });
        return q.on("replaced:by", function(replacement) {
          return _this.listenToQuery(replacement);
        });
      };

      Cell.prototype.getPopoverContent = function() {
        var content, id, popover, type,
          _this = this;

        if (this.model.cachedPopover != null) {
          return this.model.cachedPopover;
        }
        type = this.model.get('obj:type');
        id = this.model.get('id');
        popover = new intermine.table.cell.Preview({
          service: this.options.query.service,
          schema: this.options.query.model,
          model: {
            type: type,
            id: id
          }
        });
        content = popover.$el;
        popover.on('ready', function() {
          return _this.cellPreview.reposition();
        });
        popover.render();
        return this.model.cachedPopover = content;
      };

      Cell.prototype.getPopoverPlacement = function(popover) {
        var elPos, fitsOnLeft, fitsOnRight, h, left, limits, ph, pw, table, w;

        table = this.$el.closest(".im-table-container");
        left = this.$el.offset().left;
        limits = table.offset();
        _.extend(limits, {
          right: limits.left + table.width(),
          bottom: limits.top + table.height()
        });
        w = this.$el.width();
        h = this.$el.height();
        elPos = this.$el.offset();
        pw = $(popover).outerWidth();
        ph = $(popover)[0].offsetHeight;
        fitsOnRight = left + w + pw <= limits.right;
        fitsOnLeft = limits.left <= left - pw;
        if (fitsOnLeft) {
          return 'left';
        }
        if (fitsOnRight) {
          return 'right';
        } else {
          return 'top';
        }
      };

      Cell.prototype.setupPreviewOverlay = function() {
        var options;

        options = {
          container: this.el,
          containment: '.im-query-results',
          html: true,
          title: this.model.get('obj:type'),
          trigger: intermine.options.CellPreviewTrigger,
          delay: {
            show: 250,
            hide: 250
          },
          classes: 'im-cell-preview',
          content: this.getPopoverContent,
          placement: this.getPopoverPlacement
        };
        return this.cellPreview = new intermine.bootstrap.DynamicPopover(this.el, options);
      };

      Cell.prototype.updateValue = function() {
        var _this = this;

        return _.defer(function() {
          return _this.$('.im-displayed-value').html(_this.formatter(_this.model));
        });
      };

      Cell.prototype.getInputState = function() {
        var checked, disabled, display, selectable, selected, selecting, _ref2;

        _ref2 = this.model.selectionState(), selected = _ref2.selected, selectable = _ref2.selectable, selecting = _ref2.selecting;
        checked = selected;
        disabled = !selectable;
        display = selecting && selectable ? 'inline' : 'none';
        return {
          checked: checked,
          disabled: disabled,
          display: display
        };
      };

      Cell.prototype.selectingStateChange = function() {
        var checked, disabled, display, _ref2;

        _ref2 = this.getInputState(), checked = _ref2.checked, disabled = _ref2.disabled, display = _ref2.display;
        this.$el.toggleClass("active", checked);
        return this.$('input').attr({
          checked: checked,
          disabled: disabled
        }).css({
          display: display
        });
      };

      Cell.prototype.getData = function() {
        var ExternalLinkIcons, IndicateOffHostLinks, data, domain, field, url, _ref2, _ref3;

        _ref2 = intermine.options, IndicateOffHostLinks = _ref2.IndicateOffHostLinks, ExternalLinkIcons = _ref2.ExternalLinkIcons;
        field = this.options.field;
        data = {
          value: this.formatter(this.model),
          rawValue: this.model.get(field),
          field: field,
          url: this.model.get('service:url'),
          host: IndicateOffHostLinks ? window.location.host : /.*/,
          icon: null
        };
        _.extend(data, this.getInputState());
        if (!/^http/.test(data.url)) {
          data.url = this.model.get('service:base') + data.url;
        }
        for (domain in ExternalLinkIcons) {
          url = ExternalLinkIcons[domain];
          if (data.url.match(domain)) {
            if ((_ref3 = data.icon) == null) {
              data.icon = url;
            }
          }
        }
        return data;
      };

      Cell.prototype.render = function() {
        var data;

        data = this.getData();
        this.$el.html(CELL_HTML(data));
        if (data.checked) {
          this.$el.addClass('active');
        }
        if (this.model.get('id')) {
          this.setupPreviewOverlay();
        }
        return this;
      };

      Cell.prototype.setWidth = function(w) {
        return this;
      };

      Cell.prototype.activateChooser = function() {
        var selectable, selected, selecting, _ref2;

        this.reportClick();
        _ref2 = this.model.selectionState(), selected = _ref2.selected, selectable = _ref2.selectable, selecting = _ref2.selecting;
        if (selectable && selecting) {
          return this.model.set({
            'is:selected': !selected
          });
        }
      };

      return Cell;

    })(Backbone.View);
    NullCell = (function(_super) {
      __extends(NullCell, _super);

      function NullCell() {
        _ref2 = NullCell.__super__.constructor.apply(this, arguments);
        return _ref2;
      }

      NullCell.prototype.setupPreviewOverlay = function() {};

      NullCell.prototype.initialize = function(options) {
        this.options = options != null ? options : {};
        this.model = new intermine.model.NullObject();
        return NullCell.__super__.initialize.call(this);
      };

      return NullCell;

    })(Cell);
    return scope("intermine.results.table", {
      NullCell: NullCell,
      SubTable: SubTable,
      Cell: Cell
    });
  })();

  (function() {
    var COL_FILTER_TITLE, ColumnHeader, ICONS, NEXT_DIRECTION_OF, RENDER_TITLE, TEMPLATE, ignore, _ref;

    ignore = function(e) {
      if (e != null) {
        e.preventDefault();
      }
      if (e != null) {
        e.stopPropagation();
      }
      return false;
    };
    ICONS = function() {
      return {
        ASC: intermine.css.sortedASC,
        DESC: intermine.css.sortedDESC,
        css_unsorted: intermine.css.unsorted,
        css_header: intermine.css.headerIcon,
        css_remove: intermine.css.headerIconRemove,
        css_hide: intermine.css.headerIconHide,
        css_reveal: intermine.css.headerIconReveal,
        css_filter: intermine.icons.Filter,
        css_summary: intermine.icons.Summary,
        css_composed: intermine.icons.Composed
      };
    };
    TEMPLATE = _.template(" \n<div class=\"im-column-header\">\n  <div class=\"im-th-buttons\">\n    <% if (sortable) { %>\n      <span class=\"im-th-dropdown im-col-sort dropdown\">\n        <a class=\"im-th-button im-col-sort-indicator\" title=\"sort this column\">\n          <i class=\"icon-sorting <%- css_unsorted %> <%- css_header %>\"></i>\n        </a>\n        <div class=\"dropdown-menu\">\n          <div>Could not intitialise the sorting menu.</div>\n        </div>\n      </span>\n    <% }; %>\n    <a class=\"im-th-button im-col-remover\"\n       title=\"remove this column\">\n      <i class=\"<%- css_remove %> <%- css_header %>\"></i>\n    </a>\n    <a class=\"im-th-button im-col-minumaximiser\"\n       title=\"Toggle column visibility\">\n      <i class=\"<%- css_hide %> <%- css_header %>\"></i>\n    </a>\n    <span class=\"dropdown im-filter-summary im-th-dropdown\">\n      <a class=\"im-th-button im-col-filters dropdown-toggle\"\n         title=\"\"\n         data-toggle=\"dropdown\" >\n        <i class=\"<%- css_filter %> <%- css_header %>\"></i>\n      </a>\n      <div class=\"dropdown-menu\">\n        <div>Could not ititialise the filter summary.</div>\n      </div>\n    </span>\n    <span class=\"dropdown im-summary im-th-dropdown\">\n      <a class=\"im-th-button summary-img dropdown-toggle\" title=\"column summary\"\n        data-toggle=\"dropdown\" >\n        <i class=\"<%- css_summary %> <%- css_header %>\"></i>\n      </a>\n      <div class=\"dropdown-menu\">\n        <div>Could not ititialise the column summary.</div>\n      </div>\n    </span>\n    <a class=\"im-th-button im-col-composed\"\n        title=\"Toggle formatting\">\n      <i class=\"<%- css_composed %> <%- css_header %>\"></i>\n    </a>\n  </div>\n  <div class=\"im-col-title\">\n    <%- path %>\n  </div>\n</div>");
    COL_FILTER_TITLE = function(count) {
      if (count > 0) {
        return "" + count + " active filters";
      } else {
        return "Filter by values in this column";
      }
    };
    RENDER_TITLE = _.template("<div\n  class=\"im-title-part im-parent im-<%= parentType %>-parent<% if (!last) { %> im-last<% } %>\">\n    <%- penult %>\n</div>\n<% if (last) { %>\n  <div class=\"im-title-part im-last\"><%- last %></div>\n<% } %>");
    NEXT_DIRECTION_OF = {
      ASC: 'DESC',
      DESC: 'ASC'
    };
    ColumnHeader = (function(_super) {
      var firstResult, getCompositionTitle;

      __extends(ColumnHeader, _super);

      function ColumnHeader() {
        this.toggleSubTable = __bind(this.toggleSubTable, this);
        this.setSortOrder = __bind(this.setSortOrder, this);
        this.minumaximise = __bind(this.minumaximise, this);
        this.toggleColumnVisibility = __bind(this.toggleColumnVisibility, this);
        this.showFilterSummary = __bind(this.showFilterSummary, this);
        this.showColumnSummary = __bind(this.showColumnSummary, this);
        this.showSummary = __bind(this.showSummary, this);
        this.bestFit = __bind(this.bestFit, this);
        this.displaySortDirection = __bind(this.displaySortDirection, this);
        this.displayConCount = __bind(this.displayConCount, this);
        this.updateModel = __bind(this.updateModel, this);
        this.renderName = __bind(this.renderName, this);        _ref = ColumnHeader.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      ColumnHeader.prototype.tagName = 'th';

      ColumnHeader.prototype.className = 'im-column-th';

      ColumnHeader.prototype.initialize = function(_arg) {
        var query,
          _this = this;

        query = _arg.query;
        this.query = query;
        this.view = this.model.get('path').toString();
        if (this.model.get('replaces').length === 1 && this.model.get('isFormatted')) {
          this.view = this.model.get('replaces')[0].toString();
        }
        this.namePromise = this.model.get('path').getDisplayName();
        this.namePromise.done(function(name) {
          return _this.model.set({
            name: name
          });
        });
        this.updateModel();
        this.query.on('change:sortorder', this.updateModel);
        this.query.on('change:joins', this.updateModel);
        this.query.on('change:constraints', this.updateModel);
        this.query.on('change:minimisedCols', this.minumaximise);
        this.query.on('subtable:expanded', function(node) {
          if (node.toString().match(_this.view)) {
            return _this.model.set({
              expanded: true
            });
          }
        });
        this.query.on('subtable:collapsed', function(node) {
          if (node.toString().match(_this.view)) {
            return _this.model.set({
              expanded: false
            });
          }
        });
        this.query.on('showing:column-summary', function(path) {
          var _ref1;

          if (!path.equals(_this.model.get('path'))) {
            return (_ref1 = _this.summary) != null ? _ref1.remove() : void 0;
          }
        });
        this.model.on('change:conCount', this.displayConCount);
        return this.model.on('change:direction', this.displaySortDirection);
      };

      getCompositionTitle = function(replaces) {
        return "This column replaces " + replaces.length + " others. Click here\nto show the individual columns separately.";
      };

      ColumnHeader.prototype.renderName = function() {
        var ancestors, content, last, p, parentType, parts, penult, title, _i, _ref1;

        _ref1 = parts = this.model.get('name').split(' > '), ancestors = 3 <= _ref1.length ? __slice.call(_ref1, 0, _i = _ref1.length - 2) : (_i = 0, []), penult = _ref1[_i++], last = _ref1[_i++];
        parentType = ancestors.length ? 'non-root' : 'root';
        parts = (function() {
          var _j, _len, _results;

          _results = [];
          for (_j = 0, _len = parts.length; _j < _len; _j++) {
            p = parts[_j];
            _results.push("<span class=\"im-name-part\">" + p + "</span>");
          }
          return _results;
        })();
        content = RENDER_TITLE({
          penult: penult,
          last: last,
          parentType: parentType
        });
        title = parts.join('');
        return this.$('.im-col-title').html(content).popover({
          title: title,
          placement: 'bottom',
          html: true
        });
      };

      ColumnHeader.prototype.isComposed = function() {
        if (this.query.isOuterJoined(this.view)) {
          return false;
        }
        return (this.model.get('replaces') || []).length > 1;
      };

      ColumnHeader.prototype.render = function() {
        var replaces,
          _this = this;

        this.$el.empty();
        this.$el.append(this.html());
        this.displayConCount();
        this.displaySortDirection();
        this.namePromise.done(this.renderName);
        this.$('.summary-img').click(this.showColumnSummary);
        this.$('.im-col-filters').click(this.showFilterSummary);
        replaces = this.model.get('replaces');
        this.$('.im-col-composed').attr({
          title: getCompositionTitle(replaces)
        }).click(function() {
          return _this.query.trigger('formatter:blacklist', _this.view, _this.model.get('formatter'));
        });
        this.$el.toggleClass('im-is-composed', this.isComposed());
        this.$('.im-th-button').tooltip({
          placement: this.bestFit,
          container: this.el
        });
        this.$('.dropdown .dropdown-toggle').dropdown();
        if (!this.model.get('path').isAttribute() && this.query.isOuterJoined(this.view)) {
          this.addExpander();
        }
        if (this.model.get('expanded')) {
          this.query.trigger('expand:subtables', this.model.get('path'));
        }
        return this;
      };

      firstResult = _.compose(_.first, _.compact, _.map);

      ColumnHeader.prototype.updateModel = function() {
        var direction,
          _this = this;

        direction = firstResult(this.model.get('replaces').concat(this.view), function(p) {
          return _this.query.getSortDirection(p);
        });
        return this.model.set({
          direction: direction,
          sortable: !this.query.isOuterJoined(this.view),
          conCount: _.size(_.filter(this.query.constraints, function(c) {
            return !!c.path.match(_this.view);
          }))
        });
      };

      ColumnHeader.prototype.displayConCount = function() {
        var conCount;

        conCount = this.model.get('conCount');
        if (conCount) {
          this.$el.addClass('im-has-constraint');
        }
        return this.$('.im-col-filters').attr({
          title: COL_FILTER_TITLE(conCount)
        });
      };

      ColumnHeader.prototype.html = function() {
        var data;

        data = _.extend({}, ICONS(), this.model.toJSON());
        return TEMPLATE(data);
      };

      ColumnHeader.prototype.displaySortDirection = function() {
        var ASC, DESC, css_unsorted, icons, sortButton, _ref1;

        sortButton = this.$('.icon-sorting');
        _ref1 = icons = ICONS(), css_unsorted = _ref1.css_unsorted, ASC = _ref1.ASC, DESC = _ref1.DESC;
        sortButton.addClass(css_unsorted);
        sortButton.removeClass(ASC + ' ' + DESC);
        if (this.model.has('direction')) {
          return sortButton.toggleClass(css_unsorted + ' ' + icons[this.model.get('direction')]);
        }
      };

      ColumnHeader.prototype.events = {
        'click .im-col-sort': 'setSortOrder',
        'click .im-col-minumaximiser': 'toggleColumnVisibility',
        'click .im-col-filters': 'showFilterSummary',
        'click .im-subtable-expander': 'toggleSubTable',
        'click .im-col-remover': 'removeColumn',
        'toggle .im-th-button': 'summaryToggled'
      };

      ColumnHeader.prototype.summaryToggled = function(e, isOpen) {
        var _ref1;

        ignore(e);
        if (e.target !== e.currentTarget) {
          return;
        }
        if (!isOpen) {
          return (_ref1 = this.summary) != null ? _ref1.remove() : void 0;
        }
      };

      ColumnHeader.prototype.hideTooltips = function() {
        return this.$('.im-th-button').tooltip('hide');
      };

      ColumnHeader.prototype.removeColumn = function(e) {
        var unwanted, v;

        this.hideTooltips();
        unwanted = (function() {
          var _i, _len, _ref1, _results;

          _ref1 = this.query.views;
          _results = [];
          for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
            v = _ref1[_i];
            if (v.match(this.view)) {
              _results.push(v);
            }
          }
          return _results;
        }).call(this);
        this.query.removeFromSelect(unwanted);
        return false;
      };

      ColumnHeader.prototype.bestFit = function(tip, elem) {
        $(tip).addClass(intermine.options.StylePrefix);
        return 'top';
      };

      ColumnHeader.prototype.checkHowFarOver = function(el) {
        var bounds;

        bounds = this.$el.closest('.im-table-container');
        if ((el.offset().left + 350) >= (bounds.offset().left + bounds.width())) {
          return this.$el.addClass('too-far-over');
        }
      };

      ColumnHeader.prototype.showSummary = function(selector, View) {
        var _this = this;

        return function(e) {
          var $menu, summary;

          ignore(e);
          _this.checkHowFarOver(e != null ? $(e.currentTarget) : _this.$el);
          if (!_this.$(selector).hasClass('open')) {
            _this.query.trigger('showing:column-summary', _this.model.get('path'));
            summary = new View(_this.query, _this.model.get('path'), _this.model);
            $menu = _this.$(selector + ' .dropdown-menu');
            if (!$menu.length) {
              console.log("" + selector + " not found");
            }
            $menu.html(summary.el);
            summary.render();
            _this.summary = summary;
          }
          return false;
        };
      };

      ColumnHeader.prototype.showColumnSummary = function(e) {
        var cls;

        cls = this.path().isAttribute() ? intermine.query.results.DropDownColumnSummary : intermine.query.results.OuterJoinDropDown;
        return this.showSummary('.im-summary', cls)(e);
      };

      ColumnHeader.prototype.showFilterSummary = function(e) {
        return this.showSummary('.im-filter-summary', intermine.query.filters.SingleColumnConstraints)(e);
      };

      ColumnHeader.prototype.toggleColumnVisibility = function(e) {
        if (e != null) {
          e.preventDefault();
        }
        if (e != null) {
          e.stopPropagation();
        }
        return this.query.trigger('columnvis:toggle', this.view);
      };

      ColumnHeader.prototype.minumaximise = function(minimisedCols) {
        var $i, css_hide, css_reveal, minimised, _ref1;

        _ref1 = ICONS(), css_hide = _ref1.css_hide, css_reveal = _ref1.css_reveal;
        $i = this.$('.im-col-minumaximiser i').removeClass(css_hide + ' ' + css_reveal);
        minimised = minimisedCols[this.view];
        $i.addClass(minimised ? css_reveal : css_hide);
        this.$el.toggleClass('im-minimised-th', !!minimised);
        return this.$('.im-col-title').toggle(!minimised);
      };

      ColumnHeader.prototype.path = function() {
        return this.model.get('path');
      };

      ColumnHeader.prototype.setSortOrder = function(e) {
        var direction, formatter, replaces, _ref1, _ref2;

        _ref1 = this.model.toJSON(), direction = _ref1.direction, replaces = _ref1.replaces;
        direction = (_ref2 = NEXT_DIRECTION_OF[direction]) != null ? _ref2 : 'ASC';
        formatter = intermine.results.getFormatter(this.path());
        if (replaces.length) {
          this.showSummary('.im-col-sort', intermine.query.FormattedSorting)(e);
          return this.$('.im-col-sort').toggleClass('open');
        } else {
          this.$('.im-col-sort').removeClass('open');
          return this.query.orderBy([
            {
              path: this.view,
              direction: direction
            }
          ]);
        }
      };

      ColumnHeader.prototype.addExpander = function() {
        var expandAll;

        expandAll = $("<a href=\"#\" \n   class=\"im-subtable-expander im-th-button\"\n   title=\"Expand/Collapse all subtables\">\n  <i class=\"" + intermine.icons.Table + "\"></i>\n</a>");
        expandAll.tooltip({
          placement: this.bestFit
        });
        return this.$('.im-th-buttons').prepend(expandAll);
      };

      ColumnHeader.prototype.toggleSubTable = function(e) {
        var cmd, isExpanded;

        ignore(e);
        isExpanded = this.model.get('expanded');
        cmd = isExpanded ? 'collapse' : 'expand';
        this.query.trigger(cmd + ':subtables', this.model.get('path'));
        return this.model.set({
          expanded: !isExpanded
        });
      };

      return ColumnHeader;

    })(Backbone.View);
    return scope('intermine.query.results', {
      ColumnHeader: ColumnHeader
    });
  })();

  scope('intermine.snippets.table', {
    NoResults: function(query) {
      return _.template("<tr>\n  <td colspan=\"<%= views.length %>\">\n    <div class=\"im-no-results alert alert-info\">\n      <div <% if (revision === 0) { %> style=\"display:none;\" <% } %> >\n        " + intermine.snippets.query.UndoButton + "\n      </div>\n      <strong>NO RESULTS</strong>\n      This query returned 0 results.\n      <div style=\"clear:both\"></div>\n    </div>\n  </td>\n</tr>", query);
    },
    CountSummary: _.template("<span class=\"hidden-phone\">\n<span class=\"im-only-widescreen\">Showing</span>\n<span>\n  <% if (last == 0) { %>\n      All\n  <% } else { %>\n      <%= first %> to <%= last %> of\n  <% } %>\n  <%= count %> <span class=\"visible-desktop\"><%= roots %></span>\n</span>\n</span>"),
    Pagination: "<div class=\"pagination pagination-right\">\n  <ul>\n    <li title=\"Go to start\">\n      <a class=\"im-pagination-button\" data-goto=start>&#x21e4;</a>\n    </li>\n    <li title=\"Go back five pages\" class=\"visible-desktop\">\n      <a class=\"im-pagination-button\" data-goto=fast-rewind>&#x219e;</a>\n    </li>\n    <li title=\"Go to previous page\">\n      <a class=\"im-pagination-button\" data-goto=prev>&larr;</a>\n    </li>\n    <li class=\"im-current-page\">\n      <a data-goto=here  href=\"#\">&hellip;</a>\n      <form class=\"im-page-form input-append form form-horizontal\" style=\"display:none;\">\n      <div class=\"control-group\"></div>\n    </form>\n    </li>\n    <li title=\"Go to next page\">\n      <a class=\"im-pagination-button\" data-goto=next>&rarr;</a>\n    </li>\n    <li title=\"Go forward five pages\" class=\"visible-desktop\">\n      <a class=\"im-pagination-button\" data-goto=fast-forward>&#x21a0;</a>\n    </li>\n    <li title=\"Go to last page\">\n      <a class=\"im-pagination-button\" data-goto=end>&#x21e5;</a>\n    </li>\n  </ul>\n</div>"
  });

  scope('intermine.snippets.query', {
    UndoButton: "<button class=\"btn btn-primary pull-right\">\n  <i class=\"" + intermine.icons.Undo + "\"></i> undo\n</button>"
  });

  (function() {
    var NUMERIC_TYPES, Page, PageSizer, ResultsTable, Table, _ref, _ref1, _ref2;

    NUMERIC_TYPES = ["int", "Integer", "double", "Double", "float", "Float"];
    Page = (function() {
      function Page(start, size) {
        this.start = start;
        this.size = size;
      }

      Page.prototype.end = function() {
        return this.start + this.size;
      };

      Page.prototype.all = function() {
        return !this.size;
      };

      Page.prototype.toString = function() {
        return "Page(" + this.start + ", " + this.size + ")";
      };

      return Page;

    })();
    ResultsTable = (function(_super) {
      __extends(ResultsTable, _super);

      function ResultsTable() {
        this.addColumnHeaders = __bind(this.addColumnHeaders, this);
        this.handleError = __bind(this.handleError, this);
        this.appendRow = __bind(this.appendRow, this);
        this.readHeaderInfo = __bind(this.readHeaderInfo, this);
        this.appendRows = __bind(this.appendRows, this);        _ref = ResultsTable.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      ResultsTable.nextDirections = {
        ASC: "DESC",
        DESC: "ASC"
      };

      ResultsTable.prototype.className = "im-results-table table table-striped table-bordered";

      ResultsTable.prototype.tagName = "table";

      ResultsTable.prototype.attributes = {
        width: "100%",
        cellpadding: 0,
        border: 0,
        cellspacing: 0
      };

      ResultsTable.prototype.pageSize = 25;

      ResultsTable.prototype.pageStart = 0;

      ResultsTable.prototype.throbber = _.template("<tr class=\"im-table-throbber\">\n  <td colspan=\"<%= colcount %>\">\n    <h2>Requesting Data</h2>\n    <div class=\"progress progress-info progress-striped active\">\n      <div class=\"bar\" style=\"width: 100%\"></div>\n    </div>\n  </td>\n</tr>");

      ResultsTable.prototype.initialize = function(query, getData, columnHeaders) {
        var _ref1,
          _this = this;

        this.query = query;
        this.getData = getData;
        this.columnHeaders = columnHeaders;
        if ((_ref1 = this.columnHeaders) == null) {
          this.columnHeaders = new Backbone.Collection;
        }
        this.blacklistedFormatters = [];
        this.minimisedCols = {};
        this.query.on("set:sortorder", function(oes) {
          _this.lastAction = 'resort';
          return _this.fill();
        });
        this.query.on('columnvis:toggle', function(view) {
          _this.minimisedCols[view] = !_this.minimisedCols[view];
          _this.query.trigger('change:minimisedCols', _.extend({}, _this.minimisedCols));
          return _this.fill();
        });
        return this.query.on("formatter:blacklist", function(path, formatter) {
          _this.blacklistedFormatters.push(formatter);
          return _this.fill().then(_this.addColumnHeaders);
        });
      };

      ResultsTable.prototype.changePageSize = function(newSize) {
        this.pageSize = newSize;
        if (newSize === 0) {
          this.pageStart = 0;
        }
        return this.fill();
      };

      ResultsTable.prototype.render = function() {
        var promise;

        this.$el.empty();
        this.$el.append(document.createElement('thead'));
        this.$el.append(document.createElement('tbody'));
        promise = this.fill();
        return promise.done(this.addColumnHeaders);
      };

      ResultsTable.prototype.goTo = function(start) {
        this.pageStart = parseInt(start, 10);
        return this.fill();
      };

      ResultsTable.prototype.goToPage = function(page) {
        this.pageStart = page * this.pageSize;
        return this.fill();
      };

      ResultsTable.prototype.fill = function() {
        var promise,
          _this = this;

        promise = this.getData(this.pageStart, this.pageSize).then(this.readHeaderInfo);
        promise.done(this.appendRows);
        promise.fail(this.handleError);
        promise.done(function() {
          return _this.query.trigger("imtable:change:page", _this.pageStart, _this.pageSize);
        });
        return promise;
      };

      ResultsTable.prototype.handleEmptyTable = function() {
        var apology,
          _this = this;

        apology = _.template(intermine.snippets.table.NoResults(this.query));
        this.$el.append(apology);
        return this.$el.find('.btn-primary').click(function() {
          return _this.query.trigger('undo');
        });
      };

      ResultsTable.prototype.appendRows = function(res) {
        var docfrag, row, _i, _len, _ref1;

        if (res.rows.length === 0) {
          this.$("tbody > tr").remove();
          this.handleEmptyTable();
        } else {
          docfrag = document.createDocumentFragment();
          _ref1 = res.rows;
          for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
            row = _ref1[_i];
            this.appendRow(docfrag, row);
          }
          this.$el.children('tbody').html(docfrag);
        }
        return this.query.trigger("table:filled");
      };

      ResultsTable.prototype.minimisedColumnPlaceholder = _.template("<td class=\"im-minimised-col\" style=\"width:<%= width %>px\">&hellip;</td>");

      ResultsTable.prototype.readHeaderInfo = function(res) {
        var _ref1,
          _this = this;

        if (res != null ? (_ref1 = res.results) != null ? _ref1[0] : void 0 : void 0) {
          return this.getEffectiveView(res.results[0]).then(function() {
            return res;
          });
        } else {
          return res;
        }
      };

      ResultsTable.prototype.appendRow = function(tbody, row) {
        var cell, i, k, minWidth, minimised, processed, replacer_of, tr, v, _i, _len, _results,
          _this = this;

        tr = document.createElement('tr');
        tbody.appendChild(tr);
        minWidth = 10;
        minimised = (function() {
          var _ref1, _results;

          _ref1 = this.minimisedCols;
          _results = [];
          for (k in _ref1) {
            v = _ref1[k];
            if (v) {
              _results.push(k);
            }
          }
          return _results;
        }).call(this);
        replacer_of = {};
        processed = {};
        this.columnHeaders.each(function(col) {
          var r, rs, _i, _len, _ref1, _results;

          _ref1 = (rs = col.get('replaces'));
          _results = [];
          for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
            r = _ref1[_i];
            _results.push(replacer_of[r] = col);
          }
          return _results;
        });
        _results = [];
        for (i = _i = 0, _len = row.length; _i < _len; i = ++_i) {
          cell = row[i];
          _results.push((function(cell, i) {
            var c, formatter, path, r, replaces, _j, _k, _len1, _len2, _ref1, _ref2, _ref3;

            if (processed[cell.path]) {
              return;
            }
            processed[cell.path] = true;
            _ref3 = (_ref1 = (_ref2 = replacer_of[cell.path]) != null ? _ref2.toJSON() : void 0) != null ? _ref1 : {}, replaces = _ref3.replaces, formatter = _ref3.formatter, path = _ref3.path;
            if ((replaces != null ? replaces.length : void 0) > 1) {
              if (!path.equals(cell.path.getParent())) {
                return;
              }
              if ((formatter != null ? formatter.merge : void 0) != null) {
                for (_j = 0, _len1 = row.length; _j < _len1; _j++) {
                  c = row[_j];
                  if (_.any(replaces, function(x) {
                    return x.equals(c.path);
                  })) {
                    formatter.merge(cell.model, c.model);
                  }
                }
              }
              for (_k = 0, _len2 = replaces.length; _k < _len2; _k++) {
                r = replaces[_k];
                processed[r] = true;
              }
            }
            if (formatter != null) {
              cell.formatter = formatter;
            }
            if (_this.minimisedCols[cell.path] || (path && _this.minimisedCols[path])) {
              return $(tr).append(_this.minimisedColumnPlaceholder({
                width: minWidth
              }));
            } else {
              cell.render();
              return tr.appendChild(cell.el);
            }
          })(cell, i));
        }
        return _results;
      };

      ResultsTable.prototype.errorTempl = _.template("<div class=\"alert alert-error\">\n    <h2>Oops!</h2>\n    <p><i><%- error %></i></p>\n</div>");

      ResultsTable.prototype.handleError = function(err, time) {
        var btn, mailto, notice, p;

        notice = $(this.errorTempl({
          error: err
        }));
        if (time != null) {
          notice.append("<p>Time: " + time + "</p>");
        }
        notice.append("<p>\n    This is most likely related to the query that was just run. If you have\n    time, please send us an email with details of this query to help us diagnose and\n    fix this bug.\n</p>");
        btn = $('<button class="btn btn-error">');
        notice.append(btn);
        p = $('<p style="display:none" class="well">');
        btn.text('show query');
        p.text(this.query.toXML());
        btn.click(function() {
          return p.slideToggle();
        });
        mailto = this.query.service.help + "?" + $.param({
          subject: "Error running embedded table query",
          body: "We encountered an error running a query from an\nembedded result table.\n\npage:       " + window.location + "\nservice:    " + this.query.service.root + "\nerror:      " + err + "\ndate-stamp: " + time + "\nquery:      " + (this.query.toXML())
        }, true);
        mailto = mailto.replace(/\+/g, '%20');
        notice.append("<a class=\"btn btn-primary pull-right\" href=\"mailto:" + mailto + "\">\n    Email the help-desk\n</a>");
        notice.append(p);
        return this.$el.append(notice);
      };

      ResultsTable.prototype.buildColumnHeader = function(model, tr) {
        var header;

        header = new intermine.query.results.ColumnHeader({
          model: model,
          query: this.query
        });
        return header.render().$el.appendTo(tr);
      };

      ResultsTable.prototype.getEffectiveView = function(row) {
        var _this = this;

        return this.query.service.get("/classkeys").then(function(_arg) {
          var cell, classKeys, classes, col, cols, commonPrefix, explicitReplacements, formatter, getReplacedTest, isKeyField, isReplaced, longestCommonPrefix, p, path, q, r, replacedBy, replaces, subPath, v, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _m, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _results;

          classes = _arg.classes;
          q = _this.query;
          classKeys = classes;
          replacedBy = {};
          _this.columnHeaders.reset();
          _ref1 = intermine.utils, longestCommonPrefix = _ref1.longestCommonPrefix, getReplacedTest = _ref1.getReplacedTest;
          cols = (function() {
            var _i, _len, _results;

            _results = [];
            for (_i = 0, _len = row.length; _i < _len; _i++) {
              cell = row[_i];
              path = q.getPathInfo(cell.column);
              replaces = cell.view != null ? (commonPrefix = longestCommonPrefix(cell.view), path = q.getPathInfo(commonPrefix), replaces = (function() {
                var _j, _len1, _ref2, _results1;

                _ref2 = cell.view;
                _results1 = [];
                for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
                  v = _ref2[_j];
                  _results1.push(q.getPathInfo(v));
                }
                return _results1;
              })()) : [];
              _results.push({
                path: path,
                replaces: replaces
              });
            }
            return _results;
          })();
          for (_i = 0, _len = cols.length; _i < _len; _i++) {
            col = cols[_i];
            if (!(col.path.isAttribute() && intermine.results.shouldFormat(col.path))) {
              continue;
            }
            p = col.path;
            formatter = intermine.results.getFormatter(p);
            if (__indexOf.call(_this.blacklistedFormatters, formatter) < 0) {
              col.isFormatted = true;
              col.formatter = formatter;
              _ref3 = (_ref2 = formatter.replaces) != null ? _ref2 : [];
              for (_j = 0, _len1 = _ref3.length; _j < _len1; _j++) {
                r = _ref3[_j];
                subPath = "" + (p.getParent()) + "." + r;
                if ((_ref4 = replacedBy[subPath]) == null) {
                  replacedBy[subPath] = col;
                }
                if (__indexOf.call(q.views, subPath) >= 0) {
                  col.replaces.push(q.getPathInfo(subPath));
                }
              }
            }
          }
          isKeyField = function(col) {
            var fName, pType, _ref5, _ref6;

            if (!col.path.isAttribute()) {
              return false;
            }
            pType = col.path.getParent().getType().name;
            fName = col.path.end.name;
            return _ref5 = "" + pType + "." + fName, __indexOf.call((_ref6 = classKeys != null ? classKeys[pType] : void 0) != null ? _ref6 : [], _ref5) >= 0;
          };
          explicitReplacements = {};
          for (_k = 0, _len2 = cols.length; _k < _len2; _k++) {
            col = cols[_k];
            _ref5 = col.replaces;
            for (_l = 0, _len3 = _ref5.length; _l < _len3; _l++) {
              r = _ref5[_l];
              explicitReplacements[r] = col;
            }
          }
          isReplaced = getReplacedTest(replacedBy, explicitReplacements);
          _results = [];
          for (_m = 0, _len4 = cols.length; _m < _len4; _m++) {
            col = cols[_m];
            if (!(!isReplaced(col))) {
              continue;
            }
            if (col.isFormatted) {
              if (_ref6 = col.path, __indexOf.call(col.replaces, _ref6) < 0) {
                col.replaces.push(col.path);
              }
              if (isKeyField(col) || col.replaces.length > 1) {
                col.path = col.path.getParent();
              }
            }
            _results.push(_this.columnHeaders.add(col));
          }
          return _results;
        });
      };

      ResultsTable.prototype.addColumnHeaders = function() {
        var docfrag, tr,
          _this = this;

        docfrag = document.createDocumentFragment();
        tr = document.createElement('tr');
        docfrag.appendChild(tr);
        this.columnHeaders.each(function(model) {
          return _this.buildColumnHeader(model, tr);
        });
        return this.$el.children('thead').html(docfrag);
      };

      return ResultsTable;

    })(Backbone.View);
    PageSizer = (function(_super) {
      __extends(PageSizer, _super);

      function PageSizer() {
        _ref1 = PageSizer.__super__.constructor.apply(this, arguments);
        return _ref1;
      }

      PageSizer.prototype.tagName = 'form';

      PageSizer.prototype.className = "im-page-sizer form-horizontal";

      PageSizer.prototype.sizes = [[10], [25], [50], [100], [250]];

      PageSizer.prototype.initialize = function(query, pageSize) {
        var _this = this;

        this.query = query;
        this.pageSize = pageSize;
        if (this.pageSize != null) {
          if (!_.include(this.sizes.map(function(s) {
            return s[0];
          }), this.pageSize)) {
            this.sizes.unshift([this.pageSize, this.pageSize]);
          }
        } else {
          this.pageSize = this.sizes[0][0];
        }
        return this.query.on('page-size:revert', function(size) {
          return _this.$('select').val(size);
        });
      };

      PageSizer.prototype.events = {
        "change select": "changePageSize"
      };

      PageSizer.prototype.changePageSize = function(evt) {
        return this.query.trigger("page-size:selected", parseInt($(evt.target).val(), 10));
      };

      PageSizer.prototype.render = function() {
        var ps, select, _i, _len, _ref2;

        this.$el.append("<label>\n    <span class=\"im-only-widescreen\">Rows per page:</span>\n    <select class=\"span\" title=\"Rows per page\">\n    </select>\n</label>");
        select = this.$('select');
        _ref2 = this.sizes;
        for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
          ps = _ref2[_i];
          select.append(this.make('option', {
            value: ps[0],
            selected: ps[0] === this.pageSize
          }, ps[1] || ps[0]));
        }
        return this;
      };

      return PageSizer;

    })(Backbone.View);
    Table = (function(_super) {
      var badJson, errorIntro, genericExplanation;

      __extends(Table, _super);

      function Table() {
        this.updatePageDisplay = __bind(this.updatePageDisplay, this);
        this.removeOverlay = __bind(this.removeOverlay, this);
        this.overlayTable = __bind(this.overlayTable, this);
        this.getRowData = __bind(this.getRowData, this);
        this.showError = __bind(this.showError, this);
        this.handlePageSizeSelection = __bind(this.handlePageSizeSelection, this);
        this.refresh = __bind(this.refresh, this);
        this.onDraw = __bind(this.onDraw, this);        _ref2 = Table.__super__.constructor.apply(this, arguments);
        return _ref2;
      }

      Table.prototype.className = "im-table-container";

      Table.prototype.events = {
        'submit .im-page-form': 'pageFormSubmit',
        'click .im-pagination-button': 'pageButtonClick'
      };

      Table.prototype.onDraw = function() {
        if (this.__selecting) {
          this.query.trigger("start:list-creation");
        }
        return this.drawn = true;
      };

      Table.prototype.refresh = function() {
        var _ref3;

        this.query.__changed = (this.query.__changed || 0) + 1;
        if ((_ref3 = this.table) != null) {
          _ref3.remove();
        }
        this.drawn = false;
        return this.render();
      };

      Table.prototype.remove = function() {
        var _ref3;

        if ((_ref3 = this.table) != null) {
          _ref3.remove();
        }
        return Table.__super__.remove.call(this);
      };

      Table.prototype.initialize = function(query, selector, columnHeaders) {
        var _this = this;

        this.query = query;
        this.columnHeaders = columnHeaders;
        this.cache = {};
        this.itemModels = {};
        this._pipe_factor = 10;
        this.$parent = jQuery(selector);
        this.__selecting = false;
        this.visibleViews = this.query.views.slice();
        this.query.on("start:list-creation", function() {
          return _this.__selecting = true;
        });
        this.query.on("stop:list-creation", function() {
          return _this.__selecting = false;
        });
        this.query.on("table:filled", this.onDraw);
        this.query.on('page:forwards', function() {
          return _this.goForward(1);
        });
        this.query.on('page:backwards', function() {
          return _this.goBack(1);
        });
        this.query.on("page-size:selected", this.handlePageSizeSelection);
        this.query.on("add-filter-dialogue:please", function() {
          var dialogue;

          dialogue = new intermine.filters.NewFilterDialogue(_this.query);
          _this.$el.append(dialogue.el);
          return dialogue.render().openDialogue();
        });
        return this.query.on("download-menu:open", function() {
          var dialogue;

          dialogue = new intermine.query["export"].ExportDialogue(_this.query);
          _this.$el.append(dialogue.render().el);
          return dialogue.show();
        });
      };

      Table.prototype.pageSizeFeasibilityThreshold = 250;

      Table.prototype.aboveSizeThreshold = function(size) {
        var total;

        if (size >= this.pageSizeFeasibilityThreshold) {
          return true;
        }
        if (size === 0) {
          total = this.cache.lastResult.iTotalRecords;
          return total >= this.pageSizeFeasibilityThreshold;
        }
        return false;
      };

      Table.prototype.handlePageSizeSelection = function(size) {
        var $really,
          _this = this;

        if (this.aboveSizeThreshold(size)) {
          $really = $(intermine.snippets.table.LargeTableDisuader);
          $really.find('.btn-primary').click(function() {
            return _this.table.changePageSize(size);
          });
          $really.find('.btn').click(function() {
            return $really.modal('hide');
          });
          $really.find('.im-alternative-action').click(function(e) {
            if ($(e.target).data('event')) {
              _this.query.trigger($(e.target).data('event'));
            }
            return _this.query.trigger('page-size:revert', _this.table.pageSize);
          });
          $really.on('hidden', function() {
            return $really.remove();
          });
          return $really.appendTo(this.el).modal().modal('show');
        } else {
          return this.table.changePageSize(size);
        }
      };

      Table.prototype.adjustSortOrder = function(params) {
        var i, noOfSortColumns, viewIndices;

        viewIndices = (function() {
          var _i, _ref3, _results;

          _results = [];
          for (i = _i = 0, _ref3 = intermine.utils.getParameter(params, "iColumns"); 0 <= _ref3 ? _i <= _ref3 : _i >= _ref3; i = 0 <= _ref3 ? ++_i : --_i) {
            _results.push(intermine.utils.getParameter(params, "mDataProp_" + i));
          }
          return _results;
        })();
        noOfSortColumns = intermine.utils.getParameter(params, "iSortingCols");
        if (noOfSortColumns) {
          return this.query.orderBy((function() {
            var _i, _results,
              _this = this;

            _results = [];
            for (i = _i = 0; 0 <= noOfSortColumns ? _i < noOfSortColumns : _i > noOfSortColumns; i = 0 <= noOfSortColumns ? ++_i : --_i) {
              _results.push((function(i) {
                var displayed, so;

                displayed = intermine.utils.getParameter(params, "iSortCol_" + i);
                so = {
                  path: _this.query.views[viewIndices[displayed]],
                  direction: intermine.utils.getParameter(params, "sSortDir_" + i)
                };
                return so;
              })(i));
            }
            return _results;
          }).call(this));
        }
      };

      Table.prototype.showError = function(resp) {
        var data, err, _ref3, _ref4;

        try {
          data = JSON.parse(resp.responseText);
          return (_ref3 = this.table) != null ? _ref3.handleError(data.error, data.executionTime) : void 0;
        } catch (_error) {
          err = _error;
          return (_ref4 = this.table) != null ? _ref4.handleError("Internal error", new Date().toString()) : void 0;
        }
      };

      Table.prototype.getRowData = function(start, size) {
        var end, freshness, isOutOfRange, isStale, page, promise, req,
          _this = this;

        end = start + size;
        isOutOfRange = false;
        freshness = this.query.getSorting() + this.query.getConstraintXML() + this.query.views.join();
        isStale = freshness !== this.cache.freshness;
        if (isStale) {
          this.cache = {};
        } else {
          isOutOfRange = this.cache.lowerBound < 0 || start < this.cache.lowerBound || end > this.cache.upperBound || size <= 0;
        }
        promise = new jQuery.Deferred();
        if (isStale || isOutOfRange) {
          page = this.getPage(start, size);
          this.overlayTable();
          req = this.query[this.fetchMethod]({
            start: page.start,
            size: page.size
          });
          req.fail(this.showError);
          req.done(function(rows, rs) {
            _this.addRowsToCache(page, rs);
            _this.cache.freshness = freshness;
            return promise.resolve(_this.serveResultsFromCache(start, size));
          });
          req.always(this.removeOverlay);
        } else {
          promise.resolve(this.serveResultsFromCache(start, size));
        }
        return promise;
      };

      Table.prototype.overlayTable = function() {
        var elOffset, tableOffset,
          _this = this;

        if (!(this.table && this.drawn)) {
          return;
        }
        elOffset = this.$el.offset();
        tableOffset = this.table.$el.offset();
        jQuery('.im-table-overlay').remove();
        this.overlay = jQuery(this.make("div", {
          "class": "im-table-overlay discrete " + intermine.options.StylePrefix
        }));
        this.overlay.css({
          top: elOffset.top,
          left: elOffset.left,
          width: this.table.$el.outerWidth(true),
          height: (tableOffset.top - elOffset.top) + this.table.$el.outerHeight()
        });
        this.overlay.append(this.make("h1", {}, "Requesting data..."));
        this.overlay.find("h1").css({
          top: (this.table.$el.height() / 2) + "px",
          left: (this.table.$el.width() / 4) + "px"
        });
        this.overlay.appendTo('body');
        return _.delay((function() {
          return _this.overlay.removeClass("discrete");
        }), 100);
      };

      Table.prototype.removeOverlay = function() {
        var _ref3;

        return (_ref3 = this.overlay) != null ? _ref3.remove() : void 0;
      };

      Table.prototype.getPage = function(start, size) {
        var page;

        page = new Page(start, size);
        if (!this.cache.lastResult) {
          page.size *= this._pipe_factor;
          return page;
        }
        if (start < this.cache.lowerBound) {
          page.start = Math.max(0, start - (size * this._pipe_factor));
        }
        if (size > 0) {
          page.size *= this._pipe_factor;
        } else {
          page.size = '';
        }
        if (page.size && (page.end() < this.cache.lowerBound)) {
          if ((this.cache.lowerBound - page.end()) > (page.size * 10)) {
            this.cache = {};
            page.size *= 2;
            return page;
          } else {
            page.size = this.cache.lowerBound - page.start;
          }
        }
        if (this.cache.upperBound < page.start) {
          if ((page.start - this.cache.upperBound) > (page.size * 10)) {
            this.cache = {};
            page.size *= 2;
            page.start = Math.max(0, page.start - (size * this._pipe_factor));
            return page;
          }
          if (page.size) {
            page.size += page.start - this.cache.upperBound;
          }
          page.start = this.cache.upperBound;
        }
        return page;
      };

      Table.prototype.addRowsToCache = function(page, result) {
        var merged, rows;

        if (!this.cache.lastResult) {
          this.cache.lastResult = result;
          this.cache.lowerBound = result.start;
          return this.cache.upperBound = page.end();
        } else {
          rows = result.results;
          merged = this.cache.lastResult.results.slice();
          if (page.start < this.cache.lowerBound) {
            merged = rows.concat(merged.slice(page.end() - this.cache.lowerBound));
          }
          if (this.cache.upperBound < page.end() || page.all()) {
            merged = merged.slice(0, page.start - this.cache.lowerBound).concat(rows);
          }
          this.cache.lowerBound = Math.min(this.cache.lowerBound, page.start);
          this.cache.upperBound = this.cache.lowerBound + merged.length;
          return this.cache.lastResult.results = merged;
        }
      };

      Table.prototype.updateSummary = function(start, size, result) {
        var html, summary;

        summary = this.$('.im-table-summary');
        html = intermine.snippets.table.CountSummary({
          first: start + 1,
          last: size === 0 ? 0 : Math.min(start + size, result.iTotalRecords),
          count: intermine.utils.numToString(result.iTotalRecords, ",", 3),
          roots: "rows"
        });
        summary.html(html);
        return this.query.trigger('count:is', result.iTotalRecords);
      };

      Table.prototype.serveResultsFromCache = function(start, size) {
        var base, fields, makeCell, result, v,
          _this = this;

        base = this.query.service.root.replace(/\/service\/?$/, "");
        result = jQuery.extend(true, {}, this.cache.lastResult);
        result.results.splice(0, start - this.cache.lowerBound);
        if (size > 0) {
          result.results.splice(size, result.results.length);
        }
        this.updateSummary(start, size, result);
        fields = (function() {
          var _i, _len, _ref3, _results;

          _ref3 = result.views;
          _results = [];
          for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
            v = _ref3[_i];
            _results.push([this.query.getPathInfo(v).getParent(), v.replace(/^.*\./, "")]);
          }
          return _results;
        }).call(this);
        makeCell = function(obj) {
          var args, field, model, node, type, _base, _name, _ref3, _ref4;

          if (_.has(obj, 'rows')) {
            node = _this.query.getPathInfo(obj.column);
            return new intermine.results.table.SubTable({
              query: _this.query,
              cellify: makeCell,
              blacklistedFormatters: (_ref3 = (_ref4 = _this.table) != null ? _ref4.blacklistedFormatters : void 0) != null ? _ref3 : [],
              mainTable: _this,
              subtable: obj,
              node: node
            });
          } else {
            node = _this.query.getPathInfo(obj.column).getParent();
            field = obj.column.replace(/^.*\./, '');
            model = obj.id != null ? (_base = _this.itemModels)[_name = obj.id] || (_base[_name] = new intermine.model.IMObject(obj, _this.query, field, base)) : obj["class"] == null ? (type = node.getParent().name, new intermine.model.NullObject({}, {
              query: _this.query,
              field: field,
              type: type
            })) : new intermine.model.FPObject({}, {
              query: _this.query,
              obj: obj,
              field: field
            });
            model.merge(obj, field);
            args = {
              model: model,
              node: node,
              field: field
            };
            args.query = _this.query;
            return new intermine.results.table.Cell(args);
          }
        };
        result.rows = result.results.map(function(row) {
          return row.map(function(cell, idx) {
            var field, imo, _base, _name;

            if (_.has(cell, 'column')) {
              return makeCell(cell);
            } else if ((cell != null ? cell.id : void 0) != null) {
              field = fields[idx];
              imo = (_base = _this.itemModels)[_name = cell.id] || (_base[_name] = new intermine.model.IMObject(cell, _this.query, field[1], base));
              imo.merge(cell, field[1]);
              return new intermine.results.table.Cell({
                model: imo,
                node: field[0],
                field: field[1],
                query: _this.query
              });
            } else if ((cell != null ? cell.value : void 0) != null) {
              return new intermine.results.table.Cell({
                model: new intermine.model.FPObject(_this.query, cell, field[1]),
                query: _this.query,
                field: field[1]
              });
            } else {
              return new intermine.results.table.NullCell({
                query: _this.query
              });
            }
          });
        });
        return result;
      };

      Table.prototype.tableAttrs = {
        "class": "table table-striped table-bordered",
        width: "100%",
        cellpadding: 0,
        border: 0,
        cellspacing: 0
      };

      Table.prototype.render = function() {
        var tel;

        this.$el.empty();
        tel = this.make("table", this.tableAttrs);
        this.$el.append(tel);
        jQuery(tel).append("<h2>Building table</h2>\n<div class=\"progress progress-striped active progress-info\">\n    <div class=\"bar\" style=\"width: 100%\"></div>\n</div>");
        return this.query.service.fetchVersion(this.doRender(tel)).fail(this.onSetupError(tel));
      };

      Table.prototype.doRender = function(tel) {
        var _this = this;

        return function(version) {
          var path, setupParams;

          _this.fetchMethod = version >= 10 ? 'tableRows' : 'table';
          path = "query/results";
          setupParams = {
            format: "jsontable",
            query: _this.query.toXML(),
            token: _this.query.service.token
          };
          _this.$el.appendTo(_this.$parent);
          _this.query.service.post(path, setupParams).then(_this.onSetupSuccess(tel), _this.onSetupError(tel));
          return _this;
        };
      };

      Table.prototype.horizontalScroller = "<div class=\"scroll-bar-wrap well\">\n    <div class=\"scroll-bar-containment\">\n        <div class=\"scroll-bar alert-info alert\"></div>\n    </div>\n</div>";

      Table.prototype.placePagination = function($widgets) {
        var $pagination, currentPageButton,
          _this = this;

        $pagination = $(intermine.snippets.table.Pagination).appendTo($widgets);
        $pagination.find('li').tooltip({
          placement: "top"
        });
        return currentPageButton = $pagination.find(".im-current-page a").click(function() {
          var total;

          total = _this.cache.lastResult.iTotalRecords;
          if (_this.table.pageSize >= total) {
            return false;
          }
          currentPageButton.hide();
          return $pagination.find('form').show();
        });
      };

      Table.prototype.placePageSizer = function($widgets) {
        var pageSizer;

        pageSizer = new PageSizer(this.query, this.pageSize);
        return pageSizer.render().$el.appendTo($widgets);
      };

      Table.prototype.placeScrollBar = function($widgets) {
        var $scrollwrapper, currentPos, scrollbar,
          _this = this;

        if (this.bar === 'horizontal') {
          $scrollwrapper = $(this.horizontalScroller).appendTo($widgets);
          scrollbar = this.$('.scroll-bar');
          currentPos = 0;
          scrollbar.draggable({
            axis: "x",
            containment: "parent",
            stop: function(event, ui) {
              scrollbar.removeClass("scrolling");
              scrollbar.tooltip("hide");
              return _this.table.goTo(currentPos);
            },
            start: function() {
              return $(this).addClass("scrolling");
            },
            drag: function(event, ui) {
              var left, total;

              scrollbar.tooltip("show");
              left = ui.position.left;
              total = ui.helper.closest('.scroll-bar-wrap').width();
              return currentPos = _this.cache.lastResult.iTotalRecords * left / total;
            }
          });
          scrollbar.css({
            position: "absolute"
          }).parent().css({
            position: "relative"
          });
          return scrollbar.tooltip({
            trigger: "manual",
            title: function() {
              return "" + ((currentPos + 1).toFixed()) + " ... " + ((currentPos + _this.table.pageSize).toFixed());
            }
          });
        }
      };

      Table.prototype.placeTableSummary = function($widgets) {
        return $widgets.append("<span class=\"im-table-summary\"></div>");
      };

      Table.prototype.onSetupSuccess = function(telem) {
        var _this = this;

        return function(result) {
          var $telem, $widgets, component, method, _i, _len, _ref3;

          $telem = jQuery(telem).empty();
          $widgets = $('<div>').insertBefore(telem);
          _this.table = new ResultsTable(_this.query, _this.getRowData, _this.columnHeaders);
          _this.table.setElement(telem);
          if (_this.pageSize != null) {
            _this.table.pageSize = _this.pageSize;
          }
          if (_this.pageStart != null) {
            _this.table.pageStart = _this.pageStart;
          }
          _this.table.render();
          _this.query.on("imtable:change:page", _this.updatePageDisplay);
          _ref3 = intermine.options.TableWidgets;
          for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
            component = _ref3[_i];
            if (!(("place" + component) in _this)) {
              continue;
            }
            method = "place" + component;
            _this[method]($widgets);
          }
          return $widgets.append("<div style=\"clear:both\"></div>");
        };
      };

      Table.prototype.getCurrentPageSize = function() {
        var _ref3, _ref4;

        return (_ref3 = (_ref4 = this.table) != null ? _ref4.pageSize : void 0) != null ? _ref3 : this.pageSize;
      };

      Table.prototype.getCurrentPage = function() {
        if (this.table.pageSize) {
          return Math.floor(this.table.pageStart / this.table.pageSize);
        } else {
          return 0;
        }
      };

      Table.prototype.getMaxPage = function() {
        var correction, pageSize, total;

        total = this.cache.lastResult.iTotalRecords;
        pageSize = this.table.pageSize;
        correction = total % pageSize === 0 ? -1 : 0;
        return Math.floor(total / pageSize) + correction;
      };

      Table.prototype.goBack = function(pages) {
        return this.table.goTo(Math.max(0, this.table.pageStart - (pages * this.table.pageSize)));
      };

      Table.prototype.goForward = function(pages) {
        return this.table.goTo(Math.min(this.getMaxPage() * this.table.pageSize, this.table.pageStart + (pages * this.table.pageSize)));
      };

      Table.prototype.pageButtonClick = function(e) {
        var $elem;

        $elem = $(e.target);
        if (!$elem.parent().is('.active')) {
          switch ($elem.data("goto")) {
            case "start":
              return this.table.goTo(0);
            case "prev":
              return this.goBack(1);
            case "fast-rewind":
              return this.goBack(5);
            case "next":
              return this.goForward(1);
            case "fast-forward":
              return this.goForward(5);
            case "end":
              return this.table.goTo(this.getMaxPage() * this.table.pageSize);
          }
        }
      };

      Table.prototype.updatePageDisplay = function(start, size) {
        var buttons, centre, cg, handle, maxPage, overhang, p, pageForm, pageSelector, proportion, scaled, scrollbar, tbl, total, totalWidth, unit, _i, _ref3, _results;

        total = this.cache.lastResult.iTotalRecords;
        if (size === 0) {
          size = total;
        }
        scrollbar = this.$('.scroll-bar-wrap');
        if (scrollbar.length) {
          totalWidth = scrollbar.width();
          proportion = size / total;
          scrollbar.toggle(size < total);
          unit = totalWidth / total;
          scaled = Math.max(totalWidth * proportion, 20);
          overhang = size - ((total - (size * Math.floor(total / size))) % size);
          scrollbar.find('.scroll-bar-containment').css({
            width: totalWidth + (unit * overhang)
          });
          handle = scrollbar.find('.scroll-bar').css({
            width: scaled
          });
          handle.animate({
            left: unit * start
          });
        }
        tbl = this.table;
        buttons = this.$('.im-pagination-button');
        buttons.each(function() {
          var $elem, isActive, li;

          $elem = $(this);
          li = $elem.parent();
          isActive = (function() {
            switch ($elem.data("goto")) {
              case "start":
              case 'prev':
                return start === 0;
              case 'fast-rewind':
                return start === 0;
              case "next":
              case 'end':
                return start + size >= total;
              case "fast-forward":
                return start + (5 * size) >= total;
            }
          })();
          return li.toggleClass('active', isActive);
        });
        centre = this.$('.im-current-page');
        centre.find('a').text("p. " + (this.getCurrentPage() + 1));
        centre.toggleClass("active", size >= total);
        pageForm = centre.find('form');
        cg = pageForm.find('.control-group').empty().removeClass('error');
        maxPage = this.getMaxPage();
        if (maxPage <= 100) {
          pageSelector = $('<select>').appendTo(cg);
          pageSelector.val(this.getCurrentPage());
          pageSelector.change(function(e) {
            e.stopPropagation();
            e.preventDefault();
            tbl.goToPage(parseInt(pageSelector.val()));
            centre.find('a').show();
            return pageForm.hide();
          });
          _results = [];
          for (p = _i = 1, _ref3 = maxPage + 1; 1 <= _ref3 ? _i <= _ref3 : _i >= _ref3; p = 1 <= _ref3 ? ++_i : --_i) {
            _results.push(pageSelector.append("<option value=\"" + (p - 1) + "\">p. " + p + "</option>"));
          }
          return _results;
        } else {
          cg.append("<input type=text placeholder=\"go to page...\">");
          return cg.append("<button class=\"btn\" type=\"submit\">go</button>");
        }
      };

      Table.prototype.pageFormSubmit = function(e) {
        var centre, destination, inp, newSelectorVal, pageForm;

        e.stopPropagation();
        e.preventDefault();
        pageForm = this.$('.im-page-form');
        centre = this.$('.im-current-page');
        inp = pageForm.find('input');
        if (inp.size()) {
          destination = inp.val().replace(/\s*/g, "");
        }
        if (destination.match(/^\d+$/)) {
          newSelectorVal = Math.min(this.getMaxPage(), Math.max(parseInt(destination) - 1, 0));
          this.table.goToPage(newSelectorVal);
          centre.find('a').show();
          return pageForm.hide();
        } else {
          pageForm.find('.control-group').addClass('error');
          inp.val('');
          return inp.attr({
            placeholder: "1 .. " + (this.getMaxPage() + 1)
          });
        }
      };

      errorIntro = "Could not load the data-table.";

      genericExplanation = "The server may be down, or \nincorrectly configured, or \nwe could be pointed at an invalid URL.";

      badJson = "What we do know is that the server did not return a valid JSON response.";

      Table.prototype.onSetupError = function(telem) {
        var _this = this;

        return function(resp) {
          var content, e, issue, notice, reasonStr, reasons, text;

          $(telem).empty();
          console.error("SETUP FAILURE", arguments);
          notice = _this.make("div", {
            "class": "alert alert-error"
          });
          reasonStr = (function() {
            if (text = resp != null ? resp.responseText : void 0) {
              try {
                return (typeof JSON !== "undefined" && JSON !== null ? JSON.parse(text).error : void 0) || genericExplanation;
              } catch (_error) {
                e = _error;
                console.error(text);
                return genericExplanation + "\n" + badJson;
              }
            } else if (resp != null) {
              return String(resp);
            } else {
              return genericExplanation;
            }
          })();
          reasons = reasonStr.split("\n");
          content = [_this.make("span", {}, errorIntro)];
          if (reasons.length) {
            content.push(_this.make("ul", {}, (function() {
              var _i, _len, _results;

              _results = [];
              for (_i = 0, _len = reasons.length; _i < _len; _i++) {
                issue = reasons[_i];
                _results.push(this.make("li", {}, issue));
              }
              return _results;
            }).call(_this)));
          }
          return $(notice).append(_this.make("a", {
            "class": "close",
            "data-dismiss": "alert"
          }, "close")).append(_this.make("strong", {}, "Ooops...! ")).append(content).appendTo(telem);
        };
      };

      return Table;

    })(Backbone.View);
    return scope("intermine.query.results", {
      Table: Table
    });
  })();

  (function() {
    var PANE_HTML, Step, TAB_HTML, ToolBar, Tools, Trail, curry, _ref, _ref1, _ref2, _ref3;

    curry = intermine.funcutils.curry;
    TAB_HTML = _.template("<li>\n    <a href=\"#<%= ref %>\" data-toggle=\"tab\">\n        <%= title %>\n    </a>\n</li>");
    PANE_HTML = _.template("<div class=\"tab-pane\" id=\"<%= ref %>\"></div>");
    Tools = (function(_super) {
      __extends(Tools, _super);

      function Tools() {
        _ref = Tools.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      Tools.prototype.className = "im-query-tools";

      Tools.prototype.initialize = function(states) {
        this.states = states;
      };

      Tools.prototype.render = function() {
        var $pane, actions, c, columns, conf, content, filters, tabs, view, _i, _j, _len, _len1;

        tabs = this.make("ul", {
          "class": "nav nav-tabs"
        });
        conf = [
          filters = {
            title: "Filters",
            ref: "filters",
            view: intermine.query.filters.Filters
          }, columns = {
            title: "Columns",
            ref: "columns",
            view: intermine.query.columns.Columns
          }, actions = {
            title: "Actions",
            ref: "actions",
            view: intermine.query.actions.Actions
          }
        ];
        for (_i = 0, _len = conf.length; _i < _len; _i++) {
          c = conf[_i];
          $(tabs).append(TAB_HTML(c));
        }
        this.$el.append(tabs);
        content = this.make("div", {
          "class": "tab-content"
        });
        for (_j = 0, _len1 = conf.length; _j < _len1; _j++) {
          c = conf[_j];
          $pane = $(PANE_HTML(c)).appendTo(content);
          view = new c.view(this.query);
          $pane.append(view.render().el);
        }
        $(content).find('.tab-pane').first().addClass("active");
        $(tabs).find("a").first().tab('show');
        this.$el.append(content);
        return this;
      };

      return Tools;

    })(Backbone.View);
    ToolBar = (function(_super) {
      __extends(ToolBar, _super);

      function ToolBar() {
        _ref1 = ToolBar.__super__.constructor.apply(this, arguments);
        return _ref1;
      }

      ToolBar.prototype.className = "im-query-actionbar";

      ToolBar.prototype.initialize = function(states) {
        this.states = states;
      };

      ToolBar.prototype.render = function() {
        var actions, e;

        actions = new intermine.query.actions.ActionBar(this.states);
        try {
          actions.render().$el.appendTo(this.el);
        } catch (_error) {
          e = _error;
          console.error("Failed to set up toolbar because: " + e.message, e.stack);
        }
        return this;
      };

      return ToolBar;

    })(Backbone.View);
    Step = (function(_super) {
      var cell, nts, toInfoLabel, toLabel, toPathLabel, toValLabel;

      __extends(Step, _super);

      function Step() {
        _ref2 = Step.__super__.constructor.apply(this, arguments);
        return _ref2;
      }

      Step.prototype.className = 'im-step';

      Step.prototype.tagName = 'li';

      nts = function(n) {
        return intermine.utils.numToString(n, ',', 3);
      };

      Step.prototype.initialize = function(opts) {
        var _this = this;

        Step.__super__.initialize.call(this, opts);
        this.model.on('change:count', function(m, count) {
          return _this.$('.im-step-count .count').text(nts(count));
        });
        this.model.on('change:current', this.renderCurrency, this);
        return this.model.on('remove', function() {
          return _this.remove();
        });
      };

      Step.prototype.events = {
        'click .icon-info-sign': 'showDetails',
        'click h4': 'toggleSection',
        'click .btn': 'revertToThisState'
      };

      Step.prototype.toggleSection = function(e) {
        e.stopPropagation();
        $(e.target).find('i').toggleClass("icon-chevron-right icon-chevron-down");
        return $(e.target).next().children().toggle();
      };

      Step.prototype.showDetails = function(e) {
        e.stopPropagation();
        return this.$('.im-step-details').toggle();
      };

      Step.prototype.revertToThisState = function(e) {
        this.model.trigger('revert', this.model);
        return this.$('.btn-small').tooltip('hide');
      };

      Step.prototype.renderCurrency = function() {
        var isCurrent;

        isCurrent = this.model.get('current');
        this.$('.btn').toggleClass('btn-inverse', !isCurrent).attr({
          disabled: isCurrent
        });
        this.$('.btn-main').text(isCurrent ? "Current State" : "Revert to this State");
        return this.$('.btn i').toggleClass('icon-white', !isCurrent);
      };

      Step.prototype.sectionTempl = _.template("<div>\n  <h4>\n    <i class=\"icon-chevron-right\"></i>\n    <%= n %> <%= things %>\n  </h4>\n  <table></table>\n</div>");

      cell = function(content) {
        return $('<td>').html(content);
      };

      toLabel = function(type) {
        return function(text) {
          return cell("<span class=\"label label-" + type + "\">" + text + "</span>");
        };
      };

      toPathLabel = toLabel('path');

      toInfoLabel = toLabel('info');

      toValLabel = toLabel('value');

      Step.prototype.template = _.template("<button class=\"btn btn-small im-state-revert\" disabled\n    title=\"Revert to this state\">\n    <i class=\"" + intermine.icons.Undo + "\"></i>\n</button>\n<h3><%- title %></h3>\n<i class=\"icon-info-sign\"></i>\n</div>\n<span class=\"im-step-count\">\n    <span class=\"count\"><%- count %></span> rows\n</span>\n<div class=\"im-step-details\">\n<div style=\"clear:both\"></div>");

      Step.prototype.addSection = function(xs, things, toPath, f) {
        var k, n, q, table, v, _results;

        n = _.size(xs);
        if (n < 1) {
          return;
        }
        q = this.model.get('query');
        table = $(this.sectionTempl({
          n: n,
          things: things
        })).appendTo(this.$('.im-step-details')).find('table');
        _results = [];
        for (k in xs) {
          if (!__hasProp.call(xs, k)) continue;
          v = xs[k];
          _results.push((function(k, v) {
            var row;

            row = $('<tr>');
            table.append(row);
            return q.getPathInfo(toPath(k, v)).getDisplayName(function(name) {
              return f(row, name, k, v);
            });
          })(k, v));
        }
        return _results;
      };

      Step.prototype.getData = function() {
        var data;

        data = {
          count: this.model.has('count') ? nts(this.model.get('count')) : ''
        };
        return _.defaults(data, this.model.toJSON());
      };

      Step.prototype.render = function() {
        var ps, q, v;

        this.$el.attr({
          step: this.model.get('stepNo')
        });
        this.$el.append(this.template(this.getData()));
        this.renderCurrency();
        q = this.model.get('query');
        this.$('.btn-small').tooltip({
          placement: 'right'
        });
        ps = (function() {
          var _i, _len, _ref3, _results;

          _ref3 = q.views;
          _results = [];
          for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
            v = _ref3[_i];
            _results.push(q.getPathInfo(v));
          }
          return _results;
        })();
        this.addSection(ps, 'Columns', (function(i, x) {
          return x;
        }), function(row, name) {
          return row.append(toPathLabel(name));
        });
        this.addSection(q.constraints, 'Filters', (function(i, c) {
          return c.path;
        }), function(row, name, i, c) {
          row.append(toPathLabel(name));
          if (c.type != null) {
            row.append(toInfoLabel('isa'));
            row.append(toValLabel(c.type));
          }
          if (c.op != null) {
            row.append(toInfoLabel(c.op));
          }
          if (c.value != null) {
            return row.append(toValLabel(c.value));
          } else if (c.values != null) {
            return row.append(toValLabel(c.values.join(', ')));
          }
        });
        this.addSection(q.joins, 'Joins', (function(p, style) {
          return p;
        }), function(row, name, p, style) {
          row.append(toPathLabel(name));
          return row.append(toInfoLabel(style));
        });
        this.addSection(q.sortOrder, 'Sort Order Elements', (function(i, so) {
          return so.path;
        }), function(row, name, i, _arg) {
          var direction;

          direction = _arg.direction;
          row.append(toPathLabel(name));
          return row.append(toInfoLabel(direction));
        });
        return this;
      };

      return Step;

    })(Backbone.View);
    Trail = (function(_super) {
      __extends(Trail, _super);

      function Trail() {
        _ref3 = Trail.__super__.constructor.apply(this, arguments);
        return _ref3;
      }

      Trail.prototype.className = "im-query-trail";

      Trail.prototype.tagName = "div";

      Trail.prototype.initialize = function(states) {
        this.states = states;
        this.subViews = [];
        this.states.on('add', this.appendState, this);
        return this.states.on('reverted', this.render, this);
      };

      Trail.prototype.events = {
        'click a.details': 'minumaximise',
        'click a.shade': 'toggle',
        'click a.im-undo': 'undo'
      };

      Trail.prototype.toggle = function() {
        var _this = this;

        return this.$('.im-step').slideToggle('fast', function() {
          return _this.$el.toggleClass("toggled");
        });
      };

      Trail.prototype.minumaximise = function() {
        return this.$el.toggleClass("minimised");
      };

      Trail.prototype.undo = function() {
        return this.states.popState();
      };

      Trail.prototype.appendState = function(state) {
        var step;

        step = new Step({
          model: state
        });
        this.subViews.push(step);
        this.$('.im-state-list').append(step.render().el);
        return this.$el.addClass('im-has-history');
      };

      Trail.prototype.render = function() {
        var step,
          _this = this;

        while (step = this.subViews.pop()) {
          step.remove();
        }
        this.$el.html("<div class=\"btn-group\">\n  <a class=\"btn im-undo\">\n    <i class=\"" + intermine.icons.Undo + "\"></i>\n    <span class=\"visible-desktop\">Undo</span>\n  </a>\n  <a class=\"btn dropdown-toggle\" data-toggle=\"dropdown\">\n    <span class=\"caret\"></span>\n  </a>\n  <ul class=\"dropdown-menu im-state-list\">\n  </ul>\n</div>\n<div style=\"clear:both\"></div>");
        this.states.each(function(s) {
          return _this.appendState(s);
        });
        this.$el.toggleClass('im-has-history', this.states.size() > 1);
        return this;
      };

      return Trail;

    })(Backbone.View);
    return scope("intermine.query.tools", {
      Tools: Tools,
      ToolBar: ToolBar,
      Trail: Trail
    });
  })();

  (function() {
    var ViewElement, _ref;

    ViewElement = (function(_super) {
      var TEMPLATE, namePart, splitName;

      __extends(ViewElement, _super);

      function ViewElement() {
        _ref = ViewElement.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      TEMPLATE = _.template("<div>\n  <a class=\"im-col-remover\" title=\"Remove this column\">\n    <i class=\"" + intermine.icons.Remove + "\"></i>\n  </a>\n  <i class=\"icon-reorder pull-right\"></i>\n  <% if (replaces.length) { %>\n    <i class=\"" + intermine.icons.Collapsed + " im-expander pull-right\"></i>\n  <% } %>\n  <span class=\"im-display-name\"><%- path %></span>\n  <ul class=\"im-sub-views\"></ul>\n</div>");

      ViewElement.prototype.placement = 'top';

      ViewElement.prototype.tagName = 'li';

      ViewElement.prototype.className = 'im-view-element im-reorderable';

      ViewElement.prototype.events = {
        'click .im-col-remover': 'remove',
        'click': 'toggleSubViews'
      };

      ViewElement.prototype.toggleSubViews = function() {
        this.$('.im-sub-views').slideToggle();
        return this.$('.im-expander').toggleClass(intermine.icons.ExpandCollapse);
      };

      ViewElement.prototype.remove = function() {
        this.model.destroy();
        this.$('.im-col-remover').tooltip('hide');
        return ViewElement.__super__.remove.apply(this, arguments);
      };

      namePart = _.template("<span class=\"im-name-part\"><%- part %></span>");

      splitName = function($elem) {
        return function(name) {
          var part, parts, _i, _len, _results;

          parts = name.split(' > ');
          _results = [];
          for (_i = 0, _len = parts.length; _i < _len; _i++) {
            part = parts[_i];
            _results.push($elem.append(namePart({
              part: part
            })));
          }
          return _results;
        };
      };

      ViewElement.prototype.render = function() {
        var $name, path, replaced, ul, _i, _len, _ref1;

        path = this.model.get('path');
        this.model.el = this.el;
        this.$el.append(TEMPLATE(this.model.toJSON()));
        this.$('.im-col-remover').tooltip({
          placement: this.placement,
          container: this.el
        });
        $name = this.$('.im-display-name').empty();
        path.getDisplayName(splitName($name));
        ul = this.$('.im-sub-views');
        _ref1 = this.model.get('replaces');
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          replaced = _ref1[_i];
          if (replaced.isAttribute()) {
            (function(ul) {
              var li, span;

              li = $('<li></li>');
              ul.append(li);
              span = document.createElement('span');
              li.append(span);
              span.className = 'im-display-name';
              return replaced.getDisplayName(splitName($(span)));
            })(ul);
          }
        }
        if (!ul.children().length) {
          ul.remove();
        }
        return this;
      };

      return ViewElement;

    })(Backbone.View);
    return scope('intermine.columns.views', {
      ViewElement: ViewElement
    });
  })();

  end_of_definitions();

}).call(this);


  }).call(context);

}).call(window);
