using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameControl : MonoBehaviour
{
    public GameObject Camera_Bake;
    public GameObject Camera_No3DTex;

    public Material CloudMat_Bake;
    public Material CloudMat_No3DTex;

    [Range(0.1f, 1)]
    public float ClickInterval = 0.5f;

    private bool _isBake = true;
    private float _time = 0;
    private bool _isStart = false;

    void Update()
    {
        if (!_isStart)
        {
            if (Input.GetMouseButtonDown(0))
            {
                _isStart = true;
            }
        }
        else
        {
            _time += Time.deltaTime;
            if (_time <= ClickInterval)
            {
                if (Input.GetMouseButtonDown(0))
                {
                    SwitchCloud();
                    _time = 0;
                    _isStart = false;
                }
            }
            else
            {
                _time = 0;
                _isStart = false;
            }
        }
    }

    private void SwitchCloud()
    {
        if (VolumeCloud.Oneself)
        {
            //进行切换烘焙和无3D纹理模式
            _isBake = !_isBake;
            if (_isBake)
            {
                VolumeCloud.Oneself.Set.CloudMaterial = CloudMat_Bake;
                Camera_Bake.SetActive(true);
                Camera_No3DTex.SetActive(false);
            }
            else
            {
                VolumeCloud.Oneself.Set.CloudMaterial = CloudMat_No3DTex;
                Camera_Bake.SetActive(false);
                Camera_No3DTex.SetActive(true);
            }
        }
    }
}
