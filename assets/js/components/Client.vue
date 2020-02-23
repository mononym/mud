<template>
  <div
    name="client"
    class="w-screen h-screen flex flex-col overflow-hidden max-h-screen"
  >
    <div
      id="story"
      class="min-w-full flex flex-col flex-1 overflow-y-scroll p-2 font-extrabold font-story"
    >
    </div>
    <input
      id="prompt"
      type="textarea"
      class="min-w-full rounded-lg resize-y flex-shrink"
      placeholder="Enter Commands Here..."
    />
  </div>
</template>

<script>
import socket from "../socket"

let storyWindowScrolledToBottom = true;
let storywindow;

export default {
  mounted() {
    socket.connect();
    // Join in the links channel
    let character_id = document.querySelector("meta[name='character_id']").getAttribute("content")

    let channel = socket.channel("character:" + character_id, {})
    channel.join()
      .receive("ok", ({ messages }) => console.log("successfully joined", messages))
      .receive("error", ({ reason }) => console.log("failed join", reason))
      .receive("timeout", () => console.log("Networking issue. Still waiting..."))

    storywindow = document.querySelector("#story")

    channel.on("output:story", text => {
      console.log("text")
      console.log(text)
      let textLines = document.createRange().createContextualFragment(text.text.trim())

      storyWindowScrolledToBottom = storywindow.scrollHeight - storywindow.clientHeight <= storywindow.scrollTop + 1;

      story.appendChild(textLines)

      if (storyWindowScrolledToBottom)
        storywindow.scrollTop = storywindow.scrollHeight - storywindow.clientHeight;
    })

    channel.on("output:autocomplete", autocomplete => {
      console.log("autocomplete")
      console.log(autocomplete)
    })

    let prompt = document.querySelector("#prompt")
    prompt.focus()

    prompt.addEventListener('keydown', function (event) {
      if (event.keyCode == 13 && prompt.value.length > 0) { // don't sent empty msg.
        event.stopPropagation()
        event.preventDefault()

        channel.push("input", prompt.value)

        prompt.value = '';         // reset the message input field for next message.

        // "listen" for the [Tab] keypress event to send an autocomplete message:
      } else if (event.keyCode == 9) {
        console.log("autocomplete")
        event.stopPropagation()
        event.preventDefault()

        channel.push("autocomplete", prompt.value)

        // Numpad 6
      } else if (event.code == "Numpad0") {
        event.stopPropagation()
        event.preventDefault()
        channel.push("input", "down")
      } else if (event.code == "NumpadDecimal") {
        event.stopPropagation()
        event.preventDefault()
        channel.push("input", "up")
      } else if (event.code == "Numpad1") {
        event.stopPropagation()
        event.preventDefault()
        channel.push("input", "southwest")
      } else if (event.code == "Numpad2") {
        event.stopPropagation()
        event.preventDefault()
        channel.push("input", "south")
      } else if (event.code == "Numpad3") {
        event.stopPropagation()
        event.preventDefault()
        channel.push("input", "southeast")
      } else if (event.code == "Numpad4") {
        event.stopPropagation()
        event.preventDefault()
        channel.push("input", "west")
      } else if (event.code == "Numpad5" && event.ctrlKey == true) {
        event.stopPropagation()
        event.preventDefault()
        channel.push("input", "out")
      } else if (event.code == "Numpad5") {
        event.stopPropagation()
        event.preventDefault()
        channel.push("input", "in")
      } else if (event.code == "Numpad6") {
        event.stopPropagation()
        event.preventDefault()
        channel.push("input", "east")
      } else if (event.code == "Numpad7") {
        event.stopPropagation()
        event.preventDefault()
        channel.push("input", "northwest")
      } else if (event.code == "Numpad8") {
        event.stopPropagation()
        event.preventDefault()
        channel.push("input", "north")
      } else if (event.code == "Numpad9") {
        event.stopPropagation()
        event.preventDefault()
        channel.push("input", "northeast")
      } else if (event.code == "NumpadDivide") {
        event.stopPropagation()
        event.preventDefault()
        channel.push("input", "go path")
      } else if (event.code == "NumpadMultiply") {
        event.stopPropagation()
        event.preventDefault()
        channel.push("input", "go foothpath")
      } else if (event.code == "NumpadSubtract") {
        event.stopPropagation()
        event.preventDefault()
        channel.push("input", "go gate")
      } else if (event.code == "NumpadAdd") {
        event.stopPropagation()
        event.preventDefault()
        channel.push("input", "go bridge")
      } else {
        console.log(event)
      }
    });
  },
  data() {
    return {
      autocomplete: []
    }
  },
  methods: {
  },
  created() {
    console.log("Vue component created")
  }
}
</script>

 
<style>
</style>