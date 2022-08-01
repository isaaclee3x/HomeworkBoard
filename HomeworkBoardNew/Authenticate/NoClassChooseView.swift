//
//  SelectClassView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 11/7/22.
//

import SwiftUI

struct NoClassChooseView: View {
    
    @Binding var username: String
    @Binding var success: Bool
    @Binding var isSheetPresented: Bool
    
    @State var clas = ""
    @State var classes: [Class] = []
    @State var member = Member()
    
    var MM: MemberManager
    var CM: ClassManager
    
    var body: some View {
        VStack {
            Text("**Choose** your class")
                .header()
            
            if let classes = classes {
                Menu {
                    ForEach(classes) { clas in
                        Button {
                            self.clas = clas.name
                        } label: {
                            Text(clas.name)
                        }
                        
                    }
                } label: {
                    Text("Pick a class")
                        .foregroundColor(Color("murkyBlue"))
                        .bold()
                }
            }
            
            Text(clas)
                .bold()
            
            Button {
                Task {
                    member.clas = clas
                    await MM.saveAccount(member: member, bypass: false)
                    isSheetPresented = false
                    success = false
                }
            } label: {
                Text("Confirm")
                    .bold()
            }
            .bottomButton()
        }
        .background(color: "lightestBlue")
        .onAppear {
            Task {
                classes = await CM.getClass()
                member = MM.getAccount(username: username)!
                
            }
        }
    }
}
