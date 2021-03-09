Includes = {
	"cw/shadow.fxh"
	"jomini/jomini_lighting.fxh"
	"jomini/jomini_fog.fxh"
	"fog_of_war.fxh"
	"constants.fxh"
	"standardfuncsgfx.fxh"
	"jomini/jomini_road.fxh"
}


PixelShader =
{
	TextureSampler FogOfWarAlpha
	{
		Ref = JominiFogOfWar
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}	
	TextureSampler EnvironmentMap
	{
		Ref = JominiEnvironmentMap
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
		Type = "Cube"
	}
	TextureSampler ShadowTexture
	{
		Ref = PdxShadowmap
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
		CompareFunction = less_equal
		SamplerType = "Compare"
	}
	
	MainCode PixelShader
	{
		Input = "VS_OUTPUT"
		Output = "PDX_COLOR"
		Code
		[[	
			PDX_MAIN
			{	
				float4 Diffuse;
				float4 Material;
				float3 Normal;
				JominiRoadSampleTextures( Input, Diffuse, Material, Normal );
				
				SMaterialProperties MaterialProps = GetMaterialProperties( Diffuse.rgb, Normal, Material.a, Material.g, Material.b );
				SLightingProperties LightingProps = GetSunLightingProperties( Input.WorldSpacePos, ShadowTexture );
				
				float3 Color = CalculateSunLighting( MaterialProps, LightingProps, EnvironmentMap );
				
				Color = ApplyFogOfWar( Color, Input.WorldSpacePos, FogOfWarAlpha );
				Color = ApplyDistanceFog( Color, Input.WorldSpacePos );
				
				DebugReturn( Color, MaterialProps, LightingProps, EnvironmentMap );
				
				return float4( Color.rgb, Diffuse.a * GlobalOpacity );
			}
		]]
	}
}

Effect default
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
}
