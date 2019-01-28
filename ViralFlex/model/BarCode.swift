import Foundation

class BarCode: NSObject, NSCoding {
    
    var code: String!
    var time: Date!
    
    required init(code: String, time: Date) {
        self.code = code
        self.time = time
    }
    
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(code, forKey: "code")
        aCoder.encode(time, forKey: "time")
    }
    
    required init?(coder aDecoder: NSCoder) {
        //code = aDecoder.decodeObject(forKey: "code") as! String
        code = "0987654321"
        time = aDecoder.decodeObject(forKey: "time") as? Date
    }
}
