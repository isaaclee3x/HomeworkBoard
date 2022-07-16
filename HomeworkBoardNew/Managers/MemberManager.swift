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
import FirebaseDatabaseSwift

/// Manages the account details for each user
///
///  This manager allows the user to create an account, and to authenticate their account.
///  It would also allow them to recall back their password if they forget
class MemberManager: ObservableObject {
    
    /// Value is changed based on the account's username
    @Published var member: Member?
    @ObservedObject var CLM = ClientManager()
    private var ref = Database.database().reference()
    
    /// Saves a member (with an encrypted password) to the /users/(username) path
    ///
    /// It also encodes it using JSONEncoder so that it can be more easily parsed into the right struct
    /// - Parameter member: The member to save
    func saveAccount(member: Member, bypass: Bool) async {
        if !bypass {
            guard await !member.username.exists(in: "member") else { return }
            guard await member.clas.exists(in: "class") else { return }
        }
        
        var member = member
        member.password = member.password.toBase64()
        await CLM.saveData(member: member)
    }
    
    /// Checks whether the username and password the user entered matches the username and password saved in the cloud
    /// - Parameters:
    ///   - username: Serves as the path to get from the database to check with
    ///   - password: Locally inputed password
    ///   - what: What to do if the authentication is successful
    func auth(username: String, password: String, do what: (() -> Void)..., not fail: (() -> Void)...) async {
        await self.getAccount(username: username)
        if member?.username == username && member?.password == password {
            for i in what { i() }
        } else {
            for i in fail { i() }
        }
    }
    
    /// Gets the account's data from the database
    ///
    /// Decodes the data into the Member struct
    /// - Parameter username: The account to pull
    func getAccount(username: String) async {
        let decoder = JSONDecoder()
        var member = Member()
        if let data = await CLM.pullData(pull: Member.self, username: username) {
            member = try! decoder.decode(Member.self, from: data)
            member.password = member.password.fromBase64()!
        }
        self.member = member
        
    }
    
    /// Same functionality as getMember(), except that it returns the Member gotten except of updating @Published member
    /// This is used in limited occasions, where admin controls require user data but admin's own data cannot be updated
    /// - Parameter username: The account to pull
    /// - Returns: Returns the member's value
    func findAccount(username: String) async -> Member? {
        var returnMember: Member? = nil
        if let data = await self.CLM.pullData(pull: Member.self, username: username) {
            let decoder = JSONDecoder()
            returnMember = try! decoder.decode(Member.self, from: data)
        }
        try? await Task.sleep(nanoseconds: 100_000_000)
        return returnMember
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
            guard let value else { return }
            
            names = value.allKeys as? [String] ?? []
        }
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        return names
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
            
            await CM.getClasses()
            var classes: [String] = []
            for clas in await CM.classes! {
                classes.append(clas.name)
            }
            
            if classes.contains(self) { return true }
            return false
        } else {
            let MM = await MemberManager()
            
            if await MM.findAccount(username: self) == nil { return false }
        }
        return true
    }
}
