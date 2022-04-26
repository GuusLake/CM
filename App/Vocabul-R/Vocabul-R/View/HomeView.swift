//
//  ContentView.swift
//  Vocabul-R
//
//  Created by Gijs Lakeman on 01/04/2022.
//

import SwiftUI

struct HomeView: View {
    @State var initState: Bool = GetInitState()
    
    var body: some View {
        CustomNavView{
            Group{
                ZStack {
                    // Background
                    LinearGradient(gradient: Gradient(colors: [Color("Background"), Color("CardColor")]), startPoint: .top, endPoint: .bottom)
                        .edgesIgnoringSafeArea(.all)
                    
                    // Change view if init view is needed
                    if initState{
                        InitViewContent(initState: $initState)
                            .zIndex(1)
                    }else{
                        HomeViewContent()
                            .zIndex(1)
                    }
                }
                .animation(.easeInOut, value: initState)
                .transition(.opacity)
            }
            // Disable back button but show info button
            .CustomNavBarItems(title: "Vocabul-R", subtitle: "Your favourite learning app!", backButtonHidden: false, infoButtonHidden: true)
        }
    }
}




struct HomeViewContent: View{
    var body: some View{
        VStack{
            // Navigate to general learning
            CustomNavLink(destination:
                            CardView(difficulty: GetGeneralDifficulty(),topic: "general", cards: GetCards(difficulty: GetGeneralDifficulty(), topic: "general"))
                .customNAvigationTitle("Cards")
            ) {
                NavigationButton(buttonText: "General Learning")
            }
            .padding()
            // Navigate to topic specific learnin
            CustomNavLink(destination:
                            TopicView()
                .customNAvigationTitle("Topics")
            ) {
                NavigationButton(buttonText: "Learn by Topic")
            }
            .padding()
        }
    }
}

struct InitViewContent: View{
    
    @Binding var initState: Bool
    @State var difficulty: Int = 1
    @State var cards: [Card] = GetInitCards()
    
    var body: some View{
        VStack{
            // Title and current difficulty level
            Spacer()
            Group{
                Text("Difficulty level calibration")
                    .foregroundColor(Color("TextColor"))
                    .font(.title)
                Text("Current Difficulty: " + String(difficulty))
                    .foregroundColor(Color("TextColor"))
            }
            Spacer()
            
            // Cards
            ScrollView(.horizontal){
                HStack{
                    ForEach($cards){ $card in
                        CardFlip(front: {
                            // Show English side
                            VStack{
                                Spacer()
                                Text("English:")
                                Spacer()
                                Text(card.engWord.firstCapitalized)
                                Spacer()
                            }
                        }, back: {
                            // Show Dutch Side
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
                                                    // Increase attempts to shake textfield
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
                        }).padding([.top, .bottom], 80)
                    }
                }
            }
            Spacer()
            // Submitbutton
            SubmitInitButton(initState: $initState, difficulty: $difficulty, cards: $cards)
            Spacer()
        }
    }
}

struct SubmitInitButton: View{
    
    @Binding var initState: Bool
    @Binding var difficulty: Int
    @Binding var cards: [Card]
    
    var body: some View{
        Button {
            withAnimation{
                // Increase difficulty if correct and fetch new cards
                if (checkCards(cards: cards) && difficulty < 10){
                    difficulty += 1
                    cards = GetInitCards(difficulty: difficulty)
                }
                // Update the difficulty if a mistake was made or we reached a difficulty of 10
                else{
                    InitUpdateModel(difficulty: difficulty)
                    initState = false
                }
            }
        } label: {
            Text("Submit Cards")
                .bold()
                .frame(width: 280, height: 50)
                .background(Color("RevCardColor"))
                .foregroundColor(Color("RevTextColor"))
                .cornerRadius(10)
                .shadow(radius: 5, x:10, y:10)
        }
    }
    
    // Check if all cards are correctly filled
    func checkCards(cards: [Card])-> Bool{
        var allCorrect = true
        for card in cards {
            if !card.correct{
                allCorrect = card.correct
                break
            }
        }
        return allCorrect
    }
}

struct NavigationButton: View{
    var  buttonText: String
    
    var body: some View{
        Text(buttonText)
            .bold()
            .frame(width: 280, height: 50)
            .background(Color("CardColor"))
            .foregroundColor(Color("TextColor"))
            .cornerRadius(10)
            .shadow(radius: 5, x:10, y:10)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self){
            HomeView().preferredColorScheme($0)
        }
    }
}
