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
    @ObservedObject var CLM = ClientManager()
    
    /// Gets subjects from ./subject dir
    func getSubjects() async {
        if let data = await CLM.pullData(pull: Subject.self) {
            let string = String(data: data, encoding: .utf8)
            
            let strings = string!.components(separatedBy: " n ")
            let datas = strings.map() { $0.data(using: .utf8) }
            var subjects: [Subject] = []
            for i in datas { subjects.append(try! decoder.decode(Subject.self, from: i!))}
            self.subjects = subjects
        }
    }
    
    /// Appends a new subject to the ./subject path
    /// - Parameter subj: Subject to add
    func addSubject(subj: Subject) {
        let encoded = try? encoder.encode(subj)
        let stringEncoded = String(data: encoded!, encoding: .utf8)
        ref.child("subjects").child(subj.name).setValue(
            stringEncoded
        )
    }
    
    /// Deletes the subject
    /// - Parameter subj: Subject to remove
    func deleteSubject(subj: Subject) async {
        try? await ref.child("subjects").child(subj.name).removeValue()
        await getSubjects()
    }
}
