module MinimapVisibilityFix

public class MVFScannerState extends ScriptableSystem {
  private let sources: array<wref<scannerDetailsGameController>>;
  private let playerID: EntityID;
  private let scannerBoard: ref<IBlackboard>;
  private let scannerCallback: ref<CallbackHandle>;
  private let attached: Bool;

  public static func Get(game: GameInstance) -> ref<MVFScannerState> {
    return GameInstance.GetScriptableSystemsContainer(game).Get(n"MinimapVisibilityFix.MVFScannerState") as MVFScannerState;
  }

  private func OnAttach() -> Void {
    this.attached = true;
    this.scannerBoard = GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_Scanner);
    this.scannerCallback = this.scannerBoard.RegisterListenerBool(GetAllBlackboardDefs().UI_Scanner.UIVisible, this, n"OnScannerVisibilityChanged", true);
  }

  private func OnDetach() -> Void {
    this.attached = false;
    if IsDefined(this.scannerBoard) && IsDefined(this.scannerCallback) {
      this.scannerBoard.UnregisterListenerBool(GetAllBlackboardDefs().UI_Scanner.UIVisible, this.scannerCallback);
    };
    this.scannerCallback = null;
    this.scannerBoard = null;
    ArrayClear(this.sources);
  }

  private cb func OnScannerVisibilityChanged(visible: Bool) -> Bool {
    if !visible && ArraySize(this.sources) > 0 {
      ArrayClear(this.sources);
      this.RefreshMinimap();
    };
  }

  public func IsVisible(playerID: EntityID) -> Bool {
    if !this.attached {
      return false;
    };
    if !GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_Scanner).GetBool(GetAllBlackboardDefs().UI_Scanner.UIVisible) {
      ArrayClear(this.sources);
    };
    let index: Int32 = ArraySize(this.sources) - 1;
    while index >= 0 {
      if !IsDefined(this.sources[index]) {
        ArrayErase(this.sources, index);
      };
      index -= 1;
    };
    return Equals(this.playerID, playerID) && ArraySize(this.sources) > 0;
  }

  public func SetVisible(source: ref<scannerDetailsGameController>, player: ref<GameObject>, visible: Bool) -> Void {
    if visible {
      if !this.attached {
        return;
      };
      if !IsDefined(player) || player != GameInstance.GetPlayerSystem(player.GetGame()).GetLocalPlayerControlledGameObject() {
        return;
      };
      if !GameInstance.GetBlackboardSystem(this.GetGameInstance()).Get(GetAllBlackboardDefs().UI_Scanner).GetBool(GetAllBlackboardDefs().UI_Scanner.UIVisible) {
        return;
      };
      if NotEquals(this.playerID, player.GetEntityID()) {
        ArrayClear(this.sources);
        this.playerID = player.GetEntityID();
      };
    };
    let index: Int32 = ArraySize(this.sources) - 1;
    while index >= 0 {
      if !IsDefined(this.sources[index]) || this.sources[index] == source {
        ArrayErase(this.sources, index);
      };
      index -= 1;
    };
    if visible {
      ArrayPush(this.sources, source);
    };
    this.RefreshMinimap();
  }

  private func RefreshMinimap() -> Void {
    if !this.attached {
      return;
    };
    let evt: ref<MVFRefreshEvent> = new MVFRefreshEvent();
    evt.playerID = this.playerID;
    GameInstance.GetUISystem(this.GetGameInstance()).QueueEvent(evt);
  }
}

@addField(scannerDetailsGameController)
private let mvfScannerState: wref<MVFScannerState>;

@wrapMethod(scannerDetailsGameController)
protected cb func OnScannerDetailsShown(animationProxy: ref<inkAnimProxy>) -> Bool {
  wrappedMethod(animationProxy);
  if IsDefined(this.m_player) {
    this.mvfScannerState = MVFScannerState.Get(this.m_player.GetGame());
    this.mvfScannerState.SetVisible(this, this.m_player, true);
  };
}

@wrapMethod(scannerDetailsGameController)
protected cb func OnScannerDetailsHidden(animationProxy: ref<inkAnimProxy>) -> Bool {
  wrappedMethod(animationProxy);
  if IsDefined(this.mvfScannerState) {
    this.mvfScannerState.SetVisible(this, this.m_player, false);
  };
}

@wrapMethod(scannerDetailsGameController)
protected cb func OnUnitialize() -> Bool {
  if IsDefined(this.mvfScannerState) {
    this.mvfScannerState.SetVisible(this, this.m_player, false);
    this.mvfScannerState = null;
  };
  wrappedMethod();
}
