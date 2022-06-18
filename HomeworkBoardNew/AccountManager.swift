//
//  AccountManager.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 16/6/22.
//

import Foundation
import FirebaseDatabase
import FirebaseDatabaseSwift

/// Manages the account details for each user
///
///  This manager allows the user to create an account, and to authenticate their account.
///  It would also allow them to recall back their password if they forget
class AccountManager: ObservableObject {
    
    /// Value is changed based on the account's username
    @Published var account: Member?
    
    private var ref = Database.database().reference()

    
    /// Saves a member (with an encrypted password) to the /users/(username) path
    ///
    /// It also encodes it using JSONEncoder so that it can be more easily parsed into the right struct
    /// - Parameter member: The member to save
    func saveAccount(member: Member) async {
        
        guard !member.password.isTrulyEmpty() else { return }
        guard await !member.username.exists(in: "member") else { return }
        guard await member.clas.exists(in: "class") else { return }
        
        var member = member
        member.password = member.password.toBase64()
        let encoded = try? JSONEncoder().encode(member)
        let stringEncoded = String(data: encoded!, encoding: .utf8)
        
        try! await ref.child("users").child(member.username).setValue(
            [
                "data": stringEncoded
            ]
        )
    }
    
    /// Checks whether the username and password the user entered matches the username and password saved in the cloud
    /// - Parameters:
    ///   - username: Serves as the path to get from the database to check with
    ///   - password: Locally inputed password
    ///   - what: What to do if the authentication is successful
    func auth(username: String, password: String, do what: () -> Void) async {
        let _ = await self.getAccount(username: username)
        if account?.username == username && account?.password == password {
            what()
        }
    }
    
    /// Gets the account's data from the database
    /// 
    /// Decodes the data into the Member struct
    /// - Parameter username: The account to pull
    func getAccount(username: String) async {
        
        guard !username.isTrulyEmpty() else { return }
        
        ref.child("users").child(username).child("data").observeSingleEvent(of: .value) { snapshot in
            
            let value = snapshot.value as? String
            guard value != nil else { return }
            
            let data = value!.data(using: .utf8)!
            let decoder = JSONDecoder()
            var member = try? decoder.decode(Member.self, from: data)
            let decodedPassword = (member?.password.fromBase64())!
            member?.password = decodedPassword
            self.account = member
        }
        
        try? await Task.sleep(nanoseconds: 100_000_000)
    }
    
}

extension String {
    func isTrulyEmpty() -> Bool {
        let range = NSRange(location: 0, length: self.utf16.count)
        let regex = try! NSRegularExpression(pattern: #"\s"#)
        guard regex.firstMatch(in: self, options: [], range: range) != nil else { return false}
        
        return true
    }
    
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
            let CM = ClassManager()
            
            await CM.getClasses()
            var classes: [String] = []
            for clas in CM.classes! {
                classes.append(clas.name)
            }
            
            if classes.contains(self) { return true }
            return false
        } else {
            let MM = AccountManager()
            
            await MM.getAccount(username: self)
            if MM.account == nil { return false }
        }
        return true
    }
}
