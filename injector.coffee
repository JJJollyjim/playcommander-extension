# Load jQuery
jqscript = document.createElement "script"
jqscript.src = chrome.extension.getURL "jquery.js"

jqscript.onload = ->
  # Remove it after loading
  this.parentNode.removeChild(this)

  # Load the injection
  inscript = document.createElement "script"
  inscript.src = chrome.extension.getURL "injection.js"

  inscript.onload = ->
    # Remove it after loading
    this.parentNode.removeChild this

  # Inject injection
  (document.head or document.documentElement).appendChild(inscript)

# Inject jQuery
(document.head or document.documentElement).appendChild(jqscript)