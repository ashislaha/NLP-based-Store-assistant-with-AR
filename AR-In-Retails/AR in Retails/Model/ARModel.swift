//
//  ARModel.swift
//  AR in Retails
//
//  Created by Ashis Laha on 5/31/18.
//  Copyright © 2018 Ashis Laha. All rights reserved.
//

import Foundation

enum ProductDepartment: String {
    case fruits
    case packagedFoods // noodles, pasta, breakfast cereals
    case personalAndBabyCare // soap, body wash, hair care etc.
    case householdCare // detergent, laundry etc.
    case dairyAndEggs // milk, eggs,
    case electronics // mobile, computers, tvs etc.
    case fashion // dresses for men, women, kids
    case sports // sports necessities like bat, ball, rackets etc.
    case books // book stall
    case shoes
    case bags
    case groceries
    case utensils
}

/**
    user position will be filled by estimote skd once user is inside the store. this is variable once user moves around the store
    departmentsPosition will be filled by the store plan. this is most of the time static.
 **/

struct ARModel {
    var userPosition: CGPoint
    let departmentsPosition: [ProductDepartment: CGPoint] // dictionary which says "fruits": "(50,70)" position
}
