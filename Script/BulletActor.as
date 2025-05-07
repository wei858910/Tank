class ABulletActor : ACanDamageActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;

    UPROPERTY(DefaultComponent)
    UPaperSpriteComponent BulletRender;

    UPaperSprite BulletSprite = Cast<UPaperSprite>(LoadObject(nullptr, "/Game/Textures/tankBullet_Sprite.tankBullet_Sprite"));
    default BulletRender.SetSprite(BulletSprite);
    default BulletRender.SetCollisionProfileName(n"OverlapAll");
    default BulletRender.OnComponentBeginOverlap.AddUFunction(this, n"OnBulletBeginOverlap");

    protected float BulletSpeed = 0.;

    UFUNCTION()
    private void OnBulletBeginOverlap(UPrimitiveComponent OverlappedComponent, AActor OtherActor, UPrimitiveComponent OtherComp, int OtherBodyIndex, bool bFromSweep, const FHitResult&in SweepResult)
    {
        ACanDamageActor CanDamageActor = Cast<ACanDamageActor>(OtherActor);
        ATankPawn       TankPawn = Cast<ATankPawn>(OtherActor);
        if (IsValid(CanDamageActor))
        {
            if (CanDamageActor.CanDamagedByBullet(this, OtherComp))
            {
                PlayBulletEffect();
                IdleSelf();
            }
        }
        else if (IsValid(TankPawn))
        {
            if (TankPawn.CanDamagedByBullet(this, OtherComp))
            {
                PlayBulletEffect();
                IdleSelf();
            }
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

    // UFUNCTION(BlueprintOverride)
    // void Destroyed()
    // {
    //     ATankGameMode TankGameMode = Cast<ATankGameMode>(Gameplay::GetGameMode());
    //     if (IsValid(TankGameMode))
    //     {
    //         TankGameMode.GetSoundManager().PlayGameSound(SoundName::BulletCrackSound);
    //         TankGameMode.GetEffectMamager().PlayEffect(EffectName::BulletBoom, GetActorLocation());
    //     }
    // }

    void PlayBulletEffect()
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

    void IdleSelf()
    {
        BulletSpeed = 0.;
        SetActorLocation(FVector(0., 1000., 0.));
    }

    bool isIdled()
    {
        return BulletSpeed == 0.;
    }
};