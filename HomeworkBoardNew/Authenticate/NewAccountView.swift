//
//  NewAccountView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 16/6/22.
//

import SwiftUI

struct NewAccountView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var member = Member()
    @Binding var isSheetPresented: Bool
    @ObservedObject var MM: AccountManager
    
    var body: some View {
        VStack {
            TextField("Username", text: $member.username)
                .disableAutocorrection(true)
                .credStyle(dimensions: (300, 60))
            
            
            SecureField("Password", text: $member.password)
                .credStyle(dimensions: (300, 60))
            
            TextField("Class In", text: $member.clas)
                .disableAutocorrection(true)
                .credStyle(dimensions: (300, 60))
            
            Button {
                Task {
                    await MM.saveAccount(member: member)
                    isSheetPresented = false
                }
            } label: {
                Text("Save")
                    .bold()
            }
            .bottomButton()
        }
        .background(color: colorScheme == .light ? "lightestBlue" : "murkyBlue")
    }
}

struct NewAccountView_Previews: PreviewProvider {
    static var previews: some View {
        NewAccountView(isSheetPresented: .constant(true), MM: AccountManager())
    }
}
