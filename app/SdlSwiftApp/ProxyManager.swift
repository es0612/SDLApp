import Foundation

import SmartDeviceLink

class ProxyManager: NSObject {

    fileprivate var sdlManager: SDLManager!

    // singleton
    static let sharedManager = ProxyManager()

    let appName = "doNothingApp"
    let ipAddress = "m.sdl.tools"
    var port: UInt16!

    func connect() {
        setUp()

        sdlManager.start { (success, error) in
            if success {
                print("Connected.")
            } else {
                print("Connection failed.")
            }
        }
    }

    // MARK: - local Methods
    func updateScreen() {
        sdlManager.screenManager.beginUpdates()

        setScreenTemplete()
        sdlManager.screenManager.textField1 = "喋れ！！！"

        guard let appImage = UIImage(named: "sdlicon.png") else {return}
        sdlManager.screenManager.primaryGraphic
            = SDLArtwork(
                image: appImage,
                name: "mfsdlapp.png",
                persistent: true,
                as: .PNG
        )

        sdlManager.screenManager.endUpdates { (error) in
            if error == nil {
                print("UI updated.")
            } else {
                print("UI update failed. Error: \(String(describing: error))")
            }
        }
    }

    func setScreenTemplete() {
        let display = SDLSetDisplayLayout(predefinedLayout: .textWithGraphic)

        sdlManager.send(request: display) { (request, response, error) in
            if response?.resultCode == .success {
                print("The template has been set successfully")
            }
        }
    }
}

extension ProxyManager: SDLManagerDelegate {
    func setUp() {
        let lifecycleConfiguration = SDLLifecycleConfiguration(
            appName: appName,
            fullAppId: "0001",
            ipAddress: ipAddress,
            port: port
        )

        if let appImage = UIImage(named: "sdlicon.png") {
            let appIcon = SDLArtwork(
                image: appImage,
                name: "mfsdlapp.png",
                persistent: true,
                as: .PNG
            )
            lifecycleConfiguration.appIcon = appIcon
        }

        lifecycleConfiguration.shortAppName = appName
        lifecycleConfiguration.appType = .information

        let configuration = SDLConfiguration(
            lifecycle: lifecycleConfiguration,
            lockScreen: .enabled(),
            logging: .default(),
            fileManager: .default()
        )

        sdlManager = SDLManager(
            configuration: configuration,
            delegate: self
        )
    }

    // MARK: - delegate Methods
    func managerDidDisconnect() {
        print("Manager disconnected.")
    }

    func hmiLevel(_ oldLevel: SDLHMILevel, didChangeToLevel newLevel: SDLHMILevel) {
        print("Went from HMI level:\(oldLevel) to HMI level:\(newLevel)")

        if newLevel == .full {
            updateScreen()
        }
    }
}
