import UIKit

class CheckListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DialogVaccinationsDelegate, DialogDelegate {
    
    
    @IBOutlet weak var navigationTitle: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var headerHeight: NSLayoutConstraint!
    
    var navigationTitleString: String!
    var section: [String]?
    var row: [[Any]]?
    var selected: Int?
    var selectedResult: [Any] = []
    var checkListSelectDelegate: CheckListSelectDelegate?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        navigationTitle.title = navigationTitleString
        
        if section == nil {
            header.isHidden = true
            headerHeight.constant = 0
        }
        
        if section == nil {
            let rowString = row as! [[String]]
            for item in selectedResult {
                if !(rowString.contains { $0.contains(item as! String) }) {
                    row![(row?.count)! - 1].insert(item, at: row![(row?.count)! - 1].count - 2)
                }
            }
        }
        else {
            let rowVaccination = row as! [[Vaccination]]
            for item in selectedResult {
                if !(rowVaccination.contains { $0.contains(item as! Vaccination) }) {
                    row![(row?.count)! - 1].insert(item, at: row![(row?.count)! - 1].count - 1)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        view.tintColor = UIColor.white
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor(red: 42/255, green: 49/255, blue: 126/255, alpha: 1.0)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.section != nil {return self.section![section]}
        else {return ""}
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (row?.count)!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return row![section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if section == nil && indexPath.row == (row?[0].count)! - 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addSymptom", for: indexPath) as! CheckListViewCellAddSymptom
            
            cell.buttonAdd.addTarget(self, action: #selector(onAddSymptomClick), for: .touchUpInside)
            return cell
        }
        else if section == nil && indexPath.row == (row?[0].count)! - 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "clear", for: indexPath) as! CheckListViewCellClear
            
            cell.buttonClear.addTarget(self, action: #selector(onClearClick), for: .touchUpInside)
            return cell
        }
        else if section != nil && indexPath.section == (row?.count)! - 1 && indexPath.row == ((row?[(row?.count)!-1].count)! - 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addVaccination", for: indexPath) as! CheckListViewCellAddVaccination
            
            cell.buttonAdd.addTarget(self, action: #selector(onAddVaccinationClick), for: .touchUpInside)
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "row", for: indexPath) as! CheckListViewTableCell
        cell.section = indexPath.section
        cell.row = indexPath.row
        
        cell.labelAge.text = ""
        cell.labelDoses.text = ""
        cell.labelAdmin.text = ""
        cell.labelBrand.text = ""
        cell.checkBox.isSelected = false
        
        
        
        let item = row![indexPath.section][indexPath.row]
        
        if item is String {
            cell.label.text = (item as! String)
            cell.checkBox.setSelected(selected: (selectedResult as! [String]).contains(where: {
                $0 == (item as! String)
            }))
            
            for selected in selectedResult {
                if (selected as! String) == (item as! String) {
                    cell.checkBox.isSelected = true
                }
            }
        }
        else {
            var vaccination = item as! Vaccination
            for selected in selectedResult {
                if (selected as! Vaccination).name.replacingOccurrences(of: "\n", with: " ") == vaccination.name.replacingOccurrences(of: "\n", with: " ") {
                    vaccination = selected as! Vaccination
                    row![indexPath.section][indexPath.row] = vaccination
                    cell.checkBox.isSelected = true
                }
            }
            
            cell.label.text = vaccination.name
            if vaccination.age != nil {cell.labelAge.text = String(vaccination.age!)}
            if vaccination.doses != nil {cell.labelDoses.text = String(vaccination.doses!)}
            if vaccination.admin != nil {cell.labelAdmin.text = vaccination.admin!}
            if vaccination.brand != nil {cell.labelBrand.text = vaccination.brand!}
        }
        
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCelClick)))
        cell.checkBox.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onCelClick)))
        
        return cell
    }
    
    @IBAction func onBackClick(_ sender: Any) {
        
        let title = "Are you sure?"
        let message = "Going back will empty your selections."
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default) { (action) in })
        
        alertController.addAction(UIAlertAction(title: "Discard", style: .destructive) { (action) in
            self.dismiss(animated: true, completion: nil)
        })
        
        self.present(alertController, animated: true)
    }
    
    @IBAction func onDoneClick(_ sender: Any) {
        checkListSelectDelegate?.onCheckListSelect(section != nil ? "vaccination":"clinical", selectedResult)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCelClick(_ sender: UIGestureRecognizer) {
        
        var cell: CheckListViewTableCell
        if sender.view is CheckListViewTableCell {
            cell = sender.view as! CheckListViewTableCell
        }
        else {
            cell = (sender.view as! CheckBox).superview?.superview as! CheckListViewTableCell
        }
        
        let selectedItem = row![(cell.section!)][(cell.row!)]
        
        let checkBox = cell.checkBox
        
        if section == nil {
            checkBox?.setSelected(selected: !(checkBox?.isSelected)!)
        }
        else if (checkBox?.isSelected)! && !(sender.view is CheckListViewTableCell) {
            checkBox?.setSelected(selected: false)
        }
        else {
            checkBox?.setSelected(selected: true)
            
            let dialog = Dialog()
            dialog.vaccination = selectedItem as? Vaccination
            dialog.vaccinationsDelegate = self
            dialog.show()
            dialog.setup(Dialog.TYPE_VACCINATIONS)
        }
        
        if selectedItem is String {
            if (selectedResult as! [String]).contains(selectedItem as! String) {
                let index = (selectedResult as! [String]).firstIndex(of: selectedItem as! String)
                selectedResult.remove(at: index!)
            }
            else {
                selectedResult.append(selectedItem)
            }
        }
        
        if selectedItem is Vaccination {
            
            selected = nil
            let index = selectedResult.firstIndex(where: { ($0 as! Vaccination).uuid == (selectedItem as! Vaccination).uuid})
            
            if !(checkBox?.isSelected)! {
                selectedResult.remove(at: index!)
            }
            else if index == nil {
                selectedResult.append(selectedItem)
                selected = selectedResult.count - 1
            }
            else {
                selected = index
            }
        }
        
    }
    
    @IBAction func onAddSymptomClick() {
        
        let dialog = Dialog()
        dialog.delegate = self
        dialog.show()
        dialog.setup(Dialog.TYPE_TEXT)
        dialog.pickerTitle.text = "Custom Vaccination Title"
    }
    
    @IBAction func onAddVaccinationClick() {
        
        selected = nil
        let dialog = Dialog()
        dialog.vaccinationsDelegate = self
        dialog.show()
        dialog.setup(Dialog.TYPE_VACCINATIONS)
    }
    
    @IBAction func onClearClick() {
        for cell in tableView.visibleCells {
            if !(cell is CheckListViewTableCell) {continue}
            (cell as! CheckListViewTableCell).checkBox.isSelected = false
        }
        selectedResult = []
    }
    
    func onDialogResult(text: String) {
        row![0].insert(text, at: row![0].count - 2)
        selectedResult.append(text)
        tableView.reloadData()
    }
    
    func onDialogResult(_ newVaccination: Vaccination) {
        
        if selected != nil {
            selectedResult[selected!] = newVaccination
            
            for (i, section) in row!.enumerated() {
                for (j, vaccination) in (section as! [Vaccination]).enumerated() {
                    if vaccination.uuid == newVaccination.uuid {
                        row![i][j] = newVaccination
                    }
                }
            }
        }
        else {
            
            row![(row?.count)! - 1].insert(newVaccination, at: row![(row?.count)! - 1].count - 1)
            selectedResult.append(newVaccination)
        }
        tableView.reloadData()
    }
}

class CheckListViewTableCell: UITableViewCell {
    
    @IBOutlet weak var checkBox: CheckBox!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var labelAge: UILabel!
    @IBOutlet weak var labelDoses: UILabel!
    @IBOutlet weak var labelAdmin: UILabel!
    @IBOutlet weak var labelBrand: UILabel!
    
    var section: Int?
    var row: Int?
}

class CheckListViewCellAddSymptom: UITableViewCell {
    
    @IBOutlet weak var buttonAdd: UIButton!
}

class CheckListViewCellAddVaccination: UITableViewCell {
    
    @IBOutlet weak var buttonAdd: UIButton!
}

class CheckListViewCellClear: UITableViewCell {
    
    @IBOutlet weak var buttonClear: UIButton!
}

protocol CheckListSelectDelegate {
    
    func onCheckListSelect(_ type: String, _ selected: [Any])
}
