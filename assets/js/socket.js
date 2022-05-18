// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket,
// and connect at the socket path in "lib/web/endpoint.ex".
//
// Pass the token on params as below. Or remove it
// from the params if you are not using authentication.
import { Socket } from "phoenix"

import { LiveSocket } from "phoenix_live_view"

// let socket = new Socket("/socket")

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

Hooks.draggable_pane = {
    mounted() {
        this.el.addEventListener("dragstart", e => {
            e.dataTransfer.dropEffect = "move";
            console.log(e)
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

let storyWindowScrolledToBottom = true;
let storywindow;
let scrolltobottom;

Hooks.Story = {
    mounted() {
        storywindow = this.el

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
    }
}

Hooks.MessageWrapper = {
    // updated() {
        // if (storyWindowScrolledToBottom) {
            // storywindow.scrollTop = storywindow.scrollHeight;
        //     scrolltobottom.scrollIntoView(false)
        // }
    // }
}

function handleIntersect(entries, observer) {
    storyWindowScrolledToBottom = entries[0].isIntersecting;
}

Hooks.ScrollToBottom = {
    // mounted() {
    //     scrolltobottom = this.el;

    //     const io = new IntersectionObserver(handleIntersect, { threshold: [0, 1] })

    //     io.observe(this.el)
    // },
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