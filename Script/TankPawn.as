enum ETankMode
{
    ETM_Play,
    ETM_Edit
}

enum EPlayerTankState
{
    EPTS_Spawn,
    EPTS_Super,
    EPTS_Normal,
    EPTS_Dead,
    EPTS_Double
}

class ATankPawn : APawn
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;

    UPROPERTY(DefaultComponent)
    UPaperSpriteComponent TankRenderComp;

    UPaperSprite TankSprite = Cast<UPaperSprite>(LoadObject(nullptr, "/Game/Textures/tank_Sprite.tank_Sprite"));
    default TankRenderComp.SetSprite(TankSprite);
    default TankRenderComp.SetHiddenInGame(true);

    protected float OrthoWidth = 500.;

    UPROPERTY(DefaultComponent)
    UCameraComponent Camera;
    default Camera.SetProjectionMode(ECameraProjectionMode::Orthographic);
    default Camera.SetOrthoWidth(OrthoWidth);
    default Camera.SetRelativeRotation(FRotator(0., -90., 0.));
    default Camera.SetRelativeLocation(FVector(0., 100., 0.));

    UPROPERTY(DefaultComponent)
    UInputComponent InputComp;

    protected float MoveSpeed = 100.;
    protected bool bMoveHorizontal = false;
    protected bool bMoveVetical = false;

    protected ETankMode CurrentPlayMode = ETankMode::ETM_Play;

    protected float UnitSize = 32.;

    protected float EditMovementTimeInterval = 0.2;
    protected float LastEditHorizontalMovementTime = 0.;
    protected float LastEditVerticalMovementTime = 0.;

    protected uint8 CurrentSpawnWallType = 0;

    protected float MoveSoundDuration = 0.;
    protected float LastPlaySoundTime = 0.;

    protected ATankGameMode TankGameMode;

    protected ABulletActor HoldBullet = nullptr;

    protected EPlayerTankState CurrentTankState = EPlayerTankState::EPTS_Normal;
    protected EPlayerTankState NeedChangeTankState = EPlayerTankState::EPTS_Normal;

    protected float SpawnTime = 2.5;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        InputComp.BindAction(n"TurnWallType", EInputEvent::IE_Pressed, Delegate = FInputActionHandlerDynamicSignature(this, n"OnTurnWalltype"));
        InputComp.BindAction(n"Fire", EInputEvent::IE_Pressed, Delegate = FInputActionHandlerDynamicSignature(this, n"OnFire"));
        InputComp.BindAxis(n"MoveRight", Delegate = FInputAxisHandlerDynamicSignature(this, n"OnMoveRight"));
        InputComp.BindAxis(n"MoveUp", Delegate = FInputAxisHandlerDynamicSignature(this, n"OnMoveUp"));

        TankGameMode = Cast<ATankGameMode>(Gameplay::GetGameMode());
        if (IsValid(TankGameMode))
        {
            MoveSoundDuration = TankGameMode.GetSoundManager().GetSoundDuration(SoundName::MoveSound);
        }

        ChangePlayerTankState(EPlayerTankState::EPTS_Spawn);
    }

    UFUNCTION()
    private void OnTurnWalltype(FKey Key)
    {
        ++CurrentSpawnWallType;
        if (CurrentSpawnWallType > uint8(EWallType::EWT_Ice))
        {
            CurrentSpawnWallType = 0;
        }
    }

    UFUNCTION()
    private void OnFire(FKey Key)
    {
        if (CurrentPlayMode == ETankMode::ETM_Play)
        {
            // 开炮

            if (!IsValid(HoldBullet))
            {
                HoldBullet = Cast<ABulletActor>(SpawnActor(ABulletActor::StaticClass(), FVector(0., 1000., 0), FRotator::ZeroRotator));
                if (IsValid(HoldBullet))
                {
                    HoldBullet.SetBulletType(EBulletType::EBT_Player);
                    HoldBullet.SetActorLocation(TankRenderComp.GetRelativeLocation() + TankRenderComp.GetForwardVector() * 17);
                    HoldBullet.SetActorRotation(TankRenderComp.GetRelativeRotation());
                    HoldBullet.DoFire();
                }
            }
        }
        else
        {
            // 编辑墙壁
            if (IsValid(TankGameMode))
            {
                AMapManager MapManager = TankGameMode.GetMapManager();
                if (IsValid(MapManager))
                {
                    MapManager.SpawnWallFromPlayer(TankRenderComp.GetWorldLocation(), EWallType(CurrentSpawnWallType));
                }
            }
        }
    }

    UFUNCTION()
    private void OnMoveRight(float32 AxisValue)
    {
        if (CurrentPlayMode == ETankMode::ETM_Play)
        {
            if (CanMove())
            {
                bMoveHorizontal = AxisValue != 0.f;
                if (AxisValue == 0.f || bMoveVetical)
                {
                    return;
                }

                if (Gameplay::GetTimeSeconds() - LastPlaySoundTime > MoveSoundDuration)
                {
                    if (IsValid(TankGameMode))
                    {
                        LastPlaySoundTime = Gameplay::GetTimeSeconds();

                        TankGameMode.GetSoundManager().PlayGameSound(SoundName::MoveSound);
                    }
                }

                FHitResult HitResult;
                TankRenderComp.AddRelativeLocation(FVector::ForwardVector * MoveSpeed * Gameplay::GetWorldDeltaSeconds() * AxisValue, true, HitResult, true);
                TankRenderComp.SetRelativeRotation(FRotator(AxisValue > 0. ? 0. : 180., 0., 0.));
            }
        }
        else
        {
            if (Gameplay::GetTimeSeconds() - LastEditHorizontalMovementTime > EditMovementTimeInterval)
            {
                TankRenderComp.AddRelativeLocation(FVector::ForwardVector * UnitSize * AxisValue);
                LastEditHorizontalMovementTime = Gameplay::GetTimeSeconds();
            }

            if (AxisValue == 0.)
            {
                LastEditHorizontalMovementTime = 0.;
            }
        }
    }

    UFUNCTION()
    private void OnMoveUp(float32 AxisValue)
    {
        if (CurrentPlayMode == ETankMode::ETM_Play)
        {
            if (CanMove())
            {
                bMoveVetical = AxisValue != 0.f;
                if (AxisValue == 0.f || bMoveHorizontal)
                {
                    return;
                }

                if (Gameplay::GetTimeSeconds() - LastPlaySoundTime > MoveSoundDuration)
                {
                    if (IsValid(TankGameMode))
                    {
                        LastPlaySoundTime = Gameplay::GetTimeSeconds();

                        TankGameMode.GetSoundManager().PlayGameSound(SoundName::MoveSound);
                    }
                }

                FHitResult HitResult;
                TankRenderComp.AddRelativeLocation(FVector::UpVector * MoveSpeed * Gameplay::GetWorldDeltaSeconds() * AxisValue, true, HitResult, true);
                TankRenderComp.SetRelativeRotation(FRotator(AxisValue > 0. ? 90. : -90., 0., 0.));
            }
        }
        else
        {
            if (Gameplay::GetTimeSeconds() - LastEditVerticalMovementTime > EditMovementTimeInterval)
            {
                TankRenderComp.AddRelativeLocation(FVector::UpVector * UnitSize * AxisValue);
                LastEditVerticalMovementTime = Gameplay::GetTimeSeconds();
            }
            if (AxisValue == 0.)
            {
                LastEditVerticalMovementTime = 0.;
            }
        }
    }

    void SetPlayMode(ETankMode Mode)
    {
        CurrentPlayMode = Mode;
        if (CurrentPlayMode == ETankMode::ETM_Edit)
        {
            if (IsValid(TankGameMode))
            {
                AMapManager MapManager = TankGameMode.GetMapManager();
                if (IsValid(MapManager))
                {
                    int32 GridX = 0;
                    int32 GridY = 0;
                    MapManager.GetMapGridCoordinate(TankRenderComp.GetWorldLocation(), GridX, GridY);
                    FVector AdjestTankPosition = MapManager.ComputeEditModeTankPosition(GridX, GridY);
                    TankRenderComp.SetRelativeLocation(AdjestTankPosition);
                }
            }
        }
    }

    bool CanDamagedByBullet(ABulletActor BulletActor, UPrimitiveComponent HitComp)
    {
        if (BulletActor.GetBulletType() == EBulletType::EBT_Enemy)
        {
            return true;
        }
        return false;
    }

    EPlayerTankState GetPlayerTankState()
    {
        return CurrentTankState;
    }

    UFUNCTION()
    void DelayChangePlayerTankStateCallback()
    {
        ChangePlayerTankState(NeedChangeTankState);
    }

    void ChangePlayerTankStateDelay(EPlayerTankState State, float Time)
    {
        NeedChangeTankState = State;
        System::ClearTimer(this, "DelayChangePlayerTankStateCallback");

        System::SetTimer(this, n"DelayChangePlayerTankStateCallback", Time, false);
    }

    void ChangePlayerTankState(EPlayerTankState State)
    {
        System::ClearTimer(this, "DelayChangePlayerTankStateCallback");

        switch (State)
        {
            case EPlayerTankState::EPTS_Spawn:
                if (IsValid(TankGameMode))
                {
                    TankGameMode.GetEffectMamager().PlayEffect(EffectName::TankSpawn, TankRenderComp.GetWorldLocation(), TankRenderComp, SpawnTime);
                    ChangePlayerTankStateDelay(EPlayerTankState::EPTS_Normal, SpawnTime);
                }
                break;
            case EPlayerTankState::EPTS_Super:
                break;
            case EPlayerTankState::EPTS_Normal:
                TankRenderComp.SetHiddenInGame(false);
                break;
            case EPlayerTankState::EPTS_Dead:
                break;
            case EPlayerTankState::EPTS_Double:
                break;
            default:
                break;
        }
        CurrentTankState = State;
    }

    protected bool CanMove()
    {
        return CurrentTankState != EPlayerTankState::EPTS_Spawn;
    }
};