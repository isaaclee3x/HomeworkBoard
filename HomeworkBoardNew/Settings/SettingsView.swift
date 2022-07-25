//
//  SettingsView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 5/7/22.
//

import SwiftUI
import Firebase

struct SettingsView: View {
    
    @ObservedObject var MM = MemberManager()
    @ObservedObject var CM: ClassManager
    @ObservedObject var SM: SubjectManager
    
    let BM = BoardManager()
    var member: Member
    
    @State var clas = ""
    @State var sendableClas = Class(name: "", date: "")
    @State var entries: [Entry] = []
    @State var members: [Member] = []
    @State var classes: [String] = []
    @State var createNewSubject = false
    @State var massCreateUsers = false
    
    var body: some View {
        NavigationView {
            VStack {
                if MM.member?.perm == .admin || MM.member?.perm == .teacher {
                    if clas != "" {
                        let index = (CM.classes?.firstIndex() { clas in
                            return clas.name == self.clas
                        })!
                        if let $clas = Binding<Class>(
                            get: { CM.classes![index] },
                            set: { newValue in CM.classes![index] = newValue}) {
                            
                            SummaryView(clas: $clas, CM: CM, SM: SM, BM: BM, member: member)
                        }
                    }
                    
                    Form {
                        if let classes = CM.classes {
                            SelectClassView(clas: $clas, members: $members, entries: $entries, classes: classes, MM: MM, CM: CM)
                        }
                        
                        Section("Members") {
                            MembersView(members: $members)
                        }
                        
                        Section("Subjects") {
                            SubjectsView(SM: SM, createNewSubject: $createNewSubject)
                        }
                        
                        Section("Batch") {
                            Button {
                                massCreateUsers = true
                            } label: {
                                Text("Mass Create Account")
                            }

                        }
                        .onAppear {
                            Task(priority: .high) {
                                await CM.getClasses()
                                await SM.getSubjects()
                                classes = CM.classes?.map() { $0.name } ?? []
                            }
                        }
                        .navigationTitle("Settings")
                        .sheet(isPresented: $createNewSubject) {
                            CreateSubjectView(isSheetPresented: $createNewSubject, SM: SM)
                        }
                        .sheet(isPresented: $massCreateUsers) {
                            MassCreateUsersView(isSheetPresented: $massCreateUsers, MM: MM, classes: classes)
                        }
                    }
                }
            }
        }
    }
}

struct SelectClassView: View {
    
    @Binding var clas: String
    @Binding var members: [Member]
    @Binding var entries: [Entry]
    
    var classes: [Class]
    
    @ObservedObject var MM: MemberManager
    @ObservedObject var CM: ClassManager
    let BM = BoardManager()
    
    var body: some View {
        HStack {
            Text("Choose a Class")
                .bold()
            
            Menu {
                ForEach(classes) { clas in
                    Button(clas.name) {
                        Task {
                            self.clas = clas.name
                            if self.clas != "" {
                                let members = await MM.getMembers(of: self.clas)
                                self.members = []
                                for i in members {
                                    guard let member = await MM.findAccount(username: i) else {
                                        let ref = DatabaseReference()
                                        
                                        try! await ref.child(clas.name).child(i).setValue(nil)
                                        return
                                        
                                    }
                                    self.members.append(member)
                                }
                            }
                        }
                    }
                }
            } label: {
                if clas.isEmpty {
                    Text("Here")
                        .foregroundColor(.blue)
                } else {
                    Text(clas)
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

struct MembersView: View {
    
    @Binding var members: [Member]
    
    var body: some View {
        if members != [] {
            ForEach(members) { member in
                HStack {
                    Text(member.name)
                        .bold()
                    
                    VStack {
                        Text(member.clas)
                        
                        Text(member.perm.rawValue)
                    }
                    .opacity(0.5)
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                }
            }
        } else {
            Text("No Members Inside")
        }
    }
}

struct SubjectsView: View {
    
    @ObservedObject var SM: SubjectManager
    @Binding var createNewSubject: Bool
    
    var body: some View {
        if let subjects = SM.subjects {
            ForEach(subjects) { subject in
                HStack {
                    Circle()
                        .frame(width: 10)
                        .foregroundColor(Color.init(red: subject.colour.r, green: subject.colour.g, blue: subject.colour.b))
                    
                    Text(subject.name)
                        .bold()
                }
            }
            .onDelete { offsets in
                Task {
                    let index = offsets[offsets.startIndex]
                    await SM.deleteSubject(subj: subjects[index])
                    
                }
            }
        } else {
            Text("Go create a new subject")
                .foregroundColor(.gray)
                .opacity(0.5)
        }
        Button {
            createNewSubject = true
        } label: {
            Text("Create New Subject")
        }
    }
}
