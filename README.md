# SW-Lab-U02_W06_D26_30-SpeechRecognition
Recognize and transcript verbal commands. Convert text to spoken audio.

In last week of second unit, we received a request from our company that consists of modifying the company's existing Apps for non-sighted users.

We started researching how Swift can obtain our voice and transcribe it into text and how we can make iPhones reproduce voice from the reading of text. 
   - WWDC (Worldwide Developers Conference) 2016 and 2021 talks about Speech Recognition.
     - [Speech Recognition API](https://developer.apple.com/videos/play/wwdc2016/509)
     - [Advances in Speech Recognition]( https://developer.apple.com/videos/play/wwdc2019/256/)

   - Speech. Framework
     - [Speech Apple documentation](https://developer.apple.com/documentation/speech)
   - Sample Code
     - [Recognizing Speech in Live Audio](https://developer.apple.com/documentation/speech/recognizing_speech_in_live_audio)
   - WWDC 2018 about converting text to spoken audio
     - [AVSpeechSynthesizer: Making iOS Talk]( https://developer.apple.com/videos/play/wwdc2018/236/)
   - Speech Synthesis Framework
     - [Speech Synthesis Apple documentation]( https://developer.apple.com/documentation/avfoundation/speech_synthesis)
## Topics
1. Asking permission to use Speech Recognition
   - `SFSpeechRecognizer`
2. Recognize spoken words in live audio.
   - Abstract class representing a request to recognize speech from an audio source
     - `SFSpeechRecognitionRequest`
   - Class to recognize speech from captured audio content, such as audio from the device's microphone.
     - ` SFSpeechAudioBufferRecognitionRequest`
   - A task object used to monitor the speech recognition progress and determine the state of a speech recognition task, to cancel an ongoing task.
     - `SFSpeechRecognitionTask`
3. Speech Synthesis framework
   - An instance that contains the text for speech.
     - `AVSpeechUtterance`
   - Pass the utterance to an `AVSpeechSynthesizer` instance to produce spoken audio.
     - `AVSpeechSynthesizer`


## Description
1. Individually or in groups, we’ve been working in different projects like:
   - **WorldWideTour App**
     - The user tells the App the point of interest that he wishes to visit. 
     - Then the app collects the request that has been given through the voice and shows on a map the location of the point of interest such as the Eiffel Tower, Big Ben or Sagrada Familia.
   - **MyMaps App**
     - While the user walks through the city, the App tells him/her with synthesize voice in which street and number he/she is as he moves.
     - Because this application is intended for the blind, they open the application through Siri. Once opened, if the user presses the screen once, the application begins to give the location. When the user presses the screen twice, then the App stops indicating the location until the user makes a single tap again.
   - **PersonalAssistant App**
     - The App acts as a Bot. 
     - Talks to the user and asks for his name. The next time the user reopens the App, the App remembers the user's name and addresses him/her with his/her name.
     - The user can give voice commands to open the following Apps: Safari, Photo, Messages, Settings.
     - the user also can ask with his/her voice to change the background of the screen
   - **CapitalsQuiz App**
     - A quiz game where the user interacts with the App through the voice. The game proposes the questions in voice and the user answers affirmatively or negatively. The App recognizes the answers increasing the score.
   - **AudioReproducer App**
     - This App collects voice messages from the user. Then the user can reproduce them at different speeds as some podcatchers do.
   - **HomeworkTasks App**
     - This App is designed for students without visibility. When the user opens the App, a synthesized voice tells the student the tasks that she has to perform. Once the student has completed the task, they can delete it. You can also modify and add tasks.
2. Presentation of the projects.
## Deadline 
Sunday 14th November 9:15 am



