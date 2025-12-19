class BusyStateException implements Exception{}

class AsyncLock{
  bool busy=false;
  Future<T?> work<T>(Future<T?> Function() func) async {
    if (busy) throw BusyStateException();
     busy = true; // Set busy to true before executing the function.
    try {return await func();}catch(e){rethrow;}
    finally {busy = false;}
  }
}