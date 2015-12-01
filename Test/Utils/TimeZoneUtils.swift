//
//  TimeZoneUtils.swift
//  Test
//
//  Created by Daniel Rodriguez on 12/1/15.
//  Copyright © 2015 PaperlessPost. All rights reserved.
//

import UIKit

struct TimeZoneUtils {
    
    static func NSTimeZoneFromLabel(label:String) -> NSTimeZone? {
        
        for value in TimeZoneConstants.AmericaTimeZones.allValues {
            if value.getTimeZoneLabel() == label {
                return value.getTimeZone()
            }
        }
        for value in TimeZoneConstants.UnitedKingdomTimeZones.allValues {
            if value.getTimeZoneLabel() == label {
                return value.getTimeZone()
            }
        }
        for value in TimeZoneConstants.OtherTimeZones.allValues {
            if value.getTimeZoneLabel() == label {
                return value.getTimeZone()
            }
        }
        
        return nil
    }
    
    static func TimeZoneLabelFromNSTimeZone(timezone:NSTimeZone) -> String? {
        
        for value in TimeZoneConstants.AmericaTimeZones.allValues {
            if value.getTimeZone()?.name == timezone.name {
                return value.getTimeZoneLabel()
            }
        }
        for value in TimeZoneConstants.UnitedKingdomTimeZones.allValues {
            if value.getTimeZone()?.name == timezone.name {
                return value.getTimeZoneLabel()
            }
        }
        for value in TimeZoneConstants.OtherTimeZones.allValues {
            if value.getTimeZone()?.name == timezone.name {
                return value.getTimeZoneLabel()
            }
        }
        return nil
    }
    
    
}

extension NSTimeZone {
    
    func getLabel() -> String {        
        return TimeZoneUtils.TimeZoneLabelFromNSTimeZone(self) ?? ""
    }
}
