Shader "Scarecrow/Cloud"
{
    Properties
    {
        [Enum_Switch(RealTime, No3DTex, Bake)]_RenderMode ("渲染模式", float) = 0

        [Foldout]_Shape ("形状_Foldout", float) = 1
        [Tex(_WeatherTexTiling, RealTime, No3DTex)][NoScaleOffset]_WeatherTex ("天气纹理", 2D) = "white" { }
        [HideInInspector]_WeatherTexTiling ("天气纹理平铺", Range(0.1, 30)) = 1
        [Switch(RealTime, No3DTex)]_WeatherTexOffset ("天气纹理偏移", vector) = (0, 0, 0, 0)
        // _WeatherTexRepair ("天气纹理边缘拉伸修复", Range(0, 0.2)) = 0.05
        [Tex(_BaseShapeTexTiling, RealTime, Bake)][NoScaleOffset]_BaseShapeTex ("基础形状纹理", 3D) = "white" { }
        [HideInInspector]_BaseShapeTexTiling ("基础形状纹理平铺", Range(0.1, 5)) = 1
        [Switch(RealTime)]_BaseShapeDetailEffect ("基础形状细节影响", Range(0, 1)) = 0.5
        [Switch(Bake)]_BaseShapeRatio("基础形状比例", vector) = (1, 1, 1, 1)
        
        [Foldout(2, 2, 1, 0, RealTime)]_Shape_Detail ("细节形状_Foldout", float) = 1
        [Tex(_DetailShapeTexTiling)][NoScaleOffset]_DetailShapeTex ("细节形状纹理", 3D) = "white" { }
        [HideInInspector]_DetailShapeTexTiling ("细节形状纹理平铺", Range(0.1, 3)) = 1
        _DetailEffect ("细节影响强度", Range(0, 1)) = 1
        
        [Foldout(2, 2, 0, 0, RealTime, No3DTex)]_Shape_Weather ("天气设置_Foldout", float) = 1
        [Range]_CloudHeightRange ("云层高度  最小/最大范围", vector) = (1500, 4000, 0, 8000)
        [Range(RealTime)]_StratusRange ("层云范围", vector) = (0.1, 0.4, 0, 1)
        [Switch(RealTime)]_StratusFeather ("层云边缘羽化", Range(0, 1)) = 0.2
        [Range(RealTime)]_CumulusRange ("积云范围", vector) = (0.15, 0.8, 0, 1)
        [Switch(RealTime)]_CumulusFeather ("积云边缘羽化", Range(0, 1)) = 0.2
        [PowerSlider(0.7)]_CloudCover ("云层覆盖率", Range(0, 1)) = 0.5
        [Switch(No3DTex)]_CloudOffsetLower ("云底层偏移", Range(-1, 1)) = 0
        [Switch(No3DTex)]_CloudOffsetUpper ("云顶层偏移", Range(-1, 1)) = 0
        [Switch(No3DTex)]_CloudFeather ("云层边缘羽化", Range(0, 1)) = 0.2
        
        
        
        [Foldout(2, 2, 0, 0)]_Shape_Effect ("性能_Foldout", float) = 1
        [Switch(Bake)]_SDFScale("SDF缩放", Range(0, 2)) = 1
        _ShapeMarchLength ("形状单次步进长度", Range(0.001, 800)) = 300
        _ShapeMarchMax ("形状最大步进次数", Range(3, 100)) = 30
        
        [Foldout(2, 2, 0, 0)]_Shape_Other ("形状其他设置_Foldout", float) = 1
        _BlueNoiseEffect ("蓝噪声影响程度", Range(0, 1)) = 1
        [Vector3(RealTime, No3DTex)]_WindDirecton ("风向", vector) = (1, 0, 0, 0)
        [Switch(RealTime, No3DTex)]_WindSpeed ("风速", Range(0, 5)) = 1
        _DensityScale ("密度缩放", Range(0, 2)) = 1
        
        
        [Foldout]_Lighting ("光照_Foldout", float) = 1
        [Foldout(2, 2, 0, 0)]_Lighting_Convention ("常规_Foldout", float) = 1
        _CloudAbsorb ("云层吸收率", Range(0, 4)) = 0.5
        [Space]
        _ScatterForward ("向前散射", Range(0, 0.99)) = 0.5
        _ScatterForwardIntensity ("向前散射强度", Range(0, 1)) = 1
        [Space]
        _ScatterBackward ("向后散射", Range(0, 0.99)) = 0.4
        _ScatterBackwardIntensity ("向后散射强度", Range(0, 1)) = 0.4
        [Space]
        _ScatterBase ("基础散射", Range(0, 1)) = 0.2
        _ScatterMultiply ("散射乘数", Range(0, 1)) = 0.7
        
        [Foldout(2, 2, 0, 0)]_Lighting_Color ("颜色_Foldout", float) = 1
        [HDR]_ColorBright ("亮面颜色", color) = (1, 1, 1, 1)
        [HDR]_ColorCentral ("中间颜色", color) = (0.5, 0.5, 0.5, 1)
        [HDR]_ColorDark ("暗面颜色", color) = (0.1, 0.1, 0.1, 1)
        _ColorCentralOffset ("中间颜色偏移", Range(0, 1)) = 0.5
        [Space]
        _DarknessThreshold ("暗部阈值", Range(0, 1)) = 0.3
        
        [Foldout(2, 2, 0, 0, RealTime, No3DTex)]_Lighting_Effect ("性能_Foldout", float) = 1
        _LightingMarchMax ("光照最大步进次数", Range(1, 15)) = 8
        
        
        [Foldout_Out(1)]_FoldoutOut ("跳出折叠页_Foldout", float) = 1
        
        [HideInInspector]_MainTex ("Texture", 2D) = "white" { }
        [HideInInspector]_BoundBoxMin ("_BoundBoxMin", vector) = (-1, -1, -1, -1)
        [HideInInspector]_BoundBoxMax ("_BoundBoxMax", vector) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        LOD 100
        
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "CloudHelp.hlsl"
        
        CBUFFER_START(UnityPerMaterial)

        float _WeatherTexTiling;
        float2 _WeatherTexOffset;
        // float _WeatherTexRepair;
        float _BaseShapeTexTiling;
        float _BaseShapeDetailEffect;
        float3 _BaseShapeRatio;

        float _DetailShapeTexTiling;
        float _DetailEffect;
        
        float4 _CloudHeightRange;
        float4 _StratusRange;
        float _StratusFeather;
        float4 _CumulusRange;
        float _CumulusFeather;
        float _CloudCover;
        float _CloudOffsetLower;
        float _CloudOffsetUpper;
        float _CloudFeather;
        
        float _SDFScale;
        float _ShapeMarchLength;
        int _ShapeMarchMax;
        
        float _BlueNoiseEffect;
        float3 _WindDirecton;
        float _WindSpeed;
        float _DensityScale;
        
        float _CloudAbsorb;
        float _ScatterForward;
        float _ScatterForwardIntensity;
        float _ScatterBackward;
        float _ScatterBackwardIntensity;
        float _ScatterBase;
        float _ScatterMultiply;
        
        half4 _ColorBright;
        half4 _ColorCentral;
        half4 _ColorDark;
        float _ColorCentralOffset;
        float _DarknessThreshold;
        
        int _LightingMarchMax;
        
        
        
        
        //蓝噪声uv
        float2 _BlueNoiseTexUV;
        //当前绘制帧数
        int _FrameCount;
        //纹理宽度
        int _Width;
        //纹理高度
        int _Height;
        
        float3 _BoundBoxMin;
        float3 _BoundBoxMax;
        CBUFFER_END
        
        ENDHLSL
        
        Pass
        {
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #pragma shader_feature _RENDERMODE_REALTIME _RENDERMODE_NO3DTEX _RENDERMODE_BAKE
            #pragma shader_feature _SHAPE_DETAIL_ON
            #pragma multi_compile _OFF _2X2 _4X4
            
            
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_CameraDepthTexture);
            SAMPLER(sampler_CameraDepthTexture);
            TEXTURE2D(_BlueNoiseTex);
            SAMPLER(sampler_BlueNoiseTex);
            
            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv: TEXCOORD0;
            };
            
            struct v2f
            {
                float4 vertex: SV_POSITION;
                float2 uv: TEXCOORD0;
                float3 viewDir: TEXCOORD1;
            };
            
            
            v2f vert(appdata v)
            {
                v2f o;
                
                VertexPositionInputs vertexPos = GetVertexPositionInputs(v.vertex.xyz);
                o.vertex = vertexPos.positionCS;
                o.uv = v.uv;
                
                float3 viewDir = mul(unity_CameraInvProjection, float4(v.uv * 2.0 - 1.0, 0, -1)).xyz;
                o.viewDir = mul(unity_CameraToWorld, float4(viewDir, 0)).xyz;
                
                return o;
            }
            
            half4 frag(v2f i): SV_Target
            {
                half4 backColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                
                #ifndef _OFF
                    //进行分帧渲染判断
                    int iterationCount = 4;
                    #ifdef _2X2
                        iterationCount = 2;
                    #endif
                    int frameOrder = GetIndex(i.uv, _Width, _Height, iterationCount);
                    
                    // //分帧绘制顺序Debug
                    // #ifdef _2X2
                    //     return half4((frameOrder / 3.0).xxx, 0);
                    // #else
                    //     return half4((frameOrder / 15.0).xxx, 0);
                    // #endif
                    
                    //判断当帧是否渲染该片元
                    if (frameOrder != _FrameCount)
                    {
                        return backColor;
                    }
                #endif              
                
                float depth = SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, i.uv).x;
                float dstToObj = LinearEyeDepth(depth, _ZBufferParams);
                
                //获取灯光信息
                Light mainLight = GetMainLight();
                
                float3 viewDir = normalize(i.viewDir);
                float3 lightDir = normalize(mainLight.direction);
                float3 cameraPos = GetCameraPositionWS();
                
                //地球半径在6,357km到6,378km
                float earthRadius = 6300000;
                //地球中心坐标, 使水平行走永远不会逃出地球, 高度0为地表,
                float3 sphereCenter = float3(cameraPos.x, -earthRadius, cameraPos.z);
                //包围盒缩放
                float boundBoxScaleMax = 1;
                //包围盒位置
                float3 boundBoxPosition = (_BoundBoxMax + _BoundBoxMin) / 2.0;
                
                //计算步进的开始位置和结束位置
                #ifdef _RENDERMODE_BAKE
                    float2 dstCloud = RayBoxDst(_BoundBoxMin, _BoundBoxMax, cameraPos, viewDir);
                    //计算包围盒最大的缩放, 该值将用来矫正sdf以及步进
                    float3 boundBoxScale = (_BoundBoxMax - _BoundBoxMin) / _BaseShapeRatio;
                    boundBoxScaleMax = max(max(boundBoxScale.x, boundBoxScale.y), boundBoxScale.z);
                #else
                    float2 dstCloud = RayCloudLayerDst(sphereCenter, earthRadius, _CloudHeightRange.x, _CloudHeightRange.y, cameraPos, viewDir);
                #endif
                float dstToCloud = dstCloud.x;
                float dstInCloud = dstCloud.y;
                
                //不在包围盒内或被物体遮挡 直接显示背景
                if (dstInCloud <= 0 || dstToObj <= dstToCloud)
                {
                    return half4(0, 0, 0, 1);
                }
                
                
                //进行光线步进
                //设置采样信息
                SamplingInfo dsi;
                dsi.baseShapeTiling = _BaseShapeTexTiling;
                dsi.baseShapeRatio = _BaseShapeRatio;
                dsi.boundBoxScaleMax = boundBoxScaleMax;
                dsi.boundBoxPosition = boundBoxPosition;
                dsi.detailShapeTiling = _DetailShapeTexTiling;
                dsi.weatherTexTiling = _WeatherTexTiling;
                dsi.weatherTexOffset = _WeatherTexOffset;
                // dsi.weatherTexRepair = _WeatherTexRepair;
                dsi.baseShapeDetailEffect = _BaseShapeDetailEffect;
                dsi.detailEffect = _DetailEffect;
                dsi.densityMultiplier = _DensityScale;
                dsi.cloudDensityAdjust = _CloudCover;
                dsi.cloudAbsorbAdjust = _CloudAbsorb;
                dsi.windDirection = normalize(_WindDirecton);
                dsi.windSpeed = _WindSpeed;
                dsi.cloudHeightMinMax = _CloudHeightRange.xy;
                dsi.stratusInfo = float3(_StratusRange.xy, _StratusFeather);
                dsi.cumulusInfo = float3(_CumulusRange.xy, _CumulusFeather);
                dsi.cloudOffsetLower = _CloudOffsetLower;
                dsi.cloudOffsetUpper = _CloudOffsetUpper;
                dsi.feather = _CloudFeather;
                dsi.sphereCenter = sphereCenter;
                dsi.earthRadius = earthRadius;
                
                
                //向前/向后散射
                float phase = HGScatterMax(dot(viewDir, lightDir), _ScatterForward, _ScatterForwardIntensity, _ScatterBackward, _ScatterBackwardIntensity);
                phase = _ScatterBase + phase * _ScatterMultiply;
                
                
                
                //蓝噪声
                float blueNoise = SAMPLE_TEXTURE2D(_BlueNoiseTex, sampler_BlueNoiseTex, i.uv * _BlueNoiseTexUV).r;
                
                //穿出云覆盖范围的位置(结束位置)
                float endPos = dstToCloud + dstInCloud;
                //当前步进的距离, 从包围盒开始步进
                #ifdef _RENDERMODE_BAKE
                    //对于烘焙光照，蓝噪声将在第一次采样到云时进行影响
                    bool isFirstSampleCloud = true;
                    float currentMarchLength = dstToCloud;
                #else
                    //使用蓝噪声在对开始步进位置进行随机，配合TAA减轻因步进距离太大造成的层次感
                    float currentMarchLength = dstToCloud + _ShapeMarchLength * blueNoise * _BlueNoiseEffect;
                #endif
                //当前步进位置
                float3 currentPos = cameraPos + currentMarchLength * viewDir;
                //记录单次步进距离(当渲染模式为Bake时启用)
                float shapeMarchLength = _ShapeMarchLength;
                
                #if _RENDERMODE_BAKE
                    bool isBake = true;
                #else
                    bool isBake = false;
                #endif
                
                //累计总密度
                float totalDensity = 0;
                //总亮度
                float3 totalLum = 0;
                //光照衰减
                float lightAttenuation = 1.0;
                
                
                //一开始我们会以比较大的步长进行步进(2倍步长)进行密度采样检测，当检测到云时，退回来进行正常云的采样、光照计算
                //当累计采样到一定次数0密度时，在切换成大步进，从而加速退出
                //云测试密度
                float densityTest = 0;
                //上一次采样密度
                float densityPrevious = 0;
                //0密度采样次数
                int densitySampleCount_zero = 0;
                
                
                //开始步进, 当超过步进次数、被物体遮挡、穿出云覆盖氛围时，结束步进
                for (int marchNumber = 0; marchNumber < _ShapeMarchMax; marchNumber ++)
                {
                    //一开始就大步前进，烘焙模式时，我们使用sdf来快速逼近
                    if (densityTest == 0 && !isBake)
                    {
                        //向观察方向步进2倍的长度
                        currentMarchLength += _ShapeMarchLength * 2.0;
                        currentPos = cameraPos + currentMarchLength * viewDir;
                        
                        
                        //如果步进到被物体遮挡,或穿出云覆盖范围时,跳出循环
                        if (dstToObj <= currentMarchLength || endPos <= currentMarchLength)
                        {
                            break;
                        }
                        
                        //进行密度采样，测试是否继续大步前进
                        dsi.position = currentPos;
                        densityTest = SampleCloudDensity(dsi, true).density;
                        
                        //如果检测到云，往后退一步(因为我们可能错过了开始位置)
                        if (densityTest > 0)
                        {
                            currentMarchLength -= _ShapeMarchLength;
                        }
                    }
                    else
                    {
                        //采样该区域的密度
                        currentPos = cameraPos + currentMarchLength * viewDir;
                        dsi.position = currentPos;
                        #ifdef _SHAPE_DETAIL_ON
                            CloudInfo ci = SampleCloudDensity(dsi, false);
                        #else
                            CloudInfo ci = SampleCloudDensity(dsi, true);
                        #endif
                        
                        #if !_RENDERMODE_BAKE
                            //如果当前采样密度和上次采样密度都基本是0，那么进行累计，当到达指定数值时，切换到大步进
                            if (ci.density == 0 && densityPrevious == 0)
                            {
                                densitySampleCount_zero ++ ;
                                //累计检测到指定数值，切换到大步进
                                if (densitySampleCount_zero >= 8)
                                {
                                    densityTest = 0;
                                    densitySampleCount_zero = 0;
                                    continue;
                                }
                            }
                        #endif
                        
                        //乘上距离相当于该区域的积分
                        #if _RENDERMODE_BAKE
                            float density = ci.density * shapeMarchLength;
                        #else
                            float density = ci.density * _ShapeMarchLength;
                        #endif
                        
                        float currentLum = 0;
                        //密度大于阈值开始计算光照
                        if (density > 0.01)
                        {
                            //如果时烘焙模式 直接取纹理中的数据
                            #if !_RENDERMODE_BAKE
                                //计算该区域的光照贡献，从当前点向灯光方向步进
                                float2 dstCloud_light = RayCloudLayerDst(sphereCenter, earthRadius, _CloudHeightRange.x, _CloudHeightRange.y, currentPos, lightDir, false);
                                //灯光步进长度
                                float lightMarchLength = dstCloud_light.y / _LightingMarchMax;
                                //当前步进位置
                                float3 currentPos_light = currentPos;
                                //灯光方向密度
                                float totalDensity_light = 0;
                                
                                
                                //向灯光方向进行步进
                                for (int marchNumber_light = 0; marchNumber_light < _LightingMarchMax; marchNumber_light ++)
                                {
                                    currentPos_light += lightDir * lightMarchLength;
                                    dsi.position = currentPos_light;
                                    float density_Light = SampleCloudDensity(dsi, true).density * lightMarchLength;
                                    totalDensity_light += density_Light;
                                }
                                //光照强度
                                currentLum = BeerPowder(totalDensity_light, ci.absorptivity);
                            #else
                                currentLum = ci.lum;
                            #endif
                            
                            currentLum = _DarknessThreshold + currentLum * (1.0 - _DarknessThreshold);
                            //云层颜色
                            float3 cloudColor = Interpolation3(_ColorDark.rgb, _ColorCentral.rgb, _ColorBright.rgb, saturate(currentLum), _ColorCentralOffset) * mainLight.color;
                            
                            totalLum += lightAttenuation * cloudColor * density * phase;
                            totalDensity += density;
                            lightAttenuation *= Beer(density, ci.absorptivity);
                            
                            if (lightAttenuation < 0.01)
                                break;
                        }
                        
                        //向前步进
                        #if _RENDERMODE_BAKE
                            shapeMarchLength = max(_ShapeMarchLength, ci.sdf * _SDFScale);
                            //添加蓝噪声影响
                            if(density > 0.01 && isFirstSampleCloud)
                            {
                                shapeMarchLength *= blueNoise * _BlueNoiseEffect;
                                isFirstSampleCloud = false;
                            }
                            currentMarchLength += shapeMarchLength;
                        #else
                            currentMarchLength += _ShapeMarchLength;
                        #endif
                        //如果步进到被物体遮挡,或穿出云覆盖范围时,跳出循环
                        if (dstToObj <= currentMarchLength || endPos <= currentMarchLength)
                        {
                            break;
                        }
                        densityPrevious = ci.density;
                    }
                }
                
                //最后的颜色应当为backColor.rgb * lightAttenuation + totalLum, 但是因为分帧渲染，混合需要到下一pass
                // return half4(backColor.rgb * lightAttenuation + totalLum, lightAttenuation);
                return half4(totalLum, lightAttenuation);
            }
            ENDHLSL
            
        }
        
        pass
        {
            //最后的颜色应当为backColor.rgb * lightAttenuation + totalLum, 但是因为分帧渲染，混合需要特殊处理
            //云的返回颜色为half4(totalLum, lightAttenuation) , 将此混合设置为Blend One SrcAlpha 最后的颜色将为totalLum + lightAttenuation * baseColor
            //
            Blend One SrcAlpha
            
            HLSLPROGRAM
            
            #pragma vertex vert_blend
            #pragma fragment frag_blend
            
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
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
            
            v2f vert_blend(appdata v)
            {
                v2f o;
                
                VertexPositionInputs vertexPos = GetVertexPositionInputs(v.vertex.xyz);
                o.vertex = vertexPos.positionCS;
                o.uv = v.uv;
                return o;
            }
            
            half4 frag_blend(v2f i): SV_Target
            {
                return SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
            }
            
            ENDHLSL
            
        }
    }
    CustomEditor "Scarecrow.SimpleShaderGUI"
}
