//
//  CardView.swift
//  Vocabul-R
//
//  Created by Gijs Lakeman on 13/04/2022.
//

import SwiftUI



struct CardView: View{
    
    var difficulty: Int
    var topic: String
    @State var cards: [Card]
    
    var body: some View{
        ZStack {
            // Background
            LinearGradient(gradient: Gradient(colors: [Color("Background"), Color("CardColor")]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            VStack{
                // Make it scroll
                ScrollView(.horizontal){
                    HStack(spacing: 15){
                        // Dynamically add cards up to 10
                        ForEach($cards){ $card in
                            CardFlip(front: {
                                VStack{
                                    // English side
                                    Spacer()
                                    Text("English:")
                                    Spacer()
                                    Text(card.engWord.firstCapitalized)
                                    Spacer()
                                }
                            }, back: {
                                // Dutch side
                                // Check wheter a card is a learning card or test card
                                if card.test{
                                    VStack{
                                        Spacer()
                                        Text("Dutch?")
                                        Spacer()
                                        // Show checkmark or cross if entered correctly or not
                                        if (card.correct){
                                            Image(systemName: "checkmark").opacity((card.showSymbol ? 1 : 0))
                                        } else{
                                            Image(systemName: "multiply").opacity((card.showSymbol ? 1 : 0))
                                        }
                                        // Input field
                                        Group{
                                            TextField("Give Translation", text: $card.answer)
                                                .onSubmit({
                                                    // Check answer
                                                    if (card.answer.lowercased() == card.nlWord.lowercased()){
                                                        card.correct = true
                                                        card.showSymbol = true
                                                    }else{
                                                        withAnimation(.default){
                                                            // Increase attempts to shake textfield, it has no further function
                                                            card.attempts += 1
                                                            card.showSymbol = true
                                                        }
                                                    }
                                                })
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(Color("RevTextColor"))
                                                .background(Color("RevCardColor"))
                                                .cornerRadius(10)
                                                .font(.title)
                                                // Turn off autocorrection
                                                .disableAutocorrection(true)
                                                // Shake textfield if incorrect
                                                .modifier(Shake(animatableData: CGFloat(card.attempts)))
                                                // Disable textfield if correct answer is given
                                                .disabled(card.correct)
                                        }.padding(.all, 20)
                                        Spacer()
                                    }
                                    
                                }else{
                                    // If a training card show the Dutch translation
                                    VStack{
                                        Spacer()
                                        Text("Dutch:")
                                        Spacer()
                                        Text(card.nlWord.firstCapitalized)
                                        Spacer()
                                    }
                                }
                            }).padding([.top, .bottom], 80)
                        }
                        .padding()
                    }
                    .frame(maxHeight: .infinity)
                }
                // Submit the cards and update the model
                SubmitButton(buttonText: "Submit", cards: $cards)
                Spacer()
            }
        }
    }
}

struct Shake: GeometryEffect{
    // Shakes the view 3 times along the x axis
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)), y: 0))
    }
}

struct SubmitButton: View{
    @Environment(\.presentationMode) var presentationMode
    
    var  buttonText: String
    @Binding var cards: [Card]
    
    var body: some View{
        Button {
            // Update the model
            UpdateModel(cards: cards)
            // Go back to the topic view
            presentationMode.wrappedValue.dismiss()
        } label: {
            Text(buttonText)
                .bold()
                .frame(width: 280, height: 50)
                .background(Color("RevCardColor"))
                .foregroundColor(Color("RevTextColor"))
                .cornerRadius(10)
                .shadow(radius: 5, x:10, y:10)
        }
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CardView(difficulty: 2, topic: "test", cards: GetCards(difficulty: 2, topic: "test"))
                .previewInterfaceOrientation(.portrait)
            
        }
    }
}
