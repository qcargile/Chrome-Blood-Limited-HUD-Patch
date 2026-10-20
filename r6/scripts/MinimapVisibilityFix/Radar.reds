module MinimapVisibilityFix

import LimitedHudConfig.MinimapModuleConfig
import MinimapVisibilityFix.Logging.*
import MinimapVisibilityFixConfig.MVFSettings

public class MVFRefreshEvent extends Event {
  public let playerID: EntityID;
}

@addField(MinimapContainerController)
private let mvfPlayer: wref<PlayerPuppet>;

@addField(MinimapContainerController)
private let mvfPlayerID: EntityID;

@addField(MinimapContainerController)
private let mvfAttached: Bool;

@addField(MinimapContainerController)
private let mvfContextHidden: Bool;

@addField(MinimapContainerController)
private let mvfVehicleVisible: Bool;

@wrapMethod(MinimapContainerController)
protected cb func OnPlayerAttach(player: ref<GameObject>) -> Bool {
  this.MVFDetach();
  this.mvfVehicleVisible = true;
  wrappedMethod(player);
  this.mvfPlayer = player as PlayerPuppet;
  if IsDefined(this.mvfPlayer) {
    this.mvfPlayerID = player.GetEntityID();
    this.mvfAttached = true;
    ModSettings.RegisterListenerToModifications(this);
    this.MVFObserveNativeShow(this.MVFNativeShowAnimation());
    this.MVFRefresh();
    MVFInfo("Minimap", "Attached");
  };
}

@wrapMethod(MinimapContainerController)
protected cb func OnPlayerDetach(player: ref<GameObject>) -> Bool {
  this.MVFDetach();
  wrappedMethod(player);
}

@wrapMethod(MinimapContainerController)
protected cb func OnUnitialize() -> Bool {
  this.MVFDetach();
  wrappedMethod();
}

@addMethod(MinimapContainerController)
private func MVFDetach() -> Void {
  if this.mvfAttached {
    this.mvfAttached = false;
    ModSettings.UnregisterListenerToModifications(this);
  };
  this.MVFStopFade();
  this.MVFReleaseNativeShow();
  this.mvfPlayer = null;
  this.mvfTimeskip = false;
  this.mvfContextHidden = false;
  this.lhud_isScannerDetailsActive = false;
}

@addMethod(MinimapContainerController)
public func OnModSettingsChange() -> Void {
  if this.mvfAttached {
    let evt: ref<MVFRefreshEvent> = new MVFRefreshEvent();
    evt.playerID = this.mvfPlayerID;
    this.QueueEvent(evt);
  };
}

@addMethod(MinimapContainerController)
protected cb func OnMVFRefreshEvent(evt: ref<MVFRefreshEvent>) -> Bool {
  if this.mvfAttached && Equals(evt.playerID, this.mvfPlayerID) {
    this.MVFRefresh();
  };
}

@addMethod(MinimapContainerController)
private func MVFRefresh() -> Void {
  if this.mvfAttached && IsDefined(this.mvfPlayer) {
    this.lhudConfig = new MinimapModuleConfig();
    this.MVFSampleInputs();
    this.DetermineCurrentVisibility();
    this.MVFRefreshContextVisibility();
  };
}

@addMethod(MinimapContainerController)
private func MVFRefreshContextVisibility() -> Void {
  if !this.mvfAttached || !IsDefined(this.mvfPlayer) || !IsDefined(this.m_psmBlackboard) {
    return;
  };
  if !this.MVFNativeAllowsRefresh() {
    return;
  };
  let allowed: Bool = !this.mvfTimeskip && this.mvfVehicleVisible;
  if !allowed && this.GetRootWidget().IsVisible() {
    this.mvfContextHidden = true;
    this.GetRootWidget().SetVisible(false);
  } else {
    if allowed && this.mvfContextHidden && this.mvfVehicleVisible {
      this.mvfContextHidden = false;
      this.GetRootWidget().SetVisible(true);
    };
  };
  if MVFSettings.EnableDebugLog() && MVFSettings.DebugLogLevel() >= 4 {
    MVFTrace("Radar", "allowed=" + ToString(allowed) + " vehicleVisible=" + ToString(this.mvfVehicleVisible) + " visible=" + ToString(this.GetRootWidget().IsVisible()));
  };
}

@addMethod(MinimapContainerController)
private func MVFNativeVehicleVisibility() -> Void {
  this.mvfVehicleVisible = this.GetRootWidget().IsVisible();
  this.mvfContextHidden = false;
  this.MVFRefresh();
}

@wrapMethod(MinimapContainerController)
protected cb func OnRemoteControlledVehicleChanged(value: Variant) -> Bool {
  let outcome: Bool = wrappedMethod(value);
  this.MVFNativeVehicleVisibility();
  return outcome;
}

@wrapMethod(MinimapContainerController)
protected cb func OnPSMRemoteControlledVehicleCameraChangedToTPP(value: Bool) -> Bool {
  let outcome: Bool = wrappedMethod(value);
  this.MVFNativeVehicleVisibility();
  return outcome;
}
