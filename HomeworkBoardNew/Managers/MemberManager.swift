//
//  AccountManager.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 16/6/22.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseDatabase
import CoreXLSX

/// Manages the account details for each user
///
///  This manager allows the user to create an account, and to authenticate their account.
///  It would also allow them to recall back their password if they forget
class MemberManager {
    
    /// Value is changed based on the account's username
    let ref = Database.database().reference()
    var defaultPassword: String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy"
        
        let year = dateFormatter.string(from: Date())
        return "YTSS\(year)"
    }
    
    /// Saves a member (with an encrypted password) to the /users/(username) path
    ///x
    /// It also encodes it using JSONEncoder so that it can be more easily parsed into the right struct
    /// - Parameter member: The member to save
    func saveAccount(member: Member, bypass: Bool) async {
        if !bypass {
            guard await !member.name.exists(in: "member") else { return }
            guard await member.clas.exists(in: "class") else { return }
        }
        
        var member = member
        member.password = member.password.toBase64()
        let encoder = JSONEncoder()
        let json = try? encoder.encode(member)
        try! await ref.child("users").child(member.name).setValue(String(data: json!, encoding: .utf8))
        try! await ref.child(member.clas).child(member.name).setValue(member.name)
    }
    
    /// Checks whether the username and password the user entered matches the username and password saved in the cloud
    /// - Parameters:
    ///   - username: Serves as the path to get from the database to check with
    ///   - password: Locally inputed password
    ///   - what: What to do if the authentication is successful
    func auth(username: String, password: String, do what: (() -> Void)..., not fail: (() -> Void)...) async {
        let member = getAccount(username: username)
        if member?.name == username && member?.password == password {
            for i in what { i() }
        } else {
            for i in fail { i() }
        }
    }
    
    
    /// Same functionality as getMember(), except that it returns the Member gotten except of updating @Published member
    /// This is used in limited occasions, where admin controls require user data but admin's own data cannot be updated
    /// - Parameter username: The account to pull
    /// - Returns: Returns the member's value
    func getAccount(username: String) -> Member? {
        var member: Member? = nil
        ref.child("users").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? String else { return }
            
            let decoder = JSONDecoder()
            member = try! decoder.decode(Member.self, from: value.data(using: .utf8)!)
        }
        return member
    }
    
    /// Returns the names of members in a class
    ///
    /// Checks the /clas dir to pull the names of the members
    /// These can be used to pull their information using getMember()
    /// - Parameter clas: The class to check
    /// - Returns: The names of members in the class
    func getMembers(of clas: String) async -> [String] {
        var names: [String] = []
        ref.child(clas).observeSingleEvent(of: .value) { snapshot in
            let value = snapshot.value as? NSDictionary
            guard value != nil else { return }
            
            names = value!.allKeys as? [String] ?? []
        }
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        return names
    }
    
    func deleteMember(username: String) async {
        let member = self.getAccount(username: username)!
        try! await ref.child(member.clas).child(member.name).setValue(nil)
        try! await ref.child("users").child(member.name).setValue(nil)
        
    }
}



extension String {
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    func exists(in the: String) async -> Bool {
        if the == "class" {
            let CM = await ClassManager()
            
            let classes = await CM.getClass()
            var classNames: [String] = []
            for clas in await classes {
                classNames.append(clas.name)
            }
            
            if classNames.contains(self) { return true }
            return false
        } else {
            let MM = await MemberManager()
            
            if MM.getAccount(username: self) == nil { return false }
        }
        return true
    }
    
    func isDefault() -> Bool {
        self == MemberManager().defaultPassword ? true : false
    }
}
