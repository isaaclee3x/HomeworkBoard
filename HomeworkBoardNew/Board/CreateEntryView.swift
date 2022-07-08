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
    @State var subject = Subject(name: "", colour: RGB(r: 0, g: 1, b: 0))
    
    @Binding var isSheetPresented: Bool
    @Binding var clas: Class
    
    @ObservedObject var CM: ClassManager
    @ObservedObject var SM: SubjectManager
    
    var CCM = CacheManager()
    
    var body: some View {
        VStack {
            
            Text("Create an entry")
                .header()
            
            Menu {
                if let subjects = SM.subjects {
                    ForEach(subjects) { subject in
                        Button {
                            self.subject = subject
                        } label: {
                            HStack {
                                Circle()
                                    .frame(width: 10)
                                    .foregroundColor(Color.init(red: subject.colour.r, green: subject.colour.g, blue: subject.colour.b))
                                
                                Text(subject.name)
                                    .bold()
                            }
                        }
                    }
                }
            } label: {
                Text("Choose a subject")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(.white)
                
            }
            
            Text(subject.name)
            TextField("Entry", text: $name)
                .credStyle(dimensions: (300,60))
                .foregroundColor(.black)
            
            Button {
                Task {
                    clas.board.entries[self.date]![index] = Entry(entry: name, due: date, subject: subject)
                    
                    CCM.updateCache(clas: clas, did: "\(username) CREATED ENTRY \(name)")
                    await CM.saveClass(clas: clas)
                    
                    isSheetPresented = false
                }
            } label: {
                Text("Submit")
                    .bold()
                    .bottomButton()
            }
        }
        .onAppear {
            Task {
                await SM.getSubjects()
            }
        }
    }
}
