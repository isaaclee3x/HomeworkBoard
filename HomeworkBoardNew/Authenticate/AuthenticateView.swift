//
//  AuthenticateView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 16/6/22.
//

import SwiftUI

struct AuthenticateView: View {
    
    @State var username = ""
    @State var password = ""
    
    @Binding var success: Bool
    @ObservedObject var MM: MemberManager
    
    @State var createNewAccount = false
    
    var body: some View {
        VStack {
            Text("**Login** to your account")
                .header()
            
            TextField("Username", text: $username)
                .disableAutocorrection(true)
                .credStyle(width: 300, height: 60)
            
            SecureField("Password", text: $password)
                .credStyle(width: 300, height: 60)
            
            Button {
                Task {
                    await MM.auth(username: username, password: password) {
                        success = true
                    }
                }
            } label: {
                Text("Login")
                    .bold()
            }
            .bottomButton()
            .padding()
            
            HStack {
                Text("Create Account")
                    .bold()
                    .font(.system(size: 15))
                    .foregroundColor(Color("murkyBlue"))
                    .onTapGesture {
                        createNewAccount = true
                    }
            }
        }
        .background(color: "lightestBlue")
        .sheet(isPresented: $createNewAccount) {
            NewAccountView(isSheetPresented: $createNewAccount, MM: MM)
        }
        .onAppear {
            MM.member = nil
        }
    }
}
