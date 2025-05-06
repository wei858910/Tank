namespace EffectName
{
    const FName BulletBoom = n"BulletBoom";
    const FName Invincibility = n"Invincibility";
} // namespace EffectName

namespace EffectPath
{
    const FString BulletEffectPath = "/Game/Textures/Effect/tankBulletEffect.tankBulletEffect";
    const FString InvincibilityPath = "/Game/Textures/Effect/tankInvincibilityEffect.tankInvincibilityEffect";
} // namespace EffectPath

struct FEffectSource
{
    FString        EffectSourcePath;
    UPaperFlipbook BindPaperFlipbook;
}

class UEffectManager : UObject
{
    TMap<FName, FEffectSource> EffectSourceMap;

    TArray<AEffectActor> IdleEffectActors;

    void RegistEffect(FName NameOfEffect, FString Path)
    {
        FEffectSource EffectSource;
        EffectSource.EffectSourcePath = Path;
        EffectSourceMap.Add(NameOfEffect, EffectSource);
    }

    void PlayEffect(FName NameOfEffect, FVector PlayPosition, USceneComponent FollowTarget = nullptr, float Duration = -1)
    {
        UPaperFlipbook PaperFlipbook = GetFlipBookSourceByName(NameOfEffect);
        if (!IsValid(PaperFlipbook))
        {
            return;
        }

        AEffectActor EffectActor = GetIdleEffectActor();
        if (IsValid(EffectActor))
        {
            EffectActor.PlayEffect(PlayPosition, PaperFlipbook, FollowTarget, Duration);
        }
    }

    void Init()
    {
        RegistEffect(EffectName::BulletBoom, EffectPath::BulletEffectPath);
        RegistEffect(EffectName::Invincibility, EffectPath::InvincibilityPath);
    }

    UPaperFlipbook GetFlipBookSourceByName(FName NameOfEffect)
    {
        if (!EffectSourceMap.Contains(NameOfEffect))
        {
            return nullptr;
        }

        if (IsValid(EffectSourceMap[NameOfEffect].BindPaperFlipbook))
        {
            return EffectSourceMap[NameOfEffect].BindPaperFlipbook;
        }

        EffectSourceMap[NameOfEffect].BindPaperFlipbook = Cast<UPaperFlipbook>(LoadObject(nullptr, EffectSourceMap[NameOfEffect].EffectSourcePath));
        return EffectSourceMap[NameOfEffect].BindPaperFlipbook;
    }

    AEffectActor GetIdleEffectActor()
    {
        AEffectActor Temp = nullptr;
        if (IdleEffectActors.Num() > 0)
        {
            Temp = IdleEffectActors[IdleEffectActors.Num() - 1];
            IdleEffectActors.RemoveAt(IdleEffectActors.Num() - 1);
            return Temp;
        }
        else
        {
            Temp = Cast<AEffectActor>(SpawnActor(AEffectActor::StaticClass()));
        }

        return Temp;
    }

    void AddEffectActorToIdleArray(AEffectActor EffectActor)
    {
        IdleEffectActors.AddUnique(EffectActor);
    }
};