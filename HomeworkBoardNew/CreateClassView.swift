//
//  CreateClassView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 18/6/22.
//

import SwiftUI

struct CreateClassView: View {
    
    @State var name = ""
    
    @ObservedObject var CM: ClassManager
    
    @Binding var isSheetPresented: Bool
    
    var body: some View {
        VStack {
            Text("Create a new class")
            
            TextField("Name", text: $name)
            
            Button {
                Task {
                    CM.saveClass(name: name)
                    await CM.getClasses()
                    isSheetPresented = false
                }
            } label: {
                Text("Create")
            }

        }
    }
}

struct CreateClassView_Previews: PreviewProvider {
    static var previews: some View {
        CreateClassView(CM: ClassManager(), isSheetPresented: .constant(true))
    }
}
