import UIKit

class MyTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        self.delegate = self
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        let childsVc = tabBarController.viewControllers! as NSArray
        let selectedIndex : Int = childsVc.index(of: viewController)
        
        
        if selectedIndex==2 || selectedIndex==3 {
            popup(selectedIndex: selectedIndex)
            return false
        }
        return true
    }
    
    
    
    var okAction:UIAlertAction? = nil
    @IBAction func textFieldEditingDidChange(_ sender: UITextField) {
        okAction?.isEnabled = sender.text!.count>0
    }
    
    
    func popup(selectedIndex: Int) {
        
        let value = selectedIndex == 2
        
        let title = value ? "Name Your Form":"First, Name Your Form"
        let message = value ? "Give a unique, pertinent name to your form. This can be changed later.":"You must create a form for your barcodes to be attached to."
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.text = ""
            textField.addTarget(self, action: #selector(self.textFieldEditingDidChange(_:)), for: .editingChanged)
        }
        
        let okText = value ? "Create":"Create & Scan"
        
        okAction = UIAlertAction(title: okText, style: .default) { (action) in
            self.selectedIndex = 0
            
            let controllerID = value ? "newFormViewController" : "scanViewController"
            
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: controllerID) {
                
                let textField = alertController.textFields![0] as UITextField
                let form = Form(name: textField.text!)
                if selectedIndex == 2 {(controller as! NewFormViewController).form = form}
                else {
                    (controller as! ScanViewController).previousViewController = self
                    (controller as! ScanViewController).form = form
                }
                
                self.present(controller, animated: true, completion: nil)
            }
        }
        okAction?.isEnabled = false
        alertController.addAction(okAction!)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true)
    }
}
