Includes = {
	"jomini/jomini_gradient_borders.fxh"
}

PixelShader =
{
	Code
	[[
		float3 ApplyGradientBorderColor( in float3 BaseColor, inout float3 BorderColor, in float BlendAmount )
		{
			float Brightness = saturate( dot( BaseColor, float3( 0.2125, 0.7154, 0.0721 ) ) );
			float Mask = ( 1.0f - Brightness );
			
			BorderColor = RGBtoHSV( BorderColor );
			BorderColor.y *= 0.88f;
			BorderColor = HSVtoRGB( BorderColor );
			
			float3 Combined = lerp( BaseColor, BorderColor, Mask );
			float3 SoftLight = Combined + BaseColor * ( 1.0f - ((1.0f-BaseColor)*(1.0f-BorderColor)) - Combined );
			
			return lerp( BaseColor, SoftLight, BlendAmount );
		}

		void ApplyTerrainColor( inout float3 Diffuse, inout float3 FlatMap, inout float3 BorderColor, out float BorderPostLightingBlend, in float2 ColorMapCoords )
		{
			float BorderPreLightingBlend;
			GetBorderColorAndBlend( ColorMapCoords, BorderColor, BorderPreLightingBlend, BorderPostLightingBlend );
			Diffuse = ApplyGradientBorderColor( Diffuse, BorderColor, BorderPreLightingBlend );

			#ifdef TERRAIN_FLAT_MAP_LERP
				FlatMap = lerp( FlatMap, BorderColor, saturate( BorderPreLightingBlend + BorderPostLightingBlend ) );
			#endif
		}

		float4 FlatTerrainShader( in float3 WorldSpacePos, in float2 ColorMapCoords, in PdxTextureSampler2D FlatMapTex )
		{	
			float3 FlatMap = PdxTex2D( FlatMapTex, float2( ColorMapCoords.x, 1.0 - ColorMapCoords.y ) ).rgb;

			#ifdef TERRAIN_COLOR_OVERLAY
				float3 ColorOverlay;
				float PreLightingBlend;
				float PostLightingBlend;
				GetBorderColorAndBlend( ColorMapCoords, ColorOverlay, PreLightingBlend, PostLightingBlend );

				FlatMap = lerp( FlatMap, ColorOverlay, saturate( PreLightingBlend + PostLightingBlend ) );
			#endif
			
			float3 FinalColor = FlatMap;
			
			#ifdef TERRAIN_COLOR_OVERLAY
				float4 HighlightColor = BilinearColorSampleAtOffset( ColorMapCoords, IndirectionMapSize, InvIndirectionMapSize, ProvinceColorIndirectionTexture, ProvinceColorTexture, HighlightProvinceColorsOffset );
				FinalColor.rgb = lerp( FinalColor.rgb, HighlightColor.rgb, HighlightColor.a );
			#endif

			
			#ifdef TERRAIN_DEBUG
				TerrainDebug( FinalColor, WorldSpacePos );
			#endif
			
			//DebugReturn( FinalColor, lightingProperties, ShadowTerm );
			return float4( FinalColor, 1 );
		}
	]]
}
