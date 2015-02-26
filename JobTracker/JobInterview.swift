//
//  JobInterview.swift
//  
//
//  Created by Joanne Dyer on 2/24/15.
//
//

import Foundation
import CoreData

class JobInterview: NSManagedObject {

    @NSManaged var interviewNumber: NSNumber
    @NSManaged var eventID: String
    @NSManaged var title: String
    @NSManaged var starts: NSDate
    @NSManaged var ends: NSDate
    @NSManaged var notes: String
    @NSManaged var interviewLocation: JobLocation
    @NSManaged var basic: JobBasic

}
