import Foundation


class HttpRequest {
    
    static func request(_ form: Form, onRequestSuccess: @escaping ()->(), onRequestFailed: @escaping ()->()) {
        
        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI1YzRiMzFmOTcwMjAyYzdhNTVmZDgxYzEiLCJmaXJzdE5hbWUiOiJNYXJpbyIsImxhc3ROYW1lIjoiU2Fsb21vbiIsImVtYWlsIjoibWFyaW8uc2Fsb21vbjA3QGdtYWlsLmNvbSIsInBpbiI6MTIzNCwiaWF0IjoxNTQ4NDMyMzc1fQ.U9dU36ZFkD0Ua3w4c9mK05R9m-YFoISeMswagh-0m4A"

        var TestTypeMap: [String : String] = [
            "Innovax ILT Vaccine Test": "Innovax ILT",
            "Innovax ND Vaccine Test": "Innovax ND",
            "Innovax ND-IBD Vaccine Test": "Innovax ND IBD",
            "ILT Field Virus Test": "ILT field virus",
            "IBD Field Virus Test": "IBD field virus"]
        var actualTestType = String(form.testType!)
        
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
                        "testType": TestTypeMap[actualTestType],
                        "farmName": form.farmName,
                        "country": form.country,
                        "barcodes": ["00090117", "00090100"],
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
                        "inOvoVaccinator": form.inOvoVaccinator,
                        
                        //"hatcherVaccinator": form.hatcherVaccinator
                        //api is missing sample code "sampleCode": form.sampleCode
                        //api is missing Company Name "companyName": form.companyName
                        // api is missing County "county": form.county
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
                    onRequestSuccess()
                }else{
                    let str = String(data: data!, encoding: String.Encoding.utf8)
                    print(str)
                }
                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200:
                        onRequestSuccess()
                    default:
                        onRequestFailed()
                    }
                } else {
                    onRequestFailed()
                }
                        
                }.resume()
        }
        
        
    }
}
