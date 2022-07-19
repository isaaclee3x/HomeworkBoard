//
//  ClientManager.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 13/7/22.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseDatabase
import FirebaseDatabaseSwift

class ClientManager: ObservableObject {
    
    @Published var data: Data?
    
    private let ref = Database.database().reference()
    private let encoder = JSONEncoder()
    
    func pullData<T>(pull what: T.Type, username: String = "", clas: String = "", subject: String = "") async -> Data? where T: (Decodable) {
        var path = ref.child("hello")
        var data: Data? = nil
        switch what {
        case is Member.Type: path = ref.child("users").child(username)
        case is Class.Type: path = (clas != "" ? ref.child("classes").child(clas) : ref.child("classes"))
        case is Subject.Type: path = ref.child("subjects")
        default:
            let exception = NSException(name: NSExceptionName("Unable to proceed"), reason: "Unable to get data due to invalid type")
            exception.raise()
        }
        
        path.observeSingleEvent(of: .value) { snapshot in
            let value = snapshot.value as? NSDictionary
            var stringValue = ""
            guard value != nil else { return }
            switch what {
            case is Member.Type:
                stringValue = value!["data"] as! String
            case is Class.Type:
                if clas != "" {
                    stringValue = value!["data"] as! String
                } else {
                    let value = snapshot.value as! NSDictionary
                    let stringClasses = value.allValues as! [String]
                    stringValue = stringClasses.joined(separator: " n ")
                }
            case is Subject.Type:
                if subject != "" {
                    stringValue = value![subject] as! String
                } else {
                    let values = value?.allValues.map({ i in
                        i as! String
                    })
                    stringValue = values!.joined(separator: " n ")
                    print(stringValue)
                }
            default: break
            }
            let convertedString = stringValue.data(using: .utf8)
            data = convertedString
        }
        try? await Task.sleep(nanoseconds: 100_000_000)
        return data
    }
    
    func saveData(member: Member? = nil, clas: Class? = nil, subj: Subject? = nil) async {
        var path = ref.child("hello")
        var addToClas = ref.child("hello")
        var data: Data! = Data()
        
        if clas != nil {
            path = ref.child("classes").child(clas!.name)
            data = try? encoder.encode(clas)
        }
        else if member != nil {
            path = ref.child("users").child(member!.username)
            addToClas = ref.child(member!.clas).child(member!.username)
            data = try? encoder.encode(member)
        }
        else if subj != nil {
            path = ref.child("subjects").child(subj!.name)
            data = try? encoder.encode(subj)
        }
        
        try? await path.setValue(String(data: data, encoding: .utf8))
        if member != nil {
            try? await addToClas.setValue(
                [
                    "data": member?.username
                ]
            )
        }
    }
}
