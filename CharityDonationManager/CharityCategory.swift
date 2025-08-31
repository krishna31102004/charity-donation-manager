//
//  CharityCategory.swift
//  CharityDonationManager(CDM)
//
//  Created by Krishna Balaji on 8/26/25.
//


import Foundation

enum CharityCategory: String, CaseIterable, Identifiable {
    case all = "Charities"
    case food = "Food"
    case health = "Health"
    case education = "Education"
    case other = "Other"

    var id: String { rawValue }

    var query: String {
        switch self {
        case .all:       return "charity nonprofit"
        case .food:      return "food bank food pantry soup kitchen"
        case .health:    return "health charity hospital foundation medical nonprofit"
        case .education: return "education charity scholarship foundation tutoring nonprofit"
        case .other:     return ""
        }
    }
}
