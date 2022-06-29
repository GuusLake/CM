//
//  InfoView.swift
//  Vocabul-R
//
//  Created by Gijs Lakeman on 14/04/2022.
//

import SwiftUI

struct InfoView: View {
    
    @State var correct: Bool = false
    @State var attempts: Int = 0
    @State private var answer: String = ""
    @State var showSymbol: Bool = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(gradient: Gradient(colors: [Color("Background"), Color("CardColor")]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            ScrollView(.vertical){
                VStack(alignment: .leading, spacing: 10){
                    // Bunch of text
                    Group{
                        Text("What is Vacabul-R?")
                            .font(.title)
                            .bold()
                        Text("Vocabul-R is an English-Dutch vocabulary learning app. You learn Dutch words, while an ACT-R model helps you learn and determines when to show a certain word, move to a new difficulty level and when to test you using a question field.")
                    }
                    
                    Group{
                        Text("What is ACT-R?")
                            .font(.title)
                            .bold()
                        Text("ACT-R is a cognitive architecture: a theory for simulating and understanding human cognition. ACT-R aims to define the basic and irreducible cognitive and perceptual operations that enable the human mind. In theory, each task that humans can perform should consist of a series of these discrete operations.")
                    }
                    
                    Group{
                        Text("How are difficulty levels determined?")
                            .font(.title)
                            .bold()
                        Text("The difficulty is determined by two factors: word frequency and word length. Each topic is has its words divided into 5 groups ranging from difficulty level 1 to 5. These difficulties are then combined to create a scoring system for each word from 2 to 10. Additionally on the first time the app is opended a starting difficulty is determined by a small questionnaire.")
                    }
                    
                    Group{
                        Text("How do I use this app?")
                            .font(.title)
                            .bold()
                        Text("You can learn in two ways: general and topic specific. Upon selecting one of these options, you are presented with groups of 10 cards similiar to the card shown below. This first one shows an English word on the front and a Dutch Translation on the back. You can tap the card to flip it.")
                    }
                    
                    // Example learning card
                    Group{
                        HStack{
                            Spacer()
                            CardFlip(front: {
                                VStack{
                                    Spacer()
                                    Text("English:")
                                    Spacer()
                                    Text("Cat")
                                    Spacer()
                                }
                                
                            }, back: {
                                VStack{
                                    Spacer()
                                    Text("Dutch:")
                                    Spacer()
                                    Text("Kat")
                                    Spacer()
                                }
                            }).padding([.top, .bottom], 80)
                            Spacer()
                        }
                        
                        Text("A second type of card exists as shown below. This type shows the English word at the frond a text field at the back. If you enter the correct word and press enter, you will see a checkmark, if not then you will be shown a cross.")
                        
                        // Example testing Card
                        
                        HStack{
                            Spacer()
                            CardFlip(front: {
                                VStack{
                                    Spacer()
                                    Text("English:")
                                    Spacer()
                                    Text("Cat")
                                    Spacer()
                                }
                            }, back: {
                                VStack{
                                    Spacer()
                                    Text("Dutch?")
                                    Spacer()
                                    if (correct){
                                        Image(systemName: "checkmark").opacity((showSymbol ? 1 : 0))
                                    } else{
                                        Image(systemName: "multiply").opacity((showSymbol ? 1 : 0))
                                    }
                                    Group{
                                        TextField("Give Translation", text: $answer)
                                            .onSubmit({
                                                if (answer.lowercased() == "kat"){
                                                    correct = true
                                                    showSymbol = true
                                                }else{
                                                    withAnimation(.default){
                                                        attempts += 1
                                                        showSymbol = true
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
                                            .modifier(Shake(animatableData: CGFloat(attempts)))
                                            // Disable textfield if correct answer is given
                                            .disabled(correct)
                                    }.padding(.all, 20)
                                    Spacer()
                                }
                            }).padding([.top, .bottom], 80)
                            Spacer()
                        }
                    }
                }.foregroundColor(Color("TextColor"))
                    .padding()
            }
        }
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
        
    }
}
