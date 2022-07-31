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

class ClientManager: ObservableObject {
    
    let ref = Database.database().reference()
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
     
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
            let value = snapshot.value as? NSDictionary
            
            guard value != nil else {
                let value = snapshot.value as? String
                guard value != nil else { return }
                let data = value!.data(using: .utf8)
                let returnValue = try! self.decoder.decode(T.self, from: data!)
                returnData = [returnValue]
                return
            }
            
            let values = value!.allValues as! [String]
            let returnValue = values.map { item -> T in
                let data = item.data(using: .utf8)
                return try! self.decoder.decode(T.self, from: data!)
            }
            returnData = returnValue
        }
        try? await Task.sleep(nanoseconds: 100_000_000)
        return returnData
    }
    
    func saveData<T>(type: String, item: T, bypass: Bool = false) async where T: Item, T: Codable {
        
        var path = ref
        
        guard type == item.type else { return }
        path = path.child(type).child(item.name)
        
        guard let data = try? self.encoder.encode(item) else { return }
        try! await path.setValue(String(data: data, encoding: .utf8))
        
        if type == "users" {
            if bypass {
                let clas = item.getProp()
                path = ref.child(clas).child(item.name)
                
                try! await path.setValue(item.name)
            }
        }
    }
}

