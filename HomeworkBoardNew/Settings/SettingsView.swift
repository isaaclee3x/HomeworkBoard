//
//  SettingsView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 5/7/22.
//

import SwiftUI
import Firebase

struct SettingsView: View {
    
    @Binding var classes: [Class]
    @Binding var subjects: [Subject]
    
    var MM = MemberManager()
    var CM: ClassManager
    var SM: SubjectManager
    
    let BM = BoardManager()
    var member: Member
    
    @State var clas = ""
    @State var sendableClas = Class(name: "", date: "")
    @State var entries: [Entry] = []
    @State var members: [Member] = []
    @State var classNames: [String] = []
    @State var createNewSubject = false
    @State var massCreateUsers = false
    
    var body: some View {
        NavigationView {
            VStack {
                if member.perm == .admin || member.perm == .teacher {
                    if clas != "" {
                        let index = (classes.firstIndex() { clas in
                            return clas.name == self.clas
                        })
                        if let $clas = Binding<Class>(
                            get: { classes[index!] },
                            set: { newValue in
                                classes[index!] = newValue}) {
                            
                            SummaryView(clas: $clas, subjects: $subjects, CM: CM, SM: SM, BM: BM, member: member)
                        }
                    }
                    
                    Form {
                        if let classes = classes {
                            SelectClassView(clas: $clas, members: $members, entries: $entries, classes: classes, member: member, MM: MM, CM: CM)
                        }
                        
                        Section("Members") {
                            MembersView(members: $members, clas: clas, MM: MM)
                        }
                        
                        Section("Subjects") {
                            SubjectsView(subjects: $subjects, SM: SM, createNewSubject: $createNewSubject)
                        }
                        
                        Section("Batch") {
                            Button {
                                massCreateUsers = true
                            } label: {
                                Text("Mass Create Account")
                            }
                            
                        }
                        .onAppear {
                            for i in classes {
                                classNames.append(i.name)
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
    var member: Member
    
    var MM: MemberManager
    var CM: ClassManager
    let BM = BoardManager()
    
    fileprivate func findMembersOf(clas: String) async {
        let members = await MM.getMembers(of: clas)
        self.members = []
        for i in members {
            guard let member = await MM.getAccount(username: i) else {
                let ref = DatabaseReference()
                
                try! await ref.child(clas).child(i).setValue(nil)
                return
                
            }
            self.members.append(member)
        }
    }
    
    var body: some View {
        HStack {
            Text("Choose a Class")
                .bold()
            
            if member.perm == .admin {
                Menu {
                    ForEach(classes) { clas in
                        Button(clas.name) {
                            Task {
                                self.clas = clas.name
                                if self.clas != "" {
                                    await findMembersOf(clas: self.clas)
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
            } else if member.perm == .teacher {
                Text(member.clas)
                    .onAppear {
                        Task {
                            await findMembersOf(clas: member.clas)
                        }
                    }
            }
        }
    }
}

struct MembersView: View {
    
    @Binding var members: [Member]
    
    var clas: String
    
    var MM: MemberManager
    
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
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button {
                        Task {
                            await MM.deleteMember(username: member.name)
                            let members = await MM.getMembers(of: clas)
                            for i in members {
                                guard let member = await MM.getAccount(username: i) else {
                                    let ref = DatabaseReference()
                                    
                                    try! await ref.child(clas).child(i).setValue(nil)
                                    return
                                    
                                }
                                self.members = []
                                self.members.append(member)
                            }
                        }
                    } label: {
                        Text("Delete")
                    }
                    .tint(.red)
                    
                }
            }
        } else {
            Text("No Members Inside")
        }
    }
}

struct SubjectsView: View {
    
    @Binding var subjects: [Subject]
    var SM: SubjectManager
    @Binding var createNewSubject: Bool
    
    var body: some View {
        if subjects == [] {
            ForEach(subjects) { subject in
//                HStack {
//                    Circle()
//                        .frame(width: 10)
//                        .foregroundColor(Color.init(red: subject.colour.r, green: subject.colour.g, blue: subject.colour.b))
//
//                    Text(subject.name)
//                        .bold()
//                }
//                .onDelete { offsets in
//                    Task {
//                        let index = offsets[offsets.startIndex]
//                        await SM.deleteSubject(subj: subjects[index])
//
//                    }
//                }
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
