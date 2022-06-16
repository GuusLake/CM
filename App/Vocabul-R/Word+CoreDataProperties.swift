//
//  Word+CoreDataProperties.swift
//  Vocabul-R
//
//  Created by Guillermo on 15/06/2022.
//
//

import Foundation
import CoreData


extension Word {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Word> {
        return NSFetchRequest<Word>(entityName: "Word")
    }

    @NSManaged public var already_shown: Bool
    @NSManaged public var name: String?
    @NSManaged public var previous_guessed: Bool
    @NSManaged public var translation: String?
    @NSManaged public var group: NSSet?
    @NSManaged public var test_list: Test_list?
    @NSManaged public var time: NSSet?
    @NSManaged public var train_list: Train_list?

}

// MARK: Generated accessors for group
extension Word {

    @objc(addGroupObject:)
    @NSManaged public func addToGroup(_ value: GroupData)

    @objc(removeGroupObject:)
    @NSManaged public func removeFromGroup(_ value: GroupData)

    @objc(addGroup:)
    @NSManaged public func addToGroup(_ values: NSSet)

    @objc(removeGroup:)
    @NSManaged public func removeFromGroup(_ values: NSSet)

}

// MARK: Generated accessors for time
extension Word {

    @objc(addTimeObject:)
    @NSManaged public func addToTime(_ value: Time)

    @objc(removeTimeObject:)
    @NSManaged public func removeFromTime(_ value: Time)

    @objc(addTime:)
    @NSManaged public func addToTime(_ values: NSSet)

    @objc(removeTime:)
    @NSManaged public func removeFromTime(_ values: NSSet)

}

extension Word : Identifiable {

}
