//
//  AGStudent.swift
//  AGUniversityModel
//
//  Created by Admin on 09.01.2021.
//  Copyright © 2021 AlexGermek. All rights reserved.
//

import UIKit

class AGStudent: NSObject {
    //Random parameters:
    private let firstNames = ["Alex","Bob","Max", "Susan","Mary","Katy"]
    
    private let lastNames  = ["Mask","Smith","Marley", "Trump", "Baiden","Lee"]
    
    private let cars       = ["BWM", "Mercedes", "Toyota", "Hundai", "Mitsubishi", "Reno"]
    
    private let namesCount = 6
    
    
    //Student properties:
    var firstName = ""
    var lastName  = ""
    var fullname: String{
        return firstName + " " + lastName
    }
    
    var email       = ""
    var pathToPhoto = ""
    var car         = ""
    var averageGrade: CGFloat = 0
    
    func randomStudent() -> AGStudent {
        let student = AGStudent()
        
        student.firstName = firstNames.shuffled()[0]
        student.lastName  = lastNames.shuffled()[0]
        
        let randomBall = (CGFloat(arc4random() % 301 + 200)) / 100 //2..5
        student.averageGrade = randomBall
        
        
        student.email = getEmail(fromFirstName: student.firstName, andLastName: student.lastName)
        
        //Path to photo: for boys: student1,student2,student3     for girls: student4,student5,student6
        let photoNumber = firstNames.firstIndex{$0 == student.firstName}! < 3 ? Int.random(in: 1...3) : Int.random(in: 4...6)
        student.pathToPhoto = "student\(photoNumber)"
        
        student.car = cars.shuffled()[0]
        
        return student
    }
    
    func getEmail(fromFirstName firstName: String, andLastName lastName: String) -> String{
        let fullName = firstName + lastName
        let email = fullName.replacingOccurrences(of: " ", with: "").lowercased() + "@gmail.com"
        
        return email
    }
}


