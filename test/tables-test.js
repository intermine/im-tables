module("Table Tests", {
    setup: function() {
        this.table = new intermine.results.Table();
    }
});

test('init', 1, function() {
    ok(true, "Can set everything up right");
});


test('getPage', 11, function() {
    var page;
    page = this.table.getPage(0, 10);
    same({start: 0, size: 100}, page, "Basic page ok");
    page = this.table.getPage(25, 50);
    same({start: 25, size: 500}, page, "Larger page ok");

    this.table.cache = {lastResult: true, lowerBound: 0, upperBound: 100};
    page = this.table.getPage(100, 10);
    same({start: 100, size: 100}, page, "Cache doesn't interfere if there is no overlap and no gap");

    this.table.cache = {lastResult: true, lowerBound: 100, upperBound: 200};
    page = this.table.getPage(90, 10);
    same({start: 0, size: 100}, page, "Paging backwards gets a full pipe-width");

    this.table.cache = {lastResult: true, lowerBound: 100, upperBound: 200};
    page = this.table.getPage(250, 10);
    same(page, {start: 200, size: 150}, "Gaps are filled in going forwards");

    this.table.cache = {lastResult: true, lowerBound: 100, upperBound: 200};
    page = this.table.getPage(210, 25);
    same(page, {start: 200, size: 260}, "Gaps are filled in going forwards");

    this.table.cache = {lastResult: true, lowerBound: 200, upperBound: 300};
    page = this.table.getPage(50, 10);
    same(page, {start: 0, size: 200}, "Gaps are filled in going backwards");

    this.table.cache = {lastResult: true, lowerBound: 500, upperBound: 600};
    page = this.table.getPage(450, 10);
    same(page, {start: 350, size: 150}, "Gaps are filled in going backwards");

    this.table.cache = {lastResult: true, lowerBound: 500, upperBound: 600};
    page = this.table.getPage(0, 0);
    same(page, {start: 0, size: 0}, "All means all");

    this.table.cache = {lastResult: true, lowerBound: 500, upperBound: 600};
    page = this.table.getPage(750, 0);
    same(page, {start: 600, size: 0}, "But we still want to fill in gaps");

    this.table.cache = {lastResult: true, lowerBound: 500, upperBound: 600};
    page = this.table.getPage(250, 0);
    same(page, {start: 250, size: 0}, "But we still want to fill in gaps");

});

test("Add rows to cache - paging forwards", function() {
    this.table.cache = {
        lowerBound: 10, upperBound: 20,
        lastResult: {results: [11, 12, 13, 14 ,15, 16, 17, 18, 19, 20]}
    };

    var result = {results: ["xxi", "xxii", "xxiii", "xxiv", "xxv"]};
    var page = {start: 20, size: 5};

    this.table.addRowsToCache(page, result);
    
    var expected = [11, 12, 13, 14 ,15, 16, 17, 18, 19, 20, "xxi", "xxii", "xxiii", "xxiv", "xxv"];

    same(this.table.cache.lastResult.results, expected, "Can append rows");
    equals(this.table.cache.lowerBound, 10);
    equals(this.table.cache.upperBound, 25);
});

test("Merge overlap - paging forwards", function() {
    this.table.cache = {
        lowerBound: 10, upperBound: 20,
        lastResult: {results: [11, 12, 13, 14 ,15, 16, 17, 18, 19, 20]}
    };

    var result = {results: ["xviii", "xix", "xx", "xxi", "xxii", "xxiii", "xxiv", "xxv"]};
    var page = {start: 17, size: 8};

    this.table.addRowsToCache(page, result);
    
    var expected = [11, 12, 13, 14 ,15, 16, 17, "xviii", "xix", "xx", "xxi", "xxii", "xxiii", "xxiv", "xxv"];

    same(this.table.cache.lastResult.results, expected, "Can append rows");
    equals(this.table.cache.lowerBound, 10);
    equals(this.table.cache.upperBound, 25);
});

test("Add rows to cache - paging backwards", function() {
    this.table.cache = {
        lowerBound: 10, upperBound: 20,
        lastResult: {results: [11, 12, 13, 14 ,15, 16, 17, 18, 19, 20]}
    };

    var result = {results: ["vi", "vii", "viii", "ix", "x"]};
    var page = {start: 5, size: 5};

    this.table.addRowsToCache(page, result);
    
    var expected = ["vi", "vii", "viii", "ix", "x", 11, 12, 13, 14 ,15, 16, 17, 18, 19, 20];

    same(this.table.cache.lastResult.results, expected, "Can prepend rows");
    equals(this.table.cache.lowerBound, 5);
    equals(this.table.cache.upperBound, 20);
});
    
test("Merge overlap - paging backwards", function() {
    this.table.cache = {
        lowerBound: 10, upperBound: 20,
        lastResult: {results: [11, 12, 13, 14 ,15, 16, 17, 18, 19, 20]}
    };

    var result = {results: ["vi", "vii", "viii", "ix", "x", "xi", "xii"]};
    var page = {start: 5, size: 7};

    this.table.addRowsToCache(page, result);
    
    var expected = ["vi", "vii", "viii", "ix", "x", "xi", "xii", 13, 14 ,15, 16, 17, 18, 19, 20];

    same(this.table.cache.lastResult.results, expected, "Can prepend rows");
    equals(this.table.cache.lowerBound, 5);
    equals(this.table.cache.upperBound, 20);
});

test("Serve results from cache", function() {
    this.table.cache = {
        lowerBound: 10, upperBound: 20,
        lastResult: {results: [11, 12, 13, 14 ,15, 16, 17, 18, 19, 20]}
    };

    stop();
    var t = this.table;

    t.serveResultsFromCache("foo", 13, 3, function(res) {
        same(res.aaData, [14, 15, 16], "Can slice out a range of rows");
        same(t.cache.lastResult.results, [11, 12, 13, 14 ,15, 16, 17, 18, 19, 20], "This didn't affect the cache");
        equals(res.sEcho, "foo", "The echo is echo-ed");
        start();
    });

});
