class ATankPawn : APawn
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;

    UPROPERTY(DefaultComponent)
    UPaperSpriteComponent TankRenderComp;

    UPaperSprite TankSprite = Cast<UPaperSprite>(LoadObject(nullptr, "/Game/Textures/tankAll_Sprite.tankAll_Sprite"));
    default TankRenderComp.SetSprite(TankSprite);

    protected float OrthoWidth = 500.;

    UPROPERTY(DefaultComponent)
    UCameraComponent Camera;
    default Camera.SetProjectionMode(ECameraProjectionMode::Orthographic);
    default Camera.SetOrthoWidth(OrthoWidth);
    default Camera.SetRelativeRotation(FRotator(0., 90., 0.));
    default Camera.SetRelativeLocation(FVector(0., 100., 0.));

    UPROPERTY(DefaultComponent)
    UInputComponent InputComp;

    protected float MoveSpeed = 100.;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        InputComp.BindAction(n"Fire", EInputEvent::IE_Pressed, Delegate = FInputActionHandlerDynamicSignature(this, n"OnFire"));
        InputComp.BindAxis(n"MoveRight", Delegate = FInputAxisHandlerDynamicSignature(this, n"OnMoveRight"));
        InputComp.BindAxis(n"MoveUp", Delegate = FInputAxisHandlerDynamicSignature(this, n"OnMoveUp"));
    }

    UFUNCTION()
    private void OnFire(FKey Key)
    {
    }

    UFUNCTION()
    private void OnMoveRight(float32 AxisValue)
    {
        if (AxisValue == 0.f)
        {
            return;
        }
        TankRenderComp.AddRelativeLocation(FVector::ForwardVector * MoveSpeed * Gameplay::GetWorldDeltaSeconds() * AxisValue);
        TankRenderComp.SetRelativeRotation(FRotator(AxisValue > 0. ? 0. : 180., 0., 0.));
    }

    UFUNCTION()
    private void OnMoveUp(float32 AxisValue)
    {
        if (AxisValue == 0.f)
        {
            return;
        }
        TankRenderComp.AddRelativeLocation(FVector::UpVector * MoveSpeed * Gameplay::GetWorldDeltaSeconds() * AxisValue);
        TankRenderComp.SetRelativeRotation(FRotator(AxisValue > 0. ? 90. : -90., 0., 0.));
    }
};