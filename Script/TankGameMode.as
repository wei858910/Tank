class ATankGameMode : AGameMode
{
    default DefaultPawnClass = ATankPawn::StaticClass();

    UPROPERTY()
    AMapManager MapManager;

    UPROPERTY()
    UEffectManager EffectManager;

    protected USoundManager SoundManager;

    protected AEnemyManager EnemyManager;

    ATankPawn TankPawn;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        MapManager = Cast<AMapManager>(SpawnActor(AMapManager::StaticClass()));
        GetSoundManager().PlayGameSound(SoundName::StartSound);

        EnemyManager = Cast<AEnemyManager>(SpawnActor(AEnemyManager::StaticClass()));
        if (IsValid(EnemyManager))
        {
            EnemyManager.BeginMatch();
        }

        LoadMapData("map01");
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

    USoundManager GetSoundManager()
    {
        if (!IsValid(SoundManager))
        {
            SoundManager = Cast<USoundManager>(NewObject(this, USoundManager::StaticClass()));
            SoundManager.Init();
        }

        return SoundManager;
    }

    AEnemyManager GetEnemyManager()
    {
        return EnemyManager;
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

    UFUNCTION(Exec)
    void TestFollowEffect()
    {
        if (!IsValid(TankPawn))
        {
            TankPawn = Cast<ATankPawn>(Gameplay::GetPlayerPawn(0));
        }

        if (IsValid(TankPawn))
        {
            GetEffectMamager().PlayEffect(EffectName::Invincibility, TankPawn.TankRenderComp.GetWorldLocation(), TankPawn.TankRenderComp, 100);
        }
    }

    UFUNCTION(Exec)
    void SpawnPowerupItem(int32 Type)
    {
        EPowerupItemType ItemType = EPowerupItemType(Type);
        APowerupItem     PowerupItem = Cast<APowerupItem>(SpawnActor(APowerupItem::StaticClass()));
        if (IsValid(PowerupItem))
        {
            PowerupItem.SetItemType(ItemType);
        }
    }
};