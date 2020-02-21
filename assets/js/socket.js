// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket,
// and connect at the socket path in "lib/web/endpoint.ex".
//
// Pass the token on params as below. Or remove it
// from the params if you are not using authentication.
import { Socket } from "phoenix"

import LiveSocket from "phoenix_live_view"

function htmlToElement(html) {
    var template = document.createElement('template');
    html = html.trim(); // Never return a text node of whitespace as the result
    template.innerHTML = html;
    return template.content.firstChild;
}

function htmlToElements(html) {
    var template = document.createElement('template');
    template.innerHTML = html;
    return template.content.childNodes;
}

function createElementsFromHTML(htmlString) {
    var div = document.createElement('div');
    div.innerHTML = htmlString.trim();

    let frag = document.createRange().createContextualFragment(htmlString.trim())

    // Change this to div.childNodes to support multiple top-level nodes
    return frag;
}

let Hooks = {}

Hooks.Input = {
    mounted() {
        this.el.focus()
    }
}

let storyWindowScrolledToBottom = true;
let storywindow;

Hooks.Story = {
    mounted() {
        this.el.focus()

        let element = this.el
        let character_id = document.querySelector("meta[name='character_id']").getAttribute("content")
        let channel = socket.channel("character:" + character_id, {})

        storywindow = element

        channel.join()
            .receive("ok", ({ messages }) => console.log("successfully joined", messages))
            .receive("error", ({ reason }) => console.log("failed join", reason))
            .receive("timeout", () => console.log("Networking issue. Still waiting..."))

        let prompt = document.querySelector("#prompt")
        prompt.focus()

        // "listen" for the [Enter] keypress event to send a message:
        prompt.addEventListener('keydown', function (event) {
            if (event.keyCode == 13 && prompt.value.length > 0) { // don't sent empty msg.
                event.stopPropagation()
                event.preventDefault()

                channel.push("input", prompt.value)

                prompt.value = '';         // reset the message input field for next message.

                // "listen" for the [Tab] keypress event to send an autocomplete message:
            } else if (event.keyCode == 9 && prompt.value.length > 0) { // don't sent empty msg.
                event.stopPropagation()
                event.preventDefault()
                console.log(event)
                channel.push("autocomplete", prompt.value)

            } else if (event.keyCode == 9) {
                event.stopPropagation()
                event.preventDefault()
            }
        });
    },

    beforeUpdate() {
        storyWindowScrolledToBottom = storywindow.scrollHeight - storywindow.clientHeight <= storywindow.scrollTop + 1;
    },

    updated() {
        if (storyWindowScrolledToBottom)
            storywindow.scrollTop = storywindow.scrollHeight - storywindow.clientHeight;
    }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token: csrfToken }, hooks: Hooks });
liveSocket.connect()

let socket = new Socket("/socket", { params: { token: window.userToken } })

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
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
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
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
socket.connect()

// Now that you are connected, you can join channels with a topic:
// let channel = socket.channel("topic:subtopic", {})
// channel.join()
//   .receive("ok", resp => { console.log("Joined successfully", resp) })
//   .receive("error", resp => { console.log("Unable to join", resp) })

export default socket