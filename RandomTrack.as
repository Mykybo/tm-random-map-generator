
// Controls the generation of a track
class TrackGenerator {
    CGameEditorPluginMap@ map;
    CGameCtnEditorFree@ editor;
    array<TrackSection@> trackSections;
    nat3 mapSize = nat3(0,0,0);

    uint debugvalue = Blocks.Length - 1;
    uint status = 0;
    // used to reset air block mode back to previous vale after generating
    bool startAirMode;
    uint startMaxPillarCount;
    dataTracker@ generation_data;

    TrackGenerator(bool debug = false) {
#if DEPENDENCY_MLHOOK
        ItemSkins::Enable();
#endif
        @this.generation_data = dataTracker();
        if (debug) {
            this.Start(true);
        }
    }
    void Start(bool debug = false) {
        this.generation_data.ChangeActivity(Activity::Startup);
        this.status = 1;
        if (!(blocksStatus == LoadStatus::All || blocksStatus == LoadStatus::NonzeroWeight)) {
            UI::ShowNotification(pluginName, "Load blocks before creating a map", notificationErrorColor);
            this.status = 3;
            return;}

        if (GetApp() is null) {return;}
        if (GetApp().Editor is null) {
            UI::ShowNotification(pluginName, "Open the map editor to create a map", notificationErrorColor);
            this.status = 3;
            return;}
        if (GetApp().CurrentPlayground !is null) {
            UI::ShowNotification(pluginName, "Return to editor to create a map", notificationErrorColor);
            this.status = 3;
            return;}
        @this.editor = cast<CGameCtnEditorFree>(GetApp().Editor);

        @this.map = cast<CGameEditorPluginMap>(this.editor.PluginMapType);

        Refreshmap();

        //map.RemoveAllBlocks();
        this.startAirMode = editor.ExperimentalFeatures.IsAutoAirMappingEnabled; // Seems to be unused/always false, maybe from tm2. I make sure to set this back afterwards, so it should be fine
        this.startMaxPillarCount = editor.ExperimentalFeatures.AutoAirMapping_MaxPillarCount;
        // is valid map, can now start generating

        map.NextMapElemColor = CGameEditorPluginMap::EMapElemColor::Default;
        map.MapElemColorPalette = ChooseColorPalette();

        if (debug) {
            this.debugBlock();
            return;
        }
        this.generation_data.ChangeActivity(Activity::Processing);
        this.trackSections = {TrackSection(this)};
        while (this.status == 1) {
            if (debugStepMode) {
                this.generation_data.Yield(YieldReason::DebugModes);
                continue;}
            this.generation_data.CheckYield();
            this.step();
            if (this.trackSections.Length == 1) {
                UI::ShowNotification(pluginName, "Track generation failed", notificationErrorColor);
                print("Track generation failed");
                this.status = 3;
            }
        }
        this.generation_data.ChangeActivity(Activity::Refreshing);
        Refreshmap();
        this.generation_data.ChangeActivity(Activity::None);
        // this.map.SetNextSkin
    }
    void Interrupt() {
        this.status = 3;
    }
    void Finish() {
        this.status = 2;
        UI::ShowNotification(pluginName, "Track generation finished, length≈ " + Text::Format('%.4f', this.trackSections[this.trackSections.Length-1].Length) + ' (' + this.trackSections[this.trackSections.Length-1].PieceCount + ' blocks)', notificationOkColor);
        print('Track generation finished, length ' + Text::Format('%.4f', this.trackSections[this.trackSections.Length-1].Length) + ', ' + this.trackSections[this.trackSections.Length-1].PieceCount + ' blocks');
        if (this.editor.Challenge.TMObjective_NbLaps > 1) {
            uint offset = Reflection::TypeOf(this.editor.Challenge).GetMember('TMObjective_NbLaps').Offset;
            if (offset > 0 && offset < 0xffff) {
                Dev::SetOffset(this.editor.Challenge, offset, uint(1));
            } else {
                UI::ShowNotification(pluginName, 'Error setting lap count to 1', notificationErrorColor);
                print('error getting lap count offset');
            }
        }
    }
    // step for press button to step mode, no return so it can be made into CoroutineFunc for startnew (so it can yield)
    void step_debug() {
        this.step();
    }
    // attempts to add a single tracksection. Return is whether placement was successful, but is only used for debug
    bool step(bool ghost = false) {
        TrackSection@ previousSection = this.trackSections[this.trackSections.Length-1];
        this.generation_data.ChangeActivity(Activity::RandomlySelecting);
        uint thisBlockIndex = ChooseNextBlock(previousSection);
        this.generation_data.ChangeActivity(Activity::Processing);
        if (thisBlockIndex == 0) {// noWeight known for first check, but might not for second
            this.checkNoWeight();
            if (debugStepMode || debugLastBlock || debugPrint) {print('invalid (no weights on previous)');}
            return false;}
        if (debugStepMode) {print(''+Blocks[thisBlockIndex].NameID+': ' + tostring(Blocks[thisBlockIndex].startConnector) + ' -> ' + tostring(Blocks[thisBlockIndex].endConnector));}
        //print(this.map.GetBlock(previousSection.nextPosition + RotatePosition(Blocks[thisBlockIndex].endPosition, previousSection.nextDirection) + RotatePosition(int3(0,0,1), AddDirections(previousSection.nextDirection ,Blocks[thisBlockIndex].Direction))) !is null);
        //this.map.PlaceGhostBlock(this.map.GetBlockModelFromName("PlatformPlasticBaseWithHole24m"), previousSection.nextPosition + RotatePosition(Blocks[thisBlockIndex].endPosition, previousSection.nextDirection) + RotatePosition(int3(0,0,1), AddDirections(previousSection.nextDirection, Blocks[thisBlockIndex].Direction)), CGameEditorPluginMap::ECardinalDirections::North);
        //print('checking invalid for ' + (previousSection.nextPosition + RotatePosition(Blocks[thisBlockIndex].endPosition, previousSection.nextDirection)).ToString() + ', ' + AddDirections(previousSection.nextDirection, Blocks[thisBlockIndex].Direction) + ', ' + Blocks[thisBlockIndex].endConnector);
        if (!ghost) {
            int3 nextEndPosition = previousSection.nextPosition + RotatePosition(Blocks[thisBlockIndex].endPosition, previousSection.nextDirection) + RotatePosition(int3(0,0,1), AddDirections(previousSection.nextDirection, Blocks[thisBlockIndex].Direction));
            if (nextEndPosition.x < 0 || nextEndPosition.y < 0 || nextEndPosition.z < 0 || nextEndPosition.x >= int(this.mapSize.x) || nextEndPosition.y >= int(this.mapSize.y) || nextEndPosition.z >= int(this.mapSize.z)) {
                previousSection.removeWeight(thisBlockIndex);
                if (debugStepMode || debugLastBlock || debugPrint) {print('invalid (map size) ' + Blocks[thisBlockIndex].NameID);}
                this.checkNoWeight();
                return false;
            }
            CGameCtnBlock@ checkBlock = this.map.GetBlock(nextEndPosition);
            if (checkBlock !is null && checkBlock.BlockModel.IdName != "Grass") {// || checkBlock.IdName) {
                /*|| IsInvalid(this, previousSection.nextPosition + RotatePosition(Blocks[thisBlockIndex].endPosition, previousSection.nextDirection), AddDirections(previousSection.nextDirection, Blocks[thisBlockIndex].Direction), Blocks[thisBlockIndex].endConnector)*/
                previousSection.removeWeight(thisBlockIndex);
                if (debugStepMode || debugLastBlock || debugPrint) {print('invalid (ends at block) ' + Blocks[thisBlockIndex].NameID);}
                this.checkNoWeight();// won't choose a block that places the end at a wall
                return false;
            }
            if (debugStepMode) {print('not invalid');}
        }
        TrackSection@ nextSection = TrackSection(this, thisBlockIndex, ChooseNextColor(previousSection.thisColor));
        //if(!PlaceNextBlock(CurrentBlock)) {
        if (!nextSection.PlaceAttempt(ghost ? 2 : 0)) {
            if (debugShowFails) {nextSection.PlaceAttempt(1);}
            if (ghost) {print('place attempt failed');}

            this.trackSections[this.trackSections.Length-1].removeWeight(nextSection.blockIndex);
            this.checkNoWeight();
            return false;
        } else {
            this.trackSections.InsertLast(nextSection);
        }
        return true;
    }

    void checkNoWeight() {
        while (this.trackSections.Length > 1) { // will usually break when it finds a block with valid nexts
            float totalWeight = 0;
            TrackSection@ nextSection = this.trackSections[this.trackSections.Length-1];
            if (nextSection.error < errorTries) {
                for (uint i = 0; i < nextSection.weights.Length; i++) {
                    totalWeight += nextSection.weights[i];
                }
            }
            // print(totalWeight);
            // print(this.trackSections[this.trackSections.Length-1].startWeight * weightLoss + 0.0000000001);
            if (this.trackSections[this.trackSections.Length-1].startWeight >= 3.402823466e+38 || totalWeight <= this.trackSections[this.trackSections.Length-1].startWeight * weightLoss) {
                // print('removing last');
                nextSection.Undo();
                this.trackSections.RemoveLast();
                this.trackSections[this.trackSections.Length-1].removeWeight(nextSection.blockIndex);
            } else {
                break;
            }
        }
    }

    void debugBlock() {
        this.map.RemoveAllBlocksAndTerrain();

        // testing version - places each block from the start so I can check offset and next block
        if (Blocks[debugvalue] is null) {print('Trailing comma in blocks');}
        print(Blocks[debugvalue].NameID);
        for (uint i = 0; i < 4; i++) {
            this.trackSections = {TrackSection(this, CGameEditorPluginMap::ECardinalDirections(i))};
            for (uint i = 0; i < this.trackSections[0].weights.Length; i++) {
                if (Blocks[i].endConnector == Blocks[debugvalue].startConnector) {
                    this.trackSections[0].weights[i] *= 100;
                } else {
                    this.trackSections[0].weights[i] *= 0.1;
                }
            }
            this.step(true); // place a start
            if (this.trackSections.Length < 2) {
                print('didn\'t place start (debugBlock)');
                continue;
            }
            this.trackSections[1].weights[debugvalue] = 3.0e+38;

            if (!this.step(true)) {
                print('placement failed 1');
                continue;
            }

            if (Blocks[debugvalue].NameID != "") {
                this.trackSections[2].weights[debugvalue] = 3.0e+38;

                if (!this.step()) {
                    print('placement failed 2');
                } else {
                    this.trackSections[3].Undo();
                    this.trackSections.RemoveLast();
                    this.trackSections[this.trackSections.Length-1].removeWeight(debugvalue);
                    // this.trackSections[3].weights = array<float>(debugvalue+1);
                    // this.checkNoWeight();
                }
            }

            float weight4 = this.trackSections[this.trackSections.Length-1].weights[4];
            this.trackSections[this.trackSections.Length-1].weights[6] = 3.0e+38;
            this.step(true);

            this.trackSections.RemoveLast();
            this.trackSections[this.trackSections.Length-1].weights[6] = weight4;
            this.step();

        this.status = 1;


        }
        debugvalue--;
        this.Interrupt();
    }

    // debug to show the position where the track generator is.
    void showPosition() {
        if (GetApp() is null) {return;}
        if (GetApp().Editor is null) {
            UI::ShowNotification(pluginName, "Open the map editor", notificationErrorColor);
            return;}
        if (GetApp().CurrentPlayground !is null) {
            UI::ShowNotification(pluginName, "Return to editor", notificationErrorColor);
            return;}
        if (this.trackSections.Length == 0) {
            UI::ShowNotification(pluginName, "No current position", notificationErrorColor);
            return;}
        throw("");
        this.map.PlaceGhostBlock(this.map.GetBlockModelFromName("PlatformPlasticBaseWithHole24m"), this.trackSections[this.trackSections.Length-1].nextPosition, this.trackSections[this.trackSections.Length-1].nextDirection);
        this.map.PlaceGhostBlock(this.map.GetBlockModelFromName("PlatformDirtBaseWithHole24m"), this.trackSections[this.trackSections.Length-2].nextPosition, this.trackSections[this.trackSections.Length-2].nextDirection);
    }

    void Refreshmap() {
        // if (this.editor is null) return;
        // if (this.map is null) return;
        this.generation_data.CheckYield();
        this.map.AutoSave();
        this.generation_data.CheckYield();
        this.map.Undo();
        this.generation_data.CheckYield();
        this.map.Redo();
    }

}

uint64 GlobalFrameStartTime;
void Main() {
    // for (uint i = 0; i < GetApp().GlobalCatalog.Chapters[3].Articles.Length; i++) {
    //     print(cast<CGameCtnMacroBlockInfo@>(GetApp().GlobalCatalog.Chapters[3].Articles[i].LoadedNod).GeneratedBlockInfo.IdName);
    // }
    showInterface = debugOpenReload;
    GlobalFrameStartTime = Time::get_Now();
    if (GetApp() is null || GetApp().Editor is null) {showInterface = false;}

    // CGameEditorPluginMap@ editor = cast<CGameEditorPluginMap>(cast<CGameCtnEditorFree>(GetApp().Editor).PluginMapType);
    // for (uint i = 0; i < editor.BlockModels.Length; i++) {
    //     print(editor.BlockModels[i].Name);
    // }

    // I check the blocks when I add them by placing the latest block on reload (when the hardcoded debug setting is active)
    if (debugLastBlock) {
        LoadBlocks();
        @T = TrackGenerator(true);
    }

    while (true) {
        if (!(T is null)) {
            if (T.status == 0) {
                T.Start();
            }
        }
        if (T is null || !(T.status == 1)) {
            if (blocksStatus == LoadStatus::ToLoadAll) {
                LoadBlocks();
            } else if (blocksStatus == LoadStatus::ToLoadNonzeroWeight) {
                LoadBlocksNonzeroWeight();
            }
        }
        yield();
    }
}
/* air block mode is used when placing each block instead of deleting the support pillar after every block, even in simple editor.
 if the plugin is disabled while placing a block in simple editor, it will reset air mode so you can't reload it to keep air mode */
void OnDisabled() {
    if (!Permissions::OpenAdvancedMapEditor()) {
        CGameCtnEditorFree@ editor = cast<CGameCtnEditorFree>(GetApp().Editor);
        editor.ExperimentalFeatures.IsAutoAirMappingEnabled = false;
        editor.ExperimentalFeatures.AutoAirMapping_MaxPillarCount = 8;
    }
}
