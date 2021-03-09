Includes = {
	"cw/pdxmesh.fxh"
}

PixelShader =
{
	TextureSampler DiffuseMap
	{
		Index = 0
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler SpecularMap
	{
		Index = 1
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	#TextureSampler NormalMap
	#{
	#	Index = 2
	#	MagFilter = "Linear"
	#	MinFilter = "Linear"
	#	MipFilter = "Linear"
	#	SampleModeU = "Wrap"
	#	SampleModeV = "Wrap"
	#}	
	TextureSampler FlagTexture
	{
		Ref = PdxMeshCustomTexture0
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
}

VertexStruct VS_OUTPUT
{
    float4 Position			: PDX_POSITION;
	float3 Normal			: TEXCOORD0;
	float3 Tangent			: TEXCOORD1;
	float3 Bitangent		: TEXCOORD2;
	float2 UV0				: TEXCOORD3;
	float2 UV1				: TEXCOORD4;
	float3 WorldSpacePos	: TEXCOORD5;
	uint InstanceIndex 	: TEXCOORD6;
};


VertexShader =
{
	Code
	[[
		VS_OUTPUT ConvertOutput( VS_OUTPUT_PDXMESH In )
		{
			VS_OUTPUT Out;
			
			Out.Position = In.Position;
			Out.Normal = In.Normal;
			Out.Tangent = In.Tangent;
			Out.Bitangent = In.Bitangent;
			Out.UV0 = In.UV0;
			Out.UV1 = In.UV1;
			Out.WorldSpacePos = In.WorldSpacePos;
			return Out;
		}
	]]
	
	MainCode VS_standard
	{
		Input = "VS_INPUT_PDXMESHSTANDARD"
		Output = "VS_OUTPUT"
		Code
		[[
			PDX_MAIN
			{
				VS_OUTPUT Out = ConvertOutput( PdxMeshVertexShaderStandard( Input ) );
				Out.InstanceIndex = Input.InstanceIndices.y;
				return Out;
			}
		]]
	}
}

PixelShader =
{	
	MainCode PS_standard
	{
		Input = "VS_OUTPUT"
		Output = "PDX_COLOR"
		Code
		[[		
			float4 GetUserColor( uint InstanceIndex )
			{
				// assuming that the mesh user data only contains a color
				return Data[ InstanceIndex + PDXMESH_USER_DATA_OFFSET ];
			}	
			PDX_MAIN
			{
				float4 Diffuse = PdxTex2D( DiffuseMap, Input.UV0 );
				float4 Properties = PdxTex2D( SpecularMap, Input.UV0 );
				
				#ifdef COLOR
					Diffuse.rgb = lerp( Diffuse.rgb, Diffuse.rgb * GetUserColor( Input.InstanceIndex ).rgb, Properties.r );
				#endif
				#ifdef FLAG
					Diffuse.rgb *= PdxTex2D( FlagTexture, Input.UV1 ).rgb;
				#endif
				return Diffuse;
			}
		]]
	}
}


BlendState BlendState
{
	BlendEnable = yes
	SourceBlend = "SRC_ALPHA"
	DestBlend = "INV_SRC_ALPHA"
	SourceAlpha = "ONE"
	DestAlpha = "INV_SRC_ALPHA"
}

Effect gui_banner_flag
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "FLAG" }
}
Effect gui_banner_color
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "COLOR" }
}