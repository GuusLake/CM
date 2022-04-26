//
//  CustomNavBar.swift
//  Vocabul-R
//
//  Created by Gijs Lakeman on 03/04/2022.
//

import SwiftUI

struct CustomNavBar: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    let showBackButton: Bool
    let title: String
    let subtitle: String?
    let showInfoButton: Bool
    
    var body: some View {
        HStack{
            // Show the back button if needed
            if showBackButton{
                backButton
                    // Hide it when it is needed for spacing
                    .opacity(showInfoButton ? 0: 1)
            }
            Spacer()
            // Add titlesection
            titleSection
            Spacer()
            // Add hidden backbutton for spacing or infobutton
            if showBackButton{
                if showInfoButton{
                    infoButton
                }else{
                    backButton
                    .opacity(0)
                }
                
            }
        }
        .accentColor(Color("TextColor"))
        .foregroundColor(Color("TextColor"))
        .font(.headline)
        .ignoresSafeArea(edges: .top)
        .padding()
        .background(.ultraThinMaterial)
        
    }
}

struct CustomNavBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            CustomNavBar(showBackButton: true, title: "Title", subtitle: "subtitle", showInfoButton: false)
            Spacer()
        }
    }
}

extension CustomNavBar{
    
    private var backButton: some View{
        Button(action: {
            // Use apples backtracking for high performance
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Image(systemName: "chevron.left")
            
        })
    }
    
    private var titleSection: some View{
        // Title part with option for subtutle
        VStack{
            Text(title)
                .font(.title)
                .fontWeight(.semibold)
            if let subTitleText = subtitle{
                Text(subTitleText)
            }
        }
    }
    
    private var infoButton: some View{
        // Navigation to the infopage
        CustomNavLink(destination:
                        InfoView().navigationBarTitle(Text("Information")),
                      label: {
            Image(systemName: "info.circle")
        })
    }
    
}
