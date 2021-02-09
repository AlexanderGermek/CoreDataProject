//
//  CoreDataFunctions.swift
//  123123123
//
//  Created by iMac on 09.02.2021.
//  Copyright © 2021 AlexGermek. All rights reserved.
//

import UIKit
import CoreData

// 1. Load Students from Core Data (from Disk):
func loadGroupsFromCoreData() -> [AGGroup] {
    var groupsArray: [AGGroup] = []
    //1
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return groupsArray}
    let managedContext    = appDelegate.persistentContainer.viewContext

    //2 Фэтч запросом отбираем данные. Можно устанавливать различные критерии для запросов.
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Group") //NSFetchRequest<NSManagedObject>(entityName: "Person")

    //3
    do{
        let managedGroups = try managedContext.fetch(fetchRequest)
        for managedGroup in managedGroups{
            let group = AGGroup()
            group.name     = (managedGroup.value(forKey: "name") as? String)!
            
            let managedStudents = managedGroup.value(forKey: "student") as! NSMutableSet
            
            
            for managedStudent in managedStudents{
                let student = AGStudent()
                student.firstName = (managedStudent as! NSObject).value(forKey: "firstName") as! String
                student.lastName = (managedStudent as! NSObject).value(forKey: "lastName") as! String
                student.email = (managedStudent as! NSObject).value(forKey: "email") as! String
                student.pathToPhoto = (managedStudent as! NSObject).value(forKey: "pathToPhoto") as! String
                student.car = (managedStudent as! NSObject).value(forKey: "car") as! String
                student.averageGrade = (managedStudent as! NSObject).value(forKey: "averageGrade") as! CGFloat
                
                group.students.append(student)
            }

            groupsArray.append(group)
        }
    } catch let error as NSError{
       print("Couldn't fetch. \(error), \(error.userInfo)")
    }
    
    return groupsArray
    
}


// 2. Save Students in Core Data:
func saveStudents(groups: [AGGroup]) {
    
    //1 Сначала получаем контекст нашего приложения. Он автоматически создается если ставить флажок использовать кор дату при создании приложения
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}

    let managedContext = appDelegate.persistentContainer.viewContext
    

    //2 Создаем сущность entity, которая связывает наш объект Студент из CoreData с экземпляром Контекста. Затем создаем объект и помещаем его в Контекст
    for group in groups{
        
        let entityGroup   = NSEntityDescription.entity(forEntityName: "Group", in: managedContext)!
        let groupMO       = NSManagedObject(entity: entityGroup, insertInto: managedContext)
        
        groupMO.setValue(group.name, forKey: "name")
        
        for student in group.students{
            
            let entityStudent = NSEntityDescription.entity(forEntityName: "Student", in: managedContext)!
            let studentMO     = NSManagedObject(entity: entityStudent, insertInto: managedContext)
            
            studentMO.setValue(student.firstName, forKey: "firstName")
            studentMO.setValue(student.lastName, forKey:  "lastName")
            studentMO.setValue(student.email, forKey:     "email")
            studentMO.setValue(student.pathToPhoto, forKey:  "pathToPhoto")
            studentMO.setValue(student.car, forKey:  "car")
            studentMO.setValue(student.averageGrade, forKey:  "averageGrade")
            studentMO.setValue(groupMO, forKey: "group")
            
        }

         //4 Сохраняем на диск данные
         do{
             try managedContext.save()
         } catch let error as NSError{
             print("Couldn't save. \(error), \(error.userInfo)")
         }
    }
}


// 3. Delete all data from CoreData:
func resetAllCoreData() {

     //Get all entities and loop over them
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
    let managedContext    = appDelegate.persistentContainer.viewContext
    
     let entityNames = appDelegate.persistentContainer.managedObjectModel.entities.map({ $0.name!})
     entityNames.forEach { entityName in
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

        do {
            try managedContext.execute(deleteRequest)
            try managedContext.save()
        } catch let error as NSError{
            print("Couldn't delete. \(error), \(error.userInfo)")
        }
    }
}
