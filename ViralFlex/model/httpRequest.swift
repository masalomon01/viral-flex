import Foundation
import UIKit
import MobileCoreServices

class HttpRequest {
    
    static let baseUrl = "https://client.rgportal.com/api"
    
    static func signin(email: String, password: String, onRequestSuccess: @escaping (_ token: String, _ response: HTTPURLResponse)->(), onRequestFailed: @escaping (_ response: HTTPURLResponse, _ message: String)->()) {
        
        if let url = URL(string: baseUrl + "/users/auth/app-signin") {
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let data: [String: Any] = [
                "signinForm": [
                    "email": email,
                    "password": password
                ]
            ]
            
            do {
                let serializedData = try JSONSerialization.data(withJSONObject: data)
                urlRequest.httpBody = serializedData
            } catch {
                return
            }
            
            URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                if error != nil{
                    
                }else{
                    
                    let parsedData = try? JSONSerialization.jsonObject(with: data!) as! [String:Any]
                    
                    if parsedData != nil && parsedData!["token"] != nil {
                        onRequestSuccess(parsedData!["token"] as! String, response as! HTTPURLResponse)
                    }
                    else {
                        print(parsedData)
                        onRequestFailed(response as! HTTPURLResponse, parsedData?["message"] as! String)
                    }
                }
                }.resume()
        }
    }
    
    static func submitForm(_ form: Form, pin: Int, onRequestSuccess: @escaping (_ response: HTTPURLResponse)->(), onRequestFailed: @escaping (_ response: HTTPURLResponse)->()) {
        
        let defaults = UserDefaults.standard
        let token = defaults.object(forKey: "token") as! String
        
        if let url = URL(string: baseUrl + "/app-forms") {
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            var barcodes: [String] = []
            for barcode in form.barCodes {
                barcodes.append(barcode.code)
            }
            
            var vaccinations: [[String: Any]] = []
            for vaccination in form.vaccinations {
                vaccinations.append([
                    "name": vaccination.name,
                    "age": vaccination.age,
                    "doses": vaccination.doses,
                    "brand": vaccination.brand
                    ])
            }
            
            var TestTypeMap: [String : String] = [
                "Innovax ILT Vaccine Test": "Innovax ILT",
                "Innovax ND Vaccine Test": "Innovax ND",
                "Innovax ND-IBD Vaccine Test": "Innovax ND IBD",
                "ILT Field Virus Test": "ILT field virus",
                "IBD Field Virus Test": "IBD field virus"]
            var actualTestType = String(form.testType!)
            
            let data: [String: Any] = [
                "pin": pin,
                "forms": [
                    [
                        "formName": form.name,
                        "testType": TestTypeMap[actualTestType],
                        "farmName": form.farmName,
                        "country": form.country,
                        "barcodes": barcodes,
                        "samplingAge": form.samplingAge,
                        "sampleType": form.sampleType,
                        "birdBreed": form.birdType,
                        "hatcherySource": form.hatcherySource,
                        "longitude": 23.67889,
                        "latitude": 56.9888,
                        "symptoms": form.clinicalSigns,
                        "symptomNotes": "This is an example symptom note.",
                        "vetPractice": form.veterinaryPractice,
                        "vetSurgeon": form.veterinarySurgeon,
                        "savedDate": form.createTime?.timeIntervalSince1970,
                        "sentDate": Date().timeIntervalSince1970,
                        "zipPostCountry": form.postCode,
                        "labRefNo": form.labReferenceNumber,
                        "shedId": form.shedID,
                        "vaccinations": vaccinations,
                        "hatcherVaccinator": form.hatcherVaccinator,
                        "inOvoVaccinator": form.inOvoVaccinator,
                        "companyName": form.companyName,
                        "sampleCode": form.sampleCode
                        
                    ]
                ]
            ]
            
            do {
                let serializedData = try JSONSerialization.data(withJSONObject: data)
                
                if let JSONString = String(data: serializedData, encoding: String.Encoding.utf8) {
                    print(JSONString)
                }
                
                urlRequest.httpBody = serializedData
            } catch {
                print("error")
                return
            }
            if form.pictures.count >= 5 {
                print("too many pictures, max allowed is 4")
                if let urlFake = URL(string: baseUrl + "/fake/to/fail"){
                    urlRequest = URLRequest(url: urlFake)
                }
            }
            URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                if error != nil{
                    print(error.debugDescription)
                }else{
                    let str = String(data: data!, encoding: String.Encoding.utf8)
                    print(str)
                    if (response as! HTTPURLResponse).statusCode == 200 {
                        
                        if form.pictures != [] {
                            submitPictures(token: token, form: form)
                            onRequestSuccess(response as! HTTPURLResponse)
                        }
                        else{
                            onRequestSuccess(response as! HTTPURLResponse)
                        }
                    }
                    else {
                        onRequestFailed(response as! HTTPURLResponse)
                    }
                }
                }.resume()
            
        }
        
        
    }
    
    
    static func createRequest(token: String, form: String, farm: String, pictures: [String]) throws -> URLRequest {
        
        let boundary = generateBoundaryString()
        let urlStr = baseUrl + "/app-forms/images?formName=" + form.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! + "&farmName=" + farm.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let requestUrl = URL(string: urlStr)
        
        var request = URLRequest(url: requestUrl!)
        request.httpMethod = "POST"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = try createBody(filePathKey: "images", paths: pictures, boundary: boundary)
        return request
    }
    
    static func createBody(filePathKey: String, paths: [String], boundary: String) throws -> Data {
        var body = Data()
        
        let directoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        for path in paths {
            
            let fileURL: URL = directoryURL.appendingPathComponent(path)
            let fileName = fileURL.lastPathComponent
            let data = try Data(contentsOf: fileURL)
            let mimetype = mimeType(for: path)
            
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(filePathKey)\"; filename=\"\(fileName)\"\r\n")
            body.append("Content-Type: \(mimetype)\r\n\r\n")
            body.append(data)
            body.append("\r\n")
        }
        
        body.append("--\(boundary)--\r\n")
        return body
    }
    
    
    static func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
    
    
    static func mimeType(for path: String) -> String {
        let url = URL(fileURLWithPath: path)
        let pathExtension = url.pathExtension
        
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }
    
    static func submitPictures(token: String, form: Form) {
        
        let request = try? createRequest(token: token, form: form.name, farm: form.farmName!, pictures: form.pictures)
        
        URLSession.shared.dataTask(with: request!) { (data, response, error) in
            if error != nil{
                print(error.debugDescription)
            }else{
                let str = String(data: data!, encoding: String.Encoding.utf8)
                print(str)
            }
            }.resume()
    }
}


extension Data {
    
    mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}
