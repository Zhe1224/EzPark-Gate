import '../../../entity/parking_session_info.dart';
import '../../../widgets/message_card.dart';
import 'base.dart';

class ExitView extends PlateScannerPageBase{
  static const title="Register Vehicle Exit";
  const ExitView({super.key, required super.controller, required super.camera});
  @override
  State<PlateScannerPageBase> createState() => _ExitViewState();
}

class _ExitViewState extends PlateScannerPageBaseState{
  SessionInfo? inf;
  @override
  void start(){
  widget.camera.startImageStream((CameraImage image) async {
      try {
        SessionInfo? info = await worker.work(()=>widget.controller.logExit(image));
        if (info == null || info.plateNo == null || info.plateNo!.isEmpty) return;
        if (inf?.plateNo==info.plateNo) return;
        setState(() {
          inf=info;
          card=_displayExitSuccessMessage(info);
          Future.delayed(const Duration(seconds:10),(){
            setState(() {
              card=null;
            });
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

  Widget _displayExitSuccessMessage(SessionInfo info){
    DateTime now=DateTime.now();
    return Column(
      spacing:10,
      children: [
        SuccessCard.make(info.plateNo??"", widget.controller.gate.name, now.hour,now.minute,now.second),
        DetailsCard(durationHour: info.durationHour, durationMinute: info.durationMinute, baseFee: info.baseFee, payable: info.payable, shopper: info.user??"-")
      ],
    );
  }
}