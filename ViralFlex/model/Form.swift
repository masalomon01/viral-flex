import Foundation

class Form: NSObject, NSCoding, NSCopying{
    
    static let TYPE_DRAFT = 1
    static let TYPE_SUBMITTED = 2
    
    static let STATUS_NEW = 1
    static let STATUS_CREATED = 2
    static let STATUS_SUBMITTED = 3
    
    var uuid: String!
    var name: String
    var createTime: Date?
    var submitTime: Date?
    var status: Int = 1
    
    var barCodes: [BarCode] = []
    var pictures: [String] = []
    
    var testType: String?
    var farmName: String?
    var country: String?
    var birdType: String?
    var hatcherySource: String?
    var samplingAge: String?
    var sampleType: String?
    var sampleCode: String?
    var shedID: String?
    var veterinaryPractice: String?
    var veterinarySurgeon: String?
    var inOvoVaccinator: String?
    var labReferenceNumber: String?
    var companyName: String?
    var postCode: String?
    var county: String?
    
    var clinicalSigns: [String] = []
    var vaccinations: [Vaccination] = []
    
    
    static var forms: [Form]!
    
    required override init() {
        name = ""
    }
    
    required init(name: String) {
        self.uuid = UUID().uuidString
        self.name = name
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let newForm = type(of: self).init()
        newForm.uuid = UUID().uuidString
        newForm.name = self.name
        newForm.createTime = self.createTime
        newForm.status = self.status
        
        newForm.testType = testType
        newForm.farmName = farmName
        newForm.country = country
        newForm.birdType = birdType
        newForm.hatcherySource = hatcherySource
        newForm.samplingAge = samplingAge
        newForm.sampleType = sampleType
        newForm.sampleCode = sampleCode
        newForm.shedID = shedID
        newForm.veterinaryPractice = veterinaryPractice
        newForm.veterinarySurgeon = veterinarySurgeon
        newForm.inOvoVaccinator = inOvoVaccinator
        newForm.labReferenceNumber = labReferenceNumber
        newForm.companyName = companyName
        newForm.postCode = postCode
        newForm.county = county
        
        newForm.clinicalSigns = clinicalSigns
        newForm.vaccinations = vaccinations
        
        newForm.barCodes = barCodes
        
        return newForm
    }
    
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(uuid, forKey: "uuid")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(createTime, forKey: "createTime")
        aCoder.encode(status, forKey: "status")
        
        aCoder.encode(barCodes, forKey: "barCodes")
        aCoder.encode(pictures, forKey: "pictures")
        
        aCoder.encode(testType, forKey: "testType")
        aCoder.encode(farmName, forKey: "farmName")
        aCoder.encode(country, forKey: "country")
        aCoder.encode(birdType, forKey: "birdBreed")
        aCoder.encode(hatcherySource, forKey: "hatcherySource")
        aCoder.encode(samplingAge, forKey: "samplingAge")
        aCoder.encode(sampleType, forKey: "sampleType")
        aCoder.encode(sampleCode, forKey: "sampleCode")
        aCoder.encode(shedID, forKey: "shedID")
        aCoder.encode(veterinaryPractice, forKey: "veterinaryPractice")
        aCoder.encode(veterinarySurgeon, forKey: "veterinarySurgeon")
        aCoder.encode(inOvoVaccinator, forKey: "inOvoVaccinator")
        aCoder.encode(labReferenceNumber, forKey: "labReferenceNumber")
        aCoder.encode(companyName, forKey: "companyName")
        aCoder.encode(postCode, forKey: "postCode")
        aCoder.encode(county, forKey: "county")
        
        aCoder.encode(clinicalSigns, forKey: "clinicalSigns")
        aCoder.encode(vaccinations, forKey: "vaccinations")
    }
    
    required init?(coder aDecoder: NSCoder) {
        uuid = aDecoder.decodeObject(forKey: "uuid") as? String
        name = aDecoder.decodeObject(forKey: "name") as! String
        createTime = aDecoder.decodeObject(forKey: "createTime") as? Date
        status = aDecoder.decodeInteger(forKey: "status")
        
        let barCodesDecoded = aDecoder.decodeObject(forKey: "barCodes")
        if barCodesDecoded != nil {barCodes = (barCodesDecoded) as! [BarCode]}
        let pictureDecoded = aDecoder.decodeObject(forKey: "pictures")
        if pictureDecoded != nil {pictures = (pictureDecoded) as! [String]}
        
        
        testType = aDecoder.decodeObject(forKey: "testType") as? String
        farmName = aDecoder.decodeObject(forKey: "farmName") as? String
        country = aDecoder.decodeObject(forKey: "country") as? String
        birdType = aDecoder.decodeObject(forKey: "birdBreed") as? String
        hatcherySource = aDecoder.decodeObject(forKey: "hatcherySource") as? String
        samplingAge = aDecoder.decodeObject(forKey: "samplingAge") as? String
        sampleType = aDecoder.decodeObject(forKey: "sampleType") as? String
        sampleCode = aDecoder.decodeObject(forKey: "sampleCode") as? String
        shedID = aDecoder.decodeObject(forKey: "shedID") as? String
        veterinaryPractice = aDecoder.decodeObject(forKey: "veterinaryPractice") as? String
        veterinarySurgeon = aDecoder.decodeObject(forKey: "veterinarySurgeon") as? String
        inOvoVaccinator = aDecoder.decodeObject(forKey: "inOvoVaccinator") as? String
        labReferenceNumber = aDecoder.decodeObject(forKey: "labReferenceNumber") as? String
        companyName = aDecoder.decodeObject(forKey: "companyName") as? String
        postCode = aDecoder.decodeObject(forKey: "postCode") as? String
        county = aDecoder.decodeObject(forKey: "county") as? String
        
        let clinicalSigns = aDecoder.decodeObject(forKey: "clinicalSigns")
        if clinicalSigns != nil {self.clinicalSigns = clinicalSigns as! [String]}
        let vaccinations = aDecoder.decodeObject(forKey: "vaccinations")
        if vaccinations != nil {self.vaccinations = vaccinations as! [Vaccination]}
    }
    
    
    static func loadForms() -> [Form] {
        
        if (forms == nil) {
            
            let defaults = UserDefaults.standard
            let data = defaults.object(forKey: "forms")
            if data != nil {
                forms = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as! [Form]
            }
            else {
                forms = []
            }
        }
        
        return forms
    }
    
    static func saveForms() {
        
        let defaults = UserDefaults.standard
        let data = NSKeyedArchiver.archivedData(withRootObject: forms)
        defaults.set(data, forKey: "forms")
        defaults.synchronize()
    }
    
    static func getDraftForms() -> [Form] {
        return Form.loadForms().filter {$0.status==Form.STATUS_CREATED}
    }
    
    static func getSubmittedForms() -> [Form] {
        return Form.loadForms().filter {$0.status==Form.STATUS_SUBMITTED}
    }
    
    func saveDraft() {
        self.status = Form.STATUS_CREATED
        self.createTime = Date()
        
        Form.loadForms()
        Form.forms.append(self)
        Form.saveForms()
    }
    
    func saveChanges() {
        for (index, form) in Form.loadForms().enumerated() {
            if (self.uuid == form.uuid) {
                Form.forms[index] = self
                break
            }
        }
        Form.saveForms()
    }

    
    func delete() {
        for (index, form) in Form.loadForms().enumerated() {
            if (self.uuid == form.uuid) {
                Form.forms.remove(at: index)
                break
            }
        }
        Form.saveForms()
    }
    
    func submit() {
        self.status = Form.STATUS_SUBMITTED
        self.saveChanges()
    }
}
