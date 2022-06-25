//
//  CreateClassView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 18/6/22.
//

import SwiftUI

struct CreateClassView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var name = ""
    
    @ObservedObject var CM: ClassManager
    var CCM = CacheManager()
    
    @Binding var isSheetPresented: Bool
    
    var body: some View {
        VStack {
            Text("Create a new class")
                .header()
            
            TextField("Name", text: $name)
                .disableAutocorrection(true)
                .credStyle(dimensions: (300,60))
            
            Button {
                Task {
                    CM.createClass(name: name)
                    await CM.getClasses()
                    if let classes = CM.classes {
                        let i = classes.firstIndex(where: { clas in
                            clas.name == name
                        })
                        let index: Int = classes.distance(from: classes.startIndex, to: i!)
                        await CCM.updateCache(clas: classes[index], did: "ADMIN CREATED CLASS \(name)")
                    }
                    isSheetPresented = false
                }
            } label: {
                Text("Create")
                    .bold()
            }
            .bottomButton()
        }
        .background(color: colorScheme == .light ? "lightestBlue" : "murkyBlue")
    }
}

struct CreateClassView_Previews: PreviewProvider {
    static var previews: some View {
        CreateClassView(CM: ClassManager(), isSheetPresented: .constant(true))
    }
}
