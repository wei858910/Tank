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

    void PlayEffect(FVector Location, FString Path)
    {
        SetActorLocation(Location);

        UPaperFlipbook Effect = Cast<UPaperFlipbook>(LoadObject(nullptr, Path));
        if (IsValid(Effect))
        {
            EffectRenderComp.SetFlipbook(Effect);
        }
        System::SetTimer(this, n"PlayEnd", EffectRenderComp.GetFlipbookLength(), false);
    }

    UFUNCTION()
    private void PlayEnd()
    {
        DestroyActor();
    }
};