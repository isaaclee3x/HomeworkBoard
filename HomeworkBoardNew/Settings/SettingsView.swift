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
    @StateObject var BM = BoardManager()
    
    @State var names: [String] = []
    @State var createNewSubject = false
    
    var body: some View {
        VStack {
            
            if let $classes = CM.classes {
                Picker("Choose a Class", selection: $names) {
                    ForEach(names, id: \.self) { name in
                        Text(name)
                    }
                }
                .onAppear {
                    names = $classes.map { $0.name }
                }
            }
            
            Form {
                Section("Subjects") {
                    if MM.member?.perm == .admin {
                        if BM.subjects.isEmpty {
                            
                        } else {
                            ForEach(BM.subjects) { subject in
                                
                                Circle()
                                    .frame(width: 10)
                                    .foregroundColor(Color.init(red: subject.colour.r, green: subject.colour.g, blue: subject.colour.b))
                                
                                Text(subject.name)
                                    .bold()
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
        }
        .navigationTitle("Settings")
        .background(color: "lightestBlue")
        .sheet(isPresented: $createNewSubject) {
            CreateSubjectView(BM: BM)
        }
        .onAppear {
            Task(priority: .high) {
                await CM.getClasses()
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(MM: MemberManager())
    }
}
