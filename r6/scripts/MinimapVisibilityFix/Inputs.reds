module MinimapVisibilityFix

import LimitedHudCommon.*
import LimitedHudMappinChecker.MappinChecker

@addMethod(MinimapContainerController)
private func MVFSampleInputs() -> Void {
  if !IsDefined(this.m_psmBlackboard) || !IsDefined(this.m_autodriveDataBlackboard) {
    return;
  };
  let defs: ref<AllBlackboardDefinitions> = GetAllBlackboardDefs();
  let boards: ref<BlackboardSystem> = this.GetBlackboardSystem();
  let ui: ref<IBlackboard> = boards.Get(defs.UI_System);
  let scanner: ref<IBlackboard> = boards.Get(defs.UI_Scanner);
  let combat: Int32 = this.m_psmBlackboard.GetInt(defs.PlayerStateMachine.Combat);
  let locomotion: gamePSMLocomotionStates = IntEnum<gamePSMLocomotionStates>(this.m_psmBlackboard.GetInt(defs.PlayerStateMachine.Locomotion));
  let zone: SecurityAreaData = FromVariant<SecurityAreaData>(this.m_psmBlackboard.GetVariant(defs.PlayerStateMachine.SecurityZoneData));
  this.lhud_isGlobalFlagToggled = ui.GetBool(defs.UI_System.IsGlobalFlagToggled_LHUD);
  this.lhud_isMinimapFlagToggled = ui.GetBool(defs.UI_System.IsMinimapToggled_LHUD);
  this.lhud_isBraindanceActive = boards.Get(defs.Braindance).GetBool(defs.Braindance.IsActive);
  this.lhud_isScannerActive = scanner.GetBool(defs.UI_Scanner.UIVisible);
  this.lhud_isScannerDetailsActive = MVFScannerState.Get(this.mvfPlayer.GetGame()).IsVisible(this.mvfPlayerID) && this.lhud_isScannerActive;
  this.lhud_isCombatActive = combat == 1;
  this.lhud_isOutOfCombatActive = combat == 0 || combat == 2;
  this.lhud_isStealthActive = Equals(locomotion, gamePSMLocomotionStates.Crouch) || Equals(locomotion, gamePSMLocomotionStates.CrouchSprint) || Equals(locomotion, gamePSMLocomotionStates.CrouchDodge);
  this.lhud_isWeaponUnsheathed = this.mvfPlayer.HasAnyWeaponEquipped_LHUD();
  this.lhud_isZoomActive = this.m_psmBlackboard.GetFloat(defs.PlayerStateMachine.ZoomLevel) > 1.0 && !this.lhud_isWeaponUnsheathed;
  this.lhud_inAutoDrive = this.m_autodriveDataBlackboard.GetBool(defs.UI_AutodriveData.AutoDriveEnabled);
  this.lhud_isWanted = boards.Get(defs.UI_WantedBar).GetInt(defs.UI_WantedBar.CurrentWantedLevel) != 0;
  this.lhud_isInDangerZone = Equals(zone.securityAreaType, ESecurityAreaType.RESTRICTED) || Equals(zone.securityAreaType, ESecurityAreaType.DANGEROUS);
  this.lhud_hasTrackedMarkers = MappinChecker.HasTrackedMappins(this.mvfPlayer.GetGame());
  this.mvfTimeskip = this.mvfPlayer.itsTimeskipActive;
}
