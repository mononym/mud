const { app, BrowserWindow, screen } = require('electron');

app.commandLine.appendSwitch('ignore-certificate-errors', 'true');
app.commandLine.appendSwitch('allow-insecure-localhost', 'true');
require('electron-reload')(__dirname, {
    electron: require(`${__dirname}/node_modules/electron`)
});

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

    window.webContents.openDevTools()
    window.loadFile('public/index.html');
};

let window = null;

app.whenReady().then(createWindow)
app.on('window-all-closed', () => app.quit());