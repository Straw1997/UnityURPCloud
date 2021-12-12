using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class BoundBox : MonoBehaviour
{
    public Material CloudMat;
    public bool IsShowLine = true;
    public Color LineColor = Color.green;

    void OnDrawGizmos()
    {
        //绘画边框
        if (IsShowLine)
        {
            Gizmos.color = LineColor;
            Gizmos.DrawWireCube(transform.position, transform.localScale);
        }
    }
    void Update()
    {
        //更新材质包围盒
        if (CloudMat)
        {
            CloudMat.SetVector("_BoundBoxMin", transform.position - transform.localScale / 2.0f);
            CloudMat.SetVector("_BoundBoxMax", transform.position + transform.localScale / 2.0f);
        }
    }

}
