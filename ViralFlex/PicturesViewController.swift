import UIKit


class PicturesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var forms: [Form]!
    var sorted: Bool = false
    
    override func viewDidLoad() {
        
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.estimatedRowHeight = 80 // or any other number that makes sense for your cells
        tableView.rowHeight = UITableView.automaticDimension
        
        forms = Form.loadForms()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        forms = Form.loadForms()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if forms[indexPath.row].pictures.count > 0 {
            return UITableView.automaticDimension
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if forms[indexPath.row].pictures.count > 0 {
            return UITableView.automaticDimension
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let form = forms[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "rowPicture", for: indexPath)
        
        (cell as! PicturesTableViewCell).formName.text = form.name
        
        if form.pictures.count > 0 {
            let url = NSURL(fileURLWithPath: form.pictures[0])
            (cell as! PicturesTableViewCell).image1.image = UIImage(contentsOfFile: url.path!)
            (cell as! PicturesTableViewCell).name1.text = url.lastPathComponent
        }
        else {
            (cell as! PicturesTableViewCell).name1.text = ""
        }
        if form.pictures.count > 1 {
            let url = NSURL(fileURLWithPath: form.pictures[1])
            (cell as! PicturesTableViewCell).image2.image = UIImage(contentsOfFile: url.path!)
            (cell as! PicturesTableViewCell).name2.text = url.lastPathComponent
        }
        else {
            (cell as! PicturesTableViewCell).name2.text = ""
        }
        if form.pictures.count > 2 {
            let url = NSURL(fileURLWithPath: form.pictures[2])
            (cell as! PicturesTableViewCell).image3.image = UIImage(contentsOfFile: url.path!)
            (cell as! PicturesTableViewCell).name3.text = url.lastPathComponent
        }
        else {
            (cell as! PicturesTableViewCell).name3.text = ""
        }
        if form.pictures.count > 3 {
            let url = NSURL(fileURLWithPath: form.pictures[3])
            (cell as! PicturesTableViewCell).image4.image = UIImage(contentsOfFile: url.path!)
            (cell as! PicturesTableViewCell).name4.text = url.lastPathComponent
        }
        else {
            (cell as! PicturesTableViewCell).name4.text = ""
        }
        
        return cell
    }
    
    @IBAction func onNameClick(_ sender: UIButton) {
        
        self.sort()
        if (sender.tag == 1) {
            sender.setImage(UIImage(named: "arrowUp"), for: .normal)
            sender.tag = 2
        }
        else {
            sender.setImage(UIImage(named: "arrowDownSelected"), for: .normal)
            sender.tag = 1
        }
        
    }
    
    func sort() {
        if sorted {forms.reverse()}
        else {
            forms.sort() { $0.name < $1.name }
        }
        sorted = true
        tableView.reloadData()
    }
}

class PicturesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var formName: UILabel!
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var image4: UIImageView!
    @IBOutlet weak var name1: UILabel!
    @IBOutlet weak var name2: UILabel!
    @IBOutlet weak var name3: UILabel!
    @IBOutlet weak var name4: UILabel!
}
