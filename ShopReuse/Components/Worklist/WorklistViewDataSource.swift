//
//  WorklistViewDataSource.swift
//  Shop
//
//  Copyright © 2017 SAP SE or an SAP affiliate company. All rights reserved.
//  Use of this software subject to the End User License Agreement located in /src/EULA.pdf
//

import Foundation
import UIKit

public protocol WorklistViewDataSource {

    func worklistView(_ worklistView: WorklistView, didUpdateItemQuantity: Int, for cell: WorklistCell, atRow indexPath: IndexPath)
    func worklistView(_ worklistView: WorklistView, for cell: WorklistCell, atRow indexPath: IndexPath,
                      imageCompletionHandler: @escaping (UIImage?) -> Void)
    func worklistView(_ worklistView: WorklistView, deleteRowAt indexPath: IndexPath, completionHandler: @escaping (_ deleteRow: Bool) -> Void)
    func numberOfRows(in worklistView: WorklistView) -> Int
}
