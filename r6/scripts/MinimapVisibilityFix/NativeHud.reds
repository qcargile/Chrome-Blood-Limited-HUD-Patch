module MinimapVisibilityFix

import MinimapVisibilityFix.Logging.*
import MinimapVisibilityFixConfig.MVFSettings

@addField(MinimapContainerController)
private let mvfNativeHidden: Bool;

@addField(MinimapContainerController)
private let mvfNativeFolding: Bool;

@addField(MinimapContainerController)
private let mvfNativeShow: wref<inkAnimProxy>;

@addMethod(MinimapContainerController)
private func MVFNativeAllowsRefresh() -> Bool {
  if this.mvfNativeHidden || this.mvfNativeFolding {
    if MVFSettings.EnableDebugLog() && MVFSettings.DebugLogLevel() >= 4 {
      MVFTrace("Native HUD", "hidden=" + ToString(this.mvfNativeHidden) + " folding=" + ToString(this.mvfNativeFolding));
    };
    return false;
  };
  let setting: ref<ConfigVarBool> = GameInstance.GetSettingsSystem(this.mvfPlayer.GetGame()).GetVar(n"/interface/hud", n"minimap") as ConfigVarBool;
  return IsDefined(setting) && setting.GetValue();
}

@addMethod(MinimapContainerController)
private func MVFReleaseNativeShow() -> Void {
  if IsDefined(this.mvfNativeShow) {
    this.mvfNativeShow.UnregisterFromCallback(inkanimEventType.OnFinish, this, n"OnMVFNativeShowFinished");
    this.mvfNativeShow = null;
  };
}

@addMethod(MinimapContainerController)
public func MVFNativeVisibility(shown: Bool, animation: ref<inkAnimProxy>) -> Void {
  this.MVFObserveNativeShow(animation);
  this.MVFStopFade();
  this.mvfNativeHidden = !shown;
  this.mvfNativeFolding = false;
  if MVFSettings.EnableDebugLog() && MVFSettings.DebugLogLevel() >= 3 {
    MVFDebug("Native HUD", "show=" + ToString(shown));
  };
  if !shown {
    this.mvfContextHidden = false;
    return;
  };
  this.MVFRefresh();
}

@addMethod(inkHUDGameController)
protected final func MVFNativeShowAnimation() -> ref<inkAnimProxy> {
  return this.m_showAnimProxy;
}

@addMethod(MinimapContainerController)
private func MVFObserveNativeShow(animation: ref<inkAnimProxy>) -> Void {
  this.MVFReleaseNativeShow();
  if IsDefined(animation) && animation.IsPlaying() {
    this.mvfNativeShow = animation;
    animation.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnMVFNativeShowFinished");
  };
}

@addMethod(MinimapContainerController)
public func MVFNativeFolding(active: Bool) -> Void {
  this.mvfNativeFolding = active;
  if active {
    this.MVFStopFade();
    this.mvfContextHidden = false;
  } else {
    this.MVFRefresh();
  };
}

@addMethod(MinimapContainerController)
protected cb func OnMVFNativeShowFinished(animation: ref<inkAnimProxy>) -> Bool {
  if animation == this.mvfNativeShow {
    this.MVFReleaseNativeShow();
    this.MVFRefresh();
  };
}

@wrapMethod(inkHUDGameController)
protected final func ShowRequest() -> Void {
  wrappedMethod();
  let minimap: ref<MinimapContainerController> = this as MinimapContainerController;
  if IsDefined(minimap) {
    minimap.MVFNativeVisibility(true, this.m_showAnimProxy);
  };
}

@wrapMethod(inkHUDGameController)
protected final func HideRequest() -> Void {
  let minimap: ref<MinimapContainerController> = this as MinimapContainerController;
  if IsDefined(minimap) {
    minimap.MVFNativeVisibility(false, null);
  };
  wrappedMethod();
}

@wrapMethod(inkHUDGameController)
protected final func PlayInitFoldingAnim() -> Void {
  let minimap: ref<MinimapContainerController> = this as MinimapContainerController;
  if IsDefined(minimap) {
    minimap.MVFNativeFolding(true);
  };
  wrappedMethod();
  if IsDefined(minimap) && (!IsDefined(this.m_hideAnimProxy) || !this.m_hideAnimProxy.IsPlaying()) {
    minimap.MVFNativeFolding(false);
  };
}

@wrapMethod(inkHUDGameController)
protected cb func OnPlayInitFoldingAnimFinished(animation: ref<inkAnimProxy>) -> Bool {
  let result: Bool = wrappedMethod(animation);
  let minimap: ref<MinimapContainerController> = this as MinimapContainerController;
  if IsDefined(minimap) {
    minimap.MVFNativeFolding(false);
  };
  return result;
}
