module MinimapVisibilityFix

@addMethod(MinimapContainerController)
public func MVFTimeskipChanged(visible: Bool) -> Void {
  this.mvfTimeskip = visible;
  this.DetermineCurrentVisibility();
  this.MVFRefreshContextVisibility();
}

@wrapMethod(TimeskipGameController)
protected cb func OnUninitialize() -> Bool {
  let player: ref<PlayerPuppet> = this.m_player as PlayerPuppet;
  if IsDefined(player) && player.itsTimeskipActive {
    player.DisableCustomTimeFastForward();
    this.FinalizeTimeskip();
  };
  wrappedMethod();
}
