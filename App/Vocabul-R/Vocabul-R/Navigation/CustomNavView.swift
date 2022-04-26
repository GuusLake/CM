//
//  NavigationBarView.swift
//  Vocabul-R
//
//  Created by Gijs Lakeman on 12/04/2022.
//

import SwiftUI

struct CustomNavView<Content:View>: View {
    
    let content: Content
    
    init(@ViewBuilder content: () -> Content){
        self.content = content()
    }
    
    var body: some View {
        // Keep apples own navigationbar to use for its functionality 
        NavigationView{
            CustomNavBarContainer{
                content
            }
            // Hide navigation bar so we can create a custom version
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct CustomNavView_Previews: PreviewProvider {
    static var previews: some View {
        CustomNavView{
            Color.red.ignoresSafeArea()
        }
    }
}
