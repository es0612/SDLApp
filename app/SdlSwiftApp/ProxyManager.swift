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
        let port: UInt16 = 15451

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
            // UIImageからSDL標準のSDLArtworkに変換
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

        // 画面の更新はlevelがfullの時に行う
        if newLevel == .full {
            // アプリから車載機の画面アップデートする際に必須
            sdlManager.screenManager.beginUpdates()

            //更新処理
            sdlManager.screenManager.textField1 = "text 1"
            sdlManager.screenManager.textField1 = "text 2"
            sdlManager.screenManager.textField1 = "text 3"
            sdlManager.screenManager.textField1 = "text 4"

            // アプリから車載機の画面アップデートする際に必須
            sdlManager.screenManager.endUpdates { (error) in
                if error == nil {
                    print("UI updated.")
                } else {
                    print("UI update failed. Error: \(String(describing: error))")
                }
            }
        }
    }
}
