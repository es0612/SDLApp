import Foundation

import SmartDeviceLink


class ProxyManager: NSObject {

    fileprivate var sdlManager: SDLManager!
    static let sharedManager = ProxyManager()

    let appName = "doNothingApp"
    let ipAddress = "m.sdl.tools"
    var port: UInt16!

    var firstHmiState: SDLHMILevel = .none
    var speedValue = "0.0"

    func connect() {
        setUp()

        sdlManager.start { (success, error) in
            if success {
                print("Connected.")
                self.sdlManager.subscribe(to: .SDLDidReceiveVehicleData,
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

            setSubscribeSpeed()
        }

        if newLevel == .full {
            updateScreen()
        }
    }
}

// MARK: - local Methods
private extension ProxyManager {
    func updateScreen() {
        sdlManager.screenManager.beginUpdates()

        setScreenTemplete()

        sdlManager.screenManager.textField1 = "speed"
        sdlManager.screenManager.textField2 = speedValue + " kph"

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

// vehicle data
extension ProxyManager {

    func setSubscribeSpeed() {
        let subscribeSpeed = SDLSubscribeVehicleData()
        subscribeSpeed.speed = true as NSNumber

        sdlManager.send(request: subscribeSpeed) { (request, response, error) in
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
        guard let onVehicleData = notification.notification as? SDLOnVehicleData,
            let speed = onVehicleData.speed
            else {
                return
        }

        speedValue = speed.stringValue
        updateScreen()
    }
}
