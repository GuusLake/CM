//
//  CustomNavLink.swift
//  Vocabul-R
//
//  Created by Gijs Lakeman on 12/04/2022.
//

import SwiftUI
struct CustomNavLink<Label:View, Destination:View> : View{
    
    let destination: Destination
    let label: Label
    
    init(destination: Destination, @ViewBuilder label: () -> Label){
        self.destination = destination
        self.label = label()
    }
    
    // Create a custom navlink which disables the navigation bar
    var body: some View {
        NavigationLink(
            destination:
                CustomNavBarContainer(content: {
                    destination
                    
                })
                .navigationBarHidden(true)
            ,label: {
                label
            })
    }
}

struct CustomNavLink_Previews: PreviewProvider {
    static var previews: some View {
        CustomNavView{
            CustomNavLink(destination: Text("Destination")){
                Text("Click ME")
            }
        }
    }
}
