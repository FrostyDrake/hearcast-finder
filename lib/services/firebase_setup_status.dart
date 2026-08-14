class FirebaseSetupStatus {
  const FirebaseSetupStatus({
    required this.hasPackages,
    required this.hasEmulatorConfig,
    required this.hasRulesDraft,
    required this.hasFirebaseOptions,
    required this.hasAndroidAppConfig,
  });

  final bool hasPackages;
  final bool hasEmulatorConfig;
  final bool hasRulesDraft;
  final bool hasFirebaseOptions;
  final bool hasAndroidAppConfig;

  bool get canConnectFromApp {
    return hasPackages && hasFirebaseOptions && hasAndroidAppConfig;
  }

  int get completedStepCount {
    return [
      hasPackages,
      hasEmulatorConfig,
      hasRulesDraft,
      hasFirebaseOptions,
      hasAndroidAppConfig,
    ].where((isDone) => isDone).length;
  }
}

const day4FirebaseSetupStatus = FirebaseSetupStatus(
  hasPackages: true,
  hasEmulatorConfig: true,
  hasRulesDraft: true,
  hasFirebaseOptions: false,
  hasAndroidAppConfig: false,
);
