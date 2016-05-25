//
//  TaskList.swift
//  Ophelia
//
//  Created by Chase Swanstrom on 5/5/16.
//  Copyright © 2016 Chase Swanstrom. All rights reserved.
//

import Foundation
import UIKit

class TaskList {
    class var sharedInstance : TaskList {
        struct Static {
        static let instance : TaskList = TaskList()
        }
        return Static.instance
    }
    
    private let ITEMS_KEY = "taskItems"
    
    func addTask(task: Task) {
        var taskDictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey(ITEMS_KEY) ?? Dictionary()
        taskDictionary[task.UUID] = ["deadline": task.deadline, "title": task.name, "cat": task.cat, "days": task.days, "UUID": task.UUID]
        NSUserDefaults.standardUserDefaults().setObject(taskDictionary, forKey: ITEMS_KEY)
        
        let notification = UILocalNotification()
        notification.category = "TODO_CATEGORY"
        notification.alertBody = "Have you \"\(task.name)\" yet?"
        notification.alertAction = "open"
        notification.fireDate = task.deadline
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["UUID": task.UUID, ]
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
    }
    
    func allTasks() -> [Task] {
        let taskDictionary = NSUserDefaults.standardUserDefaults().dictionaryForKey(ITEMS_KEY) ?? [:]
        let tasks = Array(taskDictionary.values)
        return tasks.map({Task(name: $0["title"] as! String, deadline: $0["deadline"] as! NSDate, cat: $0["cat"] as! String, days: $0["days"] as! Int, UUID: $0["UUID"] as! String!)}).sort({(left: Task, right:Task) -> Bool in
            (left.deadline.compare(right.deadline) == .OrderedAscending) })
    }
    
    func removeItem(item: Task) {
        for notification in UIApplication.sharedApplication().scheduledLocalNotifications! as [UILocalNotification] {
            if (notification.userInfo!["UUID"] as! String == item.UUID) {
                UIApplication.sharedApplication().cancelLocalNotification(notification)
                break
            }
        }
        if var tasks = NSUserDefaults.standardUserDefaults().dictionaryForKey(ITEMS_KEY) {
            tasks.removeValueForKey(item.UUID)
            NSUserDefaults.standardUserDefaults().setObject(tasks, forKey: ITEMS_KEY) // save/overwrite todo item list
        }
    }
    
    func scheduleReminderforItem(item: Task) {
        let notification = UILocalNotification()
        notification.alertBody = "Reminder: Task \"\(item.name)\" is Due"
        notification.alertAction = "open"
        notification.fireDate = NSDate().add(2)
        notification.soundName = UILocalNotificationDefaultSoundName 
        notification.userInfo = ["title": item.name, "UUID": item.UUID]
        notification.category = "TODO_CATEGORY"
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }

}

