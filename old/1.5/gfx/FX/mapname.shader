Includes = {
	"jomini/countrynames.fxh"
	"jomini/jomini_fog.fxh"
	"standardfuncsgfx.fxh"
	"fog_of_war.fxh"
}

VertexShader =
{
	MainCode MapNameVertexShader
	{
		Input = "VS_INPUT_MAPNAME"
		Output = "VS_OUTPUT_MAPNAME"
		Code
		[[
			PDX_MAIN
			{
				VS_OUTPUT_MAPNAME Out = MapNameVertexShader( Input, FlatMapHeight, FlatMapLerp );
				return Out;
			}
		]]
	}
}

PixelShader =
{
	TextureSampler FontAtlas
	{
		Ref = PdxTexture0
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
	}
	TextureSampler FogOfWarAlpha
	{
		Ref = JominiFogOfWar
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	
	MainCode MapNamePixelShader
	{
		Input = "VS_OUTPUT_MAPNAME"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				float Alpha = CalcAlphaDistanceField( FontAtlas, Input.TexCoord );
				float3 Color = float3( 0.0f, 0.0f, 0.0f );
				Color = ApplyFogOfWar( Color, Input.WorldSpacePos, FogOfWarAlpha );
				Color = ApplyDistanceFog( Color, Input.WorldSpacePos );

				return float4( Color, Alpha * 0.93 );
			}
		]]
	}
}


BlendState BlendState
{
	BlendEnable = yes
	SourceBlend = "src_alpha"
	DestBlend = "inv_src_alpha"
	WriteMask = "RED|GREEN|BLUE"
}

RasterizerState RasterizerState
{
	frontccw = yes
}

DepthStencilState DepthStencilState
{
	DepthEnable = no
	StencilEnable = yes
	FrontStencilFunc = not_equal
	StencilRef = 1
}


Effect mapname
{
	VertexShader = "MapNameVertexShader"
	PixelShader = "MapNamePixelShader"
}

