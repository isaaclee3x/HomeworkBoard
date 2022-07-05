//
//  CreateSubjectView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 5/7/22.
//

import SwiftUI

struct CreateSubjectView: View {
    
    @State var subject = Subject(name: "", colour: RGB(r: 0, g: 0, b: 0))
    
    @ObservedObject var BM: BoardManager
    
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
                        .frame(width: 350, height: 30)
                        .foregroundColor(Color.init(red: subject.colour.r, green: subject.colour.g, blue: subject.colour.b))
                    
                    Slider(value: $subject.colour.r, in: 0 ... 1) {
                        Text("\(subject.colour.r)")
                    }
                    
                    Slider(value: $subject.colour.g, in: 0 ... 1) {
                        Text("\(subject.colour.g)")
                    }
                    
                    Slider(value: $subject.colour.b, in: 0 ... 1) {
                        Text("\(subject.colour.b)")
                    }
                } header: {
                    Text("Colour")
                }
                
                Button {
                    BM.subjects.append(subject)
                } label: {
                    Text("Save")
                }
                
            }
            .navigationTitle("Subject")
            .background(color: "lightestBlue")
        }
    }
}

struct CreateSubjectView_Previews: PreviewProvider {
    static var previews: some View {
        CreateSubjectView(BM: BoardManager())
    }
}
