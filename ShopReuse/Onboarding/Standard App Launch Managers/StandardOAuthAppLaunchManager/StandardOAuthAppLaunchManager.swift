//
//  StandardOAuthAppLaunchManager.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import UIKit
import SAPFiori
import SAPCommon
import SAPFoundation

public class StandardOAuthAppLaunchManager: AppLaunchManager<StandardOAuthFlow, StandardLoginFlow> {

    // Application HAS to override this!
    public override func onboardingFlowForApplication(_ application: UIApplication) -> StandardOAuthFlow {
        return StandardOAuthFlow()
    }

    // Application HAS to override this!
    public override func loginFlowForApplication(_ application: UIApplication, withOnboardingResult result: StandardOAuthFlowResult?) -> StandardLoginFlow? {

        ConnectionManager.shared.onboardingResult = result
        // prepare and launch the login flow.
        if let authManager = ConnectionManager.shared.authManager, let connectionParameter = ConnectionManager.shared.connectionParameters {
            let inputParameters = StandardLoginFlow.InputParams(sapUrlSession: SAPURLSession(configuration: .ephemeral), authManager: authManager, connectionParameters: connectionParameter)
            return StandardLoginFlow(inputParams: inputParameters)
        }
        return nil
    }
}
