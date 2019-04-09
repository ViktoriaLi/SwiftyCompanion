//
//  StudentModel.swift
//  Swifty companion
//
//  Created by Viktoriia LIKHOTKINA on 2/8/19.
//  Copyright © 2019 Viktoriia LIKHOTKINA. All rights reserved.
//

import Foundation

enum HeaderStatus {
    case open, close, empty
}

struct Student : Decodable {
    
    var firstName : String
    var lastName : String
    var phoneNumber : String?
    var email : String
    var login : String
    var staff : Bool
    var imageUrl : URL
    var cursusUsers : [CursusUsers]?
    var projects : [Project]
    
    var validatedProjects : [Project]? = [Project]()
    
    struct ProjectName : Decodable {
        var parent_id : Int?
        var id : Int
        var name : String
        
        enum ProjectKeys: String, CodingKey {
            case name = "name"
            case id = "id"
            case parent_id
        }
    }
    
    struct Project : Decodable {
        var status : String
        var finalMark : Int?
        var validated : Bool?
        var projectNameStruct : ProjectName
        var cursus_ids : [Int]
        var childProjects = [Project]()
        var headerStatus: HeaderStatus = .empty
        
        enum CodingKeys: String, CodingKey {
            case status = "status"
            case finalMark = "final_mark"
            case validated = "validated?"
            case cursus_ids = "cursus_ids"
            case projectNameStruct = "project"
        }
    }
    
    struct Skill : Decodable {
        
        var skillName : String
        var skillLevel : Double
        
        enum CodingKeys: String, CodingKey {
            case skillName = "name"
            case skillLevel = "level"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case phoneNumber = "phone"
        case email = "email"
        case login = "login"
        case projects = "projects_users"
        case imageUrl = "image_url"
        case cursusUsers = "cursus_users"
        case staff = "staff?"
    }
    
    struct CursusUsers : Decodable {
        var skills : [Skill]
        var grade : String?
        var level : Double
        
        enum SkillCodingKeys: String, CodingKey {
            case skills = "skills"
            case grade = "grade"
            case level = "level"
        }
    }
}
