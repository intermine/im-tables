$(function() {

    var services = {
        Production: {
            root: "www.flymine.org/query", 
            token: "21k3D5x5B8pdd8T9yeY24fG8th2",
            q: {
                select: ["symbol", "organism.name", "chromosome.primaryIdentifier", "chromosomeLocation.start"], 
                from: "Gene", 
                where: {
                    Gene: {IN: "an awesome list"}, 
                    length: {lt: 5000}
                }
            }
        },
        Preview: {
          root: "preview.flymine.org/preview",
          token: "T1f3e5D8H9f0w7n1U3RaraXk9J8",
          q: {
              select: ["symbol", "proteins.name"], 
              from: "Gene", 
              where: {
                  length: {lt: 5000},
                  "chromosome.primaryIdentifier": "2L"
              }
          }
        },
        TestModel: {
          root: "localhost:8080/intermine-test",
          token: "test-user-token",
          q: {
              select: ["*", "age"],
              from: "Employee",
              where: [
                  ["age", "lt", 50 ],
                  ["age", "gt", 40 ]
              ]
          }
        },
        PlantMine: {
          root: "www.flymine.org/plantmine",
          q: {
              select: [
                        "primaryIdentifier",
                        "strainGenotypes.strain.name",
                        "strainGenotypes.strain.populations.name",
                        "chromosome.primaryIdentifier",
                        "chromosomeLocation.start",
                        "chromosomeLocation.end",
                        "alleles",
                        "strainGenotypes.allele1",
                        "strainGenotypes.allele2"
                      ],
              from: "SNP",
              where: {primaryIdentifier: "ENSVATH00002756"}
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

    var displayCls = intermine.query.results.DashBoard;
    var display;

    var login = function(serviceArgs) {
        var q = services[serviceArgs].q;
        var service = new intermine.Service(services[serviceArgs]);
        var qv = new displayCls(service, q, query_events);

        $('#table-display').empty();
        qv.$el.appendTo("#table-display");
        qv.render();

        display = qv;

        $('.login-controls').toggleClass("logged-in", !!service.token);

        service.whoami(function(u) {
            $('#logged-in-notice').show().find('a.username').text(u.username);
        }).fail(function() {$('#logged-in-notice').hide()});
        service.fetchVersion(function(v) {
            $('.v9').toggleClass('unsupported', (v < 9));
        }).fail(function() {$('.v9').addClass('unsupported');});

    };

    $('.entry-points li').click(function() {
        var text = $(this).text();
        if (services[text]) {
            login($(this).text());
            $('.entry-points li').removeClass("active");
            $(this).addClass("active");
        }
    });

    $('.layout-chooser li').click(function() {
        $(this).addClass("active").siblings().removeClass("active");
    });

    var classOf = function(obj) {
        return obj.constructor.toString().match(/function\s*(\w+)/)[1];
    };

    var changeLayout = function() {
        if (classOf(display) != displayCls.name) {
            var service = display.service;
            var query = display.query;
            var evts = display.queryEvents;
            display = new displayCls(service, query, evts);
            $('#table-display').empty();
            display.$el.appendTo("#table-display");
            display.render();
        }
    };

    $('#select-wide-layout').click(function() {
        displayCls = intermine.query.results.DashBoard;
        changeLayout();
    });

    $('#select-compact-layout').click(function() {
        displayCls = intermine.query.results.CompactView;
        changeLayout();
    });



    login("Production");
    
});
