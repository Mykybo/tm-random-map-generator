
bool showInterface = false;// if reloaded in editor, will open menu. Otherwise, will close instantly since not in editor

TrackGenerator@ T;

void RenderMenu() {
    if (UI::MenuItem("\\$f0f" + Icons::Random + "\\$z Track Generator Extended", "", showInterface)) {
        if (GetApp() is null) {return;}
        if (GetApp().Editor is null) {
            UI::ShowNotification(pluginName, "Open the map editor to create a track", notificationOkColor);
            return;}
        showInterface = !showInterface;
	}
}


void OnKeyPress (bool down, VirtualKey key) {
    // if (!(T is null) && T.status == 2 && down && key == VirtualKey::R) {
    //     @T = TrackGenerator();
    // } else
    if (!(T is null) && T.status == 1 && debugStepMode && down && key == VirtualKey::T) {
        startnew(CoroutineFunc(T.step_debug));
    } else
    if (!(T is null) && T.status != 0 && debugLastBlock && down && key == VirtualKey::G) {
        startnew(CoroutineFunc(T.debugBlock));
    }
}


[Setting category="General" name="Average length between checkpoints" min=0 description="Measured in 1x1 block length (approximately), rather than block count"]
uint CheckpointDistance = 10;
// [Setting category="General" name="Strictness of checkpoint distance" min=0, description="Weight of checkpoint = 2 * checkpoint distance * 2 ^ (since checkpoint - checkpoint distance)"]
// uint CheckpointDistancePower = 7;
[Setting category="General" name="Average track length" min=0 description="Measured in 1x1 block length (approximately), rather than block count"]
uint FinishDistance = 70;
// [Setting category="General" name="Strictness of finish distance" min=0, description="Weight of finish = 2 * finish distance * 2 ^ (length - finish distance)"]
// uint FinishDistancePower = 7;
[Setting category="General" name="Increase vertical separation"]
bool verticalSeparation = true;
[Setting category="General" name="Placing attempts before undo" min=1]
uint errorTries = 200;
[Setting category="General" name="Weight remaining before undoing" min=0 max=1 description="When a block placement fails, its weight is removed from the possible next blocks for the previous block"]
float weightLoss = 0.001;

[Setting category="General" name="Wood Only Mode" description="Only place wood (snow road) blocks"]
bool WoodOnlyMode = false;

[Setting category="General" name="Chaotic Wood Connections" description="Allow wood blocks to connect in any orientation (flat to slope, tilt to flat, etc.)"]
bool WoodChaoticConnections = true;

[Setting category="General" name="Start at Camera Position" description="Use editor camera position as track starting point instead of random location"]
bool StartAtCameraPosition = false;

[Setting category="General" name="Enable Custom Checkpoint Signs" description="Apply custom image URLs to checkpoints, start, and finish blocks"]
bool EnableCustomSigns = false;

[Setting category="General" name="Checkpoint Sign URL" description="Image URL for checkpoints (webp/webm)"]
string CustomCheckpointSignURL = "";

[Setting category="General" name="Start/Finish Sign URL" description="Image URL for start and finish blocks (webp/webm)"]
string CustomStartFinishSignURL = "";

[Setting category="Surface" name="Change Material" min=0]
float ChangeMaterialWeight = 4.;
[Setting category="Surface" name="Change Border (not material)" min=0]
float ChangeBorderWeight = 3.;
[Setting category="Surface" name="Road tech (concrete)" min=0]
float RoadTechWeight = 1.;
[Setting category="Surface" name="Road dirt" min=0]
float RoadDirtWeight = 1.;
[Setting category="Surface" name="Road sausage" min=0]
float RoadBumpWeight = 0.8;
[Setting category="Surface" name="Road ice (bobsled)" min=0]
float RoadIceWeight = 0.7;
[Setting category="Surface" name="Underwater Bobsled" min=0]
float UnderwaterBobsledWeight = 0.5;
[Setting category="Surface" name="Road water" min=0]
float RoadWaterWeight = 1.;
[Setting category="Surface" name="Snow road" min=0]
float SnowRoadWeight = 1.;
[Setting category="Surface" name="Rally castle road" min=0]
float RallyCastleRoadWeight = 1.;
[Setting category="Surface" name="Rally dirt high penalty border" min=0]
float RallyRoadDirtHighWeight = 1.;
[Setting category="Surface" name="Rally dirt low penalty border" min=0]
float RallyRoadDirtLowWeight = 1.;
[Setting category="Surface" name="Rally mud (dirt+water) penalty border" min=0]
float RallyRoadMudLowWeight = 1.;
[Setting category="Surface" name="TrackWall / Track support platform" min=0]
float TrackWallWeight = 0.7;
[Setting category="Surface" name="Road deep water" min=0]
float TrackWallWaterWeight = 0.5;
[Setting category="Surface" name="Platform tech" min=0]
float PlatformTechWeight = 1.;
[Setting category="Surface" name="Platform dirt" min=0]
float PlatformDirtWeight = 1.;
// [Setting category="Surface" name="Platform sausage" min=0] // what
// float PlatformBumpWeight = 1.;
[Setting category="Surface" name="Platform ice" min=0]
float PlatformIceWeight = 0.7;
[Setting category="Surface" name="Platform grass" min=0]
float PlatformGrassWeight = 0.8;
[Setting category="Surface" name="Platform plastic" min=0]
float PlatformPlasticWeight = 0.8;
[Setting category="Surface" name="Platform water" min=0]
float PlatformWaterWeight = 0.8;
[Setting category="Surface" name="DecoWall / Square platform" min=0]
float DecoWallWeight = 0.5;
[Setting category="Surface" name="Platform deep water" min=0]
float DecoWallWaterWeight = 0.5;
[Setting category="Surface" name="Platform tech with penalty border" min=0]
float OpenTechWeight = 0.9;
[Setting category="Surface" name="Platform dirt with penalty border" min=0]
float OpenDirtWeight = 0.9;
// [Setting category="Surface" name="Platform sausage with penalty border" min=0] // what
// float OpenBumpWeight = 1.;
[Setting category="Surface" name="Platform ice with penalty border" min=0]
float OpenIceWeight = 0.6;
[Setting category="Surface" name="Platform grass with penalty border" min=0]
float OpenGrassWeight = 0.7;
// [Setting category="Surface" name="Platform water with penalty border" min=0]
// float OpenWaterWeight = 0.8;
[Setting category="Surface" name="Platform water with penalty grass border" min=0]
float WaterGrassWeight = 0.55;
[Setting category="Surface" name="Platform water with sand border" min=0]
float WaterDirtWeight = 0.55;
[Setting category="Surface" name="Platform water with snow border" min=0]
float WaterIceWeight = 0.55;
[Setting category="Surface" name="Penalty grass" min=0]
float PenaltyGrassWeight = 0.;
[Setting category="Surface" name="Penalty Sand" min=0]
float PenaltySandWeight = 0.;
[Setting category="Surface" name="Penalty Snow" min=0]
float PenaltySnowWeight = 0.;
[Setting category="Surface" name="Structure Beam" min=0]
float StructureWeight = 0.2;
[Setting category="Surface" name="Stand (driving on spectators)" min=0]
float StandWeight = 0.5;
[Setting category="Surface" name="Stage" min=0]
float StageWeight = 1.;
[Setting category="Surface" name="Stage long side" min=0]
float StagePlatformWeight = 0.3;
[Setting category="Surface" name="Stage Support" min=0]
float StageSupportWeight = 0.8;
[Setting category="Surface" name="Stage support long side" min=0]
float StageSupportPlatformWeight = 0.3;
[Setting category="Surface" name="Stage inside" min=0]
float StageInsideWeight = 1.;

[Setting category="Direction" name="Corner" min=0]
float CornerWeight = 0.9;
[Setting category="Direction" name="Flat" min=0]
float FlatWeight = 1.;
[Setting category="Direction" name="Slope" min=0]
float SlopeWeight = 0.8;
[Setting category="Direction" name="Tilt" min=0]
float TiltWeight = 0.7;
[Setting category="Direction" name="Diagonal" min=0]
float DiagonalWeight = 0.8;
[Setting category="Direction" name="Loop" min=0]
float LoopWeight = 0.2;
[Setting category="Direction" name="Tilt (curved)" min=0]
float TiltCurvedWeight = 0.8;
[Setting category="Direction" name="Slight tilt" min=0]
float SlightTiltWeight = 0.5;
[Setting category="Direction" name="Junction" min=0]
float JunctionWeight = 0.03;
[Setting category="Direction" name="ChangeSlope" min=0]
float ChangeSlopeWeight = 1.;
[Setting category="Direction" name="ChangeTilt" min=0]
float ChangeTiltWeight = 1.;
[Setting category="Direction" name="ChangeAngle" min=0]
float ChangeAngleWeight = 1.;
[Setting category="Direction" name="Side connections on open platforms" min=0]
float SideConnectionOpenWeight = 0.;
[Setting category="Direction" name="Side connections on 4-way platforms" min=0]
float SideConnectionPlatformWeight = 0.;
[Setting category="Direction" name="Side connections on 3-way platforms" min=0]
float SideConnectionTWeight = 0.2;

[Setting category="Special" name="Repeat" min=0]
float RepeatWeight = 0.25;
[Setting category="Special" name="Hole" min=0]
float HoleWeight = 0.5;
[Setting category="Special" name="Penalty Road" min=0]
float PenaltyRoadWeight = 0.4;
[Setting category="Special" name="Bump (dirt)" min=0]
float BumpWeight = 0.2;
[Setting category="Special" name="Narrow (bump/sausage)" min=0]
float NarrowWeight = 0.4;
[Setting category="Special" name="High wall (ice)" min=0]
float IceWallWeight = 1.;
[Setting category="Special" name="Unsmooth change high wall (ice)" min=0]
float IceWallChangeWeight = 0.1;
[Setting category="Special" name="Ramp (tech/concrete)" min=0]
float RampWeight = 0.1;
[Setting category="Special" name="AntiRamp (tech/concrete)" min=0]
float AntiRampWeight = 0.01;
[Setting category="Special" name="Poles" min=0]
float PolesWeight = 0.25;
[Setting category="Special" name="Platform Unsmooth" min=0]
float PlatformUnsmoothWeight = 0.f;
[Setting category="Special" name="Jump Start" min=0]
float JumpStartWeight = 0.75;
[Setting category="Special" name="Jump Start" min=0]
float DropJumpStartWeight = 0.25;
[Setting category="Special" name="Jump Continue" min=0]
float JumpContinueWeight = 0.4;
[Setting category="Special" name="Jump length multiplier" min=0 max=1]
float JumpContinueMultiplier = 0.25;
[Setting category="Special" name="Multilap" min=0]
float MultilapWeight = 0.5;
[Setting category="Special" name="Fake Finish" min=0]
float FakeFinishWeight = 0.5;
[Setting category="Special" name="Change car" min=0]
float CarChangeWeight = 1.5;
[Setting category="Special" name="Stadium Car" min=0]
float CarStadiumWeight = 0.6;
[Setting category="Special" name="Snow Car" min=0]
float CarSnowWeight = 0.4;
[Setting category="Special" name="Rally Car" min=0]
float CarRallyWeight = 0.3;
[Setting category="Special" name="Desert Car" min=0]
float CarDesertWeight = 0.5;

[Setting category="Effects" name="Turbo" min=0]
float TurboWeight = 0.4;
[Setting category="Effects" name="Anti turbo" min=0]
float AntiTurboWeight = 0.1;
[Setting category="Effects" name="Super-turbo" min=0]
float SuperTurboWeight = 0.1;
[Setting category="Effects" name="Anti super-turbo" min=0]
float AntiSuperTurboWeight = 0.02;
[Setting category="Effects" name="Random turbo" min=0]
float RandomTurboWeight = 0.05;
[Setting category="Effects" name="Anti random turbo" min=0]
float AntiRandomTurboWeight = 0.01;
[Setting category="Effects" name="Reactor boost up" min=0]
float BoostUpWeight = 0.2;
[Setting category="Effects" name="Reactor boost down" min=0]
float BoostDownWeight = 0.2;
[Setting category="Effects" name="Super reactor boost up" min=0]
float Boost2UpWeight = 0.2;
[Setting category="Effects" name="Super reactor boost down" min=0]
float Boost2DownWeight = 0.2;
[Setting category="Effects" name="Cruise control" min=0]
float CruiseWeight = 0.15;
[Setting category="Effects" name="No brake" min=0]
float NoBrakeWeight = 0.2;
[Setting category="Effects" name="No engine" min=0]
float NoEngineWeight = 0.2;
[Setting category="Effects" name="No steering" min=0]
float NoSteeringWeight = 0.1;
[Setting category="Effects" name="Slow motion" min=0]
float SlowMotionWeight = 0.1;
[Setting category="Effects" name="Fragile" min=0]
float FragileWeight = 0.1;
[Setting category="Effects" name="Reset" min=0]
float ResetWeight = 1.;

[Setting category="Colors" name="Change Color" min=0]
float ChangeColorWeight = 0.3;
[Setting category="Colors" name="Default" min=0]
float DefaultColorWeight = 1.;
[Setting category="Colors" name="White" min=0]
float WhiteColorWeight = 1.;
[Setting category="Colors" name="Green" min=0]
float GreenColorWeight = 1.;
[Setting category="Colors" name="Blue" min=0]
float BlueColorWeight = 1.;
[Setting category="Colors" name="Red" min=0]
float RedColorWeight = 1.;
[Setting category="Colors" name="Black" min=0]
float BlackColorWeight = 1.;

[Setting category="Colors" name="Classic Palette" min=0]
float ClassicPaletteWeight = 1.;
[Setting category="Colors" name="Stunt Palette" min=0]
float StuntPaletteWeight = 1.;
[Setting category="Colors" name="Red Palette" min=0]
float RedPaletteWeight = 0.1;
[Setting category="Colors" name="Orange Palette" min=0]
float OrangePaletteWeight = 0.1;
[Setting category="Colors" name="Yellow Palette" min=0]
float YellowPaletteWeight = 0.1;
[Setting category="Colors" name="Lime Palette" min=0]
float LimePaletteWeight = 0.1;
[Setting category="Colors" name="Green Palette" min=0]
float GreenPaletteWeight = 0.1;
[Setting category="Colors" name="Cyan Palette" min=0]
float CyanPaletteWeight = 0.1;
[Setting category="Colors" name="Blue Palette" min=0]
float BluePaletteWeight = 0.1;
[Setting category="Colors" name="Purple Palette" min=0]
float PurplePaletteWeight = 0.1;
[Setting category="Colors" name="Pink Palette" min=0]
float PinkPaletteWeight = 0.1;
[Setting category="Colors" name="White Palette" min=0]
float WhitePaletteWeight = 0.05;
[Setting category="Colors" name="Black Palette" min=0]
float BlackPaletteWeight = 0.05;


[Setting category="Colors" name="xdd Sign" min=0]
float xddSignWeight = 1.;
[Setting category="Colors" name="YEP Sign" min=0]
float YEPSignWeight = 1.;
[Setting category="Colors" name="Chatting Sign" min=0]
float ChattingSignWeight = 1;
[Setting category="Colors" name="YEK Sign" min=0]
float YEKSignWeight = 1.;
[Setting category="Colors" name="owo Sign" min=0]
float owoSignWeight = 1.;
[Setting category="Colors" name="Openplanet Sign" min=0]
float OpenplanetSignWeight = 0.5;
[Setting category="Colors" name="bla Sign" min=0]
float blaSignWeight = 1.;
[Setting category="Colors" name="uuh Sign" min=0]
float uuhSignWeight = 1.;
[Setting category="Colors" name="gettingjiggywithit Sign" min=0]
float gettingjiggywithitSignWeight = 1.;
[Setting category="Colors" name="LICKA Sign" min=0]
float LICKASignWeight = 1.;
[Setting category="Colors" name="Empty Sign" min=0]
float emptySignWeight = 0.;


[Setting category="Dev" name="Show dev tab"]
bool showDevTab = false;
[Setting category="Dev" name="Open plugin on reload"]
bool debugOpenReload= false;
[Setting category="Dev" name="debug print to console"]
bool debugPrint = false;
[Setting category="Dev" name="Step mode (press T)"]
bool debugStepMode = false;
[Setting category="Dev" name="Show failed blocks as ghost blocks"]
bool debugShowFails = false;
[Setting category="Dev" name="show position of latest block when reloaded (or press G to cycle)"]
bool debugLastBlock = false;

string pluginName = Meta::ExecutingPlugin().Name;
vec4 notificationOkColor = vec4(0.f, 0.5f, 0.f, 0.5f);
vec4 notificationWarningColor = vec4(0.5f, 0.5f, 0.f, 0.5f);
vec4 notificationErrorColor = vec4(0.5f, 0.f, 0.f, 0.5f);

// creates a trackgenerator, it will be started in main where it can yield
void StartGenerator () {
    @T = TrackGenerator();
}
void StopGenerator () {
    if (T !is null) {T.Interrupt();}
}

void ClearMap() {
    if (GetApp() is null) {return;}
    if (GetApp().Editor is null) {
        UI::ShowNotification(pluginName, "Error - map editor is not open", notificationErrorColor);
        return;}
    if (GetApp().CurrentPlayground !is null) {
        UI::ShowNotification(pluginName, "Return to edit mode first", notificationErrorColor);
        return;}
    CGameCtnEditorFree@ editor = cast<CGameCtnEditorFree>(GetApp().Editor);

    editor.PluginMapType.RemoveAllBlocksAndTerrain();
    editor.PluginMapType.AutoSave();
}

string getBlocksStatusText() {
    switch (blocksStatus) {
    case LoadStatus::NotLoaded:
        return 'Not Loaded';
    case LoadStatus::ToLoadAll:
        return 'Pending load all available blocks';
    case LoadStatus::LoadingAll:
        return 'Loading all available blocks...';
    case LoadStatus::All:
        return 'All available blocks loaded';
    case LoadStatus::LoadingExtra:
        return 'Adding extra blocks...';
    case LoadStatus::ToLoadNonzeroWeight:
        return 'Pending load nonzero weight blocks...';
    case LoadStatus::LoadingNonzeroWeight:
        return 'Loading nonzero weight blocks...';
    case LoadStatus::NonzeroWeight:
        return 'Nonzero weight blocks loaded';
    default:
        return '';
    }
}

uint currentTab = 0;
vec4 CreateColor = vec4(0, 0.9, 0, 1), SurfaceColor = vec4(0.9, 0, 0.9, 1), DirectionColor = vec4(0, 0, 0.9, 1), EffectsColor = vec4(0.9, 0.9, 0, 1), SpecialColor = vec4(0, 0.9, 0.9, 1), colorColor = vec4(0.9, 0, 0.9, 1), devColor = vec4(0.9, 0.4, 0, 1);
void RenderInterface() {
    if (!showInterface) {return;}
    if (GetApp() is null) {showInterface = false; return;}
    if (GetApp().Editor is null) {showInterface = false; return;}

    UI::SetNextWindowPos(100, 100, UI::Cond::Once);
    UI::SetNextWindowSize(440, 0, UI::Cond::Always);
    // switch (currentTab) {
    // case 0:
    //     UI::SetNextWindowSize(440, 610, UI::Cond::Always);
    //     break;
    // case 1:
    //     UI::SetNextWindowSize(440, 900, UI::Cond::Always);
    //     break;
    // case 2:
    //     UI::SetNextWindowSize(440, 420, UI::Cond::Always);
    //     break;
    // case 3:
    //     UI::SetNextWindowSize(440, 600, UI::Cond::Always);
    //     break;
    // case 4:
    //     UI::SetNextWindowSize(440, 420, UI::Cond::Always);
    //     break;
    // case 5:
    //     UI::SetNextWindowSize(440, 300, UI::Cond::Always);
    //     break;
    // case 6:
    //     UI::SetNextWindowSize(440, 300, UI::Cond::Always);
    //     break;
    // default:
    //    UI::SetNextWindowSize(440, 600, UI::Cond::Always);
    //     break;
    // }

    if (UI::Begin("Track Generator Extended ", showInterface, UI::WindowFlags::NoResize)) {
        Meta::Plugin@ plugin = Meta::ExecutingPlugin();

        float ButtonSize = 0;//UI::GetScale() * 24;


        UI::BeginTabBar("HUH who uses more than 1 tab bar?", UI::TabBarFlags::NoCloseWithMiddleMouseButton);

        UI::PushStyleColor(UI::Col::Tab, CreateColor * vec4(0.5, 0.5, 0.5, 0.75));
        UI::PushStyleColor(UI::Col::TabHovered, CreateColor * vec4(1.2, 1.2, 1.2, 0.85));
        UI::PushStyleColor(UI::Col::TabActive, CreateColor);

        if (UI::BeginTabItem("Generate")) {
            currentTab = 0;
#if DEPENDENCY_MLHOOK
#else
            UI::Text('\\$ff0'+Icons::ExclamationTriangle + '\\$z MLHook (plugin) dependency is not installed');
            UI::Separator();
#endif
            UI::Text('Loaded blocks status: ' + getBlocksStatusText());
            if (Permissions::OpenAdvancedMapEditor() && (blocksStatus == LoadStatus::NotLoaded || blocksStatus == LoadStatus::NonzeroWeight)) {
                if (UI::Button(Icons::FileTextO + " Load all block data")) {blocksStatus = LoadStatus::ToLoadAll;}// load in update, so it can yield
            } else {
                UI::BeginDisabled();
                UI::Button(Icons::FileTextO + " Load all block data");
                UI::EndDisabled();
            }
            UI::SameLine();
            if (UI::Button(Icons::FileText + " Load blocks with non 0 weight")) {blocksStatus = LoadStatus::ToLoadNonzeroWeight;}
            if ((blocksStatus == LoadStatus::All || blocksStatus == LoadStatus::NonzeroWeight) && (T is null || T.status != 1)) {
                if (UI::Button(Icons::Random + " Clear map and generate")) {ClearMap(); StartGenerator();}
            } else {
                UI::BeginDisabled();
                UI::Button(Icons::Random + " Clear map and generate");
                UI::EndDisabled();
            }
            UI::SameLine();
            if (T !is null && T.status == 1) {
                if (UI::Button("\\$d22" + Icons::Square + "\\$z Stop generation")) {StopGenerator();}
            } else {
                UI::BeginDisabled();
                UI::Button("\\$d22" + Icons::Square + "\\$z Stop generation");
                UI::EndDisabled();
            }
            if (UI::Button("\\$d22" + Icons::Trash + "\\$z Clear everything in map")) {ClearMap();}
            UI::SameLine();
            if ((blocksStatus == LoadStatus::All || blocksStatus == LoadStatus::NonzeroWeight) && (T is null || T.status != 1)) {
                if (UI::Button(Icons::Random + " Generate without clearing map")) {StartGenerator();}
            } else {
                UI::BeginDisabled();
                UI::Button(Icons::Random + " Generate without clearing map");
                UI::EndDisabled();
            }
            UI::Text("Usage (short version):");
            UI::TextWrapped("When opened, press load block data. \nThen use Generate to create a track.");
            if (UI::Button("##FinishDistance", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("FinishDistance").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            FinishDistance = Math::Max(UI::InputInt("\\$f22" + Icons::FlagCheckered + "\\$z Average track length", FinishDistance, UI::InputTextFlags::None), 0);
            if (UI::Button("##CheckpointDistance", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("CheckpointDistance").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            CheckpointDistance = Math::Max(UI::InputInt("\\$66f" + Icons::FlagO + "\\$z Average length between checkpoints", CheckpointDistance, UI::InputTextFlags::None), 0);
            float Length = 0.f, numCheckpoints = 0.f;
            int PieceCount = 0;
            string status; // format to 12?
            if (T is null) {
                status = '...';
            } else if (T.status == 0) {
                status = 'Not Started';
            } else if (T.status == 1) {
                status = 'Generating';
                if (T.trackSections.Length > 0) {
                    Length = T.trackSections[T.trackSections.Length-1].Length;
                    PieceCount = T.trackSections[T.trackSections.Length-1].PieceCount;
                    numCheckpoints = T.trackSections[T.trackSections.Length-1].numCheckpoints;
                }
            } else if (T.status == 2) {
                status = 'Finished';
                Length = T.trackSections[T.trackSections.Length-1].Length;
                PieceCount = T.trackSections[T.trackSections.Length-1].PieceCount;
                numCheckpoints = T.trackSections[T.trackSections.Length-1].numCheckpoints;
            } else if (T.status == 3) {
                status = 'Failed';
            } else {status = 'Unknown';}
            // UI::Text(status + 'Length: ' + Text::Format('% 5d', Length) + '    ' + 'Blocks: ' + Text::Format('% 5d', PieceCount) + '    ' + 'Checkpoints: ' + Text::Format('% 5d', numCheckpoints));
            vec2 startpos = UI::GetCursorPos();
            UI::Text(status);
            UI::SameLine();
            UI::SetCursorPos(vec2(startpos.x + 80, startpos.y));
            UI::Text('Length: ' + Length);
            UI::SameLine();
            UI::SetCursorPos(vec2(startpos.x + 170, startpos.y));
            UI::Text('Pieces: ' + PieceCount);
            UI::SameLine();
            UI::SetCursorPos(vec2(startpos.x + 230, startpos.y));
            UI::Text('Checkpoints: ' + numCheckpoints);

            startpos = UI::GetCursorPos();
            if (T !is null && T.generation_data.TotalTime > 0) {
                UI::Text('Plugin active duration: ' + Time::Format(T.generation_data.TotalTime - (T.generation_data.TimeFrameYielding + T.generation_data.TimeWaitingForEditor + T.generation_data.TimeWaitingForUserInput)));
                UI::SameLine();
                UI::SetCursorPos(vec2(startpos.x + 220, startpos.y));
                UI::Text('Realtime: ' + Time::Format(T.generation_data.TotalTime));
            } else {
                UI::Text('Plugin active duration: ' + Time::Format(0));
                UI::SameLine();
                UI::SetCursorPos(vec2(startpos.x + 220, startpos.y));
                UI::Text('Realtime: ' + Time::Format(0));
            }
            verticalSeparation = UI::Checkbox('##verticalSeparation', verticalSeparation);
            UI::SameLine();
            UI::TextWrapped('Increase vertical separation below placed blocks. This should ensure black platform is never blocked off.');
            WoodOnlyMode = UI::Checkbox('##WoodOnlyMode', WoodOnlyMode);
            UI::SameLine();
            UI::TextWrapped('Wood Only Mode - only use wood (snow road) blocks, no car gates.');
            WoodChaoticConnections = UI::Checkbox('##WoodChaoticConnections', WoodChaoticConnections);
            UI::SameLine();
            UI::TextWrapped('Chaotic Wood Connections - allow wood blocks to connect in any orientation (flat to slope, etc.).');
            StartAtCameraPosition = UI::Checkbox('##StartAtCameraPosition', StartAtCameraPosition);
            UI::SameLine();
            UI::TextWrapped('Start at Camera Position - use editor camera position as track starting point instead of random location.');
            EnableCustomSigns = UI::Checkbox('##EnableCustomSigns', EnableCustomSigns);
            UI::SameLine();
            UI::TextWrapped('Enable Custom Checkpoint Signs - apply custom image URLs to checkpoints, start, and finish.');
            if (EnableCustomSigns) {
                UI::SetNextItemWidth(400);
                CustomCheckpointSignURL = UI::InputText('Checkpoint Sign URL', CustomCheckpointSignURL);
                UI::SetNextItemWidth(400);
                CustomStartFinishSignURL = UI::InputText('Start/Finish Sign URL', CustomStartFinishSignURL);
            }
            UI::TextWrapped("Blocks are chosen based on a weight system. Each block has a weight which is calculated multiplicatively from the values in the next sections, and each valid block has probabilty [its weight / total weight] of being chosen. Blocks with less variants (such as change-material) have a lower total probability for all of them, and should have higher weights to counter this.");
            if (UI::Button("##weightLoss", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("weightLoss").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(50);
            weightLoss =  Math::Clamp(UI::InputFloat("\\$ff0" + Icons::Minus + "\\$z Weight left (1 - % options that failed) before undo", weightLoss, UI::InputTextFlags::None), 0., 1.);
            if (UI::Button("##errorTries", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("errorTries").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(50);
            errorTries =  uint(Math::Max(UI::InputInt("\\$ff0" + Icons::Times + "\\$z Max place-attempts for a single position", errorTries, UI::InputTextFlags::None), 1));
            showDevTab = UI::Checkbox("Show Dev tab", showDevTab);
            UI::EndTabItem();
        }
        UI::PopStyleColor(3);
        UI::PushStyleColor(UI::Col::Tab, SurfaceColor * vec4(0.5, 0.5, 0.5, 0.75));
        UI::PushStyleColor(UI::Col::TabHovered, SurfaceColor * vec4(1.2, 1.2, 1.2, 0.85));
        UI::PushStyleColor(UI::Col::TabActive, SurfaceColor);
        if (UI::BeginTabItem("Surfaces")) {

            UI::PushStyleVar(UI::StyleVar::ItemSpacing, vec2(UI::GetStyleVarVec2(UI::StyleVar::ItemSpacing).x, UI::GetStyleVarVec2(UI::StyleVar::ItemSpacing).y*0.5));
            currentTab = 1;//"##VariableName"
            UI::Text("Weights for surface types");
            if (UI::Button("##ChangeMaterialWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("ChangeMaterialWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            ChangeMaterialWeight = Math::Max(UI::InputFloat("\\$f0f" + Icons::Random + "\\$z Change Material", ChangeMaterialWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##ChangeBorderWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("ChangeBorderWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            ChangeBorderWeight = Math::Max(UI::InputFloat("\\$f0f" + Icons::Random + "\\$z Change border (not material)", ChangeBorderWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##btn1", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("RoadTechWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            RoadTechWeight = Math::Max(UI::InputFloat("\\$bbb" + Icons::Road + "\\$z Road tech (concrete)", RoadTechWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##RoadDirtWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("RoadDirtWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            RoadDirtWeight = Math::Max(UI::InputFloat("\\$d86" + Icons::Road + "\\$z Road dirt", RoadDirtWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##RoadBumpWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("RoadBumpWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            RoadBumpWeight = Math::Max(UI::InputFloat("\\$b22" + Icons::CaretUp + "\\$z Road bump (sausage)", RoadBumpWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##RoadIceWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("RoadIceWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            RoadIceWeight = Math::Max(UI::InputFloat("\\$def" + Icons::SnowflakeO + "\\$z Road ice (bobsled)", RoadIceWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##UnderwaterBobsledWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("UnderwaterBobsledWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            UnderwaterBobsledWeight = Math::Max(UI::InputFloat("\\$8cc" + Icons::SnowflakeO + "\\$z Underwater Bobsled", UnderwaterBobsledWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##RoadWaterWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("RoadWaterWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            RoadWaterWeight = Math::Max(UI::InputFloat("\\$aff" + Icons::Tint + "\\$z Road water", RoadWaterWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##SnowRoadWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("SnowRoadWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            SnowRoadWeight = Math::Max(UI::InputFloat("\\$a75" + Icons::Th + "\\$z Snow Road (Wood)", SnowRoadWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##RallyCastleRoadWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("RallyCastleRoadWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            RallyCastleRoadWeight = Math::Max(UI::InputFloat("\\$bB9" + Icons::Kenney::Cells + "\\$z Rally Castle Dirt Road", RallyCastleRoadWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##RallyRoadDirtHighWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("RallyRoadDirtHighWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            RallyRoadDirtHighWeight = Math::Max(UI::InputFloat("\\$d86" + Icons::ChevronCircleUp + "\\$z Rally High Dirt Road (penalty border)", RallyRoadDirtHighWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##RallyRoadDirtLowWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("RallyRoadDirtLowWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            RallyRoadDirtLowWeight = Math::Max(UI::InputFloat("\\$d86" + Icons::ChevronCircleDown + "\\$z Rally Low Dirt Road (penalty border)", RallyRoadDirtLowWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##RallyRoadMudLowWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("RallyRoadMudLowWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            RallyRoadMudLowWeight = Math::Max(UI::InputFloat("\\$8cc" + Icons::ChevronCircleDown + "\\$z Rally Low Mud (Dirt + Water) Road", RallyRoadMudLowWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##TrackWallWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("TrackWallWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            TrackWallWeight = Math::Max(UI::InputFloat("\\$222" + Icons::SquareO + "\\$z Surfaceless / Track support", TrackWallWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##TrackWallWaterWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("TrackWallWaterWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            TrackWallWaterWeight = Math::Max(UI::InputFloat("\\$8cc" + Icons::Tint + "\\$z Road deep water", TrackWallWaterWeight, UI::InputTextFlags::None), 0.);

            if (UI::Button("##PlatformTechWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("PlatformTechWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            PlatformTechWeight = Math::Max(UI::InputFloat("\\$bbb" + Icons::Square + "\\$z Platform tech (concrete)", PlatformTechWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##PlatformDirtWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("PlatformDirtWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            PlatformDirtWeight = Math::Max(UI::InputFloat("\\$d86" + Icons::Square + "\\$z Platform dirt", PlatformDirtWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##PlatformIceWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("PlatformIceWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            PlatformIceWeight = Math::Max(UI::InputFloat("\\$def" + Icons::SnowflakeO + "\\$z Platform ice", PlatformIceWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##PlatformGrassWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("PlatformGrassWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            PlatformGrassWeight = Math::Max(UI::InputFloat("\\$ac7" + Icons::Square + "\\$z Platform grass", PlatformGrassWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##PlatformPlasticWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("PlatformPlasticWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            PlatformPlasticWeight = Math::Max(UI::InputFloat("\\$ed4" + Icons::Square + "\\$z Platform plastic", PlatformPlasticWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##PlatformWaterWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("PlatformWaterWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            PlatformWaterWeight = Math::Max(UI::InputFloat("\\$aff" + Icons::Tint + "\\$z Platform water", PlatformWaterWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##DecoWallWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("DecoWallWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            DecoWallWeight = Math::Max(UI::InputFloat("\\$222" + Icons::SquareO + "\\$z Surfaceless / Platform support", DecoWallWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##DecoWallWaterWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("DecoWallWaterWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            DecoWallWaterWeight = Math::Max(UI::InputFloat("\\$8cc" + Icons::Tint + "\\$z Platform deep water", DecoWallWaterWeight, UI::InputTextFlags::None), 0.);

            if (UI::Button("##OpenTechWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("OpenTechWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            OpenTechWeight = Math::Max(UI::InputFloat("\\$bbb" + Icons::EllipsisV + "\\$z Platform tech with penalty border", OpenTechWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##OpenDirtWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("OpenDirtWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            OpenDirtWeight = Math::Max(UI::InputFloat("\\$d86" + Icons::EllipsisV + "\\$z Platform dirt with penalty border", OpenDirtWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##OpenIceWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("OpenIceWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            OpenIceWeight = Math::Max(UI::InputFloat("\\$def" + Icons::SnowflakeO + "\\$z Platform ice with penalty border", OpenIceWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##OpenGrassWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("OpenGrassWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            OpenGrassWeight = Math::Max(UI::InputFloat("\\$ac7" + Icons::Leaf + "\\$z Platform grass with penalty border", OpenGrassWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##WaterGrassWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("WaterGrassWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            WaterGrassWeight = Math::Max(UI::InputFloat("\\$895" + Icons::Tint + "\\$z Platform water with penalty grass border", WaterGrassWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##WaterDirtWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("WaterDirtWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            WaterDirtWeight = Math::Max(UI::InputFloat("\\$fda" + Icons::Tint + "\\$z Platform water with sand border", WaterDirtWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##WaterIceWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("WaterIceWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            WaterIceWeight = Math::Max(UI::InputFloat("\\$eff" + Icons::Tint + "\\$z Platform water with snow border", WaterIceWeight, UI::InputTextFlags::None), 0.);

            UI::PushStyleColor(UI::Col::Text, vec4(0.9, 0, 0, 0.9));
            if (UI::Button("##PenaltyGrassWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("PenaltyGrassWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            PenaltyGrassWeight = Math::Max(UI::InputFloat("\\$895" + Icons::Leaf + "\\$z Platform penalty grass", PenaltyGrassWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##PenaltySandWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("PenaltySandWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            PenaltySandWeight = Math::Max(UI::InputFloat("\\$fda" + Icons::Square + "\\$z Platform penalty sand", PenaltySandWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##PenaltySnowWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("PenaltySnowWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            PenaltySnowWeight = Math::Max(UI::InputFloat("\\$eff" + Icons::SnowflakeO + "\\$z Platform penalty snow", PenaltySnowWeight, UI::InputTextFlags::None), 0.);
            UI::PopStyleColor(1);

            if (UI::Button("##StructureWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("StructureWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            StructureWeight = Math::Max(UI::InputFloat("\\$eff" + Icons::Minus + "\\$z Structure beam", StructureWeight, UI::InputTextFlags::None), 0.);

            if (UI::Button("##StandWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("StandWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            StandWeight = Math::Max(UI::InputFloat("\\$eff" + Icons::User + "\\$z Stand (driving on spectators)", StandWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##StageWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("StageWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            StageWeight = Math::Max(UI::InputFloat("\\$eff" + Icons::Minus + "\\$z Stage", StageWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##StagePlatformWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("StagePlatformWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            StagePlatformWeight = Math::Max(UI::InputFloat("\\$eff" + Icons::Minus + "\\$z Stage support (long side)", StagePlatformWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##StageSupportWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("StageSupportWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            StageSupportWeight = Math::Max(UI::InputFloat("\\$eff" + Icons::Minus + "\\$z Stage Support", StageSupportWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##StageSupportPlatformWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("StageSupportPlatformWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            StageSupportPlatformWeight = Math::Max(UI::InputFloat("\\$eff" + Icons::Minus + "\\$z Stage Support (long side)", StageSupportPlatformWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##StageInsideWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("StageInsideWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            StageInsideWeight = Math::Max(UI::InputFloat("\\$eff" + " =  " + "\\$z Stage Inside", StageInsideWeight, UI::InputTextFlags::None), 0.);
            UI::PopStyleVar();
            UI::EndTabItem();
        }
        UI::PopStyleColor(3);
        UI::PushStyleColor(UI::Col::Tab, DirectionColor * vec4(0.5, 0.5, 0.5, 0.75));
        UI::PushStyleColor(UI::Col::TabHovered, DirectionColor * vec4(1.2, 1.2, 1.2, 0.85));
        UI::PushStyleColor(UI::Col::TabActive, DirectionColor);
        if (UI::BeginTabItem("Angle")) {
            currentTab = 2;
            UI::Text("Weights for block slopes / connection types");
            if (UI::Button("##CornerWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("CornerWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            CornerWeight = Math::Max(UI::InputFloat("\\$fff" + Icons::LevelUp + "\\$z Corners", CornerWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##FlatWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("FlatWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            FlatWeight = Math::Max(UI::InputFloat("\\$fff" + Icons::LongArrowRight + "\\$z Flat (no slope/tilt)", FlatWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##SlopeWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("SlopeWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            SlopeWeight = Math::Max(UI::InputFloat("\\$fff" + Icons::ArrowUp + "\\$z Slope (uphill / downhill)", SlopeWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##TiltWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("TiltWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            TiltWeight = Math::Max(UI::InputFloat("\\$fff" + Icons::Check + "\\$z Tilt (sideways)", TiltWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##DiagonalWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("DiagonalWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            DiagonalWeight = Math::Max(UI::InputFloat("\\$fff" + Icons::Italic + "\\$z Diagonal", DiagonalWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##LoopWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("LoopWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            LoopWeight = Math::Max(UI::InputFloat("\\$fff" + Icons::Repeat + "\\$z Loops", LoopWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##TiltCurvedWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("TiltCurvedWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            TiltCurvedWeight = Math::Max(UI::InputFloat("\\$fff" + Icons::Kenney::MoveBr + "\\$z Tilt (curved)", TiltCurvedWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##SlightTiltWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("SlightTiltWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            SlightTiltWeight = Math::Max(UI::InputFloat("\\$fff" + Icons::LongArrowRight + "\\$z Slight tilt", SlightTiltWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##JunctionWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("JunctionWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            JunctionWeight = Math::Max(UI::InputFloat("\\$fff" + Icons::Plus + "\\$z Junctions ( >2 connectors)", JunctionWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##ChangeSlopeWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("ChangeSlopeWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            ChangeSlopeWeight = Math::Max(UI::InputFloat("\\$fff" + Icons::ArrowUp + "\\$z Change / start / end slope", ChangeSlopeWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##ChangeTiltWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("ChangeTiltWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            ChangeTiltWeight = Math::Max(UI::InputFloat("\\$fff" + Icons::Check + "\\$z Change / start / end tilt", ChangeTiltWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##ChangeAngleWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("ChangeAngleWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            ChangeAngleWeight = Math::Max(UI::InputFloat("\\$fff" + Icons::ChevronUp + "\\$z Change / start / end either slope and/or tilt", ChangeAngleWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##SideConnectionOpenWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("SideConnectionOpenWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            SideConnectionOpenWeight = Math::Max(UI::InputFloat("\\$fff" + Icons::ArrowRight + "\\$z Side connection (open platform)", SideConnectionOpenWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##SideConnectionPlatformWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("SideConnectionPlatformWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            SideConnectionPlatformWeight = Math::Max(UI::InputFloat("\\$fff" + Icons::ArrowRight + "\\$z Side connection (4-way platform)", SideConnectionPlatformWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##SideConnectionTWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("SideConnectionTWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            SideConnectionTWeight = Math::Max(UI::InputFloat("\\$fff" + Icons::ArrowRight + "\\$z Side connection (3-way platform)", SideConnectionTWeight, UI::InputTextFlags::None), 0.);
            UI::EndTabItem();
        }
        UI::PopStyleColor(3);
        UI::PushStyleColor(UI::Col::Tab, EffectsColor * vec4(0.5, 0.5, 0.5, 0.75));
        UI::PushStyleColor(UI::Col::TabHovered, EffectsColor * vec4(1.2, 1.2, 1.2, 0.85));
        UI::PushStyleColor(UI::Col::TabActive, EffectsColor);
        if (UI::BeginTabItem("Effects")) {
            currentTab = 3;
            UI::Text("Weights for effects");
            if (UI::Button("##TurboWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("TurboWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            TurboWeight = Math::Max(UI::InputFloat("\\$ff0" + Icons::ArrowUp + "\\$z Turbo", TurboWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##AntiTurboWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("AntiTurboWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            AntiTurboWeight = Math::Max(UI::InputFloat("\\$ff0" + Icons::ArrowDown + "\\$z Anti turbo", AntiTurboWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##SuperTurboWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("SuperTurboWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            SuperTurboWeight = Math::Max(UI::InputFloat("\\$f00" + Icons::ArrowUp + "\\$z Super-turbo", SuperTurboWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##AntiSuperTurboWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("AntiSuperTurboWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            AntiSuperTurboWeight = Math::Max(UI::InputFloat("\\$f00" + Icons::ArrowDown + "\\$z Anti super-turbo", AntiSuperTurboWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##RandomTurboWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("RandomTurboWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            RandomTurboWeight = Math::Max(UI::InputFloat("\\$f0f" + Icons::ArrowUp + "\\$z Random turbo", RandomTurboWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##AntiRandomTurboWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("AntiRandomTurboWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            AntiRandomTurboWeight = Math::Max(UI::InputFloat("\\$f0f" + Icons::ArrowDown + "\\$z Anti random turbo", AntiRandomTurboWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##BoostUpWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("BoostUpWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            BoostUpWeight = Math::Max(UI::InputFloat("\\$cf0" + Icons::ChevronUp + "\\$z Reactor boost up", BoostUpWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##BoostDownWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("BoostDownWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            BoostDownWeight = Math::Max(UI::InputFloat("\\$cf0" + Icons::ChevronDown + "\\$z Reactor boost down", BoostDownWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##Boost2UpWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("Boost2UpWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            Boost2UpWeight = Math::Max(UI::InputFloat("\\$f93" + Icons::ChevronUp + "\\$z Super reactor boost up", Boost2UpWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##Boost2DownWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("Boost2DownWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            Boost2DownWeight = Math::Max(UI::InputFloat("\\$f93" + Icons::ChevronDown + "\\$z Super reactor boost down", Boost2DownWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##CruiseWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("CruiseWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            CruiseWeight = Math::Max(UI::InputFloat("\\$44f" + Icons::Repeat + "\\$z Cruise control", CruiseWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##NoBrakeWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("NoBrakeWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            NoBrakeWeight = Math::Max(UI::InputFloat("\\$fc3" + Icons::ExclamationCircle + "\\$z No brakes", NoBrakeWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##NoEngineWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("NoEngineWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            NoEngineWeight = Math::Max(UI::InputFloat("\\$f00" + Icons::PowerOff + "\\$z No engine", NoEngineWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##NoSteeringWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("NoSteeringWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            NoSteeringWeight = Math::Max(UI::InputFloat("\\$f0f" + Icons::DotCircleO + "\\$z No steering", NoSteeringWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##SlowMotionWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("SlowMotionWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            SlowMotionWeight = Math::Max(UI::InputFloat("\\$eee" + Icons::PlayCircleO + "\\$z Slow motion", SlowMotionWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##FragileWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("FragileWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            FragileWeight = Math::Max(UI::InputFloat("\\$f90" + Icons::CircleONotch + "\\$z Fragile", FragileWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##ResetWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("ResetWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            ResetWeight = Math::Max(UI::InputFloat("\\$2e2" + Icons::TimesCircleO + "\\$z Reset", ResetWeight, UI::InputTextFlags::None), 0.);
            UI::EndTabItem();
        }
        UI::PopStyleColor(3);
        UI::PushStyleColor(UI::Col::Tab, SpecialColor * vec4(0.5, 0.5, 0.5, 0.75));
        UI::PushStyleColor(UI::Col::TabHovered, SpecialColor * vec4(1.2, 1.2, 1.2, 0.85));
        UI::PushStyleColor(UI::Col::TabActive, SpecialColor);
        if (UI::BeginTabItem("Special")) {
            currentTab = 4;
            UI::Text("Weights for special blocks");
            if (UI::Button("##RepeatWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("RepeatWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            RepeatWeight = Math::Max(UI::InputFloat("\\$fff" + Icons::Repeat + "\\$z Repeated blocks", RepeatWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##HoleWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("HoleWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            HoleWeight = Math::Max(UI::InputFloat("\\$bbb" + Icons::SquareO + "\\$z Hole", HoleWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##PenaltyRoadWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("PenaltyRoadWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            PenaltyRoadWeight = Math::Max(UI::InputFloat("\\$895" + Icons::Minus + "\\$z Penalty (in track)", PenaltyRoadWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##BumpWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("BumpWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            BumpWeight = Math::Max(UI::InputFloat("\\$d86" + Icons::CaretUp + "\\$z Bump (on dirt)", BumpWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##NarrowWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("NarrowWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            NarrowWeight = Math::Max(UI::InputFloat("\\$b22" + Icons::CaretRight + "\\$z Narrow", NarrowWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##IceWallWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("IceWallWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            IceWallWeight = Math::Max(UI::InputFloat("\\$def" + " | " + "\\$z High wall (ice)", IceWallWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##IceWallChangeWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("IceWallChangeWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            IceWallChangeWeight = Math::Max(UI::InputFloat("\\$def" + " | " + "\\$z Change high wall unsmooth (ice)", IceWallChangeWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##RampWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("RampWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            RampWeight = Math::Max(UI::InputFloat("\\$bbb" + Icons::Kenney::ArrowTopRight + "\\$z Ramp (on tech / concrete)", RampWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##AntiRampWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("AntiRampWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            AntiRampWeight = Math::Max(UI::InputFloat("\\$bbb" + Icons::Kenney::ArrowBottomLeft + "\\$z Anti Ramp (on tech / concrete)", AntiRampWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##PolesWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("PolesWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            PolesWeight = Math::Max(UI::InputFloat("\\$ee2" + Icons::Exclamation + "\\$z Poles (and spinners)", PolesWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##PlatformUnsmoothWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("PlatformUnsmoothWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            PlatformUnsmoothWeight = Math::Max(UI::InputFloat("\\$eef" + Icons::SquareO + "\\$z Platform weird edges (e.g. curve with cutout)", PlatformUnsmoothWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##JumpStartWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("JumpStartWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            JumpStartWeight = Math::Max(UI::InputFloat("\\$eef" + Icons::ChevronUp + "\\$z Jump start (gap after ramp)", JumpStartWeight, UI::InputTextFlags::None), 0.);
        if (UI::Button("##DropJumpStartWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("DropJumpStartWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            DropJumpStartWeight = Math::Max(UI::InputFloat("\\$eef" + Icons::ChevronUp + "\\$z Drop jump start (gap without ramp)", DropJumpStartWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##JumpContinueWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("JumpContinueWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            JumpContinueWeight = Math::Max(UI::InputFloat("\\$eef" + Icons::SquareO + "\\$z Jump continue", JumpContinueWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##JumpContinueMultiplier", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("JumpContinueMultiplier").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            JumpContinueMultiplier = Math::Max(UI::InputFloat("\\$eef" + Icons::SquareO + "\\$z Jump continue multiplier", JumpContinueMultiplier, UI::InputTextFlags::None), 0.);
            if (UI::Button("##MultilapWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("MultilapWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            MultilapWeight = Math::Max(UI::InputFloat("\\$ff0" + Icons::FlagCheckered + "\\$z Multilap blocks", MultilapWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##FakeFinishWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("FakeFinishWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            FakeFinishWeight = Math::Max(UI::InputFloat("\\$e22" + Icons::FlagCheckered + "\\$z Random finish blocks", FakeFinishWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##CarChangeWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("CarChangeWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            CarChangeWeight = Math::Max(UI::InputFloat("\\$f0f" + Icons::Random + "\\$z Car change (transform blocks)", CarChangeWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##CarStadiumWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("CarStadiumWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            CarStadiumWeight = Math::Max(UI::InputFloat("\\$888" + Icons::Car + "\\$z Stadium Car (transform blocks)", CarStadiumWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##CarSnowWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("CarSnowWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            CarSnowWeight = Math::Max(UI::InputFloat("\\$b11" + Icons::Truck + "\\$z Snow Car (transform blocks)", CarSnowWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##CarRallyWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("CarRallyWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            CarRallyWeight = Math::Max(UI::InputFloat("\\$c81" + Icons::Car + "\\$z Rally Car (transform blocks)", CarRallyWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##CarDesertWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("CarDesertWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            CarDesertWeight = Math::Max(UI::InputFloat("\\$cc1" + Icons::Car + "\\$z Desert Car (transform blocks)", CarDesertWeight, UI::InputTextFlags::None), 0.);

            UI::EndTabItem();
        }
        UI::PopStyleColor(3);
        UI::PushStyleColor(UI::Col::Tab, colorColor * vec4(0.5, 0.5, 0.5, 0.75));
        UI::PushStyleColor(UI::Col::TabHovered, colorColor * vec4(1.2, 1.2, 1.2, 0.85));
        UI::PushStyleColor(UI::Col::TabActive, colorColor);
        if (UI::BeginTabItem("Colors")) {
            currentTab = 5;
            UI::Text("Weights for block colors");
            if (UI::Button("##ChangeColorWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("ChangeColorWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            ChangeColorWeight = Math::Max(UI::InputFloat("\\$f0f" + Icons::Random + "\\$z Change color", ChangeColorWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##DefaultColorWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("DefaultColorWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            DefaultColorWeight = Math::Max(UI::InputFloat("\\$fd8" + Icons::Square + "\\$z Default color", DefaultColorWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##WhiteColorWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("WhiteColorWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            WhiteColorWeight = Math::Max(UI::InputFloat("\\$fff" + Icons::Square + "\\$z White color", WhiteColorWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##GreenColorWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("GreenColorWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            GreenColorWeight = Math::Max(UI::InputFloat("\\$0f0" + Icons::Square + "\\$z Green color", GreenColorWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##BlueColorWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("BlueColorWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            BlueColorWeight = Math::Max(UI::InputFloat("\\$00f" + Icons::Square + "\\$z Blue color", BlueColorWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##RedColorWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("RedColorWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            RedColorWeight = Math::Max(UI::InputFloat("\\$f00" + Icons::Square + "\\$z Red color", RedColorWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##BlackColorWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("BlackColorWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            BlackColorWeight = Math::Max(UI::InputFloat("\\$000" + Icons::Square + "\\$z Black color", BlackColorWeight, UI::InputTextFlags::None), 0.);
            UI::Separator();
            UI::Text("Weights for color palettes");
            if (UI::Button("##ClassicPaletteWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("ClassicPaletteWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            ClassicPaletteWeight = Math::Max(UI::InputFloat("\\$888" + Icons::Square + "\\$z Classic Palette", ClassicPaletteWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##StuntPaletteWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("StuntPaletteWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            StuntPaletteWeight = Math::Max(UI::InputFloat("\\$ccc" + Icons::Square + "\\$z Stunt Palette", StuntPaletteWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##RedPaletteWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("RedPaletteWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            RedPaletteWeight = Math::Max(UI::InputFloat("\\$e00" + Icons::Square + "\\$z Red Palette", RedPaletteWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##OrangePaletteWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("OrangePaletteWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            OrangePaletteWeight = Math::Max(UI::InputFloat("\\$e70" + Icons::Square + "\\$z Orange Palette", OrangePaletteWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##YellowPaletteWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("YellowPaletteWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            YellowPaletteWeight = Math::Max(UI::InputFloat("\\$ee0" + Icons::Square + "\\$z Yellow Palette", YellowPaletteWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##LimePaletteWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("LimePaletteWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            LimePaletteWeight = Math::Max(UI::InputFloat("\\$7e0" + Icons::Square + "\\$z Lime Palette", LimePaletteWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##GreenPaletteWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("GreenPaletteWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            GreenPaletteWeight = Math::Max(UI::InputFloat("\\$0a0" + Icons::Square + "\\$z Green Palette", GreenPaletteWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##CyanPaletteWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("CyanPaletteWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            CyanPaletteWeight = Math::Max(UI::InputFloat("\\$0ee" + Icons::Square + "\\$z Cyan Palette", CyanPaletteWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##BluePaletteWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("BluePaletteWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            BluePaletteWeight = Math::Max(UI::InputFloat("\\$00e" + Icons::Square + "\\$z Blue Palette", BluePaletteWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##PurplePaletteWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("PurplePaletteWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            PurplePaletteWeight = Math::Max(UI::InputFloat("\\$70e" + Icons::Square + "\\$z Purple Palette", PurplePaletteWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##PinkPaletteWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("PinkPaletteWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            PinkPaletteWeight = Math::Max(UI::InputFloat("\\$e7e" + Icons::Square + "\\$z Pink Palette", PinkPaletteWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##WhitePaletteWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("WhitePaletteWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            WhitePaletteWeight = Math::Max(UI::InputFloat("\\$eee" + Icons::Square + "\\$z White Palette", WhitePaletteWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##BlackPaletteWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("BlackPaletteWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            BlackPaletteWeight = Math::Max(UI::InputFloat("\\$111" + Icons::Square + "\\$z Black Palette", BlackPaletteWeight, UI::InputTextFlags::None), 0.);
            UI::Separator();
            UI::Text("Weights for sign images");
            if (UI::Button("##xddSignWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("xddSignWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            xddSignWeight = Math::Max(UI::InputFloat("\\$cc8" + Icons::Square + "\\$z xdd Sign Weight", xddSignWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##YEPSignWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("YEPSignWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            YEPSignWeight = Math::Max(UI::InputFloat("\\$694" + Icons::Square + "\\$z YEP Sign Weight", YEPSignWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##ChattingSignWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("ChattingSignWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            ChattingSignWeight = Math::Max(UI::InputFloat("\\$694" + Icons::Square + "\\$z Chatting Sign Weight", ChattingSignWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##YEKSignWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("YEKSignWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            YEKSignWeight = Math::Max(UI::InputFloat("\\$d00" + Icons::Question + "\\$z YEK Sign Weight", YEKSignWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##owoSignWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("owoSignWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            owoSignWeight = Math::Max(UI::InputFloat("\\$694" + Icons::Square + "\\$z owo Sign Weight", owoSignWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##OpenplanetSignWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("OpenplanetSignWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            OpenplanetSignWeight = Math::Max(UI::InputFloat("\\$f4e" + Icons::Heartbeat + "\\$z Openplanet Sign Weight", OpenplanetSignWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##blaSignWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("blaSignWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            blaSignWeight = Math::Max(UI::InputFloat("\\$dcb" + Icons::Square + "\\$z bla Sign Weight", blaSignWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##uuhSignWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("uuhSignWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            uuhSignWeight = Math::Max(UI::InputFloat("\\$dcb" + Icons::Square + "\\$z uuh Sign Weight", uuhSignWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##gettingjiggywithitSignWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("gettingjiggywithitSignWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            gettingjiggywithitSignWeight = Math::Max(UI::InputFloat("\\$887" + Icons::Square + "\\$z gettingjiggywithit Sign Weight", gettingjiggywithitSignWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##LICKASignWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("LICKASignWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            LICKASignWeight = Math::Max(UI::InputFloat("\\$ede" + Icons::Square + "\\$z LICKA Sign Weight", LICKASignWeight, UI::InputTextFlags::None), 0.);
            if (UI::Button("##emptySignWeight", vec2(ButtonSize,ButtonSize))) {plugin.GetSetting("emptySignWeight").Reset();}
            UI::SameLine();
            UI::SetNextItemWidth(80);
            emptySignWeight = Math::Max(UI::InputFloat("\\$000" + Icons::SquareO + "\\$z Empty Sign Weight", emptySignWeight, UI::InputTextFlags::None), 0.);

            UI::EndTabItem();
        }
        UI::PopStyleColor(3);
        if (showDevTab) {
            UI::PushStyleColor(UI::Col::Tab, devColor * vec4(0.5, 0.5, 0.5, 0.75));
            UI::PushStyleColor(UI::Col::TabHovered, devColor * vec4(1.2, 1.2, 1.2, 0.85));
            UI::PushStyleColor(UI::Col::TabActive, devColor);
            if (UI::BeginTabItem("Dev")) {
                currentTab = 6;
                debugOpenReload = UI::Checkbox("Open plugin when reloaded", debugOpenReload);
                debugPrint = UI::Checkbox("Debug print to log", debugPrint);
                debugStepMode = UI::Checkbox("Step mode (press T for next block)", debugStepMode);
                if (!(T is null) && T.status == 1) {
                    if (UI::Button("Place block to show position")) {T.showPosition();}
                } else {
                    UI::BeginDisabled();
                    UI::Button("Place block to show position");
                    UI::EndDisabled();
                }
                debugShowFails = UI::Checkbox("Show failed blocks as ghost blocks", debugShowFails);
                debugLastBlock = UI::Checkbox("Show position of latest block when reloaded (or press G to cycle)", debugLastBlock);
                // if (UI::Button("\\$f0f" + Icons::ChevronDown + "\\$z Reset air mode to off")) {
                //     CGameCtnEditorFree@ editor = cast<CGameCtnEditorFree>(GetApp().Editor);
                //     if (!(editor is null)) {
                //         editor.ExperimentalFeatures.IsAutoAirMappingEnabled = false;
                //         editor.ExperimentalFeatures.AutoAirMapping_MaxPillarCount = 8;
                //     }
                // }
#if RECREATEBLOCKSFILE
                if (Meta::ExecutingPlugin().Type == Meta::PluginType::Folder) {
                    if (UI::Button("\\$f0f" + Icons::Random + "\\$z Dev_Save Loaded Blocks to file")) {
                        SaveBlocks();
                    }
                } else {
#elif  }
#else
                {
#endif
                    UI::BeginDisabled();
                    UI::Button("\\$f0f" + Icons::Random + "\\$z Dev_Save Loaded Blocks to file");
                    UI::EndDisabled();
                }
                // if (UI::Button(Icons::FileText + " Load Extra Blocks")) {
                //     LoadExtraBlocks("TGE_Extra.json");
                //     @T = TrackGenerator(true);
                // }
                if (T !is null) {
                    UI::Separator();
                    UI::SetNextItemWidth(100);
                    UI::LabelText('Total time generating this map', Time::Format(T.generation_data.TotalTime));
                    UI::SetNextItemWidth(100);
                    UI::LabelText('Time yielding due to editor not ready', Time::Format(T.generation_data.TimeWaitingForEditor));
                    UI::SetNextItemWidth(100);
                    UI::LabelText('Time yielding due to frame length', Time::Format(T.generation_data.TimeFrameYielding));
                    UI::SetNextItemWidth(100);
                    UI::LabelText('Time yielding to wait for user input', Time::Format(T.generation_data.TimeWaitingForUserInput));
                    UI::Separator();
                    UI::SetNextItemWidth(100);
                    UI::LabelText('Time preparing to generate', Time::Format(T.generation_data.TimeStartup));
                    UI::SetNextItemWidth(100);
                    UI::LabelText('Time unspecified processing', Time::Format(T.generation_data.TimeProcessing));
                    UI::SetNextItemWidth(100);
                    UI::LabelText('Time placing blocks', Time::Format(T.generation_data.TimePlacingBlock));
                    UI::SetNextItemWidth(100);
                    UI::LabelText('Time undoing', Time::Format(T.generation_data.TimeUndoing));
                    UI::SetNextItemWidth(100);
                    UI::LabelText('Time selecting the next block', Time::Format(T.generation_data.TimeRandomSelecting));
                    UI::SetNextItemWidth(100);
                    UI::LabelText('Time refreshing the map', Time::Format(T.generation_data.TimeRefreshing));
                } else {
                    UI::BeginDisabled();
                    UI::Separator();
                    UI::SetNextItemWidth(100);
                    UI::LabelText('Total time generating this map', '0');
                    UI::SetNextItemWidth(100);
                    UI::LabelText('Time yielding due to editor not ready', '0');
                    UI::SetNextItemWidth(100);
                    UI::LabelText('Time yielding due to frame length', '0');
                    UI::SetNextItemWidth(100);
                    UI::LabelText('Time yielding to wait for user input', '0');
                    UI::Separator();
                    UI::SetNextItemWidth(100);
                    UI::LabelText('Time preparing to generate', '0');
                    UI::SetNextItemWidth(100);
                    UI::LabelText('Time unspecified processing', '0');
                    UI::SetNextItemWidth(100);
                    UI::LabelText('Time placing blocks', '0');
                    UI::SetNextItemWidth(100);
                    UI::LabelText('Time undoing', '0');
                    UI::SetNextItemWidth(100);
                    UI::LabelText('Time selecting the next block', '0');
                    UI::SetNextItemWidth(100);
                    UI::LabelText('Time refreshing the map', '0');
                    UI::EndDisabled();
                }
                if (UI::Button('Print block lengths')) {
                    print('printing inaccurate block lengths');
                    print(tostring(Blocks.Length) + ' blocks long');
                    for (uint i = 0; i < Blocks.Length; i++) {
                        Blocks[i].printLengthAccuracy();
                    }
                }
                if (UI::Button('print track blocks')) {
                    if (T !is null) {
                        print('printing track blocks');
                        print(tostring(T.trackSections.Length) + ' blocks long');
                        for (uint i = 0; i < T.trackSections.Length; i++) {
                            print(T.trackSections[i].thisBlock.NameID + ' ' + tostring(T.trackSections[i].thisBlock.startConnector) + ' ' + tostring(T.trackSections[i].thisBlock.endConnector));
                        }
                    }
                }

                UI::EndTabItem();
            }
            UI::PopStyleColor(3);
        } else {
            debugPrint = false;
        }
        UI::EndTabBar();
    }
    UI::End();
}

