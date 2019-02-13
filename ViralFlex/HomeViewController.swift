import UIKit

class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) { }
    
    @IBAction func onManageClicked(_ sender: Any) {
        self.tabBarController!.selectedIndex = 1
    }
    
    @IBAction func onNewFormClicked(_ sender: Any) {
        (tabBarController as! MyTabBarController).popup(selectedIndex: 2)
    }
}
