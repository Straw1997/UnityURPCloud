Shader "Scarecrow/#NAME#"
{
    Properties
    {
        [Tex(_MainColor)]_MainTex ("Main Tex", 2D) = "white" { }
        [HideInInspector]_MainColor ("Main Color", Color) = (1, 1, 1, 1)
        
        [Foldout(1, 1, 0, 0)]_Other ("Other_Foldout", float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("Src Blend", float) = 1
        [Enum(UnityEngine.Rendering.BlendMode)]_DstBlend("Dst Blend", float) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry" }
        LOD 100
        
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        
        CBUFFER_START(UnityPerMaterial)
        float4 _MainTex_ST;
        half4 _MainColor;
        CBUFFER_END
        ENDHLSL
        
        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            Blend [_SrcBlend] [_DstBlend]
            
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
            };
            
            struct v2f
            {
                float4 vertex: SV_POSITION;
                float2 uv: TEXCOORD0;
            };
            
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            v2f vert(appdata v)
            {
                v2f o;
                VertexPositionInputs vertexPos = GetVertexPositionInputs(v.vertex.xyz);
                o.vertex = vertexPos.positionCS;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            
            half4 frag(v2f i): SV_Target
            {
                half4 col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv) * _MainColor;
                return col;
            }
            ENDHLSL            
        }
    }
    CustomEditor "Scarecrow.SimpleShaderGUI"
}
