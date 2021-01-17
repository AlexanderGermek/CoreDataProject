//
//  ViewController.swift
//  AGUniversityModel
//
//  Created by Admin on 09.01.2021.
//  Copyright © 2021 AlexGermek. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var myTableView: UITableView!

    var groupsArray: [AGGroup] = []
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadDataFromCoreData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //ВАЖНО зарегистрировать обычную ячейку при использовании кастомной!!!
        self.myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.myTableView.reloadData()
        self.myTableView.backgroundColor = .orange
    }

    //MARK: Actions
    //Then push Add student:
    @IBAction func addNewGroup(_ sender: Any) {
        
        let group = AGGroup()
        group.name = "Group # \(self.groupsArray.count + 1)"
        
        let newStudents = [AGStudent().randomStudent(), AGStudent().randomStudent()]
        group.students.append(contentsOf: newStudents)
        
        let newSectionIndex = 0
        self.groupsArray.insert(group, at: newSectionIndex)
        
        self.myTableView.beginUpdates()
        let insertSections  = IndexSet.init(integer: newSectionIndex)
        self.myTableView.insertSections(insertSections, with: .left)
        self.myTableView.endUpdates()
        
        //old version:
//        let alert = UIAlertController(title: "New student", message: "Add a new student", preferredStyle: .alert)
//
//        let saveAction = UIAlertAction(title: "Add Student", style: .default) { [unowned self] action in
//            guard let textField = alert.textFields?.first, let nameToSave = textField.text,
//                let textField2 = alert.textFields?[1], let pathToPhoto = textField2.text
//                else { return}
//
//            self.saveStudent(name: nameToSave, pathToPhoto: pathToPhoto)
//            self.myTableView.reloadData()
//        }
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//
//
//        alert.addTextField { (textField : UITextField!) -> Void in
//            textField.placeholder = "enter the name..."
//        }
//
//        alert.addTextField { (textField : UITextField!) -> Void in
//            textField.placeholder = "enter student1...student6"
//        }
//
//        alert.addAction(saveAction)
//        alert.addAction(cancelAction)
//        present(alert, animated: true)
    }
    
    //Info about the student:
    @IBAction func studentInfoAction(_ sender: UIButton) {
        
        let cell = getStudentCell(infoView: sender) as? AGStudentCell
        
                if cell != nil{
                    let path = self.myTableView.indexPath(for: cell!)!
                    
                    let group   = self.groupsArray[path.section]
                    let student = group.students[path.row - 1]
                    
                    let name  = cell?.nameLabel.text
                    let email = cell?.emailLabel.text
                    let textMessage = "Hello, my name is \(name ?? "") !"
                    let textEmail = "My email is: \(email ?? "")"
                    let textCarAndGrade   = "Car: \(student.car) \n" + "Average grade: " + String(format: "%.2f",student.averageGrade)
                    
                    let textConst = "I'm a senior at Michigan Technological University, majoring in biomedical engineering. Ever since I was a kid, I've wanted to work in the field of prosthetics. I'm drawn to prosthetic design and research, which is why I'm so excited to learn more about the internship your company is offering."
                    
                    let studentMessage = textMessage + "\n" + textConst + "\n" + textEmail + "\n" + textCarAndGrade

                    let alert = UIAlertController(title: "Info \(name ?? "")", message: studentMessage, preferredStyle: .alert)

                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)

                    let imgTitle = cell!.studentPhotoImageView?.image// UIImage(named:"imgTitle.png")
                    let imgViewTitle = UIImageView(frame: CGRect(x: 5, y: 5, width: 40, height: 40))
                    imgViewTitle.image = imgTitle

                    alert.view.addSubview(imgViewTitle)
                    alert.addAction(action)
                    
                    self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func saveInCoreData(_ sender: UIBarButtonItem) {
        resetAllCoreData()
        saveStudents(groups: self.groupsArray)
        
        let alertController = UIAlertController(title: "Core Data", message: "Saving in Core Data complete!", preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            //  Do some action here.
        })
        
        alertController.addAction(defaultAction)
//
//        alertController.popoverPresentationController?.sourceView = self.myTableView
//        alertController.popoverPresentationController?.barButtonItem = sender
////        if let popoverController = alertController.popoverPresentationController {
////            popoverController.barButtonItem = sender
////            popoverController.delegate = self
//////            popoverController.sourceView = self.myTableView
//////            popoverController.sourceRect = CGRect(x: self.view.bounds.minX, y: self.view.bounds.minY, width: 200, height: 200)
////        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func editActionBarButton(_ sender: UIBarButtonItem) {
        actionEdit(sender: sender)
    }
    
    @objc func actionEdit(sender: UIBarButtonItem){
        let isEdit = self.myTableView.isEditing
        self.myTableView.setEditing(!isEdit, animated: true)
        
        let item = !isEdit ? UIBarButtonItem.SystemItem.done : UIBarButtonItem.SystemItem.edit
        
        let editOrDoneButton = UIBarButtonItem.init(barButtonSystemItem: item, target: self, action:  #selector(actionEdit(sender:)))
        self.navigationItem.setRightBarButton(editOrDoneButton, animated: true)
    }
    
    
    //MARK: My functions
    //Get parent-cell after the push InfoButton:
    func getStudentCell(infoView: UIView) -> UITableViewCell? {

     if  infoView.superview == nil{
            return nil
        }

     let flag = infoView.superview?.isKind(of: AGStudentCell.self)
        if flag == false{
            return getStudentCell(infoView: infoView.superview!)
        }else{
           return infoView.superview as? AGStudentCell
        }

    }

    //Save student in Core Data:
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

    //Load Students from Core Data (from Disk):
    func loadDataFromCoreData(){
        //1
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
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

                self.groupsArray.append(group)
            }
        } catch let error as NSError{
           print("Couldn't fetch. \(error), \(error.userInfo)")
        }
    }
    
    //Delete all data from CoreData:
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
    
}//ViewController



//MARK: extension ================================================================
extension ViewController: UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate {

    
     //0. UIPopoverPresentationControllerDelegate method
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        // Убираем полноэкранный режим:
        return .none
    }
    
    
    // 1. Общее число секций:
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.groupsArray.count
    }
    
    
    // 2. Число строк в секции:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groupsArray[section].students.count + 1
    }

    
    // 3. Заголовок для секции:
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return self.groupsArray[section].name
        }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(50)
    }
    
    
    // 4. Установка цвета вью для Заголовка:
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = .black
        header.contentView.contentMode = .center
        header.textLabel?.textColor        = .white
        header.textLabel?.textAlignment    = .center
        //header.backgroundView?.backgroundColor = .black
        //header.textLabel?.font = UIFont(name: "Helvetica-Bold", size: 14)
    }
    
    
    // 5. Создание ячейки для секции и строки:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == 0 {
                    let addGroupIdentifier = "addcell_code"
                    var cell = tableView.dequeueReusableCell(withIdentifier: addGroupIdentifier)
                    
                    if (cell == nil){
                        cell = UITableViewCell.init(style: .default, reuseIdentifier: addGroupIdentifier)
                        cell?.textLabel?.textColor = .black
                        cell?.textLabel?.text = "+ Add New Student"
                        cell?.textLabel?.font = UIFont.boldSystemFont(ofSize: 18.0)
                        cell?.backgroundColor = .orange
                    }
                    
                    return cell!
                    
                } else {
            
                    let studentIdentifier = "studentcell"
                    let cell = tableView.dequeueReusableCell(withIdentifier: studentIdentifier, for: indexPath) as! AGStudentCell
                    
                    
                    let group = self.groupsArray[indexPath.section]
                    let student = group.students[indexPath.row - 1]
                    
                    cell.nameLabel?.text = "\(student.firstName) \(student.lastName)"
                    cell.emailLabel?.text = student.email
            

                    if let filePath = Bundle.main.path(forResource: student.pathToPhoto, ofType: "jpg"), let image = UIImage(contentsOfFile: filePath) { cell.studentPhotoImageView?.image = image }
                    
                    cell.backgroundColor = .orange
                    return cell
                }
        
    }
    
    
    // 6. Высота строки (ячейки):
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return CGFloat(40)
        } else {
            return CGFloat(80)
        }
    }
    

    // 7. Обработка нажатий delete,insert - удаление студента из группы:
       func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
           if editingStyle == .delete{
               let group = self.groupsArray[indexPath.section]
               group.students.remove(at: indexPath.row - 1)
               
               self.myTableView.beginUpdates()
               self.myTableView.deleteRows(at: [indexPath], with: .right)
               self.myTableView.endUpdates()
           }
       }
    
    
    // 8. Была выделена ячейка/ Вставка нового студентав группу:
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.myTableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            let group = self.groupsArray[indexPath.section]
            var tempArray = group.students
            let newStudentIndex = 0
            
            tempArray.insert(AGStudent().randomStudent(), at: newStudentIndex)
            
            group.students = tempArray
            
            self.myTableView.beginUpdates()
            let newIndexPath = [IndexPath.init(item: newStudentIndex + 1, section: indexPath.section)]
            self.myTableView.insertRows(at: newIndexPath, with: .left)
            self.myTableView.endUpdates()
        }
    }
    
    
    // 9. Стиль кнопки которая слева(удаление вставка) в состоянии isEditing:
     func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
         return indexPath.row == 0 ? .insert : .delete
     }
    
    
    // 10. Обрабатываем перенос из индекса в индекс:
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if proposedDestinationIndexPath.row == 0 {
            return sourceIndexPath
        } else {
           return proposedDestinationIndexPath
        }
    }
    
    // 11. Обрабатываем из какого индекса можно двигать ячейку:
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row > 0
    }
    
    // 12. При перемещении ячейки из индекса в индекс:
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceGroup = self.groupsArray[sourceIndexPath.section]
        let student     = sourceGroup.students[sourceIndexPath.row - 1]
        
        var tempStudents = sourceGroup.students
        
        if sourceIndexPath.section == destinationIndexPath.section{
            tempStudents.swapAt(sourceIndexPath.row - 1, destinationIndexPath.row - 1)
            sourceGroup.students = tempStudents
        } else {
            tempStudents.remove(at: sourceIndexPath.row - 1)
            sourceGroup.students = tempStudents
            
            let destinationGroup = self.groupsArray[destinationIndexPath.section]
            tempStudents = destinationGroup.students
            tempStudents.insert(student, at: destinationIndexPath.row - 1)
            destinationGroup.students = tempStudents
            
        }
    }
    
}
//extension ================================================================

