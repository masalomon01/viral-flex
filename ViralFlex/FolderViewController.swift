import UIKit

class FolderViewController: UIViewController {
    
}

class FolderTableViewController: UITableViewController {
    
    var folders: [Folder] = []
    
    override func viewDidLoad() {
        self.tableView.separatorStyle = .none
        refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refresh()
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folders.count / 2 + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "row", for: indexPath) as! FolderTableViewCell
        
        if indexPath.row != 0 {
            cell.tag = indexPath.row * 2 - 1
            cell.folderName1.text = folders[indexPath.row * 2 - 1].name
            cell.formCount1.text = String(folders[indexPath.row * 2 - 1].formsID.count) + " forms"
            cell.options1.tag = indexPath.row * 2 - 1
            cell.options1.addTarget(self, action: #selector(FolderTableViewController.onOptionClick(_:)), for: .touchUpInside)
            
            let gesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showFolder))
            gesture.numberOfTapsRequired = 1
            cell.folderCard1.tag = indexPath.row * 2 - 1
            cell.folderCard1?.isUserInteractionEnabled = true
            cell.folderCard1?.addGestureRecognizer(gesture)
            
            cell.LayoutAdd.isHidden = true
        }
        else {
            cell.LayoutAdd.isHidden = false
            cell.buttonAdd.addTarget(self, action: #selector(onAddClick(_:)), for: .touchUpInside)
        }
        if indexPath.row * 2 < folders.count {
            cell.tag = indexPath.row * 2
            cell.folderName2.text = folders[indexPath.row * 2].name
            cell.formCount2.text = String(folders[indexPath.row * 2].formsID.count) + " forms"
            cell.options2.tag = indexPath.row * 2
            cell.options2.addTarget(self, action: #selector(FolderTableViewController.onOptionClick(_:)), for: .touchUpInside)
            
            let gesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showFolder))
            gesture.numberOfTapsRequired = 1
            cell.folderCard2.tag = indexPath.row * 2
            cell.folderCard2?.isUserInteractionEnabled = true
            cell.folderCard2?.addGestureRecognizer(gesture)
            
            cell.folderCard2.isHidden = false
        }
        else {
            cell.folderCard2.isHidden = true
        }
        
        return cell
    }
    
    func refresh() {
        
        folders = Folder.loadFolders()
        tableView.reloadData()
    }
    
    @IBAction func showFolder(_ sender: UITapGestureRecognizer) {
        
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "folderFormViewController") {
            (controller as! FolderFormViewController).folder = folders[sender.view!.tag]
            
            self.present(controller, animated: true, completion: nil)
            (controller as! FolderFormViewController).navigationBar.topItem?.title = folders[sender.view!.tag].name
        }
    }
    
    @IBAction func onAddClick(_ sender: UIButton) {
        
        let title = "Create New Folder"
        let message = "Give a unique, pertinent name to your folder. This can be changed later."
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
//            textField.addTarget(self, action: #selector(self.textFieldEditingDidChange(_:)), for: .editingChanged)
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action) in })
        alertController.addAction(UIAlertAction(title: "Create", style: .destructive) { (action) in
            
            let textField = alertController.textFields![0] as UITextField
            let folder = Folder(textField.text!)
            folder.create()
            self.refresh()
            
        })
        
        self.present(alertController, animated: true)
    }
    
    @IBAction func onOptionClick(_ sender: UIButton) {
        
        let position = sender.tag
        let folder = folders[position]
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
            
            let title = "Delete this?"
            let message = "Deleting this cannot be undone."
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default) { (action) in })
            alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { (action) in
                folder.delete()
                self.refresh()
            })
            
            self.present(alertController, animated: true)
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Make a Copy", style: .default, handler: { (action) -> Void in
        }))
        
        alertController.addAction(UIAlertAction(title: "Rename Folder", style: .default, handler: { (action) -> Void in
            
            let title = "Rename your Folder"
            let message = "Give a unique, pertinent name to your folder. This can be changed later."
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            alertController.addTextField { (textField) in
                //            textField.addTarget(self, action: #selector(self.textFieldEditingDidChange(_:)), for: .editingChanged)
            }
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action) in })
            alertController.addAction(UIAlertAction(title: "Rename", style: .destructive) { (action) in
                
                let textField = alertController.textFields![0] as UITextField
                folder.name = textField.text
                folder.saveChanges()
                self.refresh()
                
            })
            
            self.present(alertController, animated: true)
        }))
        
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in }))
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}

class FolderTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var LayoutAdd: UIView!
    @IBOutlet weak var buttonAdd: UIButton!
    @IBOutlet weak var folderCard1: UIView!
    @IBOutlet weak var folderName1: UILabel!
    @IBOutlet weak var formCount1: UILabel!
    @IBOutlet weak var options1: UIButton!
    @IBOutlet weak var folderCard2: UIView!
    @IBOutlet weak var folderName2: UILabel!
    @IBOutlet weak var formCount2: UILabel!
    @IBOutlet weak var options2: UIButton!
}
