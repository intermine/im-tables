$(function() {

    var getPageParam = function(name, defaultValue) {
        defaultValue = (defaultValue != null) ? defaultValue : "";
        name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
        var regexS = "[\\?&]" + name + "=([^&#]*)";
        var regex = new RegExp(regexS);
        var results = regex.exec(window.location.search);
        if (results == null) {
            return defaultValue;
        } else {
            return decodeURIComponent(results[1].replace(/\+/g, " "));
        }
    };

    var services = {
        Production: {
            root: "www.flymine.org/query", 
            token: "21k3D5x5B8pdd8T9yeY24fG8th2",
            q: {
                select: ["symbol", "organism.name", "chromosomeLocation.start"], 
                from: "Gene", 
                where: {
                //    Gene: {IN: "an awesome list"}, 
                    length: {lt: 5000}
                }
            }
        },
        Pubs: {
          root: "www.flymine.org/query",
          q: {
              select: [
                "publications.title",
                "publications.bioEntities.symbol",
                "publications.bioEntities.organism.name",
                "publications.bioEntities.chromosomeLocation.end", 
              ], 
              from: "Gene", 
              where: {
                  'publications.bioEntities': {isa: 'Gene'},
                  symbol: 'ATP*',
                  length: {lt: 8000},
                  "pathways.name": ["Metabolic pathways", "Gene Expression", "Transcription", "mRNA Processing"],
                  "publications.bioEntities.symbol": 'eve' 
              }
              , joins: ['publications.bioEntities']
              , aliases: {
                'Gene.publications.bioEntities': 'Genes'
              }
          }
        },
        Preview: {
          root: "beta.flymine.org/beta",
          token: "M1n3x2ydw4icj140pbBcffIgR4Q",
          q: {
              select: [
                "symbol",
                "organism.name",
                "chromosomeLocation.locatedOn.primaryIdentifier", 
                "chromosomeLocation.start", 
                "chromosomeLocation.end", 
                "proteins.name", 
                "exons.primaryIdentifier"
              ], 
              from: "Gene", 
              where: {
                  // Aesthetic - means we can render the type correctly.
                  'chromosomeLocation.locatedOn': {isa: 'Chromosome'}, 
                  length: {lt: 8000},
                  "pathways.name": ["Metabolic pathways", "Gene Expression", "Transcription", "mRNA Processing"],
                  "chromosome.primaryIdentifier": "2L"
              }
          }
        },
        TestModel: {
          help: 'alex@intermine.org',
          root: window.location.host + "/intermine-test",
          token: "test-user-token",
          q: {
              select: ["*", "age"],
              from: "Employee",
              joins: ['address'],
              where: [
                  ["age", "lt", 50 ],
                  ["age", "gt", 40 ]
              ]
          }
        },
        OJC: {
          help: 'alex@intermine.org',
          root: "localhost:8080/intermine-test",
          token: "test-user-token",
          q: {
              select: ['name', 'company.name', 'employees.name', 'employees.age', 'employees.end', 'employees.address.address' ],
              from: "Department",
              joins: ['employees'],
              where: [
                  ["employees.age", "lt", 50 ]
              ]
          }
        },
        DeepOJC: {
          root: "localhost:8080/intermine-test",
          token: "test-user-token",
          q: {
              select: [
                'name',
                'CEO.name',
                'departments.name',
                'departments.manager.name',
                'departments.employees.name', 'departments.employees.age', 'departments.employees.address.address',
                'secretarys.name'],
              from: "Company",
              joins: ['departments', 'departments.employees', 'departments.employees.address', 'secretarys'],
              where: [
                  ["departments.employees.age", "lt", 50 ],
                  ["departments.employees.age", "gt", 40 ]
              ]
          }
        }
    };

    window.notifier = new growlr.NotificationContainer({
        extraClasses: "withnav",
        timeout: 7000
    });

    var messageTemplate = _.template(
        "List successfully created:"
        + '<table class="table table-bordered">'
        + '<tr>'
        + '<td>name</td><td><%- name %></td>'
        + '</tr><tr>'
        + '<td>description</td><td><%- description %></td>'
        + '</tr></tr>'
        + '<td>size</td><td><%- size %></td>'
        + '</tr></tr>'
        + '<td>type</td><td><%- type %></td>'
        + '</tr></table>'
    );

    var failuriser = function(msg) {
        notifier.notify({
            text: msg,
            title: "Failure",
            level: "warning"
        });
    };

    var query_events = {
        "list-creation:success": function(list) {
            notifier.notify({
                text: messageTemplate(list),
                title: "Success",
                level: "success"
            });
        },
        "list-creation:failure": failuriser,
        "list-update:failure": failuriser,
        "list-update:success": function(list, change) {
            notifier.notify({
                text: list.name + " successfully updated. " + ((change > 0) ? "Added" : "Removed") + " "
                      + Math.abs(change) + " items",
                title: "Success",
                level: "success"
            });
        }
    };

    var displayType = 'table';
    var display = $('#table-display');
    var tableProps = {
        pageSize: 10,
        bar: getPageParam('bar', 'none')
    };

    var login = function(serviceArgs) {
        $('.entry-points li').each(function() {
          $(this).toggleClass("active", $(this).text() === serviceArgs);
        });
        var token = services[serviceArgs].token;
        display.imWidget({
            type: displayType,
            url: services[serviceArgs].root,
            token: token,
            query: services[serviceArgs].q,
            events: query_events,
            properties: tableProps
        });

        $('.login-controls').toggleClass("logged-in", !!token);

        var service = display.imWidget('option', 'service');

        service.whoami()
          .done(function(u) {$('#logged-in-notice').show().find('a.username').text(u.username);})
          .fail(function() {$('#logged-in-notice').hide()});

        service.fetchVersion()
          .done(function(v) {$('.v9').toggleClass('unsupported', (v < 9))})
          .fail(function() {$('.v9').addClass('unsupported');});

    };

    $('.entry-points li').click(function() {
        var text = $(this).text();
        if (services[text]) {
            login($(this).text());
        }
    });

    $('.layout-chooser li').click(function() {
        $(this).addClass("active").siblings().removeClass("active");
    });

    var changeLayout = function() {
        if (display.imWidget('option', 'type') != displayType) {
            var service = display.imWidget('option', 'service');
            var query = display.imWidget('option', 'query');
            var evts = display.imWidget('option', 'events');
            display.imWidget({
                type: displayType,
                service: service,
                query: query,
                events: evts,
                properties: {
                    bar: getPageParam('bar', 'none')
                }
            });
        }
    };

    $('#select-wide-layout').click(function() {
        displayType = 'dashboard';
        changeLayout();
    });

    $('#select-compact-layout').click(function() {
        displayType = 'table';
        changeLayout();
    });

    login("Preview");
    
});
