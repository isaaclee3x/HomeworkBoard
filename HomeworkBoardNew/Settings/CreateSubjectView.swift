//
//  CreateSubjectView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 5/7/22.
//

import SwiftUI

struct CreateSubjectView: View {
    
    @State var subject = Subject()
    @Binding var isSheetPresented: Bool
    var SM: SubjectManager
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Name", text: $subject.name)
                } header: {
                    Text("Name")
                }
                
                Section {
                    Rectangle()
                        .frame(width: 300, height: 30)
                        .foregroundColor(Color.init(red: subject.colour.r, green: subject.colour.g, blue: subject.colour.b))
                    
                    Slider(value: $subject.colour.r, in: 0 ... 1, minimumValueLabel: Text(String(0)), maximumValueLabel: Text(String(1))) {
                        Text("\(subject.colour.r)")
                    }
                    
                    Slider(value: $subject.colour.g, in: 0 ... 1, minimumValueLabel: Text(String(0)), maximumValueLabel: Text(String(1))) {
                        Text("\(subject.colour.g)")
                    }
                    
                    Slider(value: $subject.colour.b, in: 0 ... 1, minimumValueLabel: Text(String(0)), maximumValueLabel: Text(String(1))) {
                        Text("\(subject.colour.b)")
                    }
                } header: {
                    Text("Colour")
                }
                
                
                Button {
                    Task {
                        await SM.addSubject(subj: subject)
                        isSheetPresented = false
                    }
                } label: {
                    Text("Save")
                }
                
            }
            .navigationTitle("Subject")
        }
    }
}
