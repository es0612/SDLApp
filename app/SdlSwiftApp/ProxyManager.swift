import Foundation

import SmartDeviceLink

class ProxyManager: NSObject, SDLManagerDelegate {

    fileprivate var sdlManager: SDLManager!

    // singleton
    static let sharedManager = ProxyManager()

    let appName = "SdlSwiftApp"
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

    func setUp() {
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

    // MARK: - delegate Methods
    func managerDidDisconnect() {
        print("Manager disconnected.")
    }

    func hmiLevel(_ oldLevel: SDLHMILevel, didChangeToLevel newLevel: SDLHMILevel) {
        print("Went from HMI level:\(oldLevel) to HMI level:\(newLevel)")

        // 画面の更新はlevelがfullの時に行う
        if newLevel == .full {
            // アプリから車載機の画面アップデートする際に必須
            sdlManager.screenManager.beginUpdates()

            // 画面テンプレート　変更
            setScreenTemplete()

            // 更新処理 text
            sdlManager.screenManager.textField1 = "喋れ！！！"

            // 画像更新
            guard let appImage = UIImage(named: "sdlicon.png") else {return}
            sdlManager.screenManager.primaryGraphic
                = SDLArtwork(
                    image: appImage,
                    name: "mfsdlapp.png",
                    persistent: true,
                    as: .PNG
            )

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

    // MARK: - local Methods
    func setScreenTemplete() {
        let display = SDLSetDisplayLayout(predefinedLayout: .textWithGraphic)

        sdlManager.send(request: display) { (request, response, error) in
            if response?.resultCode == .success {
                print("The template has been set successfully")
            }
        }
    }
}
