export function buildHotkeyStringFromEvent(event) {
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

export function buildHotkeyStringFromRecord(record) {
  const keys = [];

  if (record.ctrlKey) {
    keys.push("CTRL");
  }

  if (record.altKey) {
    keys.push("ALT");
  }

  if (record.shiftKey) {
    keys.push("SHIFT");
  }

  if (record.metaKey) {
    keys.push("META");
  }

  if (record.key) {
    keys.push(record.key);
  }

  return keys.join(" + ");
}

export function buildRecordFromHotkeyString(hotkeyString) {
  const newRecord = {
    id: "",
    altKey: false,
    ctrlKey: false,
    shiftKey: false,
    metaKey: false,
    key: "",
    command: "",
  };

  if (hotkeyString == "") {
    return newRecord;
  }

  const keys = hotkeyString.split(" + ");

  if ("CTRL" in keys) {
    newRecord.ctrlKey = true;
  }

  if ("ALT" in keys) {
    newRecord.altKey = true;
  }

  if ("SHIFT" in keys) {
    newRecord.shiftKey = true;
  }

  if ("META" in keys) {
    newRecord.metaKey = true;
  }

  newRecord.key = keys[keys.length - 1];

  return newRecord;
}

export function getItemColor(colors, item) {
  if (item.flags.is_clothing) {
    return colors.clothing;
  } else if (item.flags.coin) {
    return colors.coin;
  } else if (item.flags.is_equipment) {
    return colors.equipment;
  } else if (item.flags.furniture) {
    return colors.furniture;
  } else if (item.flags.gem) {
    return colors.gem;
  } else if (item.flags.is_jewelry) {
    return colors.jewelry;
  } else if (item.flags.is_structure) {
    return colors.structure;
  } else {
    return colors.misc;
  }
}
