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
    case groceries
    case shoes
    case fashion 
    case laptops
    case mobiles
}

/**
    user position will be filled by estimote skd once user is inside the store. this is variable once user moves around the store
    departmentsPosition will be filled by the store plan. this is most of the time static.
 **/

struct ARModel {
    var userPosition: CGPoint
    let departmentsPosition: [ProductDepartment: CGPoint] // dictionary which says "fruits": "(50,70)" position
}
