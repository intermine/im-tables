let openWindowWithPost;
module.exports = (openWindowWithPost = function(uri, name, params) {
  const form = document.createElement("form");
  form.method = "POST";
  form.style.display = "none";
  form.action = uri;
  form.target = name + new Date().getTime();
  for (let key in params) {
    const input = document.createElement("input");
    input.type = "hidden";
    input.name = key;
    input.value = params[key];
    form.appendChild(input);
  }
  const body = document.querySelector("body");
  body.appendChild(form);
  const w = window.open("somenonexistantpathtonowhere", name);
  form.submit();
  body.removeChild(form);
  w.close();
});
