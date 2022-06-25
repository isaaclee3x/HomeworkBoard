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
            Text("Delete a class")
                .credStyle(dimensions: (300,60))
            
            TextField("Class", text: $name)
                .disableAutocorrection(true)
                .credStyle(dimensions: (300,60))
            
            Button {
                CM.deleteClass(name: name)
                isSheetPresented = false
            } label: {
                Text("Delete")
                    .bold()
            }
            .bottomButton()
        }
        .background(color: colorScheme == .light ? "lightestBlue" : "murkyBlue")
    }
}

struct DeleteClassView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteClassView(isSheetPresented: .constant(true) ,CM: ClassManager())
    }
}
