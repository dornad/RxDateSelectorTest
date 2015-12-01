//
//  TimeZoneConstants.swift
//  Test
//
//  Created by Daniel Rodriguez on 12/1/15.
//  Copyright © 2015 PaperlessPost. All rights reserved.
//

import UIKit

protocol Enumeratable {
    
    static var allValues:[Self] { get }
}

protocol TimeZoneEnum : Enumeratable {
    
    // Properties
    func getTimeZoneName() -> String
    func getTimeZoneLabel() -> String
    
    // Transformation
    func getTimeZone() -> NSTimeZone?
}

struct TimeZoneConstants {
    
    enum AmericaTimeZones: TimeZoneEnum {
        
        case Alaska, CentralTime, EasternTime, MountainTime, PacificTime
        
        static let allValues:[AmericaTimeZones] = [Alaska, CentralTime, EasternTime, MountainTime, PacificTime]
        
        func getTimeZoneName() -> String {
            switch self {
            case Alaska:        return "America/Juneau"
            case CentralTime:   return "America/Chicago"
            case EasternTime:   return "America/New_York"
            case MountainTime:  return "America/Denver"
            case PacificTime:   return "America/Los_Angeles"
            }
        }
        
        func getTimeZoneLabel() -> String {
            switch self {
            case CentralTime:   return "Central Time (US & Canada)"
            case EasternTime:   return "Eastern Time (US & Canada)"
            case MountainTime:  return "Mountain Time (US & Canada)"
            case PacificTime:   return "Pacific Time (US & Canada)"
            case Alaska:        return "Alaska"
            }
        }
        
        func getTimeZone() -> NSTimeZone? {
            let timezoneName = self.getTimeZoneName()
            let timezone = NSTimeZone(name: timezoneName)
            return timezone
        }
    }
    
    enum UnitedKingdomTimeZones: TimeZoneEnum {
        case London
        static let allValues:[UnitedKingdomTimeZones] = [London]
        
        func getTimeZoneName() -> String {
            switch self {
            case London: return "Europe/London"
            }
        }
        
        func getTimeZoneLabel() -> String {
            switch self {
            case .London: return "London"
            }
        }
        
        func getTimeZone() -> NSTimeZone? {
            let timezone = NSTimeZone(name: self.getTimeZoneName())
            return timezone
        }
    }
    
    enum OtherTimeZones : TimeZoneEnum {
        case AbuDhabi, Adelaide, Athens, AtlanticTime, Auckland, Bangkok, BuenosAires, CapeVerdeIsland, Caracas, Dhaka, Hawaii, HongKong, Islamabad, Kabul, Kathmandu, MidAtlantic, Moscow, NewCaledonia, NewDelhi, Newfoundland, Nukualofa, Paris, Rangoon, Samoa, Sydney, Tehran, Tokyo
        
        static let allValues = [AbuDhabi, Adelaide, Athens, AtlanticTime, Auckland, Bangkok, BuenosAires, CapeVerdeIsland, Caracas, Dhaka, Hawaii, HongKong, Islamabad, Kabul, Kathmandu, MidAtlantic, Moscow, NewCaledonia, NewDelhi, Newfoundland, Nukualofa, Paris, Rangoon, Samoa, Sydney, Tehran, Tokyo]
        
        func getTimeZoneName() -> String {
            switch self {
            case AbuDhabi:          return "Asia/Muscat"
            case Adelaide:          return "Australia/Adelaide"
            case Athens:            return "Europe/Athens"
            case AtlanticTime:      return "America/Halifax"
            case Auckland:          return "Pacific/Auckland"
            case Bangkok:           return "Asia/Bangkok"
            case BuenosAires:       return "America/Argentina/Buenos_Aires"
            case CapeVerdeIsland:   return "Atlantic/Cape_Verde"
            case Caracas:           return "America/Caracas"
            case Dhaka:             return "Asia/Dhaka"
            case Hawaii:            return "Pacific/Honolulu"
            case HongKong:          return "Asia/Hong_Kong"
            case Islamabad:         return "Asia/Karachi"
            case Kabul:             return "Asia/Kabul"
            case Kathmandu:         return "Asia/Kathmandu"
            case MidAtlantic:       return "Atlantic/South_Georgia"
            case Moscow:            return "Europe/Moscow"
            case NewCaledonia:      return "Pacific/Noumea"
            case NewDelhi:          return "Asia/Kolkata"
            case Newfoundland:      return "America/St_Johns"
            case Nukualofa:         return "Pacific/Tongatapu"
            case Paris:             return "Europe/Paris"
            case Rangoon:           return "Asia/Rangoon"
            case Samoa:             return "Pacific/Apia"
            case Sydney:            return "Australia/Sydney"
            case Tehran:            return "Asia/Tehran"
            case Tokyo:             return "Asia/Tokyo"
            }
        }
        
        func getTimeZoneLabel() -> String {
            switch self {
            case AbuDhabi:          return "Abu Dhabi"
            case Adelaide:          return "Adelaide"
            case Athens:            return "Athens"
            case AtlanticTime:      return "Atlantic Time (Canada)"
            case Auckland:          return "Auckland"
            case Bangkok:           return "Bangkok"
            case BuenosAires:       return "Buenos Aires"
            case CapeVerdeIsland:   return "Cape Verde Is."
            case Caracas:           return "Caracas"
            case Dhaka:             return "Dhaka"
            case Hawaii:            return "Hawaii"
            case HongKong:          return "Hong Kong"
            case Islamabad:         return "Islamabad"
            case Kabul:             return "Kabul"
            case Kathmandu:         return "Kathmandu"
            case MidAtlantic:       return "Mid-Atlantic"
            case Moscow:            return "Moscow"
            case NewCaledonia:      return "New Caledonia"
            case NewDelhi:          return "New Delhi"
            case Newfoundland:      return "Newfoundland"
            case Nukualofa:         return "Nuku'alofa"
            case Paris:             return "Paris"
            case Rangoon:           return "Rangoon"
            case Samoa:             return "Samoa"
            case Sydney:            return "Sydney"
            case Tehran:            return "Tehran"
            case Tokyo:             return "Tokyo"
            }
        }
        
        func getTimeZone() -> NSTimeZone? {
            let timezone = NSTimeZone(name: self.getTimeZoneName())
            return timezone
        }
    }
}
