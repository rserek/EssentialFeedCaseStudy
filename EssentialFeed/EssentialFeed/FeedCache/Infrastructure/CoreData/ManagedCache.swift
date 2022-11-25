//
//  ManagedCache.swift
//  EssentialFeed
//
//  Created by Radosław Serek on 25/11/2022.
//

import CoreData

@objc(ManagedCache)
class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
    
    var localFeed: [LocalFeedImage] {
        return feed
            .compactMap { $0 as? ManagedFeedImage }
            .map(\.local)
    }
    
    static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: ManagedCache.entity().name!)
        request.returnsObjectsAsFaults = false
        
        return try context.fetch(request).first
    }
    
    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        try deleteFound(in: context)
        return ManagedCache(context: context)
    }
    
    static func deleteFound(in context: NSManagedObjectContext) throws {
        try find(in: context).map(context.delete)
    }
}
