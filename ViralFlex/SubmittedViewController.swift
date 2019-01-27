import UIKit

class SubmittedViewController: UIViewController, FolderSelectDelegate {
    
    var tableViewController: FormTableViewController!
    var selectedForm: Form?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? FormTableViewController,
            segue.identifier == "tableView" {
            self.tableViewController = vc
            self.tableViewController.type = Form.TYPE_SUBMITTED
            self.tableViewController.refresh()
        }
    }
    
    @IBAction func onOptionClick(_ sender: Any) {
        
        let position = (sender as! UIButton).tag
        let form = Form.getSubmittedForms()[position]
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Move to Folder", style: .default, handler: { (action) -> Void in
            
            self.selectedForm = form
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "addToFolderViewController") {
                (controller as! AddToFolderViewController).folderSelectDelegate = self
                self.present(controller, animated: true, completion: nil)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Make a Copy", style: .default, handler: { (action) -> Void in
            
            let alertController = UIAlertController(title: "Name Your Form", message: "Give a unique, pertinent name to your form. This can be chaned later.", preferredStyle: .alert)
            
            alertController.addTextField { (textField) in
                textField.text = form.name
                //                textField.addTarget(self, action: #selector(self.textFieldEditingDidChange(_:)), for: .editingChanged)
            }
            
            //alertController.addAction(UIAlertAction(title: "View Form", style: .default, handler: { (action) -> Void in }))
            
            alertController.addAction(UIAlertAction(title: "Create", style: .default) { (action) in
                
                if let controller = self.storyboard?.instantiateViewController(withIdentifier: "newFormViewController") {
                    
                    let textField = alertController.textFields![0] as UITextField
                    
                    let newForm = form.copy() as! Form
                    newForm.status = Form.STATUS_NEW
                    newForm.name = textField.text!
                    
                    
                    (controller as! NewFormViewController).form = newForm
                    self.present(controller, animated: true, completion: nil)
                }
            })
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action) in })
            self.present(alertController, animated: true)
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func onFolderSelect(folder: Folder) {
        folder.addForm(form: selectedForm!)
        folder.saveChanges()
    }
}
