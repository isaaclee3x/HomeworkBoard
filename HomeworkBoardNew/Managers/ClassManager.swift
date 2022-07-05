//
//  ClassesManager.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 17/6/22.
//

import SwiftDate
import Foundation
import FirebaseDatabase
import FirebaseDatabaseSwift

/// Manages the classes and their boards
/// Used to be two different managers (board manager and class managers)
class ClassManager: ObservableObject {
    
    @Published var classes: [Class]?
    
    private var ref = Database.database().reference()
    private var encoder = JSONEncoder()
    private var decoder = JSONDecoder()
    
    /// Getting the JSON object for all the class
    ///
    /// It also decodes the JSON object into the Class Struct (can be injected into other views)
    func getClasses() async {
        ref.child("classes").observeSingleEvent(of: .value) { snapshot in
            let value = snapshot.value as? NSDictionary
            var strings: [String] = []
            var classes: [Class] = []
            guard let keys = value?.allKeys else { self.classes = nil; return }
            
            for key in keys as! [String] {
                strings.append(value?[key] as! String)
            }
            
            for clas in strings {
                let data = clas.data(using: .utf8)!
                let decodedClas = try? self.decoder.decode(Class.self, from: data)
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
            let data = value!.data(using: .utf8)!
            let decodedClas = try? self.decoder.decode(Class.self, from: data)
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
        var date = Date()
        var clas = Class(name: name, date: date.toFormat("dd MMMM yyyy"))
        for i in 0 ..< 2 {
            let formattedDate = date.toFormat("dd MMMM yyyy")
            clas.board.entries[formattedDate] = []
            for _ in 0 ..< 10 {
                clas.board.entries[formattedDate]?.append(Entry(entry: nil, due: nil))
            }
            date = Date().addingTimeInterval(TimeInterval(86400 * i))
        }
        let encodedClas = try? self.encoder.encode(clas)
        let stringEncoded = String(data: encodedClas!, encoding: .utf8)
        ref.child("classes").child(name).setValue(stringEncoded)
    }
    
    /// Takes the data of an updated class and saves it under the class' path
    /// - Parameter clas: The class' data to encode
    func saveClass(clas: Class) async {
        let encodedClas = try? self.encoder.encode(clas)
        let stringEncoded = String(data: encodedClas!, encoding: .utf8)
        try! await ref.child("classes").child(clas.name).setValue(stringEncoded)
    }
    
    /// Deletes the class by setting its value to nil
    ///  - Parameter name: Name of the class to delete
    func deleteClass(name: String) {
        ref.child("classes").child(name).removeValue()
    }
    
    /// Creates a new board if the clas.board[date] value is nil
    /// - Parameters:
    ///   - clas: The class to save the new entries in
    ///   - date: The key to save in
    func createBoard(clas: Class, date: String) async -> Class {
        var clas = clas
        clas.board.entries[date] = [Entry(entry: nil, due: nil)]
        for _ in 0 ..< 9 {
            clas.board.entries[date]?.append(Entry(entry: nil, due: nil))
        }
        await self.saveClass(clas: clas)
        return clas
    }
    
    func homeworkForTheWeek(clas: Class) -> [Entry] {
        var entries: [Entry] = []
        
        for i in 0 ..< 7 {
            let date = Date().addingTimeInterval(TimeInterval(86400 * i))
            let string = date.toFormat("dd MMMM yyyy")
            if let entryForTheDay = clas.board.entries[string] {
                
                for i in entryForTheDay {
                    entries.append(i)
                }
            }
        }
        
        return entries
    }
    
    func cleanBoard(clas: Class) async {
        var clas = clas
        let nsdict = clas.board.entries as NSDictionary
        let keys = nsdict.allKeys as! [String]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        
        var dates: [Date] = []
        
        for key in keys {
            dates.append(dateFormatter.date(from: key)!)
        }
        
        for date in dates {
            if date < Date() {
                let index = dates.firstIndex(of: date)!
                let clasIndex = clas.board.entries.firstIndex() { $0.key == keys[index] }!
                let key = clas.board.entries[clasIndex].key
                
                clas.board.entries[key] = []
            }
        }
        
        await self.saveClass(clas: clas)
    }
}
