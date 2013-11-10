# Unconflictise jQuery
$.noConflict();

# Alias localStorage to ls
ls = localStorage

# Check if a uuid is stored
ls.pc_uuid = pc_genuuid() unless ls.pc_uuid?

setupsocket = ->
  # Connect to server
  socket = new WebSocket("ws://127.0.0.1:8081")

  socket.onopen = (event) ->
    socket.sendMessage("auth", {uuid: ls.pc_uuid})

    setuiled   "yellow"
    setbtntext "Authenticating"

  socket.onmessage = (event) ->
    data = JSON.parse event.data

    handleMessage(socket, data.type, data.payload)

  socket.onerror = (event) ->
    setuiled   "red"
    setbtntext "Connection error"

  socket.onclose = (event) ->
    setuiled   "red"
    setbtntext "Disconnected"

  socket.sendMessage = (type, payload = {}) ->
    payload.clientType = "player"
    message = {
      type: type
      payload: payload
    }

    this.send(JSON.stringify message)

  socket

socket = setupsocket()

sel =
  extralinks   : jQuery "#extra-links-container"
  playpause_btn: jQuery "[data-id=play-pause]"

playInterface =
  playpause:
    set: -> sel.playpause_btn.click()
    get: -> false

handleMessage = (socket, type, payload) ->
  switch type
    when "ack"
      # Authentication successful

      setuiled   "green"
      setbtntext "Connected"
      setuitext  "Pairing Code: #{payload.paircode.toUpperCase()}"
      setuirems  "No"

    when "remotenum"
      # Updated number of remotes

      setuirems  if payload.num is 0 then "No" else payload.num

# UI Feature
sel.extralinks.after "
<p id='pc_ui_pac'>
  <span id='pc_ui_pac_txt'>    </span><br>
  <span id='pc_ui_pac_remotes'></span>
</p>
<button id='pc_ui_btn' class='button small vertical-align'>
  <div id='pc_ui_led' class='red'></div>
  <span id='pc_ui_txt'>PlayCommander: Connecting</span>
</button>"

sel.ui_btn = jQuery "#pc_ui_btn"
sel.ui_led = jQuery "#pc_ui_led"
sel.ui_txt = jQuery "#pc_ui_txt"
sel.ui_pac = jQuery "#pc_ui_pac_txt"
sel.ui_rem = jQuery "#pc_ui_pac_remotes"

setuiled = (colour) ->
  for c in ["red", "yellow", "green"]
    if colour is c then sel.ui_led.addClass(c)
    else sel.ui_led.removeClass(c)

setbtntext = (text) ->
  sel.ui_txt.text "PlayCommander: #{text}"

setuitext = (text) ->
  sel.ui_pac.parent().show()
  sel.ui_pac.text text

setuirems = (num) ->
  if num is 1
    sel.ui_rem.text "#{num} remote"
  else
    sel.ui_rem.text "#{num} remotes"

# Event listener for UI feature
sel.ui_btn.click =>
  socket.close()
  socket = setupsocket()