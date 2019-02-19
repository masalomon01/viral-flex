import UIKit

class NewFormViewController: UIViewController, UITabBarDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, FolderSelectDelegate, CheckListSelectDelegate, SubmitDialogDelegate {
    
    
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var textField1: UIField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var textField3: UITextField!
    @IBOutlet weak var textField4: UIField!
    @IBOutlet weak var textField5: UITextField!
    @IBOutlet weak var textField6: UITextField! {
        didSet { textField6?.addDoneCancelToolbar() }
    }
    @IBOutlet weak var textField7: UIField!
    @IBOutlet weak var textField8: UITextField!
    @IBOutlet weak var textField9: UITextField!
    @IBOutlet weak var textField10: UITextField!
    @IBOutlet weak var textField11: UITextField!
    @IBOutlet weak var textField12: UITextField!
    @IBOutlet weak var textField13: UITextField!
    @IBOutlet weak var textField14: UITextField!
    @IBOutlet weak var textField15: UITextField!
    @IBOutlet weak var textField16: UITextField!
    @IBOutlet weak var textField17: UITextField!
    @IBOutlet weak var buttonClination: UIButton!
    @IBOutlet weak var labelNote: UILabel!
    @IBOutlet weak var buttonSubmit: RoundedButton!
    @IBOutlet weak var buttonClear: UIButton!
    @IBOutlet weak var buttonVaccination: UIButton!
    @IBOutlet weak var clinicalContainer: UIStackView!
    @IBOutlet weak var clinicalContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var vaccinationContainer: UIStackView!
    @IBOutlet weak var vaccinationContainerHeight: NSLayoutConstraint!
    
    var form: Form!
    var selectedFolder: Folder!
    var edit: Int? = nil
    var viewMode: Bool = false
    
    let vaccinationSection = ["Innovax", "IBD", "ILT", "ND", "Other Vaccinations"]
    let vaccinationRow = [
        [Vaccination("Innovax\nILT"), Vaccination("Innovax\nILT-SB"), Vaccination("Innovax\nND"), Vaccination("Innovax\nND-IBD"), Vaccination("Innovax\nND-SB")],
        [Vaccination("Nobilis\n228E"), Vaccination("Nobilis/\nClonevac D78"), Vaccination("Univax-BD"), Vaccination("Univax-Plus"), Vaccination("89/03"), Vaccination("Bursaplex"), Vaccination("Bursa-Vac"), Vaccination("Bursine 2"), Vaccination("Bursine Plus"), Vaccination("S706"), Vaccination("SVS510"), Vaccination("Transmune\n2512")],
        [Vaccination("LT-Ivax"), Vaccination("Nobilis\nILT"), Vaccination("Trachivax"), Vaccination("Other ILT")],
        [Vaccination("Newhatch-C2")],
        [Vaccination("2177"), Vaccination("Mildvac\nArk"), Vaccination("Mildvac\nGA-98"), Vaccination("Mildvac\nMass-Ark"), Vaccination("Mildvac\nMass+Conn"), Vaccination("Newhatch\nC2-M"), Vaccination("Newhatch\nC2-MC"), Vaccination("Nobilis\nIB 4-91"), Vaccination("Nobilis\nIB H120"), Vaccination("Nobilis\nIB Ma5"), Vaccination("Nobilis\nIB Rhino CV"), Vaccination("Nobilis\nTRT Live"), Vaccination("Monovalent\nHVT"), Vaccination("Ris-ma"), Vaccination("Rismavac"), Vaccination("Shor-Bron-D"), Vaccination("Injectible Antibiotic"), Vaccination("1/96"), Vaccination("Ark"), Vaccination("CR88"), Vaccination("H120 + D274\n(IB Primer)"), Vaccination("Ibmm plus\nArk"), Vaccination("Other\nCVI/Rispens"), Vaccination("SB1"), Vaccination("add")]]
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        
        navigationItem.title = form.name
        
        textField1.pickerData = ["Innovax ILT Vaccine Test", "Innovax ND Vaccine Test", "Innovax ND-IBD Vaccine Test", "IBD Field Virus Test", "ILT Field Virus Test"]
        textField4.pickerData = ["Layer", "Broiler", "Broiler Breeder"]
        textField7.pickerData = ["Feather pulp", "Spleen", "Trachea"]
        
        textField1.text = form.testType
        textField2.text = form.farmName
        textField3.text = form.country
        textField4.text = form.birdType
        textField5.text = form.hatcherySource
        textField6.text = form.samplingAge
        textField7.text = form.sampleType
        textField8.text = form.sampleCode
        textField9.text = form.shedID
        textField10.text = form.veterinaryPractice
        textField11.text = form.veterinarySurgeon
        textField12.text = form.inOvoVaccinator
        textField13.text = form.hatcherVaccinator
        textField14.text = form.labReferenceNumber
        textField15.text = form.companyName
        textField16.text = form.postCode
        textField17.text = form.county
        
        if viewMode {enableViewMode()}
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let count = form.barCodes.count
        if count == 0 {(tabBar.items![2] ).badgeValue = nil}
        else {(tabBar.items![2] ).badgeValue = String(count)}
        
        let pictureCount = form.pictures.count
        if pictureCount == 0 {(tabBar.items![1] ).badgeValue = nil}
        else {(tabBar.items![1] ).badgeValue = String(pictureCount)}
        
        
        clinicalContainer.subviews.forEach({ $0.removeFromSuperview() })
        clinicalContainerHeight.constant = CGFloat(0)
        for name in form.clinicalSigns {
            addClinical(name: name)
        }
        
        vaccinationContainer.subviews.forEach({ $0.removeFromSuperview() })
        vaccinationContainerHeight.constant = CGFloat(0)
        for vaccination in form.vaccinations {
            addVaccination(vaccination)
        }
        
        validate()
    }
    
    @IBAction func onTextFieldChanged(_ sender: UIField) {
        validate()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (sender as! UIButton).tag == 1 {
            (segue.destination as! CheckListViewController).row = [["Routine Monitoring", "Decreased Feed Intake", "Decreased Water Intake", "Birds Depressed", "Poor Growth", "Mild/Severe Respiratory Issues", "Sneezing, Snicking, Rales", "Tracheitis", "Conjunctivitis", "Swollen heads", "Nasal Exudate", "Increased Mortality", "Wet Litter/Enteritis/Scouring", "Decreased Shell Quality", "Decreased Egg Production", "Nephritis/Kidney Issues", "add", "clear"]]
            (segue.destination as! CheckListViewController).checkListSelectDelegate = self
            (segue.destination as! CheckListViewController).navigationTitleString = "Clinical Signs"
            (segue.destination as! CheckListViewController).selectedResult = form.clinicalSigns
        }
        else {
            (segue.destination as! CheckListViewController).section = vaccinationSection
            (segue.destination as! CheckListViewController).row = vaccinationRow.map { $0.map({$0.copy()}) }
            (segue.destination as! CheckListViewController).checkListSelectDelegate = self
            (segue.destination as! CheckListViewController).navigationTitleString = "Vaccination Treatments"
            (segue.destination as! CheckListViewController).selectedResult = form.vaccinations.map { $0.copy() }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view?.superview is UITabBar)
    }
    
    @IBAction func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func onBackClicked(_ sender: Any) {
        
        let title = "Save your progress?"
        let message = "You can discard any changes, or save them before continuing."
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let discard = UIAlertAction(title: "Discard", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(discard)
        
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (action) in }
        alertController.addAction(cancel)
        
        let save = UIAlertAction(title: "Save Changes", style: .default) { (action) in
            self.getData()
            self.saveDraft()
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(save)
        
        if viewMode {
            dismiss(animated: true, completion: nil)
        }
        else {
            self.present(alertController, animated: true)
        }
    }
    
    @IBAction func onSaveDraftClick(_ sender: Any) {
        
        let title = "Save a draft?"
        let message = "Save your draft and go to Manage Form."
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }
        alertController.addAction(cancel)
        
        let save = UIAlertAction(title: "Save Draft", style: .default) { (action) in
            
            self.getData()
            self.saveDraft()
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(save)
        
        self.present(alertController, animated: true)
    }
    
    @IBAction func onSubmitClick(_ sender: Any) {
        
        if viewMode {
            dismiss(animated: true, completion: nil)
        }
        else {
            let dialog = SubmitDialog()
            dialog.delegate = self
            dialog.setup()
            dialog.show()
            dialog.formName.text = form.name
        }
    }
    
    @IBAction func onAddToFolderClick(_ sender: Any) {
        
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "addToFolderViewController") {
            (controller as! AddToFolderViewController).folderSelectDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func onFolderSelect(folder: Folder) {
        selectedFolder = folder
        selectedFolder?.addForm(form: form)
    }
    
    func onCheckListSelect(_ type: String, _ selected: [Any]) {
        if type == "clinical" {
            form.clinicalSigns = selected as! [String]
        }
        else {
            form.vaccinations = selected as! [Vaccination]
            for vaccination in form.vaccinations {
                print(vaccination.uuid)
            }
        }
    }
    
    func onSubmit(dialog: SubmitDialog, pin: Int) {
        
        self.getData()
        dialog.labelError.isHidden = true
        HttpRequest.submitForm([form], pin: pin, onRequestSuccess: {response in
            
            print(response.statusCode)
            
            self.submit()
            dialog.hide()
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "submitSuccessViewController") {
                
                (controller as! SubmitSuccessViewController).previousViewController = self
                self.present(controller, animated: true, completion: nil)
            }
        }, onRequestFailed: {response in 
            
            print(response.statusCode)
            
            DispatchQueue.main.async {
                
                if response.statusCode == 401 {
                    dialog.labelError.isHidden = false
                }
                else if response.statusCode == 500 {
                    let errorDialog = ErrorDialog()
                    errorDialog.setup()
                    errorDialog.show()
                }
            }
        })
    }
    
    @IBAction func onClearClick(_ sender: Any) {
        
        let title = "Clear Form?"
        let message = "This will delete all of your inputs on this form. Continue?"
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (action) in }
        alertController.addAction(cancel)
        
        let clear = UIAlertAction(title: "Clear Form", style: .destructive) { (action) in
            self.textField1.text = ""
            self.textField2.text = ""
            self.textField3.text = ""
            self.textField4.text = ""
            self.textField5.text = ""
            self.textField6.text = ""
            self.textField7.text = ""
            self.textField8.text = ""
            self.textField9.text = ""
            self.textField10.text = ""
            self.textField11.text = ""
            self.textField12.text = ""
            self.textField13.text = ""
            self.textField14.text = ""
            self.textField15.text = ""
            self.textField16.text = ""
            self.textField17.text = ""
            self.form.clinicalSigns = []
            self.form.vaccinations = []
        }
        alertController.addAction(clear)
        
        self.present(alertController, animated: true)
    }
    
    
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        tabBar.selectedItem = nil
        
        if item == tabBar.items![0]{
            
            if viewMode {
                
                let alertController = UIAlertController(title: "Name Your Form", message: "Give a unique, pertinent name to your form. This can be chaned later.", preferredStyle: .alert)
                
                alertController.addTextField { (textField) in
                    textField.text = self.form.name
                }
                
                alertController.addAction(UIAlertAction(title: "Create", style: .default) { (action) in
                    
                    if let controller = self.storyboard?.instantiateViewController(withIdentifier: "newFormViewController") {
                        
                        let textField = alertController.textFields![0] as UITextField
                        
                        let newForm = self.form.copy() as! Form
                        newForm.status = Form.STATUS_NEW
                        newForm.name = textField.text!
                        
                        (controller as! NewFormViewController).form = newForm
                        self.present(controller, animated: true, completion: nil)
                    }
                })
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action) in })
                self.present(alertController, animated: true)
            }
            else {
                onSaveDraftClick(item)
            }
            
        }
        else if item == tabBar.items![1]{
            
            if viewMode {
                if let barcodePictureViewController = self.storyboard?.instantiateViewController(withIdentifier: "barcodePictureViewController") {
                    (barcodePictureViewController as! BarcodePictureViewController).form = form
                    (barcodePictureViewController as! BarcodePictureViewController).viewMode = viewMode
                    present(barcodePictureViewController, animated: true, completion: nil)
                }
            }
            else {
                showCamera(true)
            }
        }
        else if item == tabBar.items![2]{
            
            if viewMode {
                if let barcodePictureViewController = self.storyboard?.instantiateViewController(withIdentifier: "barcodePictureViewController") {
                    (barcodePictureViewController as! BarcodePictureViewController).form = form
                    (barcodePictureViewController as! BarcodePictureViewController).viewMode = viewMode
                    present(barcodePictureViewController, animated: true, completion: nil)
                }
            }
            else {
                if let controller = self.storyboard?.instantiateViewController(withIdentifier: "scanViewController") {
                    (controller as! ScanViewController).previousViewController = self
                    (controller as! ScanViewController).form = self.form
                    present(controller, animated: true, completion: nil)
                }
            }
            
            
        }
        else if item == tabBar.items![3] {
            
            if viewMode {
                
                if let controller = self.storyboard?.instantiateViewController(withIdentifier: "addToFolderViewController") {
                    (controller as! AddToFolderViewController).folderSelectDelegate = self
                    self.present(controller, animated: true, completion: nil)
                }
            }
            else {
                
                let alertController = UIAlertController(title: "Delete this?", message: "Deleting this cannot be undone.", preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "Delete", style: .default) { (action) in
                    self.form.delete()
                    self.dismiss(animated: true, completion: nil)
                })
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action) in })
                
                self.present(alertController, animated: true)
            }
        }
    }
    
    
    func showCamera(_ animated: Bool) {
        
        let picker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            picker.sourceType = UIImagePickerController.SourceType.camera
            picker.allowsEditing = true
            
            let myView = Bundle.main.loadNibNamed("CameraView", owner: nil, options: nil)?.first as? CameraView

            
            let window = UIApplication.shared.keyWindow!

            myView?.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: window.frame.height - 80)
            
            
            self.present(picker, animated: animated, completion: {
                myView?.controller = self
                myView?.form = self.form
                myView?.imagePickerController = picker
                picker.delegate = myView
                picker.cameraOverlayView = myView
            })
        }
    }
    
    func getData() {
        
        form.testType = textField1.text
        form.farmName = textField2.text
        form.country = textField3.text
        form.birdType = textField4.text
        form.hatcherySource = textField5.text
        form.samplingAge = textField6.text
        form.sampleType = textField7.text
        form.sampleCode = textField8.text
        form.shedID = textField9.text
        form.veterinaryPractice = textField10.text
        form.veterinarySurgeon = textField11.text
        form.inOvoVaccinator = textField12.text
        form.hatcherVaccinator = textField13.text
        form.labReferenceNumber = textField14.text
        form.companyName = textField15.text
        form.postCode = textField16.text
        form.county = textField17.text
    }
    
    func saveDraft() {
        
        if edit==nil {
            form.saveDraft()
        }
        else {
            form.saveChanges()
        }
    }
    
    func submit() {
        
        saveDraft()
        selectedFolder?.addForm(form: form)
        form.submit()
    }
    
    func validate() {
        if (textField1.text != "" && textField2.text != "" && textField3.text != "" && textField4.text != "" && textField6.text != "" && textField7.text != "" && form.barCodes.count > 0) {
            buttonSubmit.isEnabled = true
            buttonSubmit.backgroundColor = UIColor(red: 42/255, green: 49/255, blue: 126/255, alpha: 1.0)
        }
        else {
            buttonSubmit.isEnabled = false
            buttonSubmit.backgroundColor = UIColor(red: 188/255, green: 190/255, blue: 192/255, alpha: 1.0)
        }
    }
    
    func addClinical(name: String) {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "Views", bundle: bundle)
        let view = nib.instantiate(withOwner: nil, options: nil)[0] as! UIView
        
        if let foundView = view.viewWithTag(100) {
            (foundView as! CheckBox).isSelected = true
        }
        if let foundView = view.viewWithTag(101) {
            (foundView as! UILabel).text = name
        }
        
        clinicalContainer.addArrangedSubview(view)
        clinicalContainerHeight.constant = CGFloat(clinicalContainer.subviews.count * 50)
    }
    
    func addVaccination(_ vaccination: Vaccination) {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "Views", bundle: bundle)
        let view = nib.instantiate(withOwner: nil, options: nil)[1] as! UIView
        
        for (i, section) in vaccinationRow.enumerated() {
            for item in section {
                
                if let sectionName = view.viewWithTag(1), item.name.replacingOccurrences(of: "\n", with: " ") == vaccination.name.replacingOccurrences(of: "\n", with: " ") {
                    (sectionName as! UILabel).text = vaccinationSection[i]
                    break;
                }
            }
        }
        
        if let name = view.viewWithTag(2) {
            (name as! UILabel).text = vaccination.name
        }
        if let age = view.viewWithTag(3), vaccination.age != nil {
            (age as! UILabel).text = String(vaccination.age!)
        }
        if let doses = view.viewWithTag(4), vaccination.doses != nil {
            (doses as! UILabel).text = String(vaccination.doses!)
        }
        if let administration = view.viewWithTag(5), vaccination.admin != nil {
            (administration as! UILabel).text = String(vaccination.admin!)
        }
        if let brand = view.viewWithTag(6), vaccination.brand != nil {
            (brand as! UILabel).text = String(vaccination.brand!)
        }
        
        vaccinationContainer.addArrangedSubview(view)
        vaccinationContainerHeight.constant = CGFloat(vaccinationContainer.subviews.count * 150)
    }
    
    func enableViewMode() {
        navigationItem.rightBarButtonItem = nil
        
        textField1.isUserInteractionEnabled = false
        textField1.type = 0
        textField1.initView()
        textField2.isUserInteractionEnabled = false
        textField3.isUserInteractionEnabled = false
        textField4.isUserInteractionEnabled = false
        textField4.type = 0
        textField7.initView()
        textField5.isUserInteractionEnabled = false
        textField6.isUserInteractionEnabled = false
        textField7.isUserInteractionEnabled = false
        textField7.type = 0
        textField7.initView()
        textField8.isUserInteractionEnabled = false
        textField9.isUserInteractionEnabled = false
        textField10.isUserInteractionEnabled = false
        textField11.isUserInteractionEnabled = false
        textField12.isUserInteractionEnabled = false
        textField13.isUserInteractionEnabled = false
        textField14.isUserInteractionEnabled = false
        textField15.isUserInteractionEnabled = false
        textField16.isUserInteractionEnabled = false
        textField17.isUserInteractionEnabled = false
        
        buttonClination.isUserInteractionEnabled = false
        buttonVaccination.isUserInteractionEnabled = false
        labelNote.isHidden = true
        buttonClear.isHidden = true
        buttonSubmit.setTitle("Done", for: .normal)
        
        tabBar.items![0].image = UIImage(named: "copy")
        tabBar.items![3].image = UIImage(named: "download")
    }
}
