import Foundation

import SmartDeviceLink

class ProxyManager: NSObject, SDLManagerDelegate {

    fileprivate var sdlManager: SDLManager!

    static let sharedManager = ProxyManager()

    private override init() {
        super.init()

        let appName = "SdlSwiftApp"

        // for web emulator
        let ipAddress = "m.sdl.tools"
        let port: UInt16 = 16860

        // for docker emulator
        //        let ipAddress = "localhost"
        //        let port: UInt16 = 12345

        let lifecycleConfiguration = SDLLifecycleConfiguration(
            appName: appName,
            fullAppId: "1234",
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
