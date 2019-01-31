import Foundation

class Vaccination: NSObject, NSCoding, NSCopying {

    var uuid: String!
    var name: String!
    var age: Int?
    var doses: Int?
    var admin: String?
    var brand: String?
    
    init(_ name: String) {
        uuid = UUID().uuidString
        self.name = name
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(uuid, forKey: "uuid")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(age, forKey: "age")
        aCoder.encode(doses, forKey: "doses")
        aCoder.encode(admin, forKey: "admin")
        aCoder.encode(brand, forKey: "brand")
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        uuid = aDecoder.decodeObject(forKey: "uuid") as? String
        name = aDecoder.decodeObject(forKey: "name") as? String
        age = aDecoder.decodeObject(forKey: "age") as? Int
        doses = aDecoder.decodeObject(forKey: "doses") as? Int
        admin = aDecoder.decodeObject(forKey: "admin") as? String
        brand = aDecoder.decodeObject(forKey: "brand") as? String
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        
        let newVaccination = Vaccination(self.name)
        newVaccination.uuid = UUID().uuidString
        newVaccination.name = self.name
        newVaccination.age = self.age
        newVaccination.doses = self.doses
        newVaccination.admin = self.admin
        newVaccination.brand = self.brand
        return newVaccination
    }
    
    static func == (lhs: Vaccination, rhs: Vaccination) -> Bool {
        return lhs.name.replacingOccurrences(of: "\n", with: " ") == rhs.name.replacingOccurrences(of: "\n", with: " ")
    }
}
