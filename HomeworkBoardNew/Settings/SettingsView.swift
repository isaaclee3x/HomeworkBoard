//
//  SettingsView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 5/7/22.
//

import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var MM: MemberManager
    @ObservedObject var CM: ClassManager
    @ObservedObject var SM: SubjectManager
    
    @State var clas = ""
    @State var students: [Member] = []
    @State var createNewSubject = false
    
    var body: some View {
        NavigationView {
            VStack {
                if MM.member?.perm == .admin {
                    if let classes = CM.classes {
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
                    
                    Form {
                        Section("Students") {
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
                            }
                        }
                        
                        Section("Subjects") {
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
                        }
                        
                        Button {
                            createNewSubject = true
                        } label: {
                            Text("Create New Subject")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $createNewSubject) {
                CreateSubjectView(isSheetPresented: $createNewSubject, SM: SM)
            }
            .onAppear {
                Task(priority: .high) {
                    await CM.getClasses()
                    await SM.getSubjects()
                }
            }
        }
    }
}
