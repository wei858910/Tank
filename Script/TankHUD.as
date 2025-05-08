class ATankHUD : AHUD
{
    protected float FadeOffsetY;
    protected float FadeSpeed = 50.;
    protected float FadeDirection = 1.;

    protected bool bDrawFade = false;

    UFUNCTION(BlueprintOverride)
    void DrawHUD(int SizeX, int SizeY)
    {
        if (bDrawFade)
        {
            DrawFade(SizeX, SizeY);
        }
    }

    protected void DrawFade(int SizeX, int SizeY)
    {
        Print(f"{FadeOffsetY}");

        int32 Height = SizeY;
        int32 Width = SizeX;

        FLinearColor Color(0.3f, 0.3f, 0.3f, 1);

        DrawRect(Color, 0.f, 0.f, Width, FadeOffsetY);
        DrawRect(Color, 0.f, Height - FadeOffsetY, Width, FadeOffsetY);

        FadeOffsetY += FadeSpeed * Gameplay::GetWorldDeltaSeconds() * FadeDirection;

        if (FadeOffsetY > (Height >> 1))
        {
            FadeDirection = -1.;
        }
    }

    void StartFade(FName LevelName)
    {
        bDrawFade = true;
    }
};