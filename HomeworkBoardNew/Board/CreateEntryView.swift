//
//  CreateEntryView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 25/6/22.
//

import SwiftUI

struct CreateEntryView: View {
    
    var username: String
    
    var date: String
    var index: Int
    
    @State var name = ""
    @State var subject = Subject()
    @State var didNotChooseSubject = false
    
    @Binding var isSheetPresented: Bool
    @Binding var clas: Class
    @Binding var subjects: [Subject]
    
    var CM: ClassManager
    var SM: SubjectManager
    
    var body: some View {
        VStack {
            
            Text("**Create** an entry")
                .header()
            
            Menu {
                if let subjects = subjects {
                    ForEach(subjects) { subject in
                        Button {
                            self.subject = subject
                        } label: {
                            Text(subject.name)
                                .bold()
                                .foregroundColor(.black)
                        }
                    }
                }
            } label: {
                Text("Choose a subject")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(Color("murkyBlue"))
                    .bold()
                
            }
            
            Text(subject.name)
                .foregroundColor(.black)
                .bold()
    
            TextField("Entry", text: $name)
                .credStyle(width: 300, height: 60)
                .foregroundColor(.black)
            
            Button {
                Task {
                    if subject.name == "" {
                        didNotChooseSubject = true
                    } else {
                        clas.board.entries[self.date]![index] = Entry(entry: name, due: date, subject: subject)
                        clas.board.entries[self.date]![index].author = username
                        await CM.saveClass(clas: clas)
                        
                        isSheetPresented = false                        
                    }
                }
            } label: {
                Text("Submit")
                    .bold()
                    .bottomButton()
            }
        }
        .background(color: "lightestBlue")
        .alert("Please choose a subject", isPresented: $didNotChooseSubject) {
            Button("Cancel", role: .cancel) {
                
            }
        }
    }
}
