//
//  CreateEntryView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 19/6/22.
//

import SwiftUI

struct CreateEntryView: View {
    
    var date: String
    var index: Int
    
    @State var dueDate = Date()
    @State var name = ""
    
    @Binding var isSheetPresented: Bool
    @Binding var clas: Class
    
    @ObservedObject var CM: ClassManager
    
    var body: some View {
        VStack {
            Text("Create an entry")
            
            TextField("Entry", text: $name)
            
            DatePicker("Due", selection: $dueDate)
            
            Button {
                clas.board.entries[date]![index] = Entry(entry: name, due: dueDate)
                CM.saveClass(clas: clas)
                
            } label: {
                Text("Submit")
            }
        }
    }
}
