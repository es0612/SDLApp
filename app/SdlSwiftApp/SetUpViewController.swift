import UIKit
import PureLayout

class SetUpViewController: UIViewController {
    // MARK: - Properties
    private var didSetupConstraints: Bool = false

    // MARK: - Views
    private let portTextField: UITextField
    private let connectButton: UIButton
    private let imageView: UIImageView

    // MARK: - Initialization
    init() {
        portTextField = UITextField.newAutoLayout()
        connectButton = UIButton(type: .system)
        imageView = UIImageView.newAutoLayout()

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override Methods
    override func updateViewConstraints() {
        if didSetupConstraints == false {

            portTextField
                .autoAlignAxis(toSuperviewMarginAxis: .vertical)
            portTextField
                .autoPinEdge(.bottom, to: .top, of: connectButton, withOffset: -24.0)

            connectButton.autoAlignAxis(toSuperviewMarginAxis: .horizontal)
            connectButton.autoAlignAxis(toSuperviewMarginAxis: .vertical)

            imageView.autoAlignAxis(toSuperviewMarginAxis: .vertical)
            imageView
                .autoPinEdge(.bottom, to: .top, of: portTextField, withOffset: -12.0)

            imageView.autoPinEdge(toSuperviewSafeArea: .top)


            didSetupConstraints = true
        }
        super.updateViewConstraints()
    }

    override func viewDidLoad() {
        portTextField.placeholder = "Port number"

        connectButton.setTitle("connect", for: .normal)
        connectButton.addTarget(
            self,
            action: #selector(didTapConnectButton),
            for: .touchUpInside
        )

        let carImage = UIImage(named: "car_blue")
        imageView.image = carImage


        applyStyle()

        view.addSubview(portTextField)
        view.addSubview(connectButton)
        view.addSubview(imageView)

        view.updateConstraintsIfNeeded()
    }

    func applyStyle() {
        view.backgroundColor = .white

        portTextField.textAlignment = .center
        portTextField.font = UIFont(name: portTextField.font!.fontName, size: 18)

    }

    // MARK: - Actions
    @objc func didTapConnectButton() {
        ProxyManager.sharedManager.port = UInt16(portTextField.text!)!
        ProxyManager.sharedManager.connect()
    }
}

