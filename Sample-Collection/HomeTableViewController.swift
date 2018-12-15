//
//  TableViewController.swift
//  RG Samples
//
//  Created by Joseph Tocco on 8/14/17.
//  Copyright © 2017 Joseph Ryan Tocco. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

class HomeTableViewController: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate, AVCaptureMetadataOutputObjectsDelegate, SymptomDelegate, VaccinationDelegate, BarcodeDelegate, ImageViewControllerDelegate {
   
    /*
     * Set up global variables.
     */////////////////////////////////////////////////////////////////////////////////////////////////
    
    // Field references.
    @IBOutlet weak var formName: UITextField!
    @IBOutlet weak var testType: UITextField!
    @IBOutlet weak var typeOfBird: UITextField!
    @IBOutlet weak var ageOfBird: UITextField!
    @IBOutlet weak var typeOfSample: UITextField!
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
    @IBOutlet weak var selectClinicalSignsButton: UIButton!
    @IBOutlet weak var selectVaccinationsButton: UIButton!
    @IBOutlet weak var clearFormButton: UIButton!
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var gesture1: UITapGestureRecognizer!
    @IBOutlet weak var gesture2: UITapGestureRecognizer!
    
    var pickerView:UIPickerView!
    var pickerSelection:String!
    
    var symptoms:Array<String> = []
    var vaccinations:Array<Vaccination> = []
    var symptomNotes:String = ""
    var vaccinationNotes:String = ""
    
    // Constants.
    let TYPE_OF_BIRD = 1
    let AGE_OF_BIRD = 2
    let TYPE_OF_SAMPLE = 3
    let TEST_TYPE = 4
    
    var fieldSelected = 0
    
    var scannedBarcodes:[String] = [String]()
    var pickerData: [String] = [String]()
    
    // Barcode scanner stuff.
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var exitCameraButton:UIButton?
    
    // Geo-location stuff
    var locationManager = CLLocationManager()
    var latittude: String = ""
    var longitude: String = ""
    
    var setImageView: UIImageView!
    
    public func didComeInForeground() {
        print(CLLocationManager.locationServicesEnabled())
        if CLLocationManager.locationServicesEnabled() {
            enableBasicLocationServices()
        } else {
            enableLocation()
        }
    }
    
    public func didGoInBackground() {
        locationManager.stopUpdatingLocation()
    }
    /*
     * Overrided view functions.
     */////////////////////////////////////////////////////////////////////////////////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didComeInForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil);
        
        NotificationCenter.default.addObserver(self, selector: #selector(didGoInBackground), name: NSNotification.Name.UIApplicationWillResignActive, object: nil);
        
        if !CLLocationManager.locationServicesEnabled() {
            enableLocation()
        } else {
            enableBasicLocationServices()
        }
        
        // When we transition to this page from the edit page, we need to set the tab to the first one.
        let tabBarController = self.navigationController?.tabBarController!
        tabBarController?.selectedIndex = 0
        
        self.navigationItem.title = "Form (New)"
        
        // Set up picker view.
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
        self.typeOfBird.inputView = self.pickerView
        self.typeOfBird.inputAccessoryView = toolBar
        self.typeOfSample.inputView = self.pickerView
        self.typeOfSample.inputAccessoryView = toolBar
        self.testType.inputView = self.pickerView
        self.testType.inputAccessoryView = toolBar
        
        self.ageOfBird.delegate = self
        self.typeOfBird.delegate = self
        self.typeOfSample.delegate = self
        self.testType.delegate = self
        
        // So we can tell which one is which.
        self.ageOfBird.tag = AGE_OF_BIRD
        self.typeOfBird.tag = TYPE_OF_BIRD
        self.typeOfSample.tag = TYPE_OF_SAMPLE
        self.testType.tag = TEST_TYPE
        
        self.formName.delegate = self
        self.ageOfBird.delegate = self
        self.vetSurgeon.delegate = self
        self.labRefNo.delegate = self
        self.companyName.delegate = self
        self.farmName.delegate = self
        self.email.delegate = self
        self.sampleCode.delegate = self
        self.vetPractice.delegate = self
        self.shedSampled.delegate = self
        self.zipPostCounty.delegate = self
        
        image1.layer.borderColor = UIColor.gray.cgColor
        image1.layer.borderWidth = 1
        
        image2.layer.borderColor = UIColor.gray.cgColor
        image2.layer.borderWidth = 1
        
        
        // Add save button to top right.
        let saveFormItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(saveForm))
        self.navigationItem.rightBarButtonItem = saveFormItem
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        closeCamera(sender: self)
        
        self.view.endEditing(false) // Close keyboard if open.
    }
    
    // Send data to the page that the user is moving to.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // If the user is going to the page to view the symptoms for this form.
        if let viewController = segue.destination as? SymptomViewController {
            
            // Set the symptoms and notes in the symptoms page.
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
            
            viewController.notes = symptomNotes
            
            viewController.delegate = self
            
            // If the user is going to the page to view the vaccinations for this form.
        } else if let viewController = segue.destination as? VaccinationViewController {
            
            // Set the vaccinations and notes in the vaccinations page.
            for vax in vaccinations {
                let index = viewController.vaccinations.index(where: { (v) -> Bool in
                    v.name == vax.name
                })
                viewController.vaccinations[index!] = vax
            }
            
            viewController.notes = vaccinationNotes
            
            viewController.delegate = self
            
            // If the user is going to the page to view the barcodes for this form.
        } else if let viewController = segue.destination as? BarcodeTableViewController {
            
            // Set the barcodes in the manage barcodes page.
            viewController.barcodes = scannedBarcodes
            viewController.delegate = self
        } else if let viewController = segue.destination as? ImageViewController {
            if segue.identifier == "image1" {
                self.setImageView = image1
                viewController.image = image1.image
            } else if segue.identifier == "image2" {
                self.setImageView = image2
                viewController.image = image2.image
            }
            viewController.delegate = self
        }
    }
    
    /*
     * Delegate functions for navigating back to this page (basically a reverse segue).
     */////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func setSymptoms(symptoms: Array<String>, notes: String) {
        self.symptoms = symptoms
        self.symptomNotes = notes
    }
    
    func setVaccinations(vaccinations: Array<Vaccination>, notes: String) {
        self.vaccinations = vaccinations
        self.vaccinationNotes = notes
    }
    
    func setBarcodes(barcodes: Array<String>) {
        self.scannedBarcodes = barcodes
    }
    
    // To enable location service it check the authorization status in the begining and then takes appropriate action
    func enableBasicLocationServices() {
        
        locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
            
        case .notDetermined:
            // Request when-in-use authorization initially
            requestAuthorization()
            break
        
        case .restricted:
            print("enableBasicLocationService: Restricted")
            break
            
        case .denied:
            print("enableBasicLocationService: Denied")
            showLocationDisabledPopUp()
            break
            
        case .authorizedWhenInUse, .authorizedAlways:
            print("enableBasicLocationService: authorizedWhenInUse or authorizedAlways")
            setLocationManagerVariables()
            break
        }
    }
    
    // Request when-in-use authorization
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    // Sets the locaiton manager variables.
    // Sets desired Accuracy to kcLocationAcuuracyBest and Starts updating location.
    func setLocationManagerVariables() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // Calls the didUpade locaiton of location manager to get the coordinates.
        locationManager.startUpdatingLocation()
    }
    
    //  An array of CLLocation objects containing the location data. This array always contains at least one object representing the current location. If updates were deferred or if multiple locations arrived before they could be delivered, the array may contain additional entries. The objects in the array are organized in the order in which they occurred. Therefore, the most recent location update is at the end of the array.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // locations.last because the documentation says that last entry in the array is most recent loation update
        if let location = locations.last {
            
            latittude = String(format: "%f", location.coordinate.latitude)
            longitude = String(format: "%f", location.coordinate.longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print("didFailWithError ", error)
    }
    
    func utilityFunctioToShowSystemMessage() {
        print("Utility function called")
    }
    
    //Called when location serice is not denied when application is opened or application becomes active i.e. when the application comes from backround to foreground.
    func showLocationDisabledPopUp() {
        let alertController = UIAlertController(title: "Application location Access Denied", message:
            "To share loation with us click on Settings and then allow when in use authorization to the application. Click on cancel, if you don't want to share the location.", preferredStyle: .alert)
        
        let openAction = UIAlertAction(title: "Settings", style: .default) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //Called when location service is turned off.
    func enableLocation() {
        let alertController = UIAlertController(title: "System location Access Denied", message:
            "To share location with us click on Settings and then turn on the System location service. Click on cancel, if you don't want to share the location.", preferredStyle: .alert)
        
        let openAction = UIAlertAction(title: "Settings", style: .default) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
//            UIApplication.shared.open(URL(string: "App-Prefs:root=General")!, options: [:], completionHandler: nil)
        }
        alertController.addAction(openAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    /*
     * Save Form button.
     */////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    @IBAction func saveForm(_ sender: Any) {
        
        self.view.endEditing(false) // Close keyboard if open.
        
        // If the user has not scanned barcodes.
        
         if !(scannedBarcodes.count > 0) {
             displayNotification(message: "Form must contain at least one barcode.")
             return
         }

        // If the user did not specify a Form Name.
        if formName.text == nil || formName.text == "" {
            displayNotification(message: "You must specify a Form Name.")
            return
        }
        
        // Present a popup asking if the user is sure they want to save the form.
        let saveController = UIAlertController(title: "Save form locally?", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        let yes = UIAlertAction(title: "Yes", style: .default) { (_) in
            // Save the form.
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let form = Form(context: context)
            
            form.formName = self.formName.text
            form.age = self.ageOfBird.text
            form.barcodes = self.scannedBarcodes as NSArray
            form.birdType = self.typeOfBird.text
            form.sampleType = self.typeOfSample.text
            form.vetSurgeon = self.vetSurgeon.text
            form.labRefNo = self.labRefNo.text
            form.companyName = self.companyName.text
            form.farmName = self.farmName.text
            form.email = self.email.text
            form.sampleCode = self.sampleCode.text
            form.vetPractice = self.vetPractice.text
            form.shedSampled = self.shedSampled.text
            form.zipPostCounty = self.zipPostCounty.text
            form.symptoms = self.symptoms as NSArray
            form.vaccinations = self.vaccinations as NSArray
            
            form.symptomNotes = self.symptomNotes
            form.vaccinationNotes = self.vaccinationNotes
            
            form.latitude = self.latittude
            form.longitude = self.longitude
            
            form.hatcherySource = self.hatcherySource.text
            
            form.savedDate = NSDate()
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            self.scannedBarcodes = [] // Empty the barcodes array.
            self.formName.text = "" // Clear the form name.
            self.ageOfBird.text = ""
            self.typeOfBird.text = ""
            self.typeOfSample.text = ""
            self.vetSurgeon.text = ""
            self.labRefNo.text = ""
            self.companyName.text = ""
            self.farmName.text = ""
            self.email.text = ""
            self.sampleCode.text = ""
            self.vetPractice.text = ""
            self.shedSampled.text = ""
            self.zipPostCounty.text = ""
            self.hatcherySource.text = ""
            self.symptoms = []
            self.vaccinations = []
            
            self.displayNotification(message: "Saved!")
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        saveController.addAction(yes)
        saveController.addAction(cancel)
        
        self.present(saveController, animated: true, completion: nil)
    }
    
    // Display a simple notification. The variable message is what will be displayed.
    func displayNotification(message: String) {
        let messageController = UIAlertController(title: message, message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        let ok = UIAlertAction(title: "OK", style: .default) { (_) in }
        messageController.addAction(ok)
        
        self.present(messageController, animated: true, completion: nil)
    }
    
    // Clear the form of all data.
    @IBAction func clearForm(_ sender: Any) {
        self.view.endEditing(false) // Close keyboard if open.
        
        // Make sure the user actually wants to clear the form.
        let clearController = UIAlertController(title: "Are you sure you want to clear the form?", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        let clear = UIAlertAction(title: "Clear", style: .destructive) { (_) in
            self.formName.text = ""
            self.testType.text = ""
            self.typeOfSample.text = ""
            self.ageOfBird.text = ""
            self.typeOfBird.text = ""
            self.vetSurgeon.text = ""
            self.labRefNo.text = ""
            self.companyName.text = ""
            self.farmName.text = ""
            self.email.text = ""
            self.sampleCode.text = ""
            self.vetPractice.text = ""
            self.shedSampled.text = ""
            self.zipPostCounty.text = ""
            self.hatcherySource.text = ""
            
            self.scannedBarcodes = []
            self.symptoms = []
            self.vaccinations = []
            self.symptomNotes = ""
            self.vaccinationNotes = ""
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        clearController.addAction(clear)
        clearController.addAction(cancel)
        
        self.present(clearController, animated: true, completion: nil)
    }
    
    /*
     * Barcode scanning functionality.
     */////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // Called when the user presses "Scan Barcodes".
    @IBAction func scanBarcode(_ sender: Any) {
        self.view.endEditing(false) // Close keyboard if open.
        disableAllFields() // We don't want the user to be able to press buttons, open fields, and scroll while the camera is running.
        
        // Determine if the user has selected whether to allow access to their camera or not and act accordingly.
        let cameraAuthStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        // They've disallowed access to the camera. Let them know how to allow access through their device settings.
        if cameraAuthStatus == .denied {
            let message = "Scanning barcodes requires access to your phone's camera. To allow the app to access your camera:\n1. Exit out of the app.\n2. Go to your device settings.\n3. Click on \"Sampling\".\n4. Turn camera access on."
            displayNotification(message: message)
            enableAllFields() // Re-enable the fields, buttons, and scrolling.
            
            // They haven't chosen whether to allow access to the camera yet.
        } else if cameraAuthStatus == .notDetermined {
            // We prompt them first to make sure they didn't press the button by accident. We do this
            // because it is likely that people will see the system's allow access popup and then accidentally
            // press no, in which case the only way to allow access will be through their device settings.
            let confirmController = UIAlertController(title: "Scanning barcodes requires using your devices camera. Do you want to allow the app to access your camera?", message: "", preferredStyle: UIAlertControllerStyle.alert)
            
            let yes = UIAlertAction(title: "Yes", style: .default) { (_) in
                // Only after they've responded affirmatively to our prompt, give them the system's.
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { response in
                    // If the user allows access.
                    if response {
                        // Failure to use this causes an issue having to do with threads.
                        DispatchQueue.main.async {
                            self.startCamera()
                        }
                    } else {
                        // Failure to use this causes an issue having to do with threads.
                        DispatchQueue.main.async {
                            self.enableAllFields() // Re-enable the fields, buttons, and scrolling.
                        }
                    }
                }
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
                self.enableAllFields() // Re-enable the fields, buttons, and scrolling.
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
            self.enableAllFields() // Re-enable fields, buttons, and scrolling.
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
        // Add the save button back.
        let saveFormItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(saveForm))
        self.navigationItem.rightBarButtonItem = saveFormItem
        self.enableAllFields() // Re-enable all fields and buttons.
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
        if self.scannedBarcodes.contains(code) {
            alert = UIAlertController(title: "This barcode is already part of the form.", message: code, preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
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
            
            // Keep the barcode for the form, add it to the list scannedBarcodes
            alert.addAction(UIAlertAction(title: "Keep", style: UIAlertActionStyle.default, handler: { action in
                let trimmedCode = code.trimmingCharacters(in: .whitespaces)
                if !self.scannedBarcodes.contains(trimmedCode) {
                    self.scannedBarcodes.append(trimmedCode)
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
    
    // Disable all buttons, form fields, and scrolling.
    func disableAllFields() {
        // Disable fields.
        formName.isEnabled = false
        testType.isEnabled = false
        typeOfBird.isEnabled = false
        ageOfBird.isEnabled = false
        typeOfSample.isEnabled = false
        vetSurgeon.isEnabled = false
        labRefNo.isEnabled = false
        companyName.isEnabled = false
        farmName.isEnabled = false
        email.isEnabled = false
        sampleCode.isEnabled = false
        vetPractice.isEnabled = false
        shedSampled.isEnabled = false
        zipPostCounty.isEnabled = false
        hatcherySource.isEnabled = false
        
        // Disable buttons.
        scanBarcodesButton.isEnabled = false
        manageBarcodesButton.isEnabled = false
        selectClinicalSignsButton.isEnabled = false
        selectVaccinationsButton.isEnabled = false
        clearFormButton.isEnabled = false
        
        // Disable scrolling.
        tableView.isScrollEnabled = false
    }
    
    // Enable all buttons, form fields, and scrolling.
    func enableAllFields() {
        // Enable fields.
        formName.isEnabled = true
        testType.isEnabled = true
        typeOfBird.isEnabled = true
        ageOfBird.isEnabled = true
        typeOfSample.isEnabled = true
        vetSurgeon.isEnabled = true
        labRefNo.isEnabled = true
        companyName.isEnabled = true
        farmName.isEnabled = true
        email.isEnabled = true
        sampleCode.isEnabled = true
        vetPractice.isEnabled = true
        shedSampled.isEnabled = true
        zipPostCounty.isEnabled = true
        hatcherySource.isEnabled = true
        
        // Enable buttons.
        scanBarcodesButton.isEnabled = true
        manageBarcodesButton.isEnabled = true
        selectClinicalSignsButton.isEnabled = true
        selectVaccinationsButton.isEnabled = true
        clearFormButton.isEnabled = true
        
        // Enable scrolling.
        tableView.isScrollEnabled = true
    }
    
    /*
     * Picker view functions.
     */////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
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
            typeOfBird.resignFirstResponder()
        } else if(fieldSelected == TYPE_OF_SAMPLE) {
            typeOfSample.resignFirstResponder()
        } else if(fieldSelected == TEST_TYPE) {
            testType.resignFirstResponder()
        }
    }
    
    func pickerSelect() {
        if(fieldSelected == TYPE_OF_BIRD) {
            typeOfBird.text = pickerSelection
            typeOfBird.resignFirstResponder()
        } else if(fieldSelected == TYPE_OF_SAMPLE) {
            typeOfSample.text = pickerSelection
            typeOfSample.resignFirstResponder()
        } else if(fieldSelected == TEST_TYPE) {
            testType.text = pickerSelection
            testType.resignFirstResponder()
        }
    }
    
    /*
     * Text field functions.
     */////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if(textField.tag != AGE_OF_BIRD && textField.tag != TYPE_OF_BIRD && textField.tag != TYPE_OF_SAMPLE && textField.tag != TEST_TYPE) {
            return true
        }
        
        if(textField.tag == AGE_OF_BIRD) {
            fieldSelected = AGE_OF_BIRD
            return true
        } else if(textField.tag == TYPE_OF_BIRD) {
            fieldSelected = TYPE_OF_BIRD
            pickerData = ["Broiler", "Broiler Parent", "Layer", "Layer Parent", "Other"]
        } else if(textField.tag == TYPE_OF_SAMPLE) {
            fieldSelected = TYPE_OF_SAMPLE
            pickerData = ["Tracheal", "Spleen", "Blood", "Feather Pulp", "Other"]
        } else if(textField.tag == TEST_TYPE) {
            fieldSelected = TEST_TYPE
            pickerData = ["Innovax ILT vaccine take", "ILT field virus", "IBD field virus", "Innovax ND vaccine take"]
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
        self.view.endEditing(false) // Close keyboard if open.
        return false
    }
    // ImageViewControllerDelegate functions
    func sendImageData(_ image: UIImage) {
        self.setImageView.image = image
    }
}




































