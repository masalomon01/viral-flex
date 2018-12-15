//
//  SymptomViewTests.swift
//  RG SamplesTests
//
//  Created by Joseph Tocco on 10/9/17.
//  Copyright © 2017 Joseph Ryan Tocco. All rights reserved.
//

import XCTest
@testable import Sample_Collection

class SymptomViewTests: XCTestCase {
    
    var vc:SymptomViewController!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        vc = storyboard.instantiateViewController(withIdentifier: "SymptomViewController") as! SymptomViewController
        
        vc.startIntake = true
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testViewWillDisappear() {
        XCTAssertEqual(vc.startIntake, true)
    }
}
