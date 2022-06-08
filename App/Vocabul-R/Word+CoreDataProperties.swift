//
//  Word+CoreDataProperties.swift
//  Vocabul-R
//
//  Created by Guillermo on 14/05/2022.
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

extension Word : Identifiable {

}
