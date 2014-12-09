var watch = require('watch');

watch.watchTree('/src', function (f, curr, prev) {
  if (typeof f == "object" && prev === null && curr === null) {
      // Finished walking the tree
    } else if (prev === null) {
      // f is a new file
    } else if (curr.nlink === 0) {
      // f was removed
    } else {
      // f was changed
    }
});
