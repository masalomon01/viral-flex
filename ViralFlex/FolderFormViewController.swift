import UIKit

class FolderFormViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITabBarDelegate, FolderSelectDelegate, SubmitDialogDelegate {
    
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var checkBox: CheckBox!
    @IBOutlet weak var selectionNavigation: UIView!
    @IBOutlet weak var buttonMenu: UIView!
    
    
    var folder: Folder!
    var forms: [Form]!
    var type = "draft"
    
    var selectedForm: Form?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        
        super.viewWillLayoutSubviews()
        
        let tabBar = self.tabBar!
        let color = UIColor(red: 31/255, green: 32/255, blue: 107/255, alpha: 1)
        tabBar.selectionIndicatorImage = UIImage().createSelectionIndicator(color: color, size: CGSize(width: tabBar.frame.width/CGFloat(tabBar.items!.count), height: tabBar.frame.height), lineHeight: 5.0)
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 14)!], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 14)!], for: .selected)
        
        
        forms = folder.getForms(type: type)
        tabBar.selectedItem = tabBar.items![0]
        
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        self.tabBar.invalidateIntrinsicContentSize();
        let tabSize: CGFloat = 50.0
        
        var tabFrame = self.tabBar.frame;
        tabFrame.size.height = tabSize;
        tabFrame.origin.y = self.view.frame.origin.y;
        self.tabBar.frame = tabFrame;
        self.tabBar.isTranslucent = false;
        self.tabBar.isTranslucent = true;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folder.getForms(type: type).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let form = forms[indexPath.row]
        selectedForm = form
        let cell = tableView.dequeueReusableCell(withIdentifier: "row", for: indexPath) as! FolderFormTableViewCell
        cell.label.text = form.name
        
        cell.barcodeCount.text = String(form.barCodes.count)
        cell.pictureCount.text = String(form.pictures.count)
        
        cell.options.addTarget(self, action: #selector(onOptionClick), for: .touchUpInside)
        cell.options.isHidden = (type == "submitted")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mma\nMM-dd-yy"
        if (form.createTime != nil) {cell.time.text = dateFormatter.string(from: form.createTime!).lowercased()}
        
        cell.checkBox.tag = indexPath.row
        cell.checkBox.addTarget(parent, action: #selector(FolderFormViewController.onCheckBoxClick(_:)), for: .touchUpInside)
        cell.checkBox.isHidden = (type == "submitted")
        
        cell.tag = indexPath.row
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onItemClick)))
        
        return cell
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if tabBar.items?.firstIndex(of: item) == 0 {
            type = "draft"
            checkBox.isHidden = false
        }
        else {
            type = "submitted"
            checkBox.isHidden = true
        }
        forms = folder.getForms(type: type)
        tableView.reloadData()
    }
    
    func getSelectedForms() -> [Form] {
        
        let array = NSMutableArray()
        for (index, cell) in tableView.visibleCells.enumerated() {
            if (cell as! FolderFormTableViewCell).checkBox.isSelected {array.add(forms[index])}
        }
        return array.copy() as! [Form]
    }
    
    @IBAction func onBackClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDoneClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSelectAllClick(_ sender: Any) {
        checkBox.isSelected = false
        onHeaderCheckBoxClick(checkBox)
    }
    @IBAction func onCancelClick(_ sender: Any) {
        checkBox.isSelected = true
        onHeaderCheckBoxClick(checkBox)
    }
    @IBAction func onHeaderCheckBoxClick(_ sender: CheckBox) {
        if (sender.isSelected) {
            sender.setSelected(selected: false)
            for cell in tableView.visibleCells {
                (cell as! FolderFormTableViewCell).checkBox.isSelected = false
            }
        }
        else {
            sender.setSelected(selected: true)
            for cell in tableView.visibleCells {
                (cell as! FolderFormTableViewCell).checkBox.isSelected = true
            }
        }
        selectedForm = nil
        
        selectionNavigation.isHidden = getSelectedForms().count == 0
        buttonMenu.isHidden = getSelectedForms().count == 0
    }
    
    @IBAction func onSubmitClick(_ sender: Any) {
        
        let forms = getSelectedForms()
        
        var unsubmitted: String = ""
        for form in forms {
            if (form.testType == nil || form.farmName == nil || form.country == nil || form.birdType == nil || form.barCodes.count == 0) {
                unsubmitted += "\n" + form.name
            }
        }
        
        if (unsubmitted != "") {
            
            let alert = UIAlertController(title: "Submission Error", message: "You are attempting to Submit multiple Draft Forms. However, the following Forms do not have all the required fields completed:" + unsubmitted, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            //alert.addAction(UIAlertAction(title: "Next", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            var formNames: String = ""
            for form in forms {
                if formNames.isEmpty {
                    formNames = form.name
                } else {
                    formNames += ", \(form.name)"
                }
            }
            let dialog = SubmitDialog()
            dialog.delegate = self
            dialog.setup()
            dialog.show()
            dialog.formName.text = formNames
        }
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
            
            let forms = self.getSelectedForms()
            for form in forms {
                self.folder.removeForm(form: form)
                form.delete()
            }
            
            self.tableView.reloadData()
            
            self.checkBox.isSelected = true
            self.onHeaderCheckBoxClick(self.checkBox)
        })
        
        self.present(alertController, animated: true)
    }
    
    @IBAction func onItemClick(_ sender: UITapGestureRecognizer) {
        
        if type == "draft" {
            onCheckBoxClick((sender.view as! FolderFormTableViewCell).checkBox)
        }
        else {
            let form = forms[(sender.view as! FolderFormTableViewCell).tag]
            
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "newFormViewController") {
                (controller as! NewFormViewController).form = form
                (controller as! NewFormViewController).viewMode = true
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func onCheckBoxClick(_ sender: CheckBox) {
//        toggleSelectionMenu(visible: tableViewController.getSelectedForms().count == 0)
        sender.setSelected(selected: !sender.isSelected)
        
        selectionNavigation.isHidden = getSelectedForms().count == 0
        buttonMenu.isHidden = getSelectedForms().count == 0
    }
    
    
    @IBAction func onOptionClick(_ sender: UIButton) {
        
        let position = sender.superview!.superview!.tag
        let form = Form.getDraftForms()[position]
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if type == "draft" {
            alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
                
                let title = "Delete this?"
                let message = "Deleting this cannot be undone."
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "Cancel", style: .default) { (action) in })
                alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { (action) in
                    form.delete()
                    self.tableView.reloadData()
                })
                
                self.present(alertController, animated: true)
                
            }))
        }
        
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
        
        if type == "draft" {
            alertController.addAction(UIAlertAction(title: "Edit Form", style: .default, handler: { (action) -> Void in
                
                if let controller = self.storyboard?.instantiateViewController(withIdentifier: "newFormViewController") {
                    
                    (controller as! NewFormViewController).form = form
                    (controller as! NewFormViewController).edit = position
                    self.present(controller, animated: true, completion: nil)
                }
            }))
        }
        
//        self.tableView.reloadData()
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in }))
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func onFolderSelect(folder: Folder) {
        
        var forms: [Form]
        if (selectedForm != nil) {forms = [selectedForm!]}
        else {forms = self.getSelectedForms()}
        
        for form in forms {
            folder.addForm(form: form)
        }
        tableView.reloadData()
        
        checkBox.isSelected = true
        onHeaderCheckBoxClick(checkBox)
    }
    
    func onSubmit(dialog: SubmitDialog, pin: Int) {
        
        self.tableView.reloadData()
        
        self.checkBox.isSelected = true
        self.onHeaderCheckBoxClick(self.checkBox)
    }
}

class FolderFormTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var checkBox: CheckBox!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var pictureCount: UILabel!
    @IBOutlet weak var barcodeCount: UILabel!
    @IBOutlet weak var options: UIButton!
}
