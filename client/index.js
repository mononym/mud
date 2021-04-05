const { app, BrowserWindow, screen } = require('electron');


if (!app.isPackaged) {
    app.commandLine.appendSwitch('ignore-certificate-errors', 'true');
    app.commandLine.appendSwitch('allow-insecure-localhost', 'true');
    require('electron-reload')(__dirname, {
        electron: require(`${__dirname}/node_modules/electron`)
    });
}


const createWindow = () => {
    const { width, height } = screen.getPrimaryDisplay().workAreaSize;
    
    window = new BrowserWindow({
        width: width / 1.25,
        height: height / 1.25,
        webPreferences: {
            nodeIntegration: true,
            enableRemoteModule: true
        },
    });

    if (!app.isPackaged) {
        window.webContents.openDevTools()
    }
    window.setMenuBarVisibility(false)
    window.loadFile('public/index.html');
};

let window = null;

app.whenReady().then(createWindow)
app.on('window-all-closed', () => app.quit());