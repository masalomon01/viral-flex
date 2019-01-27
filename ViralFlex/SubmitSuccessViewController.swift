import UIKit

class SubmitSuccessViewController: UIViewController {
    
    var previousViewController: UIViewController?
    var okAction:UIAlertAction? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        previousViewController?.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func onHomeClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onNewFormClick(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Name Your Form", message: "Give a unique, pertinent name to your form. This can be changed later.", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.text = ""
            textField.addTarget(self, action: #selector(self.textFieldEditingDidChange(_:)), for: .editingChanged)
        }
        
        
        okAction = UIAlertAction(title: "Create", style: .default) { (action) in
            
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "newFormViewController") {
                
                let textField = alertController.textFields![0] as UITextField
                let form = Form(name: textField.text!)
                (controller as! NewFormViewController).form = form
                
                self.present(controller, animated: true, completion: nil)
            }
        }
        okAction?.isEnabled = false
        alertController.addAction(okAction!)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true)
    }
    
    @IBAction func textFieldEditingDidChange(_ sender: UITextField) {
        okAction?.isEnabled = sender.text!.count>0
    }
}
