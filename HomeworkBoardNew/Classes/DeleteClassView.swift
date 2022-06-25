//
//  DeleteClassView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 18/6/22.
//

import SwiftUI

struct DeleteClassView: View {
    
    @State var name = ""
    
    @Binding var isSheetPresented: Bool
    @ObservedObject var CM: ClassManager
    
    var body: some View {
        VStack {
            Text("Delete a class")
            
            TextField("Class", text: $name)
            
            Button {
                CM.deleteClass(name: name)
                isSheetPresented = false
            } label: {
                Text("Delete")
            }
        }
    }
}

struct DeleteClassView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteClassView(isSheetPresented: .constant(true) ,CM: ClassManager())
    }
}
