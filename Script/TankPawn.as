class ATankPawn : APawn
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;

    UPROPERTY(DefaultComponent)
    UPaperSpriteComponent TankRenderComp;

    UPaperSprite TankSprite = Cast<UPaperSprite>(LoadObject(nullptr, "/Game/Textures/tankAll_Sprite.tankAll_Sprite"));
    default TankRenderComp.SetSprite(TankSprite);

    protected float OrthoWidth = 1000.;

    UPROPERTY(DefaultComponent)
    UCameraComponent Camera;
    default Camera.SetProjectionMode(ECameraProjectionMode::Orthographic);
    default Camera.SetOrthoWidth(OrthoWidth);
    default Camera.SetRelativeRotation(FRotator(0., 90., 0.));
    default Camera.SetRelativeLocation(FVector(0., 100., 0.));

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
    }
};