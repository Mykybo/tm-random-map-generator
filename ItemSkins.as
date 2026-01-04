#if DEPENDENCY_MLHOOK
namespace ItemSkins {

    void CheckLastItemSign(const string &in sign, CGameItemModel::EnumWaypointType expectedWaypoint) {
        // Don't queue skins if custom signs are disabled
        if (!EnableCustomSigns) {return;}
        pendingSkins.InsertLast(PendingSkin(sign, expectedWaypoint));
    }

    class PendingSkin {
        string skin;
        CGameItemModel::EnumWaypointType expectedWaypoint;
        string end;

        PendingSkin(const string &in skin, CGameItemModel::EnumWaypointType expectedWaypoint) {
            this.skin = skin;
            this.expectedWaypoint = expectedWaypoint;
            string[] s = this.skin.Split('/');
            this.end = s[s.Length - 1];
        }

        bool MatchesItem(CGameCtnEditorScriptAnchoredObject@ item) {
            return this.expectedWaypoint == item.ItemModel.WaypointType;
        }
    }

    array<PendingSkin@> pendingSkins = {};


    void CheckPendingSkins(ref@ processedData) {
        if (pendingSkins.Length == 0) {return;}
        CGameCtnApp@ app = GetApp();
        CGameCtnEditorFree@ editor = cast<CGameCtnEditorFree>(app.Editor);
        if (editor is null || editor.PluginMapType is null) {return;}
        if (app.Editor is null) {pendingSkins = {};}
        CGameEditorPluginMap@ map = editor.PluginMapType;
        for (int i = pendingSkins.Length - 1; i >= 0; i--) {
            ApplySkinToItem(map, pendingSkins[i]);
        }
        pendingSkins.RemoveRange(0, pendingSkins.Length);
    }

    void ApplySkinToItem(CGameEditorPluginMap@ map, PendingSkin@ skin) {
        // Check if custom signs are enabled before applying skins
        if (!EnableCustomSigns) {
            if (debugPrint) {print('Skipping item skin - EnableCustomSigns is off');}
            return;
        }

        CGameCtnEditorScriptAnchoredObject@ item;
        int nbItems = map.Items.Length;
        for (int i = nbItems - 1; i >= 0; i--) {
            @item = map.Items[i];
            if (item is null) {continue;}
            if (!skin.MatchesItem(item)) {continue;}
            if (debugPrint) {print('setting item ' + item.ItemModel.Name + ' skin: ' + skin.skin);}
            map.SetItemSkin(item, skin.skin);
            if (!map.GetItemSkinBg(item).EndsWith(skin.end)) {
                print('failed to skin item with ' + skin.end + ', found ' + map.GetItemSkinBg(item));
            }
            return;
        }
        print('no matching item found for ' + skin.expectedWaypoint);
    }
    bool isEnabled = false;
    void Enable() {
        if (isEnabled) {return;}
        MLHook::RegisterPlaygroundMLExecutionPointCallback(CheckPendingSkins);
        isEnabled = true;
    }
    void Disable() {
        if (!isEnabled) {return;}
        MLHook::UnregisterMLHooksAndRemoveInjectedML();
        isEnabled = false;
    }
}
void OnDestroyed() {
    ItemSkins::Disable();
}
#endif