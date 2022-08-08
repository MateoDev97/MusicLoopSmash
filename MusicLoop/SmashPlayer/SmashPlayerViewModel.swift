//
//  SmashPlayerViewModel.swift
//  MusicLoop
//
//  Created by Mateo Ortiz on 4/08/22.
//

import AVFoundation
import Alamofire
import AlamofireImage

protocol SmashPlayerViewModelDelegate: AnyObject {
    func audioDidFinishPlaying()
    func updateImageSong(data: Data)
}

class SmashPlayerViewModel: NSObject {
    
    var audioPlayer = AVAudioPlayer()
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm:ss"
        return dateFormatter
    }()
    
    var model = SmashPlayerModel()
    weak var delegate: SmashPlayerViewModelDelegate?
    
    override init() {
        super.init()
        setUpAVAudioPlayer()
    }
    
    private func setUpModelData() {
        model.imageUrlSong = "https://lastfm.freetls.fastly.net/i/u/ar0/f82b5bf3c51a659ed1f0e9f28a77af55.jpg"
    
        model.nameSong = "Chasing Cars"
        model.nameSinger = "Snow Patrol"
        
        let date = Date(timeIntervalSinceReferenceDate: audioPlayer.duration)
        model.durationSong = dateFormatter.string(from: date)
        
        AF.request(model.imageUrlSong).responseData { response in
            if case .success(let data) = response.result {
                self.delegate?.updateImageSong(data: data)
            }
        }
    }
    
    private func setUpAVAudioPlayer() {
        let urlString = Bundle.main.path(forResource: "snowPatrolChasingCars", ofType: "mp3")
        
        do {
            try AVAudioSession.sharedInstance().setMode(.default)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)

            guard let urlString = urlString,
            let url = URL(string: urlString) else { return }

            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.delegate = self
            
            setUpModelData()
            
        } catch let error {
            print("error occurred \(error)")
        }
    }
    
}

extension SmashPlayerViewModel: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            delegate?.audioDidFinishPlaying()
        }
    }
}
