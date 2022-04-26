//
//  SwiftUIView.swift
//  Vocabul-R
//
//  Created by Gijs Lakeman on 03/04/2022.
//

import SwiftUI

struct CustomNavBarContainer<Content: View>: View {
    
    @State private var showBackButton: Bool = true
    @State private var title: String = ""
    @State private var subtitle: String? = nil
    @State private var showInfoButton: Bool = false
    
    let content: Content
    
    init(@ViewBuilder content:  () -> Content){
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0){
            CustomNavBar(showBackButton: showBackButton, title: title, subtitle: subtitle, showInfoButton:  showInfoButton)
            content
            // Stretch content to fit view
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        // Update title when reference key is changed
        .onPreferenceChange(CustomNavBarTitlePreferenceKey.self, perform: {
            value in
            self.title = value
        })
        // Update subtitle if reference key is changed
        .onPreferenceChange(CustomNavBarSubitlePreferenceKey.self, perform: {
            value in
            self.subtitle = value
        })
        // Update backbutton boolean if changed
        .onPreferenceChange(CustomNavBarBackButtonHiddenPreferenceKey.self, perform: {
            value in
            self.showBackButton = !value
        })
        // Update infobutton boolean if changed
        .onPreferenceChange(CustomNavBarInfoButtonHiddenPreferenceKey.self, perform: {
            value in
            self.showInfoButton = value
        })
    }
}

struct CustomNavBarContainer_Previews: PreviewProvider {
    static var previews: some View {
        CustomNavBarContainer {
            Color.red.ignoresSafeArea()
        }
    }
}
