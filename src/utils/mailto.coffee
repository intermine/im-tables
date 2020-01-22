exports.href = (address, subject, body) ->
  pairs = [['subject', subject], ['body', body]]
  params = pairs.map ([k, v]) -> "#{ k }=#{ encodeURIComponent v }"
                .join '&'
  address + '?' + params

