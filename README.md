![CAN Monitor Banner](assets/banner.png)

# OpenCANMonitor
This application is a frontend implementation of the [PCBUSB Library](https://www.mac-can.com/). It was created as an upgrade / alternative to the demo app Mac CAN Monitor.

## Features
- Transmit CAN Messages on a timer
- Receive CAN Messagees
- Display CAN Message data in Hex, Decimal, and ASCII
- Connect to devices on any USB Bus
- Connect with all available CAN Baud Rates

## Download
To download you can use the Homebrew package manager, or download the `.dmg` from the [Latest Release](https://github.com/ActuallyTaylor/OpenCANMonitor/releases/latest/download/OpenCANMonitor.dmg)

### Homebrew
```
brew tap actuallytaylor/casks
brew install --cask open-can-monitor
```

### Latest Release
https://github.com/ActuallyTaylor/OpenCANMonitor/releases/latest/download/OpenCANMonitor.dmg

## Credits
- The PCBUSB library was created and maintained by [UV Software, Berlin](https://www.mac-can.com/). This app packages the version 0.12.1 so the user does not have to go through an install process.
- [MacCAN Monitor App](https://github.com/mac-can/PCBUSB-Monitor) was used for reference for how to use the PCBUSB library in a macOS app.