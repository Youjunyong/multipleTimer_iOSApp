//
//  DataManager.swift
//  multipleTimer
//
//  Created by 유준용 on 2021/09/15.
//

import CoreData
import Foundation

class DataManager{
  static let shared = DataManager()
  private init(){
  }

  var mainContext : NSManagedObjectContext{
    return persistentContainer.viewContext
  }
    
    var timeBoxList = [TimeBox]()
    
    func isOperate()->Bool{
        let length = self.timeBoxList.count - 1
        if length > 0{
            for i in 0...length{
                if self.timeBoxList[i].startOrStop{
                    return true
                }
            }
        }
        return false
    }
    
    func fetchTimeBox() {
        let request : NSFetchRequest<TimeBox> = TimeBox.fetchRequest()
        let sortByDateDesc = NSSortDescriptor(key : "startTime", ascending : false)
        request.sortDescriptors = [sortByDateDesc]
        do{
            try timeBoxList = mainContext.fetch(request)
        }catch{
            print(error)
        }
      }
    
    func addTimeBox(_ timeTitle: String?){
        let newTimeBox = TimeBox(context : mainContext)
        newTimeBox.timeTitle = timeTitle
        newTimeBox.startTime = nil
        newTimeBox.startOrStop = false
        saveContext()
        fetchTimeBox()
    }
    
    func delTimeBox(_ timeBox: TimeBox?){
        if let timeBox = timeBox{
            mainContext.delete(timeBox)
            saveContext()
            fetchTimeBox()
        }
    }
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "multipleTimer")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

