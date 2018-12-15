//
//  VaccinationViewController.swift
//  RG Samples
//
//  Created by Joseph Tocco on 8/15/17.
//  Copyright © 2017 Joseph Ryan Tocco. All rights reserved.
//

import UIKit

// Used to send data back to the controller that sent to this page.
protocol VaccinationDelegate {
    func setVaccinations(vaccinations: Array<Vaccination>, notes: String)
}

// Class to keep track of different aspects of each vaccine (name, age, # doses, and route of administration).
class Vaccination: NSObject, NSCoding {
    var name:String?
    var age:String?
    var doses:String?
    var administration:String?
    var brandOfVaccinator:String?
    var nameOfAntibiotics:String?
    
    init(name: String, age: String, doses: String, administration: String, brandOfVaccinator: String) {
        self.name = name
        self.age = age
        self.doses = doses
        self.administration = administration
        self.brandOfVaccinator = brandOfVaccinator
    }
    
    init(name: String, age: String, doses: String, administration: String, brandOfVaccinator: String, nameOfAntibiotics: String) {
        self.name = name
        self.age = age
        self.doses = doses
        self.administration = administration
        self.brandOfVaccinator = brandOfVaccinator
        self.nameOfAntibiotics = nameOfAntibiotics
    }
    
    // So Vaccination objects can be saved with core data.
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(age, forKey: "age")
        coder.encode(doses, forKey: "doses")
        coder.encode(administration, forKey: "administration")
        coder.encode(brandOfVaccinator, forKey: "brandOfVaccinator")
    }
    
    required init(coder: NSCoder) {
        super.init()
        
        name = coder.decodeObject(forKey: "name") as? String
        age = coder.decodeObject(forKey: "age") as? String
        doses = coder.decodeObject(forKey: "doses") as? String
        administration = coder.decodeObject(forKey: "administration") as? String
        brandOfVaccinator = coder.decodeObject(forKey: "brandOfVaccinator") as? String
    }
}

// The view controller for the vaccination page.
class VaccinationViewController: UITableViewController, UITextViewDelegate {
    
    // In the future, this should be dynamic. For now, we have outlets
    // for each of the three fields for each type of vaccination.
    
    @IBOutlet weak var innovaxILTAge: UILabel!
    @IBOutlet weak var innovaxILTDoses: UILabel!
    @IBOutlet weak var innovaxILTAdmin: UILabel!
    @IBOutlet weak var innovaxILTBrandOfVaccinator: UILabel!
    @IBOutlet weak var innovaxILTNameOfAntibiotics: UILabel!
    
    @IBOutlet weak var innovaxMDAge: UILabel!
    @IBOutlet weak var innovaxMDDoses: UILabel!
    @IBOutlet weak var innovaxMDAdmin: UILabel!
    @IBOutlet weak var innovaxMDBrandOfVaccinator: UILabel!
    @IBOutlet weak var innovaxMDNameOfAntibiotics:UILabel!
    
    @IBOutlet weak var innovaxMDIBDAge: UILabel!
    @IBOutlet weak var innovaxMDIBDDoses: UILabel!
    @IBOutlet weak var innovaxMDIBDAdmin: UILabel!
    @IBOutlet weak var innovaxMDIBDBrandOfVaccinator: UILabel!
    @IBOutlet weak var innovaxMDIBDNameOfAntibiotics:UILabel!
    
    @IBOutlet weak var nobilisILTAge: UILabel!
    @IBOutlet weak var nobilisILTDoses: UILabel!
    @IBOutlet weak var nobilisILTAdmin: UILabel!
    @IBOutlet weak var nobilisILTBrandOfVaccinator: UILabel!
    @IBOutlet weak var nobilisILTNameOfAntibiotics: UILabel!
    
    @IBOutlet weak var otherILTAge: UILabel!
    @IBOutlet weak var otherILTDoses: UILabel!
    @IBOutlet weak var otherILTAdmin: UILabel!
    @IBOutlet weak var otherILTBrandOfVaccinator: UILabel!
    @IBOutlet weak var otherILTNameOfAntibiotics: UILabel!

    @IBOutlet weak var nobilisIB491Age: UILabel!
    @IBOutlet weak var nobilisIB491Doses: UILabel!
    @IBOutlet weak var nobilisIB491Admin: UILabel!
    @IBOutlet weak var nobilisIB491BrandOfVaccinator: UILabel!
    @IBOutlet weak var nobilisIB491NameOfAntibiotics: UILabel!
    
    @IBOutlet weak var nobilisIBH120Age: UILabel!
    @IBOutlet weak var nobilisIBH120Doses: UILabel!
    @IBOutlet weak var nobilisIBH120Admin: UILabel!
    @IBOutlet weak var nobilisIBH120BrandOfVaccinator: UILabel!
    @IBOutlet weak var nobilisIBH120NameOfAntibiotics: UILabel!
    
    @IBOutlet weak var nobilisIBMa5Age: UILabel!
    @IBOutlet weak var nobilisIBMa5Doses: UILabel!
    @IBOutlet weak var nobilisIBMa5Admin: UILabel!
    @IBOutlet weak var nobilisIBMa5BrandOfVaccinator: UILabel!
    @IBOutlet weak var nobilisIBMa5NameOfAntibiotics: UILabel!
    
    @IBOutlet weak var h120D274Age: UILabel!
    @IBOutlet weak var h120D274Doses: UILabel!
    @IBOutlet weak var h120D274Admin: UILabel!
    @IBOutlet weak var h120D274BrandOfVaccinator: UILabel!
    @IBOutlet weak var h120D274NameOfAntibiotics: UILabel!
    
    @IBOutlet weak var iB88Age: UILabel!
    @IBOutlet weak var iB88Doses: UILabel!
    @IBOutlet weak var iB88Admin: UILabel!
    @IBOutlet weak var iB88BrandOfVaccinator: UILabel!
    @IBOutlet weak var iB88NameOfAntibiotics: UILabel!
    
    @IBOutlet weak var iBmmArkAge: UILabel!
    @IBOutlet weak var iBmmArkDoses: UILabel!
    @IBOutlet weak var iBmmArkAdmin: UILabel!
    @IBOutlet weak var iBmmArkBrandOfVaccinator: UILabel!
    @IBOutlet weak var iBmmArkNameOfAntibiotics: UILabel!
    
    @IBOutlet weak var nobilisRhinoCVAge: UILabel!
    @IBOutlet weak var nobilisRhinoCVDoses: UILabel!
    @IBOutlet weak var nobilisRhinoCVAdmin: UILabel!
    @IBOutlet weak var nobilisRhinoCVABrandOfVaccinator: UILabel!
    @IBOutlet weak var nobilisRhinoCVANameOfAntibiotics: UILabel!
    
    @IBOutlet weak var nobilisTRTLiveAge: UILabel!
    @IBOutlet weak var nobilisTRTLiveDoses: UILabel!
    @IBOutlet weak var nobilisTRTLiveAdmin: UILabel!
    @IBOutlet weak var nobilisTRTLiveBrandOfVaccinator: UILabel!
    @IBOutlet weak var nobilisTRTNameOfAntibiotitcs: UILabel!
    
    @IBOutlet weak var cevaciBird196Age: UILabel!
    @IBOutlet weak var cevaciBird196Doses: UILabel!
    @IBOutlet weak var cevaciBird196Admin: UILabel!
    @IBOutlet weak var cevaciBird196BrandOfVaccinator: UILabel!
    @IBOutlet weak var cevaciBird196NameOfAntibiotics: UILabel!
    
    @IBOutlet weak var injectableAntibioticAge: UILabel!
    @IBOutlet weak var injectableAntibioticDoses: UILabel!
    @IBOutlet weak var injectableAntibioticAdmin: UILabel!
    @IBOutlet weak var injectableAntibioticsBrandOfVaccinator: UILabel!
    @IBOutlet weak var injectableAntibioticsNameOfAntibiotics: UILabel!
    
    @IBOutlet weak var csiRispenseAge: UILabel!
    @IBOutlet weak var csiRispenseDoses: UILabel!
    @IBOutlet weak var csiRispenseAdmin: UILabel!
    @IBOutlet weak var csiRispenseBrandOfVaccinator: UILabel!
    @IBOutlet weak var csiRispenseNameOfAntibiotics: UILabel!
    
    @IBOutlet weak var vaccinationNotes: UITextView!
    
    var vaccinations:Array<Vaccination> = [
        Vaccination(name: "Innovax ILT", age: "", doses: "", administration: "", brandOfVaccinator: ""),
        Vaccination(name: "Innovax MD", age: "", doses: "", administration: "", brandOfVaccinator: ""),
        Vaccination(name: "Innovax MDIBD", age: "", doses: "", administration: "", brandOfVaccinator: ""),
        Vaccination(name: "Nobilis ILT", age: "", doses: "", administration: "", brandOfVaccinator: ""),
        Vaccination(name: "Other ILT", age: "", doses: "", administration: "", brandOfVaccinator: ""),
        Vaccination(name: "Nobilis IB 4-91", age: "", doses: "", administration: "", brandOfVaccinator: ""),
        Vaccination(name: "Nobilis IB H120", age: "", doses: "", administration: "", brandOfVaccinator: ""),
        Vaccination(name: "Nobilis IB Ma5", age: "", doses: "", administration: "", brandOfVaccinator: ""),
        Vaccination(name: "H120+D274", age: "", doses: "", administration: "", brandOfVaccinator: ""),
        Vaccination(name: "IB88", age: "", doses: "", administration: "", brandOfVaccinator: ""),
        Vaccination(name: "IBmm+Ark", age: "", doses: "", administration: "", brandOfVaccinator: ""),
        Vaccination(name: "Nobilis Rhino CV", age: "", doses: "", administration: "", brandOfVaccinator: ""),
        Vaccination(name: "Nobilis TRT Live", age: "", doses: "", administration: "", brandOfVaccinator: ""),
        Vaccination(name: "Cevac iBird 1/96", age: "", doses: "", administration: "", brandOfVaccinator: ""),
        Vaccination(name: "Injectable Antibiotics", age: "", doses: "", administration: "", brandOfVaccinator: "", nameOfAntibiotics: ""),
        Vaccination(name: "CSI/ Rispense", age: "", doses: "", administration: "", brandOfVaccinator: "")
    ]
    var notes:String?
    
    var delegate:VaccinationDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Select Vaccinations"
        
        if (notes != nil) { vaccinationNotes.text = notes }
        resetInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Send the vaccinations to the controller that sent to this view.
        var vaxes:Array<Vaccination> = []
        
        for vax in vaccinations {
            if vax.age != "" || vax.doses != "" || vax.administration != "" {
                vaxes.append(vax)
            }
        }
        
        delegate?.setVaccinations(vaccinations: vaxes, notes: vaccinationNotes.text)
    }
    
    // When a row in the table is selected, allow the user to specify info for the vaccination.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(false)
        
        let row = indexPath.row - 1
        if row >= 0 && row < vaccinations.count {
        
            let vaxController = UIAlertController(title: "Enter Vaccination Info", message: "", preferredStyle: UIAlertControllerStyle.alert)
            
            // Save changes.
            let enter = UIAlertAction(title: "Enter", style: .default) { (_) in
                self.vaccinations[row].age = vaxController.textFields?[0].text
                self.vaccinations[row].doses = vaxController.textFields?[1].text
                self.vaccinations[row].administration = vaxController.textFields?[2].text
                self.vaccinations[row].brandOfVaccinator = vaxController.textFields?[3].text
                if self.vaccinations[row].name == "Injectable Antibiotics" {
                    self.vaccinations[row].nameOfAntibiotics = vaxController.textFields?[4].text
                }
                
                self.resetInfo()
            }
            
            // Don't save changes.
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
            
            vaxController.addTextField { (textField) in
                textField.placeholder = "Age at Time of Administration"
            }
            
            vaxController.addTextField { (textField) in
                textField.placeholder = "# Doses"
            }
            
            vaxController.addTextField { (textField) in
                textField.placeholder = "Route of Administration"
            }
            
            vaxController.addTextField { (textField) in
                textField.placeholder = "Brand of Vaccinator"
            }
            
            if self.vaccinations[row].name == "Injectable Antibiotics" {
                vaxController.addTextField { (textField) in
                    textField.placeholder = "Injectable Antibiotics"
                }
            }
        
            vaxController.addAction(enter)
            vaxController.addAction(cancel)
            
            self.present(vaxController, animated: true, completion: nil)
        }
    }
    
    // Set the table text to match that in the vaccinations array.
    func resetInfo() {
        innovaxILTAge.text = vaccinations[0].age
        innovaxILTDoses.text = vaccinations[0].doses
        innovaxILTAdmin.text = vaccinations[0].administration
        innovaxILTBrandOfVaccinator.text = vaccinations[0].brandOfVaccinator
        innovaxILTNameOfAntibiotics.text = "N/A"
        
        innovaxMDAge.text = vaccinations[1].age
        innovaxMDDoses.text = vaccinations[1].doses
        innovaxMDAdmin.text = vaccinations[1].administration
        innovaxMDBrandOfVaccinator.text = vaccinations[1].brandOfVaccinator
        innovaxMDNameOfAntibiotics.text = "N/A"

        innovaxMDIBDAge.text = vaccinations[2].age
        innovaxMDIBDDoses.text = vaccinations[2].doses
        innovaxMDIBDAdmin.text = vaccinations[2].administration
        innovaxMDIBDBrandOfVaccinator.text = vaccinations[2].brandOfVaccinator
        innovaxMDIBDNameOfAntibiotics.text = "N/A"

        nobilisILTAge.text = vaccinations[3].age
        nobilisILTDoses.text = vaccinations[3].doses
        nobilisILTAdmin.text = vaccinations[3].administration
        nobilisILTBrandOfVaccinator.text = vaccinations[3].brandOfVaccinator
        nobilisILTNameOfAntibiotics.text = "N/A"
        
        otherILTAge.text = vaccinations[4].age
        otherILTDoses.text = vaccinations[4].doses
        otherILTAdmin.text = vaccinations[4].administration
        otherILTBrandOfVaccinator.text = vaccinations[4].brandOfVaccinator
        otherILTNameOfAntibiotics.text = "N/A"
        
        nobilisIB491Age.text = vaccinations[5].age
        nobilisIB491Doses.text = vaccinations[5].doses
        nobilisIB491Admin.text = vaccinations[5].administration
        nobilisIB491BrandOfVaccinator.text = vaccinations[5].brandOfVaccinator
        nobilisIB491NameOfAntibiotics.text = "N/A"
        
        nobilisIBH120Age.text = vaccinations[6].age
        nobilisIBH120Doses.text = vaccinations[6].doses
        nobilisIBH120Admin.text = vaccinations[6].administration
        nobilisIBH120BrandOfVaccinator.text = vaccinations[6].brandOfVaccinator
        nobilisIBH120NameOfAntibiotics.text = "N/A"
        
        nobilisIBMa5Age.text = vaccinations[7].age
        nobilisIBMa5Doses.text = vaccinations[7].doses
        nobilisIBMa5Admin.text = vaccinations[7].administration
        nobilisIBMa5BrandOfVaccinator.text = vaccinations[7].brandOfVaccinator
        nobilisIBMa5NameOfAntibiotics.text = "N/A"
        
        h120D274Age.text = vaccinations[8].age
        h120D274Doses.text = vaccinations[8].doses
        h120D274Admin.text = vaccinations[8].administration
        h120D274BrandOfVaccinator.text = vaccinations[8].brandOfVaccinator
        h120D274NameOfAntibiotics.text = "N/A"
        
        iB88Age.text = vaccinations[9].age
        iB88Doses.text = vaccinations[9].doses
        iB88Admin.text = vaccinations[9].administration
        iB88BrandOfVaccinator.text = vaccinations[9].brandOfVaccinator
        iB88NameOfAntibiotics.text = "N/A"
        
        iBmmArkAge.text = vaccinations[10].age
        iBmmArkDoses.text = vaccinations[10].doses
        iBmmArkAdmin.text = vaccinations[10].administration
        iBmmArkBrandOfVaccinator.text = vaccinations[10].brandOfVaccinator
        iBmmArkNameOfAntibiotics.text = "N/A"
        
        nobilisRhinoCVAge.text = vaccinations[11].age
        nobilisRhinoCVDoses.text = vaccinations[11].doses
        nobilisRhinoCVAdmin.text = vaccinations[11].administration
        nobilisRhinoCVABrandOfVaccinator.text = vaccinations[11].brandOfVaccinator
        nobilisRhinoCVANameOfAntibiotics.text = "N/A"
        
        nobilisTRTLiveAge.text = vaccinations[12].age
        nobilisTRTLiveDoses.text = vaccinations[12].doses
        nobilisTRTLiveAdmin.text = vaccinations[12].administration
        nobilisTRTLiveBrandOfVaccinator.text = vaccinations[12].brandOfVaccinator
        nobilisTRTNameOfAntibiotitcs.text = "N/A"
        
        cevaciBird196Age.text = vaccinations[13].age
        cevaciBird196Doses.text = vaccinations[13].doses
        cevaciBird196Admin.text = vaccinations[13].administration
        cevaciBird196BrandOfVaccinator.text = vaccinations[13].brandOfVaccinator
        cevaciBird196NameOfAntibiotics.text = "N/A"
        
        injectableAntibioticAge.text = vaccinations[14].age
        injectableAntibioticDoses.text = vaccinations[14].doses
        injectableAntibioticAdmin.text = vaccinations[14].administration
        injectableAntibioticsBrandOfVaccinator.text = vaccinations[14].brandOfVaccinator
        injectableAntibioticsNameOfAntibiotics.text = vaccinations[14].nameOfAntibiotics
        
        csiRispenseAge.text = vaccinations[15].age
        csiRispenseDoses.text = vaccinations[15].doses
        csiRispenseAdmin.text = vaccinations[15].administration
        csiRispenseBrandOfVaccinator.text = vaccinations[15].brandOfVaccinator
        csiRispenseNameOfAntibiotics.text = "N/A"
    }
    
}
