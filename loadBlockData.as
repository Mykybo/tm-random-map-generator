
array<Block@> Blocks;

array<array<uint>> StraightBlocks = {};
array<array<uint>> StraightBlocks_up = {};
array<array<uint>> StraightBlocks_down = {};
array<array<uint>> StraightBlocks_up2 = {};
array<array<uint>> StraightBlocks_down2 = {};
// array<array<uint>> StraightBlocks_empty = {};

void SetupStraightBlocks() {
    for (uint i = 0; i < Connections::PlatformAnyTiltRight; i++) {
        StraightBlocks.InsertLast({});
        StraightBlocks_up.InsertLast({});
        StraightBlocks_down.InsertLast({});
        StraightBlocks_up2.InsertLast({});
        StraightBlocks_down2.InsertLast({});
        // StraightBlocks_empty.InsertLast({});
    }
}

enum LoadStatus {
    NotLoaded,
    ToLoadAll,
    LoadingAll,
    All,
    LoadingExtra,
    ToLoadNonzeroWeight,
    LoadingNonzeroWeight,
    NonzeroWeight,
}

LoadStatus blocksStatus = LoadStatus::NotLoaded;

array<Tags> toTagArray(Json::Value tags) {
    array<Tags> result = {};
    result.Reserve(tags.Length);
    for (uint i = 0; i < tags.Length; i++) {
        result.InsertLast(Tags(uint(tags[i])));
    }
    return result;
}
array<int3> toint3Array(Json::Value int3s) {
    array<int3> result = {};
    result.Reserve(int3s.Length);
    for (uint i = 0; i < int3s.Length; i++) {
        result.InsertLast(int3(int(int3s[i][0]),int(int3s[i][1]),int(int3s[i][2])));
    }
    return result;
}

void LoadBlocks() {
    if (!Permissions::OpenAdvancedMapEditor()) {
        UI::ShowNotification(pluginName, "Error - trying to load advanced editor blocks without permission", notificationErrorColor);
        blocksStatus = LoadStatus::NotLoaded;
        return;
    }
    blocksStatus = LoadStatus::LoadingAll;
    Blocks = {};
    Json::Value JsonBlocks = Json::FromFile('BlockData.json');
    Blocks.Reserve(JsonBlocks.Length);
    Block@ b;
    SetupStraightBlocks();
    for (uint i = 0; i < JsonBlocks.Length; i++) {
        if (Time::get_Now() - GlobalFrameStartTime > 20) {
            yield();
            GlobalFrameStartTime = Time::get_Now();
        }
        Json::Value CurrentBlock = JsonBlocks[i];
        @b = Block(
            CurrentBlock.Get("NameID"),
            Connections(uint(CurrentBlock.Get("startConnector"))),
            Connections(uint(CurrentBlock.Get("endConnector"))),
            int3(CurrentBlock.Get("endPosition")[0], CurrentBlock.Get("endPosition")[1], CurrentBlock.Get("endPosition")[2]),
            Directions(uint(CurrentBlock.Get("Direction"))),
            toTagArray(CurrentBlock.Get("tags")),
            uint(CurrentBlock.Get("length")),
            Directions(uint(CurrentBlock.Get("RotationOffset"))),
            toint3Array(CurrentBlock.Get("PositionOffset")));
        Blocks.InsertLast(b);
        // if (string(CurrentBlock.Get("NameID")).StartsWith("Macroblock:Stadium\\Macroblocks\\LightSculpture")) {
        if (b.startConnector == b.endConnector && b.Direction == Directions::Forwards && b.endPosition == int3(0,0,1)) {
            StraightBlocks[b.startConnector].InsertLast(i);
        } else if (b.startConnector == b.endConnector && b.Direction == Directions::Forwards && b.endPosition == int3(0,1,1)) {
            StraightBlocks_up[b.startConnector].InsertLast(i);
        } else if (b.startConnector == b.endConnector && b.Direction == Directions::Forwards && b.endPosition == int3(0,-1,1)) {
            StraightBlocks_down[b.startConnector].InsertLast(i);
        } else if (b.startConnector == b.endConnector && b.Direction == Directions::Forwards && b.endPosition == int3(0,2,1)) {
            StraightBlocks_up2[b.startConnector].InsertLast(i);
        } else if (b.startConnector == b.endConnector && b.Direction == Directions::Forwards && b.endPosition == int3(0,-2,1)) {
            StraightBlocks_down2[b.startConnector].InsertLast(i);
        // } else if (b.startConnector == b.endConnector && b.Direction == Directions::Forwards && b.endPosition == int3(0,0,0)) {
        //     StraightBlocks_empty[b.startConnector].InsertLast(i);
        }
    }
    blocksStatus = LoadStatus::All;
    if (debugPrint) {print('Loaded ' + Blocks.Length + ' blocks');}
#if RECREATEBLOCKSFILE
    CreateBlocks();
#endif
}

void LoadBlocksNonzeroWeight() {
    if (!Permissions::OpenAdvancedMapEditor()) {
        UI::ShowNotification(pluginName, "Error - trying to load advanced editor blocks without permission", notificationErrorColor);
        blocksStatus = LoadStatus::NotLoaded;
        return;
    }
    blocksStatus = LoadStatus::LoadingNonzeroWeight;
    Blocks = {};
    Json::Value JsonBlocks = Json::FromFile('BlockData.json');
    Blocks.Reserve(JsonBlocks.Length);
    Block@ b;
    array<Tags> tags;
    bool iszero;
    SetupStraightBlocks();
    uint blockIdx = 0; // index of block in block list; i is in currentBlocks which is now different
    for (uint i = 0; i < JsonBlocks.Length; i++) {
        if (Time::get_Now() - GlobalFrameStartTime > 20) {
            yield();
            GlobalFrameStartTime = Time::get_Now();
        }
        Json::Value CurrentBlock = JsonBlocks[i];
        tags = toTagArray(CurrentBlock.Get("tags"));
        iszero = false;
        for (uint j = 0; j < tags.Length; j++){
            if (getWeightFromTag(tags[j], Cars::CarStadium) == 0) {
                iszero = true;
            }
        }
        if (iszero) {continue;}
        @b = Block(
            CurrentBlock.Get("NameID"),
            Connections(uint(CurrentBlock.Get("startConnector"))),
            Connections(uint(CurrentBlock.Get("endConnector"))),
            int3(CurrentBlock.Get("endPosition")[0], CurrentBlock.Get("endPosition")[1], CurrentBlock.Get("endPosition")[2]),
            Directions(uint(CurrentBlock.Get("Direction"))),
            tags,
            uint(CurrentBlock.Get("length")),
            Directions(uint(CurrentBlock.Get("RotationOffset"))),
            toint3Array(CurrentBlock.Get("PositionOffset")));
        Blocks.InsertLast(b);
        blockIdx++;
        if (b.startConnector == b.endConnector && b.Direction == Directions::Forwards && b.endPosition == int3(0,0,1)) {
            StraightBlocks[b.startConnector].InsertLast(blockIdx);
        } else if (b.startConnector == b.endConnector && b.Direction == Directions::Forwards && b.endPosition == int3(0,1,1)) {
            StraightBlocks_up[b.startConnector].InsertLast(blockIdx);
        } else if (b.startConnector == b.endConnector && b.Direction == Directions::Forwards && b.endPosition == int3(0,-1,1)) {
            StraightBlocks_down[b.startConnector].InsertLast(blockIdx);
        } else if (b.startConnector == b.endConnector && b.Direction == Directions::Forwards && b.endPosition == int3(0,2,1)) {
            StraightBlocks_up2[b.startConnector].InsertLast(i);
        } else if (b.startConnector == b.endConnector && b.Direction == Directions::Forwards && b.endPosition == int3(0,-2,1)) {
            StraightBlocks_down2[b.startConnector].InsertLast(i);
        // } else if (b.startConnector == b.endConnector && b.Direction == Directions::Forwards && b.endPosition == int3(0,0,0)) {
        //     StraightBlocks_empty[b.startConnector].InsertLast(i);
        }
    }
    blocksStatus = LoadStatus::NonzeroWeight;
    if (debugPrint) {print('Loaded ' + Blocks.Length + ' blocks');}
}

// load blocks from an extra file
void LoadExtraBlocks(const string &in filename) {
    if (!Permissions::OpenAdvancedMapEditor()) {
        UI::ShowNotification(pluginName, "Error - trying to load extra blocks without advanced editor permission", notificationErrorColor);
        blocksStatus = LoadStatus::NotLoaded;
        return;
    }
    blocksStatus = LoadStatus::LoadingExtra;
    Json::Value JsonBlocks = Json::FromFile(filename);
    if (JsonBlocks.GetType() == Json::Type::Null) {
        UI::ShowNotification(pluginName, "Couldn't read file", notificationErrorColor);
        print(filename);
        return;
    }
    Blocks.Reserve(Blocks.Length + JsonBlocks.Length);
    Block@ b;
    SetupStraightBlocks();
    for (uint i = 0; i < JsonBlocks.Length; i++) {
        if (Time::get_Now() - GlobalFrameStartTime > 20) {
            yield();
            GlobalFrameStartTime = Time::get_Now();
        }
        Json::Value CurrentBlock = JsonBlocks[i];
        @b = Block(
            CurrentBlock.Get("NameID"),
            Connections(uint(CurrentBlock.Get("startConnector"))),
            Connections(uint(CurrentBlock.Get("endConnector"))),
            int3(CurrentBlock.Get("endPosition")[0], CurrentBlock.Get("endPosition")[1], CurrentBlock.Get("endPosition")[2]),
            Directions(uint(CurrentBlock.Get("Direction"))),
            toTagArray(CurrentBlock.Get("tags")),
            uint(CurrentBlock.Get("length")),
            Directions(uint(CurrentBlock.Get("RotationOffset"))),
            toint3Array(CurrentBlock.Get("PositionOffset")));
        Blocks.InsertLast(b);
        // if (string(CurrentBlock.Get("NameID")).StartsWith("Macroblock:Stadium\\Macroblocks\\LightSculpture")) {
        if (b.startConnector == b.endConnector && b.Direction == Directions::Forwards && b.endPosition == int3(0,0,1)) {
            StraightBlocks[b.startConnector].InsertLast(i);
        } else if (b.startConnector == b.endConnector && b.Direction == Directions::Forwards && b.endPosition == int3(0,1,1)) {
            StraightBlocks_up[b.startConnector].InsertLast(i);
        } else if (b.startConnector == b.endConnector && b.Direction == Directions::Forwards && b.endPosition == int3(0,-1,1)) {
            StraightBlocks_down[b.startConnector].InsertLast(i);
        } else if (b.startConnector == b.endConnector && b.Direction == Directions::Forwards && b.endPosition == int3(0,2,1)) {
            StraightBlocks_up2[b.startConnector].InsertLast(i);
        } else if (b.startConnector == b.endConnector && b.Direction == Directions::Forwards && b.endPosition == int3(0,-2,1)) {
            StraightBlocks_down2[b.startConnector].InsertLast(i);
        // } else if (b.startConnector == b.endConnector && b.Direction == Directions::Forwards && b.endPosition == int3(0,0,0)) {
        //     StraightBlocks_empty[b.startConnector].InsertLast(i);
        }
    }
    blocksStatus = LoadStatus::All;
    if (debugPrint) {print('Loaded ' + Blocks.Length + ' blocks');}
}
