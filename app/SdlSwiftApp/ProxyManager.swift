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

            // 更新処理 text
            sdlManager.screenManager.textField1 = "text 1"
            sdlManager.screenManager.textField1 = "text 2"
            sdlManager.screenManager.textField1 = "text 3"
            sdlManager.screenManager.textField1 = "text 4"

            // 更新処理　ボタン
            let stateButton = setStateButton()
            sdlManager.screenManager.softButtonObjects = [stateButton]


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

    func setStateButton() -> SDLSoftButtonObject {
        let image1 = UIImage(named: "spring.png")
        let artwork1 = SDLArtwork(image: image1!, persistent: true, as: .PNG)
        let image2 = UIImage(named: "summer.png")
        let artwork2 = SDLArtwork(image: image2!, persistent: true, as: .PNG)
        let image3 = UIImage(named: "autumn.png")
        let artwork3 = SDLArtwork(image: image3!, persistent: true, as: .PNG)
        let image4 = UIImage(named: "winter.png")
        let artwork4 = SDLArtwork(image: image4!, persistent: true, as: .PNG)

        let sbState11 = SDLSoftButtonState(stateName: "State11", text: "spring", artwork: artwork1)
        let sbState12 = SDLSoftButtonState(stateName: "State12", text: "summer", artwork: artwork2)
        let sbState13 = SDLSoftButtonState(stateName: "State13", text: "autumn", artwork: artwork3)
        let sbState14 = SDLSoftButtonState(stateName: "State14", text: "winter", artwork: artwork4)

        let sbObj1 = SDLSoftButtonObject(name: "Button1", states: [sbState11, sbState12, sbState13, sbState14], initialStateName: "State11")
        {
            (buttonPress, buttonEvent) in

            guard buttonPress != nil else { return }
            print("Button 1 Pressed!")
            let sbObj = self.sdlManager.screenManager.softButtonObjectNamed("Button1")
            sbObj?.transitionToNextState()
        }

        return sbObj1
    }
}
