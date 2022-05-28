// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket,
// and connect at the socket path in "lib/web/endpoint.ex".
//
// Pass the token on params as below. Or remove it
// from the params if you are not using authentication.
import { Socket } from "phoenix"

import { LiveSocket } from "phoenix_live_view"

let Hooks = {}

Hooks.Input = {
  mounted() {
    this.el.focus()
  }
}

const auto_flash_timers = {}

Hooks.AutoHideFlash = {
  mounted() {
    const self = this
    const element = this.el
    const id = element.id

    if (auto_flash_timers[id]) {
      clearTimeout(auto_flash_timers[id])
    }

    const timeout = setTimeout(function () {
      element.classList.add("fade-out")
      self.pushEventTo(element, "lv:clear-flash", {}, (_reply, _ref) => { })
    }, 15000);

    auto_flash_timers[id] = timeout
  },
  updated() {
    const self = this
    const element = this.el
    const id = element.id

    if (auto_flash_timers[id]) {
      clearTimeout(auto_flash_timers[id])
    }

    const timeout = setTimeout(function () {
      element.classList.add("fade-out")
      self.pushEventTo(element, "lv:clear-flash", {}, (_reply, _ref) => { })
    }, 15000);

    auto_flash_timers[id] = timeout
  }
}

function buildKeyStringFromKeydownEvent(event) {
  var string = ""

  if (event.ctrlKey) {
    string += "CTRL "
  }

  if (event.altKey) {
    string += "ALT "
  }

  if (event.shiftKey) {
    string += "SHIFT "
  }

  if (event.metaKey) {
    string += "META "
  }

  string += event.code

  return string
}

const hotkeys = {
  "Numpad7": "move northwest",
  "Numpad8": "move north",
  "Numpad9": "move northeast",
  "Numpad4": "move west",
  "Numpad5": "move out",
  "Numpad6": "move east",
  "Numpad1": "move southwest",
  "Numpad2": "move south",
  "Numpad3": "move southeast",
  "Numpad0": "move down",
  "NumpadDecimal": "move up",
  "NumpadEnter": "move bridge",
  "NumpadAdd": "move path",
  "NumpadSubtract": "move gate",
  "NumpadMultiply": "move door",
  "NumpadDivide": "move portal"
}

Hooks.GameClient = {
  mounted() {
    window.addEventListener("beforeunload", event => {
      event.returnValue = "Leaving the page without explicitly logging out will leave your character active for a short time. Do you want to continue?";
    })

    window.addEventListener("keydown", event => {
      var hotkeyString = buildKeyStringFromKeydownEvent(event)
      if (hotkeyString in hotkeys) {
        event.preventDefault()
        this.pushEvent("submit_text_input", { "input": { "text": hotkeys[hotkeyString] } })

        var element = document.getElementById("text_input")
        element.focus()
      }
    })
  }
}

Hooks.draggable_pane = {
  mounted() {
    this.el.addEventListener("dragstart", e => {
      e.dataTransfer.dropEffect = "move";
      var which = $(this.el).parents('div[name ="window"]').first().data("window")
      e.dataTransfer.setData("text/plain", which + ":" + e.target.id); // save the elements id as a payload
    })
  }
}


Hooks.draggable_pane_drop_zone = {
  mounted() {
    this.el.addEventListener("dragover", e => {
      e.preventDefault();
      e.dataTransfer.dropEffect = "move";
    })

    this.el.addEventListener("drop", e => {
      e.preventDefault();
      var data = e.dataTransfer.getData("text/plain");
      var which = $(this.el).parents('div[name ="window"]').first().data("window")
      this.pushEvent("move_pane", data + ":" + which)
    })
  }
}

const toggleMenu = command => {
  menu.style.display = command === "show" ? "block" : "none";
};

const setPosition = ({ top, left }) => {
  menu.style.left = `${left}px`;
  menu.style.top = `${top}px`;
  toggleMenu('show');
};

Hooks.CharacterInventoryWindow = {
  mounted() {
    // this.el.addEventListener("click", e => {
    //     if (menuVisible) toggleMenu("hide");
    // });

    // this.el.addEventListener("contextmenu", e => {
    //     e.preventDefault();
    // });

    // const origin = {
    //     left: e.pageX,
    //     top: e.pageY
    // };
    // setPosition(origin);
    // return false;
  }

}

Hooks.MainStoryWindowTrim = {
  updated() {
    const element = this.el;
    if (element.children.length > 50) {
      do {
        element.removeChild(element.children[0])
      } while (element.children.length > 50)
    }
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  metadata: {
    click: (e, el) => {
      return {
        clientX: e.clientX,
        clientY: e.clientY
      }
    }
  },
  dom: {
    onBeforeElUpdated(from, to) {
      if (from._x_dataStack) {
        window.Alpine.clone(from, to);
      }
    },
  },
  hooks: Hooks
});
liveSocket.connect()

// let socket = new Socket("/socket", { params: { token: window.userToken } })

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_player`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_player = conn.assigns[:current_player] do
//         token = Phoenix.Token.sign(conn, "user socket", current_player.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/3" function
// in "lib/web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket, _connect_info) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, connect to the socket:
// socket.connect()

// Now that you are connected, you can join channels with a topic:
// let channel = socket.channel("character:" + document.querySelector('meta[name="character_id"]').content, {})

// channel.on("output:story", payload => {
//     let message = document.createRange().createContextualFragment(payload.body)
//     storywindow.appendChild(message)
//     if (storyWindowScrolledToBottom) {
//         scrolltobottom.scrollIntoView(false)
//     }
// })
// console.log(channel)
// channel.join()
//     .receive("ok", resp => { console.log("Joined successfully", resp) })
//     .receive("error", resp => { console.log("Unable to join", resp) })
// console.log(channel)
// export default socket