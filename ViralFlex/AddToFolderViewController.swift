import UIKit


class AddToFolderViewController: UIViewController {
    
    var folderSelectDelegate: FolderSelectDelegate!
    var tableViewController: AddToFolderTableViewController!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AddToFolderTableViewController,
            segue.identifier == "tableView" {
            self.tableViewController = vc
        }
    }
    
    @IBAction func onCancelClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onNewFolderClick(_ sender: UIButton) {
        
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
            self.tableViewController.refresh()
            
        })
        
        self.present(alertController, animated: true)
    }
}


class AddToFolderTableViewController: UITableViewController {
    
    var folders: [Folder]!
    
    override func viewDidLoad() {
        refresh()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folders.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "row", for: indexPath) as! AddToFolderTableViewCell
        
        cell.folderName.text = folders[indexPath.row].name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        parent?.dismiss(animated: true, completion: nil)
        (parent as! AddToFolderViewController).folderSelectDelegate.onFolderSelect(folder: folders[indexPath.row])
    }
    
    func refresh() {
        folders = Folder.loadFolders()
        folders.sort() { $0.name < $1.name }
        tableView.reloadData()
    }
}

class AddToFolderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var folderName: UILabel!
}

protocol FolderSelectDelegate {
    
    func onFolderSelect(folder: Folder)
}
