//
//  ModelView.swift
//  Vocabul-R
//
//  Created by Guillermo on 08/06/2022.
//

import Foundation
import SwiftUI
import CoreData

let dataController = DataController()
let context = dataController.container.viewContext

let model = Model()

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

func GetCards(topic: String = "") -> [Card]{
    
    // The function do_..._practice gives cards with the words that match the user level
    //let model = Model()
    var cards: [Card]
    if topic == "general" || topic == "" {
        print("general")
        cards = model.do_general_practice(context: context)
    } else {
        print("topic")
        cards = model.do_topic_practice(topic_name: topic, context: context)
    }
    
    return cards
}

func GetInitCards(difficulty: Int=0) -> [Card]{
    // The same than the previous function but this one is for the first time the app opens. We with 3 cards of each levels range until the user fails
//    let dataController = DataController()
//    let context = dataController.container.viewContext

    let max_difficulty = model.getMaxDifficulty(context: context)
    let maxDifficulty = Int(max_difficulty)
    
    let difficulty_increase = (maxDifficulty)/50
    
    
    var cards = [Card]()
    let difficulties = Array(stride(from: difficulty, to: difficulty+difficulty_increase, by: 1))
        
    var randomIndex = Int(arc4random_uniform(UInt32(difficulties.count)))
    
    let groups = model.getGroupFromLevel(level: Int16(difficulties[randomIndex]), context: context)
    for _ in stride(from: 0, to: 3, by: 1) {
        randomIndex = Int(arc4random_uniform(UInt32(groups.count)))
        let group = groups[randomIndex]
        let words = group.word as! Set<Word>
        let new_word = words.randomElement()!
        //let words = Word.getWordFromGroup(group: group, context: context)
        //randomIndex = Int(arc4random_uniform(UInt32(words.count)))
        //let new_word = words[randomIndex]
        
        cards.append(Card(engWord: new_word.name!, nlWord: new_word.translation!, test: true))
    }
    
    return cards
}

func UpdateModel(cards: [Card]) {
    //let model = Model()
    model.updateModel(cards: cards, context: context)
}

func getMaxLevel(topic: String) -> Int{
    return Int(model.getMaxTopicDifficulty(topic_name: topic))
}

func InitUpdateModel(difficulty: Int) {
    // Set the first levels after the first test
//    let dataController = DataController()
//    let context = dataController.container.viewContext

    let group = model.getGroupFromLevel(level: Int16(difficulty), context: context)
    //let model = Model()
    model.setFirstLevel(groups: group, context: context)
}

func GetTopics() -> [Topic]{
    // List of all the topics
//    let dataController = DataController()
//    let context = dataController.container.viewContext
    
    let topics_data = model.getAllTopics(context: context)
    
    var topics = [Topic]()
    for topic_data in topics_data {
        let name = topic_data.name ?? ""
        let level = Int(topic_data.activationLevel)
        
        let new_topic = Topic(topic:name, level:level)

        topics.append(new_topic)
    }
    
    return topics
}

func GetInitState() -> Bool{
    // The first time the app runs, move csv files to database and return true to do the first test
    UserDefaults.standard.set(false, forKey: "firstRun")
    let firstRun = UserDefaults.standard.bool(forKey: "firstRun") as Bool
    
    
    if firstRun == false {
        restartApp()
        do {
            try moveToDataBase()
        } catch {}
        
        return true
    }
    else {
        addWordsToDM()
        return false
    }
}

func addWordsToDM() {
    // This function is used when the app launches after being closed. It get all the words that we have to test and the last time they were activated
    let test_list = model.getTestList(context: context)
    let test_words = test_list.word as! Set<Word>
    let words = Array(test_words)
    for word in words {
        let times = word.time as! Set<Time>
        let new_times = Array(times)
        let chunk = Chunk(s: word.name!, m: model)
        for time in new_times {
            let interval = time.time!.timeIntervalSinceReferenceDate
            let minutes = Double((interval/60).truncatingRemainder(dividingBy: 60))
            model.dm.addToDM(chunk, minutes)
        }
    }
}



func moveToDataBase() throws {
    
        // Read all the csv files and move their content to the correspondent entity on the database
    
        
        // TOPICS
        parseCSV_topics(data_file: "data/activation_level")
        
        // GROUPS
        parseCSV_groups(data_file: "data/action_mean_level", topic_name: "Action")
        
        parseCSV_groups(data_file: "data/attribute_mean_level", topic_name: "Attribute")
        
        parseCSV_groups(data_file: "data/building_mean_level", topic_name: "Building")
        
        parseCSV_groups(data_file: "data/business_mean_level", topic_name: "Business")
        
        //parseCSV_groups(data_file: "data/city_mean_level", topic_name: "City")
        
        parseCSV_groups(data_file: "data/clothes_mean_level", topic_name: "Clothes")
        
        parseCSV_groups(data_file: "data/color_mean_level", topic_name: "Color")
        
        parseCSV_groups(data_file: "data/computer_mean_level", topic_name: "Computer")
        
        //parseCSV_groups(data_file: "data/cook_mean_level", topic_name: "Cook")
        
        parseCSV_groups(data_file: "data/day_mean_level", topic_name: "Day")
        
        parseCSV_groups(data_file: "data/earth_mean_level", topic_name: "Earth")
        
        parseCSV_groups(data_file: "data/emotions_mean_level", topic_name: "Emotions")
        
        parseCSV_groups(data_file: "data/feelings_mean_level", topic_name: "Feelings")
        
        parseCSV_groups(data_file: "data/film_mean_level", topic_name: "Film")

        parseCSV_groups(data_file: "data/fish_mean_level", topic_name: "Fish")
        
        parseCSV_groups(data_file: "data/food_mean_level", topic_name: "Food")

        parseCSV_groups(data_file: "data/fruit_mean_level", topic_name: "Fruit")
        
        parseCSV_groups(data_file: "data/furniture_mean_level", topic_name: "Furniture")
        
        parseCSV_groups(data_file: "data/house_mean_level", topic_name: "House")
        
        parseCSV_groups(data_file: "data/insect_mean_level", topic_name: "Insect")
        
        parseCSV_groups(data_file: "data/jobs_mean_level", topic_name: "Jobs")
        
        parseCSV_groups(data_file: "data/mammal_mean_level", topic_name: "Mammal")
        
        parseCSV_groups(data_file: "data/medicine_mean_level", topic_name: "Medicine")
        
        parseCSV_groups(data_file: "data/music_mean_level", topic_name: "Music")
        
        parseCSV_groups(data_file: "data/negotiation_mean_level", topic_name: "Negotiation")
        
        parseCSV_groups(data_file: "data/number_mean_level", topic_name: "Number")
        
        parseCSV_groups(data_file: "data/quantity_mean_level", topic_name: "Quantity")
        
        parseCSV_groups(data_file: "data/reptile_mean_level", topic_name: "Reptile")
        
        parseCSV_groups(data_file: "data/road_mean_level", topic_name: "Road")
        
        parseCSV_groups(data_file: "data/shapes_mean_level", topic_name: "Shapes")
        
        parseCSV_groups(data_file: "data/space_mean_level", topic_name: "Space")
        
        parseCSV_groups(data_file: "data/sports_mean_level", topic_name: "Sports")
        
        parseCSV_groups(data_file: "data/temperature_mean_level", topic_name: "Temperature")
        
        parseCSV_groups(data_file: "data/time_mean_level", topic_name: "Time")
        
        parseCSV_groups(data_file: "data/vegetables_mean_level", topic_name: "Vegetables")
        
        parseCSV_groups(data_file: "data/vehicle_mean_level", topic_name: "Vehicle")
        
        parseCSV_groups(data_file: "data/weather_mean_level", topic_name: "Weather")
        
    
        // WORDS
        
        parseCSV_words(data_file: "data/action", topic_name: "Action")
        
        parseCSV_words(data_file: "data/attribute", topic_name: "Attribute")
        
        parseCSV_words(data_file: "data/building", topic_name: "Building")
        
        parseCSV_words(data_file: "data/business", topic_name: "Business")
        
        //parseCSV_words(data_file: "data/city", topic_name: "City")
        
        parseCSV_words(data_file: "data/clothes", topic_name: "Clothes")
        
        parseCSV_words(data_file: "data/color", topic_name: "Color")
        
        parseCSV_words(data_file: "data/computer", topic_name: "Computer")
        
        //parseCSV_words(data_file: "data/cook", topic_name: "Cook")
        
        parseCSV_words(data_file: "data/day", topic_name: "Day")
        
        parseCSV_words(data_file: "data/earth", topic_name: "Earth")
        
        parseCSV_words(data_file: "data/emotions", topic_name: "Emotions")
        
        parseCSV_words(data_file: "data/feelings", topic_name: "Feelings")
        
        parseCSV_words(data_file: "data/film", topic_name: "Film")

        parseCSV_words(data_file: "data/fish", topic_name: "Fish")
        
        parseCSV_words(data_file: "data/food", topic_name: "Food")

        parseCSV_words(data_file: "data/fruit", topic_name: "Fruit")
        
        parseCSV_words(data_file: "data/furniture", topic_name: "Furniture")
        
        parseCSV_words(data_file: "data/house", topic_name: "House")
        
        parseCSV_words(data_file: "data/insect", topic_name: "Insect")
        
        parseCSV_words(data_file: "data/jobs", topic_name: "Jobs")
        
        parseCSV_words(data_file: "data/mammal", topic_name: "Mammal")
        
        parseCSV_words(data_file: "data/medicine", topic_name: "Medicine")
        
        parseCSV_words(data_file: "data/music", topic_name: "Music")
        
        parseCSV_words(data_file: "data/negotiation", topic_name: "Negotiation")
        
        parseCSV_words(data_file: "data/number", topic_name: "Number")
        
        parseCSV_words(data_file: "data/quantity", topic_name: "Quantity")
        
        parseCSV_words(data_file: "data/reptile", topic_name: "Reptile")
        
        parseCSV_words(data_file: "data/road", topic_name: "Road")
        
        parseCSV_words(data_file: "data/shapes", topic_name: "Shapes")
        
        parseCSV_words(data_file: "data/space", topic_name: "Space")
        
        parseCSV_words(data_file: "data/sports", topic_name: "Sports")
        
        parseCSV_words(data_file: "data/temperature", topic_name: "Temperature")
        
        parseCSV_words(data_file: "data/time", topic_name: "Time")
        
        parseCSV_words(data_file: "data/vegetables", topic_name: "Vegetables")
        
        parseCSV_words(data_file: "data/vehicle", topic_name: "Vehicle")
        
        parseCSV_words(data_file: "data/weather", topic_name: "Weather")
    
}

func parseCSV_topics (data_file: String) {
    
    guard let filepath = Bundle.main.path(forResource: data_file, ofType: "csv") else {
        return
    }
    
    
//    let dataController = DataController()
//    let context = dataController.container.viewContext
    
    
    
    
    
    do {
        try context.save()
        }
    catch {
    }
    
    
    
    var data = ""
    do {
        data = try String(contentsOfFile: filepath)
    } catch {
        return
    }
    
    var rows = data.components(separatedBy: "\n")
    rows.remove(at: 0)
    
    
    for row in rows {
        let columns = row.components(separatedBy: ",")
        
        let name = columns[0]
        let activation_level = (columns[1] as NSString).integerValue
        let activated: Bool = false
        let last_opened_group: Int16 = 0
        let current_level: Int16 = 0
        let finished: Bool = false
        
        let topic = TopicData(context: context)
        topic.name = name
        
        topic.activated = activated
        topic.activationLevel = Int16(activation_level)
        topic.last_opened_group = last_opened_group
        topic.current_level = current_level
        topic.finished = finished
        
        do {
            try context.save()
            }
        catch {
            print("Context not saved")
        }
    }
    
    
    
}


func parseCSV_groups (data_file: String, topic_name: String) {
    
    guard let filepath = Bundle.main.path(forResource: data_file, ofType: "csv") else {
        return
    }
    
    var data = ""
    do {
        data = try String(contentsOfFile: filepath)
    } catch {
        return
    }
    
    var rows = data.components(separatedBy: "\n")
    rows.remove(at: 0)
//    let dataController = DataController()
//    let context = dataController.container.viewContext
    
    let topic = model.getTopicFromName(name: topic_name, context: context)
    
    let train_list = Train_list(context: context)
    let test_list = Test_list(context: context)
    train_list.train_list = "train_list"
    test_list.test_list = "test_list"
    
    
    
    for row in rows {
        let columns = row.components(separatedBy: ",")
        
        
        
        let index_group = (columns[0] as NSString).integerValue
        let mean_level = (columns[1] as NSString).integerValue
        let cleared_words: Int16 = 0
        
        
        let group = GroupData(context: context)
        group.index_group = Int16(index_group)
        
        group.mean_level = Int16(mean_level)
        group.cleared_words = cleared_words
        //group.topic = topic
        topic.addToGroup(group)
        
        do {
            try context.save()
            }
        catch {
            print("Context not saved")
        }
        
    }
    
    
}

func restartApp() {
    let model = Model()
    model.deleteAll(context: context)
    //UserDefaults.standard.set(true, forKey: "firstRun")
}


func parseCSV_words (data_file: String, topic_name: String) {
    
    guard let filepath = Bundle.main.path(forResource: data_file, ofType: "csv") else {
        return
    }
    
    var data = ""
    do {
        data = try String(contentsOfFile: filepath)
    } catch {
        return
    }
    
    var rows = data.components(separatedBy: "\n")
    rows.remove(at: 0)
//    let dataController = DataController()
//    let context = dataController.container.viewContext
    
    let topic = model.getTopicFromName(name: topic_name, context: context)
    
    
    for row in rows {
        let columns = row.components(separatedBy: ",")
        
        let name = columns[0]
        let translation = columns[1]
        let group_index = (columns[2] as NSString).integerValue
        let previous_guessed: Bool = false
        let character: Character = "?"
        
        let group = model.getGroupFromIndexAndTopic(index: Int16(group_index), topic: topic, context: context)
        //print(group.topic!.name!)
        
        
        var already_shown: Bool = false
        
        if translation.contains(character) || translation.contains("0") || translation.contains("/") {
            already_shown = true
        }
        
        let word = Word(context: context)
        
        word.name = name
        word.translation = translation
        word.previous_guessed = previous_guessed
        
        
        
        group.addToWord(word)
//        var previous_groups = word.group as? Set<GroupData> ?? []
//        previous_groups.update(with: group)
        
        word.already_shown = already_shown
        
        do {
            try context.save()
            }
        catch {
            print("Context not saved")
        }
    }
    
}

