//
//  ModelView.swift
//  Vocabul-R
//
//  Created by Gijs Lakeman on 26/04/2022.
//

import Foundation
import SwiftUI

// Add extension to uppercase firest letter of a string
extension StringProtocol {
    var firstUppercased: String { prefix(1).uppercased() + dropFirst() }
    var firstCapitalized: String { prefix(1).capitalized + dropFirst() }
}

struct Card: Identifiable{
    // Needed for foreach iteration
    let id = UUID()
    // Actual data from Model
    let engWord: String
    let nlWord: String
    let test: Bool
    // Needed for textfield et cetera
    var correct: Bool = false
    var answer: String = ""
    var showSymbol: Bool = false
    var attempts: Int = 0
}

struct Topic: Identifiable{
    // Needed for foreach iteration
    let id = UUID()
    // Actual data from Model
    let topic: String
    let level: Int
}

func GetCards(difficulty: Int = 1, topic: String = "") -> [Card]{
    // Remove this when adding function
    let cards: [Card] = [
        Card(engWord: "Test1", nlWord: "Test2", test: true),
        Card(engWord: "Test3", nlWord: "Test4", test: false),
        Card(engWord: "Test5", nlWord: "Test6", test: true)
    ]
    //let cards: [Card] =INSERT FUNCTION HERE
    return cards
}

func UpdateModel(cards: [Card]){
    // UPDATE FUNCTION HERE
}

func GetInitCards(difficulty: Int = 1) -> [Card]{
    // Remove this when adding function
    let cards: [Card]
    if difficulty == 1 {
         cards = [
            Card(engWord: "Test1", nlWord: "Test2", test: true),
            Card(engWord: "Test3", nlWord: "Test4", test: false),
            Card(engWord: "Test5", nlWord: "Test6", test: true)
        ]
    }else{
        cards = [
            Card(engWord: "Test7", nlWord: "Test8", test: true),
            Card(engWord: "Test9", nlWord: "Test10", test: false),
            Card(engWord: "Test11", nlWord: "Test12", test: true)
        ]
    }
    //let cards: [Card] =INSERT FUNCTION HERE
    return cards
}

func InitUpdateModel(difficulty: Int){
    // ADD FUNCTION HERE
}

func GetTopics() -> [Topic]{
    // Remove this if replacing with function
    let topics: [Topic] = [
        Topic(topic: "Topic1", level: 2),
        Topic(topic: "Topic2", level: 3),
        Topic(topic: "Topic3", level: 4),
        Topic(topic: "Topic3", level: 4),
        Topic(topic: "Topic3", level: 4),
        Topic(topic: "Topic3", level: 4),
        Topic(topic: "Topic3", level: 4),
        Topic(topic: "Topic3", level: 4),
        Topic(topic: "Topic3", level: 4),
        Topic(topic: "Topic3", level: 4),
        Topic(topic: "Topic3", level: 4),
        Topic(topic: "Topic3", level: 4),
    ]
    //let topics: [Topic] = ADD FUNCTION HERE
    return topics
}

func GetInitState() -> Bool{
    //return ADD FUNCTION HERE
    return true
}

func GetGeneralDifficulty() -> Int{
    // return ADD FUNCTION HERE
    return 1
}
