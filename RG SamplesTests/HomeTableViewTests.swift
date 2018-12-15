//
//  RG_SamplesTests.swift
//  RG SamplesTests
//
//  Created by Joseph Ryan Tocco on 7/28/17.
//  Copyright © 2017 Joseph Ryan Tocco. All rights reserved.
//

import XCTest
@testable import Sample_Collection

class HomeTableViewTests: XCTestCase {
    
    var vc:HomeTableViewController!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        vc = storyboard.instantiateViewController(withIdentifier: "HomeTableViewController") as! HomeTableViewController
//        vc = storyboard.instantiateViewController(withIdentifier: "HomeTableViewController.swift")
//        _ = vc.view
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testViewDidLoad() {
        
    }
    
    func testPrepare() {
        
    }
    
    func testSetSymptoms() {
        XCTAssert(vc.symptoms.count == 0, "Should begin with no symptoms.")
        XCTAssertEqual(vc.symptomNotes, "", "Should begin with no notes.")
        let symptoms = ["symptom 1", "symptom 2"]
        let notes = "Notes"
        vc.setSymptoms(symptoms: symptoms, notes: notes)
        XCTAssert(vc.symptoms.count == 2, "Should end with 2 symptoms")
        XCTAssertEqual(vc.symptomNotes, "Notes", "Should end with a note.")
    }
    
    func testSetVaccinations() {
        XCTAssert(vc.vaccinations.count == 0, "Should begin with no vaccinations.")
        XCTAssertEqual(vc.vaccinationNotes, "", "Should begin with no notes")
        let vaccinations = [Vaccination(name: "name1", age: "age1", doses: "doses1", administration: "admin1"), Vaccination(name: "name2", age: "age2", doses: "doses2", administration: "admin2")]
        let notes = "Notes"
        vc.setVaccinations(vaccinations: vaccinations, notes: notes)
        XCTAssert(vc.vaccinations.count == 2, "Should end with 2 vaccinations.")
        XCTAssertEqual(vc.vaccinationNotes, "Notes", "Should end with a note.")
    }
    
    func testSetBarcodes() {
        XCTAssert(vc.scannedBarcodes.count == 0, "Should begin with no barcodes.")
        let barcodes = ["barcode1", "barcode2"]
        vc.setBarcodes(barcodes: barcodes)
        XCTAssert(vc.scannedBarcodes.count == 2, "Should end with 2 barcodes")
    }
    
    func testSaveForm() {
        
    }
    
    func testDisplayNotification() {
        
    }
    
    func testClearForm() {
        
    }
    
    func testScanBarcode() {
        
    }
    
    func testCaptureOutput() {
        
    }
    
    func testCloseCamera() {
        
    }
    
    func testBarcodeDetected() {
        
    }
    
    func testPickerViewRowSelected() {
        
    }
    
    func testTextFieldShouldBeginEditing() {
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
