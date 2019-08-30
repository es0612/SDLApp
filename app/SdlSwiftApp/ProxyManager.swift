import Foundation

import SmartDeviceLink


class ProxyManager: NSObject {

    fileprivate var sdlManager: SDLManager!
    static let sharedManager = ProxyManager()

    let appName = "hungryApp"
    let ipAddress = "m.sdl.tools"
    var port: UInt16!

    var firstHmiState: SDLHMILevel = .none

    var fuelLevelValue = 100.0
    let hungryMessage = "ぐぅううう。お腹が減ったよぉ。"

    let laughImage = UIImage(named: "laugh")
    let smileImage = UIImage(named: "smile")
    let angryImage = UIImage(named: "angry")
    let crtImage = UIImage(named: "cry")


    func connect() {
        setUp()

        sdlManager.start { (success, error) in
            if success {
                print("Connected.")

                self.sdlManager.subscribe(
                    to: .SDLDidReceiveVehicleData,
                    observer: self,
                    selector: #selector(self.vehicleDataNotification(_:))
                )
            } else {
                print("Connection failed.")
            }
        }
    }
}

// MARK: - delegate Methods
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

    func managerDidDisconnect() {
        print("Manager disconnected.")
    }

    func hmiLevel(_ oldLevel: SDLHMILevel, didChangeToLevel newLevel: SDLHMILevel) {

        if newLevel != .none && firstHmiState == .none {
            firstHmiState = newLevel

            setSubscribeFuelLevel()
        }

        if newLevel == .full {
            updateScreen()
        }
    }
}

// MARK: - local Methods -> screen
private extension ProxyManager {
    func updateScreen() {
        sdlManager.screenManager.beginUpdates()

        setScreenTemplete()

        sdlManager.screenManager.textField1 = "remaining fuel."
        sdlManager.screenManager.textField2 = String(fuelLevelValue) + " %"
        sdlManager.screenManager.textField3 = ""

        var appImage: UIImage? = nil

        if fuelLevelValue > 80 {
            appImage = laughImage
        } else if fuelLevelValue > 60 {
            appImage = smileImage
        } else if fuelLevelValue > 20 {
            appImage = angryImage
        } else {
            appImage = crtImage
            sdlManager.screenManager.textField3 = hungryMessage
        }

        sdlManager.screenManager.primaryGraphic
            = SDLArtwork(
                image: appImage!,
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

// MARK: - local Methods -> vehicle data
private extension ProxyManager {

    func setSubscribeFuelLevel() {
        let subscribeData = SDLSubscribeVehicleData()
        subscribeData.fuelLevel = true as NSNumber

        sdlManager.send(request: subscribeData) { (request, response, error) in
            guard let response = response as? SDLSubscribeVehicleDataResponse else { return }
            guard response.resultCode == .success
                else {
                    switch response.resultCode
                    {
                    case .disallowed:
                        print("disallowd")
                    default:
                        print("default")
                    }
                    return
            }
        }
    }

    @objc func vehicleDataNotification(_ notification: SDLRPCNotificationNotification) {
        guard
            let onVehicleData = notification.notification as? SDLOnVehicleData,
            let fuel = onVehicleData.fuelLevel
            else { return }

        fuelLevelValue = fuel.doubleValue
        
        updateScreen()
        sendVoice()
    }
}

// MARK: - local Methods -> speech
private extension ProxyManager {
    func sendVoice() {
        if fuelLevelValue < 20.0 {
            sdlManager.send(request: SDLSpeak(tts: hungryMessage), responseHandler:
                {(_, response, error) in
                    guard response?.resultCode == .success else { return }

            })
        }
    }
}
