class AEffectActor : AActor
{
    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent Root;

    UPROPERTY(DefaultComponent)
    UPaperFlipbookComponent EffectRenderComp;
    default EffectRenderComp.SetRelativeLocation(FVector(0., 20., 0.));

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
    }

    void PlayEffect(FVector PlayPosition, UPaperFlipbook Effect)
    {
        SetActorLocation(PlayPosition);
        if (IsValid(Effect))
        {
            EffectRenderComp.SetFlipbook(Effect);
        }
        System::SetTimer(this, n"PlayEnd", EffectRenderComp.GetFlipbookLength(), false);
    }

    UFUNCTION()
    private void PlayEnd()
    {
        IdleSelf();
    }

    protected void IdleSelf()
    {
        EffectRenderComp.SetFlipbook(nullptr);
        ATankGameMode TankGameMode = Cast<ATankGameMode>(Gameplay::GetGameMode());
        if (IsValid(TankGameMode))
        {
            TankGameMode.GetEffectMamager().AddEffectActorToIdleArray(this);
        }
    }
};