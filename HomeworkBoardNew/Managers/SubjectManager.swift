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

class SubjectManager: ObservableObject {
    
    @Published var subjects: [Subject]?
    
    private var ref = Database.database().reference()
    private var encoder = JSONEncoder()
    private var decoder = JSONDecoder()
    
    func getSubjects() async {
        ref.child("subjects").observeSingleEvent(of: .value) { snapshot in
            var subjects: [Subject] = []
            let value = snapshot.value as? NSDictionary
            
            guard value != nil else { self.subjects = []; return}

            let values = value?.allValues as? [String]
            for i in values! {
                let data = i.data(using: .utf8)!
                let subject = try! self.decoder.decode(Subject.self, from: data)
                subjects.append(subject)
            }
            self.subjects = subjects
        }
    }
    
    func addSubject(subj: Subject) {
        let encoded = try? encoder.encode(subj)
        let stringEncoded = String(data: encoded!, encoding: .utf8)
        ref.child("subjects").child(subj.name).setValue(
            stringEncoded
        )
    }
    
    func deleteSubject(subj: Subject) async {
        try? await ref.child("subjects").child(subj.name).removeValue()
        await getSubjects()
    }
}
