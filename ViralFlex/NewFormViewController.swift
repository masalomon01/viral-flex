import UIKit

class NewFormViewController: UIViewController, UITabBarDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, FolderSelectDelegate, CheckListSelectDelegate, SubmitDialogDelegate {
    
    
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var textField1: UIField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var textField3: UITextField!
    @IBOutlet weak var textfield4: UIField!
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
    @IBOutlet weak var textField16: UITextField! {
        didSet { textField16?.addDoneCancelToolbar() }
    }
    @IBOutlet weak var textField17: UITextField!
    @IBOutlet weak var buttonSubmit: RoundedButton!
    
    var form: Form!
    var selectedFolder: Folder!
    var edit: Int? = nil
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        
        navigationItem.title = form.name
        
        textField1.pickerData = ["Innovax ILT Vaccine Test", "Innovax ND Vaccine Test", "Innovax ND-IBD Vaccine Test", "IBD Field Virus Test", "ILT Field Virus Test"]
        textfield4.pickerData = ["Layer", "Broiler", "Broiler Breeder"]
        textField7.pickerData = ["Feather pulp", "Spleen", "Trachea"]
        
        textField1.text = form.testType
        textField2.text = form.farmName
        textField3.text = form.country
        textfield4.text = form.birdType
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
            (segue.destination as! CheckListViewController).section = ["Innovax", "IBD", "Other Vaccinations"]
            (segue.destination as! CheckListViewController).row = [
                [Vaccination("Innovax\nILT"), Vaccination("Innovax\nILT-SB"), Vaccination("Innovax\nND"), Vaccination("Innovax\nND-IBD"), Vaccination("Innovax\nND-SB")],
                [Vaccination("Nobilis\n228E"), Vaccination("Nobilis/\nClonevac D78"), Vaccination("Univax-BD"), Vaccination("Univax-Plus"), Vaccination("89/03"), Vaccination("Bursaplex"), Vaccination("Bursa-Vac"), Vaccination("Bursine 2"), Vaccination("Bursine Plus"), Vaccination("S706"), Vaccination("SVS510"), Vaccination("Transmune\n2512")],
                [Vaccination("add")]
            ]
            (segue.destination as! CheckListViewController).checkListSelectDelegate = self
            (segue.destination as! CheckListViewController).navigationTitleString = "Vaccination Treatments"
            (segue.destination as! CheckListViewController).selectedResult = form.vaccinations
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
        
        self.present(alertController, animated: true)
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
        
        let dialog = SubmitDialog()
        dialog.delegate = self
        dialog.setup()
        dialog.show()
        dialog.formName.text = form.name
    }
    
    @IBAction func onAddToFolderClick(_ sender: Any) {
        
        if let controller = self.storyboard?.instantiateViewController(withIdentifier: "addToFolderViewController") {
            (controller as! AddToFolderViewController).folderSelectDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func onFolderSelect(folder: Folder) {
        selectedFolder = folder
    }
    
    func onCheckListSelect(_ selected: [Any]) {
        if selected is [String] {
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
        self.saveDraft()
        dialog.labelError.isHidden = true
        HttpRequest.submitForm(form, pin: pin, onRequestSuccess: {response in
            
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
            self.textfield4.text = ""
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
        }
        alertController.addAction(clear)
        
        self.present(alertController, animated: true)
    }
    
    
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        tabBar.selectedItem = nil
        
        if item == tabBar.items![0]{
            onSaveDraftClick(item)
        }
        else if item == tabBar.items![1]{
            //            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "cameraViewController") {
            //                self.present(controller, animated: true, completion: nil)
            //            }
            
            showCamera(true)
        }
        else if item == tabBar.items![2]{
            if let controller = self.storyboard?.instantiateViewController(withIdentifier: "scanViewController") {
                (controller as! ScanViewController).previousViewController = self
                (controller as! ScanViewController).form = self.form
                self.present(controller, animated: true, completion: nil)
            }
        }
        else if item == tabBar.items![3] {
            let alertController = UIAlertController(title: "Delete this?", message: "Deleting this cannot be undone.", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Delete", style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(okAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true)
        }
        
        
    }
    
    func showCamera(_ animated: Bool) {
        
        let picker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            picker.sourceType = UIImagePickerController.SourceType.camera
            picker.allowsEditing = true
            
            let myView = Bundle.main.loadNibNamed("CameraView", owner: nil, options: nil)?.first as? CameraView

            
            let window = UIApplication.shared.keyWindow!

            myView?.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: window.frame.height - 50)
            
            
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
        form.birdType = textfield4.text
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
            selectedFolder?.addForm(form: form)
        }
        else {
            selectedFolder?.addForm(form: form)
            form.saveChanges()
        }
    }
    
    func submit() {
        
        form.saveDraft()
        selectedFolder?.addForm(form: form)
        form.submit()
    }
    
    func validate() {
        if (textField1.text != "" && textField2.text != "" && textField3.text != "" && textfield4.text != "" && form.barCodes.count > 0) {
            buttonSubmit.isEnabled = true
            buttonSubmit.backgroundColor = UIColor(red: 42/255, green: 49/255, blue: 126/255, alpha: 1.0)
        }
        else {
            buttonSubmit.isEnabled = false
            buttonSubmit.backgroundColor = UIColor(red: 188/255, green: 190/255, blue: 192/255, alpha: 1.0)
        }
    }
}
