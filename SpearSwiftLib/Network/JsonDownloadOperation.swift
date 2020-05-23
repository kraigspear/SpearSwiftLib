//
// Created by Kraig Spear on 6/3/17.
// Copyright (c) 2017 spearware. All rights reserved.
//

import Foundation

/// Class that downloading JSON from the network.
public final class JsonDownloadOperation: NetworkDownloadOperation<JsonKeyValue> {
    /**
     Initialize with a request
     **/
    public override init(requestBuilder: RequestBuildable,
                         urlSession: URLSession) {
        super.init(requestBuilder: requestBuilder,
                   urlSession: urlSession)
    }

    public override func convertTo(_ data: Data) -> JsonKeyValue? {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? JsonKeyValue
            return json
        } catch {
            self.error = error
            return nil
        }
    }
}
