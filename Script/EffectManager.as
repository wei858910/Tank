namespace EffectName
{
    const FName BulletBoom = n"BulletBoom";
}

namespace EffectPath
{
    const FString BulletEffectPath = "/Game/Textures/Effect/tankBulletEffect.tankBulletEffect";
}

struct FEffectSource
{
    FString        EffectSourcePath;
    UPaperFlipbook BindPaperFlipbook;
}

class UEffectManager : UObject
{
    TMap<FName, FEffectSource> EffectSourceMap;

    void RegistEffect(FName NameOfEffect, FString Path)
    {
        FEffectSource EffectSource;
        EffectSource.EffectSourcePath = Path;
        EffectSourceMap.Add(NameOfEffect, EffectSource);
    }

    void PlayEffect(FName NameOfEffect, FVector PlayPosition)
    {
        if (!EffectSourceMap.Contains(NameOfEffect))
        {
            return;
        }

        AEffectActor EffectActor = Cast<AEffectActor>(SpawnActor(AEffectActor::StaticClass(), PlayPosition));
        if (IsValid(EffectActor))
        {
            EffectActor.PlayEffect(GetFlipBookSourceByName(NameOfEffect));
        }
    }

    void Init()
    {
        RegistEffect(EffectName::BulletBoom, EffectPath::BulletEffectPath);
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
};