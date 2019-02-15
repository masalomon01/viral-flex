import UIKit

class FormTableViewController: UITableViewController, UIActionSheetDelegate {
    
    static let Field_NAME = 1
    static let Field_DATE = 2
    
    var type: Int!
    var forms: [Form]!
    var sorted: Int?
    
    var itemClickDelegate: ItemClickDelegate?
    
    override func viewDidLoad() {
        refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refresh()
    }
    
    func refresh() {
        
        if (type==Form.TYPE_DRAFT) {forms = Form.getDraftForms()}
        else {forms = Form.getSubmittedForms()}
        tableView.reloadData()
        print("size")
        print(forms.count)
    }
    
    func sort(by field: Int) {
        if (field == sorted) {forms.reverse()}
        else if (field == FormTableViewController.Field_NAME) {
            forms.sort() { $0.name < $1.name }
        }
        else if (field == FormTableViewController.Field_DATE) {
            forms.sort() { $0.createTime! < $1.createTime! }
        }
        sorted = field
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "row", for: indexPath) as! FormTableViewCell
        
        let gesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onItemClick))
        gesture.numberOfTapsRequired = 1
        cell.tag = indexPath.row
        cell.isUserInteractionEnabled = true
        cell.addGestureRecognizer(gesture)
        
        cell.options.tag = indexPath.row
        cell.options.addTarget(parent, action: #selector(SubmittedViewController.onOptionClick(_:)), for: .touchUpInside)
        
        cell.checkBox.tag = indexPath.row
        cell.checkBox.addTarget(parent, action: Selector(("onCheckBoxClick:")), for: .touchUpInside)
        
        let form = forms![indexPath.row]
        cell.LabelName.text = form.name
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mma\nMM-dd-yy"
        if (form.createTime != nil) {cell.labelTime.text = dateFormatter.string(from: form.createTime!).lowercased()}
        cell.labelBarcodeCount.text = String(form.barCodes.count)
        cell.labelPhotoCount.text = String(form.pictures.count)
        
        if type == Form.TYPE_SUBMITTED {cell.checkBox.isHidden = true}
        
        return cell
    }
    
    func selectedRow() -> NSMutableArray {
        
        let array = NSMutableArray()
        for cell in tableView.visibleCells {
            if (cell as! FormTableViewCell).checkBox.isSelected {array.add((cell as! FormTableViewCell).checkBox)}
        }
        
        return array
    }
    
    func selectAll() {
        for cell in tableView.visibleCells {
            (cell as! FormTableViewCell).checkBox.isSelected = true
        }
    }
    
    func deselectAll() {
        for cell in tableView.visibleCells {
            (cell as! FormTableViewCell).checkBox.isSelected = false
        }
    }
    
    func getSelectedForms() -> [Form] {
        
        let array = NSMutableArray()
        for (index, cell) in tableView.visibleCells.enumerated() {
            if (cell as! FormTableViewCell).checkBox.isSelected {array.add(forms[index])}
        }
        return array.copy() as! [Form]
    }
    @IBAction func onItemClick(_ sender: UITapGestureRecognizer) {
        self.itemClickDelegate?.onItemClick(sender: sender.view! as! FormTableViewCell, position: sender.view!.tag)
    }
}

class FormTableViewCell: UITableViewCell {
    
    @IBOutlet weak var checkBox: CheckBox!
    @IBOutlet weak var LabelName: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelBarcodeCount: UILabel!
    @IBOutlet weak var labelPhotoCount: UILabel!
    @IBOutlet weak var options: UIButton!
}

protocol ItemClickDelegate{
    
    func onItemClick(sender: FormTableViewCell, position: Int)
}
