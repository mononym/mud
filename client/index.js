const { app, BrowserWindow, screen } = require('electron');


if (!app.isPackaged) {
    // app.commandLine.appendSwitch('ignore-certificate-errors', 'true');
    // app.commandLine.appendSwitch('allow-insecure-localhost', 'true');
    require('electron-reload')(__dirname, {
        electron: require(`${__dirname}/node_modules/electron`)
    });
}

app.userAgentFallback = 'Chrome'//app.userAgentFallback.replace('Electron/' + process.versions.electron, '')


// const createWindow = () => {
//     const { width, height } = screen.getPrimaryDisplay().workAreaSize;

//     window = new BrowserWindow({
//         width: width / 1.25,
//         height: height / 1.25,
//         webPreferences: {
//             nodeIntegration: true,
//             enableRemoteModule: true,
//             contextIsolation: false,
//         },
//     });

//     if (!app.isPackaged) {
//         window.webContents.openDevTools()
//     }
//     window.setMenuBarVisibility(false)
//     window.loadFile('public/index.html');
// };

// let window = null;

// app.whenReady().then(createWindow)
// app.on('window-all-closed', () => app.quit());





// const {app} = require('electron');

const {createAuthWindow} = require('./main/auth-process');
const createAppWindow = require('./main/app-process');
const authService = require('./services/auth-service');

async function showWindow() {
  try {
    await authService.refreshTokens();
    return createAppWindow();
  } catch (err) {
    createAuthWindow();
  }
}

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.whenReady().then(showWindow)

// Quit when all windows are closed.
app.on('window-all-closed', () => {
  app.quit();
});