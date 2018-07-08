//
//  ViewController.swift
//  SpeechRecognizer
//
//  Created by M_Sugawara on 2018/07/07.
//  Copyright © 2018年 Sugawar. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController {
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var textLabel: UILabel!
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestSpeechAuthorization()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    print("authorized")
                case .denied:
                    print("denied")
                case .restricted:
                    print("restricted")
                case .notDetermined:
                    print("notDeterminded")
                }
            }
        }
    }
    
    private func recordAndRecognizeSpeech() {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.request.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            return print(error)
        }
        
        guard let myRecognizer = SFSpeechRecognizer() else {
            print("A recognizer is not supported for the current locale")
            return
        }
        if !myRecognizer.isAvailable {
            print("A recognizer is not available right now")
            return
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: request, delegate: self)
    }

    // MARK: - Actions
    @IBAction func startButtonTapped(_ sender: UIButton) {
        recordAndRecognizeSpeech()
        self.startButton.isEnabled = false
    }
    

}

extension ViewController: SFSpeechRecognitionTaskDelegate {
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didHypothesizeTranscription transcription: SFTranscription) {
        let bestString = transcription.formattedString
        print("formatted String is \(bestString)")
        self.textLabel.text = bestString
        
        var lastString = ""
        for segment in transcription.segments {
            let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
            //                    lastString = bestString.substring(from: indexTo)
            lastString = String(bestString[indexTo...])
            print("lastString: \(lastString)")
        }
    }
    
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishRecognition recognitionResult: SFSpeechRecognitionResult) {
        task.finish()
    }
    
    func speechRecognitionTaskFinishedReadingAudio(_ task: SFSpeechRecognitionTask) {
        print("finished recording audio.")
        self.startButton.isEnabled = true
    }
}
