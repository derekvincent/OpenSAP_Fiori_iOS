//
//  PersistenceManager.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import Foundation
import SAPCommon

class PersistenceManager {

    private let logger = Logger.shared(forClass: PersistenceManager.self)

    private static let userPreferencesKey = "com.sap.mobile.apps.toolkit.onboarding.OnboardingResultData"
    private let onboardingDoneKey = "com.sap.mobile.apps.toolkit.onboarding.OnboardingDone"
    private let applicationMoveToBackgroundKey = "com.sap.mobile.apps.toolkit.onboarding.AppDidEnterBackgroundDate"


    public func isOnboardingDone() -> Bool {
        return UserDefaults.standard.bool(forKey: onboardingDoneKey)
    }

    public func storeOnboardingDoneState() {
        UserDefaults.standard.set(true, forKey: onboardingDoneKey)
        UserDefaults.standard.synchronize()
    }

    public func resetOnboardingDoneState() {
        UserDefaults.standard.removeObject(forKey: onboardingDoneKey)
        UserDefaults.standard.synchronize()
    }

    public func loadOnboardingResultData() -> Data? {
        return UserDefaults.standard.data(forKey: PersistenceManager.userPreferencesKey)
    }

    public func storeOnboardingResultData(_ data: Data) {
        UserDefaults.standard.set(data, forKey: PersistenceManager.userPreferencesKey)
        UserDefaults.standard.synchronize()
    }

    public func removeAllOnboardingResultData() {
        UserDefaults.standard.removeObject(forKey: PersistenceManager.userPreferencesKey)
        UserDefaults.standard.synchronize()
    }

    public func storeAppDidMoveToBackgroundDate(_ date: Date) {
        UserDefaults.standard.set(date, forKey: applicationMoveToBackgroundKey)
        UserDefaults.standard.synchronize()
    }

    public func loadAppDidMoveToBackgroundDate() -> Date? {
        guard let nonNilDate = UserDefaults.standard.object(forKey: applicationMoveToBackgroundKey) else {
            return nil
        }

        if let date = nonNilDate as? Date {
            return date
        } else {
            logger.error("ApplicationDidEnterBackground-date is not nil but cannot be cast to Date. Returning nil.")
            return nil
        }
    }
}
