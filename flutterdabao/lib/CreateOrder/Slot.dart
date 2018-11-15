class Slot {
  String _slotString;
  DateTime _startTime;
  DateTime _endTime;
  DateTime _startDate;
  bool _pressed;

  String get slotString => _slotString;

  set slotString(String value) {
    _slotString = value;
  }

  DateTime get startDate => _startDate;

  DateTime get startTime => _startTime;

  DateTime get endTime => _endTime;

  bool get pressed => _pressed;

  set pressed(bool value) {
    _pressed = value;
  }

  set endTime(DateTime value) {
    _endTime = value;
  }

  set startTime(DateTime value) {
    _startTime = value;
  }

  set startDate(DateTime value) {
    _startDate = value;
  }
}
