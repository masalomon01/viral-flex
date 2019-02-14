import Foundation

class Folder: NSObject, NSCoding {
    
    static var folders: [Folder]!
    
    var uuid: String!
    var name: String!
    
    var formsID: [String] = []
    
    required init(_ name: String) {
        uuid = UUID().uuidString
        self.name = name
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(uuid, forKey: "uuid")
        aCoder.encode(name, forKey: "name")
        
        aCoder.encode(formsID, forKey: "formsID")
    }
    
    required init?(coder aDecoder: NSCoder) {
        uuid = aDecoder.decodeObject(forKey: "uuid") as? String
        name = aDecoder.decodeObject(forKey: "name") as? String
        
        formsID = aDecoder.decodeObject(forKey: "formsID") as! [String]
    }
    
    static func loadFolders() -> [Folder] {
        
        if (folders == nil) {
            
            let defaults = UserDefaults.standard
            let data = defaults.object(forKey: "folders")
            if data != nil {
                folders = NSKeyedUnarchiver.unarchiveObject(with: data as! Data) as! [Folder]
            }
            else {
                folders = []
            }
        }
        
        return folders
    }
    
    static func saveFolders() {
        
        let defaults = UserDefaults.standard
        let data = NSKeyedArchiver.archivedData(withRootObject: folders)
        defaults.set(data, forKey: "folders")
        defaults.synchronize()
    }
    
    func saveChanges() {
        for (index, folder) in Folder.loadFolders().enumerated() {
            if (self.uuid == folder.uuid) {
                Folder.folders[index] = self
                break
            }
        }
        Folder.saveFolders()
    }
    
    func create() {
        Folder.loadFolders()
        Folder.folders.append(self)
        Folder.saveFolders()
    }
    
    func delete() {
        for (index, folder) in Folder.loadFolders().enumerated() {
            if (self.uuid == folder.uuid) {
                Folder.folders.remove(at: index)
                break
            }
        }
        Folder.saveFolders()
    }
    
    
    func addForm(form: Form) {
        removeForm(form: form)
        formsID.append(form.uuid)
        saveChanges()
    }
    
    func removeForm(form: Form) {
        for folder in Folder.loadFolders() {
            if (folder.formsID.contains(form.uuid)) {
                folder.formsID.remove(at: folder.formsID.firstIndex(of: form.uuid)!)
            }
        }
    }
    
    func getForms(type: String) -> [Form] {
        var forms: [Form] = []
        if type == "draft" {
            for form in Form.getDraftForms() {
                if formsID.contains(form.uuid) {forms.append(form)}
            }
        }
        else {
            for form in Form.getSubmittedForms() {
                if formsID.contains(form.uuid) {forms.append(form)}
            }
        }
        return forms
    }
}
