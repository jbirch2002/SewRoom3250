// Made with Amplify Shader Editor v1.9.6.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Vefects/SH_Vefects_URP_Candle_Smoke_01"
{
	Properties
	{
		_EmissiveMultiply("Emissive Multiply", Float) = 1
		_TextureColorIntensity("Texture Color Intensity", Float) = 0
		_Specular("Specular", Float) = 0
		_Smoothness("Smoothness", Float) = 0
		[Space(33)][Header(Smoke)][Space(13)]_SmokeTexture("Smoke Texture", 2D) = "white" {}
		_SmokeUVScale("Smoke UV Scale", Vector) = (1,0.2,0,0)
		_SmokeUVPan("Smoke UV Pan", Vector) = (0,-0.2,0,0)
		[Space(33)][Header(Distortion)][Space(13)]_DistortionTexture("Distortion Texture", 2D) = "white" {}
		_DistortionUVScale("Distortion UV Scale", Vector) = (0.1,0.1,0,0)
		_DistortionUVPan("Distortion UV Pan", Vector) = (-0.03,-0.2,0,0)
		_DistortionIntensity("Distortion Intensity", Float) = 0.03
		_VerticalDistortionPosition("Vertical Distortion Position", Float) = 0
		_VerticalDistortionFalloff("Vertical Distortion Falloff", Float) = 1
		_VerticalOpacityPosition("Vertical Opacity Position", Float) = 0
		_VerticalOpacityFalloff("Vertical Opacity Falloff", Float) = 1
		_VerticalBotOpacityPosition("Vertical Bot Opacity Position", Float) = 0.01
		_VerticalBotOpacityFalloff("Vertical Bot Opacity Falloff", Float) = 0.2
		_Eros("Eros", Float) = 0
		_ErosSmooth("Eros Smooth", Float) = 1
		[Space(33)][Header(AR)][Space(13)]_Cull("Cull", Float) = 2
		_Src("Src", Float) = 5
		_Dst("Dst", Float) = 10
		_ZWrite("ZWrite", Float) = 0
		_ZTest("ZTest", Float) = 2
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull [_Cull]
		ZWrite [_ZWrite]
		ZTest [_ZTest]
		Blend [_Src] [_Dst]
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf StandardSpecular keepalpha noshadow 
		#undef TRANSFORM_TEX
		#define TRANSFORM_TEX(tex,name) float4(tex.xy * name##_ST.xy + name##_ST.zw, tex.z, tex.w)
		struct Input
		{
			float4 vertexColor : COLOR;
			float4 uv_texcoord;
		};

		uniform float _ZWrite;
		uniform float _ZTest;
		uniform float _Cull;
		uniform float _Src;
		uniform float _Dst;
		uniform sampler2D _SmokeTexture;
		uniform float2 _SmokeUVPan;
		uniform float2 _SmokeUVScale;
		uniform sampler2D _DistortionTexture;
		uniform float2 _DistortionUVPan;
		uniform float2 _DistortionUVScale;
		uniform float _DistortionIntensity;
		uniform float _VerticalDistortionPosition;
		uniform float _VerticalDistortionFalloff;
		uniform float _TextureColorIntensity;
		uniform float _EmissiveMultiply;
		uniform float _Specular;
		uniform float _Smoothness;
		uniform float _Eros;
		uniform float _ErosSmooth;
		uniform float _VerticalOpacityPosition;
		uniform float _VerticalOpacityFalloff;
		uniform float _VerticalBotOpacityPosition;
		uniform float _VerticalBotOpacityFalloff;

		void surf( Input i , inout SurfaceOutputStandardSpecular o )
		{
			float2 panner59 = ( 1.0 * _Time.y * _SmokeUVPan + ( i.uv_texcoord.xy * _SmokeUVScale ));
			float randomOffset44 = i.uv_texcoord.z;
			float2 appendResult105 = (float2(0.0 , randomOffset44));
			float2 panner17 = ( 1.0 * _Time.y * _DistortionUVPan + ( i.uv_texcoord.xy * _DistortionUVScale ));
			float smoothstepResult29 = smoothstep( _VerticalDistortionPosition , ( _VerticalDistortionPosition + _VerticalDistortionFalloff ) , i.uv_texcoord.xy.y);
			float2 lerpResult21 = lerp( float2( 0,0 ) , ( ( (tex2D( _DistortionTexture, ( panner17 + randomOffset44 ) ).rgb).xy + -0.5 ) * 2.0 ) , saturate( ( _DistortionIntensity * saturate( smoothstepResult29 ) ) ));
			float4 tex2DNode10 = tex2D( _SmokeTexture, ( ( panner59 + appendResult105 ) + lerpResult21 ) );
			float4 lerpResult86 = lerp( i.vertexColor , ( i.vertexColor * float4( tex2DNode10.rgb , 0.0 ) ) , _TextureColorIntensity);
			o.Albedo = lerpResult86.rgb;
			o.Emission = ( lerpResult86 * _EmissiveMultiply ).rgb;
			float3 temp_cast_3 = (_Specular).xxx;
			o.Specular = temp_cast_3;
			o.Smoothness = _Smoothness;
			float3 temp_cast_4 = (_Eros).xxx;
			float3 temp_cast_5 = (( _Eros + _ErosSmooth )).xxx;
			float3 smoothstepResult61 = smoothstep( temp_cast_4 , temp_cast_5 , tex2DNode10.rgb);
			float smoothstepResult71 = smoothstep( _VerticalOpacityPosition , ( _VerticalOpacityPosition + _VerticalOpacityFalloff ) , ( 1.0 - i.uv_texcoord.xy.y ));
			float smoothstepResult79 = smoothstep( _VerticalBotOpacityPosition , ( _VerticalBotOpacityPosition + _VerticalBotOpacityFalloff ) , i.uv_texcoord.xy.y);
			o.Alpha = saturate( ( saturate( ( saturate( smoothstepResult61 ) * saturate( ( saturate( smoothstepResult71 ) * saturate( smoothstepResult79 ) ) ) ) ) * i.vertexColor.a ) ).x;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19603
Node;AmplifyShaderEditor.TextureCoordinatesNode;14;-4096,640;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;43;-1408,-1152;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;16;-3712,768;Inherit;False;Property;_DistortionUVScale;Distortion UV Scale;9;0;Create;True;0;0;0;False;0;False;0.1,0.1;0.1,0.1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;44;-1024,-1152;Inherit;False;randomOffset;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;18;-3328,768;Inherit;False;Property;_DistortionUVPan;Distortion UV Pan;10;0;Create;True;0;0;0;False;0;False;-0.03,-0.2;-0.03,-0.2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-3712,640;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-1664,1152;Inherit;False;Property;_VerticalDistortionPosition;Vertical Distortion Position;12;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-1664,1280;Inherit;False;Property;_VerticalDistortionFalloff;Vertical Distortion Falloff;13;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;17;-3328,640;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;28;-1664,1024;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;31;-1280,1280;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;-3072,512;Inherit;False;44;randomOffset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;45;-3072,640;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;29;-1152,1024;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-1664,384;Inherit;False;Property;_DistortionIntensity;Distortion Intensity;11;0;Create;True;0;0;0;False;0;False;0.03;0.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;11;-2816,640;Inherit;True;Property;_DistortionTexture;Distortion Texture;8;0;Create;True;0;0;0;False;3;Space(33);Header(Distortion);Space(13);False;-1;c41456e9fec361b4db55c9fc66883c07;c41456e9fec361b4db55c9fc66883c07;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SaturateNode;33;-896,1024;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;23;-3712,0;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;57;-3328,128;Inherit;False;Property;_SmokeUVScale;Smoke UV Scale;6;0;Create;True;0;0;0;False;0;False;1,0.2;0.1,0.1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ComponentMaskNode;20;-2432,640;Inherit;False;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-1408,384;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;58;-2944,128;Inherit;False;Property;_SmokeUVPan;Smoke UV Pan;7;0;Create;True;0;0;0;False;0;False;0,-0.2;0,-0.2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-3328,0;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;106;-2432,256;Inherit;False;44;randomOffset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;19;-2176,640;Inherit;False;ConstantBiasScale;-1;;1;63208df05c83e8e49a48ffbdce2e43a0;0;3;3;FLOAT2;0,0;False;1;FLOAT;-0.5;False;2;FLOAT;2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;24;-2048,128;Inherit;False;Constant;_Vector0;Vector 0;4;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SaturateNode;27;-1152,384;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;67;-1664,1920;Inherit;False;Property;_VerticalOpacityPosition;Vertical Opacity Position;14;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;68;-1664,2048;Inherit;False;Property;_VerticalOpacityFalloff;Vertical Opacity Falloff;15;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;69;-1664,1792;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;77;-1664,2560;Inherit;False;Property;_VerticalBotOpacityFalloff;Vertical Bot Opacity Falloff;17;0;Create;True;0;0;0;False;0;False;0.2;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-1664,2432;Inherit;False;Property;_VerticalBotOpacityPosition;Vertical Bot Opacity Position;16;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;59;-2944,0;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;105;-2432,128;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;21;-1664,128;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;70;-1280,2048;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;74;-1408,1792;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;78;-1280,2560;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;80;-1664,2304;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;103;-2432,0;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;22;-1664,0;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-768,512;Inherit;False;Property;_Eros;Eros;18;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;64;-768,640;Inherit;False;Property;_ErosSmooth;Eros Smooth;19;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;71;-1152,1792;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;79;-1152,2304;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;10;-1408,0;Inherit;True;Property;_SmokeTexture;Smoke Texture;5;0;Create;True;0;0;0;False;3;Space(33);Header(Smoke);Space(13);False;-1;66fecea9ea01c0f4d94abda6fed2878a;66fecea9ea01c0f4d94abda6fed2878a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleAddOpNode;65;-512,640;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;72;-896,1792;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;75;-896,2304;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;61;-768,384;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;1,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;-640,1792;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;40;-384,384;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;84;-384,1792;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;73;-640,1024;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexColorNode;13;-1408,-512;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;66;-384,1024;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-768,0;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;88;-768,-256;Inherit;False;Property;_TextureColorIntensity;Texture Color Intensity;2;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;39;718,-50;Inherit;False;1252;162.95;Lush was here! <3;5;36;35;37;38;34;Lush was here! <3;0,0,0,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;101;-640,1152;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;86;-768,-384;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-384,-640;Inherit;False;Property;_EmissiveMultiply;Emissive Multiply;1;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;37;1536,0;Inherit;False;Property;_ZWrite;ZWrite;23;0;Create;True;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;1792,0;Inherit;False;Property;_ZTest;ZTest;24;0;Create;True;0;0;0;True;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;768,0;Inherit;False;Property;_Cull;Cull;20;0;Create;True;0;0;0;True;3;Space(33);Header(AR);Space(13);False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;1024,0;Inherit;False;Property;_Src;Src;21;0;Create;True;0;0;0;True;0;False;5;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;36;1280,0;Inherit;False;Property;_Dst;Dst;22;0;Create;True;0;0;0;True;0;False;10;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-384,-512;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;89;-384,0;Inherit;False;Property;_Smoothness;Smoothness;4;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;90;-384,128;Inherit;False;Property;_Specular;Specular;3;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;102;-384,1152;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;107;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;StandardSpecular;Vefects/SH_Vefects_URP_Candle_Smoke_01;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;True;_ZWrite;0;True;_ZTest;False;0;False;;0;False;;False;0;Custom;0.5;True;False;0;False;Transparent;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;2;5;True;_Src;10;True;_Dst;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;True;_Cull;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;44;0;43;3
WireConnection;15;0;14;0
WireConnection;15;1;16;0
WireConnection;17;0;15;0
WireConnection;17;2;18;0
WireConnection;31;0;30;0
WireConnection;31;1;32;0
WireConnection;45;0;17;0
WireConnection;45;1;46;0
WireConnection;29;0;28;2
WireConnection;29;1;30;0
WireConnection;29;2;31;0
WireConnection;11;1;45;0
WireConnection;33;0;29;0
WireConnection;20;0;11;5
WireConnection;26;0;25;0
WireConnection;26;1;33;0
WireConnection;60;0;23;0
WireConnection;60;1;57;0
WireConnection;19;3;20;0
WireConnection;27;0;26;0
WireConnection;59;0;60;0
WireConnection;59;2;58;0
WireConnection;105;1;106;0
WireConnection;21;0;24;0
WireConnection;21;1;19;0
WireConnection;21;2;27;0
WireConnection;70;0;67;0
WireConnection;70;1;68;0
WireConnection;74;0;69;2
WireConnection;78;0;76;0
WireConnection;78;1;77;0
WireConnection;103;0;59;0
WireConnection;103;1;105;0
WireConnection;22;0;103;0
WireConnection;22;1;21;0
WireConnection;71;0;74;0
WireConnection;71;1;67;0
WireConnection;71;2;70;0
WireConnection;79;0;80;2
WireConnection;79;1;76;0
WireConnection;79;2;78;0
WireConnection;10;1;22;0
WireConnection;65;0;63;0
WireConnection;65;1;64;0
WireConnection;72;0;71;0
WireConnection;75;0;79;0
WireConnection;61;0;10;5
WireConnection;61;1;63;0
WireConnection;61;2;65;0
WireConnection;83;0;72;0
WireConnection;83;1;75;0
WireConnection;40;0;61;0
WireConnection;84;0;83;0
WireConnection;73;0;40;0
WireConnection;73;1;84;0
WireConnection;66;0;73;0
WireConnection;12;0;13;0
WireConnection;12;1;10;5
WireConnection;101;0;66;0
WireConnection;101;1;13;4
WireConnection;86;0;13;0
WireConnection;86;1;12;0
WireConnection;86;2;88;0
WireConnection;41;0;86;0
WireConnection;41;1;42;0
WireConnection;102;0;101;0
WireConnection;107;0;86;0
WireConnection;107;2;41;0
WireConnection;107;3;90;0
WireConnection;107;4;89;0
WireConnection;107;9;102;0
ASEEND*/
//CHKSM=BB561B7D047D6C7A3A470FE3DAF7870946FBC7C9