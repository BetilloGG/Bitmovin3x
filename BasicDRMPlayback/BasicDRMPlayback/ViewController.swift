//
// Bitmovin Player iOS SDK
// Copyright (C) 2021, Bitmovin GmbH, All Rights Reserved
//
// This source code and its use and distribution, is subject to the terms
// and conditions of the applicable license agreement.
//

import UIKit
import BitmovinPlayer

class ViewController: UIViewController {
    var player: Player!

    deinit {
        player?.destroy()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .black

        /**
         * TODO: Add URLs below to make this sample application work.
         */
        // Define needed resources
        //
        guard let fairplayStreamUrl = URL(string: "https://hlscf.cinepolisklic.com/usp-s3-storage/clear/peter-rabbit-conejos-en-fuga/peter-rabbit-conejos-en-fuga_fp.ism/.m3u8"),
              let certificateUrl = URL(string: "https://lic.drmtoday.com/license-server-fairplay/cert/cinepolis"),
              let licenseUrl = URL(string: "https://lic.drmtoday.com/license-server-fairplay/") else {
            print("Please specify the needed resources marked with TODO in ViewController.swift file.")
            return
        }

        // Create player configuration
        let config = PlayerConfig()
        config.styleConfig.userInterfaceType = .bitmovin
        config.playbackConfig.isAutoplayEnabled = true

        // Create player based on player configuration
        player = PlayerFactory.create(playerConfig: config)

        // Create player view and pass the player instance to it
        let playerView = PlayerView(player: player, frame: .zero)

        // Listen to player events
        player.add(listener: self)

        playerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        playerView.frame = view.bounds

        view.addSubview(playerView)
        view.bringSubviewToFront(playerView)

        // create drm configuration
        let fpsConfig = FairplayConfig(license: licenseUrl, certificateURL: certificateUrl)

        // Example of how certificate data can be prepared if custom modifications are needed
        fpsConfig.prepareLicense = { (data: Data) -> Data in
            guard let certString = String(data: data, encoding: .utf8),
                  let certResult = Data(base64Encoded: certString.replacingOccurrences(of: "\"", with: "")) else {
                return data
            }
            return certResult
        }

        let base64 = self.prepareHeaderKlic()
       fpsConfig.licenseRequestHeaders = ["x-dt-custom-data": base64]
      // fpsConfig.certificateRequestHeaders = ["dt-custom-data": base64]


        fpsConfig.prepareContentId = { (contentId: String) -> String in
            print("contentId: \(contentId)")
            let pattern = "skd://drmtoday?"
            let contentId = String(contentId[pattern.endIndex...])
            print("contentId: \(contentId)")
            return contentId
        }

        fpsConfig.prepareMessage = { (data: Data, contentId: String) -> Data in
           let base64String = data.base64EncodedString()
           guard let uriEncodedMessage =
               base64String.addingPercentEncoding(withAllowedCharacters:
                   CharacterSet.alphanumerics) else { return Data() }
           let message = "spc=\(uriEncodedMessage)&\(contentId)"
           if let dataMessage = message.data(using: String.Encoding.utf8) {
               return dataMessage
           } else {
               return Data()
           }
       }

        fpsConfig.certificateUrl = certificateUrl

        let sourceConfig = SourceConfig(url: fairplayStreamUrl, type: .hls)
        sourceConfig.drmConfig = fpsConfig

        player.load(sourceConfig: sourceConfig)
    }
}

extension ViewController {

    func prepareHeaderKlic() -> String  {
        let userData = #"{"sessionId":"XkcxR0hNcZ","userId":"11514946","merchant":"cinepolis"}"#
        let data = (userData).data(using: String.Encoding.utf8)
        return data!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    }
}
extension ViewController: PlayerListener {
    func onEvent(_ event: Event, player: Player) {
        dump(event, name: "[Player Event]", maxDepth: 1)
    }
}
