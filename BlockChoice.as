
// Checks if a connector is a SnowRoad type connector
bool IsSnowRoadConnector(Connections conn) {
    return conn == Connections::SnowRoadFlat ||
           conn == Connections::SnowRoadSlopeDown ||
           conn == Connections::SnowRoadSlopeUp ||
           conn == Connections::SnowRoadTiltLeft ||
           conn == Connections::SnowRoadTiltRight;
}

// Checks if two connectors are compatible (normally must match exactly, but with Chaotic Wood Connections any SnowRoad connectors match)
bool ConnectorsCompatible(Connections endConn, Connections startConn) {
    if (endConn == startConn) {
        return true;
    }
    // With Chaotic Wood Connections, any SnowRoad connector can connect to any other SnowRoad connector
    if (WoodChaoticConnections && IsSnowRoadConnector(endConn) && IsSnowRoadConnector(startConn)) {
        return true;
    }
    return false;
}

// Creates an array of weights representing the weight for each block
array<float> GetWeights(TrackSection@ currentSection) {
    float length;
    length = currentSection.Length;
    array<float> weights(Blocks.Length, 0);
    currentSection.startWeight = 0;
    bool previousEmpty = currentSection.thisBlock.NameID == "" && currentSection.thisBlock.lengthAccurate == 0;

    for (uint i = 0; i < Blocks.Length; i++) {
        if (Blocks[i] is null) {print('Maybe trailing comma in blocks list?');}
        // Wood Only Mode: only allow SnowRoad blocks, finish, start - no car gates, boosters, or checkpoints (we place CP items instead)
        if (WoodOnlyMode) {
            bool isSnowRoad = Blocks[i].tags.Find(Tags::SnowRoad) != -1;
            bool isCheckpoint = Blocks[i].tags.Find(Tags::Checkpoint) != -1;
            bool isFinish = Blocks[i].tags.Find(Tags::Finish) != -1;
            bool isStart = Blocks[i].tags.Find(Tags::Start) != -1;
            bool isCarGate = (Blocks[i].tags.Find(Tags::CarStadium) != -1 || Blocks[i].tags.Find(Tags::CarSnow) != -1 || Blocks[i].tags.Find(Tags::CarRally) != -1 || Blocks[i].tags.Find(Tags::CarDesert) != -1);
            // Filter out all boost/reactor blocks - we only place reactor down manually at CPs and start
            bool isBooster = Blocks[i].tags.Find(Tags::BoostUp) != -1 || Blocks[i].tags.Find(Tags::BoostDown) != -1 || Blocks[i].tags.Find(Tags::Boost2Up) != -1 || Blocks[i].tags.Find(Tags::Boost2Down) != -1;
            if (isBooster) {
                continue;
            }
            // Filter out checkpoint blocks - we place checkpoint items manually based on distance
            if (isCheckpoint) {
                continue;
            }
            // Allow car gates only on start blocks (SnowRoad start includes CarSnow)
            if (isCarGate && !isStart) {
                continue;
            }
            // For start blocks, require SnowRoad tag to ensure we get a wood start
            if (isStart && !isSnowRoad) {
                continue;
            }
            if (!isSnowRoad && !isFinish && !isStart) {
                continue;
            }
        }
        if (ConnectorsCompatible(currentSection.thisBlock.endConnector, Blocks[i].startConnector)) {
            // if ((currentSection.thisBlock.lengthAccurate == 0) && Blocks[i].lengthAccurate == 0) {
            //     weights[i] = 0;
            // } else
            if (currentSection.thisBlock.tags.Find(Tags::NoDuplicate) != -1 && Blocks[i].tags.Find(Tags::NoDuplicate) != -1) {
                weights[i] = 0;
            } else if (previousEmpty && Blocks[i].tags.Find(Tags::PreviousNotEmpty) != -1) {
                weights[i] = 0;
            } else {
                weights[i] = 1;
                if (currentSection.thisBlock.NameID == Blocks[i].NameID) {weights[i] *= RepeatWeight;}
                for (uint j = 0; j < Blocks[i].tags.Length; j++) {
                    if (Blocks[i].tags[j] == Tags::Checkpoint) {
                        weights[i] *= 2 * CheckpointDistance * Math::Pow(2., currentSection.sinceLastCheckpoint - CheckpointDistance);
                    } else if (Blocks[i].tags[j] == Tags::Finish) {
                        if (length < 0.9*FinishDistance) {
                            weights[i] = 0;
                        } else {
                            weights[i] *= 2 * FinishDistance * Math::Pow(2., (length - FinishDistance)) * Math::Pow(2., currentSection.sinceLastCheckpoint - CheckpointDistance);}
                    } else if (Blocks[i].tags[j] == Tags::JumpContinue) {
                        weights[i] *= Math::Pow(JumpContinueMultiplier, currentSection.jumpLength) * getWeightFromTag(Tags::JumpContinue, currentSection.currentCar);
                        //print('weight: ' + (Math::Pow(JumpContinueMultiplier, jumpLength) * getWeightFromTag(Tags::JumpContinue, currentSection.currentCar)) + ' ' + Math::Pow(JumpContinueMultiplier, float(jumpLength)) + ' ' + JumpContinueMultiplier + ' ' + jumpLength + ' ' + getWeightFromTag(Tags::JumpContinue, currentSection.currentCar));
                    } else {
                        weights[i] *= getWeightFromTag(Blocks[i].tags[j], currentSection.currentCar);}
                    //if (weights[i] > 1000) {print(weights[i]); print('n'+Blocks[i].NameID);}
                }
                currentSection.startWeight += weights[i];
            }
        }
    }
    currentSection.startWeight += FinishDistance * Math::Pow(2., (length - FinishDistance)) * Math::Pow(2., currentSection.sinceLastCheckpoint - CheckpointDistance);
    currentSection.startWeight += CheckpointDistance * Math::Pow(2., currentSection.sinceLastCheckpoint - CheckpointDistance);
    return weights;
}

// Chooses an index from an array of weights
uint ChooseNextBlock(TrackSection@ trackSection) {
    float weight = 0;
    for (uint i = 0; i < trackSection.weights.Length; i++) {
        if (trackSection.weights[i] >= 3.402823466e+38) {return i;} // can happen if no valid finish placement (basically inf)
        weight += trackSection.weights[i];
    }
    if (weight <= trackSection.startWeight*weightLoss) {return 0;}
    weight = Math::Rand(0., weight); // reusing variable

    for (uint i = 0; i < Blocks.Length; i++) {
        weight -= trackSection.weights[i];
        if (weight <= 0.000000001) {
            return i;}
    }

    if (debugPrint) {print('Invalid block choice from: ' + trackSection.thisBlock.endConnector + ' with total weight ' + weight);}
    return 0;
}

// chooses a color for the next block, using the weights settings for each block
CGameEditorPluginMap::EMapElemColor ChooseNextColor(CGameEditorPluginMap::EMapElemColor currentColor) {
    if (Math::Rand(0., 1.) > ChangeColorWeight) {
        return currentColor;
    }
    float totalWeight = DefaultColorWeight + WhiteColorWeight + GreenColorWeight + BlueColorWeight + RedColorWeight + BlackColorWeight;
    float chosenWeight = Math::Rand(0., totalWeight);
    if (chosenWeight < DefaultColorWeight) {
        return CGameEditorPluginMap::EMapElemColor::Default;
    }
    if (chosenWeight < DefaultColorWeight + WhiteColorWeight) {
        return CGameEditorPluginMap::EMapElemColor::White;
    }
    if (chosenWeight < DefaultColorWeight + WhiteColorWeight + GreenColorWeight) {
        return CGameEditorPluginMap::EMapElemColor::Green;
    }
    if (chosenWeight < DefaultColorWeight + WhiteColorWeight + GreenColorWeight + BlueColorWeight) {
        return CGameEditorPluginMap::EMapElemColor::Blue;
    }
    if (chosenWeight < DefaultColorWeight + WhiteColorWeight + GreenColorWeight + BlueColorWeight + RedColorWeight) {
        return CGameEditorPluginMap::EMapElemColor::Red;
    }
    return CGameEditorPluginMap::EMapElemColor::Black;
}

const string xddSign = "https://download.dashmap.live/fc8467b8-b253-457f-b8bb-3bbd2bb5bfdd/xdd_sign.webp";
const string xddSignName = "https://download.dashmap.live/fc8467b8-b253-457f-b8bb-3bbd2bb5bfdd/xdd_sign_name.webp";
const string YEPSign = "https://download.dashmap.live/fc8467b8-b253-457f-b8bb-3bbd2bb5bfdd/YEP_sign.webp";
const string YEPSignName = "https://download.dashmap.live/fc8467b8-b253-457f-b8bb-3bbd2bb5bfdd/YEP_sign_name.webp";
const string ChattingSign = "https://download.dashmap.live/fc8467b8-b253-457f-b8bb-3bbd2bb5bfdd/Chatting_sign.webm";
const string ChattingSignName = "https://download.dashmap.live/fc8467b8-b253-457f-b8bb-3bbd2bb5bfdd/Chatting_sign_name.webm";
const string YEKSign = "https://download.dashmap.live/fc8467b8-b253-457f-b8bb-3bbd2bb5bfdd/YEK_sign.webp";
const string YEKSignName = "https://download.dashmap.live/fc8467b8-b253-457f-b8bb-3bbd2bb5bfdd/YEK_sign_name.webp";
const string owoSign = "https://download.dashmap.live/fc8467b8-b253-457f-b8bb-3bbd2bb5bfdd/owo_sign.webp";
const string owoSignName = "https://download.dashmap.live/fc8467b8-b253-457f-b8bb-3bbd2bb5bfdd/owo_sign_name.webp";
const string OpenplanetSign = "https://download.dashmap.live/fc8467b8-b253-457f-b8bb-3bbd2bb5bfdd/Openplanet_sign.webp";
const string OpenplanetSignName = "https://download.dashmap.live/fc8467b8-b253-457f-b8bb-3bbd2bb5bfdd/Openplanet_sign_name.webp";
const string blaSign = "https://download.dashmap.live/fc8467b8-b253-457f-b8bb-3bbd2bb5bfdd/bla_sign.webp";
const string blaSignName = "https://download.dashmap.live/fc8467b8-b253-457f-b8bb-3bbd2bb5bfdd/bla_sign_name.webp";
const string uuhSign = "https://download.dashmap.live/fc8467b8-b253-457f-b8bb-3bbd2bb5bfdd/uuh_sign.webm";
const string uuhSignName = "https://download.dashmap.live/fc8467b8-b253-457f-b8bb-3bbd2bb5bfdd/uuh_sign_name.webm";
const string gettingjiggywithitSign = "https://download.dashmap.live/fc8467b8-b253-457f-b8bb-3bbd2bb5bfdd/gettingjiggywithit_sign.webm";
const string gettingjiggywithitSignName = "https://download.dashmap.live/fc8467b8-b253-457f-b8bb-3bbd2bb5bfdd/gettingjiggywithit_sign_name.webm";
const string LICKASign = "https://download.dashmap.live/fc8467b8-b253-457f-b8bb-3bbd2bb5bfdd/LICKA_sign.webm";
const string LICKASignName = "https://download.dashmap.live/fc8467b8-b253-457f-b8bb-3bbd2bb5bfdd/LICKA_sign_name.webm";
const string emptySign = "None";
const string emptySignName = "https://download.dashmap.live/fc8467b8-b253-457f-b8bb-3bbd2bb5bfdd/empty_sign_name.webp";

// chooses a sign image for the next block, using the weights settings for each block
string ChooseNextSign(bool start = false) {
    float totalWeight = xddSignWeight + YEPSignWeight + ChattingSignWeight + YEKSignWeight + owoSignWeight + OpenplanetSignWeight + blaSignWeight + uuhSignWeight + gettingjiggywithitSignWeight + LICKASignWeight + emptySignWeight;
    float chosenWeight = Math::Rand(0.f, totalWeight);
    if (chosenWeight < xddSignWeight) {
        return start ? xddSignName : xddSign;
    } else {chosenWeight -= xddSignWeight;}

    if (chosenWeight < YEPSignWeight) {
        return start ? YEPSignName : YEPSign;
    } else {chosenWeight -= YEPSignWeight;}

    if (chosenWeight < ChattingSignWeight) {
        return start ? ChattingSignName : ChattingSign;
    } else {chosenWeight -= ChattingSignWeight;}

    if (chosenWeight < YEKSignWeight) {
        return start ? YEKSignName : YEKSign;
    } else {chosenWeight -= YEKSignWeight;}

    if (chosenWeight < owoSignWeight) {
        return start ? owoSignName : owoSign;
    } else {chosenWeight -= owoSignWeight;}

    if (chosenWeight < OpenplanetSignWeight) {
        return start ? OpenplanetSignName : OpenplanetSign;
    } else {chosenWeight -= OpenplanetSignWeight;}

    if (chosenWeight < blaSignWeight) {
        return start ? blaSignName : blaSign;
    } else {chosenWeight -= blaSignWeight;}

    if (chosenWeight < uuhSignWeight) {
        return start ? uuhSignName : uuhSign;
    } else {chosenWeight -= uuhSignWeight;}

    if (chosenWeight < gettingjiggywithitSignWeight) {
        return start ? gettingjiggywithitSignName : gettingjiggywithitSign;
    } else {chosenWeight -= gettingjiggywithitSignWeight;}

    if (chosenWeight < LICKASignWeight) {
        return start ? LICKASignName : LICKASign;
    } else {chosenWeight -= LICKASignWeight;}

    return start ? emptySignName : emptySign;
}

// reference between tags and each settings variable
float getWeightFromTag(Tags tag, Cars currentCar) {
    switch(tag) {
        case(Tags::RoadTech): return RoadTechWeight;
        case(Tags::RoadDirt): return RoadDirtWeight;
        case(Tags::RoadBump): return RoadBumpWeight;
        case(Tags::RoadIce): return RoadIceWeight;
        case(Tags::UnderwaterBobsled): return UnderwaterBobsledWeight;
        case(Tags::RoadWater): return RoadWaterWeight;
        case(Tags::SnowRoad): return SnowRoadWeight;
        case(Tags::RallyCastleRoad): return RallyCastleRoadWeight;
        case(Tags::RallyRoadDirtHigh): return RallyRoadDirtHighWeight;
        case(Tags::RallyRoadDirtLow): return RallyRoadDirtLowWeight;
        case(Tags::RallyRoadDirt): return (RallyRoadDirtHighWeight + RallyRoadDirtLowWeight) / 2;
        case(Tags::RallyRoadMudLow): return RallyRoadMudLowWeight;
        case(Tags::TrackWall): return TrackWallWeight;
        case(Tags::TrackWallWater): return TrackWallWaterWeight;
        case(Tags::PlatformTech): return PlatformTechWeight; // change this later
        case(Tags::PlatformDirt): return PlatformDirtWeight;
        case(Tags::PlatformIce): return PlatformIceWeight;
        case(Tags::PlatformGrass): return PlatformGrassWeight;
        case(Tags::PlatformPlastic): return PlatformPlasticWeight;
        case(Tags::PlatformWater): return PlatformWaterWeight;
        case(Tags::DecoWall): return DecoWallWeight;
        case(Tags::DecoWallWater): return DecoWallWaterWeight;
        case(Tags::OpenTech): return OpenTechWeight;
        case(Tags::OpenDirt): return OpenDirtWeight;
        case(Tags::OpenIce): return OpenIceWeight;
        case(Tags::OpenGrass): return OpenGrassWeight;
        case(Tags::WaterGrass): return WaterGrassWeight;
        case(Tags::WaterDirt): return WaterDirtWeight;
        case(Tags::WaterIce): return WaterIceWeight;
        case(Tags::PenaltyGrass): return PenaltyGrassWeight;
        case(Tags::PenaltySand): return PenaltySandWeight;
        case(Tags::PenaltySnow): return PenaltySnowWeight;
        case(Tags::Structure): return StructureWeight;
        case(Tags::Stand): return StandWeight;
        case(Tags::Stage): return StageWeight;
        case(Tags::StagePlatform): return StagePlatformWeight;
        case(Tags::StageSupport): return StageSupportWeight;
        case(Tags::StageSupportPlatform): return StageSupportPlatformWeight;
        case(Tags::StageInside): return StageInsideWeight;

        case(Tags::Corner): return CornerWeight;
        case(Tags::Flat): return FlatWeight;
        case(Tags::Slope): return SlopeWeight;
        case(Tags::Tilt): return TiltWeight;
        case(Tags::Diagonal): return DiagonalWeight;
        case(Tags::Loop): return LoopWeight;
        case(Tags::TiltCurved): return TiltCurvedWeight;
        case(Tags::SlightTilt): return SlightTiltWeight;

        case(Tags::Junction): return JunctionWeight;
        case(Tags::ChangeMaterial): return ChangeMaterialWeight;
        case(Tags::NoDuplicate): return 1.f;
        case(Tags::ChangeBorder): return ChangeBorderWeight;
        case(Tags::ChangeSlope): return ChangeSlopeWeight;
        case(Tags::ChangeTilt): return ChangeTiltWeight;
        case(Tags::ChangeAngle): return ChangeAngleWeight;
        case(Tags::SideConnectionOpen): return SideConnectionOpenWeight;
        case(Tags::SideConnectionPlatform): return SideConnectionPlatformWeight;
        case(Tags::SideConnectionT): return SideConnectionTWeight;

        case(Tags::Multilap): return MultilapWeight;
        case(Tags::Hole): return HoleWeight;
        case(Tags::PenaltyRoad): return PenaltyRoadWeight;
        case(Tags::Ramp): return RampWeight;
        case(Tags::AntiRamp): return AntiRampWeight;
        case(Tags::Bump): return BumpWeight;
        case(Tags::Narrow): return NarrowWeight;
        case(Tags::IceWall): return IceWallWeight;
        case(Tags::IceWallChange): return IceWallChangeWeight;
        case(Tags::Poles): return PolesWeight;
        case(Tags::PlatformUnsmooth): return PlatformUnsmoothWeight;
        case(Tags::JumpStart): return JumpStartWeight;
        case(Tags::DropJumpStart): return DropJumpStartWeight;
        case(Tags::JumpContinue): return JumpContinueWeight;

        case(Tags::Turbo): return TurboWeight;
        case(Tags::AntiTurbo): return AntiTurboWeight;
        case(Tags::SuperTurbo): return SuperTurboWeight;
        case(Tags::AntiSuperTurbo): return AntiSuperTurboWeight;
        case(Tags::RandomTurbo): return RandomTurboWeight;
        case(Tags::AntiRandomTurbo): return AntiRandomTurboWeight;
        case(Tags::BoostUp): return BoostUpWeight;
        case(Tags::BoostDown): return BoostDownWeight;
        case(Tags::Boost2Up): return Boost2UpWeight;
        case(Tags::Boost2Down): return Boost2DownWeight;
        case(Tags::Cruise): return CruiseWeight;
        case(Tags::NoBrake): return NoBrakeWeight;
        case(Tags::NoEngine): return NoEngineWeight;
        case(Tags::NoSteering): return NoSteeringWeight;
        case(Tags::SlowMotion): return SlowMotionWeight;
        case(Tags::Fragile): return FragileWeight;
        case(Tags::Reset): return ResetWeight;

        case(Tags::CarStadium): return currentCar == Cars::CarStadium ? CarStadiumWeight : CarStadiumWeight * CarChangeWeight;
        case(Tags::CarSnow): return currentCar == Cars::CarSnow ? CarSnowWeight : CarSnowWeight * CarChangeWeight;
        case(Tags::CarRally): return currentCar == Cars::CarRally ? CarRallyWeight : CarRallyWeight * CarChangeWeight;
        case(Tags::CarDesert): return currentCar == Cars::CarDesert ? CarDesertWeight : CarDesertWeight * CarChangeWeight;

        case(Tags::Start): return 1.f;
        case(Tags::Checkpoint): return 1.f;
        case(Tags::Finish): return 1.f;
        case(Tags::FakeFinish): return FakeFinishWeight;


        case(Tags::PreviousNotEmpty): return 1.f;

        case(Tags::Quarter): return 0.25f;
        case(Tags::Half): return 0.5f;
        case(Tags::Double): return 2.f;
        case(Tags::HighChance): return 128.f;


    }
    print('no setting for tag: ' + tostring(tag));
    return 1.;
}

const array<string> stageSigns = {
    "Skins\\Any\\Advertisement4x1\\Reversible\\AnimatedFoggyBlue.webm",
    "Skins\\Any\\Advertisement4x1\\Reversible\\AnimatedFoggyCyan.webm",
    "Skins\\Any\\Advertisement4x1\\Reversible\\AnimatedFoggyMarine.webm",
    "Skins\\Any\\Advertisement4x1\\Reversible\\AnimatedFoggyOrange.webm",
    "Skins\\Any\\Advertisement4x1\\Reversible\\AnimatedFoggyPurple.webm",
    // "Skins\\Any\\Advertisement4x1\\Reversible\\EffectCherry.webm",
    // "Skins\\Any\\Advertisement4x1\\Reversible\\EffectLaser.webm",
    "Skins\\Any\\Advertisement4x1\\Reversible\\StaticIce.tga",
    "Skins\\Any\\Advertisement4x1\\Reversible\\StaticLeaf.tga",
    "Skins\\Any\\Advertisement4x1\\Reversible\\StaticSakura.tga",
    "Skins\\Any\\Advertisement4x1\\Reversible\\StaticSand.tga",
    "Skins\\Any\\Advertisement4x1\\Reversible\\StaticSpotLight.tga"
};

string randomStageSign() {
    int r = Math::Rand(0, stageSigns.Length);
    return stageSigns[r];
}

CGameEditorPluginMap::EMapElemColorPalette ChooseColorPalette() {
    float totalWeight = ClassicPaletteWeight + StuntPaletteWeight + RedPaletteWeight + OrangePaletteWeight + YellowPaletteWeight + LimePaletteWeight + GreenPaletteWeight + CyanPaletteWeight + BluePaletteWeight + PurplePaletteWeight + PinkPaletteWeight + WhitePaletteWeight + BlackPaletteWeight;
    float chosenWeight = Math::Rand(0., totalWeight);
    if (chosenWeight < ClassicPaletteWeight) {
        return CGameEditorPluginMap::EMapElemColorPalette::Classic;
    }
    if (chosenWeight < ClassicPaletteWeight + StuntPaletteWeight) {
        return CGameEditorPluginMap::EMapElemColorPalette::Stunt;
    }
    if (chosenWeight < ClassicPaletteWeight + StuntPaletteWeight + RedPaletteWeight) {
        return CGameEditorPluginMap::EMapElemColorPalette::Red;
    }
    if (chosenWeight < ClassicPaletteWeight + StuntPaletteWeight + RedPaletteWeight + OrangePaletteWeight) {
        return CGameEditorPluginMap::EMapElemColorPalette::Orange;
    }
    if (chosenWeight < ClassicPaletteWeight + StuntPaletteWeight + RedPaletteWeight + OrangePaletteWeight + YellowPaletteWeight) {
        return CGameEditorPluginMap::EMapElemColorPalette::Yellow;
    }
    if (chosenWeight < ClassicPaletteWeight + StuntPaletteWeight + RedPaletteWeight + OrangePaletteWeight + YellowPaletteWeight + LimePaletteWeight) {
        return CGameEditorPluginMap::EMapElemColorPalette::Lime;
    }
    if (chosenWeight < ClassicPaletteWeight + StuntPaletteWeight + RedPaletteWeight + OrangePaletteWeight + YellowPaletteWeight + LimePaletteWeight + GreenPaletteWeight) {
        return CGameEditorPluginMap::EMapElemColorPalette::Green;
    }
    if (chosenWeight < ClassicPaletteWeight + StuntPaletteWeight + RedPaletteWeight + OrangePaletteWeight + YellowPaletteWeight + LimePaletteWeight + GreenPaletteWeight + CyanPaletteWeight) {
        return CGameEditorPluginMap::EMapElemColorPalette::Cyan;
    }
    if (chosenWeight < ClassicPaletteWeight + StuntPaletteWeight + RedPaletteWeight + OrangePaletteWeight + YellowPaletteWeight + LimePaletteWeight + GreenPaletteWeight + CyanPaletteWeight + BluePaletteWeight) {
        return CGameEditorPluginMap::EMapElemColorPalette::Blue;
    }
    if (chosenWeight < ClassicPaletteWeight + StuntPaletteWeight + RedPaletteWeight + OrangePaletteWeight + YellowPaletteWeight + LimePaletteWeight + GreenPaletteWeight + CyanPaletteWeight + BluePaletteWeight + PurplePaletteWeight) {
        return CGameEditorPluginMap::EMapElemColorPalette::Purple;
    }
    if (chosenWeight < ClassicPaletteWeight + StuntPaletteWeight + RedPaletteWeight + OrangePaletteWeight + YellowPaletteWeight + LimePaletteWeight + GreenPaletteWeight + CyanPaletteWeight + BluePaletteWeight + PurplePaletteWeight + PinkPaletteWeight) {
        return CGameEditorPluginMap::EMapElemColorPalette::Pink;
    }
    if (chosenWeight < ClassicPaletteWeight + StuntPaletteWeight + RedPaletteWeight + OrangePaletteWeight + YellowPaletteWeight + LimePaletteWeight + GreenPaletteWeight + CyanPaletteWeight + BluePaletteWeight + PurplePaletteWeight + PinkPaletteWeight + WhitePaletteWeight) {
        return CGameEditorPluginMap::EMapElemColorPalette::White;
    }
    return CGameEditorPluginMap::EMapElemColorPalette::Black;
}