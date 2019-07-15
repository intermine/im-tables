exports.href = function(address, subject, body) {
  const pairs = [['subject', subject], ['body', body]];
  const params = pairs.map(function(...args) { const [k, v] = Array.from(args[0]); return `${ k }=${ encodeURIComponent(v) }`; })
                .join('&');
  return address + '?' + params;
};

