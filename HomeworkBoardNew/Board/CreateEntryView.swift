//
//  CreateEntryView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 25/6/22.
//

import SwiftUI

struct CreateEntryView: View {
    
    var username: String
    
    var date: String
    var index: Int
    
    @State var name = ""
    
    @Binding var isSheetPresented: Bool
    @Binding var clas: Class
    
    @ObservedObject var CM: ClassManager
    var CCM = CacheManager()
    
    var body: some View {
        VStack {
            Text("Create an entry")
                .header()
            
            TextField("Entry", text: $name)
                .credStyle(dimensions: (300,60))
                .foregroundColor(.black)
            
            Button {
                Task {
                    clas.board.entries[self.date]![index] = Entry(entry: name, due: date)
                    
                    CCM.updateCache(clas: clas, did: "\(username) CREATED ENTRY \(name)")
                    await CM.saveClass(clas: clas)
                    
                    isSheetPresented = false
                }
            } label: {
                Text("Submit")
                    .bold()
            }
            .bottomButton()
        }
        .background(color: "lightestBlue")
    }
}
