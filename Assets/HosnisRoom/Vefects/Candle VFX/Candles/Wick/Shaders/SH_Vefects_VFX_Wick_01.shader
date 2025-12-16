// Made with Amplify Shader Editor v1.9.6.3
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Vefects/SH_Vefects_VFX_Wick_01"
{
	Properties
	{
		_Specular("Specular", Float) = 0.03
		_Smoothness("Smoothness", Float) = 0
		_WickColor("Wick Color", Color) = (0.3490196,0.3176471,0.3098039,0)
		_TipColor("Tip Color", Color) = (1,0.5372549,0,0)
		_EmissiveIntensity("Emissive Intensity", Float) = 13
		_TipPosition("Tip Position", Range( 0 , 1)) = 0.8
		_TipFalloff("Tip Falloff", Range( 0 , 1)) = 0.1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf StandardSpecular keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _WickColor;
		uniform float4 _TipColor;
		uniform float _TipPosition;
		uniform float _TipFalloff;
		uniform float _EmissiveIntensity;
		uniform float _Specular;
		uniform float _Smoothness;

		void surf( Input i , inout SurfaceOutputStandardSpecular o )
		{
			o.Albedo = _WickColor.rgb;
			float smoothstepResult49 = smoothstep( _TipPosition , ( _TipPosition + _TipFalloff ) , i.uv_texcoord.y);
			o.Emission = ( ( _TipColor.rgb * saturate( smoothstepResult49 ) ) * _EmissiveIntensity );
			float3 temp_cast_0 = (_Specular).xxx;
			o.Specular = temp_cast_0;
			o.Smoothness = _Smoothness;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19603
Node;AmplifyShaderEditor.RangedFloatNode;51;-1408,-384;Inherit;False;Property;_TipPosition;Tip Position;5;0;Create;True;0;0;0;False;0;False;0.8;0.8;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-1408,-256;Inherit;False;Property;_TipFalloff;Tip Falloff;6;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;48;-1408,-512;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;53;-1152,-256;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;49;-1152,-512;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;50;-896,-512;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;40;-1408,-768;Inherit;False;Property;_TipColor;Tip Color;3;0;Create;True;0;0;0;False;0;False;1,0.5372549,0,0;1,0.5372549,0,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-768,-768;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-384,-640;Inherit;False;Property;_EmissiveIntensity;Emissive Intensity;4;0;Create;True;0;0;0;False;0;False;13;13;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;22;-1408,0;Inherit;False;Property;_WickColor;Wick Color;2;0;Create;True;0;0;0;False;0;False;0.3490196,0.3176471,0.3098039,0;0.3490196,0.3176471,0.3098039,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-384,-768;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-1408,512;Inherit;False;Property;_Specular;Specular;0;0;Create;True;0;0;0;False;0;False;0.03;0.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-1408,640;Inherit;False;Property;_Smoothness;Smoothness;1;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;54;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;StandardSpecular;Vefects/SH_Vefects_VFX_Wick_01;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;53;0;51;0
WireConnection;53;1;52;0
WireConnection;49;0;48;2
WireConnection;49;1;51;0
WireConnection;49;2;53;0
WireConnection;50;0;49;0
WireConnection;44;0;40;5
WireConnection;44;1;50;0
WireConnection;41;0;44;0
WireConnection;41;1;43;0
WireConnection;54;0;22;5
WireConnection;54;2;41;0
WireConnection;54;3;27;0
WireConnection;54;4;28;0
ASEEND*/
//CHKSM=E04BB17A22CFCB3E7CEDE706ECBD846CDFBE37E9