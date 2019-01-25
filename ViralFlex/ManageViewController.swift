import UIKit

class ManageViewController: UIViewController {
    
    @IBOutlet weak var layoutSelection: UIView!
    @IBOutlet weak var buttonSelectAll: UIBarButtonItem!
    @IBOutlet weak var buttonCancel: UIBarButtonItem!
    
    var tableViewController: FormTableViewController!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    
    @IBAction func onBackClick(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
    }
}
