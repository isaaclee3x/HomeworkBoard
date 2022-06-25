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
    var CCM = CacheManager()
    
    @Binding var isSheetPresented: Bool
    
    var body: some View {
        VStack {
            Text("Create a new class")
            
            TextField("Name", text: $name)
            
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
            }

        }
    }
}

struct CreateClassView_Previews: PreviewProvider {
    static var previews: some View {
        CreateClassView(CM: ClassManager(), isSheetPresented: .constant(true))
    }
}
