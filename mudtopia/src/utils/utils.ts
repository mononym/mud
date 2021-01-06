export function buildPresetHotkeyStringFromEvent(event) {
  const keys = [];

  if (event.ctrlKey) {
    keys.push("CTRL");
  }

  if (event.altKey) {
    keys.push("ALT");
  }

  if (event.shiftKey) {
    keys.push("SHIFT");
  }

  if (event.metaKey) {
    keys.push("META");
  }

  if (event.code) {
    keys.push(event.code);
  }

  return keys.join(" + ");
}
