//
//  SettingsView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 5/7/22.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject var MM = MemberManager()
    @StateObject var CM = ClassManager()
    @StateObject var SM = SubjectManager()
    
    @State var names: [String] = []
    @State var createNewSubject = false
    
    var body: some View {
        VStack {
            if let $classes = CM.classes {
                HStack {
                    Text("Choose a Class:")
                        .bold()
                    
                    Picker("Choose a Class", selection: $names) {
                        ForEach(names, id: \.self) { name in
                            Text(name)
                        }
                    }
                    .onAppear {
                        names = $classes.map { $0.name }
                    }
                }
            }
            
            Form {
                Section("Subjects") {
                    if MM.member?.perm == .admin {
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
                                let index = offsets[offsets.startIndex]
                                SM.deleteSubject(subj: subjects[index])
                                
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


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(MM: MemberManager())
    }
}
