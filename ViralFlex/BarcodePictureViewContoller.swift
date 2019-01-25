import UIKit

class BarcodePictureViewController: UIViewController, UITableViewDataSource, UITabBarDelegate {
    
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var tableHeader: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var layoutPreview: UIView!
    @IBOutlet weak var imagePreview: UIImageView!
    
    
    var type: Int = 0
    var form: Form!
    var selectedPicture: Int?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        
        tabBar.addIndicator()
        navigationBar.topItem?.title = form.name
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
    }
    
    @IBAction func onBackClick(_ sender: Any) {
        
        if layoutPreview.isHidden == false {
            layoutPreview.isHidden = true
        }
        else {dismiss(animated: true, completion: nil)}
    }
    
    @IBAction func onDeleteClick(_ sender: Any) {
        
        let title = "Delete this?"
        let message = "Deleting this cannot be undone."
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default) { (action) in })
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive) { (action) in
            
            self.layoutPreview.isHidden = true
            self.form.pictures.remove(at: self.selectedPicture!)
            self.tableView.reloadData()
        })
        
        self.present(alertController, animated: true)
    }
    
    @IBAction func onShareClick(_ sender: Any) {
        
    }
    
    @IBAction func onImageItemClick(_ sender: UITapGestureRecognizer) {
        
        selectedPicture = sender.view!.tag
        layoutPreview.isHidden = false
        imagePreview.image = UIImage(contentsOfFile: form.pictures[sender.view!.tag])
    }
    
    
    
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if (tabBar.items?.firstIndex(of: item) == 0) {
            type = 0
            tableHeader.isHidden = false
        }
        else {
            type = 1
            tableHeader.isHidden = true
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return type == 0 ? form.barCodes.count:((form.pictures.count + 3) / 4)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: BarcodePicktureTableCell
        if (type == 0) {
            cell = tableView.dequeueReusableCell(withIdentifier: "barCodeRow", for: indexPath) as! BarcodePicktureTableCell
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mma\nMM-dd-yy"
            
            cell.labelCode.text = form.barCodes[indexPath.row].code
            cell.labelTime.text = dateFormatter.string(from: form.barCodes[indexPath.row].time!).lowercased()

        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "imageRow", for: indexPath) as! BarcodePicktureTableCell
            
            let url = NSURL(fileURLWithPath: form.pictures[indexPath.row*4])
            cell.image1.image = UIImage(contentsOfFile: url.path!)
            cell.image1.tag = indexPath.row*4
            cell.image1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onImageItemClick)))
            cell.name1.text = url.lastPathComponent
            
            if (indexPath.row*4+1 < form.pictures.count) {
                let url = NSURL(fileURLWithPath: form.pictures[indexPath.row*4+1])
                cell.image2.tag = indexPath.row*4+1
                cell.image2.image = UIImage(contentsOfFile: url.path!)
                cell.image2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onImageItemClick)))
                cell.name2.text = url.lastPathComponent
            }
            else {
                cell.image2.isHidden = true
                cell.name2.isHidden = true
            }
            
            if (indexPath.row*4+2 < form.pictures.count) {
                let url = NSURL(fileURLWithPath: form.pictures[indexPath.row*4+2])
                cell.image3.tag = indexPath.row*4+2
                cell.image3.image = UIImage(contentsOfFile: url.path!)
                cell.image3.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onImageItemClick)))
                cell.name3.text = url.lastPathComponent
            }
            else {
                cell.image3.isHidden = true
                cell.name3.isHidden = true
            }
            
            if (indexPath.row*4+3 < form.pictures.count) {
                let url = NSURL(fileURLWithPath: form.pictures[indexPath.row*4+3])
                cell.image4.tag = indexPath.row*4+3
                cell.image4.image = UIImage(contentsOfFile: url.path!)
                cell.image4.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onImageItemClick)))
                cell.name4.text = url.lastPathComponent
            }
            else {
                cell.image4.isHidden = true
                cell.name4.isHidden = true
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            form.barCodes.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
}

class BarcodePicktureTableCell: UITableViewCell {
    
    @IBOutlet weak var labelCode: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var image4: UIImageView!
    @IBOutlet weak var name1: UILabel!
    @IBOutlet weak var name2: UILabel!
    @IBOutlet weak var name3: UILabel!
    @IBOutlet weak var name4: UILabel!
}







extension UITabBar {
    
    func addIndicator() {
        
        
        let color = UIColor(red: 31/255, green: 32/255, blue: 107/255, alpha: 1)
        self.selectionIndicatorImage = UIImage().createSelectionIndicator(color: color, size: CGSize(width: self.frame.width/CGFloat(self.items!.count), height: self.frame.height), lineHeight: 5.0)
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 14)!], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 14)!], for: .selected)
        
        
        self.invalidateIntrinsicContentSize();
        let tabSize: CGFloat = 50.0
        
        var tabFrame = self.frame;
        tabFrame.size.height = tabSize;
//                tabFrame.origin.y = self.view.frame.origin.y;
        self.frame = tabFrame;
        self.isTranslucent = false;
        self.isTranslucent = true;
        
        selectedItem = items![0]
        
        self.backgroundImage = UIImage()
    }
}
