//
//  CreateEntryView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 25/6/22.
//

import SwiftUI

struct CreateEntryView: View {
    
    var username: String
    var index: Int
    
    let dateFormatter = DateFormatter()
    
    @State var name = ""
    @State var subject = Subject()
    
    @State var beforeTomorrow = false
    @State var didNotChooseSubject = false
    
    @State var date = Date()
    
    @Binding var isSheetPresented: Bool
    @Binding var clas: Class
    @Binding var subjects: [Subject]
    
    var CM: ClassManager
    var SM: SubjectManager
    
    var body: some View {
        VStack {
            Text("**Create** an entry")
                .header()
            
            HStack {
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
            }
            
            Text(subject.name)
                .foregroundColor(.black)
                .bold()
            
            TextField("Entry", text: $name)
                .credStyle(width: 300, height: 60)
                .foregroundColor(.black)
            
            HStack {
                Text("Due: \(dateFormatter.string(from: date))")
                    .frame(width: 60)
                
                DatePicker("Choose a date", selection: $date)
                    .datePickerStyle(.graphical)
            }
            .frame(width: 300, height: 350, alignment: .center)
            
            Button {
                Task {
                    if subject.name == "" {
                        didNotChooseSubject = true
                    } else if date < Date().addingTimeInterval(86400) {
                      beforeTomorrow = true
                    } else {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd MMM yyyy"
                        let strDate = dateFormatter.string(from: date)
                        if clas.board.entries[strDate] != nil {
                            clas.board.entries[strDate]!.append(Entry(entry: name, due: strDate, subject: subject))
                        } else {
                            clas.board.entries[strDate] = [Entry(entry: name, due: strDate, subject: subject)]
                        }
                        clas.board.entries[strDate]![index].author = username
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
        .alert("Due date has already passed", isPresented: $beforeTomorrow) {
            Button("Cancel", role: .cancel) {
                
            }
        }
        .onAppear {
            dateFormatter.dateFormat = "dd MMM yyyy"
        }
    }
}
