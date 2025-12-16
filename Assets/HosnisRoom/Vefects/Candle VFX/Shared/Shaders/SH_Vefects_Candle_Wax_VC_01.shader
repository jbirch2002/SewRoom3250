// Made with Amplify Shader Editor v1.9.6.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Vefects/SH_Vefects_Candle_Wax_VC_01"
{
	Properties
	{
		_WaxColor("Wax Color", Color) = (1,1,1,0)
		_WaxSSSColor("Wax SSS Color", Color) = (0.2745098,0.2235294,0.1960784,0)
		_Specular("Specular", Float) = 0.3
		_SpecularVC("Specular VC", Float) = 0.3
		_Smoothness("Smoothness", Float) = 0.3
		_SmoothnessVC("Smoothness VC", Float) = 1
		_NormalTexture("Normal Texture", 2D) = "white" {}
		_NormalIntensity("Normal Intensity", Float) = 0.2
		_NormalUVS("Normal UV S", Vector) = (1,3,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#pragma target 3.0
		#pragma surface surf StandardSpecularCustom keepalpha addshadow fullforwardshadows exclude_path:deferred 
		struct Input
		{
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
		};

		struct SurfaceOutputStandardSpecularCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half3 Specular;
			half Smoothness;
			half Occlusion;
			half Alpha;
			half3 Transmission;
		};

		uniform sampler2D _NormalTexture;
		uniform float2 _NormalUVS;
		uniform float _NormalIntensity;
		uniform float4 _WaxColor;
		uniform float _SpecularVC;
		uniform float _Specular;
		uniform float _SmoothnessVC;
		uniform float _Smoothness;
		uniform float4 _WaxSSSColor;

		inline half4 LightingStandardSpecularCustom(SurfaceOutputStandardSpecularCustom s, half3 viewDir, UnityGI gi )
		{
			half3 transmission = max(0 , -dot(s.Normal, gi.light.dir)) * gi.light.color * s.Transmission;
			half4 d = half4(s.Albedo * transmission , 0);

			SurfaceOutputStandardSpecular r;
			r.Albedo = s.Albedo;
			r.Normal = s.Normal;
			r.Emission = s.Emission;
			r.Specular = s.Specular;
			r.Smoothness = s.Smoothness;
			r.Occlusion = s.Occlusion;
			r.Alpha = s.Alpha;
			return LightingStandardSpecular (r, viewDir, gi) + d;
		}

		inline void LightingStandardSpecularCustom_GI(SurfaceOutputStandardSpecularCustom s, UnityGIInput data, inout UnityGI gi )
		{
			#if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
				gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal);
			#else
				UNITY_GLOSSY_ENV_FROM_SURFACE( g, s, data );
				gi = UnityGlobalIllumination( data, s.Occlusion, s.Normal, g );
			#endif
		}

		void surf( Input i , inout SurfaceOutputStandardSpecularCustom o )
		{
			float3 lerpResult60 = lerp( float3(0,0,1) , tex2D( _NormalTexture, ( i.uv_texcoord * _NormalUVS ) ).rgb , _NormalIntensity);
			o.Normal = lerpResult60;
			o.Albedo = _WaxColor.rgb;
			float lerpResult56 = lerp( _SpecularVC , _Specular , i.vertexColor.r);
			float3 temp_cast_1 = (lerpResult56).xxx;
			o.Specular = temp_cast_1;
			float lerpResult53 = lerp( _SmoothnessVC , _Smoothness , i.vertexColor.r);
			o.Smoothness = lerpResult53;
			o.Transmission = _WaxSSSColor.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19603
Node;AmplifyShaderEditor.TextureCoordinatesNode;63;-1536,1024;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;65;-1152,1152;Inherit;False;Property;_NormalUVS;Normal UV S;8;0;Create;True;0;0;0;False;0;False;1,3;1,3;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-1152,1024;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.VertexColorNode;54;-768,768;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;52;-768,512;Inherit;False;Property;_Smoothness;Smoothness;4;0;Create;True;0;0;0;False;0;False;0.3;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-768,656;Inherit;False;Property;_SmoothnessVC;Smoothness VC;5;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-768,256;Inherit;False;Property;_Specular;Specular;2;0;Create;True;0;0;0;False;0;False;0.3;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-768,384;Inherit;False;Property;_SpecularVC;Specular VC;3;0;Create;True;0;0;0;False;0;False;0.3;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;61;-768,1280;Inherit;False;Constant;_Vector0;Vector 0;6;0;Create;True;0;0;0;False;0;False;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;59;-768,1024;Inherit;True;Property;_NormalTexture;Normal Texture;6;0;Create;True;0;0;0;False;0;False;-1;c41456e9fec361b4db55c9fc66883c07;c41456e9fec361b4db55c9fc66883c07;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;62;-256,1152;Inherit;False;Property;_NormalIntensity;Normal Intensity;7;0;Create;True;0;0;0;False;0;False;0.2;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;26;-768,0;Inherit;False;Property;_WaxColor;Wax Color;0;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.6901961,0.5686274,0.4627449,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.LerpOp;53;-384,768;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;56;-384,512;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;60;-256,1024;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;66;-768,-384;Inherit;False;Property;_WaxSSSColor;Wax SSS Color;1;0;Create;True;0;0;0;False;0;False;0.2745098,0.2235294,0.1960784,0;0.2745098,0.2235294,0.1960784,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;67;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;StandardSpecular;Vefects/SH_Vefects_Candle_Wax_VC_01;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;64;0;63;0
WireConnection;64;1;65;0
WireConnection;59;1;64;0
WireConnection;53;0;55;0
WireConnection;53;1;52;0
WireConnection;53;2;54;0
WireConnection;56;0;57;0
WireConnection;56;1;51;0
WireConnection;56;2;54;0
WireConnection;60;0;61;0
WireConnection;60;1;59;5
WireConnection;60;2;62;0
WireConnection;67;0;26;5
WireConnection;67;1;60;0
WireConnection;67;3;56;0
WireConnection;67;4;53;0
WireConnection;67;6;66;5
ASEEND*/
//CHKSM=3870158BFA228EFC18941B74748AE9F9B4C04512