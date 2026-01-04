

class dataTracker {
    uint64 StartTime = 0;
    uint64 TotalTime = 0;
    uint64 ActivityStartTime;
    Activity currentActivity = Activity::None;

    uint64 TimeWaitingForEditor = 0;
    uint64 TimeFrameYielding = 0;
    uint64 TimeWaitingForUserInput = 0;

    uint64 TimeStartup = 0;
    uint64 TimeProcessing = 0;
    uint64 TimePlacingBlock = 0;
    uint64 TimeUndoing = 0;
    uint64 TimeRandomSelecting = 0;
    uint64 TimeRefreshing = 0;


    dataTracker(){
    }

    // check if the current frame time is long enough that it should yield
    void CheckYield() {
        if (Time::get_Now() - GlobalFrameStartTime > 20) {
            Yield(YieldReason::FrameTime);
        }
    }

    // add the activity time to the current activity, and reset activity time
    private void ResolveCurrentActivity() {
        uint64 duration = Time::get_Now() - this.ActivityStartTime;
        switch(this.currentActivity) {
            case Activity::None: break;
            case Activity::Startup:
                this.TimeStartup += duration;
                break;
            case Activity::Processing:
                this.TimeProcessing += duration;
                break;
            case Activity::PlacingBlock:
                this.TimePlacingBlock += duration;
                break;
            case Activity::Undoing:
                this.TimeUndoing += duration;
                break;
            case Activity::RandomlySelecting:
                this.TimeRandomSelecting += duration;
                break;
            case Activity::Refreshing:
                this.TimeRefreshing += duration;
                break;
            default:
                throw('unknown current activity in duration tracking');
        }
        this.TotalTime = Time::get_Now() - StartTime;
        this.ActivityStartTime = Time::get_Now();
    }

    // yields (and makes sure the time spent yielding is added to the correct counter)
    void Yield(YieldReason reason) {
        ResolveCurrentActivity();
        // sets activitystarttime to now

        yield();
        uint64 duration = Time::get_Now() - this.ActivityStartTime;
        GlobalFrameStartTime = this.ActivityStartTime = Time::get_Now();

        switch(reason) {
            case YieldReason::FrameTime:
                this.TimeFrameYielding += duration;
                break;
            case YieldReason::EditorNotReady:
                this.TimeWaitingForEditor += duration;
                break;
            case YieldReason::DebugModes:
                this.TimeWaitingForUserInput += duration;
                break;
            default:
                throw('unknown yield reason in duration tracking');
        }
    }

    // switches the activity (and sets the time on the previous activity)
    void ChangeActivity(Activity newactivity) {
        if (newactivity == Activity::Startup) {
            this.StartTime = Time::get_Now();
        }
        ResolveCurrentActivity();
        this.currentActivity = newactivity;
    }
}

enum YieldReason {
    FrameTime,
    EditorNotReady,
    DebugModes
}
enum Activity {
    None,
    Startup,
    Processing,
    PlacingBlock,
    Undoing,
    RandomlySelecting,
    Refreshing

}