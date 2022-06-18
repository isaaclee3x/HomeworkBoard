//
//  DeleteClassView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 18/6/22.
//

import SwiftUI

struct DeleteClassView: View {
    
    @State var name = ""
    @ObservedObject var CM: ClassManager
    
    var body: some View {
        VStack {
            Text("Delete a class")
            
            TextField("Class", text: $name)
            
            Button {
                CM.deleteClass(name: name)
            } label: {
                Text("Delete")
            }
        }
    }
}

struct DeleteClassView_Previews: PreviewProvider {
    static var previews: some View {
        DeleteClassView(CM: ClassManager())
    }
}
