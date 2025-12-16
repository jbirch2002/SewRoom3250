// Made with Amplify Shader Editor v1.9.6.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Vefects/SH_Vefects_URP_Candle_Flame_01"
{
	Properties
	{
		_EmissiveMultiply("Emissive Multiply", Float) = 13
		_IsAdd("Is Add", Float) = 0
		[Space(33)][Header(Flame)][Space(13)]_FlameTexture("Flame Texture", 2D) = "white" {}
		[Space(33)][Header(Distortion)][Space(13)]_DistortionTexture("Distortion Texture", 2D) = "white" {}
		_DistortionUVScale("Distortion UV Scale", Vector) = (0.1,0.1,0,0)
		_DistortionUVPan("Distortion UV Pan", Vector) = (-0.03,-0.2,0,0)
		_DistortionIntensity("Distortion Intensity", Float) = 0.03
		_VerticalDistortionPosition("Vertical Distortion Position", Float) = 0
		_VerticalDistortionFalloff("Vertical Distortion Falloff", Float) = 1
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
		#pragma surface surf Unlit keepalpha noshadow nofog nometa noforwardadd 
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
		uniform sampler2D _FlameTexture;
		uniform sampler2D _DistortionTexture;
		uniform float2 _DistortionUVPan;
		uniform float2 _DistortionUVScale;
		uniform float _DistortionIntensity;
		uniform float _VerticalDistortionPosition;
		uniform float _VerticalDistortionFalloff;
		uniform float _IsAdd;
		uniform float _EmissiveMultiply;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 panner17 = ( 1.0 * _Time.y * _DistortionUVPan + ( i.uv_texcoord.xy * _DistortionUVScale ));
			float randomOffset44 = i.uv_texcoord.z;
			float smoothstepResult29 = smoothstep( _VerticalDistortionPosition , ( _VerticalDistortionPosition + _VerticalDistortionFalloff ) , i.uv_texcoord.xy.y);
			float2 lerpResult21 = lerp( float2( 0,0 ) , ( ( (tex2D( _DistortionTexture, ( panner17 + randomOffset44 ) ).rgb).xy + -0.5 ) * 2.0 ) , saturate( ( _DistortionIntensity * saturate( smoothstepResult29 ) ) ));
			float4 tex2DNode10 = tex2D( _FlameTexture, ( i.uv_texcoord.xy + lerpResult21 ) );
			float3 temp_output_48_0 = saturate( tex2DNode10.rgb );
			float4 lerpResult54 = lerp( i.vertexColor , ( float4( temp_output_48_0 , 0.0 ) * i.vertexColor ) , _IsAdd);
			o.Emission = ( lerpResult54 * _EmissiveMultiply ).rgb;
			o.Alpha = temp_output_48_0.x;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19603
Node;AmplifyShaderEditor.Vector2Node;16;-3712,768;Inherit;False;Property;_DistortionUVScale;Distortion UV Scale;6;0;Create;True;0;0;0;False;0;False;0.1,0.1;0.1,0.1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;14;-4096,640;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexCoordVertexDataNode;43;-1408,-1152;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;30;-1792,1152;Inherit;False;Property;_VerticalDistortionPosition;Vertical Distortion Position;9;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-1792,1280;Inherit;False;Property;_VerticalDistortionFalloff;Vertical Distortion Falloff;10;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-3712,640;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;44;-1024,-1152;Inherit;False;randomOffset;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;18;-3328,768;Inherit;False;Property;_DistortionUVPan;Distortion UV Pan;7;0;Create;True;0;0;0;False;0;False;-0.03,-0.2;-0.03,-0.2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;28;-1792,1024;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;31;-1408,1280;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;17;-3328,640;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;-3072,512;Inherit;False;44;randomOffset;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;29;-1280,1024;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;45;-3072,640;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;33;-1024,1024;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-1664,384;Inherit;False;Property;_DistortionIntensity;Distortion Intensity;8;0;Create;True;0;0;0;False;0;False;0.03;0.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;11;-2816,640;Inherit;True;Property;_DistortionTexture;Distortion Texture;5;0;Create;True;0;0;0;False;3;Space(33);Header(Distortion);Space(13);False;-1;c41456e9fec361b4db55c9fc66883c07;c41456e9fec361b4db55c9fc66883c07;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.ComponentMaskNode;20;-2432,640;Inherit;False;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-1408,384;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;19;-2176,640;Inherit;False;ConstantBiasScale;-1;;1;63208df05c83e8e49a48ffbdce2e43a0;0;3;3;FLOAT2;0,0;False;1;FLOAT;-0.5;False;2;FLOAT;2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;24;-2048,128;Inherit;False;Constant;_Vector0;Vector 0;4;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SaturateNode;27;-1152,384;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;21;-1664,128;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;23;-2048,0;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;22;-1664,0;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;10;-1408,0;Inherit;True;Property;_FlameTexture;Flame Texture;4;0;Create;True;0;0;0;False;3;Space(33);Header(Flame);Space(13);False;-1;3d7dd642a5acab84594e789377168cba;3d7dd642a5acab84594e789377168cba;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.VertexColorNode;13;-1408,-512;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;48;-384,384;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-640,128;Inherit;False;Property;_IsAdd;Is Add;2;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-896,0;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;39;718,-50;Inherit;False;1252;162.95;Lush was here! <3;5;36;35;37;38;34;Lush was here! <3;0,0,0,1;0;0
Node;AmplifyShaderEditor.LerpOp;54;-640,0;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-384,-256;Inherit;False;Property;_EmissiveMultiply;Emissive Multiply;1;0;Create;True;0;0;0;False;0;False;13;13;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-640,640;Inherit;False;Property;_DepthFade;Depth Fade;3;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;49;-640,512;Inherit;False;False;True;False;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;50;-384,512;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-640,384;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-384,0;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;37;1536,0;Inherit;False;Property;_ZWrite;ZWrite;14;0;Create;True;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;38;1792,0;Inherit;False;Property;_ZTest;ZTest;15;0;Create;True;0;0;0;True;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;768,0;Inherit;False;Property;_Cull;Cull;11;0;Create;True;0;0;0;True;3;Space(33);Header(AR);Space(13);False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;35;1024,0;Inherit;False;Property;_Src;Src;12;0;Create;True;0;0;0;True;0;False;5;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;36;1280,0;Inherit;False;Property;_Dst;Dst;13;0;Create;True;0;0;0;True;0;False;10;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;57;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Vefects/SH_Vefects_URP_Candle_Flame_01;False;False;False;False;False;False;False;False;False;True;True;True;False;False;False;False;False;False;False;False;False;Back;0;True;_ZWrite;0;True;_ZTest;False;0;False;;0;False;;False;0;Custom;0.5;True;False;0;True;Transparent;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;2;5;True;_Src;10;True;_Dst;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;True;_Cull;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;15;0;14;0
WireConnection;15;1;16;0
WireConnection;44;0;43;3
WireConnection;31;0;30;0
WireConnection;31;1;32;0
WireConnection;17;0;15;0
WireConnection;17;2;18;0
WireConnection;29;0;28;2
WireConnection;29;1;30;0
WireConnection;29;2;31;0
WireConnection;45;0;17;0
WireConnection;45;1;46;0
WireConnection;33;0;29;0
WireConnection;11;1;45;0
WireConnection;20;0;11;5
WireConnection;26;0;25;0
WireConnection;26;1;33;0
WireConnection;19;3;20;0
WireConnection;27;0;26;0
WireConnection;21;0;24;0
WireConnection;21;1;19;0
WireConnection;21;2;27;0
WireConnection;22;0;23;0
WireConnection;22;1;21;0
WireConnection;10;1;22;0
WireConnection;48;0;10;5
WireConnection;56;0;48;0
WireConnection;56;1;13;0
WireConnection;54;0;13;0
WireConnection;54;1;56;0
WireConnection;54;2;55;0
WireConnection;49;0;52;0
WireConnection;50;0;49;0
WireConnection;47;0;10;5
WireConnection;47;1;50;0
WireConnection;41;0;54;0
WireConnection;41;1;42;0
WireConnection;57;2;41;0
WireConnection;57;9;48;0
ASEEND*/
//CHKSM=24B5D7D85E6871D2BEBAC3CF5438C05F3F2E3842