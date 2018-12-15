//
//  BarcodeTableViewController.swift
//  RG Samples
//
//  Created by Joseph Tocco on 8/18/17.
//  Copyright © 2017 Joseph Ryan Tocco. All rights reserved.
//

import UIKit

// Give a list of barcodes to the sending controller.
protocol BarcodeDelegate {
    func setBarcodes(barcodes: Array<String>)
}

// View controller for the manage barcodes page.
class BarcodeTableViewController: UITableViewController {
    
    @IBOutlet weak var barcodeTable: UITableView!
    
    var barcodes:Array<String> = []
    
    var delegate:BarcodeDelegate?
    
    var lastBarcodeDisplayed:String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Manage Barcodes"
        
        // Add a button to add a barcode to the top right corner.
        let addButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addBarcodePrompt))
        self.navigationItem.rightBarButtonItem = addButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.setBarcodes(barcodes: barcodes)
    }

    /*
     * Table view functions.
     */////////////////////////////////////////////////////////////////////////////////////

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Select to edit. Swipe left to delete."
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return barcodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = barcodeTable.dequeueReusableCell(withIdentifier: "BarcodeCell")
        cell?.textLabel?.text = barcodes[indexPath.row]
        
        return cell!
    }
    
    // When you swipe a table cell left, a delete button is revealed.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            barcodes.remove(at: indexPath.row)
            barcodeTable.reloadData()
        }
    }
    
    // When a table cell is selected, a text input field pops up for the user to edit the barcode.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        
        let editController = UIAlertController(title: "Enter a barcode number", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        // Called if the user decides to keep any changes they made (by pressing "Enter")
        let enter = UIAlertAction(title: "Enter", style: .default) { (_) in
            let code = editController.textFields![0].text!
            
            // Check the barcode for correctness.
            let check = self.checkBarcodeForCorrectness(barcode: code)
            
            // If the barcode is valid.
            if check == "Correct" {
                if self.barcodes.contains(code) {
                    // Let the user know the barcode is already part of this form.
                    let alertController = UIAlertController(title: "The barcode is already part of this form.", message: "", preferredStyle: UIAlertControllerStyle.alert)
                    let ok = UIAlertAction(title: "OK", style: .default) { (_) in }
                    alertController.addAction(ok)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    self.barcodes[row] = code
                }
                self.barcodeTable.reloadData()
                self.lastBarcodeDisplayed = nil
            } else {
                // Let the user know the barcode is invalid and let them try again.
                let alertController = UIAlertController(title: "Invalid Barcode", message: check, preferredStyle: UIAlertControllerStyle.alert)
                let ok = UIAlertAction(title: "OK", style: .default) { (_) in
                    self.lastBarcodeDisplayed = code
                    self.tableView(tableView, didSelectRowAt: indexPath)
                }
                alertController.addAction(ok)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
        // Called if the user presses "Cancel".
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            self.lastBarcodeDisplayed = nil
        }
        
        editController.addTextField { (textField) in
            textField.placeholder = "Barcode"
            if self.lastBarcodeDisplayed != nil {
                textField.text = self.lastBarcodeDisplayed
            } else {
                textField.text = self.barcodes[row]
            }
            textField.keyboardType = UIKeyboardType.decimalPad
        }
        
        editController.addAction(enter)
        editController.addAction(cancel)
        
        self.present(editController, animated: true, completion: nil)
    }
    
    // When the add button is pressed, prompt the user to type in a new barcode.
    @IBAction func addBarcodePrompt(sender: Any) {
        let addController = UIAlertController(title: "Add a barcode", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        // Called if the user decides to keep the barcode (by pressing "Enter")
        let enter = UIAlertAction(title: "Add", style: .default) { (_) in
            let code = addController.textFields![0].text!
            
            // Check barcode for correctness.
            let check = self.checkBarcodeForCorrectness(barcode: code)
            
            // If the barcode is valid.
            if check == "Correct" {
                // If the barcode has already been scanned/added.
                if self.barcodes.contains(code) {
                    // Let the user know the barcode is already part of this form.
                    let alertController = UIAlertController(title: "The barcode is already part of this form.", message: "", preferredStyle: UIAlertControllerStyle.alert)
                    let ok = UIAlertAction(title: "OK", style: .default) { (_) in }
                    alertController.addAction(ok)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    self.barcodes.append(code)
                }
                
                self.barcodeTable.reloadData()
                self.lastBarcodeDisplayed = nil
            } else {
                // Let the user know the barcode is invalid and let them try again.
                let alertController = UIAlertController(title: "Invalid Barcode", message: check, preferredStyle: UIAlertControllerStyle.alert)
                let ok = UIAlertAction(title: "OK", style: .default) { (_) in
                    self.lastBarcodeDisplayed = code
                    self.addBarcodePrompt(sender: self)
                }
                alertController.addAction(ok)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
        // Called if the user presses "Cancel".
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            self.lastBarcodeDisplayed = nil
        }
        
        addController.addTextField { (textField) in
            textField.placeholder = "Barcode"
            if self.lastBarcodeDisplayed != nil {
                textField.text = self.lastBarcodeDisplayed
            }
            textField.keyboardType = UIKeyboardType.decimalPad
        }
        
        addController.addAction(enter)
        addController.addAction(cancel)
        
        self.present(addController, animated: true, completion: nil)
    }
    
    // Check if the given barcode is valid.
    func checkBarcodeForCorrectness(barcode: String) -> String {
        // Check if the barcode has the correct number of digits (8)
        if barcode.count != 8 {
            return "The barcode must contain exactly 8 digits."
        }
        
        // Check if the barcode contains only numbers and begin calculating the checksum.
        var checksum = 0
        var lastDigit = 0
        for (index, char) in barcode.enumerated() {
            let digit = Int(String(char))
            if digit == nil {
                return "The barcode must contain only numbers."
            }
            
            // Continue calculating the checksum.
            if [0, 2, 4, 6].contains(index) {
                checksum += (Int(String(char))! * 3) // These are weighted by a factor of 3
            } else if [1, 3, 5].contains(index) {
                checksum += Int(String(char))!
            }
            
            if index == 7 && Int(String(char)) != nil {
                lastDigit = Int(String(char))!
            }
        }
        checksum = (checksum % 10 == 0) ? 0 : (10 - (checksum % 10))
        
        // Check to see if the last digit matches the checksum.
        if lastDigit != checksum {
            return "The barcode contains an invalid check digit. Please double check the entry."
        }
        
        return "Correct"
    }

}
