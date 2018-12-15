//
//  SampleViewController.swift
//  RG Samples
//
//  Created by Joseph Tocco on 8/17/17.
//  Copyright © 2017 Joseph Ryan Tocco. All rights reserved.
//

import UIKit
import AVFoundation

// Used to facilitate prompting the user when they press the back button.
public protocol BackButtonDelegate {
    func shouldGoBack() -> Bool
}

// Used to facilitate prompting the user when they press the back button.
extension UINavigationController: UINavigationBarDelegate {
    public func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        if (self.topViewController as? SampleViewController) != nil {
            if (self.topViewController as? SampleViewController)!.shouldGoBack() {
                self.popViewController(animated: true)
                return true
            }
            return false
        }
        self.popViewController(animated: true)
        return true
    }
}

class SampleViewController: UITableViewController, AVCaptureMetadataOutputObjectsDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, SymptomDelegate, VaccinationDelegate, BarcodeDelegate, BackButtonDelegate {
    
    /*
     * Set up global variables.
     *////////////////////////////////////////////////////////////////////////////////
    
    // Field references.
    @IBOutlet weak var formName: UITextField!
    @IBOutlet weak var sampleType: UITextField!
    @IBOutlet weak var ageOfBird: UITextField!
    @IBOutlet weak var birdType: UITextField!
    @IBOutlet weak var vetSurgeon: UITextField!
    @IBOutlet weak var labRefNo: UITextField!
    @IBOutlet weak var companyName: UITextField!
    @IBOutlet weak var farmName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var sampleCode: UITextField!
    @IBOutlet weak var vetPractice: UITextField!
    @IBOutlet weak var shedSampled: UITextField!
    @IBOutlet weak var zipPostCounty: UITextField!
    @IBOutlet weak var hatcherySource: UITextField!
    
    @IBOutlet weak var scanBarcodesButton: UIButton!
    @IBOutlet weak var manageBarcodesButton: UIButton!
    @IBOutlet weak var selectSymptomsButton: UIButton!
    @IBOutlet weak var selectVaccinationsButton: UIButton!
    @IBOutlet weak var saveChangesButton: UIButton!
    @IBOutlet weak var createCopyButton: UIButton!
    
    var pickerView:UIPickerView!
    var pickerSelection:String!
    
    // Constants.
    let TYPE_OF_BIRD = 1
    let AGE_OF_BIRD = 2
    let TYPE_OF_SAMPLE = 3
    var fieldSelected = 0
    
    // Barcode scanner stuff.
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var exitCameraButton:UIButton?
    
    var form:Form?
    var pickerData: [String] = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Modify the navigation bar at the top.
        self.navigationItem.title = "Form (Editing)"
        
        formName.text = form?.formName
        sampleType.text = form?.sampleType
        ageOfBird.text = form?.age
        birdType.text = form?.birdType
        vetSurgeon.text = form?.vetSurgeon
        labRefNo.text = form?.labRefNo
        companyName.text = form?.companyName
        farmName.text = form?.farmName
        email.text = form?.email
        sampleCode.text = form?.sampleCode
        vetPractice.text = form?.vetPractice
        shedSampled.text = form?.shedSampled
        zipPostCounty.text = form?.zipPostCounty
        
        // Set up the picker view.
        self.pickerView = UIPickerView(frame: CGRect(x: 0, y: 200, width: view.frame.width, height: 200))
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        pickerView.backgroundColor = UIColor.white
        pickerData = []
        
        // Set up toolbar for picker view.
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(pickerCancel))
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let select = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(pickerSelect))
        toolBar.setItems([cancel, space, select], animated: false)
        toolBar.isUserInteractionEnabled = true
        self.birdType.inputView = self.pickerView
        self.birdType.inputAccessoryView = toolBar
        self.sampleType.inputView = self.pickerView
        self.sampleType.inputAccessoryView = toolBar
        
        self.ageOfBird.delegate = self
        self.birdType.delegate = self
        self.sampleType.delegate = self
        
        // So we can tell which one is which
        self.ageOfBird.tag = AGE_OF_BIRD
        self.birdType.tag = TYPE_OF_BIRD
        self.sampleType.tag = TYPE_OF_SAMPLE
        
        self.formName.delegate = self
        self.vetSurgeon.delegate = self
        self.labRefNo.delegate = self
        self.companyName.delegate = self
        self.farmName.delegate = self
        self.email.delegate = self
        self.sampleCode.delegate = self
        self.vetPractice.delegate = self
        self.shedSampled.delegate = self
        self.zipPostCounty.delegate = self
        
        // Add delete button to top right.
        let deleteFormItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.trash, target: self, action: #selector(deleteFormPrompt))
        deleteFormItem.tintColor = UIColor.red
        self.navigationItem.rightBarButtonItem = deleteFormItem
        
        // Hide the tab bar at the bottom to avoid confusion between editing and creating a new form.
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.closeCamera(sender: self)
        
        self.view.endEditing(false) // Close keyboard if open.
        
        // If moving back to the Manage Barcodes table.
        if self.isMovingFromParentViewController {
            self.tabBarController?.tabBar.isHidden = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Send data to the page that the user is moving to.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // If the user is going to the page to view the symptoms for this form.
        if let viewController = segue.destination as? SymptomViewController {
            
            // Set the symptoms and notes in the symptoms page.
            let symptoms = form?.symptoms as! Array<String>
            
            if symptoms.contains("Decreased feed/water intake") { viewController.startIntake = true }
            if symptoms.contains("Birds depressed") { viewController.startDepressed = true }
            if symptoms.contains("Poor growth") { viewController.startGrowth = true }
            if symptoms.contains("Routine monitoring") { viewController.startMonitoring = true }
            if symptoms.contains("Mild/Severe respiratory problems") { viewController.startRespiratory = true }
            if symptoms.contains("Sneezing, snicking, rales") { viewController.startSneezing = true }
            if symptoms.contains("Tracheitis") { viewController.startTracheitis = true }
            if symptoms.contains("Conjunctivitis") { viewController.startConjunctivitis = true }
            if symptoms.contains("Swollen heads/Nasal exudate/Sinusitis") { viewController.startHeads = true }
            if symptoms.contains("Increased mortality") { viewController.startMortality = true }
            if symptoms.contains("Wet litter/Enteritis/Scouring") { viewController.startWetLitter = true }
            if symptoms.contains("Decrease in shell quality") { viewController.startShellQuality = true }
            if symptoms.contains("Drop in egg production") { viewController.startEggProduction = true }
            if symptoms.contains("Nephritis/Kidney problems") { viewController.startNephritis = true }
            
            if form?.symptomNotes != nil { viewController.notes = form?.symptomNotes }
            
            viewController.delegate = self
            
        // If the user is going to the page to view the vaccinations for this form.
        } else if let viewController = segue.destination as? VaccinationViewController {
            
            // Set the vaccinations and notes in the vaccinations page.
            let vaccinations = form?.vaccinations as! Array<Vaccination>
            for vax in vaccinations {
                let index = viewController.vaccinations.index(where: { (v) -> Bool in
                    v.name == vax.name
                })
                viewController.vaccinations[index!] = vax
            }
            
            if form?.vaccinationNotes != nil { viewController.notes = form?.vaccinationNotes }
            
            viewController.delegate = self
            
        // If the user is going to the page to view the barcodes for this form.
        } else if let viewController = segue.destination as? BarcodeTableViewController {
            
            // Set the barcodes in the manage barcodes page.
            viewController.barcodes = form?.barcodes as! Array<String>
            viewController.delegate = self
        }
    }
    
    func shouldGoBack() -> Bool {
        let confirmController = UIAlertController(title: "Are you sure you want to leave the page?", message: "Any changes you made will not be saved.", preferredStyle: .alert)
        
        let yes = UIAlertAction(title: "Yes", style: .default) { (_) in
            self.navigationController?.popViewController(animated: true)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            self.navigationItem.hidesBackButton = true
            self.navigationItem.hidesBackButton = false
        }
        
        confirmController.addAction(yes)
        confirmController.addAction(cancel)
        present(confirmController, animated: true, completion: nil)
        
        return false
    }
    
    /*
     * Delegate functions for navigating back to this page (basically a reverse segue).
     *////////////////////////////////////////////////////////////////////////////////
    
    func setSymptoms(symptoms: Array<String>, notes: String) {
        form?.symptoms = symptoms as NSArray
        form?.symptomNotes = notes
    }
    
    func setVaccinations(vaccinations: Array<Vaccination>, notes: String) {
        form?.vaccinations = vaccinations as NSArray
        form?.vaccinationNotes = notes
    }
    
    func setBarcodes(barcodes: Array<String>) {
        form?.barcodes = barcodes as NSArray
    }
    
    /*
     * Save Form button.
     */
    
    @IBAction func saveChanges(_ sender: Any) {
        
        // If the form has no barcodes.
        if form?.barcodes == nil || (form?.barcodes as! NSArray).count  == 0 {
            displayNotification(message: "Form must contain at least one barcode.")
            return
        }
        // If the form does not have a Form Name.
        if self.formName.text == nil || self.formName.text == "" {
            displayNotification(message: "You must specify a Form Name.")
            return
        }

        // Present a popup asking if the user is sure they want to save the form.
        let saveController = UIAlertController(title: "Save form locally?", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        let yes = UIAlertAction(title: "Yes", style: .default) { (_) in
            // Save the form.
            self.form?.formName = self.formName.text
            self.form?.age = self.ageOfBird.text
            self.form?.birdType = self.birdType.text
            self.form?.sampleType = self.sampleType.text
            self.form?.vetSurgeon = self.vetSurgeon.text
            self.form?.labRefNo = self.labRefNo.text
            self.form?.companyName = self.companyName.text
            self.form?.farmName = self.farmName.text
            self.form?.email = self.email.text
            self.form?.sampleCode = self.sampleCode.text
            self.form?.vetPractice = self.vetPractice.text
            self.form?.shedSampled = self.shedSampled.text
            self.form?.zipPostCounty = self.zipPostCounty.text
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            // Notify the user that the form has been saved and then go back to the manage forms page.
            let messageController = UIAlertController(title: "Saved!", message: "", preferredStyle: UIAlertControllerStyle.alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (_) in
                self.navigationController!.popViewController(animated: true)
            }
            messageController.addAction(ok)
            self.present(messageController, animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        saveController.addAction(yes)
        saveController.addAction(cancel)
        
        self.present(saveController, animated: true, completion: nil)
    }
    
    // Create a copy of the current form with a new saved date to be edited by the user.
    @IBAction func createCopy(_ sender: Any) {
        let message = "Note that all symptoms and vaccinations will be copied over, but barcodes will not."
        let copyController = UIAlertController(title: "Create a copy of this form?", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        let yes = UIAlertAction(title: "Yes", style: .default) { (_) in
        
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let newForm = Form(context: context)
            
            let newFormName = self.form!.formName == nil ? "(copy)" : self.form!.formName! + " (copy)"
            
            newForm.formName = newFormName
            newForm.age = self.form!.age
            newForm.barcodes = [] as NSObject
            newForm.birdType = self.form!.birdType
            newForm.sampleType = self.form!.sampleType
            newForm.vetSurgeon = self.form!.vetSurgeon
            newForm.labRefNo = self.form!.labRefNo
            newForm.companyName = self.form!.companyName
            newForm.farmName = self.form!.farmName
            newForm.email = self.form!.email
            newForm.sampleCode = self.form!.sampleCode
            newForm.vetPractice = self.form!.vetPractice
            newForm.shedSampled = self.form!.shedSampled
            newForm.zipPostCounty = self.form!.zipPostCounty
            newForm.symptoms = self.form!.symptoms
            newForm.vaccinations = self.form!.vaccinations
            
            newForm.symptomNotes = self.form!.symptomNotes
            newForm.vaccinationNotes = self.form!.vaccinationNotes
            
            newForm.savedDate = NSDate()
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            self.navigationController?.popViewController(animated: true)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        copyController.addAction(yes)
        copyController.addAction(cancel)
        
        self.present(copyController, animated: true, completion: nil)
    }
    
    // Display a simple notification. The variable message is what will be displayed.
    func displayNotification(message: String) {
        let messageController = UIAlertController(title: message, message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        let ok = UIAlertAction(title: "OK", style: .default) { (_) in }
        messageController.addAction(ok)
        
        self.present(messageController, animated: true, completion: nil)
    }
    
    /*
     * Barcode scanning functionality.
     *////////////////////////////////////////////////////////////////////////////////
    
    // Called when the user presses "Scan Barcodes".
    @IBAction func scanBarcodes(_ sender: Any) {
        self.view.endEditing(false)
        self.navigationItem.setHidesBackButton(true, animated: false)
        disableAllFields() // We don't want the user to be able to press anything in the form while the camera is running.
        
        // Determine if the user has selected whether to allow access to their camera or not and act accordingly.
        let cameraAuthStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        // They've disallowed access to the camera. Let them know how to allow access through their device settings.
        if cameraAuthStatus == .denied {
            let message = "Scanning barcodes requires access to your phone's camera. To allow the app to access your camera:\n1. Exit out of the app.\n2. Go to your device settings.\n3. Click on \"Sampling\".\n4. Turn camera access on."
            displayNotification(message: message)
            enableAllFields() // Re-enable all fields, buttons, and scrolling.
            
        } else if cameraAuthStatus == .notDetermined {
            // We prompt them first to make sure they didn't press the button by accident. We do this
            // because it is likely that people will see the system's allow access popup and then accidentally
            // press no, in which case the only way to allow access will be through their device settings.
            let confirmController = UIAlertController(title: "Scanning barcodes requires using your devices camera. Do you want to allow the app to access your camera?", message: "", preferredStyle: UIAlertControllerStyle.alert)
            
            let yes = UIAlertAction(title: "Yes", style: .default) { (_) in
                // Only after they've responded affirmatively to our prompt, give them the system's.
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { response in
                    if response {
                        // Failure to use this causes an issue having to do with threads.
                        DispatchQueue.main.async {
                            self.startCamera()
                        }
                    } else {
                        // Failure to use this causes an issue having to do with threads.
                        DispatchQueue.main.async {
                            self.enableAllFields() // Re-enable all fields, buttons, and scrolling.
                        }
                    }
                }
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
                self.enableAllFields() // Re-enable all fields, buttons, and scrolling.
            }
            
            confirmController.addAction(yes)
            confirmController.addAction(cancel)
            
            self.present(confirmController, animated: true, completion: nil)
            
        // They've allowed access to the camera.
        } else {
            startCamera()
        }
    }
    
    func startCamera() {
        // The device (camera) that will capture the video.
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set up a "capture session" to receive data from the camera.
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeEAN8Code]
            
            // Add a camera view (layer) to the screen.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Add the done button to the navigation bar.
            let exitCameraItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(closeCamera))
            self.navigationItem.rightBarButtonItem = exitCameraItem
            
            captureSession?.startRunning()
            
        } catch {
            self.enableAllFields()
            return
        }
    }
    
    // This function receives data from the camera and sees if a barcode was detected.
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        if metadataObjects == nil || metadataObjects.count == 0 {
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        // If a barcode (of type EAN8) was detected, call the function that deals with it.
        if metadataObj.type == AVMetadataObjectTypeEAN8Code {
            barcodeDetected(code: metadataObj.stringValue)
        }
        
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        
        // Stop the camera from capturing output while user interacts with prompt.
        captureSession?.stopRunning()
    }
    
    @IBAction func closeCamera(sender: Any) {
        // Stop camera from capturing input.
        captureSession?.stopRunning()
        // Remove Done button.
        exitCameraButton?.removeFromSuperview()
        // Close the camera.
        videoPreviewLayer?.removeFromSuperlayer()
        // Add the back button back.
        self.navigationItem.setHidesBackButton(false, animated: false)
        // Re-enable all fields, buttons, and scrolling.
        self.enableAllFields()
        // Add the delete button back.
        let deleteFormItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.trash, target: self, action: #selector(self.deleteFormPrompt))
        deleteFormItem.tintColor = UIColor.red
        self.navigationItem.rightBarButtonItem = deleteFormItem
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    // Called when a barcode was detected. Pops up an alert that allows
    // a user to decide whether to keep the barcode for the form or not.
    func barcodeDetected(code: String) {
        
        // Although the Done button is disabled automatically when the popup is presented,
        // after the user selects an option there is a small window of opportunity where the
        // user can confuse the app. So, we temporarily disable the button and then enable
        // it again once the alert action has finished executing.
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        let alert:UIAlertController
        
        // If the barcode has already been scanned.
        if (form?.barcodes as! Array<String>).contains(code) {
            alert = UIAlertController(title: "This barcode is already part of the form.", message: code, preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in
                if !(self.captureSession?.isRunning)! {
                    self.captureSession?.startRunning()
                }
                
                // Reenable the Done button.
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }))
        } else {
            alert = UIAlertController(title: "Found a barcode!", message: code, preferredStyle: UIAlertControllerStyle.alert)
            
            // Do not keep the barcode for the form.
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: { action in
                if !(self.captureSession?.isRunning)! {
                    self.captureSession?.startRunning()
                }
                
                // Reenable the Done button.
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }))
            
            // Keep the barcode for the form, add it to the form's list of barcodes.
            alert.addAction(UIAlertAction(title: "Keep", style: UIAlertActionStyle.default, handler: { action in
                let trimmedCode = code.trimmingCharacters(in: .whitespaces)
                var barcodes = self.form?.barcodes as! Array<String>
                if !barcodes.contains(trimmedCode) {
                    barcodes.append(trimmedCode)
                    self.form?.barcodes = barcodes as NSArray
                }

                if !(self.captureSession?.isRunning)! {
                    self.captureSession?.startRunning()
                }
                
                // Reenable the Done button.
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }))
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // Disable all fields, buttons, and scrolling.
    func disableAllFields() {
        // Disable form fields.
        formName.isEnabled = false
        sampleType.isEnabled = false
        ageOfBird.isEnabled = false
        birdType.isEnabled = false
        vetSurgeon.isEnabled = false
        labRefNo.isEnabled = false
        companyName.isEnabled = false
        farmName.isEnabled = false
        email.isEnabled = false
        sampleCode.isEnabled = false
        vetPractice.isEnabled = false
        shedSampled.isEnabled = false
        zipPostCounty.isEnabled = false
        
        // Disable buttons.
        scanBarcodesButton.isEnabled = false
        manageBarcodesButton.isEnabled = false
        selectSymptomsButton.isEnabled = false
        selectVaccinationsButton.isEnabled = false
        saveChangesButton.isEnabled = false
        createCopyButton.isEnabled = false
        
        // Disable scrolling.
        tableView.isScrollEnabled = false
    }
    
    // Enable all fields, buttons, and scrolling.
    func enableAllFields() {
        // Disable form fields.
        formName.isEnabled = true
        sampleType.isEnabled = true
        ageOfBird.isEnabled = true
        birdType.isEnabled = true
        vetSurgeon.isEnabled = true
        labRefNo.isEnabled = true
        companyName.isEnabled = true
        farmName.isEnabled = true
        email.isEnabled = true
        sampleCode.isEnabled = true
        vetPractice.isEnabled = true
        shedSampled.isEnabled = true
        zipPostCounty.isEnabled = true
        
        // Disable buttons.
        scanBarcodesButton.isEnabled = true
        manageBarcodesButton.isEnabled = true
        selectSymptomsButton.isEnabled = true
        selectVaccinationsButton.isEnabled = true
        saveChangesButton.isEnabled = true
        createCopyButton.isEnabled = true
        
        // Disable scrolling.
        tableView.isScrollEnabled = true
    }
    
    /*
     * Picker view functions.
     *////////////////////////////////////////////////////////////////////////////////
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerSelection = pickerData[row]
    }
    
    func pickerCancel() {
        if(fieldSelected == TYPE_OF_BIRD) {
            birdType.resignFirstResponder()
        } else if(fieldSelected == TYPE_OF_SAMPLE) {
            sampleType.resignFirstResponder()
        }
    }
    
    func pickerSelect() {
        if(fieldSelected == TYPE_OF_BIRD) {
            birdType.text = pickerSelection
            birdType.resignFirstResponder()
        } else if(fieldSelected == TYPE_OF_SAMPLE) {
            sampleType.text = pickerSelection
            sampleType.resignFirstResponder()
        }
    }
    
    /*
     * Text field functions.
     *////////////////////////////////////////////////////////////////////////////////
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if(textField.tag != AGE_OF_BIRD && textField.tag != TYPE_OF_BIRD && textField.tag != TYPE_OF_SAMPLE) {
            return true
        }
        
        if(textField.tag == AGE_OF_BIRD) {
            fieldSelected = AGE_OF_BIRD
            return true
        } else if(textField.tag == TYPE_OF_BIRD) {
            self.view.endEditing(false)
            fieldSelected = TYPE_OF_BIRD
            pickerData = ["Broiler", "Broiler Parent", "Layer", "Layer Parent", "Other"]
        } else if(textField.tag == TYPE_OF_SAMPLE) {
            self.view.endEditing(false)
            fieldSelected = TYPE_OF_SAMPLE
            pickerData = ["Tracheal", "Spleen", "Blood", "Feather Pulp", "Other"]
        }
        
        pickerView.reloadAllComponents()
        if(textField.text != nil && textField.text != "") {
            let index = pickerData.index(of: textField.text!)
            if(index != nil) {
                pickerView.selectRow(index!, inComponent: 0, animated: true)
                pickerSelection = textField.text
            }
        } else {
            pickerView.selectRow(0, inComponent: 0, animated: true)
            pickerSelection = pickerData[0]
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(false)
        return false
    }
    
    // When the delete button is pressed, prompt the user as to whether they really want to delete the form.
    @IBAction func deleteFormPrompt(sender: Any) {
        
        let deleteController = UIAlertController(title: "Are you sure you want to delete this form?", message: "This action cannot be undone.", preferredStyle: UIAlertControllerStyle.alert)
        
        let enter = UIAlertAction(title: "Yes", style: .destructive) { (_) in
            self.deleteForm()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        deleteController.addAction(enter)
        deleteController.addAction(cancel)
        
        self.present(deleteController, animated: true, completion: nil)
    }
    
    // Delete the form.
    func deleteForm() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        context.delete(form!)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController?.popViewController(animated: true)
    }

}
