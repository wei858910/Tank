class AEnemyActor : ACanDamageActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    UPaperSpriteComponent TankRenderComp;

    protected float MoveSpeed;
    protected float CheckBarrierInterval = 0.3;
    protected float CheckBarrierTick = 0.;
    protected int32 HP = 5;

    protected float MinTime = 1.2;
    protected float MaxTime = 2.8;

    protected bool bPause = false;
    protected float PauseTime = 6.;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        System::SetTimer(this, n"DoFire", Math::RandRange(0.5, 1.5), false);

        System::SetTimer(this, n"TurnDirection", Math::RandRange(MinTime, MaxTime), false);
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        if (bPause)
        {
            return;
        }
        UpdateMove(DeltaSeconds);
    }

    protected void UpdateMove(float DeltaSeconds)
    {
        if (MoveSpeed == 0.)
        {
            return;
        }

        FHitResult HitResult;
        AddActorWorldOffset(GetActorForwardVector() * MoveSpeed * DeltaSeconds, true, HitResult, false);
        CheckBarrierTick -= DeltaSeconds;
        if (CheckBarrierTick < 0)
        {
            if (CheckForwardBarrier())
            {
                RandomDirection();
            }
            CheckBarrierTick = CheckBarrierInterval;
        }
    }

    UFUNCTION()
    void TurnDirection()
    {
        if (Math::RandRange(0., 1.) < 0.6)
        {
            RandomDirection();
        }
        System::SetTimer(this, n"TurnDirection", Math::RandRange(MinTime, MaxTime), false);
    }

    protected void RandomDirection()
    {
        float PitchValue = 0.;
        int32 RandRotateFlag = Math::RandRange(0, 3);
        PitchValue = RandRotateFlag * 90.;
        SetActorRotation(FRotator(PitchValue, 0., 0.));
    }

    protected bool CheckForwardBarrier()
    {
        FHitResult      HitResult;
        FVector         Start = GetActorLocation() + GetActorForwardVector() * 16.;
        FCollisionShape CollisionShape;
        CollisionShape.ShapeType = ECollisionShape::Box;
        CollisionShape.SetBox(FVector(1.5, 4., 12.));
        FCollisionQueryParams Params;
        Params.AddIgnoredActor(this);
        // System::DrawDebugBox(Start, FVector(1.5, 4., 12.), FLinearColor::Red, GetActorRotation(), 1.5);
        bool bHit = System::SweepSingleByChannel(HitResult, Start, Start, GetActorRotation().Quaternion(), ECollisionChannel::ECC_Camera, CollisionShape, Params);
        if (bHit)
        {
            Print(f"HitResult = {HitResult.Actor.Name}");
        }
        return bHit;
    }

    UFUNCTION()
    protected void DoFire()
    {
        ABulletActor Bullet = nullptr;

        System::SetTimer(this, n"DoFire", Math::RandRange(1.5, 3.), false);
        if (!IsValid(Bullet))
        {
            Bullet = Cast<ABulletActor>(SpawnActor(ABulletActor::StaticClass(), FVector(0., 1000., 0), FRotator::ZeroRotator));
        }

        if (IsValid(Bullet))
        {
            Bullet.SetBulletType(EBulletType::EBT_Enemy);
            Bullet.SetActorLocation(GetActorLocation() + GetActorForwardVector() * 18);
            Bullet.SetActorRotation(GetActorRotation());
            Bullet.DoFire();
        }
    }

    void SetTankData(UPaperSprite TankSprite, float Speed)
    {
        TankRenderComp.SetSprite(TankSprite);
        MoveSpeed = Speed;
    }

    void Hurt()
    {
        --HP;
        if (HP < 0)
        {
            DestroyActor();
        }
    }

    UFUNCTION(BlueprintOverride)
    void Destroyed()
    {
        ATankGameMode TankGameMode = Cast<ATankGameMode>(Gameplay::GetGameMode());
        if (IsValid(TankGameMode))
        {
            TankGameMode.GetSoundManager().PlayGameSound(SoundName::EnemyCrack);
            TankGameMode.GetEffectMamager().PlayEffect(EffectName::TankBoom, GetActorLocation());
        }
    }

    bool CanDamagedByBullet(ABulletActor BulletActor, UPrimitiveComponent HitComp) override
    {
        if (BulletActor.GetBulletType() == EBulletType::EBT_Player)
        {
            Hurt();
            return true;
        }

        return false;
    }

    void PauseSelf(bool bPaused)
    {
        bPause = bPaused;
        System::ClearTimer(this, "TurnDirection");
        System::ClearTimer(this, "DoFire");
        System::SetTimer(this, n"UnPauseSelf", PauseTime, false);
    }

    UFUNCTION()
    void UnPauseSelf()
    {
        bPause = false;
        System::SetTimer(this, n"DoFire", Math::RandRange(0.5, 1.5), false);

        System::SetTimer(this, n"TurnDirection", Math::RandRange(MinTime, MaxTime), false);
    }
};