enum AwtoSafetyClass {
  viewOnly,
  normal,
  motion,
  outputEnable,
  calibration,
  reset,
  firmware,
  destructive,
  raw,
}

extension AwtoSafetyClassExt on AwtoSafetyClass {
  String get displayName {
    return switch (this) {
      AwtoSafetyClass.viewOnly => 'view_only',
      AwtoSafetyClass.normal => 'normal',
      AwtoSafetyClass.motion => 'motion',
      AwtoSafetyClass.outputEnable => 'output_enable',
      AwtoSafetyClass.calibration => 'calibration',
      AwtoSafetyClass.reset => 'reset',
      AwtoSafetyClass.firmware => 'firmware',
      AwtoSafetyClass.destructive => 'destructive',
      AwtoSafetyClass.raw => 'raw',
    };
  }

  bool get requiresConfirmation {
    return switch (this) {
      AwtoSafetyClass.viewOnly => false,
      AwtoSafetyClass.normal => false,
      AwtoSafetyClass.motion => true,
      AwtoSafetyClass.outputEnable => true,
      AwtoSafetyClass.calibration => true,
      AwtoSafetyClass.reset => true,
      AwtoSafetyClass.firmware => true,
      AwtoSafetyClass.destructive => true,
      AwtoSafetyClass.raw => true,
    };
  }
}
