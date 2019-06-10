exports.suppress = function(e) { if (e) {
  e.preventDefault();
} return (e != null ? e.stopPropagation() : undefined); };
