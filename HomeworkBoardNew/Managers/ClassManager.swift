//
//  ClassesManager.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 17/6/22.
//

import SwiftDate
import SwiftUI
import Foundation
import Firebase
import FirebaseDatabase


/// Manages the classes and their boards
/// Used to be two different managers (board manager and class managers)
class ClassManager: ObservableObject {
    
    @Published var classes: [Class]?
    
    let MM = MemberManager()
    let BM = BoardManager()
    var ref = Database.database().reference()
    var encoder = JSONEncoder()
    var CLM = ClientManager()
    
    /// Getting the JSON object for all /one the class
    ///
    /// It also decodes the JSON object into the Class Struct (can be injected into other views)
    func getClass(name: String? = nil) async {
        if let name = name {
            self.classes = await CLM.pullData(pull: Class(name: "", date: ""), name: name)
        } else {
            self.classes = await CLM.pullData(pull: Class(name: "", date: ""))
        }
    }
    
    /// Creates a new class
    ///
    /// Note that it saves the class as a JSON object so that it can be more easily decoded into the Class struct
    /// - Parameter name: Name of the class
    func createClass(name: String) async {
        var date = Date()
        var clas = Class(name: name, date: Date().toFormat("dd MMMM yyyy"))
        for i in 0 ..< 2 {
            clas = await BM.createBoard(clas: clas, date: date.toFormat("dd MMMM yyyy"))
            date = date.advanced(by: Double(86400 * i))
        }
        await CLM.saveData(type: "classes", item: clas)
    }
    
    /// Takes the data of an updated class and saves it under the class' path
    /// - Parameter clas: The class' data to encode
    func saveClass(clas: Class) async {
        await CLM.saveData(type: "classes", item: clas)
    }
    
    /// Deletes all instances of a member being in a class
    ///
    /// This deletes the class in classes/clas, and also /clas where the names of members are in
    /// It uses the data of the members to set their class to "",
    ///  - Parameter name: Name of the class to delete
    func deleteClass(name: String) async {
        try! await ref.child("classes").child(name).removeValue()
        
        let fetchName = await MM.getMembers(of: name)
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        guard fetchName != [] else { return }
        
        for name in fetchName {
            if let member = await self.MM.findAccount(username: name) {
                var member = member
                member.clas = ""
                member.password = member.password.toBase64()
                let encodedMember = try? encoder.encode(member)
                try! await ref.child("users").child(member.name).child("data").setValue(String(data: encodedMember!, encoding: .utf8))
            }
        }
        
        try! await ref.child(name).removeValue()
    }
}
