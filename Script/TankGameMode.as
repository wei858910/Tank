class ATankGameMode : AGameMode
{
    default DefaultPawnClass = ATankPawn::StaticClass();

    UPROPERTY()
    AMapManager MapManager;

    UPROPERTY()
    UEffectManager EffectManager;

    protected USoundManager SoundManager;

    ATankPawn TankPawn;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        MapManager = Cast<AMapManager>(SpawnActor(AMapManager::StaticClass()));
        GetSoundManager().PlayGameSound(SoundName::StartSound);

        // 测试代码 生成敌人坦克
        AEnemyActor EnemyTank = Cast<AEnemyActor>(SpawnActor(AEnemyActor::StaticClass(), FVector(0., 0., 190.), FRotator(-90, 0., 0.)));
        UPaperSprite TankSprite = Cast<UPaperSprite>(LoadObject(nullptr, "/Game/Textures/Enemy/tankEnemy_Sprite.tankEnemy_Sprite"));
        if(IsValid(EnemyTank))
        {
            EnemyTank.SetTankData(TankSprite, 50.);
        }
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

};