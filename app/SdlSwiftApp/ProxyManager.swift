import Foundation

import SmartDeviceLink


class ProxyManager: NSObject {

    fileprivate var sdlManager: SDLManager!
    static let sharedManager = ProxyManager()

    let appName = "hungryApp"
    let ipAddress = "m.sdl.tools"
    var port: UInt16!
//        let ipAddress = "10.0.0.1"
//        var port = "12345"

    var firstHmiState: SDLHMILevel = .none

    var fuelLevelValue = 100.0
    let hungryMessage = "ぐぅううう。お腹が減ったよぉ。"

    let laughImage = UIImage(named: "laugh")
    let smileImage = UIImage(named: "smile")
    let angryImage = UIImage(named: "angry")
    let cryImage = UIImage(named: "cry")


    var updateScreenTimer: Timer?
    var actionStatus: Int = 0
    var resetStatus: Int = 0

    var speedValue = "0"
    var amuro1 = UIImage(named: "amuroIkimasu")
    var amuro2 = UIImage(named: "amuroikimasu2")


    var actionStatus2: Int = 0
    var resetStatus2: Int = 0

    var carImage = UIImage(named: "car_blue")

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

        if let appImage = UIImage(named: "gasoline") {
            let appIcon = SDLArtwork(
                image: appImage,
                name: "gasoline",
                persistent: true,
                as: .PNG
            )
            lifecycleConfiguration.appIcon = appIcon
        }

        lifecycleConfiguration.shortAppName = appName
        lifecycleConfiguration.appType = .information

        let lockScreenConfiguration = SDLLockScreenConfiguration.enabledConfiguration(withAppIcon: carImage!, backgroundColor: .white)
        lockScreenConfiguration.showInOptionalState = true

        let configuration = SDLConfiguration(
            lifecycle: lifecycleConfiguration,
            lockScreen: lockScreenConfiguration,
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
            setSubscribeSpeed()
        }

        if newLevel == .full {
            setHungryScreen()
            startUpdateTimer()
        }
    }
}

// MARK: - local Methods -> screen
private extension ProxyManager {
    func setHungryScreen() {
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
            appImage = cryImage
            sdlManager.screenManager.textField3 = hungryMessage
            sendVoice(hungryMessage)
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

    func setScreenTempleteForCar() {
        let display = SDLSetDisplayLayout(predefinedLayout: .graphicWithText)

        sdlManager.send(request: display) { (request, response, error) in
            if response?.resultCode == .success {
                print("The template has been set successfully")
            }
        }
    }

    func setAmuroScreen() {
        sdlManager.screenManager.beginUpdates()

        setScreenTemplete()

        sdlManager.screenManager.textField1 = "いつでも行けます！！"
        sdlManager.screenManager.textField2 = speedValue + " km/h"
        sdlManager.screenManager.textField3 = ""

        var appImage: UIImage? = nil

        if speedValue == "0" {
            appImage = amuro1
            sendVoice("いつでも行けます")
        } else {
            appImage = amuro2
            sdlManager.screenManager.textField1 = "いきまあああす！！"
            sendVoice("アムロいっきまぁああす！！")
        }

        sdlManager.screenManager.primaryGraphic
            = SDLArtwork(
                image: appImage!,
                persistent: true,
                as: .JPG
        )

        sdlManager.screenManager.endUpdates { (error) in
            if error == nil {
                print("UI updated.")
            } else {
                print("UI update failed. Error: \(String(describing: error))")
            }
        }
    }

    func setCarScreen() {
        sdlManager.screenManager.beginUpdates()

        setScreenTempleteForCar()

        var appImage: UIImage? = nil
        appImage = carImage
        sendVoice("ワシにまかせろ")

        sdlManager.screenManager.primaryGraphic
            = SDLArtwork(
                image: appImage!,
                persistent: true,
                as: .PNG
        )

        sdlManager.screenManager.textField1 = "ワシにまかせろ"
        sdlManager.screenManager.textField2 = ""
        sdlManager.screenManager.textField3 = ""

        sdlManager.screenManager.endUpdates { (error) in
            if error == nil {
                print("UI updated.")
            } else {
                print("UI update failed. Error: \(String(describing: error))")
            }
        }
    }

    func setCarScreen2() {
        sdlManager.screenManager.beginUpdates()

        let randomValue = Int.random(in: 0..<5)

        if randomValue == 0 {
            sdlManager.screenManager.textField1 = "今日のマラソン大会見た？"
            sendVoice("今日のマラソン大会見た？")
        } else if randomValue == 1 {
            sdlManager.screenManager.textField1 = "最近の煽り運転ひどいよねぇ"
            sendVoice("最近の煽り運転ひどいよねぇ")
        } else if randomValue == 2 {
            sdlManager.screenManager.textField1 = "消費税の増税についてどう思う？"
            sendVoice("消費税の増税についてどう思う？")
        } else if randomValue == 3 {
            sdlManager.screenManager.textField1 = "ワシはタピオカミルクティーが飲みたい"
            sendVoice("ワシはタピオカミルクティーが飲みたい")
        } else if randomValue == 4 {
            sdlManager.screenManager.textField1 = "ワシはタピオカミルクティーが飲みたい"
            sendVoice("ワシはタピオカミルクティーが飲みたい")
        }

        sdlManager.screenManager.textField2 = ""
        sdlManager.screenManager.textField3 = ""

        sdlManager.screenManager.endUpdates { (error) in
            if error == nil {
                print("UI updated.")
            } else {
                print("UI update failed. Error: \(String(describing: error))")
            }
        }
    }
}

// MARK: - local Methods -> vehicle data
private extension ProxyManager {
    @objc func vehicleDataNotification(_ notification: SDLRPCNotificationNotification) {
        guard let onVehicleData = notification.notification as? SDLOnVehicleData else { return }

        if let fuel = onVehicleData.fuelLevel  {
            fuelLevelValue = fuel.doubleValue

            setHungryScreen()
        }

        if let speed = onVehicleData.speed {
            speedValue = speed.stringValue
            setAmuroScreen()
        }

    }

    func checkAngleAction(_ data: Double) {

        print("-------------angle-------------")
        print(data)
        print(actionStatus)
        print(resetStatus)

        resetStatus += 1
        if resetStatus > 10 {
            actionStatus = 0
            resetStatus = 0
            return
        }

        if data > 100 && actionStatus == 0 {
            resetStatus = 0
            actionStatus = 1
        } else if data < -100 && actionStatus == 1 {
            resetStatus = 0
            actionStatus = 2
        } else if data > 100 && actionStatus == 2 {
            resetStatus = 0
            actionStatus = 3
        } else if data < -100 && actionStatus == 3 {
            resetStatus = 0
            actionStatus = 4
        } else if actionStatus == 4 {
            actionStatus = 0
            resetStatus = 0

            setCarScreen()
            sleep(6)
            setCarScreen2()
            print("success")

        }
    }

    func checkPedalAction(_ data: Double) {

        print("-------------pedal-------------")
        print(data)
        print(actionStatus2)
        print(resetStatus2)

        resetStatus2 += 1
        if resetStatus2 > 10 {
            actionStatus2 = 0
            resetStatus2 = 0
            return
        }

        if data > 10 && actionStatus2 == 0 {
            resetStatus2 = 0
            actionStatus2 = 1
        } else if data < 10 && actionStatus2 == 1 {
            resetStatus2 = 0
            actionStatus2 = 2
        } else if data > 10 && actionStatus2 == 2 {
            resetStatus2 = 0
            actionStatus2 = 3
        } else if data < 10 && actionStatus2 == 3 {
            resetStatus2 = 0
            actionStatus2 = 4
        } else if actionStatus2 == 4 {
            actionStatus2 = 0
            resetStatus2 = 0

            setAmuroScreen()
            print("success")
        }
    }


    func startUpdateTimer() {

        DispatchQueue.main.async {
            self.updateScreenTimer = Timer.scheduledTimer(
                timeInterval: 1,
                target: self,
                selector: #selector(ProxyManager.timerUpdate),
                userInfo: nil,
                repeats: true
            )
            self.updateScreenTimer?.fire()
        }
    }

    @objc func timerUpdate() {
        getSteeringWheelAngleData()
        getAccPedalPositionData()
    }
}

// MARK: - local Methods -> speech
private extension ProxyManager {
    func sendVoice(_ text: String) {
        sdlManager.send(request: SDLSpeak(tts: text), responseHandler:
            {(_, response, error) in
                guard response?.resultCode == .success else { return }

        })
    }
}

extension ProxyManager {
    func getSteeringWheelAngleData() {
        let vehicleData = SDLGetVehicleData()
        vehicleData.steeringWheelAngle = true as NSNumber

        sdlManager.send(request: vehicleData) { (request, response, error) in
            guard let response = response as? SDLGetVehicleDataResponse else { return }
            guard response.resultCode == .success else { switch response.resultCode {
            case .disallowed:
                print("diallowd.")
            case .rejected:
                print("rejected.")
            default:
                print("some erroe is occured.")
                }
                return
            }

            guard let steeringWheelAngleData = response.steeringWheelAngle else { return }

            self.checkAngleAction(steeringWheelAngleData.doubleValue)

        }
    }

    func getAccPedalPositionData() {
        let vehicleData = SDLGetVehicleData()
        vehicleData.accPedalPosition = true as NSNumber

        sdlManager.send(request: vehicleData) { (request, response, error) in
            guard let response = response as? SDLGetVehicleDataResponse else { return }
            guard response.resultCode == .success else { switch response.resultCode {
            case .disallowed:
                print("diallowd.")
            case .rejected:
                print("rejected.")
            default:
                print("some erroe is occured.")
                }
                return
            }

            guard let accPedalPositionData = response.accPedalPosition else { return }

            self.checkPedalAction(accPedalPositionData.doubleValue)
        }
    }
}

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
                        print("diallowd.")
                    case .rejected:
                        print("rejected.")
                    default:
                        print("some erroe is occured.")
                    }
                    return
            }
        }
    }

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
                        print("diallowd.")
                    case .rejected:
                        print("rejected.")
                    default:
                        print("some erroe is occured.")
                    }
                    return
            }
        }
    }
}

