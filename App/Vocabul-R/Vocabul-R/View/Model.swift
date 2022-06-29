import Foundation
import CoreData


class Model: Codable {

    var dm = Declarative()
    var chunkIdCounter = 0
    var buffers: [String:Chunk] = [:]

    
    func getCurrentTime() -> Double{
        let now = Date()
        let interval = now.timeIntervalSinceReferenceDate
        let minutes = Double((interval/60).truncatingRemainder(dividingBy: 60))

        let seconds = Double((interval).truncatingRemainder(dividingBy: 60))
        return minutes
    }
    
    

    
    // Get the groups that suit the user best level and open them. Also, add words to train list
    func setFirstLevel(groups: [GroupData], context: NSManagedObjectContext) {

        
        
        let train_list = getTrainList(context: context)
        
        for group in groups {
            let topic = group.topic!
            topic.activated = true
            

            topic.last_opened_group = group.index_group
            topic.current_level = group.mean_level
            
            let words_set = group.word as! Set<Word>
            let words = Array(words_set)
            
            for word in words {
                word.train_list = train_list
            }
            
            
            
            do {
                try context.save()
                }
            catch {
                print("Context not saved")
            }
            
        }
        
        UserDefaults.standard.set(true, forKey: "firstRun")
    }


    func do_general_practice(context: NSManagedObjectContext) -> [Card]{
//        let dataController = DataController()
//        let context = dataController.container.viewContext
        
        // Choose the corresponding train and test words and make the cards to show
        
        var cards = [Card]()
        
        let trainList = getTrainList(context: context)
        let trainWords = trainList.word as! Set<Word>
        
        
        let testList = getTestList(context: context)
        let testWords = testList.word as! Set<Word>
        let newTestWords = Array(testWords)

        
        if (trainWords.count + testWords.count < 10) {
            openNextGeneralGroup(context: context)
        }
        var train_count: Double = Double(trainWords.count / (trainWords.count + testWords.count))
        train_count = round(Double(train_count*10))
        let test_count = 10 - train_count
        let retrievedWords = retrieve_general_test_words(words: newTestWords, test_count: Int16(test_count), context: context)
        
        var index = 0
        
        
        if train_count != 0 {
            for new_word in trainWords {
                
                let engWord = new_word.name ?? ""
                let nlWord = new_word.translation ?? ""
                let test = false
                
                cards.append(Card(engWord: engWord, nlWord: nlWord, test: test))
                
                index += 1
                if index == Int(train_count) {
                    break
                }
            }
        }
        
        
        for (current_test_words, test_booleans) in retrievedWords {
            let engWord = current_test_words.name ?? ""
            let nlWord = current_test_words.translation ?? ""
            let test = test_booleans
            
            
            cards.append(Card(engWord: engWord, nlWord: nlWord, test: test))
            
        }


        return cards
        

    }

    func retrieve_general_test_words(words: [Word], test_count: Int16, context: NSManagedObjectContext) -> ([Word: Bool]) {
        // Used for the previous function. Get the words that are in the test list and choose the ones with lower latency
//        let dataController = DataController()
//        let context = dataController.container.viewContext
        
        var chunkDict: [String: Double] = [:]
        
        for word in words {
            let chunk = Chunk(s: word.name!, m: self)
            let (new_latency, new_retrieveResult) = dm.retrieve(chunk: chunk)
            chunkDict[new_retrieveResult?.name ?? ""] = new_latency
        }
        

        
        let sortedByValueDictionary = chunkDict.sorted { $0.1 < $1.1 }
        
        
        var testDict: [Word: Bool] = [:]
        
        var index = 0
        var test_bool = true
        var new_word: Word
        for (name, latency) in sortedByValueDictionary {
            test_bool = true
            if index == test_count {
                break
            }
            if latency == -2 {
                test_bool = false
            }
            new_word = getWordFromName(name: name, context: context)!
            testDict[new_word] = test_bool
            index = index + 1
        }
        
        return testDict
    }
    
    func updateModel(cards: [Card], context: NSManagedObjectContext) {
        // Depending on if the word was trained or tested, we do different things
//        let dataController = DataController()
//        let context = dataController.container.viewContext
        let trainList = getTrainList(context: context)
        let testList = getTestList(context: context)
        for card in cards {
            let word_name = card.engWord
            let word = getWordFromName(name: word_name, context: context)
            let chunk = Chunk(s: word_name, m: self)
            
            if card.test == false {
                
                // Save chunk
                dm.addToDM(chunk, getCurrentTime())
                let now = Date()
                let time = Time(context: context)
                time.time = now
                time.word = word
                
                word?.train_list = nil
                word?.test_list = testList

                
            } else {
                if card.correct == false {
                    word?.previous_guessed = false
                    word?.test_list = nil
                    word?.train_list = trainList
                    dm.addToDM(chunk, getCurrentTime())
                    let now = Date()
                    let time = Time(context: context)
                    time.time = now
                    time.word = word
                } else {
                    if word?.previous_guessed == false {
                        word?.previous_guessed = true
                        dm.addToDM(chunk, getCurrentTime())
                        dm.addToDM(chunk, getCurrentTime())
                        let now = Date()
                        let time = Time(context: context)
                        time.time = now
                        time.word = word
                        
                    } else {
                        // Remove from test list
                        word?.test_list = nil
                        // And remove time references
                        word?.time = nil
                        
                        
                        // Check changes
                        let groups = word!.group as! Set<GroupData>
                        for group in groups {
                            var cleared_words = group.cleared_words
                            cleared_words += 1
                            print(cleared_words)
                            group.cleared_words += 1
                            if group.topic!.group?.count == Int(group.index_group) {
                                // This happens when the group is the last one in the topic. Hide this topic since it is learned
                                if cleared_words == group.word!.count {
                                    group.topic!.finished = true
                                }
                            }
                            else {
                                if cleared_words >= 8 {
                                    // We consider the group cleared and open the next one
                                    openNextTopicGroup(topic: group.topic!, context: context)
                                    openNewTopic(context: context)
                                }
                            }
                            
                        }
                        
                        
                    }
                    
                }
            }
            
            do {
                try context.save()
                }
            catch {
                print("Context not saved")
            }
        }

    }

    func openNewTopic(context: NSManagedObjectContext) {
        
        // Check if from the current level there are more topics that can be opened
//        let dataController = DataController()
//        let context = dataController.container.viewContext
        let trainList = getTrainList(context: context)
        
        let mean_level = getMeanLevel(context: context)
        let (topics,open_topic) = openTopicFromLevel(level: mean_level, context: context)
        
        if open_topic == true {
            for topic in topics {
                print("opening new topic")
                let group = getGroupFromIndexAndTopic(index: 0, topic: topic, context: context)
                topic.last_opened_group = 0
                topic.activated = true
                topic.current_level = group.mean_level
                
                let words_list = group.word as! Set<Word>
                var increase_already_shown = 0
                for word in words_list {
                    if word.already_shown == false {
                        word.train_list = trainList
                    } else {
                        increase_already_shown += 1
                    }
                    
                }
                group.cleared_words = Int16(increase_already_shown)
            }
            
            
            do {
                try context.save()
                }
            catch {
                print("Context not saved")
            }
        }
    }

    func openNextTopicGroup(topic: TopicData, context: NSManagedObjectContext) {
        // Update topic (current_level and current_group)
        // Update train_list (add words from new group)
//        let dataController = DataController()
//        let context = dataController.container.viewContext
        
        
        let max_groups = (topic.group?.count)! - 1
        
        let last_group = topic.last_opened_group
        if last_group < max_groups {
            let new_group_index = last_group+1
            
            topic.last_opened_group += 1
            let topicGroups = topic.group as! Set<GroupData>
            let groupsArray = Array(topicGroups)
            
            let new_group = groupsArray[Int(new_group_index)]
            topic.current_level = new_group.mean_level
            
            let trainList = getTrainList(context: context)
            
            let words_list = new_group.word as! Set<Word>
            var increase_already_shown = 0
            for word in words_list {
                
                if word.already_shown == false {
                    word.train_list = trainList
                } else {
                    increase_already_shown += 1
                }
                
            }
            new_group.cleared_words = Int16(increase_already_shown)
            do {
                try context.save()
                }
            catch {
                print("Context not saved")
            }
        }
        
        
    }
    
    func openNextGeneralGroup(context: NSManagedObjectContext) {
        // Uses the previous function but choosing the topic with the lowest level
//        let dataController = DataController()
//        let context = dataController.container.viewContext

        let topic = getTopicFromLowerActivation(context: context)
        openNextTopicGroup(topic: topic, context: context)
    }


    func do_topic_practice(topic_name: String, context: NSManagedObjectContext) -> [Card]{
        // Same as general practice but words are just gotten for one topic
        
//        let dataController = DataController()
//        let context = dataController.container.viewContext
        
        // Choose the corresponding train and test words and make the cards to show
        
        var cards = [Card]()
        
        let topic = getTopicFromName(name: topic_name, context: context)
        
        var trainList = getTrainList(context: context)
        var trainWords = trainList.word as! Set<Word>
        var train_Words = Array(trainWords)
        
        var topicTrainWords = getTrainWordFromTopic(train_words: train_Words, topic: topic, context: context)
        
        
        var testList = getTestList(context: context)
        var testWords = testList.word as! Set<Word>
        var test_Words = Array(testWords)
        var topicTestWords = getTestWordFromTopic(test_words: test_Words, topic: topic, context: context)
        

        if (topicTrainWords.count + topicTestWords.count < 10) {
            
            openNextTopicGroup(topic: topic, context: context)
            trainList = getTrainList(context: context)
            trainWords = trainList.word as! Set<Word>
            train_Words = Array(trainWords)
            
            
            topicTrainWords = getTrainWordFromTopic(train_words: train_Words, topic: topic, context: context)
            
            
            
            testList = getTestList(context: context)
            testWords = testList.word as! Set<Word>
            test_Words = Array(testWords)
            topicTestWords = getTestWordFromTopic(test_words: test_Words, topic: topic, context: context)
        }

        var train_count: Double = (Double(topicTrainWords.count) / Double(topicTrainWords.count + topicTestWords.count))
        
        train_count = round(Double(train_count*10))
        let test_count = 10 - train_count
        
        let retrievedWords = retrieve_topic_test_words(words: topicTestWords, test_count: Int16(test_count), context: context)
        
        var index = 0
        
        if train_count != 0 {
            for new_word in topicTrainWords {
                
                
                let engWord = new_word.name ?? ""
                let nlWord = new_word.translation ?? ""
                let test = false
                
                cards.append(Card(engWord: engWord, nlWord: nlWord, test: test))
                
                index += 1
                if index == Int(train_count) {
                    break
                }
            }
            
        }
        
        for (current_test_words, test_booleans) in retrievedWords {
            let engWord = current_test_words.name ?? ""
            let nlWord = current_test_words.translation ?? ""
            let test = test_booleans
            
            
            cards.append(Card(engWord: engWord, nlWord: nlWord, test: test))
            
        }

        
        return cards
        

    }

    func retrieve_topic_test_words(words: [Word], test_count: Int16, context: NSManagedObjectContext) -> ([Word: Bool]) {
//        let dataController = DataController()
//        let context = dataController.container.viewContext
        
        var chunkDict: [String: Double] = [:]
        // Loop through all test_words in the topic and retrieve chunk from each if exists
        for word in words {
            let chunk = Chunk(s: word.name!, m: self)
            
            
            let (new_latency, new_retrieveResult) = dm.retrieve(chunk: chunk)
            
            chunkDict[new_retrieveResult?.name ?? ""] = new_latency
        }
        
        let sortedByValueDictionary = chunkDict.sorted { $0.1 < $1.1 }
        
        var testDict: [Word: Bool] = [:]
        
        var index = 0
        var test_bool = true
        var new_word: Word
        if test_count != 0 {
            for (name, latency) in sortedByValueDictionary {
                test_bool = true
                if index == test_count {
                    break
                }
                if latency == -2 {
                    test_bool = false
                }
                new_word = getWordFromName(name: name, context: context)!
                testDict[new_word] = test_bool
                index = index + 1
            }
        }
        
        
        return testDict
    }

    func generateNewChunk(string id: String = "chunk", name: String) -> Chunk {
        let name = generateName(string: id)
        let chunk = Chunk(s: name, m: self)
        return chunk
    }
    
    func generateName(string s1: String = "name") -> String {
        let name = s1 + "\(chunkIdCounter)"
        chunkIdCounter += 1
        return name
    }
    
    
    func deleteAll(context: NSManagedObjectContext) {
        // Get all entities on the database and remove them. Also remove chunks on dm
        deleteTopic(context: context)
        deleteWord(context: context)
        deleteGroup(context: context)
        deleteTrainList(context: context)
        deleteTestList(context: context)
        dm.chunks = [:]
    }

    func getTestList(context:NSManagedObjectContext) -> Test_list {
        let fetchList = NSFetchRequest<Test_list>(entityName: "Test_list")
        fetchList.predicate = NSPredicate(format: "test_list == test_list")
        let test_list = (try? context.fetch(fetchList)) ?? []
        let single_list = test_list.first
        return single_list!
    }

    func deleteTestList(context: NSManagedObjectContext) {
//        let dataController = DataController()
//        let context = dataController.container.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Test_list")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
        } catch {
            
        }
    }
    
    func getAllTopics(context:NSManagedObjectContext) -> [TopicData] {
        let fetchRequest = NSFetchRequest<TopicData>(entityName: "TopicData")
        fetchRequest.predicate = NSPredicate(format: "finished = false")
        let topics = (try? context.fetch(fetchRequest)) ?? []
        return topics
    }

    func getTopicFromName(name: String, context:NSManagedObjectContext) -> TopicData {
        let fetchRequest = NSFetchRequest<TopicData>(entityName: "TopicData")
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        let topics = (try? context.fetch(fetchRequest)) ?? []
        let topic = topics.first ?? TopicData()
        
        return topic
    }

    func getTopicFromLowerActivation(context:NSManagedObjectContext) -> TopicData {
        let fetchRequest = NSFetchRequest<TopicData>(entityName: "TopicData")
        fetchRequest.predicate = NSPredicate(format: "activated = true")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key:"current_level", ascending: true)]
        let topics = (try? context.fetch(fetchRequest)) ?? []
        let topic = topics.first
        return topic!
    }

    func getActivationFromTopic(name: String, context:NSManagedObjectContext) -> Int16? {
        let fetchRequest = NSFetchRequest<TopicData>(entityName: "TopicData")
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        let topics = (try? context.fetch(fetchRequest)) ?? []
        let topic = topics.first
        let activation = topic?.activationLevel
        return activation
    }

    func getMeanLevel(context:NSManagedObjectContext) -> Int16 {
        let fetchRequest = NSFetchRequest<TopicData>(entityName: "TopicData")
        fetchRequest.predicate = NSPredicate(format: "activated = true")
        let topics = (try? context.fetch(fetchRequest)) ?? []
        var total_sum = 0
        for topic in topics {
            total_sum += Int(topic.current_level)
        }
        let mean_level = total_sum/topics.count
        return Int16(mean_level)
    }

    func openTopicFromLevel(level: Int16, context:NSManagedObjectContext) -> ([TopicData], Bool) {
        let fetchRequest = NSFetchRequest<TopicData>(entityName: "TopicData")
        fetchRequest.predicate = NSPredicate(format: "activated = false AND activationLevel = %i", level)
        let topics = (try? context.fetch(fetchRequest)) ?? []
        var open_group = false
        if topics.isEmpty == false{
            open_group = true
            
            
        }
        return (topics, open_group)
    }

    func deleteTopic(context: NSManagedObjectContext) {
//        let dataController = DataController()
//        let context = dataController.container.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "TopicData")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
        } catch {
            
        }
    }
    
    func getGroupFromIndexAndTopic(index: Int16, topic: TopicData, context:NSManagedObjectContext) -> GroupData {
        let fetchRequest = NSFetchRequest<GroupData>(entityName: "GroupData")
        
        fetchRequest.predicate = NSPredicate(format: "index_group = %d AND topic = %@", index, topic)

        
        let groups = (try? context.fetch(fetchRequest)) ?? []
        let group = groups.first!
        return group
    }

    func getGroupFromLevel(level: Int16, context:NSManagedObjectContext) -> [GroupData] {
        let fetchRequest = NSFetchRequest<GroupData>(entityName: "GroupData")
        fetchRequest.predicate = NSPredicate(format: "mean_level = %d", level)
        let groups = (try? context.fetch(fetchRequest)) ?? []
        return groups
    }

    func getMaxDifficulty(context:NSManagedObjectContext) -> Int16 {
        let fetchRequest = NSFetchRequest<GroupData>(entityName: "GroupData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key:"mean_level", ascending: false)]
        let group = (try? context.fetch(fetchRequest)) ?? []
        let level = group.first?.mean_level
        return level!
    }
    
    func getMaxTopicDifficulty(topic_name: String) -> Int16 {
        let context = dataController.container.viewContext
        let topic = getTopicFromName(name: topic_name, context: context)
        
        let fetchRequest = NSFetchRequest<GroupData>(entityName: "GroupData")
        fetchRequest.predicate = NSPredicate(format: "topic = %@", topic)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key:"mean_level", ascending: false)]
        let group = (try? context.fetch(fetchRequest)) ?? []
        let level = group.first?.mean_level
        return level!
    }

    func deleteGroup(context: NSManagedObjectContext) {
//        let dataController = DataController()
//        let context = dataController.container.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "GroupData")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
        } catch {
            
        }
    }
    
    func getTrainList(context:NSManagedObjectContext) -> Train_list {
        let fetchList = NSFetchRequest<Train_list>(entityName: "Train_list")
        fetchList.predicate = NSPredicate(format: "train_list == train_list")
        let train_list = (try? context.fetch(fetchList)) ?? []
        let single_list = train_list.first
        return single_list!
    }

    func deleteTrainList(context: NSManagedObjectContext) {
//        let dataController = DataController()
//        let context = dataController.container.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Train_list")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
        } catch {
            
        }
    }
    
    //    func getWordFromGroup(group: GroupData, context:NSManagedObjectContext) -> [Word] {
    //        let fetchRequest = NSFetchRequest<Word>(entityName: "Word")
    //        fetchRequest.predicate = NSPredicate(format: "group = %@", group)
    //        let words = (try? context.fetch(fetchRequest)) ?? []
    //        return words
    //    }

    func getWordFromTopic(topic: TopicData, context:NSManagedObjectContext) -> [Word] {
        
        let groups = topic.group as! Set<GroupData>
        
    //        let fetchRequest = NSFetchRequest<GroupData>(entityName: "GroupData")
    //        fetchRequest.predicate = NSPredicate(format: "topic = %@", topic)
    //        let groups = (try? context.fetch(fetchRequest)) ?? []
        
        var topic_words = [Word]()
        for group in groups {
            let group_words = group.word as! Set<Word>
            topic_words.append(contentsOf: group_words)
            
        }
        return topic_words
    }

    func getWordFromName(name: String, context:NSManagedObjectContext) -> Word? {
        let fetchRequest = NSFetchRequest<Word>(entityName: "Word")
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        let words = (try? context.fetch(fetchRequest)) ?? []
        return words.first
    }
    

    func getTrainWordFromTopic(train_words: [Word], topic: TopicData, context:NSManagedObjectContext) -> [Word] {
        
        let fetchRequest = NSFetchRequest<Word>(entityName: "Word")
        let topic_words = getWordFromTopic(topic: topic, context: context)
        
        // Get names so we can compare with topic name
        let topic_word_names = topic_words.map { $0.name! }
        let train_word_names = train_words.map { $0.name! }
        fetchRequest.predicate = NSPredicate(format: "name IN %@ AND name IN %@", topic_word_names, train_word_names)
        let words = (try? context.fetch(fetchRequest)) ?? []
        return words
    }

    func getTestWordFromTopic(test_words: [Word], topic: TopicData, context:NSManagedObjectContext) -> [Word] {
        
        let fetchRequest = NSFetchRequest<Word>(entityName: "Word")
        let topic_words = getWordFromTopic(topic: topic, context: context)
        // Get names so we can compare with topic name
        let topic_word_names = topic_words.map { $0.name! }
        let test_word_names = test_words.map { $0.name! }
        fetchRequest.predicate = NSPredicate(format: "name IN %@ AND name IN %@", topic_word_names, test_word_names)
        let words = (try? context.fetch(fetchRequest)) ?? []
        return words
    }

    func deleteWord(context: NSManagedObjectContext) {
//        let dataController = DataController()
//        let context = dataController.container.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Word")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
        } catch {
            
        }
    }
}
