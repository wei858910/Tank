namespace SoundName
{
    const FName BulletCrackSound = n"BulletBoomSound";
    const FName FireSound = n"FireSound";
    const FName MoveSound = n"MoveSound";
    const FName StartSound = n"StartSound";
    const FName EnemyCrack = n"EnemyCrack";
    const FName PowerupItemSound = n"PowerupItem";
} // namespace SoundName

namespace SoundPath
{
    const FString BulletCrackSoundPath = "/Game/Sound/bulletCrack.bulletCrack";
    const FString FireSoundPath = "/Game/Sound/attack.attack";
    const FString MoveSoundPath = "/Game/Sound/move.move";
    const FString StartSoundPath = "/Game/Sound/start.start";
    const FString EnemyCrackPath = "/Game/Sound/tankCrack.tankCrack";
    const FString PowerupItemSoundPath = "/Game/Sound/prop.prop";
} // namespace SoundPath

struct FSoundSource
{
    FString    SoundPath;
    USoundWave BindSoundWave = nullptr;
}

class USoundManager : UObject
{
    protected TMap<FName, FSoundSource> SoundSorceMap;

    void Init()
    {
        RegistSound(SoundName::StartSound, SoundPath::StartSoundPath);
        RegistSound(SoundName::FireSound, SoundPath::FireSoundPath);
        RegistSound(SoundName::BulletCrackSound, SoundPath::BulletCrackSoundPath);
        RegistSound(SoundName::MoveSound, SoundPath::MoveSoundPath);
        RegistSound(SoundName::EnemyCrack, SoundPath::EnemyCrackPath);
        RegistSound(SoundName::PowerupItemSound, SoundPath::PowerupItemSoundPath);
    }

    void RegistSound(FName NameOfSound, FString Path)
    {
        if (SoundSorceMap.Contains(NameOfSound))
        {
            return;
        }

        FSoundSource SoundSorce;
        SoundSorce.SoundPath = Path;
        SoundSorce.BindSoundWave = Cast<USoundWave>(LoadObject(nullptr, Path));

        SoundSorceMap.Add(NameOfSound, SoundSorce);
    }

    void PlayGameSound(FName NameOfSound)
    {
        if (!SoundSorceMap.Contains(NameOfSound))
        {
            return;
        }

        if (IsValid(SoundSorceMap[NameOfSound].BindSoundWave))
        {
            Gameplay::PlaySound2D(SoundSorceMap[NameOfSound].BindSoundWave);
        }
    }

    float GetSoundDuration(FName NameOfSound)
    {
        if (!SoundSorceMap.Contains(NameOfSound))
        {
            return 0.;
        }

        if (IsValid(SoundSorceMap[NameOfSound].BindSoundWave))
        {
            return SoundSorceMap[NameOfSound].BindSoundWave.Duration;
        }

        return 0.;
    }
};
