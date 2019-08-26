import Foundation

import SmartDeviceLink

class ProxyManager: NSObject, SDLManagerDelegate {

    fileprivate var sdlManager: SDLManager!

    // singleton
    static let sharedManager = ProxyManager()

    let appName = "SdlSwiftApp"

    let ipAddress = "m.sdl.tools"
    var port: UInt16!

    private override init() {
        super.init()
    }

    func setUp() {
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
        setUp()

        sdlManager.start { (success, error) in
            if success {
                print("Connected.")
            } else {
                print("Connection failed.")
            }
        }
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
            sdlManager.screenManager.textField1 = "This app is sample"
            //            sdlManager.screenManager.textField1 = "text 2"
            //            sdlManager.screenManager.textField1 = "text 3"
            //            sdlManager.screenManager.textField1 = "text 4"

            // 更新処理　ボタン
            let stateButton = setStateButton()
            let alertButton = setAlertButton()
            sdlManager.screenManager.softButtonObjects = [stateButton, alertButton]

            // 更新処理　ハンバーガーメニュー
            self.sdlManager.screenManager.menu = [setMenuItem1(), setMenuItem2()]

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

    func setAlertButton() -> SDLSoftButtonObject {
        let image = UIImage(named: "sdlicon.png")
        let artwork = SDLArtwork(image: image!, persistent: true, as: .PNG)
        let sbState21 = SDLSoftButtonState(stateName: "State21", text: "alert", artwork: artwork)
        let sbObj2
            = SDLSoftButtonObject(name: "Button2", states: [sbState21], initialStateName: "State21")
            {
                (buttonPress, buttonEvent) in
                guard buttonPress != nil else { return }
                print("Button 2 Pressed!")

                let alert = SDLAlert(
                    alertText1: "Cancel Button Pushed",
                    alertText2: "Wait for 5 Sec to dismiss",
                    alertText3: "..."
                )

                // ５秒でアラートを閉じる
                alert.duration = 5000 as NSNumber & SDLInt
                self.sdlManager.send(request: alert) { (request, response, error) in
                    if response?.resultCode == .success { }

                }
        }

        return sbObj2
    }

    func setMenuItem1() -> SDLMenuCell {
        let cell00 = SDLMenuCell(title: "Menu Item without Submenu", icon: nil, voiceCommands: nil)
        { (triggerSource: SDLTriggerSource) in
            print("First Menu Item Selected: \(triggerSource)")
        }

        return cell00
    }

    func setMenuItem2() -> SDLMenuCell {
        let cell10 = SDLMenuCell(title: "Submenu Item A", icon: nil, voiceCommands: nil)
        { (triggerSource: SDLTriggerSource) in
            print("Submenu Item A Selected: \(triggerSource)")
        }

        let cell11 = SDLMenuCell(title: "Submenu Item B", icon: nil, voiceCommands: nil)
        { (triggerSource: SDLTriggerSource) in
            print("Submenu Item B Selected: \(triggerSource)")
        }

        let cell01 = SDLMenuCell(title: "Menu Item with Submenu", icon: nil, subCells:[cell10, cell11])

        return cell01
    }

    func setScreenTemplete() {
        let display = SDLSetDisplayLayout(predefinedLayout: .media)

        sdlManager.send(request: display) { (request, response, error) in
            if response?.resultCode == .success {
                print("The template has been set successfully")
            }
        }
    }
}
