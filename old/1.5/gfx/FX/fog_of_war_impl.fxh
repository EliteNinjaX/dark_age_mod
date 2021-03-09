Includes = {
	#"cw/debug_constants.fxh"
}

ConstantBuffer( GameFogOfWar )
{
	float4 	FoWColor1;
	float4 	FoWColor2;
	float	FoWColorBlendMidpoint;
	float	FoWColorBlendWidth;
}

Code
[[
	#define FOG_OF_WAR_BLEND_FUNCTION CalcFogOfWarBlend
	float4 CalcFogOfWarBlend( float Alpha )
	{
		Alpha = saturate(Alpha);
		
		const float SCALE = 20.0f;
		float MinColorBlend = FoWColorBlendMidpoint - FoWColorBlendWidth;
		float MaxColorBlend =  FoWColorBlendMidpoint + FoWColorBlendWidth;
		float ColorBlend = smoothstep( saturate(MinColorBlend), saturate(MaxColorBlend), Alpha );
		
		float4 FoWColor = lerp( FoWColor1, FoWColor2, ColorBlend );
		
		return float4( FoWColor.rgb * SCALE, ( 1.0 - Alpha ) * FoWColor.a );
	}
]]