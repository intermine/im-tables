_ = require 'underscore'

prefixesAll = (xs) -> (prefix) -> _.all xs, (x) -> 0 is x.indexOf prefix

# Find the longest common prefix from an array of paths as strings.
# :: [string] -> string
module.exports = longestCommonPrefix = ([head, tail...]) ->
  throw new Error 'Empty list' unless head?
  return head unless tail.length # lcp of single item list is that item.
  parts = head.split /\./
  # We only need to test the tail, since we know that the parts come from the head.
  test = prefixesAll tail

  [prefix] = parts # Root, must be common prefix.
  for part in parts when test nextPrefix = "#{prefix}.#{part}"
    prefix = nextPrefix
  prefix

