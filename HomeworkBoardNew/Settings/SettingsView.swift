//
//  SettingsView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 5/7/22.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject var MM: MemberManager
    
    @State var createNewSubject = false
    
    
    var body: some View {
        Form {
            Section("Subjects") {
                if MM.member?.perm == .admin {
                    if BoardManager.subjects.isEmpty {
                        
                    } else {
                        ForEach(BoardManager.subjects) { subject in
                            
                            Circle()
                                .frame(width: 10)
                                .foregroundColor(Color.init(red: subject.colour.r, green: subject.colour.g, blue: subject.colour.b))
                            
                            Text(subject.name)
                                .bold()
                        }
                    }
                    Button {
                        
                    } label: {
                        Text("Create New Subject")
                    }
                }
            }
        }
        .sheet(isPresented: $createNewSubject) {
            
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(MM: MemberManager())
    }
}
