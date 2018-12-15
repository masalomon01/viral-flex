//
//  SymptomViewController.swift
//  RG Samples
//
//  Created by Joseph Tocco on 8/14/17.
//  Copyright © 2017 Joseph Ryan Tocco. All rights reserved.
//

import UIKit

// Meant to transfer symptom data back to the previous controller.
protocol SymptomDelegate {
    func setSymptoms(symptoms: Array<String>, notes: String)
}

// Controller for the select clinical signs page.
class SymptomViewController: UITableViewController, UITextViewDelegate {
    
    // We could probably find a better way of doing this, but
    // for now we set different variables for each symptom.
    
    @IBOutlet weak var intake: UISwitch!
    @IBOutlet weak var depressed: UISwitch!
    @IBOutlet weak var growth: UISwitch!
    @IBOutlet weak var monitoring: UISwitch!
    @IBOutlet weak var respiratory: UISwitch!
    @IBOutlet weak var sneezing: UISwitch!
    @IBOutlet weak var tracheitis: UISwitch!
    @IBOutlet weak var conjunctivitis: UISwitch!
    @IBOutlet weak var heads: UISwitch!
    @IBOutlet weak var mortality: UISwitch!
    @IBOutlet weak var wetLitter: UISwitch!
    @IBOutlet weak var shellQuality: UISwitch!
    @IBOutlet weak var eggProduction: UISwitch!
    @IBOutlet weak var nephritis: UISwitch!
    
    @IBOutlet weak var symptomNotes: UITextView!
    
    // These variables are set by the calling controller.
    var startIntake:Bool?
    var startDepressed:Bool?
    var startGrowth:Bool?
    var startMonitoring:Bool?
    var startRespiratory:Bool?
    var startSneezing:Bool?
    var startTracheitis:Bool?
    var startConjunctivitis:Bool?
    var startHeads:Bool?
    var startMortality:Bool?
    var startWetLitter:Bool?
    var startShellQuality:Bool?
    var startEggProduction:Bool?
    var startNephritis:Bool?
    
    var notes:String?
    
    // This should be the controller that sent to the symptom page.
    var delegate: SymptomDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Clinical Signs"
        
        // Set switches to true if the calling controller so specifies.
        if startIntake == true { intake.isOn = true }
        if startDepressed == true { depressed.isOn = true }
        if startGrowth == true { growth.isOn = true }
        if startMonitoring == true { monitoring.isOn = true }
        if startRespiratory == true { respiratory.isOn = true }
        if startSneezing == true { sneezing.isOn = true }
        if startTracheitis == true { tracheitis.isOn = true }
        if startConjunctivitis == true { conjunctivitis.isOn = true }
        if startHeads == true { heads.isOn = true }
        if startMortality == true { mortality.isOn = true }
        if startWetLitter == true { wetLitter.isOn = true }
        if startShellQuality == true { shellQuality.isOn = true }
        if startEggProduction == true { eggProduction.isOn = true }
        if startNephritis == true { nephritis.isOn = true }
        
        if (notes != nil) { symptomNotes.text = notes }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Let the calling controller know what symptoms were specified.
        var symptoms:Array<String> = []
        if intake.isOn { symptoms.append("Decreased feed/water intake") }
        if depressed.isOn { symptoms.append("Birds depressed") }
        if growth.isOn { symptoms.append("Poor growth") }
        if monitoring.isOn { symptoms.append("Routine monitoring") }
        if respiratory.isOn { symptoms.append("Mild/Severe respiratory problems") }
        if sneezing.isOn { symptoms.append("Sneezing, snicking, rales") }
        if tracheitis.isOn { symptoms.append("Tracheitis") }
        if conjunctivitis.isOn { symptoms.append("Conjunctivitis") }
        if heads.isOn { symptoms.append("Swollen heads/Nasal exudate/Sinusitis") }
        if mortality.isOn { symptoms.append("Increased mortality") }
        if wetLitter.isOn { symptoms.append("Wet litter/Enteritis/Scouring") }
        if shellQuality.isOn { symptoms.append("Decrease in shell quality") }
        if(eggProduction.isOn) { symptoms.append("Drop in egg production") }
        if(nephritis.isOn) { symptoms.append("Nephritis/Kidney problems") }
        
        delegate?.setSymptoms(symptoms: symptoms, notes: symptomNotes.text)
    }
}
