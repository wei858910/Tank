class AEnemyActor : AActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    UPaperSpriteComponent TankRenderComp;

    protected float MoveSpeed;
    protected float CheckBarrierInterval = 0.3;
    protected float CheckBarrierTick = 0.;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
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
        System::DrawDebugBox(Start, FVector(1.5, 4., 12.), FLinearColor::Red, GetActorRotation(), 1.5);
        bool bHit = System::SweepSingleByChannel(HitResult, Start, Start, GetActorRotation().Quaternion(), ECollisionChannel::ECC_Camera, CollisionShape, Params);
        if (bHit)
        {
            Print(f"HitResult = {HitResult.Actor.Name}");
        }
        return bHit;
    }

    void SetTankData(UPaperSprite TankSprite, float Speed)
    {
        TankRenderComp.SetSprite(TankSprite);
        MoveSpeed = Speed;
    }
};