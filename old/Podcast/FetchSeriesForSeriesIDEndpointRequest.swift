//
//  SeriesbySeriesIdEndpointRequest.swift
//  Podcast
//
//  Created by Natasha Armbrust on 3/30/17.
//  Copyright © 2017 Cornell App Development. All rights reserved.
//

import UIKit
import SwiftyJSON

class FetchSeriesForSeriesIDEndpointRequest: EndpointRequest {
    
    var seriesID: String
    
    init(seriesID: String) {
        self.seriesID = seriesID
        super.init()
        path = "/podcasts/series/" + seriesID
        httpMethod = .get
    }
    
    override func processResponseJSON(_ json: JSON) {
        processedResponseValue = Series(json: json["data"]["series"])
    }
}
