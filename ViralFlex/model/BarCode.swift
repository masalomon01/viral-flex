import Foundation

class BarCode: NSObject, NSCoding {
    
    var code: String!
    var time: Date!
    
    required init(code: String, time: Date) {
        self.code = code
        self.time = time
    }
    
    func encode(with aCoder: NSCoder) {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        
    }
}
