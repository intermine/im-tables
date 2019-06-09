module.exports = openWindowWithPost = (uri, name, params) ->
  form = document.createElement("form")
  form.method = "POST"
  form.style.display = "none"
  form.action = uri
  form.target = name + new Date().getTime()
  for key of params
    input = document.createElement("input")
    input.type = "hidden"
    input.name = key
    input.value = params[key]
    form.appendChild input
  body = document.querySelector("body")
  body.appendChild form
  w = window.open("somenonexistantpathtonowhere", name)
  form.submit()
  body.removeChild form
  w.close()
  return
