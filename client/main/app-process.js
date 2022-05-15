const { BrowserWindow, screen } = require("electron");

function createAppWindow() {
    const { width, height } = screen.getPrimaryDisplay().workAreaSize;

    window = new BrowserWindow({
        width: width / 1.25,
        height: height / 1.25,
        webPreferences: {
            nodeIntegration: true,
            enableRemoteModule: true,
            contextIsolation: false,
        },
    });

    // if (!app.isPackaged) {
    //     window.webContents.openDevTools()
    // }
    window.setMenuBarVisibility(false)
    window.loadFile('public/index.html');


    // let win = new BrowserWindow({
    //     width: 1920,
    //     height: 1080,
    //     webPreferences: {
    //         nodeIntegration: true,
    //         enableRemoteModule: true,
    //     },
    // });

    // win.loadFile("./renderers/home.html");

    window.on("closed", () => {
        window = null;
    });
}

module.exports = createAppWindow;
