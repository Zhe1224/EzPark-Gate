import '../../../widgets/message_card.dart';
import 'base.dart';

class EntryView extends PlateScannerPageBase{
  static const title="Register Vehicle Entry";
  const EntryView({super.key, required super.controller});
  @override
  State<PlateScannerPageBase> createState() => _EntryViewState();
}

class _EntryViewState extends PlateScannerPageBaseState{
  @override
  void start() {
    camera.startImageStream((CameraImage image) async {
    try {
      String plateNo = await worker.work(()=>widget.controller.logEntry(image))??"";
      if (plateNo.isEmpty) return;
      DateTime now=DateTime.now();
      setState(() {
        card=SuccessCard.make(plateNo,widget.controller.gate.name,now.hour,now.minute,now.second);
        Future.delayed(const Duration(seconds:10),(){
          setState(() {card=null;});
        });
      });
    }catch (e){ switch (e){
        case BusyStateException _:return;
        default: card=_displayErrorMessage(e.toString());
      }}});
  }

  Widget _displayErrorMessage(String error) {
    return ErrorCard(
      exceptionName: error,
    );
  }
}

