Includes = {
	"cw/fullscreen_vertexshader.fxh"
	"dynamicflag.fxh"
}

PixelShader =
{
	TextureSampler Pattern
	{
		Ref = PdxTexture0
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler Symbol
	{
		Ref = PdxTexture1
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}

	MainCode PS_main
	{
		Input = "VS_OUTPUT_FULLSCREEN"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				float A = PdxTex2D( Pattern, Input.uv ).r;
				
				float3 PatternColor = lerp( Color1, Color2, A );
				
				float4 SymbolColor = PdxTex2D( Symbol, Input.uv );
				SymbolColor.rgb = Color3 * SymbolColor.r;
				
				float3 Result = lerp( PatternColor, SymbolColor.rgb, SymbolColor.a );
				
				return float4( Result.r, Result.g, Result.b, 1.0 );
			}
		]]
	}
}

BlendState BlendState
{
	BlendEnable = no
}

Effect create_dynamic_flag
{
	VertexShader = VertexShaderFullscreen
	PixelShader = PS_main
}
