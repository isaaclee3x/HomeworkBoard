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
    
    @State var name = ""
    @State var createNewSubject = false
    
    var body: some View {
        NavigationView {
            VStack {
                if MM.member?.perm == .admin {
                    if let classes = CM.classes {
                        HStack {
                            Text("Choose a Class:")
                                .bold()
                            
                            Picker("Choose a Class", selection: $name) {
                                ForEach(classes) { clas in
                                    Text(clas.name)
                                }
                            }
                        }
                    }
                    
                    Form {
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
