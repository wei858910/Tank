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
        else if (IsValid(Cast<UBoxComponent>(OtherComp)))
        {
            DestroyActor();
        }
        else if (IsValid(Cast<ABulletActor>(OtherActor)))
        {
            DestroyActor();
        }
    }

    void DoFire(float Speed = 130.)
    {
        BulletSpeed = Speed;
        ATankGameMode TankGameMode = Cast<ATankGameMode>(Gameplay::GetGameMode());
        if (IsValid(TankGameMode))
        {
            TankGameMode.GetSoundManager().PlayGameSound(SoundName::FireSound);
        }
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
    void Destroyed()
    {
        ATankGameMode TankGameMode = Cast<ATankGameMode>(Gameplay::GetGameMode());
        if (IsValid(TankGameMode))
        {
            TankGameMode.GetSoundManager().PlayGameSound(SoundName::BulletCrackSound);
            TankGameMode.GetEffectMamager().PlayEffect(EffectName::BulletBoom, GetActorLocation());
        }
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