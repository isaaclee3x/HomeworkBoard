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
class ClassManager {
    
    var ref = Database.database().reference()
    var encoder = JSONEncoder()
    
    /// Creates a new class
    ///
    /// Note that it saves the class as a JSON object so that it can be more easily decoded into the Class struct
    /// - Parameter name: Name of the class
    func createClass(name: String) async {
        let clas = Class(name: name, date: Date().toFormat("dd MMMM yyyy"))
        await saveClass(clas: clas)
    }
    
    func getClass(name: String = "") async -> [Class] {
        var returnClas: [Class] = []
        if name == "" {
            ref.child("classes").observeSingleEvent(of: .value) { snapshot in
                guard let value = snapshot.value as? NSDictionary else { return }
                
                let keys = value.allValues as? [String]
                let decoder = JSONDecoder()
                for key in keys! {
                    let result = try? decoder.decode(Class.self, from: key.data(using: .utf8)!)
                    returnClas.append(result!)
                }
                
            }
        } else {
            ref.child("classes").child(name).observeSingleEvent(of: .value) { snapshot in
                let value = snapshot.value as? String
                
                let decoder = JSONDecoder()
                let clas = try! decoder.decode(Class.self, from: value!.data(using: .utf8)!)
                returnClas = [clas]
                
            }
        }
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        return returnClas
    }
    
    /// Takes the data of an updated class and saves it under the class' path
    /// - Parameter clas: The class' data to encode
    func saveClass(clas: Class) async {
        let encoder = JSONEncoder()
        let json = try! encoder.encode(clas)
        try! await ref.child("classes").child(clas.name).setValue(String(data: json, encoding: .utf8))
    }
    
    /// Deletes all instances of a member being in a class
    ///
    /// This deletes the class in classes/clas, and also /clas where the names of members are in
    /// It uses the data of the members to set their class to "",
    ///  - Parameter name: Name of the class to delete
    func deleteClass(name: String) async {
        try! await ref.child("classes").child(name).removeValue()
        
        let fetchName = await MemberManager().getMembers(of: name)
        
        guard fetchName != [] else { return }
        
        for name in fetchName {
            if let member = await MemberManager().getAccount(username: name) {
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
