
// controls placing a Block, and removing it if the next block can't be placed
class TrackSection {
    // index of the block for this TrackSection
    uint blockIndex;
    // the block this tracksection will try to place
    Block@ thisBlock;
    CGameEditorPluginMap::EMapElemColor thisColor;
    // the trackgenerator this tracksection is created by
    TrackGenerator@ generator;
    // the previous section of the trackgenerator
    TrackSection@ previousSection;
    // the position of the *end* of this TrackSection
    int3 nextPosition;
    // absolute direction
    CGameEditorPluginMap::ECardinalDirections nextDirection;
    // array of weights for the next block
    array<float>@ weights;
    float startWeight;
    // // the location at which this block is placed (will check this and actual position when removing)
    int3 placedAt = int3(-1,-1,-1);
    CGameEditorPluginMap::ECardinalDirections placedDirection;
    // approximate length since a checkpoint was placed
    uint error = 0;
    float Length = 0;
    uint PieceCount = 0;
    uint numCheckpoints = 0;
    float sinceLastCheckpoint = 0;
    // during a jump, this is the approximate length of the jump
    float jumpLength = 0;
    Cars currentCar = Cars::CarStadium;

    // Created after block choice with next block. Will then calculate weights for next block (if a next block's placement fails its weight will be set to 0)
    TrackSection(TrackGenerator@ T, uint blockIndex, CGameEditorPluginMap::EMapElemColor thisColor) {
        @this.generator = T;
        @this.previousSection = this.generator.trackSections[this.generator.trackSections.Length-1];
        this.blockIndex = blockIndex;
        this.thisColor = thisColor;
        @this.thisBlock = Blocks[blockIndex];
        this.Length = this.previousSection.Length + this.thisBlock.lengthAccurate;
        this.PieceCount = this.previousSection.PieceCount + 1;
        this.numCheckpoints = previousSection.numCheckpoints;
        if (this.thisBlock.tags.Find(Tags::Checkpoint) >= 0) {
            //print('Checkpoint after ' + previousSection.sinceLastCheckpoint + ' blocks');
            this.sinceLastCheckpoint = this.thisBlock.lengthAccurate - 1;
            this.numCheckpoints++;
        } else {
            this.sinceLastCheckpoint = this.previousSection.sinceLastCheckpoint + this.thisBlock.lengthAccurate;}
        if (this.thisBlock.endConnector == Connections::Jump || this.thisBlock.endConnector == Connections::JumpBlack || this.thisBlock.endConnector == Connections::JumpWhite) {
            if (this.thisBlock.startConnector == Connections::Jump || this.thisBlock.startConnector == Connections::JumpBlack || this.thisBlock.startConnector == Connections::JumpWhite) {
                this.jumpLength = previousSection.jumpLength + this.thisBlock.lengthAccurate;
            } else {
                if (this.thisBlock.tags.Find(Tags::DropJumpStart) != -1) {
                    this.jumpLength = 3;
                } else {
                    this.jumpLength = 0;
                }
            }
            if (this.thisBlock.NameID == "RoadTechRampMed") {
                this.jumpLength -= 1;
            }
            if (this.thisBlock.NameID == "RoadTechRampHigh") {
                this.jumpLength -= 2;
            }
            if (this.thisBlock.NameID == "RoadTechRampVeryHigh") {
                this.jumpLength -= 3;
            }
        }
        this.currentCar = previousSection.currentCar;
        if (this.thisBlock.tags.Find(Tags::CarStadium) != -1) {
            this.currentCar = Cars::CarStadium;
        } else if (this.thisBlock.tags.Find(Tags::CarSnow) != -1) {
            this.currentCar = Cars::CarSnow;
        } else if (this.thisBlock.tags.Find(Tags::CarRally) != -1) {
            this.currentCar = Cars::CarRally;
        } else if (this.thisBlock.tags.Find(Tags::CarDesert) != -1) {
            this.currentCar = Cars::CarDesert;
        }
        this.generator.generation_data.ChangeActivity(Activity::RandomlySelecting);
        @this.weights = GetWeights(this);
        this.generator.generation_data.ChangeActivity(Activity::Processing);
        // if (this.thisBlock.NameID == "" && this.thisBlock.length == 0) { // removed, PreviousNotEmpty tag instead
        //     for (uint i = 0; i < Blocks.Length; i++) {
        //         if (Blocks[i].NameID == "" && this.thisBlock.length == 0) {
        //             weights[i] = 0; // cannot chain no-length blocks when it encounters an edge
        //         }
        //     }
        // }
        this.nextPosition = this.previousSection.nextPosition + RotatePosition(this.thisBlock.endPosition, this.previousSection.nextDirection);
        this.nextDirection = AddDirections(this.previousSection.nextDirection, this.thisBlock.Direction);
    }

    // Creates the first TrackSection, without any previous
    TrackSection(TrackGenerator@ T) {
        @this.generator = T;
        @this.thisBlock = Blocks[0];
        if (this.thisBlock.tags.Find(Tags::CarStadium) != -1) {
            this.currentCar = Cars::CarStadium;
        } else if (this.thisBlock.tags.Find(Tags::CarSnow) != -1) {
            this.currentCar = Cars::CarSnow;
        } else if (this.thisBlock.tags.Find(Tags::CarRally) != -1) {
            this.currentCar = Cars::CarRally;
        } else if (this.thisBlock.tags.Find(Tags::CarDesert) != -1) {
            this.currentCar = Cars::CarDesert;
        }
        this.generator.generation_data.ChangeActivity(Activity::RandomlySelecting);
        @this.weights = GetWeights(this);
        this.generator.generation_data.ChangeActivity(Activity::Processing);
        this.generator.mapSize = this.generator.map.Map.Size;// max height 39 (38 if tall block such as start)

        // Determine start position based on settings
        if (StartAtCameraPosition) {
#if DEPENDENCY_CAMERA
            auto camera = Camera::GetCurrent();
            if (camera !is null) {
                // Use camera position as start location
                // iso4.tx, .ty, .tz are the translation/position components
                float camX = camera.Location.tx;
                float camY = camera.Location.ty;
                float camZ = camera.Location.tz;
                // Convert world position to grid coordinates (each block is 32x8x32 units)
                // Clamp to valid map bounds
                int x = Math::Clamp(int(camX / 32.0), 1, int(this.generator.mapSize.x) - 1);
                int y = Math::Clamp(int(camY / 8.0), 1, int(this.generator.mapSize.y) - 1);
                int z = Math::Clamp(int(camZ / 32.0), 1, int(this.generator.mapSize.z) - 1);
                this.nextPosition = int3(x, y, z);
            } else {
#endif
                // Camera plugin not available or no camera, use random position
                uint x = this.generator.mapSize.x/4;
                uint y = this.generator.mapSize.y/4;
                uint z = this.generator.mapSize.z/4;
                this.nextPosition = int3(Math::Rand(x, this.generator.mapSize.x - x),Math::Rand(y + y/2, this.generator.mapSize.y - y),Math::Rand(z, this.generator.mapSize.z - z));
#if DEPENDENCY_CAMERA
            }
#endif
        } else {
            // Use random position in the middle of the map
            uint x = this.generator.mapSize.x/4;
            uint y = this.generator.mapSize.y/4;
            uint z = this.generator.mapSize.z/4;
            this.nextPosition = int3(Math::Rand(x, this.generator.mapSize.x - x),Math::Rand(y + y/2, this.generator.mapSize.y - y),Math::Rand(z, this.generator.mapSize.z - z));
        }

        switch(Math::Rand(0, 4)) {
            case 0:
                this.nextDirection = CGameEditorPluginMap::ECardinalDirections::North;
            case 1:
                this.nextDirection = CGameEditorPluginMap::ECardinalDirections::East;
            case 2:
                this.nextDirection = CGameEditorPluginMap::ECardinalDirections::South;
            case 3:
                this.nextDirection = CGameEditorPluginMap::ECardinalDirections::West;
            default:
                this.nextDirection = CGameEditorPluginMap::ECardinalDirections::North;
        }
    }

    // Creates a first TrackSection with a specified direction, for debugstep
    TrackSection(TrackGenerator@ T, CGameEditorPluginMap::ECardinalDirections direction) {
        @this.generator = T;
        @this.thisBlock = Blocks[0];
        if (this.thisBlock.tags.Find(Tags::CarStadium) != -1) {
            this.currentCar = Cars::CarStadium;
        } else if (this.thisBlock.tags.Find(Tags::CarSnow) != -1) {
            this.currentCar = Cars::CarSnow;
        } else if (this.thisBlock.tags.Find(Tags::CarRally) != -1) {
            this.currentCar = Cars::CarRally;
        } else if (this.thisBlock.tags.Find(Tags::CarDesert) != -1) {
            this.currentCar = Cars::CarDesert;
        }
        // @this.weights = GetWeights(this.generator, Connections::Start, 0, 0, false, this.startWeight);
        this.generator.generation_data.ChangeActivity(Activity::RandomlySelecting);
        @this.weights = GetWeights(this);
        this.generator.generation_data.ChangeActivity(Activity::Processing);
        this.generator.mapSize = generator.map.Map.Size;// max height 39 (38 if tall block such as start)
        this.nextDirection = direction;
        this.nextPosition = int3(24,15+uint(direction)*3,24);
        //@this.thisBlock = Blocks[ChooseNextBlock(this)];
    }

    bool PlaceAttemptMacroblock(uint ghost) {
        this.generator.map.NextMapElemColor = this.thisColor;
        string macroblocknameid = this.thisBlock.NameID.SubStr(11);

        CGameCtnMacroBlockInfo@ macroblock;
        if (macroblocknameid.Contains(':')) {
            string nameid = macroblocknameid.Split(':')[0];
            @macroblock = this.generator.map.GetMacroblockModelFromFilePath(nameid);
            if (macroblock is null) {
                print("unknown macroblock: " + nameid);
                return false;}
        } else {
            @macroblock = this.generator.map.GetMacroblockModelFromFilePath(macroblocknameid);
            if (macroblock is null) {
                print("unknown macroblock: " + macroblocknameid);
                return false;}
        }
        while (!this.generator.map.IsEditorReadyForRequest) {
            this.generator.generation_data.Yield(YieldReason::EditorNotReady);
        }
        this.generator.generation_data.ChangeActivity(Activity::PlacingBlock);
        this.placedAt = this.previousSection.nextPosition + this.thisBlock.PositionOffset[this.previousSection.nextDirection];
        this.placedDirection = AddDirections(this.previousSection.nextDirection, this.thisBlock.RotationOffset);
        bool hasplaced = false;
        if (ghost > 0) { // called if debug, to place the block as ghost in the same position
            CGameEditorMapMacroBlockInstance@ MacroblockInstance = this.generator.map.CreateMacroblockInstance(macroblock, nat3(this.placedAt.x ,this.placedAt.y, this.placedAt.z), this.placedDirection, this.thisColor, true);
            if (this.generator.map.PlaceMacroblock_AirMode(MacroblockInstance.MacroblockModel, this.placedAt, this.placedDirection)) {
                this.generator.generation_data.ChangeActivity(Activity::Processing);
                hasplaced = true;
            } else if (debugPrint) {
                print('place failed (no ghost mode for macroblock)');
                print('' + this.previousSection.nextPosition.ToString() + ' ' + this.thisBlock.PositionOffset[this.previousSection.nextDirection].ToString() + ' ' + this.placedDirection);
            }
        } else {
            CGameEditorMapMacroBlockInstance@ MacroblockInstance = this.generator.map.CreateMacroblockInstance(macroblock, nat3(this.placedAt.x ,this.placedAt.y, this.placedAt.z), this.placedDirection, this.thisColor, true);
            if (MacroblockInstance is null) {
                if (debugPrint) {print('null macroblock pre-place instance');}
                return false;
            }
            if (_CheckPlaceAbove(this.thisBlock.startConnector, this.thisBlock.endConnector)) {
                if (!this.generator.map.PlaceMacroblock_AirMode(MacroblockInstance.MacroblockModel, this.placedAt + int3(0,1,0), this.placedDirection)){
                    return false;
                }
                if (!this.generator.map.RemoveMacroblock(MacroblockInstance.MacroblockModel, this.placedAt + int3(0,1,0), this.placedDirection)) {
                    if (debugPrint) {print('failed to remove ' + this.thisBlock.NameID + ' (during above check)');}
                    if(!this.generator.map.RemoveBlock(this.placedAt + int3(0,1,0))) {
                        if (debugPrint) {print('failed to remove any block (during above check)');}
                    }
                    if (debugPrint) {print('Removed a block, so assume it changed to support pillar when placed');}
                }
            }
            if (verticalSeparation) {
                if (!this.generator.map.PlaceMacroblock_AirMode(MacroblockInstance.MacroblockModel, this.placedAt + int3(0,-1,0), this.placedDirection)){
                    return false;
                }
                if (!this.generator.map.RemoveMacroblock(MacroblockInstance.MacroblockModel, this.placedAt + int3(0,-1,0), this.placedDirection)) {
                    if (debugPrint) {print('failed to remove ' + this.thisBlock.NameID + ' (during below check)');}
                    if(!this.generator.map.RemoveBlock(this.placedAt + int3(0,-1,0))) {
                        if (debugPrint) {print('failed to remove any block (during below check)');}
                    }
                    if (debugPrint) {print('Removed a block, so assume it changed to support pillar when placed (below check)');}
                    return false; // if it converted to a pillar when placed below, it won't fit above anyway
                }
            }
            this.generator.generation_data.ChangeActivity(Activity::PlacingBlock);
            hasplaced = this.generator.map.PlaceMacroblock_AirMode(MacroblockInstance.MacroblockModel, this.placedAt, this.placedDirection);
            this.generator.generation_data.ChangeActivity(Activity::Processing);
        }
        if (hasplaced) {
            CGameEditorMapMacroBlockInstance@ placedMacroblock = this.generator.map.GetMacroblockInstanceFromUnitCoord(this.placedAt);
            CGameCtnBlock@ placedBlock = this.generator.map.GetBlock(this.placedAt);
            if (placedMacroblock is null) {
                print('null macroblock');
                uint8 u = 0;
                if (this.generator.map.GetLatestMacroblockInstance() is null) {
                    print('null latest macroblock');
                    u += 1;
                }
                if (placedBlock is null) {
                    if (debugPrint) {print("no block found where macroblock was placed (this may not be an error)");}
                    u += 1;
                }
                if (u == 2) {
                    this.generator.generation_data.ChangeActivity(Activity::Undoing);
                    this.Undo();
                    this.generator.generation_data.ChangeActivity(Activity::Processing);
                    return false;
                }
            }
            // multi-block overlays place extra ghost blocks
            if (this.thisBlock.NameID.Contains(':')) {
                CGameCtnBlockInfo@ blockType;
                string[] overlays = this.thisBlock.NameID.Split(':');
                for (uint i = 2; i < overlays.Length; i++) {
                    @blockType = this.generator.map.GetBlockModelFromName(overlays[i]);
                    if (blockType is null) {
                        if (debugPrint) {print("unknown block overlay: " + overlays[i]);}
                        continue;}
                    if (this.generator.map.PlaceGhostBlock(blockType, this.placedAt, this.placedDirection)) {
                        // placed overlay
                    } else if (debugPrint) {print('overlay place failed');}
                }
            }
            if (!(placedMacroblock is null)) {
                if (thisBlock.tags.Find(Tags::Finish) >= 0) {
                    if (EnableCustomSigns && CustomStartFinishSignURL != "") {
                        this.generator.map.SetMacroblockSkin(placedMacroblock, CustomStartFinishSignURL);
                        this.generator.map.AutoSave();
                    }
                    this.generator.Finish();
                } else if ((this.thisBlock.tags.Find(Tags::Start) >= 0)) {
                    if (EnableCustomSigns && CustomStartFinishSignURL != "") {
                        this.generator.map.SetMacroblockSkin(placedMacroblock, CustomStartFinishSignURL);
                        this.generator.map.AutoSave();
                    }
                    // In One Type Only Mode, place selected effect after start
                    if (OneTypeOnlyMode) {
                        _PlaceCheckpointEffect();
                    }
                } else if ((this.thisBlock.tags.Find(Tags::Checkpoint) >= 0)) {
                    if (EnableCustomSigns && CustomCheckpointSignURL != "") {
                        this.generator.map.SetMacroblockSkin(placedMacroblock, CustomCheckpointSignURL);
                        this.generator.map.AutoSave();
                    } else if (!EnableCustomSigns) {
                        // Clear any existing skin when custom signs are disabled
                        this.generator.map.SetMacroblockSkin(placedMacroblock, "");
                    }
                    // In One Type Only Mode, place selected effect after checkpoints
                    if (OneTypeOnlyMode) {
                        _PlaceCheckpointEffect();
                    }
                } else if ((this.thisBlock.tags.Find(Tags::Multilap) >= 0)) {
                    if (EnableCustomSigns && CustomCheckpointSignURL != "") {
                        this.generator.map.SetMacroblockSkin(placedMacroblock, CustomCheckpointSignURL);
                        this.generator.map.AutoSave();
                    } else if (!EnableCustomSigns) {
                        // Clear any existing skin when custom signs are disabled
                        this.generator.map.SetMacroblockSkin(placedMacroblock, "");
                    }
                }
            }
            return true;
        }
        this.generator.generation_data.ChangeActivity(Activity::Processing);
        return false;
    }

    // attempts to place a block ingame. Will call success function, or return false if failed
    bool PlaceAttempt(uint ghost = 0) { // ghost 0 is normal, 1 is show fail, 2 is just place ghost for debug
        if (this.thisBlock.NameID == "") {
            //print(tostring(this.thisBlock.startConnector) + ' ' + tostring(this.thisBlock.endConnector));
            return true;
        } else if (this.thisBlock.NameID.StartsWith("Macroblock:")) {
            return PlaceAttemptMacroblock(ghost);
        }
        this.generator.map.NextMapElemColor = this.thisColor;
        CGameCtnBlockInfo@ blockType;
        if (this.thisBlock.NameID.Contains(':')) {
            string nameid = this.thisBlock.NameID.Split(':')[0];
            @blockType = this.generator.map.GetBlockModelFromName(nameid);
            if (blockType is null) {
                print("unknown block: " + nameid);
                return false;}
        } else {
            @blockType = this.generator.map.GetBlockModelFromName(this.thisBlock.NameID);
            if (blockType is null) {
                print("unknown block: " + this.thisBlock.NameID);
                return false;}
        }
        while (!this.generator.map.IsEditorReadyForRequest) {
            this.generator.generation_data.Yield(YieldReason::EditorNotReady);
        }
        this.generator.generation_data.ChangeActivity(Activity::PlacingBlock);
        this.placedAt = this.previousSection.nextPosition + this.thisBlock.PositionOffset[this.previousSection.nextDirection];
        this.placedDirection = AddDirections(this.previousSection.nextDirection, this.thisBlock.RotationOffset);
        bool hasplaced = false;
        if (ghost > 0) { // called if debug, to place the block as ghost in the same position
            if (this.generator.map.PlaceGhostBlock(blockType, this.placedAt, this.placedDirection)) {
                hasplaced = true;
            } else if (debugPrint) {
                print('ghost place failed');
                print('' + this.previousSection.nextPosition.ToString() + ' ' + this.thisBlock.PositionOffset[this.previousSection.nextDirection].ToString() + ' ' + this.placedDirection);
            }
            this.generator.generation_data.ChangeActivity(Activity::Processing);
        } else {
            if (_CheckPlaceAbove(this.thisBlock.startConnector, this.thisBlock.endConnector)) {
                if (!this.generator.map.PlaceBlock(blockType, this.placedAt + int3(0,1,0), this.placedDirection)){
                    return false;
                }
                if (!this.generator.map.RemoveBlockSafe(blockType, this.placedAt + int3(0,1,0), this.placedDirection)) {
                    if (debugPrint) {print('failed to remove ' + this.thisBlock.NameID + ' (during above check)');}
                    if(!this.generator.map.RemoveBlock(this.placedAt + int3(0,1,0))) {
                        if (debugPrint) {print('failed to remove any block (during above check)');}
                    }
                    if (debugPrint) {print('Removed a block, so assume it changed to support pillar when placed (above check)');}
                }
            }
            if (verticalSeparation) {
                if (!this.generator.map.PlaceBlock(blockType, this.placedAt + int3(0,-1,0), this.placedDirection)){
                    return false;
                }
                if (!this.generator.map.RemoveBlockSafe(blockType, this.placedAt + int3(0,-1,0), this.placedDirection)) {
                    if (debugPrint) {print('failed to remove ' + this.thisBlock.NameID + ' (during below check)');}
                    if(!this.generator.map.RemoveBlock(this.placedAt + int3(0,-1,0))) {
                        if (debugPrint) {print('failed to remove any block (during below check)');}
                    }
                    if (debugPrint) {print('Removed a block, so assume it changed to support pillar when placed (below check)');}
                    return false; // if it converted to a pillar when placed below, it won't fit above anyway
                }
            }
            this.generator.generation_data.ChangeActivity(Activity::PlacingBlock);
            this.generator.editor.ExperimentalFeatures.IsAutoAirMappingEnabled = true; // enabling air mode temporarily to place block (simple editor players can delete supports, so air-placed blocks are obtainable there)
            this.generator.editor.ExperimentalFeatures.AutoAirMapping_MaxPillarCount = 0;
            hasplaced = this.generator.map.PlaceBlock(blockType, this.placedAt, this.placedDirection);
            this.generator.editor.ExperimentalFeatures.IsAutoAirMappingEnabled = this.generator.startAirMode; // resetting instantly after placing block, so if in simple editor this can't be abused
            this.generator.editor.ExperimentalFeatures.AutoAirMapping_MaxPillarCount = this.generator.startMaxPillarCount;
            this.generator.generation_data.ChangeActivity(Activity::Processing);
        }
        if (hasplaced) {
            if (ghost == 0) {
                CGameCtnBlock@ placedBlock = this.generator.map.GetBlockSafe(blockType, this.placedAt, this.placedDirection);
                if (placedBlock is null || !(placedBlock.BlockModel.IdName == blockType.IdName)) {
                    if (debugPrint) {print("Block placed wrong, is placed block different?: " + (placedBlock is null));}
                    if (!(placedBlock is null)) {
                        if (debugPrint) {print("Block placed wrong, is block name correct?: " + placedBlock.BlockModel.IdName + " " + blockType.IdName);}
                    }
                    this.generator.generation_data.ChangeActivity(Activity::Undoing);
                    this.Undo();
                    this.generator.generation_data.ChangeActivity(Activity::Processing);
                    return false;
                }
            }
            // multi-block overlays place extra ghost blocks
            if (this.thisBlock.NameID.Contains(':')) {
                string[] overlays = this.thisBlock.NameID.Split(':');
                for (uint i = 1; i < overlays.Length; i++) {
                    @blockType = this.generator.map.GetBlockModelFromName(overlays[i]);
                    if (blockType is null) {
                        if (debugPrint) {print("unknown block overlay: " + overlays[i]);}
                        continue;}
                    if (this.generator.map.PlaceGhostBlock(blockType, this.placedAt, this.placedDirection)) {
                        // placed overlay
                    } else if (debugPrint) {print('overlay place failed');}
                }
            }
            if (ghost == 0) {
                this._OnPlaceSuccess();
            }
            return true;
        }
        return false;
    }
    // after successfully placing a block, check if it needs a skin, and if its a finish
    void _OnPlaceSuccess() {
        CGameCtnBlock@ placedBlock = this.generator.map.GetBlock(this.placedAt);
        if (placedBlock is null) {
            if (debugPrint) {print('placed block is null ' + Blocks[this.blockIndex].NameID);}
            // this.generator.map.PlaceGhostBlock(this.generator.map.GetBlockModelFromName("PlatformPlasticBaseWithHole24m"), this.placedAt, CGameEditorPluginMap::ECardinalDirections::North);
            return;}
        //print(placedBlock.BlockInfoVariantIndex);
        if (thisBlock.tags.Find(Tags::Finish) >= 0) {
            if (EnableCustomSigns && CustomStartFinishSignURL != "") {
                this.generator.map.SetBlockSkin(placedBlock, CustomStartFinishSignURL);
                this.generator.map.AutoSave();
            }
            this.generator.Finish();
        } else if ((this.thisBlock.tags.Find(Tags::Start) >= 0)) {
            if (EnableCustomSigns && CustomStartFinishSignURL != "") {
                this.generator.map.SetBlockSkin(placedBlock, CustomStartFinishSignURL);
                this.generator.map.AutoSave();
            }
            // In One Type Only Mode, place selected effect after start
            if (OneTypeOnlyMode) {
                _PlaceCheckpointEffect();
            }
        } else if ((this.thisBlock.tags.Find(Tags::Checkpoint) >= 0 || this.thisBlock.tags.Find(Tags::Multilap) >= 0)) {
            if (EnableCustomSigns && CustomCheckpointSignURL != "") {
                this.generator.map.SetBlockSkin(placedBlock, CustomCheckpointSignURL);
                this.generator.map.AutoSave();
            } else if (!EnableCustomSigns) {
                // Clear any existing skin when custom signs are disabled
                this.generator.map.SetBlockSkin(placedBlock, "");
            }
            // In One Type Only Mode, place selected effect after checkpoints
            if (OneTypeOnlyMode) {
                _PlaceCheckpointEffect();
            }
        } else if (OneTypeOnlyMode) {
            // In One Type Only Mode, check if we should place a checkpoint item on this regular block
            // Only place checkpoints on straight blocks to ensure proper alignment
            if (_IsStraightBlock() && _ShouldPlaceCheckpoint()) {
                _PlaceCheckpointItem();
            }
        }
    }

    // Places the selected checkpoint effect ghost block at the next position after current block
    void _PlaceCheckpointEffect() {
        // Adjust height for non-SnowRoad surfaces before calling the overload
        int3 effectPos = this.nextPosition;
        if (!_IsSnowRoad()) {
            effectPos = effectPos + int3(0, -1, 0);
        }
        _PlaceCheckpointEffect(effectPos, this.nextDirection);
    }

    // Overload: Place checkpoint effect at a specific position/direction
    void _PlaceCheckpointEffect(int3 pos, CGameEditorPluginMap::ECardinalDirections dir) {
        // Don't place anything if effect is None
        if (CheckpointEffect == CheckpointEffectType::None) {
            return;
        }

        // Map effect type to block name and rotation
        string blockName = "";
        bool useReverseDirection = false;

        switch (CheckpointEffect) {
            case CheckpointEffectType::ReactorDown:
                blockName = "GateSpecialBoost";
                useReverseDirection = true; // Down variant
                break;
            case CheckpointEffectType::ReactorUp:
                blockName = "GateSpecialBoost";
                useReverseDirection = false; // Up variant
                break;
            case CheckpointEffectType::NoEngine:
                blockName = "GateSpecialNoEngine";
                useReverseDirection = false;
                break;
            case CheckpointEffectType::NoBrake:
                blockName = "GateSpecialNoBrake";
                useReverseDirection = false;
                break;
            case CheckpointEffectType::Cruise:
                blockName = "GateSpecialCruise";
                useReverseDirection = false;
                break;
            case CheckpointEffectType::Fragile:
                blockName = "GateSpecialFragile";
                useReverseDirection = false;
                break;
        }

        if (blockName == "") {
            return;
        }

        CGameCtnBlockInfo@ effectBlock = this.generator.map.GetBlockModelFromName(blockName);
        if (effectBlock is null) {
            if (debugPrint) {print('Could not find ' + blockName + ' block');}
            return;
        }

        // Apply reverse direction if needed (for down variant)
        CGameEditorPluginMap::ECardinalDirections effectDirection = useReverseDirection ? AddDirections(dir, Directions::Reverse) : dir;

        if (this.generator.map.PlaceGhostBlock(effectBlock, pos, effectDirection)) {
            if (debugPrint) {print('Placed checkpoint effect: ' + blockName);}
        } else {
            if (debugPrint) {print('Failed to place checkpoint effect: ' + blockName);}
        }
    }

    // Places a checkpoint gate item on the current block position (used for Wood Only Mode)
    void _PlaceCheckpointItem() {
        CGameCtnBlockInfo@ checkpointBlock = this.generator.map.GetBlockModelFromName("GateCheckpoint");
        if (checkpointBlock is null) {
            if (debugPrint) {print('Could not find GateCheckpoint block');}
            return;
        }
        // Adjust height for non-SnowRoad surfaces (place lower)
        int3 itemPos = this.placedAt;
        if (!_IsSnowRoad()) {
            itemPos = itemPos + int3(0, -1, 0);
        }
        // Place at the current block position with the driving direction (nextDirection)
        if (this.generator.map.PlaceGhostBlock(checkpointBlock, itemPos, this.nextDirection)) {
            // Clear or set the skin based on EnableCustomSigns
            uint itemCount = this.generator.map.Items.Length;
            if (itemCount > 0) {
                CGameCtnEditorScriptAnchoredObject@ lastItem = this.generator.map.Items[itemCount - 1];
                if (lastItem !is null) {
                    if (EnableCustomSigns && CustomCheckpointSignURL != "") {
                        this.generator.map.SetItemSkin(lastItem, CustomCheckpointSignURL);
                    } else {
                        // Clear the skin by setting it to empty string
                        this.generator.map.SetItemSkin(lastItem, "");
                    }
                }
            }

            if (debugPrint) {print('Placed checkpoint item');}
            // Reset sinceLastCheckpoint and increment numCheckpoints
            this.sinceLastCheckpoint = this.thisBlock.lengthAccurate - 1;
            this.numCheckpoints++;
            // Also place selected effect after the checkpoint, at the same position/height as the item
            _PlaceCheckpointEffect(itemPos, this.nextDirection);
        } else {
            if (debugPrint) {print('Failed to place checkpoint item');}
        }
    }

    // Checks if the current block is straight (no turns, no tilts) for proper checkpoint item placement
    bool _IsStraightBlock() {
        // Block is straight if it doesn't change direction and ends at (0,?,1) relative position
        // Also check it's not tilted or curved
        return this.thisBlock.Direction == Directions::Forwards &&
               this.thisBlock.endPosition.x == 0 &&
               this.thisBlock.endPosition.z == 1;
    }

    // Checks if the current block uses SnowRoad connections
    bool _IsSnowRoad() {
        Connections conn = this.thisBlock.endConnector;
        return conn == Connections::SnowRoadFlat ||
               conn == Connections::SnowRoadSlopeUp ||
               conn == Connections::SnowRoadSlopeDown ||
               conn == Connections::SnowRoadTiltLeft ||
               conn == Connections::SnowRoadTiltRight;
    }

    // Checks if it's time to place a checkpoint based on distance, using probability
    bool _ShouldPlaceCheckpoint() {
        // Don't place checkpoints too close together - enforce minimum distance of 60% of target
        float minDistance = CheckpointDistance * 0.6;
        if (this.sinceLastCheckpoint < minDistance) {
            return false;
        }

        // Always place if we're way over the target distance (150% of target)
        if (this.sinceLastCheckpoint >= CheckpointDistance * 1.5) {
            return true;
        }

        // Use probability-based placement between min and max distance
        // Weight = 2 * CheckpointDistance * Math::Pow(2., sinceLastCheckpoint - CheckpointDistance)
        float cpWeight = 2.0 * CheckpointDistance * Math::Pow(2., this.sinceLastCheckpoint - CheckpointDistance);
        // Normalize to a probability (cap at 1.0)
        float probability = Math::Min(cpWeight / (cpWeight + 20.0), 1.0);
        return Math::Rand(0.0, 1.0) < probability;
    }

    void removeWeight(uint index) {
        this.weights[index] = 0;

        this.error++;
        if (Blocks[index].startConnector == Blocks[index].endConnector && Blocks[index].Direction == Directions::Forwards && Blocks[index].endPosition == int3(0,0,1)) {
            for (uint i = 0; i < StraightBlocks[Blocks[index].startConnector].Length; i++) {
                if (StraightBlocks[Blocks[index].startConnector][i] >= this.weights.Length) {
                    print('StraightBlocks index out of weights');
                } else {
                    this.weights[StraightBlocks[Blocks[index].startConnector][i]] = 0;
                }
            }
        }
        if (Blocks[index].startConnector == Blocks[index].endConnector && Blocks[index].Direction == Directions::Forwards && Blocks[index].endPosition == int3(0,1,1)) {
            for (uint i = 0; i < StraightBlocks_up[Blocks[index].startConnector].Length; i++) {
                if (StraightBlocks_up[Blocks[index].startConnector][i] >= this.weights.Length) {
                    print('StraightBlocks_up index out of weights');
                } else {
                    this.weights[StraightBlocks_up[Blocks[index].startConnector][i]] = 0;
                }
            }
        }
        if (Blocks[index].startConnector == Blocks[index].endConnector && Blocks[index].Direction == Directions::Forwards && Blocks[index].endPosition == int3(0,-1,1)) {
            for (uint i = 0; i < StraightBlocks_down[Blocks[index].startConnector].Length; i++) {
                if (StraightBlocks_down[Blocks[index].startConnector][i] >= this.weights.Length) {
                    print('StraightBlocks_down index out of weights');
                } else {
                    this.weights[StraightBlocks_down[Blocks[index].startConnector][i]] = 0;
                }
            }
        }
        if (Blocks[index].startConnector == Blocks[index].endConnector && Blocks[index].Direction == Directions::Forwards && Blocks[index].endPosition == int3(0,2,1)) {
            for (uint i = 0; i < StraightBlocks_up2[Blocks[index].startConnector].Length; i++) {
                if (StraightBlocks_up2[Blocks[index].startConnector][i] >= this.weights.Length) {
                    print('StraightBlocks_up2 index out of weights');
                } else {
                    this.weights[StraightBlocks_up2[Blocks[index].startConnector][i]] = 0;
                }
            }
        }
        if (Blocks[index].startConnector == Blocks[index].endConnector && Blocks[index].Direction == Directions::Forwards && Blocks[index].endPosition == int3(0,-2,1)) {
            for (uint i = 0; i < StraightBlocks_down2[Blocks[index].startConnector].Length; i++) {
                if (StraightBlocks_down2[Blocks[index].startConnector][i] >= this.weights.Length) {
                    print('StraightBlocks_down2 index out of weights');
                } else {
                    this.weights[StraightBlocks_down2[Blocks[index].startConnector][i]] = 0;
                }
            }
        }
        // if (Blocks[index].startConnector == Blocks[index].endConnector && Blocks[index].Direction == Directions::Forwards && Blocks[index].endPosition == int3(0,0,0)) {
        //     for (uint i = 0; i < StraightBlocks_empty[Blocks[index].startConnector].Length; i++) {
        //         if (StraightBlocks_empty[Blocks[index].startConnector][i] >= this.weights.Length) {
        //             print('StraightBlocks_empty index out of weights');
        //         } else {
        //             this.weights[StraightBlocks_empty[Blocks[index].startConnector][i]] = 0;
        //         }
        //     }
        // }
    }

    // if all next blocks fail, will need to remove its block
    void Undo() {
        if (this.thisBlock.NameID == "") {return;}
        if (this.thisBlock.NameID.StartsWith("Macroblock:")) {UndoMacroblock(); return;}
        CGameCtnBlockInfo@ blockType;
        if (this.thisBlock.NameID.Contains(':')) {
            string nameid = this.thisBlock.NameID.Split(':')[0];
            @blockType = this.generator.map.GetBlockModelFromName(nameid);
            if (blockType is null) {
                print("unknown block (undo): " + nameid);
                return;}
        } else {
            @blockType = this.generator.map.GetBlockModelFromName(this.thisBlock.NameID);
            if (blockType is null) {
                print("unknown block (undo): " + this.thisBlock.NameID);
                return;}
        }
        // CGameEditorPluginMap::ECardinalDirections direction = AddDirections(this.previousSection.nextDirection, this.thisBlock.RotationOffset);
        // some blocks don't have any hitbox in their lower corner; can depend on rotation
        if (!(this.generator.map.RemoveBlockSafe(blockType, this.placedAt, this.placedDirection))) {
            if (debugPrint) {print('failed to remove ' + this.thisBlock.NameID + ' at ' + tostring(this.placedAt) + ' (this can happen if it has a weird hitbox, or if it connects to the block above)');}
            //if (!(this.generator.map.RemoveBlockSafe(blockType, this.previousSection.nextPosition, this.placedDirection))) {
            //    //print('didn\'t remove at nextposition ' + this.thisBlock.NameID);
            if (!(this.generator.map.RemoveBlock(this.placedAt))) {
                if (debugPrint) {print('failed to remove at placedAt with any-block remove');}
            }
        }
        // multi-block overlays place extra ghost blocks, need to remove them
        if (this.thisBlock.NameID.Contains(':')) {
            string[] overlays = this.thisBlock.NameID.Split(':');
            for (uint i = 1; i < overlays.Length; i++) {
                @blockType = this.generator.map.GetBlockModelFromName(overlays[i]);
                if (blockType is null) {
                    print("unknown block overlay (undo): " + overlays[i]);
                    continue;}
                if (this.generator.map.RemoveGhostBlock(blockType, this.placedAt, this.placedDirection)) {
                    // placed overlay
                } else if (debugPrint) {print('overlay undo failed');}
            }
        }
    }
    void UndoMacroblock() {
        string macroblocknameid = this.thisBlock.NameID.SubStr(11);
        CGameCtnMacroBlockInfo@ macroblock;
        if (macroblocknameid.Contains(':')) {
            string nameid = macroblocknameid.Split(':')[0];
            @macroblock = this.generator.map.GetMacroblockModelFromFilePath(nameid);
            if (macroblock is null) {
                print("unknown macroblock: " + nameid);
                return;}
        } else {
            @macroblock = this.generator.map.GetMacroblockModelFromFilePath(macroblocknameid);
            if (macroblock is null) {
                print("unknown macroblock: " + macroblocknameid);
                return;}
        }
        if (!(this.generator.map.RemoveMacroblock(macroblock, this.placedAt, this.placedDirection))) {
            if (debugPrint) {print('failed to remove macroblock ' + this.thisBlock.NameID + ' (this can happen if it has a weird hitbox, or if it connects to the block above)');}
        }
        // multi-block overlays place extra ghost blocks, need to remove them
        CGameCtnBlockInfo@ blockType;
        if (this.thisBlock.NameID.Contains(':')) {
            string[] overlays = this.thisBlock.NameID.Split(':');
            for (uint i = 2; i < overlays.Length; i++) {
                @blockType = this.generator.map.GetBlockModelFromName(overlays[i]);
                if (blockType is null) {
                    print("unknown block overlay (undo): " + overlays[i]);
                    continue;}
                if (this.generator.map.RemoveGhostBlock(blockType, this.placedAt, this.placedDirection)) {
                    // placed overlay
                } else if (debugPrint) {print('overlay undo failed');}
            }
        }
    }
}

bool _CheckPlaceAbove(Connections c, Connections d) {
    switch(c) {case(Connections::TrackWallFlat): case(Connections::TrackWallDiagLeft): case(Connections::TrackWallDiagRight): case(Connections::TrackWallSlopeDown): case(Connections::DecoWallFlat): case(Connections::DecoWallSlopeDown): case(Connections::Structure): case(Connections::StagePlatform):  case(Connections::StageLeft):  case(Connections::StageRight): case(Connections::StageSupportPlatform):  case(Connections::StageSupportLeft):  case(Connections::StageSupportRight):  case(Connections::SnowRoadFlat):  case(Connections::SnowRoadSlopeUp):  case(Connections::SnowRoadSlopeDown):  case(Connections::SnowRoadTiltLeft):  case(Connections::SnowRoadTiltRight):
        return true;}
    switch(d) {case(Connections::TrackWallFlat): case(Connections::TrackWallDiagLeft): case(Connections::TrackWallDiagRight): case(Connections::TrackWallSlopeUp): case(Connections::DecoWallFlat): case(Connections::DecoWallSlopeUp): case(Connections::Structure): case(Connections::StagePlatform):  case(Connections::StageLeft):  case(Connections::StageRight): case(Connections::StageSupportPlatform):  case(Connections::StageSupportLeft):  case(Connections::StageSupportRight):  case(Connections::SnowRoadFlat):  case(Connections::SnowRoadSlopeUp):  case(Connections::SnowRoadSlopeDown):  case(Connections::SnowRoadTiltLeft):  case(Connections::SnowRoadTiltRight):
        return true;}
    return false;
}