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
        let formattedDate = dateFormatter.string(from: Date())
        var clas = Class(name: name, date: formattedDate)
        clas.board.entries[formattedDate] = []
        for _ in 0 ..< 10 {
            clas.board.entries[formattedDate]?.append(Entry(entry: nil, due: nil))
        }
        let encoder = JSONEncoder()
        let encodedClas = try? encoder.encode(clas)
        let stringEncoded = String(data: encodedClas!, encoding: .utf8)
        ref.child("classes").child(name).setValue(stringEncoded)
    }
    
    
    /// Takes the data of an updated class and saves it under the class' path
    /// - Parameter clas: The class' data to encode
    func saveClass(clas: Class) async {
        let encoder = JSONEncoder()
        let encodedClas = try? encoder.encode(clas)
        let stringEncoded = String(data: encodedClas!, encoding: .utf8)
        try! await ref.child("classes").child(clas.name).setValue(stringEncoded)
        await self.getClass(name: clas.name)
    }
    
    /// Deletes the class by setting its value to nil
    ///  - Parameter name: Name of the class to delete
    func deleteClass(name: String) {
        ref.child("classes").child(name).setValue("")
    }
    
    /// Creates a new board if the clas.board[date] value is nil
    /// - Parameters:
    ///   - clas: The class to save the new entries in
    ///   - date: The key to save in
    func createBoard(clas: Class, date: String) async {
        
        var clas = clas
        clas.board.entries[date] = []
        for _ in 0 ..< 10 {
            clas.board.entries[date]?.append(Entry(entry: nil, due: nil))
        }
        await self.saveClass(clas: clas)
    }
}
