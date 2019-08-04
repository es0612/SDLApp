import Foundation

import SmartDeviceLink

class ProxyManager: NSObject, SDLManagerDelegate {

    fileprivate var sdlManager: SDLManager!

    static let sharedManager = ProxyManager()

    private override init() {
        super.init()

        let appName = "SdlSwiftApp"

        let lifecycleConfiguration = SDLLifecycleConfiguration(
            appName: appName,
            fullAppId: "1234",
            ipAddress: "localhost",
            port: 12345
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

    func connect() {
        sdlManager.start { (success, error) in
            if success {
                print("Connected.")
            }
        }
    }


    // delegate methods
    func managerDidDisconnect() {
        print("Manager disconnected.")
    }

    func hmiLevel(_ oldLevel: SDLHMILevel, didChangeToLevel newLevel: SDLHMILevel) {
        print("Went from HMI level:\(oldLevel) to HMI level:\(newLevel)")
    }

}
