class AEffectActor : AActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;

    UPROPERTY(DefaultComponent)
    UPaperFlipbookComponent EffectRenderComp;
    default EffectRenderComp.SetRelativeLocation(FVector(0., 20., 0.));

    protected USceneComponent FollowTarget;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
    }

    void PlayEffect(FVector PlayPosition, UPaperFlipbook Effect, USceneComponent FollowedTarget = nullptr, float Duration = -1)
    {
        FollowTarget = FollowedTarget;

        SetActorLocation(PlayPosition);
        if (IsValid(Effect))
        {
            EffectRenderComp.SetFlipbook(Effect);
        }
        System::SetTimer(this, n"PlayEnd", Duration == -1 ? EffectRenderComp.GetFlipbookLength() : Duration, false);
    }

    UFUNCTION()
    private void PlayEnd()
    {
        IdleSelf();
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        UpdateFollowPosition();
    }

    protected void IdleSelf()
    {
        EffectRenderComp.SetFlipbook(nullptr);
        ATankGameMode TankGameMode = Cast<ATankGameMode>(Gameplay::GetGameMode());
        if (IsValid(TankGameMode))
        {
            TankGameMode.GetEffectMamager().AddEffectActorToIdleArray(this);
        }

        FollowTarget = nullptr;
    }

    void UpdateFollowPosition()
    {
        if (IsValid(FollowTarget))
        {
            SetActorLocation(FollowTarget.GetWorldLocation());
        }
    }
};