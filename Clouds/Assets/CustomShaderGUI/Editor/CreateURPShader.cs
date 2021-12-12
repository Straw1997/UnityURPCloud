using UnityEngine;
using UnityEditor;
using System;
using System.IO;
using System.Text;
using UnityEditor.ProjectWindowCallback;
using System.Text.RegularExpressions;
 
public class CreateURPShader
{
    public const string shaderTemplatePath = "Assets/CustomShaderGUI/Editor/Template/URPShader.shader";

    [MenuItem("Assets/Create/Shader/URP Shader")]
    public static void CreatURPShaderTemplate()
    {
        ProjectWindowUtil.StartNameEditingIfProjectWindowExists(0,
        ScriptableObject.CreateInstance<URPShadertAsset>(),
        GetSelectedPathOrFallback() + "/URPShader.shader",
        null,
       shaderTemplatePath);
    }
 
 
    //获取选择的路径
    public static string GetSelectedPathOrFallback()
    {
        string path = "Assets";
        foreach (UnityEngine.Object obj in Selection.GetFiltered(typeof(UnityEngine.Object), SelectionMode.Assets))
        {
            path = AssetDatabase.GetAssetPath(obj);
            if (!string.IsNullOrEmpty(path) && File.Exists(path))
            {
                path = Path.GetDirectoryName(path);
                break;
            }
        }
        return path;
    }
}    
 
 
class URPShadertAsset : EndNameEditAction
{
 
    public override void Action(int instanceId, string pathName, string resourceFile)
    {
        UnityEngine.Object o = CreateScriptAssetFromTemplate(pathName, resourceFile);
        ProjectWindowUtil.ShowCreatedAsset(o);
    }
 
    internal static UnityEngine.Object CreateScriptAssetFromTemplate(string pathName, string resourceFile)
    {
        string fullPath = Path.GetFullPath(pathName);
        StreamReader streamReader = new StreamReader(resourceFile);
        string text = streamReader.ReadToEnd();//读取模板内容
        streamReader.Close();
        string fileNameWithoutExtension = Path.GetFileNameWithoutExtension(pathName);
        text = Regex.Replace(text, "#NAME#", fileNameWithoutExtension);//将模板的#NAME# 替换成文件名

        //写入文件，并导入资源
        bool encoderShouldEmitUTF8Identifier = true;
        bool throwOnInvalidBytes = false;
        UTF8Encoding encoding = new UTF8Encoding(encoderShouldEmitUTF8Identifier, throwOnInvalidBytes);
        bool append = false;
        StreamWriter streamWriter = new StreamWriter(fullPath, append, encoding);
        streamWriter.Write(text);
        streamWriter.Close();
        AssetDatabase.ImportAsset(pathName);
        return AssetDatabase.LoadAssetAtPath(pathName, typeof(UnityEngine.Object));
    }
 
}  