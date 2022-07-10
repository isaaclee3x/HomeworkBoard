//
//  DeleteClassView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 18/6/22.
//

import SwiftUI

struct DeleteClassView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var name = ""
    
    @Binding var isSheetPresented: Bool
    @ObservedObject var CM: ClassManager
    
    var body: some View {
        VStack {
            Text("**Delete** a class")
                .header()
            
            TextField("Class", text: $name)
                .disableAutocorrection(true)
                .credStyle(width: 300, height: 60)
            
            Button {
                CM.deleteClass(name: name)
                isSheetPresented = false
            } label: {
                Text("Delete")
                    .bold()
            }
            .bottomButton()
        }
        .background(color: "lightestBlue")
    }
}
