//
//  CreateEntryView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 25/6/22.
//

import SwiftUI

struct CreateEntryView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var username: String
    
    var date: String
    var index: Int
    
    @State var dueDate = Date()
    @State var name = ""
    
    @Binding var isSheetPresented: Bool
    @Binding var clas: Class
    
    var dateFormatter = DateFormatter()
    
    @ObservedObject var CM: ClassManager
    var CCM = CacheManager()
    
    var body: some View {
        VStack {
            Text("Create an entry")
                .header()
            
            TextField("Entry", text: $name)
                .credStyle(dimensions: (300,60))
            
            DatePicker("Due", selection: $dueDate)
                .datePickerStyle(.compact)
                .frame(width: 300, height: 50)
            
            Button {
                Task {
                    dateFormatter.dateFormat = "dd MMMM yyyy"
                    dateFormatter.locale = .current
                    let date = dateFormatter.string(from: dueDate)
                    clas.board.entries[self.date]![index] = Entry(entry: name, due: date)
                    await CM.saveClass(clas: clas)
                    await CCM.updateCache(clas: clas, did: "\(username) CREATED ENTRY \(name)")
                    isSheetPresented = false
                }
            } label: {
                Text("Submit")
                    .bold()
            }
            .bottomButton()
        }
        .background(color: colorScheme == .light ? "lightestBlue" : "murkyBlue")
    }
}
