import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late final GenerativeModel _model;
  late final ChatSession _chatSession;

  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  String _resultado = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _model = GenerativeModel(model: 'gemini-pro', apiKey: 'AIzaSyBfyZYXZDaILXeCDGrhMbjJM8BIbMb4Zqo');
    _chatSession = _model.startChat();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }
  void sendToGemini(String message) async {
    Content userMessage = Content.text(message);
    print("Sending text to Gemini: $message");
    // Implement logic to send text to Gemini API or service (replace with actual logic)
    final response = await _chatSession.sendMessage(userMessage);
    if (response != null) {
      print("Gemini Response: ${response.text}");
      setState(() {
        _resultado = response.text!;
      });
      // Update UI with the response text (optional)
      // ...
    } else {
      print("Error getting response from Gemini");
      // Handle potential errors (optional)
      // ...
    }
  }
  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;


    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI-Pollo'),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Ingrese confirme su promp apretando el boton de la derecha",
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    _resultado, // Agrega tu texto adicional aquí
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      // If listening is active show the recognized words
                      _speechToText.isListening
                          ? '$_lastWords'
                      // If listening isn't active but could be tell the user
                      // how to start it, otherwise indicate that speech
                      // recognition is not yet ready or not supported on
                      // the target device
                          : _speechEnabled
                          ? 'Toca el microfono para empezar a escuchar...'
                          : 'Speech not available',
                    ),


                  ),

                ),
              ],
            ),
          ),
          Positioned(
            // Posiciona la imagen al centro
            top: MediaQuery.of(context).size.height / 2 - 100, // Centra verticalmente
            left: MediaQuery.of(context).size.width / 2 - 100, // Centra horizontalmente
            child: Image.asset(
              'assets/mascota.png', // Cambia 'your_image.png' por la ruta de tu imagen
              width: 200, // Ajusta el ancho de la imagen según sea necesario
              height: 200, // Ajusta la altura de la imagen según sea necesario
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FloatingActionButton(
            onPressed: _speechToText.isNotListening ? _startListening : _stopListening,
            child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
          ),
          FloatingActionButton(
            onPressed: () {
              sendToGemini(_lastWords);

            },
            tooltip: 'enviar',
            child: Icon(Icons.add_circle), // Cambia el icono según sea necesario
          ),
        ],
      ),

    );
  }
}
