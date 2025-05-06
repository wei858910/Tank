class ATankGameMode : AGameMode
{
    default DefaultPawnClass = ATankPawn::StaticClass();

    AMapManager MapManager;
    ATankPawn   TankPawn;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        MapManager = Cast<AMapManager>(SpawnActor(AMapManager::StaticClass()));
    }

    AMapManager GetMapManager()
    {
        return MapManager;
    }

    UFUNCTION(Exec)
    void ChangePlayGameMode(int32 Mode)
    {
        if (!IsValid(TankPawn))
        {
            TankPawn = Cast<ATankPawn>(Gameplay::GetPlayerPawn(0));
        }

        if (Mode == 0)
        {
            if (IsValid(TankPawn))
            {
                TankPawn.SetPlayMode(ETankMode::ETM_Play);
            }
        }
        else
        {
            if (IsValid(TankPawn))
            {
                TankPawn.SetPlayMode(ETankMode::ETM_Edit);
            }
        }
    }

    UFUNCTION(Exec)
    void SaveMapData(const FString& MapName)
    {
        if (IsValid(MapManager))
        {
            MapManager.SaveMapData(MapName);
        }
    }

    UFUNCTION(Exec)
    void LoadMapData(const FString& MapName)
    {
        if (IsValid(MapManager))
        {
            MapManager.LoadMapData(MapName);
        }
    }
};