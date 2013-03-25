
jQuery(document).ready(function($) {
    $('#entry-dropdowns').click(function() {
      $('.entry-points').toggleClass('dropdown');
    });

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
        YeastMineNext: {
          root: "http://yeastmine-test.yeastgenome.org/yeastmine-dev",
          token: "E1S3edN5Jed3qe53mdMa",
          q: {
            "name": "Phenotype -> Genes",
            "from": "Phenotype",
            "select": [
              "genes.name",
              "experimentType",
              "qualifier", "allele", "condition", "details", "reporter",
              "publications.pubMedId", "publications.citation"],
            "orderBy": ["experimentType"],
            "joins": ["publications"],
            "where": {
              "observable": "Protein secretion"
            }
          }
        },
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
          "root": "preview.flymine.org/preview",
          q: {
            "title":"Gene --> Orthologues + GO terms of these orthologues.","description":"Show GO terms applied to orthologues of a specific gene. (Data Source: InParanoid, TreeFam, Drosophila Consortium, GO Consortium).",
            "select":[
              "Gene.primaryIdentifier","Gene.symbol","Gene.homologues.homologue.primaryIdentifier","Gene.homologues.homologue.symbol","Gene.homologues.type","Gene.homologues.homologue.organism.name","Gene.homologues.dataSets.name","Gene.homologues.gene.goAnnotation.ontologyTerm.name","Gene.homologues.gene.goAnnotation.ontologyTerm.identifier"],
            "constraintLogic":"A and B",
            "name":"Gene_OrthologueGO_new",
            "comment":"13/03/07 added orthologue organismDbId. Philip 070607 updated to work with gene class Philip",
            "orderBy":[{"Gene.primaryIdentifier":"ASC"}],
            "joins":["Gene.homologues.gene","Gene.homologues.gene.goAnnotation","Gene.homologues.gene.goAnnotation.ontologyTerm"],
            "where":[{"path":"Gene.homologues.type","op":"=","code":"A","value":"orthologue"},{"path":"Gene","op":"LOOKUP","code":"B","value":"CG6235","extraValue":"D. melanogaster"}]}
        },
        Beta: {
          //"root": "preview.flymine.org/preview",
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
                  "chromosomeLocation.locatedOn.primaryIdentifier": "2L"
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

    window.notifier = {
      notify: function(o) {
        console.log(arguments);
        alert(o.text);
      }
    };
      
      
    //new growlr.NotificationContainer({
    //    extraClasses: "withnav",
    //    timeout: 7000
    //});

    var messageTemplate = function(list) {
      return list.name + ": " + list.description + " (" + list.size + " " + list.type + ")";
    };
    /**  _.template(
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
    );**/

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

    var login = function(serviceArgs, noToken) {
        $('.entry-points li').each(function() {
          $(this).toggleClass("active", $(this).text() === serviceArgs);
        });
        $('.entry-points').removeClass('dropdown');
        var token = (noToken ? null : services[serviceArgs].token);
        var url = services[serviceArgs].root;
        var query = services[serviceArgs].q;
        doLogin(url, token, query);
    };
    var doLogin = function(url, token, query) {

        display.imWidget({
            type: displayType,
            url: url,
            token: token,
            query: query,
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

    $('#log-out').on('click', function(e) {
      var current = $('.entry-points li.active a').text();
      console.log("Logging out of " + current);
      login(current, true);
    });

    $('#start-registration').on('click', function(e) {
      $('#registration-fields').show();
      $('#user-changer').text('Sign Up');
      $('#offer-registration').hide();
    });

    $('#cancel-login').on('click', function(e) {
      e.preventDefault();
      e.stopPropagation();
      $('#registration-fields').hide();
      $('#user-changer').text('Log In');
      $('#offer-registration').show();
      $('#change-user-form input').each(function() {
        $(this).val('');
      });
      $('#log-out').dropdown('toggle');
    });

    var canBasicAuth = function() {
      if (!jQuery.base64) {
        return $.getScript(intermine.options.CDN.server + '/js/jquery-base64/1.0/jquery-base64.min.js');
      } else {
        return $.Deferred(function () {this.resolve(true)}).promise();
      }
    };

    var makeBasicAuth = function(user, pass) {
      return canBasicAuth().then(function() {
        var tok = user + ':' + pass;
        var hash = $.base64.encode(tok);
        return 'Basic ' + hash;
      });
    };

    $('#change-user-form').submit(function (e) {
      e.preventDefault();
      e.stopPropagation();
      var service = display.imWidget('option', 'service');
      var username = $('#new-user').val();
      var password = $('#new-pass').val();
      var root = service.root;
      $('#log-out').dropdown('toggle');
      var authP = makeBasicAuth(username, password);
      authP.fail(function() {
        notifier.notify({
          title: "Log in failed",
          text: 'Cannot fetch base64 encoder',
          level: "warning"
        });
      });
      var promise = authP.then(function(auth) {
        return $.ajax({
          url: root + 'user/token?format=json',
          beforeSend: function (xhr) { xhr.setRequestHeader('Authorization', auth); return true;},
          dataType: 'json',
          type: 'GET'
        });
      });
      promise.done(function(ret) {
        var url = service.root;
        var token = ret.token;
        var query = display.imWidget('option', 'query');
        doLogin(url, token, query);
        console.log(ret);
        notifier.notify({
          title: "Logged in",
          text: "logged in as " + username,
          level: 'success'
        });
      });

      promise.fail(function(xhr) {
        notifier.notify({
          title: "Log in failed",
          text: 'Incorrect username/password',
          level: "warning"
        });
      });
    });

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

    login("Beta");
    
});
