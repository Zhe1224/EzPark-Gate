import '../../../widgets/message_card.dart';
import 'base.dart';

class EntryView extends PlateScannerPageBase{
  static const title="Register Vehicle Entry";
  const EntryView({super.key, required super.controller,required super.camera});
  @override
  State<PlateScannerPageBase> createState() => _EntryViewState();
}

class _EntryViewState extends PlateScannerPageBaseState{
  @override
  void start() {
    widget.camera.startImageStream((CameraImage image) async {
    try {
      String plateNo = await worker.work(()=>widget.controller.logEntry(image))??"";
      if (plateNo.isEmpty) return;
      worker.work((){return Future.delayed(Duration(seconds: 8));});
      DateTime now=DateTime.now();
      setCard(SuccessCard.make(plateNo,widget.controller.gate.name,now.hour,now.minute,now.second));
    }catch (e){ switch (e){
        case BusyStateException _:return;
        default: setCard(_displayErrorMessage(e.toString()));;
      }}});
  }

  Widget _displayErrorMessage(String error) {
    return ErrorCard(
      exceptionName: error,
    );
  }
}

