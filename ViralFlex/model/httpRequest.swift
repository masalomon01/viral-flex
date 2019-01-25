import Foundation


class HttpRequest {
    
    static func request(_ form: Form) {
        
        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI1YzRiMzFmOTcwMjAyYzdhNTVmZDgxYzEiLCJmaXJzdE5hbWUiOiJNYXJpbyIsImxhc3ROYW1lIjoiU2Fsb21vbiIsImVtYWlsIjoibWFyaW8uc2Fsb21vbjA3QGdtYWlsLmNvbSIsInBpbiI6MTIzNCwiaWF0IjoxNTQ4NDMyMzc1fQ.U9dU36ZFkD0Ua3w4c9mK05R9m-YFoISeMswagh-0m4A"
        
        if let url = URL(string: "https://client.rgportal.com/api/app-forms") {
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let data: [String: Any] = [
                "pin": 1234,
                "forms": [
                    [
                        "formName": form.name,
                        "testType": form.birdType,
                        "farmName": form.farmName,
                        "country": form.country,
                        "barcodes": [
                            "00090117",
                            "00090100"
                        ],
                        "samplingAge": form.samplingAge,
                        "birdBreed": form.birdType,
                        "hatcherySource": form.hatcherySource,
                        "clinicalSigns": form.clinicalSigns,
                        "vetSurgeon": form.veterinarySurgeon,
                        "savedDate": form.createTime?.timeIntervalSince1970,
                        "sentDate": form.submitTime?.timeIntervalSince1970,
                        "zipPostCountry": form.postCode,
                        "labRefNo": form.labReferenceNumber,
                        "sampleType": form.sampleType,
                        "shedId": form.shedID
//                        "vaccinations": form.vaccinations
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
                print("Error: cannot create JSON from todo")
                return
            }
            
            _ = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                if error != nil{
                    print(error.debugDescription)
                }else{
                    let str = String(data: data!, encoding: String.Encoding.utf8)
                    print(str)
                }
                }.resume()
            //
        }
        
        
    }
}
