
jQuery(document).ready(function($) {

    var formatsets, formatset, fsKey;
    for (formatsets in intermine.results.formatsets) {
      formatset = intermine.results.formatsets[formatsets];
      for (fsKey in formatset) {
        if (formatset[fsKey] === false)
          formatset[fsKey] = true;
      }
    }

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

    var merge = function() {
      var toMerge, key, value
        , len = arguments.length
        , i   = 1
        , obj = arguments[0];
      if (obj == null) obj = {}; // Null target is {}
      for (;i < len;i++) {
        toMerge = arguments[i];
        if (toMerge != null) { // Skip null mergends
          for (key in toMerge) {
            value = toMerge[key];
            obj[key] = value;
          }
        }
      }
      return obj;
    }
    var any = function(things, test, context) {
      if (things == null) throw new Error("no things provided to test");
      if (test == null) test = function (x) { return x };
      if (!test.call) throw new Error("test is not callable");
      var elem, i = 0, len = things.length;
      for (;i < len; i++) {
        elem = things[i];
        if (test.call(context, elem)) {
          return true;
        }
      }
      return false;
    }
    var all = function(things, test, context) {
      if (test == null) test = function (x) { return x };
      if (!test.call) throw new Error("test is not callable");
      var invertedTest = function (x) { return !test.call(context, x) };
      return !any(things, invertedTest);
    }

    intermine.scope("intermine.results.formatters", {
      Manager: function(model) {
        var id, needs, p, data;
        id = model.get('id');
        needs = ['title', 'name'];
        if (model._fetching || any(needs, function (n) { return !model.has(n); })) {
          model._fetching = p = this.options.query.service.findById('Manager', id);
          p.done(function(manager) { model.set(manager) });
        }
        data = merge({title: '', name: ''}, model.toJSON());
        return data.title + " " + data.name;
      }
    });
    var employeeNameFormatter = function(model) {
      return "<strong>" + model.get('name') + "</strong>";
    };
    var employeeAgeFormatter = function(model) {
      return "<i>" + model.get('age') + "</i>";
    };

    intermine.scope('intermine.results.formatsets.testmodel', {
      'Manager.name': true,
      'Employee.age': employeeAgeFormatter,
      'Employee.name': employeeNameFormatter
    });

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
        MetabolicTest: {
          root: "http://test.metabolicmine.org/test",
          q: {
            "name": "SNPS and their doubles",
            "select":[
              "GWASResult.SNP.primaryIdentifier",
              "GWASResult.SNP.alleles",
              "GWASResult.SNP.chromosomeLocation.start",
              "GWASResult.SNP.chromosome.primaryIdentifier",
              "GWASResult.phenotype","GWASResult.pValue",
              "GWASResult.study.firstAuthor"
            ],
            "orderBy":[{"GWASResult.SNP.primaryIdentifier":"ASC"}]
          }
        },
        WormMine: {
          root: "http://206.108.125.166:8080/wormmine",
          q: {
            "name": "Gene -> CDS's",
            "from": "Gene",
            "select": [ "CDSs.primaryIdentifier", "organism.name" ],
            "join": ['organism']
          }
        },
        'Worm-CDSs': {
          root: "http://206.108.125.166:8080/wormmine",
          q: {
            "name": "CDSs",
            "from": "CDS",
            "select": [ "length", "primaryIdentifier", "symbol", "gene.primaryIdentifier" ]
          }
        },
        Production: {
            // root: "www.flymine.org/query", 
            // token: "21k3D5x5B8pdd8T9yeY24fG8th2",
            // q: {
            //    select: ["symbol", "organism.name", "chromosomeLocation.start"], 
            //    from: "Gene", 
            //    where: {
            //    //    Gene: {IN: "an awesome list"}, 
            //        length: {lt: 5000}
            //    }
            //}
            root: "localhost/squirrelmine",
            q: {
              select: ["symbol"],
              from: "Gene",
              where: {"Gene.goAnnotation": null}
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
        'Missing Column': {
          q: {
            "model":{"name":"genomic"},
            "title":"GO term name (and children of this term) --> Genes in organism1 + Orthologues in organism2.",
            "description":"For a specified GO term (and children of this term) find all the genes in a particular organism that have an orthologue in another organism",
            "select":[
              "Gene.secondaryIdentifier",
              "Gene.symbol","Gene.goAnnotation.ontologyTerm.parents.name",
              "Gene.goAnnotation.ontologyTerm.parents.identifier",
              "Gene.goAnnotation.ontologyTerm.name",
              "Gene.goAnnotation.ontologyTerm.identifier",
              "Gene.homologues.homologue.primaryIdentifier",
              "Gene.homologues.homologue.secondaryIdentifier",
              "Gene.homologues.homologue.symbol"
            ],
            "constraintLogic":"A and B and C and D",
            "name":"GO_GeneOrthologues",
            "comment":"","orderBy":[{"Gene.secondaryIdentifier":"ASC"}],"where":[{"path":"Gene.goAnnotation.ontologyTerm","type":"GOTerm"},{"path":"Gene.goAnnotation.ontologyTerm.parents","type":"GOTerm"},{"path":"Gene.homologues.type","op":"=","code":"D","editable":false,"switchable":false,"switched":"LOCKED","value":"orthologue"},{"path":"Gene.goAnnotation.ontologyTerm.parents.name","op":"=","code":"A","editable":true,"switchable":false,"switched":"LOCKED","value":"DNA binding"},{"path":"Gene.organism.name","op":"=","code":"B","editable":true,"switchable":false,"switched":"LOCKED","value":"Drosophila melanogaster"},{"path":"Gene.homologues.homologue.organism.name","op":"=","code":"C","editable":true,"switchable":true,"switched":"ON","value":"Caenorhabditis elegans"}]},
          "root": "preview.flymine.org/preview"
        },
        'Gene-Homologues': {
          "root": "beta.flymine.org/beta",
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
        'CDSs': {
          "root": "beta.flymine.org/beta",
          "token": "M1n3x2ydw4icj140pbBcffIgR4Q",
          q: {
            "name":"CDSs",
            "title":"a query for the features overlapping the cdss",
            "select":[
              'symbol',
              'CDSs.primaryIdentifier',
              'CDSs.chromosomeLocation.*'
            ],
            from: "Gene",
            "joins":["CDSs"],
            "where":{
              length: {lt: 2000},
              'organism.species': 'melanogaster'
            }
          }
        },
        'Gene-Prot-Exons': {
          root: "beta.flymine.org/beta",
          //"root": "localhost/squirrelmine",
          //token: "M1n3x2ydw4icj140pbBcffIgR4Q",
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
              orderBy: ["proteins.name"],
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
        MouseColumnHeaders: {
          help: "alex@intermine.org",
          root: "http://beta.mousemine.org/mousemine",
          q: {
            "select":[
              "GXDExpression.assayType","GXDExpression.feature.symbol",
              "GXDExpression.assayId","GXDExpression.probe","GXDExpression.image",
              "GXDExpression.publication.mgiJnum"
            ],
            "orderBy":[{"GXDExpression.assayId":"ASC"}],
            "where":[
              {"path":"GXDExpression.feature.organism.taxonId","op":"=","code":"B","value":"10090"},
              {"path":"GXDExpression.feature","op":"LOOKUP","code":"A","value":"Pax6"}
            ]
          }
        },
        TestModel: {
          help: 'alex@intermine.org',
          //root: "http://demo.intermine.org/intermine-test-dev",
          root: "http://localhost/intermine-test",
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
          root: "http://localhost/intermine-test",
          token: "test-user-token",
          q: {
              select: ['name', 'company.name', 'employees.name', 'employees.age', 'employees.end', 'employees.address.address' ],
              from: "Department",
              joins: ['employees'],
              where: [
                  ["employees.age", "lt", 50 ]
              ]
          },
          properties: {
            SubtableInitialState: 'open'
          }
        },
        MultiOJC: {
          help: 'alex@intermine.org',
          root: "http://localhost/intermine-test",
          token: "test-user-token",
          q: {
              select: [
                'name', 'department.name', 'address.address', 'employmentPeriod.start'
              ],
              from: "Employee",
              joins: ['department', 'address', 'employmentPeriod']
          }
        },
        DeepOJC: {
          root: "http://localhost/intermine-test",
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

    var notifier, errorHandler, noop;
    noop = function () {};
    notifier = window.notifier = {
      notify: function(o) {
        console.log(arguments);
        alert(o.text);
      }
    };
    errorHandler = function(err) {
      if (err.responseText || /whoami/.test(err)) {
        return;
      }
      console.log("Error", err);
      var messages, div, closer;

      messages = document.getElementById('error-messages');
      div = document.createElement('div');
      closer = document.createElement('button');

      if (!messages) {
        messages =  document.createElement('ul');
        messages.id = 'error-messages';
        document.querySelector('body').appendChild(messages);
      }

      closer.innerHTML = 'dismiss';
      closer.className = 'dismiss';
      closer.addEventListener('click', function(event) {
        messages.removeChild(div);
      });
      div.appendChild(closer);
      div.className = 'error-message';
      div.appendChild(document.createTextNode('ERROR: ' + err));

      messages.appendChild(div);
        
    };

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

    // intermine.setOptions({GalaxyCurrent: 'https://demo.g2.bx.psu.edu'});

    var query_events = {
        "imo:click": function(type, id) {
          console.log("The user is interested in " + type + "(" + id + ")");
        },
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
        doLogin(url, token, query, services[serviceArgs].properties);
    };
    var doLogin = function(url, token, query, props) {
        jQuery('#error-messages').empty();
        console.log(props);

        display.imWidget({
            type: displayType,
            url: url,
            token: token,
            error: errorHandler,
            query: query,
            events: query_events,
            properties: merge({}, tableProps, props)
        });

        var service = display.imWidget('option', 'service');

        $('.login-controls').toggleClass("logged-in", !!token);

        var p1 = service.whoami()
          .done(function(u) {$('#logged-in-notice').show().find('a.username').text(u.username);})
          .fail(function() {$('#logged-in-notice').hide()});

        var p2 = service.fetchVersion()
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

    $('#select-minimal-layout').click(function() {
        displayType = 'minimal';
        changeLayout();
    });


    $('#demo-settings').click(function() {
      $('#settings-dialogue').modal('show');
    });

    (function() {
      var $serviceSelect = $('#query-service');
      var serviceCombinations = {};
      var name, service, root;
      for (name in services) {
        service = services[name];
        if (!serviceCombinations[service.root]) {
          serviceCombinations[service.root] = service;
        }
      }
      for (root in serviceCombinations) {
        $serviceSelect.append('<option value="' + root + '">' + root + '</option>');
      }

      $('#settings-dialogue .btn-primary').click(function(e) {
        $('#settings-dialogue').modal('hide');
        var params = $('#settings-dialogue form').serializeArray();
        var form = intermine.funcutils.pairsToObj(params.map(function(param) {
          return [param.name, param.value];
        }));
        var service = serviceCombinations[form.service];
        doLogin(service.root, service.token, intermine.Query.fromXML(form.query), service.properties);
      });
    })();

    var initial = $('.entry-points li.active a').text();
    login(initial || "Gene-Prot-Exons");
    
});
