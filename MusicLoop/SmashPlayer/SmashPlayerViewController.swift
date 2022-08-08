//
//  ViewController.swift
//  MusicLoop
//
//  Created by Mateo Ortiz on 4/08/22.
//

import UIKit

class SmashPlayerViewController: UIViewController {
    
    private let songImageView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    
    private let nameSongLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameSingerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.textAlignment = .center
        label.font = label.font.withSize(12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let progressSlider: UISlider = {
        let slider = UISlider()
        slider.tintColor = .white
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    private let initTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.textAlignment = .left
        label.text = "0:00"
        label.font = label.font.withSize(12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let endTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.textAlignment = .right
        label.text = "0:00"
        label.font = label.font.withSize(12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let playPauseButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "icon-play"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let loopButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "icon-record"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let viewModel = SmashPlayerViewModel()
    
    private var loopCounter: Int = 0
    private var startTimeIntervalLoop: TimeInterval?
    private var endTimeIntervalLoop: TimeInterval?
    private var timerLoop: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        setUpModelData()
        setUpViewController()
        setUpConstraints()
    }
    
    private func setUpViewController() {
        
        view.backgroundColor = .black
        view.addSubview(songImageView)
        view.addSubview(nameSongLabel)
        view.addSubview(nameSingerLabel)
        view.addSubview(progressSlider)
        view.addSubview(initTimeLabel)
        view.addSubview(endTimeLabel)
        view.addSubview(playPauseButton)
        view.addSubview(loopButton)
        
        setUpPlayPauseButton()
        setUpProgressSlider()
        setUpLoopButton()
        
    }
    
    private func setUpPlayPauseButton() {
        playPauseButton.addTarget(self, action: #selector(didTapPlayPauseButton(_:)), for: .touchUpInside)
    }

    private func setUpProgressSlider() {
        progressSlider.addTarget(self, action: #selector(changeAudioTime), for: .valueChanged)
        
        progressSlider.maximumValue = Float(viewModel.audioPlayer.duration)
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        let thumbImage = UIImage(named: "icon-thumb")
        let resizedImage = thumbImage?.resized(to: CGSize(width: 10, height: 10))
        progressSlider.setThumbImage(resizedImage, for: .normal)
    }
    
    private func setUpLoopButton() {
        loopButton.isEnabled = false
        loopButton.isUserInteractionEnabled = false
        loopButton.addTarget(self, action: #selector(didTapOnLoop(_:)), for: .touchUpInside)
    }
    
    private func setUpModelData(){
        nameSongLabel.text = viewModel.model.nameSong
        nameSingerLabel.text = viewModel.model.nameSinger
        endTimeLabel.text = viewModel.model.durationSong
    }
    
    @objc func didTapPlayPauseButton(_ sender: UIButton) {
        
        if viewModel.audioPlayer.isPlaying {
            // pause
            viewModel.audioPlayer.pause()
            playPauseButton.setBackgroundImage(UIImage(named: "icon-play"), for: .normal)
            loopButton.isEnabled = false
            loopButton.isUserInteractionEnabled = false
        } else {
            // play
            viewModel.audioPlayer.play()
            playPauseButton.setBackgroundImage(UIImage(named: "icon-pause"), for: .normal)
            loopButton.isEnabled = true
            loopButton.isUserInteractionEnabled = true
        }
    }
    
    @objc func changeAudioTime() {
        progressSlider.maximumValue = Float(viewModel.audioPlayer.duration)
        viewModel.audioPlayer.currentTime = TimeInterval(progressSlider.value)
        if viewModel.audioPlayer.isPlaying {
            viewModel.audioPlayer.stop()
            viewModel.audioPlayer.prepareToPlay()
            viewModel.audioPlayer.play()
        }
    }
    
    @objc func updateSlider() {
        progressSlider.value = Float(viewModel.audioPlayer.currentTime)
        let date = Date(timeIntervalSinceReferenceDate: viewModel.audioPlayer.currentTime)
        initTimeLabel.text = viewModel.dateFormatter.string(from: date)
    }
    
    @objc func didTapOnLoop(_ sender: UIButton) {
        loopCounter += 1
        switch loopCounter {
        case 1:
            startRecording()
        case 2:
            stopRecording()
        case 3:
            breakLoopPlayer()
        default:
            break
        }
    }
    
    func startRecording() {
        loopButton.setBackgroundImage(UIImage(named: "icon-stop"), for: .normal)
        startTimeIntervalLoop = viewModel.audioPlayer.currentTime
        progressSlider.tintColor = .red
        progressSlider.isUserInteractionEnabled = false
    }
    
    func stopRecording() {
        endTimeIntervalLoop = viewModel.audioPlayer.currentTime
        
        guard let startTime = startTimeIntervalLoop,
              let endTime = endTimeIntervalLoop else { return }
        
        loopButton.setBackgroundImage(UIImage(named: "icon-resume"), for: .normal)
        
        viewModel.audioPlayer.currentTime = startTime
        viewModel.audioPlayer.pause()
        viewModel.audioPlayer.prepareToPlay()
        viewModel.audioPlayer.play()
        
        if timerLoop == nil {
            timerLoop = Timer.scheduledTimer(timeInterval: endTime-startTime, target: self, selector: #selector(restartPlayer), userInfo: nil, repeats: true)
        }
    }
    
    @objc func restartPlayer() {
        guard let startTime = startTimeIntervalLoop else { return }
        viewModel.audioPlayer.stop()
        viewModel.audioPlayer.currentTime = startTime
        viewModel.audioPlayer.prepareToPlay()
        viewModel.audioPlayer.play()
    }

    func breakLoopPlayer() {
        loopButton.setBackgroundImage(UIImage(named: "icon-record"), for: .normal)
        loopCounter = 0
        startTimeIntervalLoop = nil
        endTimeIntervalLoop = nil
        progressSlider.tintColor = .white
        progressSlider.isUserInteractionEnabled = true
        guard let timerLoop = timerLoop else { return }
        timerLoop.invalidate()
        self.timerLoop = nil
    }
}

extension SmashPlayerViewController: SmashPlayerViewModelDelegate {
    func audioDidFinishPlaying() {
        playPauseButton.setBackgroundImage(UIImage(named: "icon-play"), for: .normal)
        loopButton.isEnabled = false
        loopButton.isUserInteractionEnabled = false
    }
    
    func updateImageSong(data: Data) {
        songImageView.image = UIImage(data: data)
    }
}


// MARK: Constraints
extension SmashPlayerViewController {
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            songImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            songImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            songImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            songImageView.heightAnchor.constraint(equalToConstant: 250),
            
            nameSongLabel.topAnchor.constraint(equalTo: songImageView.bottomAnchor, constant: 20),
            nameSongLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameSongLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            nameSingerLabel.topAnchor.constraint(equalTo: nameSongLabel.bottomAnchor, constant: 10),
            nameSingerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameSingerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            progressSlider.topAnchor.constraint(equalTo: nameSingerLabel.bottomAnchor, constant: 30),
            progressSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            progressSlider.heightAnchor.constraint(equalToConstant: 20),
            
            initTimeLabel.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 5),
            initTimeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            initTimeLabel.widthAnchor.constraint(equalToConstant: 40),
            
            endTimeLabel.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 5),
            endTimeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            endTimeLabel.widthAnchor.constraint(equalToConstant: 40),
            
            playPauseButton.topAnchor.constraint(equalTo: progressSlider.bottomAnchor, constant: 40),
            playPauseButton.widthAnchor.constraint(equalToConstant: 50),
            playPauseButton.heightAnchor.constraint(equalToConstant: 50),
            playPauseButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            loopButton.widthAnchor.constraint(equalToConstant: 30),
            loopButton.heightAnchor.constraint(equalToConstant: 30),
            loopButton.leadingAnchor.constraint(equalTo: playPauseButton.trailingAnchor, constant: 20),
            loopButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor)
            
        ])
    }
}


