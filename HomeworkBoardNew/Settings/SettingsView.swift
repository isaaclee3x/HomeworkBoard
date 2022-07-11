//
//  SettingsView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 5/7/22.
//

import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var MM = MemberManager()
    @ObservedObject var CM: ClassManager
    @ObservedObject var SM: SubjectManager
    
    let BM = BoardManager()
    var member: Member
    
    @State var clas = ""
    @State var sendableClas = Class(name: "", date: "")
    @State var entries: [Entry] = []
    @State var students: [Member] = []
    @State var createNewSubject = false
    
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
                            
                            SelectClassView(clas: $clas, students: $students, entries: $entries, classes: classes, MM: MM, CM: CM)
                        }
                        
                        Section("Students") {
                            StudentsView(students: $students)
                        }
                        
                        Section("Subjects") {
                            SubjectsView(SM: SM, createNewSubject: $createNewSubject)
                        }
                        .navigationTitle("Settings")
                        .sheet(isPresented: $createNewSubject) {
                            CreateSubjectView(isSheetPresented: $createNewSubject, SM: SM)
                        }
                        .onChange(of: clas) { newValue in
                            Task(priority: .high) {
                                await CM.getClasses()
                                await SM.getSubjects()
                            }
                        }
                    }
                }
            }
        }
    }
}

struct SelectClassView: View {
    
    @Binding var clas: String
    @Binding var students: [Member]
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
                                let students = await MM.getMembers(of: self.clas)
                                self.students = []
                                for i in students {
                                    self.students.append(await MM.adminBasedGetAccount(username: i))
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

struct StudentsView: View {
    
    @Binding var students: [Member]
    
    var body: some View {
        if students != [] {
            ForEach(students) { student in
                HStack {
                    Text(student.username)
                        .bold()
                    
                    VStack {
                        Text(student.clas)
                        
                        Text(student.perm.rawValue)
                    }
                    .opacity(0.5)
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                }
            }
        } else {
            Text("No Students Inside")
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
