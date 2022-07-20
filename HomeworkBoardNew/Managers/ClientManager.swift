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
    
    private let ref = Database.database().reference()
    private let encoder = JSONEncoder()
    
    func pullData<T>(pull what: T, name: String? = nil) async -> [T] where T: Item, T: Decodable {
        
        var returnData: [T] = []
        var path = ref
        
        if let type = what.type {
            if let name = name {
                path = ref.child(type).child(name)
            } else {
                path = ref.child(type)
            }
        }
        
        path.observeSingleEvent(of: .value) { snapshot in
            let decoder = JSONDecoder()
            let value = snapshot.value as? NSDictionary
            
            guard value != nil else {
                let value = snapshot.value as? String
                guard value != nil else { return }
                let data = value!.data(using: .utf8)
                let returnValue = try! decoder.decode(T.self, from: data!)
                returnData = [returnValue]
                return
            }
            
            let values = value!.allValues as! [String]
            let returnValue = values.map { item -> T in
                let data = item.data(using: .utf8)
                return try! decoder.decode(T.self, from: data!)
            }
            returnData = returnValue
        }
        try? await Task.sleep(nanoseconds: 100_000_000)
        return returnData
    }
    
    func saveData<T>(type: String, item: T, perm: Permissions = .member) async where T: Item, T: Codable {
        
        var path = ref
        
        guard type == item.type else { return }
        path = path.child(type).child(item.name)
        
        guard let data = try? JSONEncoder().encode(item) else { return  }
        try! await path.setValue(String(data: data, encoding: .utf8))
        
        if type == "users" {
            if perm == .member || perm == .leader {
                let clas = item.getProp()
                path = ref.child(clas)
                
                try! await path.setValue([item.name: item.name])
            }
        }
    }
}

