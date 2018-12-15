//
//  ManageFormsViewController.swift
//  RG Samples
//
//  Created by Joseph Ryan Tocco on 7/28/17.
//  Copyright © 2017 Joseph Ryan Tocco. All rights reserved.
//

import UIKit
import MessageUI

class ManageFormsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var viewButton: UIButton!
    @IBOutlet weak var formTable: UITableView!
    @IBOutlet weak var unsubmittedFormsButton: UIButton!
    @IBOutlet weak var submittedFormsButton: UIButton!
    @IBOutlet weak var submitSelectedButton: UIButton!
    @IBOutlet weak var topButtonsView: UIStackView!
    
    var unsubmittedForms:Array<Form> = []
    var submittedForms:Array<Form> = []
    var formsToDisplay:Array<Form> = []
    var unsubmittedDates:Array<String> = []
    var submittedDates:Array<String> = []
    var datesToDisplay:Array<String> = []
    var formSelectedTracker:Dictionary = [NSObject: Bool]()
    var dateSelectedTracker:Dictionary = [String: Bool]()
    var username:String?
    var password:String?
    
    var mailController = MFMailComposeViewController()
    
    var submittedSelected = false
    var selectedDate:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Manage Forms"
        
        mailController.mailComposeDelegate = self
        
        formTable.delegate = self
        formTable.dataSource = self
        
        showUnsubmittedTable(self)
        
        // Set a border for the top buttons.
        unsubmittedFormsButton.layer.borderWidth = 1.0
        submittedFormsButton.layer.borderColor = UIColor.black.cgColor
        submittedFormsButton.layer.borderWidth = 1.0
        submittedFormsButton.layer.borderColor = UIColor.black.cgColor
        
        // Add select all button to top right.
        let saveFormItem = UIBarButtonItem(title: "Select All", style: .plain, target: self, action: #selector(selectAllCells))
        self.navigationItem.rightBarButtonItem = saveFormItem
        
        // Add a button to top left to allow the user to go back to viewing groups of forms after selecting a date.
        let viewGroupsItem = UIBarButtonItem(title: "By Date", style: .plain, target: self, action: #selector(viewGroups))
        self.navigationItem.leftBarButtonItem = viewGroupsItem
        self.navigationItem.leftBarButtonItem?.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadForms()
        
        showUnsubmittedTable(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Prepare for switch to view sample.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        let sampleViewController = segue.destination as? SampleViewController
        
        let selectedCell = sender as! UITableViewCell
        let indexPath = formTable.indexPath(for: selectedCell)
        
        let selectedForm:Form?
        if submittedSelected == false {
            selectedForm = unsubmittedForms[(indexPath?.row)!]
        } else {
            selectedForm = submittedForms[(indexPath?.row)!]
        }
        sampleViewController?.form = selectedForm
        formTable.reloadData()
    }
    
    func loadForms() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        context.reset() // We reset the context so that any changes made thus far that haven't been saved will be removed.
        
        do {
            let forms:Array<Form> = try context.fetch(Form.fetchRequest())
            
            // Create an array of all submitted forms and an array of all unsubmitted forms.
            submittedForms = []
            unsubmittedForms = []
            for form in forms.reversed() {
                formSelectedTracker[form.objectID] = false
                if form.submitted {
                    submittedForms.append(form)
                } else {
                    unsubmittedForms.append(form)
                }
            }
            
            // Create an array of dates that submitted forms were created on
            // and an array of dates that unsubmitted forms were created on.
            submittedDates = submittedForms.map { nsDateAsDay(date: $0.savedDate!) } // Array of dates when submitted forms were created.
            submittedDates = Array(Set(submittedDates)) // Now all dates in the array are unique.
            unsubmittedDates = unsubmittedForms.map { nsDateAsDay(date: $0.savedDate!) } // Array of dates when unsubmitted forms were created.
            unsubmittedDates = Array(Set(unsubmittedDates)) // Now all dates in the array are unique.
            datesToDisplay = submittedSelected ? submittedDates : unsubmittedDates
            
            // If the table is currently showing forms (instead of dates) we need to change the displayed forms based on the data just loaded in.
            if selectedDate != nil && selectedDate != "" {
                if submittedSelected == true {
                    formsToDisplay = submittedForms.filter { nsDateAsDay(date: $0.savedDate!) == selectedDate }
                } else {
                    formsToDisplay = unsubmittedForms.filter { nsDateAsDay(date: $0.savedDate!) == selectedDate }
                }
            }
            
            DispatchQueue.main.async {
                self.formTable.reloadData()
            }
        } catch {
            print("Could not retrieve data")
        }
    }
    
    // Takes in an NSDate and returns a string in M-d-yyyy format.
    func nsDateAsDay(date: NSDate) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "M-d-yyyy"
        return dateFormatter.string(from: date as Date)
    }
    
    func selectAllCells() {
        if selectedDate == nil || selectedDate == "" {
            var allAreSelected = true
            // Determine if all dates have been selected.
            for date in datesToDisplay {
                let isSelected = dateSelectedTracker[date]
                if isSelected == nil || isSelected == false {
                    allAreSelected = false
                }
            }
            
            // Set all switches as selected or all as unselected in the tracker dictionary.
            for date in datesToDisplay {
                dateSelectedTracker[date] = !allAreSelected
            }
            
            // Set all cells being displayed to match the values decided on above.
            for cell in formTable.visibleCells {
                let switchView = cell.accessoryView as! UISwitch
                switchView.setOn(!allAreSelected, animated: true)
            }
        } else {
            var allAreSelected = true
            // Determine if all forms have been selected.
            for form in formsToDisplay {
                let isSelected = formSelectedTracker[form.objectID]
                if isSelected == nil || isSelected == false {
                    allAreSelected = false
                }
            }
            
            // Set all switches as selected or all as unselected in the tracker dictionary.
            for form in formsToDisplay {
                formSelectedTracker[form.objectID] = !allAreSelected
            }
            
            // Set all cells being displayed to match the values decided on above.
            for cell in formTable.visibleCells {
                let switchView = cell.accessoryView as! UISwitch
                switchView.setOn(!allAreSelected, animated: true)
            }
        }
    }
    
    func getSelectedForms() -> Array<Form> {
        var selectedForms: Array<Form> = []
        
        // If the date table is displayed.
        if selectedDate == nil || selectedDate == "" {
            // Combine all of the forms for each of the dates that have been selected in the current table.
            if submittedSelected == true {
                for form in submittedForms {
                    if dateSelectedTracker[nsDateAsDay(date: form.savedDate!)] == true {
                        selectedForms.append(form)
                    }
                }
            } else {
                for form in unsubmittedForms {
                    if dateSelectedTracker[nsDateAsDay(date: form.savedDate!)] == true {
                        selectedForms.append(form)
                    }
                }
            }
            
        // If the forms table is displayed
        } else {
            // All forms in the current table that have been selected.
            selectedForms = formsToDisplay.filter { formSelectedTracker[$0.objectID] == true }
        }
        
        return selectedForms
    }
    
    /*
     * Methods for saving the forms.
     */
    
    func formsOkToSubmit(forms: Array<Form>) -> Bool {
        // Check if any forms were selected.
        if forms.count == 0 {
            displayNotification(message: "No forms selected.")
            return false
        }
        
        // Check if any forms don't contain barcodes.
        var formsWithNoBarcodes:Array<String> = []
        for form in forms {
            if form.barcodes == nil || (form.barcodes as! NSArray).count == 0 {
                formsWithNoBarcodes.append(form.formName!)
            }
        }
        if formsWithNoBarcodes.count > 0 {
            var message = "The email will not be sent because the following form(s) do not contain barcodes:"
            for formName in formsWithNoBarcodes {
                message += (" " + formName)
            }
            displayNotification(message: message)
            return false
        }
        
        return true
    }
    
    @IBAction func showLoginPopup(_ sender: Any) {
        
        let forms = getSelectedForms()
        
        if !formsOkToSubmit(forms: forms) {
            return
        }
        
        let loginController = UIAlertController(title: "Enter Credentials", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        let enter = UIAlertAction(title: "Enter", style: .default) { (_) in
            self.username = loginController.textFields?[0].text
            self.password = loginController.textFields?[1].text
            self.postForms(formsToSave: forms)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        loginController.addTextField { (textField) in
            textField.placeholder = "Username"
        }
        
        loginController.addTextField { (textField) in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        
        loginController.addAction(enter)
        loginController.addAction(cancel)
        
        self.present(loginController, animated: true, completion: nil)
    }
    
    func postForms(formsToSave: Array<Form>) {
        
        // Structure the data as JSON.
        do {
            var dictArray:Array<NSDictionary> = []
            for form in formsToSave {
                
                var vaccinations:Array<NSDictionary> = []
                for vax in form.vaccinations as! NSArray {
                    let vaxDict:NSDictionary = [
                        "name": (vax as! Vaccination).name!,
                        "age": (vax as! Vaccination).age!,
                        "doses": (vax as! Vaccination).doses!,
                        "administration": (vax as! Vaccination).administration!
                    ]
                    vaccinations.append(vaxDict)
                }
                
                // The current time.
                let sentDate = NSDate()
                
                let dict:NSDictionary = [
                    "age": form.age! as NSString,
                    "barcodes": (form.barcodes as! NSArray),
                    "birdType": form.birdType! as NSString,
                    "companyName": form.companyName! as NSString,
                    "email": form.email! as NSString,
                    "farmName": form.farmName! as NSString,
                    "formName": form.formName! as NSString,
                    "labRefNo": form.labRefNo! as NSString,
                    "sampleCode": form.sampleCode! as NSString,
                    "sampleType": form.sampleType! as NSString,
                    "shedSampled": form.shedSampled! as NSString,
                    "symptoms": (form.symptoms as! NSArray),
                    "vaccinations": vaccinations,
                    "symptomNotes": form.symptomNotes! as NSString,
                    "vaccinationNotes": form.vaccinationNotes! as NSString,
                    "vetPractice": form.vetPractice! as NSString,
                    "vetSurgeon": form.vetSurgeon! as NSString,
                    "zipPostCounty": form.zipPostCounty! as NSString,
                    "hatcherySourde": form.hatcherySource! as NSString,
                    "savedDate": form.savedDate!.timeIntervalSince1970,
                    "sentDate": sentDate.timeIntervalSince1970,
                    "longitude": form.longitude! as NSString,
                    "latitude": form.latitude! as NSString
                ]
                
                dictArray.append(dict)
            }
        
            let jsonData = try JSONSerialization.data(withJSONObject: dictArray, options: .prettyPrinted)

            // Sign in.
            
            var request = URLRequest(url: URL(string: "https://client.rgportal.com/api/auth/signin")!)
            request.httpMethod = "POST"
            let postString = "username=" + username! + "&password=" + password!
            request.httpBody = postString.data(using: .utf8)
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if error != nil {
                    self.displayNotification(message: "Couldn't Connect")
                    return
                }
                
                let httpStatus = response as! HTTPURLResponse
                
                if httpStatus.statusCode != 200 {
                    self.displayNotification(message: "Sign in failed")
                } else {
                        
                    // Send a post request with the sample forms.
                    var request2 = URLRequest(url: URL(string: "https://client.rgportal.com/api/forms")!)
                    request2.httpMethod = "POST"
                    request2.httpBody = jsonData
                    request2.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                    let task2 = URLSession.shared.dataTask(with: request2) { data2, response2, error2 in
                        if error2 != nil {
                            self.displayNotification(message: "An Error Occurred")
                            return
                        }
                        
                        if let httpStatus2 = response2 as? HTTPURLResponse, httpStatus2.statusCode != 200 {
                            self.displayNotification(message: "An Error Occurred")
                        } else {
                            self.displayNotification(message: "Sent!")

                            // Mark forms as submitted.
                            for form in formsToSave {
                                form.submitted = true
                            }
                            (UIApplication.shared.delegate as! AppDelegate).saveContext()
                            
                            self.loadForms()
                        }
                    }
                    task2.resume()
                    
                }
            }
            task.resume()
            
        } catch {
            self.displayNotification(message: "An Error Occurred")
        }
    }
    
    func formsOkToEmail(forms: Array<Form>) -> Bool {
        // Check if the user has email set up with their phone.
        if !MFMailComposeViewController.canSendMail() {
            displayNotification(message: "Set up your iOS device with email to have an email sent for your records")
            return false
        }
        
        // Check if any forms were selected.
        if forms.count == 0 {
            displayNotification(message: "No forms selected.")
            return false
        }
        
        // Check if any forms don't contain barcodes.
        var formsWithNoBarcodes:Array<String> = []
        for form in forms {
            if form.barcodes == nil || (form.barcodes as! NSArray).count == 0 {
                formsWithNoBarcodes.append(form.formName!)
            }
        }
        if formsWithNoBarcodes.count > 0 {
            var message = "The email will not be sent because the following form(s) do not contain barcodes:"
            for (index, formName) in formsWithNoBarcodes.enumerated() {
                var addition = " " + formName
                if index < formsWithNoBarcodes.count - 1 {
                    addition += ","
                }
                message += addition
            }
            displayNotification(message: message)
            return false
        }
        
        return true
    }
    
    @IBAction func emailSelected(_ sender: Any) {
        let forms = getSelectedForms()
        sendEmail(forms: forms)
    }
    
    func sendEmail(forms: Array<Form>) {
        if !formsOkToEmail(forms: forms) {
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd' at 'HH:mm a"
        
        mailController = MFMailComposeViewController()
        mailController.mailComposeDelegate = self
        
        var recipients:Array<String> = []
        
        var body = ""
        for form in forms {
            if form.email != nil && form.email != "" && !recipients.contains(form.email!) {
                recipients.append(form.email!)
            }
            
            body += "<table border=\"1\">"
            
            body += "<tr><th align=\"left\">Submitted: </th><td align=\"left\">\(form.submitted == true ? "True" : "False")</td></tr>"
            body += "<tr><th align=\"left\">Created: </th><td align=\"left\">\(dateFormatter.string(from: form.savedDate! as Date))</td></tr>"
            if form.submitted == true && form.submittedDate != nil {
                body += "<tr><th align=\"left\"Submitted: </th><td align=\"left\">\(dateFormatter.string(from: form.submittedDate! as Date))</td></tr>"
            }
            body += "<tr><th align=\"left\">Form Name: </th><td align=\"left\">\(form.formName != "" ? form.formName! : "N/A")</td></tr>"
            body += "<tr><th align=\"left\">Veterinary Practice: </th><td align=\"left\">\(form.vetPractice != "" ? form.vetPractice! : "N/A")</td></tr>"
            body += "<tr><th align=\"left\">Veterinary Surgeon: </th><td align=\"left\">\(form.vetSurgeon != "" ? form.vetSurgeon! : "N/A")</td></tr>"
            body += "<tr><th align=\"left\">Email: </th><td align=\"left\">\(form.email != "" ? form.email! : "N/A")</td></tr>"
            body += "<tr><th align=\"left\">Lab Ref. No.: </th><td align=\"left\">\(form.labRefNo != "" ? form.labRefNo! : "N/A")</td></tr>"
            body += "<tr><th align=\"left\">Sample Code: </th><td align=\"left\">\(form.sampleCode != "" ? form.sampleCode! : "N/A")</td></tr>"
            body += "<tr><th align=\"left\">Company Name: </th><td align=\"left\">\(form.companyName != "" ? form.companyName! : "N/A")</td></tr>"
            body += "<tr><th align=\"left\">Farm Name: </th><td align=\"left\">\(form.farmName != "" ? form.farmName! : "N/A")</td></tr>"
            body += "<tr><th align=\"left\">Zip Code/Postcode/County: </th><td align=\"left\">\(form.zipPostCounty != "" ? form.zipPostCounty! : "N/A")</td></tr>"
            body += "<tr><th align=\"left\">Shed Sampled: </th><td align=\"left\">\(form.shedSampled != "" ? form.shedSampled! : "N/A")</td></tr>"
            body += "<tr><th align=\"left\">Age of Birds: </th><td align=\"left\">\(form.age != "" ? form.age! : "N/A")</td></tr>"
            body += "<tr><th align=\"left\">Type of Bird: </th><td align=\"left\">\(form.birdType != "" ? form.birdType! : "N/A")</td></tr>"
            body += "<tr><th align=\"left\">Type of Sample: </th><td align=\"left\">\(form.sampleType != "" ? form.sampleType! : "N/A")</td></tr>"
            body += "<tr><th align=\"left\">Type of Sample: </th><td align=\"left\">\(form.hatcherySource != "" ? form.hatcherySource! : "N/A")</td></tr>"
            body += "<tr><th align=\"left\">Latitude: </th><td align=\"left\">\(form.latitude != "" ? form.latitude! : "N/A")</td></tr>"
            body += "<tr><th align=\"left\">Longitude: </th><td align=\"left\">\(form.longitude != "" ? form.longitude! : "N/A")</td></tr>"
            
            body += "</table>"
            
            body += "<b>Symptoms: </b>"
            let symptoms = form.symptoms as! Array<String>
            if symptoms.count == 0 {
                body += "<p>N/A</p>"
            }
            for symptom in symptoms {
                body += "-\(symptom)<br>"
            }
            body += "<b>Symptom Notes: </b>"
            body += "<p>\(form.symptomNotes != "" ? form.symptomNotes! : "N/A")</p>"
            
            body += "<b>Vaccinations: </b>"
            let vaxes = form.vaccinations as! Array<Vaccination>
            if vaxes.count > 0 {
                body += "<table border=\"1\"><tr><th>Name</th><th>Age</th><th>Doses</th><th>Admin.</th>"
                for vax in vaxes {
                    body += "<tr><td>\(vax.name!)</td><td>\(vax.age!)</td><td>\(vax.doses!)</td><td>\(vax.administration!)</td>"
                }
                body += "</table>"
            } else {
                body += "<p>N/A</p>"
            }
            body += "<b>Vaccination Notes: </b>"
            body += "<br><br><br>------------------------------------------------------------<br><br><br>"
            body += "<p>\(form.vaccinationNotes != "" ? form.vaccinationNotes! : "N/A")</p>"
            body += "<b>Barcodes: </b>"
            body += (form.barcodes as! Array<String>).joined(separator: ", ")
            body += "<br><br><br>------------------------------------------------------------<br><br><br>"
        }
        
        mailController.setToRecipients(recipients)
        mailController.setSubject("Sample Submission Record")
        mailController.setMessageBody(body, isHTML: true)
        self.present(mailController, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func displayNotification(message: String) {
        let errorController = UIAlertController(title: message, message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        let ok = UIAlertAction(title: "OK", style: .default) { (_) in }
        
        errorController.addAction(ok)
        
        self.present(errorController, animated: true, completion: nil)
    }
    
    func viewGroups() {
        if submittedSelected == true {
            showSubmittedTable(self)
        } else {
            showUnsubmittedTable(self)
        }
    }
    
    // Called when the user presses "View Unsubmitted".
    @IBAction func showUnsubmittedTable(_ sender: Any) {
        // Change background colors to show which is selected.
        submittedFormsButton.backgroundColor = UIColor.clear
        unsubmittedFormsButton.backgroundColor = UIColor.init(displayP3Red: 0.86, green: 0.86, blue: 0.86, alpha: 1.0)
        
        // Enable the Submit Selected button.
        submitSelectedButton.isEnabled = true
        
        // Disable the "By Date" button.
        navigationItem.leftBarButtonItem?.isEnabled = false
        
        // Ensure the table is showing dates, not individual forms.
        selectedDate = nil
        
        // Show the dates of unsubmitted forms.
        datesToDisplay = unsubmittedDates
        
        // Ensure all date switches start as off.
        for date in Array(dateSelectedTracker.keys) {
            dateSelectedTracker[date] = false
        }
        
        // Ensure all form switches are off for when we select a date, so as not to confuse the user.
        for id in Array(formSelectedTracker.keys) {
            formSelectedTracker[id] = false
        }
        
        // Set this variable so we know which is selected.
        submittedSelected = false
        DispatchQueue.main.async {
            self.formTable.reloadData()
        }
    }
    
    // Called when the user presses "View Submitted".
    @IBAction func showSubmittedTable(_ sender: Any) {
        // Change backbround colors to show which is selected.
        unsubmittedFormsButton.backgroundColor = UIColor.clear
        submittedFormsButton.backgroundColor = UIColor.init(displayP3Red: 0.86, green: 0.86, blue: 0.86, alpha: 1.0)
        
        // Disable the Submit Selected button.
        submitSelectedButton.isEnabled = false
        
        // Disable the "By Date" button.
        navigationItem.leftBarButtonItem?.isEnabled = false
        
        // Ensure the table is showing dates, not individual forms.
        selectedDate = nil
        
        // Show the dates of submitted forms.
        datesToDisplay = submittedDates
        
        // Ensure all date switches start as off.
        for date in Array(dateSelectedTracker.keys) {
            dateSelectedTracker[date] = false
        }
        
        // Ensure all form switches are off for when we select a date, so as not to confuse the user.
        for id in Array(formSelectedTracker.keys) {
            formSelectedTracker[id] = false
        }
        
        // Set this variable so we know which is selected.
        submittedSelected = true
        DispatchQueue.main.async {
            self.formTable.reloadData()
        }
    }
    
    
    func switchPressed(sender: UISwitch) {
        if selectedDate == nil || selectedDate == "" {
            if submittedSelected == true {
                dateSelectedTracker[submittedDates[sender.tag]] = sender.isOn
            } else {
                dateSelectedTracker[unsubmittedDates[sender.tag]] = sender.isOn
            }
        } else {
            formSelectedTracker[formsToDisplay[sender.tag].objectID] = sender.isOn
        }
    }
    
    /*
     * Table view (form/form table) functions.
     */
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedDate == nil || selectedDate == "" {
            if submittedSelected == true {
                return submittedDates.count
            } else {
                return unsubmittedDates.count
            }
        } else {
            return formsToDisplay.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = formTable.dequeueReusableCell(withIdentifier: "FormTableCell")
        cell?.tag = indexPath.row
        
        if selectedDate == nil || selectedDate == "" {
            let dateString:String?
            if submittedSelected == true {
                dateString = submittedDates[cell!.tag]
            } else {
                dateString = unsubmittedDates[cell!.tag]
            }
            cell?.accessoryView = nil
            cell?.textLabel?.text = "Forms from " + dateString!
            
            let switchView = UISwitch()
            let isSelected = dateSelectedTracker[dateString!]
            switchView.isOn = isSelected == nil ? false : isSelected!
            switchView.tag = indexPath.row
            switchView.addTarget(self, action: #selector(switchPressed), for: UIControlEvents.valueChanged)
            cell?.accessoryView = switchView
            
            return cell!
        } else {
            let form:Form?
            form = formsToDisplay[cell!.tag]
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "h:mm a"
            let cellText = form!.formName! + " : " + dateFormatter.string(from: form!.savedDate! as Date)
            cell?.textLabel?.text = String(cellText)

            let switchView = UISwitch()
            let isSelected = formSelectedTracker[form!.objectID]
            switchView.isOn = isSelected == nil ? false : isSelected!
            switchView.tag = indexPath.row
            switchView.addTarget(self, action: #selector(switchPressed), for: UIControlEvents.valueChanged)
            cell?.accessoryView = switchView
            
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if submittedSelected == true {
            return selectedDate == nil || selectedDate == "" ? "Submitted: Grouped by Date" : "Submitted Forms: " + selectedDate!
        } else {
            return selectedDate == nil || selectedDate == "" ? "Unsubmitted: Grouped by Date" : "Unsubmitted Forms: " + selectedDate!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = formTable.visibleCells.index(where: { $0.tag == indexPath.row })!
        let cell = formTable.visibleCells[index]
        
        if selectedDate == nil || selectedDate == "" {
            // Enable the "By Date" button.
            navigationItem.leftBarButtonItem?.isEnabled = true
            
            if submittedSelected == true {
                selectedDate = submittedDates[indexPath.row]
                formsToDisplay = submittedForms.filter { nsDateAsDay(date: $0.savedDate!) == selectedDate }
            } else {
                selectedDate = unsubmittedDates[indexPath.row]
                formsToDisplay = unsubmittedForms.filter { nsDateAsDay(date: $0.savedDate!) == selectedDate }
            }
            formTable.reloadData()
        } else {
            performSegue(withIdentifier: "GoToEditPage", sender: cell)
        }
    }
}

