import UIKit


class BarcodesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var forms: [Form]!
    var sorted: Bool = false
    
    override func viewDidLoad() {
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        forms = Form.loadForms()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        forms = Form.loadForms()
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return forms.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = tableView.dequeueReusableCell(withIdentifier: "sectionHeader") as! BarcodesTableViewHeader
        header.formName.text = forms[section].name
        
        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (forms[section].barCodes.count + 2) / 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let form = forms[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: "row", for: indexPath) as! BarcodesTableViewCell
        
        if indexPath.row * 3 < form.barCodes.count {
            cell.image1.image = self.generateBarcode(from: form.barCodes[indexPath.row * 3].code)
            cell.name1.text = form.barCodes[indexPath.row * 3].code
        }
        else {
            cell.name1.text = ""
        }
        
        if indexPath.row * 3 + 1 < form.barCodes.count {
            cell.image2.image = self.generateBarcode(from: form.barCodes[indexPath.row * 3 + 1].code)
            cell.name2.text = form.barCodes[indexPath.row * 3 + 1].code
        }
        else {
            cell.name2.text = ""
        }
        
        if indexPath.row * 3 + 2 < form.barCodes.count {
            cell.image3.image = self.generateBarcode(from: form.barCodes[indexPath.row * 3 + 2].code)
            cell.name3.text = form.barCodes[indexPath.row * 3 + 2].code
        }
        else {
            cell.name3.text = ""
        }
        
        return cell
    }
    
    func generateBarcode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
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

class BarcodesTableViewHeader: UITableViewCell {
    
    @IBOutlet weak var formName: UILabel!
}

class BarcodesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var name1: UILabel!
    @IBOutlet weak var name2: UILabel!
    @IBOutlet weak var name3: UILabel!
}
