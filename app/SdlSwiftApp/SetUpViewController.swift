import UIKit
import PureLayout

class SetUpViewController: UIViewController {
    // MARK: - Properties
    private var didSetupConstraints: Bool = false

    // MARK: - Views
    private let portTextField: UITextField
    private let connectButton: UIButton

    // MARK: - Initialization
    init() {
        portTextField = UITextField.newAutoLayout()
        connectButton = UIButton(type: .system)

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
                .autoAlignAxis(toSuperviewMarginAxis: .horizontal)

            connectButton.autoPinEdge(.top, to: .bottom, of: portTextField, withOffset: 6.0)
            connectButton.autoAlignAxis(toSuperviewMarginAxis: .vertical)

            didSetupConstraints = true
        }
        super.updateViewConstraints()
    }

    override func viewDidLoad() {

        view.backgroundColor = .white

        portTextField.placeholder = "Port numberr"

        connectButton.setTitle("connect", for: .normal)
        connectButton.addTarget(
            self, action: #selector(didTapConnectButton), for: .touchUpInside
        )

        view.addSubview(portTextField)
        view.addSubview(connectButton)

        view.updateConstraintsIfNeeded()
    }

    // MARK: - Actions
    @objc func didTapConnectButton() {
        ProxyManager.sharedManager.port = UInt16(portTextField.text!)!
        ProxyManager.sharedManager.connect()
    }
}

