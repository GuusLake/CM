//
//  CardFlip.swift
//  Vocabul-R
//
//  Created by Gijs Lakeman on 13/04/2022.
//

import SwiftUI

struct CardFlip<Front: View, Back: View>: View{
    var front: () -> Front
    var back: () -> Back
    
    @State var flipped: Bool = false
    @State var cardRotation = 0.0
    @State var contentRotation = 0.0
    @State var cardSize = 0.0
    
    
    init(@ViewBuilder front: @escaping () -> Front, @ViewBuilder back: @escaping () -> Back){
        self.front = front
        self.back = back
    }
    
    var body: some View{
        ZStack{
            Group{
                // Card body and background
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color("CardColor"))
                    .frame(width: 250, height: 250)
                    .shadow(radius: 5, x:10, y:10)
                    // Flip card when tapped
                    .onTapGesture {
                        flipCard()
                    }
                // Change view to show
                if flipped{
                    back()
                }else{
                    front()
                }
            }
            .rotation3DEffect(.degrees(contentRotation), axis: (x: 0, y: 1, z:0))
            .frame(maxWidth:250, maxHeight: 250, alignment: .center)
            .font(.title)
            .foregroundColor(Color("TextColor"))
        }
        .padding()
        .rotation3DEffect(.degrees(cardRotation), axis: (x: 0, y: 1, z:0))
    }
    
    func flipCard(){
        // Animate card to flip
        let animitionTime = 0.5
        withAnimation(Animation.linear(duration: animitionTime)){
            cardRotation += 180
        }
        
        // When halfway flip the back side so it does not appear mirrored
        withAnimation(Animation.linear(duration: 0.001).delay(animitionTime / 2)){
            contentRotation += 180
            DispatchQueue.main.asyncAfter(deadline: .now() + (animitionTime / 2), execute: {
                flipped.toggle()
            })
        }
    }
}

struct CardFlip_Previews: PreviewProvider {
    static var previews: some View {
        CardFlip(front: {
            Text("Test1")
        }, back: {
            Text("Test2")
        })
    }
}
