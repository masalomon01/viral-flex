import Foundation
import UIKit

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
                    print(22222)
                }else{
                    let str = String(data: data!, encoding: String.Encoding.utf8)
                    if (response as! HTTPURLResponse).statusCode == 200 {print(11111)
                        print(str)
                        if form.pictures != [] {
                            submitPictures(pictures: form.pictures, token: token, farm: form.farmName ?? "farm", form: form.name)
                            onRequestSuccess(response as! HTTPURLResponse)
                        }
                        else{
                            onRequestSuccess(response as! HTTPURLResponse)
                        }
                    }
                    else {print(11112)
                        print(str)
                        onRequestFailed(response as! HTTPURLResponse)
                    }
                }
                }.resume()
            
        }
        
        
    }
    
    static func createRequestBodyWith(imagePaths:[String]) -> Data{
        var bodyData = Data()
        let boundary: String
        boundary = "Boundary-\(NSUUID().uuidString)"
    
        for each in imagePaths {
            let url = URL(fileURLWithPath: each)
            let filename = url.lastPathComponent
            let splitName = filename.split(separator: ".")
            let name = String(describing: splitName.first)
            let filetype = String(describing: splitName.last)
            
            let imgBoundary = "\r\n--\(boundary)\r\nContent-Type: image/\(filetype)\r\nContent-Disposition: form-data; filename=\(filename); name=\(name)\r\n\r\n"
            
            if let d = imgBoundary.data(using: .utf8) {
                bodyData.append(d)
            }
            
            do {
                let imgData = try Data(contentsOf:url, options:[])
                bodyData.append(imgData)
            }
            catch {
                print("can't load image data")
                // can't load image data
            }
            
        }
        let closingBoundary = "\r\n--\(boundary)--"
        if let d = closingBoundary.data(using: .utf8) {
            bodyData.append(d)
        }
    return bodyData
    }

    static func submitPictures(pictures: [String], token: String, farm: String, form: String) {
        print(pictures)
        
        if let url = URL(string: baseUrl + "/app-forms/images?formName=" + form + "&farmName=" + farm) {
            let boundary = "Boundary-\(NSUUID().uuidString)"
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue(token, forHTTPHeaderField: "Authorization")
            urlRequest.setValue("multipart/form-data; boundary=----\(boundary)", forHTTPHeaderField: "Content-Type")
            //urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            //urlRequest.httpBody = bodyData.data(using: String.Encoding.utf8)
            print(url)
            let imgData = createRequestBodyWith(imagePaths: pictures)
            print (imgData)
            urlRequest.httpBody = imgData as Data
            
            URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                if error != nil{
                    print(error.debugDescription)
                    print(22222)
                }else{
                    let str = String(data: data!, encoding: String.Encoding.utf8)
                    if (response as! HTTPURLResponse).statusCode == 200 {print(11111)
                        print(str)
                    }
                    else {print(11112)
                        print(str)
                    }
                }
            }.resume()
    }
}
}
