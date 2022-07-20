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
        self.subjects = await CLM.pullData(pull: Subject())
    }
    
    /// Appends a new subject to the ./subject path
    /// - Parameter subj: Subject to add
    func addSubject(subj: Subject) async {
        await CLM.saveData(type: "subjects", item: subj)
    }
    
    /// Deletes the subject
    /// - Parameter subj: Subject to remove
    func deleteSubject(subj: Subject) async {
        try! await ref.child("subjects").child(subj.name).removeValue()
        await getSubjects()
    }
}
