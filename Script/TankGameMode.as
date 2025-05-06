class ATankGameMode : AGameMode
{
    default DefaultPawnClass = ATankPawn::StaticClass();

    UPROPERTY()
    AMapManager MapManager;

    UPROPERTY()
    UEffectManager EffectManager;

    ATankPawn TankPawn;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        MapManager = Cast<AMapManager>(SpawnActor(AMapManager::StaticClass()));
    }

    AMapManager GetMapManager()
    {
        return MapManager;
    }

    UEffectManager GetEffectMamager()
    {
        if (!IsValid(EffectManager))
        {
            EffectManager = Cast<UEffectManager>(NewObject(this, UEffectManager::StaticClass()));
            EffectManager.Init();
        }
        return EffectManager;
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