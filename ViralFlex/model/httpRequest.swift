import Foundation


class HttpRequest {
    
    static let baseUrl = "https://client.rgportal.com/api"
    
    static func signin(email: String, password: String, onRequestSuccess: @escaping (_ token: String)->(), onRequestFailed: @escaping (_ response: HTTPURLResponse, _ message: String)->()) {
        
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
                        onRequestSuccess(parsedData!["token"] as! String)
                    }
                    else {
                        print(parsedData)
                        onRequestFailed(response as! HTTPURLResponse, parsedData?["message"] as! String)
                    }
                }
                }.resume()
        }
    }
    
    static func submitForm(_ form: Form, pin: Int, onRequestSuccess: @escaping ()->(), onRequestFailed: @escaping (_ response: HTTPURLResponse)->()) {
        
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
            
            let data: [String: Any] = [
                "pin": pin,
                "forms": [
                    [
                        "formName": form.name,
                        "testType": form.birdType,
                        "farmName": form.farmName,
                        "country": form.country,
                        "barcodes": barcodes,
                        "samplingAge": form.samplingAge,
                        "birdBreed": form.birdType,
                        "hatcherySource": form.hatcherySource,
                        "clinicalSigns": form.clinicalSigns,
                        "vetPractice": form.veterinaryPractice,
                        "vetSurgeon": form.veterinarySurgeon,
                        "savedDate": form.createTime?.timeIntervalSince1970,
                        "sentDate": form.submitTime?.timeIntervalSince1970,
                        "zipPostCountry": form.postCode,
                        "labRefNo": form.labReferenceNumber,
                        "sampleType": form.sampleType,
                        "shedId": form.shedID,
                        "vaccinations": vaccinations,
                        "hatcherVaccinator": form.hatcherVaccinator,
                        "inOvoVaccinator": form.inOvoVaccinator
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
            
            URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                if error != nil{
                    print(error.debugDescription)
                    print(22222)
                }else{
                    
                    if (response as! HTTPURLResponse).statusCode == 200 {print(11111)
                        onRequestSuccess()
                    }
                    else {print(11112)
                        let str = String(data: data!, encoding: String.Encoding.utf8)
                        print(str)
                        onRequestFailed(response as! HTTPURLResponse)
                    }
                }
                }.resume()
            
        }
        
        
    }
    
    static func submitPictures() {
        
        
    }
}
