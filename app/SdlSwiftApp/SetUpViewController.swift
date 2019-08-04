import UIKit

class SetUpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .purple

        ProxyManager.sharedManager.connect()
    }


}

