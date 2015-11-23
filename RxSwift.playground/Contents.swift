//: Playground - noun: a place where people can play

import UIKit
import XCPlayground
import SnapKit

let managedTimeZones: [String : NSTimeZone?] = [
    "Abu Dhabi":                    NSTimeZone(name:"Asia/Muscat"),
    "Adelaide":                     NSTimeZone(name:"Australia/Adelaide"),
    "Alaska":                       NSTimeZone(name:"America/Juneau"),
    "Athens":                       NSTimeZone(name:"Europe/Athens"),
    "Atlantic Time (Canada)":       NSTimeZone(name:"America/Halifax"),
    "Auckland":                     NSTimeZone(name:"Pacific/Auckland"),
    "Bangkok":                      NSTimeZone(name:"Asia/Bangkok"),
    "Buenos Aires":                 NSTimeZone(name:"America/Argentina/Buenos_Aires"),
    "Cape Verde Is.":               NSTimeZone(name:"Atlantic/Cape_Verde"),
    "Caracas":                      NSTimeZone(name:"America/Caracas"),
    "Central Time (US & Canada)":   NSTimeZone(name:"America/Chicago"),
    "Dhaka":                        NSTimeZone(name:"Asia/Dhaka"),
    "Eastern Time (US & Canada)":   NSTimeZone(name:"America/New_York"),
    "Hawaii":                       NSTimeZone(name:"Pacific/Honolulu"),
    "Hong Kong":                    NSTimeZone(name:"Asia/Hong_Kong"),
    "Islamabad":                    NSTimeZone(name:"Asia/Karachi"),
    "Kabul":                        NSTimeZone(name:"Asia/Kabul"),
    "Kathmandu":                    NSTimeZone(name:"Asia/Kathmandu"),
    "London":                       NSTimeZone(name:"Europe/London"),
    "Mid-Atlantic":                 NSTimeZone(name:"Atlantic/South_Georgia"),
    "Moscow":                       NSTimeZone(name:"Europe/Moscow"),
    "Mountain Time (US & Canada)":  NSTimeZone(name:"America/Denver"),
    "New Caledonia":                NSTimeZone(name:"Pacific/Noumea"),
    "New Delhi":                    NSTimeZone(name:"Asia/Kolkata"),
    "Newfoundland":                 NSTimeZone(name:"America/St_Johns"),
    "Nuku'alofa":                   NSTimeZone(name:"Pacific/Tongatapu"),
    "Pacific Time (US & Canada)":   NSTimeZone(name:"America/Los_Angeles"),
    "Paris":                        NSTimeZone(name:"Europe/Paris"),
    "Rangoon":                      NSTimeZone(name:"Asia/Rangoon"),
    "Samoa":                        NSTimeZone(name:"Pacific/Apia"),
    "Sydney":                       NSTimeZone(name:"Australia/Sydney"),
    "Tehran":                       NSTimeZone(name:"Asia/Tehran"),
    "Tokyo":                        NSTimeZone(name:"Asia/Tokyo")
];

let foo: NSTimeZone? = managedTimeZones["Alaska"]!

enum TimeZonePickerErrors : ErrorType {
    case NameInvalid
    case NotFound(message:String)
}

func getTimezoneFromLabel( label: String ) throws -> NSTimeZone
{
    for (timezoneName, timezone) in managedTimeZones {
        
        if timezoneName == label {
            return timezone!
        }
    }
    
    throw TimeZonePickerErrors.NotFound(message: "")
}

func getTimezoneLabel( tz : NSTimeZone ) throws -> String {
    
    for (timezoneLabel, timezone) in managedTimeZones {
        if let timezone = timezone {
            if timezone.name == tz.name {
                return timezoneLabel
            }
        }
        else {
            throw TimeZonePickerErrors.NameInvalid
        }
    }
    throw TimeZonePickerErrors.NotFound(message: "")
}

let current = NSTimeZone.localTimeZone()

do {
    let label = try getTimezoneLabel(current)
    let timeZone = try getTimezoneFromLabel(label)
}
catch TimeZonePickerErrors.NameInvalid {
    print("The NSTimeZone stored inside managedTimeZones is not a valid NSTimeZone name.")
}
catch TimeZonePickerErrors.NotFound(let message) {
    print("oh noes... here's the message: \(message)")
}


