//
//  TopicView.swift
//  Vocabul-R
//
//  Created by Gijs Lakeman on 13/04/2022.
//

import SwiftUI
import CoreData


struct TopicView: View {
    
    @State var topics: [Topic] = []
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(gradient: Gradient(colors: [Color("Background"), Color("CardColor")]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            ScrollView(.vertical){
                VStack{
                    // Create buttons for each topic
                    ForEach(topics){ topic in
                        TopicButton(buttonText: topic.topic, progressValue: topic.level)
                    }
                }
            }
        }.onAppear(perform: {updateTopics()})
    }
    
    func updateTopics(){
        self.topics = GetTopics()
    }
}

struct TopicButton: View{
    var buttonText: String
    var progressValue: Int
    
    var body: some View{
        CustomNavLink(destination: CardView(topic: buttonText)
            .customNAvigationTitle(buttonText.firstCapitalized), label: {
            VStack{
                HStack(){
                    // Progressbar
                    ProgressBar(progress: progressValue, maxLevel: getMaxLevel(topic: buttonText))
                    // Text
                    Text(buttonText.capitalized)
                        .font(.title)
                        .foregroundColor(Color("TextColor"))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                    // Chevron to indicate that it is a button
                    Image(systemName: "chevron.right")
                        .frame(alignment: .trailing)
                        .padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 100)
            .background(Color("CardColor"))
            .cornerRadius(10)
            .shadow(radius: 5, x:10, y:10)
            .padding()
        }).customNAvigationTitle(buttonText)
    }
}

struct ProgressBar: View{
    var progress: Int
    var maxLevel: Int
    
    var body: some View{
        ZStack {
            // Inner gray circle
            Circle()
                .stroke(lineWidth: 10.0)
                .opacity(0.20)
                .foregroundColor(Color("TextColor"))
                .frame(width: 70, height: 70)
            
            // Outer progress circle but capped off
            Circle()
                .trim(from: 0.0, to: CGFloat(min(Float(self.progress) / Float(maxLevel), 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 12.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color("RevCardColor"))
                .rotationEffect(Angle(degrees: 270))
                .animation(.easeInOut(duration: 2.0), value: self.progress)
                .frame(width: 70, height: 70)
                .padding()
            
            // Difficulty level number
            Text(String(progress))
                .font(.title)
                .foregroundColor(Color("TextColor"))
        }
    }
}

struct TopicView_Previews: PreviewProvider {
    static var previews: some View {
        TopicView()
    }
}
