class ABulletActor : AActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;

    UPROPERTY(DefaultComponent)
    UPaperSpriteComponent BulletRender;

    UPaperSprite BulletSprite = Cast<UPaperSprite>(LoadObject(nullptr, "/Game/Textures/tankBullet_Sprite.tankBullet_Sprite"));
    default BulletRender.SetSprite(BulletSprite);
    default BulletRender.SetCollisionProfileName(n"OverlapAll");
    default BulletRender.OnComponentBeginOverlap.AddUFunction(this, n"OnBulletBeginOverlap");

    protected float BulletSpeed = 130.;

    UFUNCTION()
    private void OnBulletBeginOverlap(UPrimitiveComponent OverlappedComponent, AActor OtherActor, UPrimitiveComponent OtherComp, int OtherBodyIndex, bool bFromSweep, const FHitResult&in SweepResult)
    {
        UWallSpriteComponent Wall = Cast<UWallSpriteComponent>(OtherComp);
        if (IsValid(Wall))
        {
            if (Wall.Hited())
            {
                DestroyActor();
            }
        }
    }

    void DoFire(float Speed = 130.)
    {
        BulletSpeed = Speed;
    }

    void UpdateBulletFly(float DeltaSeconds)
    {
        if (BulletSpeed == 0.)
        {
            return;
        }

        AddActorWorldOffset(GetActorForwardVector() * BulletSpeed * DeltaSeconds);
    }

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        UpdateBulletFly(DeltaSeconds);
    }
};