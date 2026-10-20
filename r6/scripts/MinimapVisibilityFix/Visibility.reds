module MinimapVisibilityFix

import LimitedHudCommon.*
import LimitedHudConfig.MinimapModuleConfig
import MinimapVisibilityFix.Logging.*
import MinimapVisibilityFixConfig.MVFSettings

@addField(MinimapContainerController)
private let mvfFade: ref<inkAnimProxy>;

@addField(MinimapContainerController)
private let mvfTargetOpacity: Float;

@addField(MinimapContainerController)
private let mvfTimeskip: Bool;

@addMethod(MinimapContainerController)
private func MVFPrepareVisibility() -> Bool {
  if !this.mvfAttached || !IsDefined(this.mvfPlayer) || !IsDefined(this.lhudConfig) || !IsDefined(this.m_psmBlackboard) || !IsDefined(this.m_autodriveDataBlackboard) {
    return false;
  };
  if !this.MVFNativeAllowsRefresh() {
    this.MVFStopFade();
    return false;
  };
  this.lhud_inAutoDrive = this.m_autodriveDataBlackboard.GetBool(GetAllBlackboardDefs().UI_AutodriveData.AutoDriveEnabled);
  this.lhud_isInVehicle = !this.lhud_inAutoDrive && VehicleComponent.IsMountedToVehicle(this.mvfPlayer.GetGame(), this.mvfPlayer) && VehicleComponent.IsDriver(this.mvfPlayer.GetGame(), this.mvfPlayer);
  this.lhud_isScannerDetailsActive = MVFScannerState.Get(this.mvfPlayer.GetGame()).IsVisible(this.mvfPlayerID) && this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_Scanner).GetBool(GetAllBlackboardDefs().UI_Scanner.UIVisible);
  this.lhud_isBraindanceActive = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().Braindance).GetBool(GetAllBlackboardDefs().Braindance.IsActive);
  this.lhud_isZoomActive = this.m_psmBlackboard.GetFloat(GetAllBlackboardDefs().PlayerStateMachine.ZoomLevel) > 1.0 && !this.mvfPlayer.HasAnyWeaponEquipped_LHUD();
  return true;
}

@addMethod(MinimapContainerController)
private func MVFReconcileOpacity() -> Void {
  if IsDefined(this.mvfNativeShow) && this.mvfNativeShow.IsPlaying() {
    return;
  };
  let opacity: Float = this.lhudConfig.IsEnabled ? (this.lhud_isVisibleNow ? this.lhudConfig.Opacity : 0.0) : 1.0;
  opacity = this.MVFAllowedOpacity(opacity);
  if IsDefined(this.mvfFade) && this.mvfFade.IsPlaying() && this.mvfTargetOpacity == opacity {
    return;
  };
  this.MVFStopFade();
  if AbsF(this.GetRootWidget().GetOpacity() - opacity) > 0.001 {
    this.MVFAnimateAlpha(this.GetRootWidget(), opacity, 0.3);
  };
}

@addMethod(MinimapContainerController)
private func MVFAllowedOpacity(opacity: Float) -> Float {
  return this.mvfTimeskip ? 0.0 : opacity;
}

@addMethod(MinimapContainerController)
private func MVFStopFade() -> Void {
  if IsDefined(this.mvfFade) {
    this.mvfFade.Stop();
    this.mvfFade = null;
  };
}

@addMethod(MinimapContainerController)
private func MVFAnimateAlpha(targetWidget: wref<inkWidget>, endAlpha: Float, duration: Float) -> ref<inkAnimProxy> {
  if IsDefined(this.mvfNativeShow) && this.mvfNativeShow.IsPlaying() {
    return null;
  };
  this.MVFStopFade();
  this.mvfTargetOpacity = this.MVFAllowedOpacity(endAlpha);
  this.mvfFade = this.AnimateAlphaLHUD(targetWidget, this.mvfTargetOpacity, duration);
  if MVFSettings.EnableDebugLog() && MVFSettings.DebugLogLevel() >= 4 {
    MVFTrace("Opacity", "actual=" + ToString(targetWidget.GetOpacity()) + " target=" + ToString(this.mvfTargetOpacity));
  };
  return this.mvfFade;
}
