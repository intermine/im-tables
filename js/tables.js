if (!window.console) {
    window.console = {
        log: function() {}
    };
}

    
//----------------
// Calculates a point Z(x), 
// the Probability Density Function, on any normal curve. 
// This is the height of the point ON the normal curve.
// For values on the Standard Normal Curve, call with Mean = 0, StdDev = 1.
function getNormalCurve(Mean, StdDev) { return function(x) {
    var a = x - Mean;
    return Math.exp(-(a * a) 
           / (2 * StdDev * StdDev)) 
           / (Math.sqrt(2 * Math.PI) * StdDev); 
}}

(function( ) {

    // Inline form fix: http://datatables.net/blog/Twitter_Bootstrap_2
    $(function() {
        $.extend( $.fn.dataTableExt.oStdClasses, {
            "sWrapper": "dataTables_wrapper form-inline" 
        });
    });

    var CELL_HTML = _.template(
        '<input class="list-chooser" type="checkbox" style="display: none" data-obj-id="<%= id %>" '
        + 'data-obj-type="<%= type %>">'
        + '<% if (value == null) { %>'
        + ' <span class="null-value">no value</span>'
        + '<% } else { %>'
        + ' <a href="<%= base %><%= url %>"><%= value %></a>'
        + '<% } %>');

    var CellValue = function(cell, base) {

        this.cell = _.extend({id: "", type: cell["class"], base: base}, cell);

        this.toString = function() {
            return CELL_HTML(this.cell);
        };
    };

    var utils = {
        /**
        * Very naïve English word pluralisation algorithm
        *
        * @param {String} word The word to pluralise.
        * @param {Number} count The number of items this word represents.
        */
        pluralise: function(word, count) {
            return (count == 1) 
                ? word 
                : ((word.match(/(s|x|ch)$/)) 
                        ? word + "es" 
                        : (word.match(/[^aeiou]y$/) 
                            ? word.replace(/y$/, 'ies')
                            : word + "s"));
        },

        /*
         * Stringification of numbers.
         */
        num_to_string: function(num, sep, every) {
            var num_as_string = num + "";
            var chars = num_as_string.split("");
            var ret = "";
            for (var i = chars.length - 1, c = 1; i >= 0; i--, c++) {
                var ch = chars[i];
                ret = ch + ret;
                if (c && i && (c % every == 0)) {
                    ret = sep + ret;
                }
            }
            return ret;
        },

        /**
        * Function to work around the decision to use the list of pairs format...
        */
        getParameter: function(params, name) {
            return __(params).select(function(p) {return p.name == name}).pluck('value').first().value();
        }
    };

    var TABLE_INIT_PARAMS = {
        sDom: "<'row-fluid'<'span2 im-table-summary'><'span3'l><'span6 pull-right'p>t<'row-fluid'<'span6'i>>",
        sPaginationType: "bootstrap",
        oLanguage: {
            sLengthMenu: "_MENU_ rows per page",
            sProcessing: '<div class="progress progress-info progress-striped active"><div class="bar" style="width: 100%"></div></div>'
        },
        aLengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
        iDisplayLength: 10,
        bProcessing: false,
        bServerSide: true,
    };

    var NUMERIC_TYPES = ["int", "Integer", "double", "Double", "float", "Float"];
    var COUNT_HTML = _.template('<span><%= count %></span> <%= roots %>');

    var ResultTable = Backbone.View.extend({

        className: "im-table-container",

        initialize: function(query, selector) {
            _.bindAll(this, "render", "getRowData", "serveResultsFromCache");
            var self = this;
            this.cache = {};
            this._pipe_factor = 10; // Request x times the page size.
            this.query = query;
            console.log(selector);
            this.$parent = $(selector);
            console.log(this.$parent);

            this.visibleViews = self.query.views.slice();

            this.query.on("add:from-node", function(path) {
                self.visibleViews.push(path);
                self.table.fnDestroy();
                self.render();
            });

            this.query.on("change:view", function() {
                self.visibleViews = self.query.views.slice();
                self.table.fnDestroy();
                self.render();
            });

            this.query.on("change:constraints", function() {
                self.table.fnDestroy();
                self.render();
            });

            this.query.on("change:joins", function() {
                self.table.fnDestroy();
                self.render();
            });

            this.query.on("remove:from-node", function(path) {
                console.log("node removed");
                self.visibleViews = _(self.visibleViews).filter(function(v) {
                    return v.substring(0, v.lastIndexOf(".")) !== path;
                });
                self.table.fnDestroy();
                self.render();
            });
        },

        /**
         * Set the sort order of a query so that it matches the parameters 
         * passed from DataTables.
         *
         * @param params An array of {name: x, value: y} objects passed from DT.
         *
         */
        adjustSortOrder: function(params) {
            // Adjust the query's sort-order.
            var self = this;
            var viewIndices = [];
            for (var i = 0, l = utils.getParameter(params, "iColumns"); i < l; i++) {
                viewIndices[i] = utils.getParameter(params, "mDataProp_" + i);
            }

            var noOfSortCols = utils.getParameter(params, "iSortingCols");

            if (noOfSortCols) {
                var sort_cols = __(0).range(noOfSortCols).map(function(i) {
                    var so = {}; 
                    var displayed = utils.getParameter(params, "iSortCol_" + i);
                    var path = self.query.views[viewIndices[displayed]];
                    var direction = utils.getParameter(params, "sSortDir_" + i);
                    so[path] = direction;
                    return so;
                }).value();
                this.query.orderBy(sort_cols);
            }
        },

        /**
         * Function for buffering data for a request. Each request fetches a page of
         * pipe_factor * size, and if subsequent requests request data within this range, then
         *
         * This function is used as a callback to the datatables server data method.
         *
         * @param src URL passed from DataTables. Ignored.
         * @param param list of {name: x, value: y} objects passed from DataTables
         * @param callback fn of signature: resultSet -> ().
         *
         */
        getRowData: function(src, params, callback) {
            // ignore the url. 
            var self = this;
            var echo = utils.getParameter(params, "sEcho");
            var start = utils.getParameter(params, "iDisplayStart");
            var size = utils.getParameter(params, "iDisplayLength");
            var end  = start + size;
            var isOutOfRange = false;
            var isStale = false;

            this.adjustSortOrder(params);

            // We need new data if the query is different, by different:
            //  * the constraints have changed, or
            //  * the sort order has changed, or 
            //  * the filter has changed, or 
            //  * the underlying view has changed.
            var freshness = this.query.getSorting() + this.query.getConstraintXML() + this.query.views.join();
            isStale = (freshness !== this.cache.freshness);

            if (isStale) {
                // Invalidate the cache.
                this.cache = {};
            } else {
                // We need new data if the range of this request goes beyond that of the 
                // cached values, or if all results are selected.
                isOutOfRange = (
                        this.cache.lowerBound < 0        // ie. no requests yet.
                        || start < this.cache.lowerBound // want results before what we have.
                        || end > this.cache.upperBound   // want results beyond what we have.
                        || size < 0                      // All results - can't be sure we have them all.
                    );
            }
            
            if (isStale || isOutOfRange) { // fetch fresh data.
                console.log("Requesting fresh data");
                var page = this.getPage(start, size);
                this.query.table(page, function(rows, resultSet) {
                    self.addRowsToCache(page, resultSet);
                    // Update cache values 
                    self.cache.freshness = freshness;
                    self.serveResultsFromCache(echo, start, size, callback);
                }).fail(this.showError);
            } else { // return a slice of the cache data
                this.serveResultsFromCache(echo, start, size, callback);
            }
        },

        /**
         * Get the page to request given the desired start and size.
         *
         * @param start the index of the first result the user actually wants to see.
         * @param size The size of the dislay window.
         *
         * @return A page object with "start" and "size" properties set to include the desired
         *         results, but also taking the cache into account.
         */
        getPage: function(start, size) {
            var page = {start: start, size: size};
            var cache = this.cache;
            if (!cache.lastResult) {
                // Don't have to consider the cache, just inflate the pipe.
                page.size *= this._pipe_factor;
                return page;
            }

            if (start < cache.lowerBound) {
                // Paging backwards - extend page size towards 0
                page.start = Math.max(start - (size * (this._pipe_factor)), 0);
            } 
            if (size > 0) {
                page.size *= this._pipe_factor;
            } else {
                page.size = 0; // ALL
            }
            // Don't permit gaps, if the query itself is ok
            // If the result page doesn't even reach up to the cache's lower-bound
            if (page.size && ((page.start + page.size) < cache.lowerBound)) { 
                page.size = cache.lowerBound - page.start;
            }
            // If the result page starts beyond the upper bound of the cache.
            if (cache.upperBound < page.start) {
                if (page.size != 0) {
                    page.size += page.start - cache.upperBound;
                }
                page.start = cache.upperBound;
            }
            return page;
        },

        /**
         * Update the cache with the retrieved results. If there is an overlap 
         * between the returned results and what is already held in cache, prefer the newer 
         * results.
         *
         * @param page The page these results were requested with.
         * @param result The resultset returned from the server.
         *
         */
        addRowsToCache: function(page, result) {
            var cache = this.cache;
            if (!cache.lastResult) {
                cache.lastResult = result;
                cache.lowerBound = page.start;
                cache.upperBound = page.start + page.size;
            } else {
                var rows = result.results;
                var merged = cache.lastResult.results.slice();
                // Add rows we don't have to the front
                if (page.start < cache.lowerBound) {
                    merged = Array.prototype.concat.call(rows, 
                        merged.slice((page.start + page.size) - cache.lowerBound));
                }
                cache.lowerBound = Math.min(page.start, cache.lowerBound);

                // Add rows we don't have to the end.
                if ((page.start + page.size) > cache.upperBound) {
                    merged = Array.prototype.concat.call(
                        merged.slice(0, (page.start - cache.lowerBound)), rows);
                }
                cache.upperBound = Math.max((page.start + page.size), cache.upperBound);

                cache.lastResult.results = merged;
            }
        },

        /**
         * Retrieve the results from the results cache.
         *
         * @param echo The results table request control.
         * @param start The index of the first result desired.
         * @param size The page size
         */
        serveResultsFromCache: function(echo, start, size, cb) {
            var cache = this.cache;
            var result = jQuery.extend(true, {}, cache.lastResult);
            result.sEcho = echo;
            // Splice off the undesired sections.
            result.results.splice(0, start - cache.lowerBound);
            result.results.splice(size, result.results.length);
            // Rename the property.
            var base = this.query.service.root.replace(/\/service\/?$/, "");
            this.$('.im-table-summary').html(COUNT_HTML({count: result.iTotalRecords, roots: utils.pluralise(this.query.root)}));
            result.aaData = _(result.results).map(function(xs) { 
                return _(xs).map(function(x) {return new CellValue(x, base)});
            });
            cb(result);
        },

        addMissingQueryAttributes: function() {
            var self = this;
            var currentView = self.query.views;
            return self.query.service.fetchModel(function(m) {
                /* better to do this all on the query?
                 * This could also be done in the getRows fn.
                self.query.addToSelect(__(currentView)
                  .map(function(p) { return p.substring(0, p.lastIndexOf("."))})
                  .uniq()
                  .map(function(p) {
                      return __(m.getCdForPath(p).attributes)
                              .keys().without("id")
                              .map(function(a) {return p + "." + a})
                              .value()
                  })
                  .flatten()
                  .filter(function(p) {return !_(currentView).include(p)})
                  .value());
                */
            });
        },

        render: function() {
            var self = this;
            var attributes = {
                "class": "table table-striped table-bordered",
                width: "100%",
                cellpadding: 0,
                border: 0,
                cellspacing: 0
            };
            self.$el.empty();
            var tElem = self.make("table", attributes);
            self.$el.append(tElem);
            var url = self.query.service.root + "query/results";
            return self.addMissingQueryAttributes().then(function() {
                var setupParams = {
                    format: "jsontable", // No results - just table set-up info.
                    query: self.query.toXML(),
                    token: self.query.service.token,
                };
                self.$el.appendTo(self.$parent);
                $.ajax( {
                    dataType: "json", 
                    type: "POST",
                    url: url,
                    data: setupParams,
                    success: function(result) {
                        var dtOptions = $.extend(true, {}, TABLE_INIT_PARAMS, {
                            fnServerData: self.getRowData,
                            aoColumns: _(self.query.views).map(function(v, i) {
                                return {
                                    bVisible: _(self.visibleViews).include(v),
                                    sTitle: result.columnHeaders[i].split(" > ").slice(1).join(" > ")
                                            + '<i class="summary-img summary_col-' + i + '"'
                                            + ' title="get column summary">\u03A3</i>',
                                    sName: v,
                                    sType: ($.inArray(result.viewTypes[i], NUMERIC_TYPES) >= 0) ? "numeric" : "string",
                                    mDataProp: i
                                };
                            }),
                        });
                        self.table = $(tElem).dataTable(dtOptions);
                    },
                    error: function() {
                        console.log("Error loading table... from " + url, arguments);
                        var notice = self.make("div", {"class": "alert alert-error"});
                        var m = self.make;
                        var explanation = "Could not load the data-table."
                            + " This server probably doesn't have the correct"
                            + " CORS headers set up";
                        if (arguments[0].responseText) {
                            explanation = JSON.parse(arguments[0].responseText).error;
                            var parts = __(explanation.split("\n"))
                                .filter(function(part) {return !!part})
                                .groupBy(function(part, i) {return i == 0 ? "heading" : "li"})
                                .value();
                            explanation = [
                                m("span", {}, parts.heading + ""),
                                m("ul", {}, _(parts.li).map(function(li) {return m("li",{},li)}))
                            ];
                        }

                        $(notice).append(m("a", {"class": "close", "data-dismiss": "alert"}, 'x'))
                                 .append(m("strong", {}, "Ooops..."))
                                 .append(explanation)
                                 .appendTo(tElem);

                    }
                });
            });
        },
        
    });

    var QueryColumns = Backbone.View.extend({
        className: "im-query-columns",

        initialize: function(query) {
            this.query = query;
        },

        render: function() {
            var self = this;
            var nodeAdder = new NodeAdder(self.query);
            self.$el.append(nodeAdder.render().el);
            
            var currentNodes = new CurrentNodes(self.query);
            currentNodes.render().$el.appendTo(self.el);
            return this;
        }

    });

    var QueryFilters = Backbone.View.extend({
        className: "im-query-filters",

        initialize: function(query) {
            this.query = query;
        },

        render: function() {
            var self = this;
            var constraints = new CurrentConstraints(self.query);
            constraints.render().$el.appendTo(this.el);

            var facets = new QueryFacets(self.query);
            facets.render().$el.appendTo(this.el);
            return this;
        }
        
    });

    var FACETS = {
        Gene: [
            {title: "Pathways", path: "pathways.name"},
            {title: "Expression Term", path: "mRNAExpressionResults.mRNAExpressionTerms.name"},
            {title: "Ontology Term", path: "ontologyAnnotations.ontologyTerm.name"},
            {title: "Protein Domains", path: "proteins.proteinDomains.name"}
            
        ]
    };

    var QueryFacets = Backbone.View.extend({

        className: "im-query-facets",
        tagName: "dl",

        initialize: function(query) {
            this.query = query;

            _.bindAll(this, "render");

            this.query.on("change:constraints", this.render);
            this.query.on("change:joins", this.render);
        },

        render: function() {
            var self = this;
            self.$el.empty();
            var facets = (FACETS[this.query.root] || []).concat(
                _(self.query.views).map(function(v) {
                    return {
                        title: v.replace(/^[^\.]+\./, "").replace(/\./g, " > "),
                        path: v
                    };
                }));
            if (facets) {
                var searcher = self.make("input", {
                    "class": "input-long", 
                    "placeholder": "Filter facets...",
                });
                self.$el.append(searcher);
                $(searcher).keyup(function() {
                    var term;
                    if (term = $(this).val()) {
                        var pattern = new RegExp(term, "i");
                        self.$("dd").each(function() {
                            var text = $(this).text();
                            if (pattern.test(text)) {
                                $(this).show();
                            } else {
                                $(this).hide();
                            }
                        });
                    } else {
                        self.$('dd').show();
                    }
                });

                __(facets).filter(function(facet) {
                    return !_(self.query.constraints).any(function(c) {
                        return c.path === self.query.root + "." + facet.path;
                    });
                }).each(function(facet) {
                    var cs = new intermine.results.ColumnSummary(facet, self.query);
                    self.$el.append(cs.el);
                    cs.render();
                });
            }
            return this;
        }
    });

    var CONSTRAINT_ADDER_HTML = 
          '<input type="text" placeholder="Add a new filter" class="im-constraint-adder span9">'
          + '<button class="disabled btn span2" type="submit">Filter</button>';

    var ConstraintAdder = Backbone.View.extend({
        tagName: "form",
        className: "im-constraint-adder row-fluid im-constraint",

        initialize: function(query) {
            var self = this;
            this.query = query;
            this.$el.submit(function(e) {
                e.preventDefault();
                e.stopPropagation();
                self.$('input').hide();
                self.$('button[type="submit"]').hide();
                var con = {path: self.$('input').val(), value: "Enter a value..."};
                var ops;
                var type;
                if (type = query.service.model.getCdForPath(con.path)) {
                    ops = intermine.Query.REFERENCE_OPS;
                    con.op = "LOOKUP";
                } else {
                    ops = intermine.Query.ATTRIBUTE_OPS;
                    con.op = "=";
                }
                // TODO: make subclass of activeconstraint
                var ac = new intermine.query.ActiveConstraint(query, con, ops);
                self.$el.append(ac.render().el);
                self.$('form').show();
                self.$('form label').text(con.path).find('i').hide();
                self.$('form').append(self.make('a', {"class": 'btn btn-primary'}, 'Add filter'))
                              .append(self.make('a', {"class": 'btn btn-cancel'}, 'Cancel'));
                self.$('.btn-cancel').click(function() {
                    self.$('form').remove();
                    self.$('input').show();
                    self.$('button[type="submit"]').show();
                });
                self.$('.btn-primary').click(function() {
                    con.op = self.$('.im-ops').val();
                    con.value = self.$('.im-constraint-value').val();
                    self.query.addConstraint(con);
                    self.query.trigger("change:constraints");
                });
                    
            });

        },

        render: function() {
            var self = this;

            self.$el.append(CONSTRAINT_ADDER_HTML);

            // TODO: refactor this from here and NodeAdder::render
            var root = self.query.root;
            var depth = 3;
            var paths = self.query.getPossiblePaths(depth);
            self.$('input').typeahead({
                source: paths,
                items: 10,
                sorter: PATH_LEN_SORTER
            }).keyup(function() {
                $(this).next().removeClass("disabled");
            }).focus(function() {
                $(this).val(root).keyup();
            }).blur(function() {
                var that = this;
                _(function() {
                    $(that).val("");
                    $(that).next().addClass("disabled");
                }).delay(3000);
            });
            return this;
        }
    });
    var CurrentConstraints = Backbone.View.extend({

        initialize: function(query) {
            this.query = query;
            _.bindAll(this, "render");

            this.query.on("change:constraints", this.render);
        },

        className: "alert alert-info im-constraints",

        render: function() {
            var self = this;
            self.$el.empty();
            self.$el.append(self.make("h3", {}, "Active Filters"));
            self.$el.append(self.make("p", {}, "edit or remove the currently active filters."));
            self.$el.append(self.make("ul"));
            
            _(self.query.constraints).each(function(con) {
                var con = new intermine.query.ActiveConstraint(self.query, con);
                con.render().$el.appendTo(self.$('ul'));
            });

            var conAdder = new ConstraintAdder(self.query);
            self.$el.append(conAdder.render().el);

            return this;
        }

    });

    var TAB_HTML = _.template(
        '<li><a href="#<%= ref %>" data-toggle="tab"><%= title %></a></li>');
    var PANE_HTML = _.template(
        '<div class="tab-pane" id="<%= ref %>"></div>');
    var QueryTools = Backbone.View.extend({

        className: "im-query-tools",

        initialize: function(query) {
            this.query = query;
        },

        render: function() {
            var self = this;
            var tabs = this.make("ul", {"class": "nav nav-tabs"});
            var conf = [
                {   
                    title: "Filters",
                    ref: "filters",
                    view: QueryFilters
                },
                {
                    title: "Columns",
                    ref: "columns",
                    view: QueryColumns
                },
            ];
            _(conf).each(function(c) {
                var tab = TAB_HTML(c);
                $(tab).appendTo(tabs);
            });
            self.$el.append(tabs);

            var content = this.make("div", {"class": "tab-content"});
            _(conf).each(function(c) {
                var $pane = $(PANE_HTML(c)).appendTo(content);
                var view = new c.view(self.query);
                view.render().$el.appendTo($pane);
            });
            self.$el.append(content);
            
            $(content).find('.tab-pane').first().addClass("active");

            $(tabs).find('a').first().tab('show');
            return this;
        }

    });

    var ATTR_HTML = _.template(
            '<input type="checkbox" data-path="<%= path %>" '
            + '<% inQuery ? print("checked") : "" %> >'
            + '<span class="im-view-option">'
            + '<%= name %> (<% print(type.replace("java.lang.", "")) %>)'
            + '</span>');

    var JOIN_TOGGLE_HTML = _.template(
          '<form class="form-inline pull-right im-join">'
        + '<div class="btn-group" data-toggle="buttons-radio">'
        + ' <button data-style="INNER" class="btn btn-small <% print(outer ? "" : "active") %>">'
        + '   Required'
        + ' </button>'
        + ' <button data-style="OUTER" class="btn btn-small <% print(outer ? "active" : "") %>">'
        + '   Optional'
        + ' </button>'
        + '</div></form>');

    var CurrentNodes = Backbone.View.extend({

        tagName: "dl",
        className: "node-remover",

        initialize: function(query) {
            this.query = query;
            _.bindAll(this, "render", "refresh");
            this.query.on("add:from-node", this.render);
            this.query.on("remove:from-node", this.render);
            this.query.on("change:joins", this.render);
        },

        refresh: function() {},

        render: function() {
            var self = this;
            self.$el.empty();
            var m = self.query.service.model;
            var foundPaths = [];
            var getAttrHandler = function(p) { return function(a) {
                if (a.name !== "id") {
                    var path = p + "." + a.name;
                    var dd = self.make("dd");
                    var ctx = _.extend({
                        path: path,
                        inQuery: _(self.query.views).include(path)
                    }, a);
                    $(dd).append(ATTR_HTML(ctx)).appendTo(self.el);
                }
            }};
            var getRefHandler = function(p) {return function(ref) {
                var path = ref ? p + "." + ref.name : p;
                var box = self.make("dt");
                var refCd = m.classes[(ref ? ref.referencedType : p)];
                var title = self.make("h4", {"class": "im-column-group"}, 
                        (ref ? ref.name : p));

                var isInView = _(self.query.views).any(function(v) { 
                    return path === v.substring(0, v.lastIndexOf(".")); 
                });

                $(box).append(title);
                var icon =  isInView ? "minus" : "plus";
                $('<i class="icon-' + icon + '-sign"></i>')
                    .css({cursor: "pointer"})
                    .appendTo(title);
                if (isInView && path !== self.query.root) {
                    $(JOIN_TOGGLE_HTML({outer: self.query.isOuterJoin(path)}))
                        .submit(function(e) {e.preventDefault()})
                        .css({"display": "inline-block"})
                        .appendTo(title)
                        .find(".btn")
                        .click(function(e) {
                            e.stopPropagation();
                            var style = $(this).data("style");
                            self.query.setJoinStyle(path, style);
                        })
                        .button();
                }
                self.$el.append(box);
                _(refCd.attributes).each(getAttrHandler(path));
            }};

            getRefHandler(self.query.root)();

            var rootCd = m.getCdForPath(self.query.root);
            var refHandler = getRefHandler(self.query.root);
            _(rootCd.references).each(refHandler);
            _(rootCd.collections).each(refHandler);

            this.$("dt").click(function() {
                $(this).nextUntil("dt").slideToggle();
            });

            this.$('input[type="checkbox"]').change(function() {
                var path = $(this).attr("data-path");
                if ($(this).attr("checked")) {
                    self.query.addToSelect(path);
                } else {
                    self.query.removeFromSelect(path);
                }
                self.query.trigger("change:view");
            });
                    
            return this;
        }

    });

    // TODO: Move this into query.js
    var getJoins = function(table) {
        var refs = _(table.references).values();
        var cols = _(table.collections).values();
        return _.union(refs, cols);
    };

    var PATH_LEN_SORTER = function(items) {
        return _(items).sortBy(function(x) {
            return x.split(".").length;
        });
    };

    var NodeAdder = Backbone.View.extend({

        tagName: "form",
        className: "form node-adder",

        initialize: function(query) {
            this.model = query.service.model;
            this.root = query.root;
            this.query = query;
            _.bindAll(this, "render");
        },

        render: function() {
            var self = this;
            var ti = self.make("input", {type: "text", "class": "span10"});
            self.$el.append(ti);
            var paths = this.query.getPossiblePaths(3);
            $(ti).typeahead({
                source: paths, 
                items: 10,
                sorter: PATH_LEN_SORTER
            }).focus(function() {
                $(this).val(self.root).keyup();
            }).blur(function() {
                $(this).val("");
            });
            
            self.$el.submit(function(e) {
                var newPath = $(ti).val();
                self.query.addToSelect(newPath);
                self.query.trigger("add:from-node", newPath);
                e.stopPropagation();
                e.preventDefault();
                return false;
            });
            return this;
        }

    });

    var QueryView = Backbone.View.extend({

        tagName: "div",
        className: "query-display row-fluid",

        initialize: function(service, query) {
            if (_(service).isString()) {
                this.service = new intermine.Service({root: service});
            } else if (!service.fetchModel) { // test if this is actually a Service obj.
                this.service = new intermine.Service(service);
            } else {
                this.service = service;
            }
            this.query = query;
            _.bindAll(this, "render");
        },

        render: function() {
            var self = this;
            self.service.query(self.query, function(q) {
                var main = self.make("div", {"class": "span9 im-query-results"});
                $(main).css({"min-height": "30em"});
                self.$el.append(main);
                self.table = new ResultTable(q, main);
                self.table.render();

                var tools = self.make("div", {"class": "span3 im-query-toolbox"});
                self.$el.append(tools);
                var toolBar = new QueryTools(q);
                toolBar.render().$el.appendTo(tools);
            });
            return this;
        }

    });

    window.intermine = window.intermine || {};
    window.intermine.results = window.intermine.results || {};
    _.extend(window.intermine.results, {
        Table: ResultTable,
        QueryView: QueryView
    });

}).call( this );

