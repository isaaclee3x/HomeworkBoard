//
//  ClassesManager.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 17/6/22.
//

import Foundation
import FirebaseDatabase
import FirebaseDatabaseSwift

/// Manages the classes and their boards
/// Used to be two different managers (board manager and class managers)
class ClassManager: ObservableObject {
    
    @Published var classes: [Class]?
    private var ref = Database.database().reference()
    
    
    /// Getting the JSON object for all the class
    ///
    /// It also decodes the JSON object into the Class Struct (can be injected into other views)
    func getClasses() async {
        ref.child("classes").observeSingleEvent(of: .value) { snapshot in
            let value = snapshot.value as? NSDictionary
            let decoder = JSONDecoder()
            var strings: [String] = []
            var classes: [Class] = []
            let keys = value?.allKeys as! [String]
            for key in keys {
                strings.append(value?[key] as! String)
            }
            
            for clas in strings {
                let data = clas.data(using: .utf8)!
                let decodedClas = try? decoder.decode(Class.self, from: data)
                classes.append(decodedClas!)
            }   
            self.classes = classes
        }
        try? await Task.sleep(nanoseconds: 100_000_000)
    }
    
    /// Gets the JSON object from one class
    ///
    /// It also decodes the JSON object into the Class Struct (can be injected into other views)
    ///  - Parameter name: Name of the class
    func getClass(name: String) async {
        ref.child("classes").child(name).observeSingleEvent(of: .value) { snapshot in
            
            let value = snapshot.value as? String
            var classes: [Class] = []
            let decoder = JSONDecoder()
            let data = value!.data(using: .utf8)!
            let decodedClas = try? decoder.decode(Class.self, from: data)
            classes.append(decodedClas!)
            self.classes = classes
        }
        try? await Task.sleep(nanoseconds: 100_000_000)
    }
    /// Creates a new class
    ///
    /// Note that it saves the class as a JSON object so that it can be more easily decoded into the Class struct
    /// - Parameter name: Name of the class
    func createClass(name: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        dateFormatter.locale = .current
        let clas = Class(name: name, date: dateFormatter.string(from: Date()))
        let encoder = JSONEncoder()
        let encodedClas = try? encoder.encode(clas)
        let stringEncoded = String(data: encodedClas!, encoding: .utf8)
        ref.child("classes").child(name).setValue(stringEncoded)
    }
    
    /// Deletes the class by setting its value to nil
    ///  - Parameter name: Name of the class to delete
    func deleteClass(name: String) {
        ref.child("classes").child(name).setValue("")
    }
}
