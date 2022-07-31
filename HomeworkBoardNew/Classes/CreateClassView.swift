//
//  CreateClassView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 18/6/22.
//

import SwiftUI

struct CreateClassView: View {
    
    @State var name = ""
    var CM: ClassManager
    
    @Binding var isSheetPresented: Bool
    
    var body: some View {
        VStack {
            Text("**Create** a new class")
                .header()
            
            TextField("Name", text: $name)
                .disableAutocorrection(true)
                .credStyle(width: 300, height: 60)
            
            Button {
                Task {
                    await CM.createClass(name: name)
                    isSheetPresented = false
                }
            } label: {
                Text("Create")
                    .bold()
            }
            .bottomButton()
        }
        .background(color: "lightestBlue")
    }
}

