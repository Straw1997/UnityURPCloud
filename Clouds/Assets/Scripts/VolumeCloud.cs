using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class VolumeCloud : ScriptableRendererFeature
{
    //测试切换使用
    public static VolumeCloud Oneself;

    //分帧渲染的块数
    public enum FrameBlock
    {
        _Off = 1,
        _2x2 = 4,
        _4x4 = 16
    }

    [System.Serializable]
    public class Setting
    {
        //后处理材质
        public Material CloudMaterial;
        //渲染队列
        public RenderPassEvent RenderQueue = RenderPassEvent.AfterRenderingSkybox;
        //蓝噪声
        public Texture2D BlueNoiseTex;
        //分辨率缩放
        [Range(0.1f, 1)]
        public float RTScale = 0.5f;
        //分帧渲染
        public FrameBlock FrameBlocking = FrameBlock._4x4;

        //屏蔽相机分辨率宽度(受纹理缩放影响)
        [Range(100, 600)]
        public int ShieldWidth = 400;

        //是否开启分帧测试
        public bool IsFrameDebug = false;
        //分帧测试
        [Range(1, 16)]
        public int FrameDebug = 1;
    }




    class VolumeCloudRenderPass : ScriptableRenderPass
    {

        public Setting Set;
        public string name;
        public RenderTargetIdentifier cameraColorTex;
        //云渲染纹理， 通过两张进行相互迭代，完成分帧渲染
        public RenderTexture[] cloudTex;
        //云纹理的宽度
        public int width;
        //云纹理的高度
        public int height;
        //帧计数
        public int frameCount;
        //纹理切换
        public int rtSwitch;



        public VolumeCloudRenderPass(Setting set, string name)
        {
            renderPassEvent = set.RenderQueue;
            this.Set = set;
            this.name = name;
            this.frameCount = 0;
        }

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get(name);

            //设置材质参数
            Set.CloudMaterial.SetTexture("_BlueNoiseTex", Set.BlueNoiseTex);
            Set.CloudMaterial.SetVector("_BlueNoiseTexUV", new Vector4((float)width / (float)Set.BlueNoiseTex.width, (float)height / (float)Set.BlueNoiseTex.height, 0, 0));
            Set.CloudMaterial.SetInt("_Width", width - 1);
            Set.CloudMaterial.SetInt("_Height", height - 1);
            Set.CloudMaterial.SetInt("_FrameCount", frameCount);
            if (Set.FrameBlocking == FrameBlock._Off)
            {
                Set.CloudMaterial.EnableKeyword("_OFF");
                Set.CloudMaterial.DisableKeyword("_2X2");
                Set.CloudMaterial.DisableKeyword("_4X4");

            }
            if (Set.FrameBlocking == FrameBlock._2x2)
            {
                Set.CloudMaterial.DisableKeyword("_OFF");
                Set.CloudMaterial.EnableKeyword("_2X2");
                Set.CloudMaterial.DisableKeyword("_4X4");

            }
            if (Set.FrameBlocking == FrameBlock._4x4)
            {
                Set.CloudMaterial.DisableKeyword("_OFF");
                Set.CloudMaterial.DisableKeyword("_2X2");
                Set.CloudMaterial.EnableKeyword("_4X4");
            }


            //如果不开启分帧渲染，我们将创建临时渲染纹理
            if (Set.FrameBlocking == FrameBlock._Off)
            {
                //创建临时渲染纹理
                RenderTextureDescriptor temDescriptor = new RenderTextureDescriptor(width, height, RenderTextureFormat.ARGB32);
                temDescriptor.depthBufferBits = 0;
                int temTextureID = Shader.PropertyToID("_CloudTex");
                cmd.GetTemporaryRT(temTextureID, temDescriptor);

                cmd.Blit(cameraColorTex, temTextureID, Set.CloudMaterial, 0);
                cmd.Blit(temTextureID, cameraColorTex, Set.CloudMaterial, 1);

                //执行
                context.ExecuteCommandBuffer(cmd);
                //释放资源
                cmd.ReleaseTemporaryRT(temTextureID);
            }
            else//如果开启分帧渲染，则进行两张纹理相互迭代，完成分帧渲染
            {
                cmd.Blit(cloudTex[rtSwitch % 2], cloudTex[(rtSwitch + 1) % 2], Set.CloudMaterial, 0);
                cmd.Blit(cloudTex[(rtSwitch + 1) % 2], cameraColorTex, Set.CloudMaterial, 1);

                //执行
                context.ExecuteCommandBuffer(cmd);
            }

            //释放资源
            CommandBufferPool.Release(cmd);
        }

    }

    VolumeCloudRenderPass cloudPass;
    public Setting Set = new Setting();

    //云渲染纹理， 通过两张进行相互迭代，完成分帧渲染
    private RenderTexture[] _cloudTex_game = new RenderTexture[2];
    //预览窗口和游戏视口需要分开
    private RenderTexture[] _cloudTex_sceneView = new RenderTexture[2];
    //上一次纹理分辨率
    private int _width_game;
    private int _height_game;
    private int _width_sceneView;
    private int _height_sceneView;

    //当前帧数
    private int _frameCount_game;
    private int _frameCount_sceneView;

    //纹理切换
    private int _rtSwitch_game;
    private int _rtSwitch_sceneView;

    //上一次分帧测试数值
    private int _frameDebug = 1;

    public override void Create()
    {
        Oneself = this;
        cloudPass = new VolumeCloudRenderPass(Set, name);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {

        if (!(Set.CloudMaterial && (renderingData.cameraData.cameraType == CameraType.Game || renderingData.cameraData.cameraType == CameraType.SceneView)))
            return;

        //云纹理分辨率
        int width = (int)(renderingData.cameraData.cameraTargetDescriptor.width * Set.RTScale);
        int height = (int)(renderingData.cameraData.cameraTargetDescriptor.height * Set.RTScale);

        //不进行分帧渲染
        if (Set.FrameBlocking == FrameBlock._Off)
        {
            for (int i = 0; i < 2; i++)
            {
                //重置纹理
                RenderTexture.ReleaseTemporary(_cloudTex_game[i]);
                RenderTexture.ReleaseTemporary(_cloudTex_sceneView[i]);
                _cloudTex_game = new RenderTexture[2];
                _cloudTex_sceneView = new RenderTexture[2];
            }

            cloudPass.width = width;
            cloudPass.height = height;
            cloudPass.cameraColorTex = renderer.cameraColorTarget;
            renderer.EnqueuePass(cloudPass);
            return;
        }



        //分帧渲染////////////////////////////////////////////////////////////////////////////
        //分帧调试
        if (Set.IsFrameDebug)
        {
            if (Set.FrameDebug != _frameDebug)
            {
                for (int i = 0; i < 2; i++)
                {
                    //重置纹理
                    RenderTexture.ReleaseTemporary(_cloudTex_game[i]);
                    RenderTexture.ReleaseTemporary(_cloudTex_sceneView[i]);
                    _cloudTex_game = new RenderTexture[2];
                    _cloudTex_sceneView = new RenderTexture[2];
                }
            }
            _frameDebug = Set.FrameDebug;
            //分帧测试
            _frameCount_game = _frameCount_game % Set.FrameDebug;
            _frameCount_sceneView = _frameCount_sceneView % Set.FrameDebug;
        }



        //对游戏视口和场景视口进行分别处理，内容基本是一至的
        if (renderingData.cameraData.cameraType == CameraType.Game)
        {
            //创建纹理
            for (int i = 0; i < _cloudTex_game.Length; i++)
            {
                if (_cloudTex_game[i] != null && _width_game == width && _height_game == height)
                    continue;
                //当选中相机时，右下角会有一个预览窗口，他的分辨率与当前game视口不一样，所以会进行打架
                //在这设置阈值，屏蔽掉预览窗口的变化
                if (width < Set.ShieldWidth)
                    continue;

                //创建游戏视口的渲染纹理
                _cloudTex_game[i] = RenderTexture.GetTemporary(width, height, 0, RenderTextureFormat.ARGB32);

                _width_game = width;
                _height_game = height;
            }

            cloudPass.cloudTex = _cloudTex_game;
            cloudPass.width = _width_game;
            cloudPass.height = _height_game;
            cloudPass.frameCount = _frameCount_game;
            cloudPass.rtSwitch = _rtSwitch_game;

            _rtSwitch_game = (++_rtSwitch_game) % 2;

            //增加帧数
            _frameCount_game = (++_frameCount_game) % (int)Set.FrameBlocking;
        }
        else
        {
            //创建纹理
            for (int i = 0; i < _cloudTex_sceneView.Length; i++)
            {
                if (_cloudTex_sceneView[i] != null && _width_sceneView == width && _height_sceneView == height)
                    continue;

                //创建场景视口的渲染纹理
                _cloudTex_sceneView[i] = RenderTexture.GetTemporary(width, height, 0, RenderTextureFormat.ARGB32);//, RenderTextureReadWrite.Default, 1);

                _width_sceneView = width;
                _height_sceneView = height;
            }

            cloudPass.cloudTex = _cloudTex_sceneView;
            cloudPass.width = _width_sceneView;
            cloudPass.height = _height_sceneView;
            cloudPass.frameCount = _frameCount_sceneView;
            cloudPass.rtSwitch = _rtSwitch_sceneView;

            _rtSwitch_sceneView = (++_rtSwitch_sceneView) % 2;

            //增加帧数
            _frameCount_sceneView = (++_frameCount_sceneView) % (int)Set.FrameBlocking;
        }

        renderer.EnqueuePass(cloudPass);
        cloudPass.cameraColorTex = renderer.cameraColorTarget;
    }


}


