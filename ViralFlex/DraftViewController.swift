import UIKit

class DraftViewController: UIViewController, FolderSelectDelegate, ItemClickDelegate {
    
    @IBOutlet weak var checkBox: CheckBox!
    @IBOutlet weak var labelName: UIButton!
    @IBOutlet weak var labelDate: UIButton!
    
    var tableViewController: FormTableViewController!
    var selectedForm: Form?
    
    override func viewDidAppear(_ animated: Bool) {
        if tableViewController.getSelectedForms().count>0 {
            toggleSelectionMenu(visible: false)
        }
        
        let manageViewController = self.parent!.parent as! ManageViewController
        manageViewController.buttonSelectAll.target = self
        manageViewController.buttonSelectAll.action = #selector(onNavigationSelectAllClick(sender:))
        manageViewController.buttonCancel.target = self
        manageViewController.buttonCancel.action = #selector(onNavigationCancelClick(sender:))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        toggleSelectionMenu(visible: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? FormTableViewController,
            segue.identifier == "tableView" {
            self.tableViewController = vc
            self.tableViewController.type = Form.TYPE_DRAFT
            self.tableViewController.refresh()
            self.tableViewController.itemClickDelegate = self
        }
    }
    
    @IBAction func onSelectAllClick(_ sender: CheckBox) {
        
        if (sender.isSelected) {
            sender.setSelected(selected: false)
            tableViewController.deselectAll()
        }
        else {
            sender.setSelected(selected: true)
            tableViewController.selectAll()
        }
        toggleSelectionMenu(visible: !sender.isSelected)
    }
    
    @IBAction func onSortByNameClick(_ sender: UIButton) {
        tableViewController.sort(by: FormTableViewController.Field_NAME)
        if tableViewController.sorted == FormTableViewController.Field_NAME {
            if (sender.tag == 1) {
                sender.setImage(UIImage(named: "arrowUp"), for: .normal)
                sender.tag = 2
            }
            else {
                sender.setImage(UIImage(named: "arrowDownSelected"), for: .normal)
                sender.tag = 1
            }
        }
        
        labelName.setTitleColor(UIColor(red: 26/255, green: 26/255, blue: 26/255, alpha: 1.0), for: .normal)
        labelDate.tag = 0
        labelDate.setTitleColor(UIColor(red: 112/255, green: 112/255, blue: 112/255, alpha: 1.0), for: .normal)
        labelDate.setImage(UIImage(named: "arrowDownUnselected"), for: .normal)
    }
    
    @IBAction func onSortByDateClick(_ sender: UIButton) {
        tableViewController.sort(by: FormTableViewController.Field_DATE)
        if tableViewController.sorted == FormTableViewController.Field_DATE {
            if (sender.tag == 1) {
                sender.setImage(UIImage(named: "arrowUp"), for: .normal)
                sender.tag = 2
            }
            else {
                sender.setImage(UIImage(named: "arrowDownSelected"), for: .normal)
                sender.tag = 1
            }
        }
        
        
        labelDate.setTitleColor(UIColor(red: 26/255, green: 26/255, blue: 26/255, alpha: 1.0), for: .normal)
        labelName.tag = 0
        labelName.setTitleColor(UIColor(red: 112/255, green: 112/255, blue: 112/255, alpha: 1.0), for: .normal)
        labelName.setImage(UIImage(named: "arrowDownUnselected"), for: .normal)
    }
    
    
    @IBAction func onCheckBoxClick(_ sender: CheckBox) {
        toggleSelectionMenu(visible: tableViewController.getSelectedForms().count == 0)
        print(tableViewController.getSelectedForms().count)
    }
    
    @IBAction func onOptionClick(_ sender: UIButton) {
        
        let position = sender.tag
        let form = Form.getDraftForms()[position]
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
            
            let title = "Delete this?"
            let message = "Deleting this cannot be undone."
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default) { (action) in })
            alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { (action) in
                form.delete()
                self.tableViewController.refresh()
            })
            
            self.present(alertController, animated: true)
            
        }))
        
        alertController.addAction(UIAlertAction(title: "View Attachments", style: .default, handler: { (action) -> Void in }))
        
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
        
        alertController.addAction(UIAlertAction(title: "Edit Form", style: .default, handler: { (action) -> Void in
            
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "newFormViewController") {
                
                (controller as! NewFormViewController).form = form
                (controller as! NewFormViewController).edit = position
                self.present(controller, animated: true, completion: nil)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Submit", style: .default, handler: { (action) -> Void in
            
            if (form.testType != nil && form.farmName != nil && form.country != nil && form.birdType != nil && form.barCodes.count > 0) {
                
                form.submit()
                self.tableViewController.refresh()
            }
            else {
                let alert = UIAlertController(title: "Submission Error", message: "Your form has been savedin Drafts. We were unable to Submit it because not all required fields were filled.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Go to Drafts", style: .default, handler: { (action) in
                    
                    if let controller = self.storyboard?.instantiateViewController(withIdentifier: "newFormViewController") {
                        
                        (controller as! NewFormViewController).form = form
                        (controller as! NewFormViewController).edit = position
                        self.present(controller, animated: true, completion: nil)
                    }
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onSubmitClick(_ sender: Any) {
        let forms = tableViewController.getSelectedForms()
        
        var unsubmitted: String = ""
        for form in forms {
            if (form.testType == nil || form.farmName == nil || form.country == nil || form.birdType == nil || form.barCodes.count == 0) {
                unsubmitted += "\n" + form.name
            }
        }
        
        if (unsubmitted != "") {
            
            let alert = UIAlertController(title: "Submission Error", message: "We are attempting to Submit multiple Draft Forms. However, the following Forms do not have all the required fields completed:" + unsubmitted, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Next", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            for form in forms {
                form.submit()
            }
        }
        
        self.tableViewController.refresh()
        
        self.checkBox.isSelected = false
        self.tableViewController.deselectAll()
        self.toggleSelectionMenu(visible: true)
    }
    
    @IBAction func onMoveToFolderClick(_ sender: Any) {
        
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "addToFolderViewController") {
            (controller as! AddToFolderViewController).folderSelectDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func onDeleteClick(_ sender: Any) {
        
        let title = "Delete this?"
        let message = "Deleting this cannot be undone."
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default) { (action) in })
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { (action) in
            
            let forms = self.tableViewController.getSelectedForms()
            for form in forms {
                form.delete()
            }
            self.tableViewController.refresh()
            
            self.checkBox.isSelected = false
            self.tableViewController.deselectAll()
            self.toggleSelectionMenu(visible: true)
        })
        
        self.present(alertController, animated: true)
    }
    
    func onFolderSelect(folder: Folder) {
        
        var forms: [Form]
        if (selectedForm != nil) {forms = [selectedForm!]}
        else {forms = self.tableViewController.getSelectedForms()}
        
        for form in forms {
            folder.addForm(form: form)
        }
        
        checkBox.isSelected = false
        tableViewController.deselectAll()
        toggleSelectionMenu(visible: true)
    }
    
    func onItemClick(sender: FormTableViewCell, position: Int) {
        let selected = sender.checkBox.isSelected
        sender.checkBox.setSelected(selected: !selected)
        sender.checkBox.sendActions(for: .touchUpInside)
    }
    
    
    func toggleSelectionMenu(visible: Bool) {
        let manageViewController = self.parent!.parent as! ManageViewController
        manageViewController.layoutSelection.isHidden = visible
        parent!.tabBarController?.tabBar.isHidden = !visible
    }
    
    @IBAction func onNavigationSelectAllClick(sender: UITabBarItem) {
        tableViewController.selectAll()
        self.checkBox.isSelected = true
    }
    
    @IBAction func onNavigationCancelClick(sender: UITabBarItem) {
        tableViewController.deselectAll()
        self.toggleSelectionMenu(visible: true)
        self.checkBox.isSelected = false
    }
}
