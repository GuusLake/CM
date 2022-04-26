//
//  CustomNavBarPreferenceKeys.swift
//  Vocabul-R
//
//  Created by Gijs Lakeman on 12/04/2022.
//

import Foundation
import SwiftUI

struct CustomNavBarTitlePreferenceKey: PreferenceKey{
    // Reference key for Title
    static var defaultValue: String = ""
    
    static func reduce(value: inout String, nextValue: () -> String) {
        value = nextValue()
    }
}

struct CustomNavBarSubitlePreferenceKey: PreferenceKey{
    // Reference key for subtitle
    static var defaultValue: String? = nil
    
    static func reduce(value: inout String?, nextValue: () -> String?) {
        value = nextValue()
    }
}

struct CustomNavBarBackButtonHiddenPreferenceKey: PreferenceKey{
    // Reference key for backbutton
    static var defaultValue: Bool = false
    
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}

struct CustomNavBarInfoButtonHiddenPreferenceKey: PreferenceKey{
    // Reference key for infobutton
    static var defaultValue: Bool = false
    
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}

extension View{
    
    func customNAvigationTitle(_ title: String) -> some View{
        preference(key: CustomNavBarTitlePreferenceKey.self, value: title)
    }
    
    func customNAvigationSubtitle(_ title: String?) -> some View{
        preference(key: CustomNavBarSubitlePreferenceKey.self, value: title)
    }
    
    func customNavigationBarBackButtonHidden(_ hidden: Bool) -> some View{
        preference(key: CustomNavBarBackButtonHiddenPreferenceKey.self, value: hidden)
    }
    
    func customNavigationBarInfoButtonHidden(_ hidden: Bool) -> some View{
        preference(key: CustomNavBarInfoButtonHiddenPreferenceKey.self, value: hidden)
    }
    
    func CustomNavBarItems(title: String = "Vocabul-R", subtitle: String? = nil, backButtonHidden: Bool = false, infoButtonHidden: Bool = true) -> some View{
        self
            .customNAvigationTitle(title)
            .customNAvigationSubtitle(subtitle)
            .customNavigationBarBackButtonHidden(backButtonHidden)
            .customNavigationBarInfoButtonHidden(infoButtonHidden)
    }
}
