
// The end of one block and the start of the next block will have the same connector
enum Connections {
    None,
    Start,
    End,

    RoadTechFlat,
    RoadTechDiagLeft,
    RoadTechDiagRight,
    RoadTechSlopeDown,
    RoadTechSlopeUp,
    RoadTechTiltLeft, // these connections are kinda weird since they don't line up with blocks directly. 
    RoadTechTiltRight,
    RoadTechInvertedBlack, // top of looping. Will only connect to another looping
    RoadTechInvertedWhite,

    RoadDirtFlat,
    RoadDirtDiagLeft,
    RoadDirtDiagRight,
    RoadDirtSlopeDown,
    RoadDirtSlopeUp,
    RoadDirtTiltLeft,
    RoadDirtTiltRight,
    RoadDirtInvertedBlack,
    RoadDirtInvertedWhite,

    RoadBumpFlat,
    RoadBumpDiagLeft,
    RoadBumpDiagRight,
    RoadBumpSlopeDown,
    RoadBumpSlopeUp,
    RoadBumpTiltLeft,
    RoadBumpTiltRight,
    RoadBumpInvertedBlack,
    RoadBumpInvertedWhite,

    RoadIceFlat,
    RoadIceFlatWallLeft,
    RoadIceFlatWallRight,
    RoadIceDiagLeft,
    RoadIceDiagLeftWallLeft,
    RoadIceDiagLeftWallRight,
    RoadIceDiagRight,
    RoadIceDiagRightWallLeft,
    RoadIceDiagRightWallRight,
    RoadIceSlopeDown,
    RoadIceSlopeUp,
    RoadIceTiltLeft,
    RoadIceTiltRight,
    RoadIceInvertedBlack,
    RoadIceInvertedWhite,
    UnderwaterBobsledFlat,
    UnderwaterBobsledFlatWallLeft,
    UnderwaterBobsledFlatWallRight,

    RoadWaterFlat,
    TrackWallWaterFlat,
    TrackWallWaterReactorUp,

    SnowRoadFlat,
    SnowRoadSlopeDown,
    SnowRoadSlopeUp,
    SnowRoadTiltLeft,
    SnowRoadTiltRight,

    RallyCastleRoadFlat,
    RallyCastleRoadSlopeDown,
    RallyCastleRoadSlopeUp,
    RallyCastleRoadDiagLeft,
    RallyCastleRoadDiagRight,

    RallyRoadDirtHighFlat,
    RallyRoadDirtLowFlat,
    RallyRoadMudLowFlat,

    TrackWallFlat, // move down 1 when starting this
    TrackWallDiagLeft,
    TrackWallDiagRight,
    TrackWallSlopeDown,
    TrackWallSlopeUp,
    TrackWallTiltLeft,
    TrackWallTiltRight,


    Jump,
    JumpWhite,
    JumpBlack,
    
    PlatformTechFlat,
    PlatformTechToDecoWallLeft,
    PlatformTechToDecoWallRight,
    PlatformTechSlopeDown,
    PlatformTechSlopeUp,
    PlatformTechTiltLeft, // height is 'lower'
    PlatformTechTiltRight,
    PlatformTechSlopeBaseLeft,
    PlatformTechSlopeBaseRight,
    PlatformTechSlope2BaseLeft,
    PlatformTechSlope2BaseRight,
    PlatformTechSlopeStartLeft,
    PlatformTechSlopeStartRight,
    PlatformTechSlopeEndLeft,
    PlatformTechSlopeEndRight,
    PlatformTechLoopStartLeft,
    PlatformTechLoopStartRight,
    PlatformTechLoopStart1x2Left,
    PlatformTechLoopStart1x2Right,
    PlatformTechLoopStart1x1Left,
    PlatformTechLoopStart1x1Right,
    PlatformTechLoopOutStartLeft,
    PlatformTechLoopOutStartRight,
    PlatformTechSlope2UTop,
    PlatformTechSlope2UBottom,

    PlatformDirtFlat,
    PlatformDirtToDecoWallLeft,
    PlatformDirtToDecoWallRight,
    PlatformDirtSlopeDown,
    PlatformDirtSlopeUp,
    PlatformDirtTiltLeft,
    PlatformDirtTiltRight,
    PlatformDirtSlopeBaseLeft,
    PlatformDirtSlopeBaseRight,
    PlatformDirtSlope2BaseLeft,
    PlatformDirtSlope2BaseRight,
    PlatformDirtSlopeStartLeft,
    PlatformDirtSlopeStartRight,
    PlatformDirtSlopeEndLeft,
    PlatformDirtSlopeEndRight,
    PlatformDirtLoopStartLeft,
    PlatformDirtLoopStartRight,
    PlatformDirtLoopStart1x2Left,
    PlatformDirtLoopStart1x2Right,
    PlatformDirtLoopStart1x1Left,
    PlatformDirtLoopStart1x1Right,
    PlatformDirtLoopOutStartLeft,
    PlatformDirtLoopOutStartRight,
    PlatformDirtSlope2UTop,
    PlatformDirtSlope2UBottom,
    
    PlatformIceFlat,
    PlatformIceToDecoWallLeft,
    PlatformIceToDecoWallRight,
    PlatformIceSlopeDown,
    PlatformIceSlopeUp,
    PlatformIceTiltLeft,
    PlatformIceTiltRight,
    PlatformIceSlopeBaseLeft,
    PlatformIceSlopeBaseRight,
    PlatformIceSlope2BaseLeft,
    PlatformIceSlope2BaseRight,
    PlatformIceSlopeStartLeft,
    PlatformIceSlopeStartRight,
    PlatformIceSlopeEndLeft,
    PlatformIceSlopeEndRight,
    PlatformIceLoopStartLeft,
    PlatformIceLoopStartRight,
    PlatformIceLoopStart1x2Left,
    PlatformIceLoopStart1x2Right,
    PlatformIceLoopStart1x1Left,
    PlatformIceLoopStart1x1Right,
    PlatformIceLoopOutStartLeft,
    PlatformIceLoopOutStartRight,
    PlatformIceSlope2UTop,
    PlatformIceSlope2UBottom,
    
    PlatformGrassFlat,
    PlatformGrassToDecoWallLeft,
    PlatformGrassToDecoWallRight,
    PlatformGrassSlopeDown,
    PlatformGrassSlopeUp,
    PlatformGrassTiltLeft,
    PlatformGrassTiltRight,
    PlatformGrassSlopeBaseLeft,
    PlatformGrassSlopeBaseRight,
    PlatformGrassSlope2BaseLeft,
    PlatformGrassSlope2BaseRight,
    PlatformGrassSlopeStartLeft,
    PlatformGrassSlopeStartRight,
    PlatformGrassSlopeEndLeft,
    PlatformGrassSlopeEndRight,
    PlatformGrassLoopStartLeft,
    PlatformGrassLoopStartRight,
    PlatformGrassLoopStart1x2Left,
    PlatformGrassLoopStart1x2Right,
    PlatformGrassLoopStart1x1Left,
    PlatformGrassLoopStart1x1Right,
    PlatformGrassLoopOutStartLeft,
    PlatformGrassLoopOutStartRight,
    PlatformGrassSlope2UTop,
    PlatformGrassSlope2UBottom,
    
    PlatformPlasticFlat,
    PlatformPlasticToDecoWallLeft,
    PlatformPlasticToDecoWallRight,
    PlatformPlasticSlopeDown,
    PlatformPlasticSlopeUp,
    PlatformPlasticTiltLeft,
    PlatformPlasticTiltRight,
    PlatformPlasticSlopeBaseLeft,
    PlatformPlasticSlopeBaseRight,
    PlatformPlasticSlope2BaseLeft,
    PlatformPlasticSlope2BaseRight,
    PlatformPlasticSlopeStartLeft,
    PlatformPlasticSlopeStartRight,
    PlatformPlasticSlopeEndLeft,
    PlatformPlasticSlopeEndRight,
    PlatformPlasticLoopStartLeft,
    PlatformPlasticLoopStartRight,
    PlatformPlasticLoopStart1x2Left,
    PlatformPlasticLoopStart1x2Right,
    PlatformPlasticLoopStart1x1Left,
    PlatformPlasticLoopStart1x1Right,
    PlatformPlasticLoopOutStartLeft,
    PlatformPlasticLoopOutStartRight,
    PlatformPlasticSlope2UTop,
    PlatformPlasticSlope2UBottom,
    
    PlatformWaterFlat,

    DecoWallFlat,
    DecoWallSlopeDown,
    DecoWallSlopeUp,
    DecoWallTiltLeft,
    DecoWallTiltRight,
    DecoWallSlopeBaseLeft,
    DecoWallSlopeBaseRight,
    DecoWallSlope2BaseLeft,
    DecoWallSlope2BaseRight,
    DecoWallSlopeStartLeft,
    DecoWallSlopeStartRight,
    DecoWallSlopeEndLeft,
    DecoWallSlopeEndRight,
    DecoWallLoopStartLeft,
    DecoWallLoopStartRight,
    DecoWallLoopStart1x2Left,
    DecoWallLoopStart1x2Right,
    DecoWallLoopStart1x1Left,
    DecoWallLoopStart1x1Right,
    DecoWallLoopOutStartLeft,
    DecoWallLoopOutStartRight,
    DecoWallSlope2UTop,
    DecoWallSlope2UBottom,
    // different materials of decowall? For now, not including them

    DecoWallWaterFlat,
    DecoWallWaterToPlatformLeft, // add these at some point
    DecoWallWaterToPlatformRight,
    DecoWallWaterSlopeLeft,
    DecoWallWaterSlopeRight,
    DecoWallWaterSlopeDeepLeft,
    DecoWallWaterSlopeDeepRight,
    DecoWallWaterReactorUp,
    DecoWallWaterSink,

    // used for jumping off stands
    PlatformTechTiltLeftToOpen,
    PlatformTechTiltRightToOpen,
    PlatformDirtTiltLeftToOpen,
    PlatformDirtTiltRightToOpen,
    PlatformIceTiltLeftToOpen,
    PlatformIceTiltRightToOpen,
    PlatformGrassTiltLeftToOpen,
    PlatformGrassTiltRightToOpen,


    OpenTechFlat,
    OpenTechSlopeDown,
    OpenTechSlopeUp,
    OpenTechTiltLeft,
    OpenTechTiltRight,
    OpenTechZoneLeftFlat,
    OpenTechZoneRightFlat,
    OpenTechZoneLeftSlopeDown,
    OpenTechZoneRightSlopeDown,
    OpenTechZoneLeftSlopeUp,
    OpenTechZoneRightSlopeUp,
    OpenTechZoneLeftTiltLeft,
    OpenTechZoneRightTiltLeft,
    OpenTechZoneLeftTiltRight,
    OpenTechZoneRightTiltRight,
    OpenTechHillShortLeft,
    OpenTechHillShortRight,

    OpenDirtFlat,
    OpenDirtSlopeDown,
    OpenDirtSlopeUp,
    OpenDirtTiltLeft,
    OpenDirtTiltRight,
    OpenDirtZoneLeftFlat,
    OpenDirtZoneRightFlat,
    OpenDirtZoneLeftSlopeDown,
    OpenDirtZoneRightSlopeDown,
    OpenDirtZoneLeftSlopeUp,
    OpenDirtZoneRightSlopeUp,
    OpenDirtZoneLeftTiltLeft,
    OpenDirtZoneRightTiltLeft,
    OpenDirtZoneLeftTiltRight,
    OpenDirtZoneRightTiltRight,
    OpenDirtHillShortLeft,
    OpenDirtHillShortRight,

    OpenDirtFlatGrass,
    OpenDirtSlopeDownGrass,
    OpenDirtSlopeUpGrass,

    OpenIceFlat,
    OpenIceSlopeDown,
    OpenIceSlopeUp,
    OpenIceTiltLeft,
    OpenIceTiltRight,
    OpenIceZoneLeftFlat,
    OpenIceZoneRightFlat,
    OpenIceZoneLeftSlopeDown,
    OpenIceZoneRightSlopeDown,
    OpenIceZoneLeftSlopeUp,
    OpenIceZoneRightSlopeUp,
    OpenIceZoneLeftTiltLeft,
    OpenIceZoneRightTiltLeft,
    OpenIceZoneLeftTiltRight,
    OpenIceZoneRightTiltRight,
    OpenIceHillShortLeft,
    OpenIceHillShortRight,

    OpenGrassFlat,
    OpenGrassSlopeDown,
    OpenGrassSlopeUp,
    OpenGrassTiltLeft,
    OpenGrassTiltRight,
    OpenGrassZoneLeftFlat,
    OpenGrassZoneRightFlat,
    OpenGrassZoneLeftSlopeDown,
    OpenGrassZoneRightSlopeDown,
    OpenGrassZoneLeftSlopeUp,
    OpenGrassZoneRightSlopeUp,
    OpenGrassZoneLeftTiltLeft,
    OpenGrassZoneRightTiltLeft,
    OpenGrassZoneLeftTiltRight,
    OpenGrassZoneRightTiltRight,
    OpenGrassHillShortLeft,
    OpenGrassHillShortRight,

    WaterGrassFlat,
    WaterGrassZoneLeftFlat,
    WaterGrassZoneRightFlat,
    WaterDirtFlat,
    WaterDirtZoneLeftFlat,
    WaterDirtZoneRightFlat,
    WaterIceFlat,
    WaterIceZoneLeftFlat,
    WaterIceZoneRightFlat,

    DecoPlatformFlat,
    DecoPlatformToDecoWallLeft,
    DecoPlatformToDecoWallRight,
    DecoPlatformSlopeDown,
    DecoPlatformSlopeUp,
    DecoPlatformTiltLeft,
    DecoPlatformTiltRight,
    DecoPlatformSlopeBaseLeft,
    DecoPlatformSlopeBaseRight,
    DecoPlatformSlope2BaseLeft,
    DecoPlatformSlope2BaseRight,
    DecoPlatformSlopeStartLeft,
    DecoPlatformSlopeStartRight,
    DecoPlatformSlopeEndLeft,
    DecoPlatformSlopeEndRight,
    DecoPlatformLoopStartLeft,
    DecoPlatformLoopStartRight,
    DecoPlatformLoopStart1x2Left,
    DecoPlatformLoopStart1x2Right,
    DecoPlatformLoopStart1x1Left,
    DecoPlatformLoopStart1x1Right,
    DecoPlatformLoopOutStartLeft,
    DecoPlatformLoopOutStartRight,
    DecoPlatformHillSlopeLeft,
    DecoPlatformHillSlopeRight,
    DecoPlatformSlope2UTop,
    DecoPlatformSlope2UBottom,

    DecoPlatformDirtFlat,
    DecoPlatformDirtToDecoWallLeft,
    DecoPlatformDirtToDecoWallRight,
    DecoPlatformDirtSlopeDown,
    DecoPlatformDirtSlopeUp,
    DecoPlatformDirtTiltLeft,
    DecoPlatformDirtTiltRight,
    DecoPlatformDirtSlopeBaseLeft,
    DecoPlatformDirtSlopeBaseRight,
    DecoPlatformDirtSlope2BaseLeft,
    DecoPlatformDirtSlope2BaseRight,
    DecoPlatformDirtSlopeStartLeft,
    DecoPlatformDirtSlopeStartRight,
    DecoPlatformDirtSlopeEndLeft,
    DecoPlatformDirtSlopeEndRight,
    DecoPlatformDirtLoopStartLeft,
    DecoPlatformDirtLoopStartRight,
    DecoPlatformDirtLoopStart1x2Left,
    DecoPlatformDirtLoopStart1x2Right,
    DecoPlatformDirtLoopStart1x1Left,
    DecoPlatformDirtLoopStart1x1Right,
    DecoPlatformDirtLoopOutStartLeft,
    DecoPlatformDirtLoopOutStartRight,
    DecoPlatformDirtHillSlopeLeft,
    DecoPlatformDirtHillSlopeRight,
    DecoPlatformDirtSlope2UTop,
    DecoPlatformDirtSlope2UBottom,

    DecoPlatformIceFlat,
    DecoPlatformIceToDecoWallLeft,
    DecoPlatformIceToDecoWallRight,
    DecoPlatformIceSlopeDown,
    DecoPlatformIceSlopeUp,
    DecoPlatformIceTiltLeft,
    DecoPlatformIceTiltRight,
    DecoPlatformIceSlopeBaseLeft,
    DecoPlatformIceSlopeBaseRight,
    DecoPlatformIceSlope2BaseLeft,
    DecoPlatformIceSlope2BaseRight,
    DecoPlatformIceSlopeStartLeft,
    DecoPlatformIceSlopeStartRight,
    DecoPlatformIceSlopeEndLeft,
    DecoPlatformIceSlopeEndRight,
    DecoPlatformIceLoopStartLeft,
    DecoPlatformIceLoopStartRight,
    DecoPlatformIceLoopStart1x2Left,
    DecoPlatformIceLoopStart1x2Right,
    DecoPlatformIceLoopStart1x1Left,
    DecoPlatformIceLoopStart1x1Right,
    DecoPlatformIceLoopOutStartLeft,
    DecoPlatformIceLoopOutStartRight,
    DecoPlatformIceHillSlopeLeft,
    DecoPlatformIceHillSlopeRight,
    DecoPlatformIceSlope2UTop,
    DecoPlatformIceSlope2UBottom,

    RoadToOpenTech,
    OpenTechToRoad,
    RoadToOpenDirt,
    OpenDirtToRoad,
    RoadToOpenIce,
    OpenIceToRoad,
    RoadToOpenGrass,
    OpenGrassToRoad,
    RoadToRallyRoadDirt,

    Structure,

    StandLeft, // driving over spectators
    StandRight,
    StagePlatform,
    StageLeft,
    StageRight,
    StageSupportPlatform,
    StageSupportLeft,
    StageSupportRight,
    StageInsideLeft,
    StageInsideRight,

    DropAny, // general 'dropping down onto something'
    PlatformAnyFlat, // changing platform material (unused currently)
    PlatformAnySlopeDown,
    PlatformAnySlopeUp,
    PlatformAnyTiltLeft,
    PlatformAnyTiltRight,

// if adding new things to end, change list iterating in main
}

array<Connections> diagLeft = {Connections::RoadTechDiagLeft, Connections::RoadDirtDiagLeft, Connections::RoadBumpDiagLeft, Connections::RoadIceDiagLeft, Connections::RoadIceDiagLeftWallRight, Connections::RoadIceDiagLeftWallLeft, Connections::RallyCastleRoadDiagLeft, Connections::TrackWallDiagLeft};
array<Connections> diagRight = {Connections::RoadTechDiagRight, Connections::RoadDirtDiagRight, Connections::RoadBumpDiagRight, Connections::RoadIceDiagRight, Connections::RoadIceDiagRightWallRight, Connections::RoadIceDiagRightWallLeft, Connections::RallyCastleRoadDiagRight, Connections::TrackWallDiagRight};
array<Connections> sideLeft = {Connections::StageLeft, Connections::StageSupportLeft, Connections::StageInsideLeft};
array<Connections> sideRight = {Connections::StageRight, Connections::StageSupportRight, Connections::StageInsideRight};

// Relative directions, for things that change depending on the orientation of a trackpiece
enum Directions {
    Forwards = 0,
    Left = 3,
    Right = 1,
    Reverse = 2,
}

// calculates the new absolute direction after being changed by a relative direction
CGameEditorPluginMap::ECardinalDirections AddDirections(CGameEditorPluginMap::ECardinalDirections a, Directions b) {
    switch (b) {
        case Directions::Forwards:
            return a;
        case Directions::Right:
            switch(a) {
            case CGameEditorPluginMap::ECardinalDirections::North:
                return CGameEditorPluginMap::ECardinalDirections::East;
            case CGameEditorPluginMap::ECardinalDirections::East:
                return CGameEditorPluginMap::ECardinalDirections::South;
            case CGameEditorPluginMap::ECardinalDirections::South:
                return CGameEditorPluginMap::ECardinalDirections::West;
            default:
                return CGameEditorPluginMap::ECardinalDirections::North;
            }
        case Directions::Left:
            switch(a) {
            case CGameEditorPluginMap::ECardinalDirections::North:
                return CGameEditorPluginMap::ECardinalDirections::West;
            case CGameEditorPluginMap::ECardinalDirections::East:
                return CGameEditorPluginMap::ECardinalDirections::North;
            case CGameEditorPluginMap::ECardinalDirections::South:
                return CGameEditorPluginMap::ECardinalDirections::East;
            default:
                return CGameEditorPluginMap::ECardinalDirections::South;
            }
        case Directions::Reverse:
            switch(a) {
            case CGameEditorPluginMap::ECardinalDirections::North:
                return CGameEditorPluginMap::ECardinalDirections::South;
            case CGameEditorPluginMap::ECardinalDirections::East:
                return CGameEditorPluginMap::ECardinalDirections::West;
            case CGameEditorPluginMap::ECardinalDirections::South:
                return CGameEditorPluginMap::ECardinalDirections::North;
            default:
                return CGameEditorPluginMap::ECardinalDirections::East;
            }
    }
    throw('All directions used');// this should never happen, but needed for compiling
    return CGameEditorPluginMap::ECardinalDirections::North;
}

// rotates a (relative) position to an absolute direction
// used for e.g. track section's end-location-from-start
int3 RotatePosition(int3 position, CGameEditorPluginMap::ECardinalDirections direction) {
    switch(direction) {
        case CGameEditorPluginMap::ECardinalDirections::North:
            return position;
        case CGameEditorPluginMap::ECardinalDirections::East:
            return int3(-position.z, position.y, position.x);
        case CGameEditorPluginMap::ECardinalDirections::South:
            return int3(-position.x, position.y, -position.z);
        default:
            return int3(position.z, position.y, -position.x);
    }

}

// properties a block can have. Used for calculating weights
enum Tags {
    //road
    RoadTech, 
    RoadDirt,
    RoadBump,
    RoadIce,
    UnderwaterBobsled,
    RoadWater,
    SnowRoad,
    RallyCastleRoad,
    RallyRoadDirtHigh,
    RallyRoadDirtLow,
    RallyRoadDirt, // average
    RallyRoadMudLow,
    TrackWall,
    TrackWallWater,
    PlatformTech,
    PlatformDirt,
    PlatformIce,
    PlatformGrass,
    PlatformPlastic,
    PlatformWater,
    DecoWall,
    DecoWallWater,
    // platform-path
    OpenTech, 
    OpenDirt,
    OpenIce,
    OpenGrass,
    WaterGrass,
    WaterDirt,
    WaterIce,
    PenaltyGrass,
    PenaltySand,
    PenaltySnow,
    Structure,
    Stand,// driving over spectators
    Stage,
    StagePlatform,
    StageSupport,
    StageSupportPlatform,
    StageInside,

    Corner,
    Flat,
    Slope,
    Tilt,
    Diagonal,
    Loop,
    TiltCurved, // sides of platform base and slope start/end/u
    SlightTilt,

    // extra unused exits
    Junction,
    ChangeMaterial,
    NoDuplicate, // 2 blocks with this tag can't be put after each other
    ChangeBorder,
    ChangeSlope,
    ChangeTilt,
    // change slope and change tilt but as one
    ChangeAngle,
    SideConnectionOpen, // open platform side connections
    SideConnectionPlatform, // side connections on 4-way platforms
    SideConnectionT, // side connections on 3-way platforms

    Start,
    Checkpoint,
    Multilap,
    Finish,
    FakeFinish,
    Hole,
    PenaltyRoad,
    Ramp,
    AntiRamp,
    Bump,
    Narrow,
    IceWall,
    IceWallChange,
    Poles,
    PlatformUnsmooth,
    JumpStart,
    DropJumpStart,
    JumpContinue,

    Turbo,
    AntiTurbo,
    SuperTurbo,
    AntiSuperTurbo,
    RandomTurbo,
    AntiRandomTurbo,
    BoostUp,
    BoostDown,
    Boost2Up,
    Boost2Down,
    Cruise,
    NoBrake,
    NoEngine,
    NoSteering,
    SlowMotion,
    Fragile,
    Reset,

    CarStadium,
    CarSnow,
    CarRally,
    CarDesert,

    PreviousNotEmpty,

    Quarter,
    Half,
    Double,
    HighChance,
}

enum Cars {
    CarStadium,
    CarSnow,
    CarRally,
    CarDesert,
}

bool int3Equals(int3 a, int3 b) {
    if (a.x == b.x && a.y == b.y && a.z == b.z) {
        return true;
    } return false;
}

/* Stores the data about a block placement. 
 * includes orientation, connectors, end position
 * ingame blocks can have multiple Blocks for them, such as a corner having left and right variants */
class Block {
    // string name that identifies block ingame
    string NameID;
    Connections startConnector;
    Connections endConnector;
    // the position of the end of the block section, relative to the start
    int3 endPosition; // size-1 block is (0,0,1), corner2 is (+-1,0,2))
    // end direction relative to start
    Directions Direction;
    // tags applicable to this block
    array<Tags> tags;
    // approximate length (integer rounded)
    uint _length;
    float lengthAccurate;
    // rotation of the actual block relative to the direction the generation starts from
    Directions RotationOffset;
    /* the position the block will be placed relative to the connection start point.
    different version for every rotation */
    array<int3> PositionOffset(4);

    Block(const string &in NameID, Connections startConnector, Connections endConnector, int3 endPosition, Directions Direction,
    array<Tags> tags, uint length, Directions RotationOffset = Directions::Forwards, array<int3> PositionOffset = {int3(0,0,1),int3(-1,0,0),int3(0,0,-1),int3(1,0,0)}) {
        this.NameID = NameID;
        this.startConnector = startConnector;
        this.endConnector = endConnector;
        this.endPosition = endPosition;
        this.Direction = Direction;
        this.tags = tags;
        this._length = length;
        this.lengthAccurate = getLengthAccurate();
        this.RotationOffset = RotationOffset;
        this.PositionOffset = PositionOffset;
        if (PositionOffset.Length != 4){
            throw('wrong positionoffset');
        }
    }
    Block(const string &in NameID, Connections startConnector, Connections endConnector, int3 endPosition, Directions Direction,
    array<Tags> tags, uint length, array<int3> PositionOffset) {
        this.NameID = NameID;
        this.startConnector = startConnector;
        this.endConnector = endConnector;
        this.endPosition = endPosition;
        this.Direction = Direction;
        this.tags = tags;
        this._length = length;
        this.lengthAccurate = getLengthAccurate();
        this.RotationOffset = Directions::Forwards;
        this.PositionOffset = PositionOffset;
        if (PositionOffset.Length != 4){
            throw('wrong positionoffset');
        }
    }
    float getLengthAccurate() {
        vec3 actualend;
        if (this.Direction == Directions::Left) {
            actualend = vec3(this.endPosition[0] + 0.5, (float(this.endPosition[1])*0.25), this.endPosition[2] - 0.5);
        } else if (this.Direction == Directions::Right) {
            actualend = vec3(this.endPosition[0] - 0.5, (float(this.endPosition[1])*0.25), this.endPosition[2] - 0.5);
        } else if (this.Direction == Directions::Reverse) {
            // actualend = vec3(this.endPosition[0], (float(this.endPosition[1])*0.25), this.endPosition[2] - 1);
            return float(this._length);
        } else  {
            actualend = vec3(this.endPosition[0], this.endPosition[1], this.endPosition[2]);
        }
        if (diagLeft.Find(this.startConnector) >= 0) {
            actualend -= vec3(0.5,0,0);
        } else if (diagRight.Find(this.startConnector) >= 0) {
            actualend += vec3(0.5,0,0);
        }
        if (diagLeft.Find(this.endConnector) >= 0) {
            if (this.Direction == Directions::Forwards) {
                actualend += vec3(0.5,0,0);
            } else if (this.Direction == Directions::Reverse) {
                actualend -= vec3(0.5,0,0);
            } else if (this.Direction == Directions::Left) {
                actualend -= vec3(0,0,0.5);
            } else if (this.Direction == Directions::Right) {
                actualend += vec3(0,0,0.5);
            }
        } else if (diagRight.Find(this.endConnector) >= 0) {
            if (this.Direction == Directions::Forwards) {
                actualend -= vec3(0.5,0,0);
            } else if (this.Direction == Directions::Reverse) {
                actualend += vec3(0.5,0,0);
            } else if (this.Direction == Directions::Left) {
                actualend += vec3(0,0,0.5);
            } else if (this.Direction == Directions::Right) {
                actualend -= vec3(0,0,0.5);
            }
        }
        if (sideLeft.Find(this.startConnector) >= 0) {
            actualend -= vec3(0.4,0,0);
        } else if (sideRight.Find(this.startConnector) >= 0) {
            actualend += vec3(0.4,0,0);
        }
        if (sideLeft.Find(this.endConnector) >= 0) {
            if (this.Direction == Directions::Forwards) {
                actualend += vec3(0.4,0,0);
            } else if (this.Direction == Directions::Reverse) {
                actualend -= vec3(0.4,0,0);
            } else if (this.Direction == Directions::Left) {
                actualend -= vec3(0,0,0.4);
            } else if (this.Direction == Directions::Right) {
                actualend += vec3(0,0,0.4);
            }
        } else if (sideRight.Find(this.endConnector) >= 0) {
            if (this.Direction == Directions::Forwards) {
                actualend -= vec3(0.4,0,0);
            } else if (this.Direction == Directions::Reverse) {
                actualend += vec3(0.4,0,0);
            } else if (this.Direction == Directions::Left) {
                actualend += vec3(0,0,0.4);
            } else if (this.Direction == Directions::Right) {
                actualend -= vec3(0,0,0.4);
            }
        }
        if (actualend[0] == 0) {
            if (actualend[1] == 0) {
                return actualend[2];
            } else {
                float directlength = Math::Sqrt((actualend[1]*0.25) ** 2 + actualend[2] ** 2);
                return directlength;
            }
        } else {
            // (s,0,f) actually moves f+0.5 forwards ([2]) and |s|-0.5 sideways ([0])
            float directlength = Math::Sqrt(actualend[0] ** 2 + (actualend[1]*0.25) ** 2 + actualend[2] ** 2);
            if (this.Direction == Directions::Forwards) {
                return directlength;
            }
            if (Math::Abs(Math::Abs(actualend[0]) - Math::Abs(actualend[2])) < 0.1) {
                if (this.NameID.Contains('Diag') && (this.NameID.EndsWith('Curve1Out') || this.NameID.EndsWith('Curve2Out'))) {
                    // curves that are a 'straighter' line between start and end, so just use the direct length
                    return directlength;
                } else {
                    float curvedlength = 0.25f * Math::PI * (Math::Abs(actualend[0]) + Math::Abs(actualend[2]));
                    if (actualend[1] != 0) { // assume slope is linear and curve is curved
                        return Math::Sqrt((actualend[1]*0.25) ** 2 + curvedlength ** 2);
                    }
                    return curvedlength;
                }
            } else {
                if (this.NameID.Contains('ToRoadTech') || this.NameID.Contains('BranchCurve') || this.NameID.StartsWith('Stage') || this.NameID.StartsWith('Stand')) {
                    // treat as curve + straight
                    float min = Math::Min(Math::Abs(actualend[0]), Math::Abs(actualend[2]));
                    float max = Math::Max(Math::Abs(actualend[0]), Math::Abs(actualend[2]));
                    return (0.5f * Math::PI * min) + (max - min);
                } else if (this.NameID.StartsWith('StageDouble')) {
                    // the difference will be entering on left/right side; which are both very close to the middle anyway.
                    return 0.25f * Math::PI * (Math::Abs(actualend[0]) + Math::Abs(actualend[2]));
                } else if (this.NameID.Contains('Diag') || this.NameID == "RoadIceWithWallRightStartCurve1In"){
                    if (this.NameID.EndsWith('Curve1Out') || this.NameID.EndsWith('Curve2Out')) {
                        // curves that are a 'straighter' line between start and end, so just use the direct length
                        return directlength;
                    } else {
                        // using halfway between curve+straight and diag for most
                        float curvedlength = -2;
                        float min = Math::Min(Math::Abs(actualend[0]), Math::Abs(actualend[2]));
                        float max = Math::Max(Math::Abs(actualend[0]), Math::Abs(actualend[2]));
                        curvedlength = (0.5f * Math::PI * min) + (max - min);
                        if (this.NameID.EndsWith('SwitchCurve1In') || this.NameID.EndsWith('SwitchCurve2In')) {
                            curvedlength += 0.5;
                        } else {
                            curvedlength = 0.5 * (curvedlength + directlength);
                        }
                        return curvedlength;
                    }
                } else {
                    trace('unsmooth curve: ' + this.NameID + " " + actualend[0] + " " + actualend[2]);
                    return this._length;
                }
            }
        }
    }
    void printLengthAccuracy() {
        vec3 actualend;
        if (this.Direction == Directions::Left) {
            actualend = vec3(this.endPosition[0] + 0.5, (float(this.endPosition[1])*0.25), this.endPosition[2] - 0.5);
        } else if (this.Direction == Directions::Right) {
            actualend = vec3(this.endPosition[0] - 0.5, (float(this.endPosition[1])*0.25), this.endPosition[2] - 0.5);
        } else if (this.Direction == Directions::Reverse) {
            // actualend = vec3(this.endPosition[0], (float(this.endPosition[1])*0.25), this.endPosition[2] - 1);
            return;
        } else  {
            actualend = vec3(this.endPosition[0], this.endPosition[1], this.endPosition[2]);
        }
        if (diagLeft.Find(this.startConnector) >= 0) {
            actualend -= vec3(0.5,0,0);
        } else if (diagRight.Find(this.startConnector) >= 0) {
            actualend += vec3(0.5,0,0);
        }
        if (diagLeft.Find(this.endConnector) >= 0) {
            if (this.Direction == Directions::Forwards) {
                actualend += vec3(0.5,0,0);
            } else if (this.Direction == Directions::Reverse) {
                actualend -= vec3(0.5,0,0);
            } else if (this.Direction == Directions::Left) {
                actualend -= vec3(0,0,0.5);
            } else if (this.Direction == Directions::Right) {
                actualend += vec3(0,0,0.5);
            }
        } else if (diagRight.Find(this.endConnector) >= 0) {
            if (this.Direction == Directions::Forwards) {
                actualend -= vec3(0.5,0,0);
            } else if (this.Direction == Directions::Reverse) {
                actualend += vec3(0.5,0,0);
            } else if (this.Direction == Directions::Left) {
                actualend += vec3(0,0,0.5);
            } else if (this.Direction == Directions::Right) {
                actualend -= vec3(0,0,0.5);
            }
        }
        if (sideLeft.Find(this.startConnector) >= 0) {
            actualend -= vec3(0.4,0,0);
        } else if (sideRight.Find(this.startConnector) >= 0) {
            actualend += vec3(0.4,0,0);
        }
        if (sideLeft.Find(this.endConnector) >= 0) {
            if (this.Direction == Directions::Forwards) {
                actualend += vec3(0.4,0,0);
            } else if (this.Direction == Directions::Reverse) {
                actualend -= vec3(0.4,0,0);
            } else if (this.Direction == Directions::Left) {
                actualend -= vec3(0,0,0.4);
            } else if (this.Direction == Directions::Right) {
                actualend += vec3(0,0,0.4);
            }
        } else if (sideRight.Find(this.endConnector) >= 0) {
            if (this.Direction == Directions::Forwards) {
                actualend -= vec3(0.4,0,0);
            } else if (this.Direction == Directions::Reverse) {
                actualend += vec3(0.4,0,0);
            } else if (this.Direction == Directions::Left) {
                actualend += vec3(0,0,0.4);
            } else if (this.Direction == Directions::Right) {
                actualend -= vec3(0,0,0.4);
            }
        }
        if (actualend[0] == 0) {
            if (actualend[1] == 0) {
                if (actualend[2] == int(this._length)) {
                    return;
                } else {
                    print(this.NameID + " " + tostring(actualend) + " " + this._length);
                }
            } else {
                float directlength = Math::Sqrt((actualend[1]*0.25) ** 2 + actualend[2] ** 2);
                if (Math::Abs(float(this._length) - directlength) <= 0.5) {
                    return;
                } else {
                    print(this.NameID + " " + tostring(actualend) + " " + this._length + " " + directlength);
                }
            }
        } else {
            // (s,0,f) actually moves f+0.5 forwards ([2]) and |s|-0.5 sideways ([0])
            float directlength = Math::Sqrt(actualend[0] ** 2 + (actualend[1]*0.25) ** 2 + actualend[2] ** 2);
            if (this.Direction == Directions::Forwards && Math::Abs(float(this._length) - directlength) <= 0.5) {
                return;
            }
            float curvedlength = -2;
            if (Math::Abs(Math::Abs(actualend[0]) - Math::Abs(actualend[2])) < 0.1) {
                if (this.NameID.Contains('Diag') && (this.NameID.EndsWith('Curve1Out') || this.NameID.EndsWith('Curve2Out'))) {
                    // curves that are a 'straighter' line between start and end, so just use the direct length
                    curvedlength = directlength;
                } else {
                    curvedlength = 0.25f * Math::PI * (Math::Abs(actualend[0]) + Math::Abs(actualend[2]));
                    if (actualend[1] != 0) { // assume slope is linear and curve is curved
                        curvedlength = Math::Sqrt((actualend[1]*0.25) ** 2 + curvedlength ** 2);
                    }
                }
            } else {
                if (this.Direction != Directions::Forwards) {
                    if (this.NameID.Contains('ToRoadTech') || this.NameID.Contains('BranchCurve') || this.NameID.StartsWith('Stage') || this.NameID.StartsWith('Stand')) {
                        // treat as curve + straight
                        float min = Math::Min(Math::Abs(actualend[0]), Math::Abs(actualend[2]));
                        float max = Math::Max(Math::Abs(actualend[0]), Math::Abs(actualend[2]));
                        curvedlength = (0.5f * Math::PI * min) + (max - min);
                    } else if (this.NameID.StartsWith('StageDouble')) {
                        // the difference will be entering on left/right side; which are both very close to the middle anyway.
                        curvedlength = (0.25f * Math::PI * (Math::Abs(actualend[0]) + Math::Abs(actualend[2])));
                    } else if (this.NameID.Contains('Diag') || this.NameID == "RoadIceWithWallRightStartCurve1In"){
                        if (this.NameID.EndsWith('Curve1Out') || this.NameID.EndsWith('Curve2Out')) {
                            // curves that are a 'straighter' line between start and end, so just use the direct length
                            curvedlength = directlength;
                        } else {
                            // using halfway between curve+straight and diag for most
                            float min = Math::Min(Math::Abs(actualend[0]), Math::Abs(actualend[2]));
                            float max = Math::Max(Math::Abs(actualend[0]), Math::Abs(actualend[2]));
                            curvedlength = (0.5f * Math::PI * min) + (max - min);
                            if (this.NameID.EndsWith('SwitchCurve1In') || this.NameID.EndsWith('SwitchCurve2In')) {
                                curvedlength += 0.5;
                            } else {
                                curvedlength = 0.5 * (curvedlength + directlength);
                            }
                        }
                    } else {
                        trace('unsmooth curve: ' + this.NameID + " " + actualend[0] + " " + actualend[2]);
                        curvedlength = -1;
                    }
                } else {
                    curvedlength = -1;
                }
            }
            if (this.Direction != Directions::Forwards && Math::Abs(float(this._length) - curvedlength) <= 0.5) {
                return;
            }
            print(this.NameID + " " + tostring(this.endPosition) + " " + tostring(actualend) + " " + this._length + " " + tostring(this.Direction) + " " + directlength + " " + curvedlength + " " + tostring(this.startConnector) + " " + tostring(this.endConnector));


        }
    }
}
