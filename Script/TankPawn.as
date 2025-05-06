enum ETankMode
{
    ETM_Play,
    ETM_Edit
}

class ATankPawn : APawn
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;

    UPROPERTY(DefaultComponent)
    UPaperSpriteComponent TankRenderComp;

    UPaperSprite TankSprite = Cast<UPaperSprite>(LoadObject(nullptr, "/Game/Textures/tank_Sprite.tank_Sprite"));
    default TankRenderComp.SetSprite(TankSprite);

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

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        InputComp.BindAction(n"TurnWallType", EInputEvent::IE_Pressed, Delegate = FInputActionHandlerDynamicSignature(this, n"OnTurnWalltype"));
        InputComp.BindAction(n"Fire", EInputEvent::IE_Pressed, Delegate = FInputActionHandlerDynamicSignature(this, n"OnFire"));
        InputComp.BindAxis(n"MoveRight", Delegate = FInputAxisHandlerDynamicSignature(this, n"OnMoveRight"));
        InputComp.BindAxis(n"MoveUp", Delegate = FInputAxisHandlerDynamicSignature(this, n"OnMoveUp"));
    }

    UFUNCTION()
    private void OnTurnWalltype(FKey Key)
    {
        if (++CurrentSpawnWallType > uint8(EWallType::EWT_Ice))
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
        }
        else
        {
            // 编辑墙壁
            ATankGameMode TankGameMode = Cast<ATankGameMode>(Gameplay::GetGameMode());
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
            bMoveHorizontal = AxisValue != 0.f;
            if (AxisValue == 0.f || bMoveVetical)
            {
                return;
            }
            FHitResult HitResult;
            TankRenderComp.AddRelativeLocation(FVector::ForwardVector * MoveSpeed * Gameplay::GetWorldDeltaSeconds() * AxisValue, true, HitResult, true);
            TankRenderComp.SetRelativeRotation(FRotator(AxisValue > 0. ? 0. : 180., 0., 0.));
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
            bMoveVetical = AxisValue != 0.f;
            if (AxisValue == 0.f || bMoveHorizontal)
            {
                return;
            }
            FHitResult HitResult;
            TankRenderComp.AddRelativeLocation(FVector::UpVector * MoveSpeed * Gameplay::GetWorldDeltaSeconds() * AxisValue, true, HitResult, true);
            TankRenderComp.SetRelativeRotation(FRotator(AxisValue > 0. ? 90. : -90., 0., 0.));
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
            ATankGameMode TankGameMode = Cast<ATankGameMode>(Gameplay::GetGameMode());
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
};