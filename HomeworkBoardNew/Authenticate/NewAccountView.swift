//
//  NewAccountView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 16/6/22.
//

import SwiftUI

struct NewAccountView: View {
    
    @State var member = Member()
    @State var classes: [Class] = []
    @Binding var isSheetPresented: Bool
    var MM: MemberManager
    var CM: ClassManager
    
    @State var isAdmin = false
    
    var body: some View {
        VStack {
            Text("**Create** a new account")
                .header()
            
            
            TextField("Username", text: $member.name)
                .disableAutocorrection(true)
                .credStyle(width: 300, height: 60)
            
            
            SecureField("Password", text: $member.password)
                .credStyle(width: 300, height: 60)
            
            if let classes = classes {
                Menu {
                    ForEach(classes) { clas in
                        Button {
                            member.clas = clas.name
                        } label: {
                            Text(clas.name)
                        }
                    }
                } label: {
                    Text("Pick your Class")
                        .foregroundColor(Color("murkyBlue"))
                        .bold()
                }
                .padding()
            }
            
            if member.name == "YTSSADMIN" {
                Toggle("Are you an admin?", isOn: $isAdmin)
                    .frame(width: 200)
            }
            
            Text(member.clas)
                .bold() 
            
            Button {
                Task {
                    await MM.saveAccount(member: member, bypass: (isAdmin ? true : false))
                }
                isSheetPresented = false
            } label: {
                Text("Save")
                    .bold()
            }
            .bottomButton()
        }
        .background(color: "lightestBlue")
        .onAppear {
            Task { classes = await CM.getClass() }
        }
    }
}
