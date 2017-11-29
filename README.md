# BLE prototype apps for iOS

Workspace contains two demo projects created for testing CoreBluetooth on iOS platform.

 * Master (Central) App
 * Peripheral App (with background support)


## Testing (requires two iOS devices with enabled bluetooth)

1. Install Peripheral App on first iOS device
2. Launch Peripheral App
3. Put app in background mode by pressing home button
4. Install Master App to second iOS device
5. Launch Master App

### Repeatable steps:

6. Connect to peripheral by tapping on row with peripheral device
7. Send date by swiping left on device and clicking "Send date"
8. Alert with "Data send" should be displayed
9. Finally If peripheral application is alive and works correctly also alert with "New characteristic value" should be displayed

## Known problems
 * Peripheral App does not survive in background when user launches multiple apps and system decides that Peripheral App should be deallocated from memory. Expected behavior is that device keeps advertising and is relaunched when new BLE connection occurs


Note: You can recognize that app was deallocated from memory, by having peripheral app connected to debugger. When deallocation occurs you'll see following message in Console Output "Message from debugger: Terminated due to memory issue"



