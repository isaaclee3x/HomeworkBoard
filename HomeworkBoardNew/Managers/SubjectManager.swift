//
//  SubjectManager.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 5/7/22.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseDatabaseSwift

class SubjectManager {
    
    var ref = Database.database().reference()
    var encoder = JSONEncoder()
    var decoder = JSONDecoder()
    
    /// Appends a new subject to the ./subject path
    /// - Parameter subj: Subject to add
    func addSubject(subj: Subject) async {
        let json = try? encoder.encode(subj)
        try! await ref.child("subjects").child(subj.name).setValue(String(data: json!, encoding: .utf8))
    }
    
    /// Deletes the subject
    /// - Parameter subj: Subject to remove
    func deleteSubject(subj: Subject) async {
        try! await ref.child("subjects").child(subj.name).removeValue()
    }
}
